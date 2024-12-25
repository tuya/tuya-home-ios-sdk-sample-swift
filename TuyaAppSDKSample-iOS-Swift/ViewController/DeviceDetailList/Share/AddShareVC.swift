//
//  AddShareVC.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class AddShareVC: UITableViewController {

    var homeId: Int64
    var resType: ThingShareResType
    var resId: String
        
    init(homeId: Int64, resType:ThingShareResType, resId:String) {
        self.homeId = homeId
        self.resType = resType
        self.resId = resId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    var deviceItems: [[String:Any]] = [
        ["text": "share to user", "key": 0, "type": -1],
        ["text": "share link - account", "key": 1, "type": 0],
        ["text": "share link - qq", "key": 1, "type": 1],
        ["text": "share link - wechat", "key": 1, "type": 2],
        ["text": "share link - message", "key": 1, "type": 3],
        ["text": "share link - email", "key": 1, "type": 4],
        ["text": "share link - copy", "key": 1, "type": 5],
        ["text": "share link - more", "key": 1, "type": 6],
        ["text": "share link - contact", "key": 1, "type": 7],
    ]
    
    var groupItems: [[String:Any]] = [
        ["text": "share to user", "key": 0, "type": -1],
    ]
    
    var remindShareTimes: Int32 = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DeviceDetailListViewControllerReuseIdentifier")
        
        ThingDeviceShareManager.remainingShareTimes(self.resId, resType: self.resType) { times in
            self.remindShareTimes = times
            self.tableView.reloadData()
        } failure: { e in
            self.remindShareTimes = 0
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        }else{
            if (self.resType == .device) {
                return self.deviceItems.count
            }else{
                return self.groupItems.count
            }
            
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "DeviceDetailListViewControllerReuseIdentifier")

        if (indexPath.section == 0) {
            cell.textLabel?.text = "remindingShareTimes"
            cell.detailTextLabel?.text = self.remindShareTimes == -1 ? "not limit" : "\(self.remindShareTimes)"
        }else{
            let map = self.resType == .device ? self.deviceItems[indexPath.row] : self.groupItems[indexPath.row]
            cell.textLabel?.text = map["text"] as? String
            cell.detailTextLabel?.text = ""
        }
                
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == 0) {
            
        }else{
            let map = self.resType == .device ? self.deviceItems[indexPath.row] : self.groupItems[indexPath.row]
            self.share(item: map)
        }
    }

    func share(item: [String:Any]) {
        let key = item["key"] as! Int
        if (key == 0) {
            
            let alertController = UIAlertController(title: "share to user", message: nil, preferredStyle: .alert)
            alertController.addTextField { (textField) in
                textField.placeholder = "input the account of user"
            }
            let confirmAction = UIAlertAction(title: "ok", style: .default) { (_) in
                guard let textField = alertController.textFields?.first, let text = textField.text else {return}
                self.shareTo(user: text)
            }
            alertController.addAction(confirmAction)
            
            let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }else{
            let type = item["type"] as! Int
            
            let alertController = UIAlertController(title: "create share link", message: nil, preferredStyle: .alert)
            alertController.addTextField { (textField) in
                textField.placeholder = "input the share times"
            }
            let confirmAction = UIAlertAction(title: "ok", style: .default) { (_) in
                guard let textField = alertController.textFields?.first, let text = textField.text, let num = Int32(text) else {return}
                self.shareLink(num: num, type: type)
            }
            alertController.addAction(confirmAction)
            
            let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func shareTo(user: String) {
        SVProgressHUD.show()
        ThingDeviceShareManager.share(self.resId, resType: self.resType, spaceId: self.homeId, userAccount: user) { result in
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: "success")
        } failure: { e in
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: "failure")
        }
    }
    
    func shareLink(num: Int32, type: Int) {
        guard let shareType = ThingDeviceShareType(rawValue: type) else {return}
        
        SVProgressHUD.show()
        ThingDeviceShareManager.createShareInfo(self.resId, resType: self.resType, spaceId: self.homeId, shareType: shareType, shareCount: num) { info in
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: "success \(info.code)")
        } failure: { e in
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: "failure")
        }

    }

}
