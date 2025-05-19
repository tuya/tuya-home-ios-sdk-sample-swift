//
//  BEDualModeWifiListTableViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartBLEKit
import ThingSmartActivatorDiscoveryManager
import ThingSmartBaseKit
import ThingSmartBusinessExtensionKit

class BEDualModeWifiListTableViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var connectButton: UIButton!
    
    // MARK: - Property
    private var isSuccess = false
    private var deviceList: [ThingSmartActivatorDeviceModel] = []
    private var wifiList: [[String: Any]] = []
    private var selectedDevice: ThingSmartActivatorDeviceModel?
    private var selectedWiFi: [String: Any]?
    
    // MARK: - Discovery Service
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopConfiguring()
    }
    
    // MARK: - Private Method
    private func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(searchTapped))
        connectButton.isEnabled = false
        passwordTextField.delegate = self
    }
    
    @objc private func searchTapped() {
        // Start finding un-paired BLE devices
        discovery.startSearch([self.typeModel])
        SVProgressHUD.show(withStatus: NSLocalizedString("Searching", comment: ""))
    }
    
    private func stopConfiguring() {
        if !isSuccess {
            SVProgressHUD.dismiss()
        }
        
        discovery.stopSearch([self.typeModel], clearCache: true)
        discovery.stopActive([self.typeModel], clearCache: true)
        discovery.removeDelegate(self)
    }
    
    private func getWiFiList() {
        guard let device = selectedDevice, device.supportAbilityWifiList() else {
            SVProgressHUD.showError(withStatus: "Device does not support WiFi list")
            return
        }
        
        SVProgressHUD.show(withStatus: "Getting WiFi List")
        let param = ThingSmartActivatorScanWifiParam.default()
        param.uuid = device.uniqueID;
        discovery.scanWifiList(
            param,
            activatorTypeModel: typeModel,
            deviceModel: device
        )
    }
    
    @IBAction func connectButtonTapped(_ sender: UIButton) {
        guard let device = selectedDevice,
              let wifi = selectedWiFi,
              let ssid = wifi["ssid"] as? String else {
            return
        }
        
        typeModel.ssid = ssid
        typeModel.password = passwordTextField.text ?? ""
        device.selectAbility = .wifiList
        ThingSmartActivator.sharedInstance()?.getTokenWithHomeId(typeModel.spaceId, success: { [weak self] (token) in
            guard let self = self else { return }
            typeModel.token = token ?? ""
            discovery.startActive(typeModel, deviceList: [device])
            SVProgressHUD.show(withStatus: NSLocalizedString("Activating", comment: "Active BLE."))
        }, failure: { (error) in

        })
    }
}

// MARK: - UITextFieldDelegate
extension BEDualModeWifiListTableViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension BEDualModeWifiListTableViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? deviceList.count : wifiList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Devices" : "WiFi List"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if indexPath.section == 0 {
            let device = deviceList[indexPath.row]
            cell.textLabel?.text = device.name
            cell.detailTextLabel?.text = device.deviceStatus == ThingSearchDeviceStatusNetwork ? "Success" : "Add"
        } else {
            let wifi = wifiList[indexPath.row]
            cell.textLabel?.text = wifi["ssid"] as? String
            if let rssi = wifi["rssi"] as? String {
                cell.detailTextLabel?.text = "Signal: \(rssi)"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedDevice = deviceList[indexPath.row]
            getWiFiList()
        } else {
            selectedWiFi = wifiList[indexPath.row]
            connectButton.isEnabled = true
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - ThingSmartActivatorSearchDelegate
extension BEDualModeWifiListTableViewController: ThingSmartActivatorSearchDelegate {
    func activatorService(
        _ service: ThingSmartActivatorSearchProtocol,
        activatorType type: ThingSmartActivatorTypeModel,
        didFindDevice device: ThingSmartActivatorDeviceModel?,
        error errorModel: ThingSmartActivatorErrorModel?
    ) {
        
        if let errorModel = errorModel {
            SVProgressHUD.showError(withStatus: errorModel.error.localizedDescription)
            return
        }
        
        if let device = device {
            if device.deviceModelType == ThingSearchDeviceModelTypeBle {
                print("Please use Dual Mode to pair: \(device.uniqueID)")
                return
            }
            
            if device.deviceModelType == ThingSearchDeviceModelTypeBleWifi {
                if !deviceList.contains(where: { $0.uniqueID == device.uniqueID }) {
                    deviceList.append(device)
                    tableView.reloadData()
                }
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    func activatorService(_ service: ThingSmartActivatorSearchProtocol, activatorType type: ThingSmartActivatorTypeModel, didUpdateDevice device: ThingSmartActivatorDeviceModel) {
        
    }
}

// MARK: - ThingSmartActivatorActiveDelegate
extension BEDualModeWifiListTableViewController: ThingSmartActivatorActiveDelegate {
    func activatorService(
        _ service: ThingSmartActivatorActiveProtocol,
        activatorType type: ThingSmartActivatorTypeModel,
        didReceiveDevices devices: [ThingSmartActivatorDeviceModel]?,
        error errorModel: ThingSmartActivatorErrorModel?
    ) {
        if let errorModel = errorModel {
            SVProgressHUD.showError(withStatus: errorModel.error.localizedDescription)
            return
        }
        
        if let devices = devices, let device = devices.first {
            if let index = deviceList.firstIndex(where: { $0.uniqueID == device.uniqueID }) {
                deviceList[index].deviceStatus = ThingSearchDeviceStatusNetwork
                tableView.reloadData()
                SVProgressHUD.showSuccess(withStatus: "Device activated successfully")
                isSuccess = true
            }
        }
    }
}


// MARK: - ThingSmartActivatorDeviceExpandDelegate
extension BEDualModeWifiListTableViewController: ThingSmartActivatorDeviceExpandDelegate {
    
    func activatorService(
        _ service: ThingSmartActivatorActiveProtocol,
        activatorType type: ThingSmartActivatorTypeModel,
        didReceiveResponse response: Any?,
        error errorModel: ThingSmartActivatorErrorModel?
    ) {
        
        if let response = response as? ThingActivatorDeviceResponseData,
           response.responseType == .wifiList,
           let wifiArray = response.responseData as? [[String: Any]] {
            wifiList = wifiArray
            tableView.reloadData()
            SVProgressHUD.dismiss()
        }
        
        if let errorModel = errorModel {
            SVProgressHUD.showError(withStatus: errorModel.error.localizedDescription)
            return
        }
        

    }
}
