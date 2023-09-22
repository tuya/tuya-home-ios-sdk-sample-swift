//
//  ZigbeeGatewayViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartActivatorKit
import ThingSmartActivatorDiscoveryManager

class BEZigbeeGatewayViewController: UIViewController {

    // MARK: - Property
    private var token: String = ""
    private var isSuccess = false
    @IBOutlet weak var tableview: UITableView!
    var deviceList:[ThingSmartActivatorDeviceModel] = []
    
    private var typeModel: ThingSmartActivatorTypeWiredModel = {
        let type = ThingSmartActivatorTypeWiredModel()
        type.type = ThingSmartActivatorType.wired
        type.typeName = NSStringFromThingSmartActivatorType(ThingSmartActivatorType.wired)
        type.timeout = 120
        if let currentHome = Home.current {
            type.spaceId = currentHome.homeId
        } else {
            assert((Home.current != nil),"Home cannot be nil, need to create a Home")
        }
        return type
    }()
    
    lazy var discovery: ThingSmartActivatorDiscovery = {
        let discovery = ThingSmartActivatorDiscovery()
        discovery.register(withActivatorList: [self.typeModel])
        discovery.setupDelegate(self)
        discovery.loadConfig()
        return discovery
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopConfigWifi()
    }
    
    // MARK: - IBAction
    @IBAction func searchTapped(_ sender: UIBarButtonItem) {
        discovery.startSearch([self.typeModel])
        SVProgressHUD.show(withStatus: NSLocalizedString("Searching", comment: ""))
    }

    
    private func stopConfigWifi() {
        if !isSuccess {
            SVProgressHUD.dismiss()
        }
        discovery.stopActive([self.typeModel], clearCache: true)
        discovery.removeDelegate(self)
    }
}

extension BEZigbeeGatewayViewController: UITableViewDelegate,UITableViewDataSource {
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "zibgeegatewaycell")!
        cell.textLabel?.text = deviceList[indexPath.row].name
        cell.detailTextLabel?.text = deviceList[indexPath.row].deviceStatus == ThingSearchDeviceStatusNetwork ? "Success":"Add";
        cell.accessoryType = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        guard let homeID = Home.current?.homeId else { return }
        SVProgressHUD.show(withStatus: NSLocalizedString("Requesting for Token", comment: ""))

        ThingSmartActivator.sharedInstance()?.getTokenWithHomeId(homeID, success: { [weak self] (token) in
            guard let self = self else { return }
            typeModel.token = token ?? ""
            let deviceModel = deviceList[indexPath.row]
            discovery.startActive(typeModel, deviceList: [deviceModel])
            SVProgressHUD.show(withStatus: NSLocalizedString("Activating", comment: "Active Zigbee gateway."))
        }, failure: { (error) in
            let errorMessage = error?.localizedDescription ?? ""
            SVProgressHUD.showError(withStatus: errorMessage)
        })
        
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension BEZigbeeGatewayViewController: ThingSmartActivatorSearchDelegate {
    func activatorService(_ service: ThingSmartActivatorSearchProtocol, activatorType type: ThingSmartActivatorTypeModel, didFindDevice device: ThingSmartActivatorDeviceModel?, error errorModel: ThingSmartActivatorErrorModel?) {
        if (device != nil) {
            SVProgressHUD.dismiss()
            deviceList.append(device!)
            tableview.reloadData()
        }
    }
    
    func activatorService(_ service: ThingSmartActivatorSearchProtocol, activatorType type: ThingSmartActivatorTypeModel, didUpdateDevice device: ThingSmartActivatorDeviceModel) {
        
    }
    
}

extension BEZigbeeGatewayViewController: ThingSmartActivatorActiveDelegate {
    func activatorService(_ service: ThingSmartActivatorActiveProtocol, activatorType type: ThingSmartActivatorTypeModel, didReceiveDevices devices: [ThingSmartActivatorDeviceModel]?, error errorModel: ThingSmartActivatorErrorModel?) {
        if (errorModel != nil) {
            SVProgressHUD.showError(withStatus: NSLocalizedString("Failed to Activate BLE Device", comment: ""))
            return
        }
        
        if (devices!.count > 0) {
            let device = devices?.first
            var successDevice: ThingSmartActivatorDeviceModel?

            self.deviceList.forEach { obj in
                if device!.isEqual(toDevice: obj) {
                    successDevice = obj
                }
            }
            
            SVProgressHUD.dismiss()
            successDevice?.deviceStatus = ThingSearchDeviceStatusNetwork
            tableview.reloadData()
            
        }
    }
    

}
