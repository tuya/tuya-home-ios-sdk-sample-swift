//
//  BEDeviceNetworkListViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import UIKit


class BEDeviceNetworkListViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Function List"
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
