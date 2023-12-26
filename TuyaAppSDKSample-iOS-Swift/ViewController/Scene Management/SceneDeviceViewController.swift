//
//  SceneDeviceViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation

enum DeviceType: Int{
    case Condition
    case Action
}

class SceneDeviceViewController: UITableViewController {
    
    var deviceList: [SceneDeviceNode]? = []
    var deviceType: DeviceType = .Condition
    var selectionCompletion: ((AnyObject)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Device List"
        
        switch self.deviceType {
        case .Condition:
            self.fetchDeviceList()
        case .Action:
            self.fetchActionDeviceList()
        }
    }
    
    func fetchDeviceList() {
        guard let homeID = Home.current?.homeId else {
            SVProgressHUD.showError(withStatus: "HomeID is Empty")
            return
        }
        SVProgressHUD.show(withStatus: "Fetch Condition Device List")
        ThingSmartSceneManager.sharedInstance().getConditionDeviceList(withHomeId: homeID) { deviceModels in
            SVProgressHUD.dismiss()
            for deviceModel in deviceModels {
                let nodeModel = SceneDeviceNode(deviceModel: deviceModel)
                self.deviceList?.append(nodeModel)
            }
            self.tableView.reloadData()
        } failure: { error in
            let errorMessage = error?.localizedDescription ?? ""
            SVProgressHUD.showError(withStatus: errorMessage)
        }
    }
    
    func fetchActionDeviceList() {
        guard let homeID = Home.current?.homeId else {
            SVProgressHUD.showError(withStatus: "HomeID is Empty")
            return
        }
        SVProgressHUD.show(withStatus: "Fetch Action Device List")
        ThingSmartSceneManager.sharedInstance().getActionGroupListAndDeviceList(withHomeId: homeID) { deviceMap in
            SVProgressHUD.dismiss()
            if let groupList = deviceMap?["groupList"] as? [ThingSmartGroupModel] {
                for groupModel in groupList {
                    let nodeModel = SceneDeviceNode(groupModel: groupModel)
                    self.deviceList?.append(nodeModel)
                }
            }
            if let deviceList = deviceMap?["deviceList"] as? [ThingSmartDeviceModel] {
                for deviceModel in deviceList {
                    let nodeModel = SceneDeviceNode(deviceModel: deviceModel)
                    self.deviceList?.append(nodeModel)
                }
            }
            self.tableView.reloadData()
        } failure: { error in
            let errorMessage = error?.localizedDescription ?? ""
            SVProgressHUD.showError(withStatus: errorMessage)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let nodeModel = self.deviceList?[indexPath.row] {
            switch nodeModel.nodeType {
            case .Device:
                let sceneDPVC = SceneDPViewController()
                sceneDPVC.dpBizType = self.deviceType == .Condition ? .ConditionDevice : .ActionDeivce
                sceneDPVC.currentNode = nodeModel
                sceneDPVC.selectionCompletion = self.selectionCompletion
                self.navigationController?.pushViewController(sceneDPVC, animated: true)
            case .Group:
                let sceneDPVC = SceneDPViewController()
                sceneDPVC.dpBizType = .ActionGroup
                sceneDPVC.currentNode = nodeModel
                sceneDPVC.selectionCompletion = self.selectionCompletion
                self.navigationController?.pushViewController(sceneDPVC, animated: true)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        if let nodeModel = self.deviceList?[indexPath.row] {
            cell.textLabel?.text = nodeModel.name
        }
        return cell
    }
}
