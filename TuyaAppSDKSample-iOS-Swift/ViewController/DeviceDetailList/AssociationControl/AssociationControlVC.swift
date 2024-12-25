//
//  AssociationControlVC.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class AssociationControlVC: UITableViewController {

    var homeId: Int64
    var deviceId: String
    
    init(homeId: Int64, deviceId:String) {
        self.homeId = homeId
        self.deviceId = deviceId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "AssociationControlVCReuseIdentifier")
        
        if (indexPath.row == 0) {
            cell.textLabel?.text = "multi control"
            let support = ThingDeviceAssociationControlManager.checkSupportMultiControl(self.deviceId)
            cell.detailTextLabel?.text = support ? "support" : "unsupport"

        } else {
            cell.textLabel?.text = "double control"
            let support = ThingDeviceAssociationControlManager.checkSupportDoubleControl(self.deviceId)
            cell.detailTextLabel?.text = support ? "support" : "unsupport"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.row == 0) {
            showMulti()
        } else {
            showDouble()
        }
    }
    
    func showMulti() {
        let vc = MultiControlVC(homeId: homeId, deviceId: deviceId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showDouble() {
        let vc = DoubleControlVC(homeId: homeId, deviceId: deviceId)
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
