//
//  ShareRelationVC.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class ShareRelationVC: UITableViewController {

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
    
    
    var members: [ThingSmartShareMemberModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DeviceDetailListViewControllerReuseIdentifier")
        
        self.loadData()
    }
    
    func loadData() {
        ThingDeviceShareManager.relationMembers { result in
            self.members = result ?? []
            self.tableView.reloadData()
        } failure: { e in
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.members.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "DeviceDetailListViewControllerReuseIdentifier")
        cell.textLabel?.text = self.members[indexPath.row].userName
        cell.detailTextLabel?.text = "\(self.members[indexPath.row].memberId)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.remove(relation: self.members[indexPath.row])
    }
    
    func remove(relation: ThingSmartShareMemberModel) {
        SVProgressHUD.show()
        ThingDeviceShareManager.removeRelationMember(relation.uid) {
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: "success")
            self.loadData()
        } failure: { e in
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: "failure")
        }
    }
}
