//
//  SceneDPViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartSceneCoreKit
import ThingSmartDeviceCoreKit
import ThingSmartDeviceCoreKit.ThingSmartSchemaModel

enum DPBizType: Int {
    case ConditionDevice
    case ActionGroup
    case ActionDeivce
}

class SceneDPViewController: UITableViewController {
    var dpList: [AnyObject]? = []
    var dpBizType: DPBizType = .ConditionDevice
    var currentNode: SceneDeviceNode?
    var selectionCompletion: ((AnyObject)->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "DP List"
        
        switch self.dpBizType {
        case .ConditionDevice:
            self.fetchConditionDeviceDPList()
        case .ActionGroup:
            self.fetchActionGroupDPList()
        case .ActionDeivce:
            self.fetchActionDeviceDPList()
        }
    }
    
    // MARK: - Request
    func fetchConditionDeviceDPList() {
        ThingSmartSceneManager.sharedInstance().getCondicationDeviceDPList(withDevId: currentNode?.nodeID) { sceneDPModels in
            self.dpList = sceneDPModels
            self.tableView.reloadData()
        } failure: { error in
            let errorMessage = error?.localizedDescription ?? ""
            SVProgressHUD.showError(withStatus: errorMessage)
        }
    }
    
    func fetchActionDeviceDPList() {
        ThingSmartSceneManager.sharedInstance().getNewActionDeviceDPList(withDevId: currentNode?.nodeID) { featureModels in
            self.dpList = featureModels
            self.tableView.reloadData()
        } failure: { error in
            let errorMessage = error?.localizedDescription ?? ""
            SVProgressHUD.showError(withStatus: errorMessage)
        }
    }
    
    func fetchActionGroupDPList() {
        ThingSmartSceneManager.sharedInstance().getNewActionGroupDPList(withGroupId: currentNode?.nodeID) { featureModels in
            self.dpList = featureModels
            self.tableView.reloadData()
        } failure: { error in
            let errorMessage = error?.localizedDescription ?? ""
            SVProgressHUD.showError(withStatus: errorMessage)
        }
    }
    
    func backToAddScenePage() {
        // 导航控制器回到指定视图控制器
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController is AddSceneViewController {
                    navigationController?.popToViewController(viewController, animated: true)
                    break
                }
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let dpModel = self.dpList?[indexPath.row] {
            
            // is SceneDPModel
            if dpModel is ThingSmartSceneDPModel {
                
                let deviceModel = currentNode?.deviceModel
                var deviceExpr: ThingSmartSceneExprModel
                switch dpModel.dpModel.property.type {
                case "bool":
                    deviceExpr = ThingSmartSceneConditionExprBuilder.createBoolExpr(withType: dpModel.entitySubId, isTrue: true, exprType: .device)
                case "value":
                    deviceExpr = ThingSmartSceneConditionExprBuilder.createValueExpr(withType: dpModel.entitySubId, operater: "==", chooseValue: 100, exprType: .device)
                case "enum":
                    let valueRange = dpModel.valueRangeJson[0]
                    if let value = valueRange as? [String] {
                        let res = value[0]
                        deviceExpr = ThingSmartSceneConditionExprBuilder.createEnumExpr(withType: dpModel.entitySubId, chooseValue: res, exprType: .device)
                    } else {
                        deviceExpr = ThingSmartSceneExprModel()
                    }
                default:
                    deviceExpr = ThingSmartSceneConditionExprBuilder.createBoolExpr(withType: dpModel.entitySubId, isTrue: true, exprType: .device)
                }
                
                if let deviceCondition = ThingSmartSceneConditionFactory.createDeviceCondition(withDevice: deviceModel, dpModel: dpModel as? ThingSmartSceneDPModel, exprModel: deviceExpr) {
                    
                    self.backToAddScenePage()
                    
                    if let completion = selectionCompletion {
                        completion(deviceCondition)
                    }
                }
            }
            
            // is FeatureModel
            if dpModel is ThingSmartSceneCoreFeatureModel {
                
                if let deviceModel = currentNode?.deviceModel {
                    if let featureModel = dpModel as? ThingSmartSceneCoreFeatureModel,
                       let actionDPModel = featureModel.dataPoints[0] as? ThingSmartSceneCoreActionDpModel {
                        actionDPModel.selectedRow = 0
                    }

                    let deviceAction = ThingSmartSceneActionFactory.deviceAction(withFeature: dpModel as! ThingSmartSceneCoreFeatureModel, devId: deviceModel.devId, deviceName: deviceModel.name)
                        
                    self.backToAddScenePage()
                    if let completion = selectionCompletion {
                        completion(deviceAction)
                    }
                }
                if let groupModel = currentNode?.groupModel {
                    if let featureModel = dpModel as? ThingSmartSceneCoreFeatureModel,
                       let actionDPModel = featureModel.dataPoints[0] as? ThingSmartSceneCoreActionDpModel {
                        actionDPModel.selectedRow = 0
                    }
                    
                    let groupAction = ThingSmartSceneActionFactory.groupAction(withFeature: dpModel as! ThingSmartSceneCoreFeatureModel, groupId: groupModel.groupId, groupName: groupModel.name)
                    
                    self.backToAddScenePage()
                    if let completion = selectionCompletion {
                        completion(groupAction)
                    }
                }
            }
        }
    }
    
    // MARK: - UITableViewDatasource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dpList?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        if let nodeModel = self.dpList?[indexPath.row] {
            if nodeModel is ThingSmartSceneDPModel {
                cell.textLabel?.text = nodeModel.entityName
            }
            if nodeModel is ThingSmartSceneCoreFeatureModel {
                cell.textLabel?.text = nodeModel.functionName
            }
        }
        return cell
    }
}

