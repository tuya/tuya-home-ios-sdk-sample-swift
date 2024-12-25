//
//  SharerVC.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class SharerVC: UITableViewController {

    
    var sharers: [ThingDeviceSharer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DeviceDetailListViewControllerReuseIdentifier")
        
        self.loadData()
    }
    
    func loadData() {
        ThingDeviceShareManager.sharers { result in
            self.sharers = result ?? []
            self.tableView.reloadData()
        } failure: { e in
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sharers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "DeviceDetailListViewControllerReuseIdentifier")
        cell.textLabel?.text = self.sharers[indexPath.row].userName
        cell.detailTextLabel?.text = "\(self.sharers[indexPath.row].memberId)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.showShareDetail(sharer: self.sharers[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.remove(sharer: self.sharers[indexPath.row])
    }
    
    func remove(sharer: ThingDeviceSharer) {
        SVProgressHUD.show()
        ThingDeviceShareManager.removeSharer(sharer.memberId) {
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: "success")
            self.loadData()
        } failure: { e in
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: "failure")
        }
    }
    
    func showShareDetail(sharer: ThingDeviceSharer) {
        let vc = SharerDetailVC(sharer: sharer)
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
