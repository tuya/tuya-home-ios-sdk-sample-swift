//
//  DeviceDetailKitInfoVC.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class DeviceDetailKitInfoVC: UITableViewController {

    var deviceId: String
    var manager: ThingDeviceInfoManager
    var items: [CustomMenuModel] = []
    
    init(deviceId: String) {
        self.deviceId = deviceId
        self.manager = ThingDeviceInfoManager(deviceId: deviceId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DeviceDetailListViewControllerReuseIdentifier")
        self.manager.add(self)
        self.loadData()
        
    }
    
    func loadData() {
        SVProgressHUD.show()
        self.manager.fetchDataSuccess { [weak self] info, hardware in
            var list = [CustomMenuModel]()
            list.append(CustomMenuModel(title: "devId", detail: info.devId))
            list.append(CustomMenuModel(title: "iccid", detail: info.iccid ?? ""))
            list.append(CustomMenuModel(title: "netStrength", detail: info.netStrength ?? ""))
            list.append(CustomMenuModel(title: "lanIp", detail: info.lanIp ?? ""))
            list.append(CustomMenuModel(title: "ip", detail: info.ip ?? ""))
            list.append(CustomMenuModel(title: "mac", detail: info.mac ?? ""))
            list.append(CustomMenuModel(title: "timezone", detail: info.timezone ?? ""))
            list.append(CustomMenuModel(title: "channel", detail: info.channel ?? ""))
            list.append(CustomMenuModel(title: "rsrp", detail: info.rsrp != nil ? "\(info.rsrp!)" : ""))
            list.append(CustomMenuModel(title: "wifiSignal", detail: info.wifiSignal != nil ? "\(info.wifiSignal!)" : ""))
            list.append(CustomMenuModel(title: "homekitCode", detail: info.homekitCode ?? ""))
            list.append(CustomMenuModel(title: "connectAbility", detail: "\(info.connectAbility)"))
            list.append(CustomMenuModel(title: "vendorName", detail: info.vendorName ?? ""))
            self?.items = list
            self?.tableView.reloadData()
            SVProgressHUD.dismiss()
        } failure: { e in
            SVProgressHUD.dismiss()
        }

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "DeviceDetailListViewControllerReuseIdentifier")
        cell.textLabel?.text = self.items[indexPath.row].title
        cell.detailTextLabel?.text = self.items[indexPath.row].detail
        return cell
    }

}

extension DeviceDetailKitInfoVC: ThingDeviceInfoManagerListener {
    func deviceInfoManager(_ manager: ThingDeviceInfoManager, wifiSignalDidUpdate wifiSignal: Int32) {
        let item = self.items.first { item in
            return item.title == "wifiSignal"
        }
        item?.detail = "\(wifiSignal)"
        self.tableView.reloadData()
    }
}
