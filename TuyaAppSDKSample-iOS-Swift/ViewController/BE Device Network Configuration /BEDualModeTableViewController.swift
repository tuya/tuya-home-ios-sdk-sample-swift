//
//  DualModeTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartBLEKit
import ThingSmartActivatorDiscoveryManager

class BEDualModeTableViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var ssidTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var tableview: UITableView!
    var deviceList:[ThingSmartActivatorDeviceModel] = []
    lazy var discovery: ThingSmartActivatorDiscovery = {
        let discovery = ThingSmartActivatorDiscovery()
        discovery.register(withActivatorList: [self.typeModel])
        discovery.setupDelegate(self)
        discovery.loadConfig()
        if let currentHome = Home.current {
            discovery.currentSpaceId(currentHome.homeId)
        } else {
            assert((Home.current != nil),"Home cannot be nil, need to create a Home")
        }
        return discovery
    }()
    
    private lazy var typeModel: ThingSmartActivatorTypeBleModel = {
        let type = ThingSmartActivatorTypeBleModel()
        type.type = ThingSmartActivatorType.ble
        type.typeName = NSStringFromThingSmartActivatorType(ThingSmartActivatorType.ble)
        type.timeout = 120
        if let currentHome = Home.current {
            type.spaceId = currentHome.homeId
        } else {
            assert((Home.current != nil),"Home cannot be nil, need to create a Home")
        }
        return type
    }()
    
    // MARK: - Property
    private var isSuccess = false

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopConfiguring()
    }

    @IBAction func searchTapped(_ sender: UIBarButtonItem) {
        // Start finding un-paired BLE devices, it's the same process as single BLE mode.
        discovery.startSearch([self.typeModel])
        
        SVProgressHUD.show(withStatus: NSLocalizedString("Searching", comment: ""))
        
    }
    
    // MARK: - Private method
    private func stopConfiguring() {
        if !isSuccess {
            SVProgressHUD.dismiss()
        }
        
        discovery.stopSearch([self.typeModel], clearCache: true)
        discovery.stopActive([self.typeModel], clearCache: true)
        discovery.removeDelegate(self)
    }
}

extension BEDualModeTableViewController: UITableViewDelegate,UITableViewDataSource {
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dualDeviceCell")!
        cell.textLabel?.text = deviceList[indexPath.row].name
        cell.detailTextLabel?.text = deviceList[indexPath.row].deviceStatus == ThingSearchDeviceStatusNetwork ? "Success":"Add";
        cell.accessoryType = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        
        let deviceModel = deviceList[indexPath.row]
        typeModel.ssid = ssidTextField.text ?? ""
        typeModel.password = passwordTextField.text ?? ""
        discovery.startActive(typeModel, deviceList: [deviceModel])
        SVProgressHUD.show(withStatus: NSLocalizedString("Activating", comment: "Active BLE."))
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - ThingSmartActivatorSearchDelegate
extension BEDualModeTableViewController: ThingSmartActivatorSearchDelegate {
    func activatorService(_ service: ThingSmartActivatorSearchProtocol, activatorType type: ThingSmartActivatorTypeModel, didFindDevice device: ThingSmartActivatorDeviceModel?, error errorModel: ThingSmartActivatorErrorModel?) {
        
        if let device = device {
            if device.deviceModelType == ThingSearchDeviceModelTypeBle {
                print("Please use Dual Mode to pair: %@", device.uniqueID)
                SVProgressHUD.dismiss()
                return
            }
            
            if device.deviceModelType == ThingSearchDeviceModelTypeBleWifi {
                deviceList.append(device)
                tableview.reloadData()
            }

            SVProgressHUD.dismiss()
        }
    }
    
    func activatorService(_ service: ThingSmartActivatorSearchProtocol, activatorType type: ThingSmartActivatorTypeModel, didUpdateDevice device: ThingSmartActivatorDeviceModel) {
        
    }

}

// MARK: - ThingSmartActivatorSearchDelegate
extension BEDualModeTableViewController: ThingSmartActivatorActiveDelegate {
    func activatorService(_ service: ThingSmartActivatorActiveProtocol, activatorType type: ThingSmartActivatorTypeModel, didReceiveDevices devices: [ThingSmartActivatorDeviceModel]?, error errorModel: ThingSmartActivatorErrorModel?) {
        if let errorModel = errorModel {
            
            SVProgressHUD.showError(withStatus: NSLocalizedString("Failed to Activate BLE Device", comment: ""))
            return
        }
        
        if let devices = devices {
            let device = devices.first
            var successDevice: ThingSmartActivatorDeviceModel?

            self.deviceList.forEach { obj in
                if device!.isEqual(toDevice: obj) {
                    successDevice = obj
                }
            }
            
            successDevice?.deviceStatus = ThingSearchDeviceStatusNetwork
            tableview.reloadData()
        }
    }
}
