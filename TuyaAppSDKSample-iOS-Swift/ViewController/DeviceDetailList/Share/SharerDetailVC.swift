//
//  SharerDetailVC.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class SharerDetailVC: UITableViewController {

    var sharer: ThingDeviceSharer
    var detail: ThingDeviceSharerDetail?

    init(sharer: ThingDeviceSharer) {
        self.sharer = sharer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DeviceDetailListViewControllerReuseIdentifier")
        
        self.loadData()
    }
    
    func loadData() {
        ThingDeviceShareManager.sharerDetail(sharer.memberId) { result in
            self.detail = result
            self.tableView.reloadData()
        } failure: { e in
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 2
        }else{
            return self.detail?.devices.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "DeviceDetailListViewControllerReuseIdentifier")

        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.textLabel?.text = "sharer"
                cell.detailTextLabel?.text = self.detail?.name
            }else{
                cell.textLabel?.text = "remark"
                cell.detailTextLabel?.text = self.detail?.remarkName
            }
        }else{
            cell.textLabel?.text = self.detail?.devices[indexPath.row].name
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == 0 && indexPath.row == 1) {
            self.showUpdateRemarkAlert()
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 0) {return false}
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.remove(device: self.detail!.devices[indexPath.row])
    }
    
    func remove(device: ThingSmartShareDeviceModel) {
        SVProgressHUD.show()
        ThingDeviceShareManager.removeShare(device.devId, resType: .device) {
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: "success")
            self.loadData()
        } failure: { e in
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: "failure")
        }
    }
    
    func showUpdateRemarkAlert() {
        let alertController = UIAlertController(title: "update remark", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "input the new remark"
        }
        let confirmAction = UIAlertAction(title: "ok", style: .default) { (_) in
            guard let textField = alertController.textFields?.first, let text = textField.text else {return}
            self.updateRemark(text)
        }
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateRemark(_ remark: String) {
        SVProgressHUD.show()
        ThingDeviceShareManager.updateSharer(self.sharer.memberId, name: remark) {
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: "success")
            self.loadData()
        } failure: { e in
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: "failure")
        }
    }

}
