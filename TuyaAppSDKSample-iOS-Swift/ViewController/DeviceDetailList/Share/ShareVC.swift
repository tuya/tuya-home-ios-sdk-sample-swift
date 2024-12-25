//
//  ShareVC.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class ShareVC: UITableViewController {

    var homeId: Int64
    var resType: ThingShareResType
    var resId: String
    
    var supportShare: Bool = false
    
    init(homeId: Int64, resType:ThingShareResType, resId:String) {
        self.homeId = homeId
        self.resType = resType
        self.resId = resId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DeviceDetailListViewControllerReuseIdentifier")
        
        ThingDeviceShareManager.supportShare(self.resId, resType: self.resType) { support in
            self.supportShare = support
            self.tableView.reloadData()
        } failure: { e in
            self.supportShare = false
            self.tableView.reloadData()
        }
    }
    

    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "DeviceDetailListViewControllerReuseIdentifier")

        if (indexPath.section == 0) {
            cell.textLabel?.text = "shara to user"
            cell.detailTextLabel?.text = self.supportShare ? "support" : "unsupport"

        }else if (indexPath.section == 1) {
            cell.textLabel?.text = "go to receivers"
            cell.detailTextLabel?.text = ""
        }else if (indexPath.section == 2) {
            cell.textLabel?.text = "go to relations"
            cell.detailTextLabel?.text = ""
        }else if (indexPath.section == 3){
            cell.textLabel?.text = "accept share invate with code"
            cell.detailTextLabel?.text = ""
        }else{
            cell.textLabel?.text = "go to sharer"
            cell.detailTextLabel?.text = ""
        }
                
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == 0) {
            self.share()
        }else if (indexPath.section == 1) {
            self.receivers()
        }else if (indexPath.section == 2) {
            self.relations()
        } else if (indexPath.section == 3) {
            self.shareCode()
        }else if (indexPath.section == 4) {
            self.sharer()
        }
    }
    
    func share() {
        if (self.supportShare == false) {
            let alertController = UIAlertController(title: nil, message: "do not support share", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        let vc = AddShareVC(homeId: self.homeId, resType: self.resType, resId: self.resId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func receivers() {
        if (self.supportShare == false) {
            let alertController = UIAlertController(title: nil, message: "do not support share", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        let vc = ShareReceiverVC(homeId: self.homeId, resType: self.resType, resId: self.resId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func relations() {
        let vc = ShareRelationVC(homeId: self.homeId, resType: self.resType, resId: self.resId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func shareCode() {
        let alertController = UIAlertController(title: "accept share code", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "input the share code"
        }
        let confirmAction = UIAlertAction(title: "ok", style: .default) { (_) in
            guard let textField = alertController.textFields?.first, let text = textField.text else {return}
            self.validShareCode(text)
        }
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func validShareCode(_ code:String) {
        SVProgressHUD.show()
        ThingDeviceShareManager.validate(code) { result in
            if (result) {
                SVProgressHUD.dismiss()
                self.invateShare(code)
            }else{
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: "failure")
            }
        } failure: { e in
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: "failure")
        }
    }
    
    func invateShare(_ code:String) {
        ThingDeviceShareManager.shareCodeInfo(code) { codeInfo in
            self.showAcceptShareAlert(code, info: codeInfo)
        } failure: { e in
            SVProgressHUD.showError(withStatus: "failure")
        }
    }
    
    func showAcceptShareAlert(_ code:String, info: ThingDeviceShareCodeInfo) {
        let alertController = UIAlertController(title: "accept share", message: "\(info.nickName) share \(info.resName) to you", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "ok", style: .default) { (_) in
            self.acceptShare(code)
        }
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func acceptShare(_ code:String) {
        SVProgressHUD.show()
        ThingDeviceShareManager.accept(code) {
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: "success")
        } failure: { e in
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: "failure")
        }
    }
    
    func sharer() {
        let vc = SharerVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
