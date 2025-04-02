//
//  BEDualModePlusViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartBLEKit
import ThingSmartActivatorDiscoveryManager

class BEDualModePlusViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(DeviceTableViewCell.self, forCellReuseIdentifier: DeviceTableViewCell.identifier)
        table.rowHeight = 60
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var ssidTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Please enter the WiFi name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Please enter the WiFi password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // MARK: - Properties
    private var deviceList: [ThingSmartActivatorDeviceModel] = []
    private var cellModelList: [BEDeviceCellModel] = [] 
    private var isSuccess = false
    
    private lazy var discovery: ThingSmartActivatorDiscovery = {
        let discovery = ThingSmartActivatorDiscovery()
        discovery.register(withActivatorList: [self.typeModel])
        discovery.setupDelegate(self)
        discovery.loadConfig()
        if let currentHome = Home.current {
            discovery.currentSpaceId(currentHome.homeId)
        } else {
            assert((Home.current != nil), "Home cannot be nil, need to create a Home")
        }
        return discovery
    }()
    
    private lazy var typeModel: ThingSmartActivatorTypeBleModel = {
        let type = ThingSmartActivatorTypeBleModel()
        type.type = ThingSmartActivatorType.ble
        type.typeName = NSStringFromThingSmartActivatorType(ThingSmartActivatorType.ble)
        type.timeout = 120
        /// Special attention: Batch network configuration requires this setting, otherwise only the standard single device network configuration will proceed.
        type.activeType = ThingActivatorBleActiveType.batch
        if let currentHome = Home.current {
            type.spaceId = currentHome.homeId
        } else {
            assert((Home.current != nil), "Home cannot be nil, need to create a Home")
        }
        return type
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopConfiguring()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(ssidTextField)
        view.addSubview(passwordTextField)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            ssidTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            ssidTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            ssidTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            ssidTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo: ssidTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            tableView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Dual-mode Pairing"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(searchTapped))
    }
    
    // MARK: - Actions
    @objc private func searchTapped() {
        deviceList.removeAll()
        tableView.reloadData()
        discovery.startSearch([self.typeModel])
        SVProgressHUD.show(withStatus: "Searching for devices...")
    }
    
    // MARK: - Private Methods
    private func stopConfiguring() {
        if !isSuccess {
            SVProgressHUD.dismiss()
        }
        
        discovery.stopSearch([self.typeModel], clearCache: true)
        discovery.stopActive([self.typeModel], clearCache: true)
        discovery.removeDelegate(self)
    }
    
    private func updateDeviceStatus(for deviceCellModel: BEDeviceCellModel) {
        if let index = deviceList.firstIndex(where: { $0.uniqueID == deviceCellModel.deviceModel.uniqueID }) {
            cellModelList[index] = deviceCellModel
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    private func cellModel(for device: ThingSmartActivatorDeviceModel) -> BEDeviceCellModel {
        guard let index = cellModelList.firstIndex(where: { $0.deviceModel.uniqueID == device.uniqueID }) else {
            let deviceCellModel = BEDeviceCellModel(deviceModel: device)
            cellModelList.append(deviceCellModel)
            return deviceCellModel
        }
        
        // 如果找到了索引，返回对应的 cell model
        return cellModelList[index]
    }
    
    private func startConfiguringNetwork(deviceCellModel: BEDeviceCellModel, indexPath: IndexPath) {
        deviceCellModel.deviceStatus = "Adding"
        typeModel.ssid = ssidTextField.text ?? ""
        typeModel.password = passwordTextField.text ?? ""
        updateDeviceStatus(for: deviceCellModel)
    
        // 开始配网
        discovery.startActive(typeModel, deviceList: [deviceCellModel.deviceModel])
//        discovery.startActive(typeModel, deviceList: deviceList)
    
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension BEDualModePlusViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DeviceTableViewCell.identifier, for: indexPath) as! DeviceTableViewCell
        let deviceCellModel = cellModel(for: deviceList[indexPath.row])
        cell.configure(with: deviceCellModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ssidTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        let deviceCellModel = cellModelList[indexPath.row]
        
        guard let ssid = ssidTextField.text, !ssid.isEmpty else {
            SVProgressHUD.showError(withStatus: "Please enter the WiFi name")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            SVProgressHUD.showError(withStatus: "Please enter the WiFi password")
            return
        }
        
        if typeModel.token.isEmpty {
            ThingSmartActivator.sharedInstance()?.getTokenWithHomeId(typeModel.spaceId, success: { [weak self] (token) in
                guard let self = self else { return }
                typeModel.token = token ?? ""
                self.startConfiguringNetwork(deviceCellModel: deviceCellModel, indexPath: indexPath)
            }, failure: { (error) in

            })
        } else {
            startConfiguringNetwork(deviceCellModel: deviceCellModel, indexPath: indexPath)
        }
    }
}

// MARK: - ThingSmartActivatorSearchDelegate
extension BEDualModePlusViewController: ThingSmartActivatorSearchDelegate {
    func activatorService(_ service: ThingSmartActivatorSearchProtocol, activatorType type: ThingSmartActivatorTypeModel, didFindDevice device: ThingSmartActivatorDeviceModel?, error errorModel: ThingSmartActivatorErrorModel?) {
        if errorModel != nil {
            SVProgressHUD.showError(withStatus:"Faulty device")
            return
        }
        
        guard let device = device else { return }
        
        switch device.deviceModelType {
        case ThingSearchDeviceModelTypeBle:
            print("Please use Dual Mode to pair \(device.uniqueID)")
            SVProgressHUD.dismiss()
        case ThingSearchDeviceModelTypeBleWifi:
            if !deviceList.contains(where: { $0.uniqueID == device.uniqueID }) {
                deviceList.append(device)
                tableView.reloadData()
            }
            SVProgressHUD.dismiss()
        default:
            break
        }
    }
    
    func activatorService(_ service: ThingSmartActivatorSearchProtocol, activatorType type: ThingSmartActivatorTypeModel, didUpdateDevice device: ThingSmartActivatorDeviceModel) {
        let devicecellModel = cellModel(for: device)
        updateDeviceStatus(for: devicecellModel)
    }
}

// MARK: - ThingSmartActivatorActiveDelegate
extension BEDualModePlusViewController: ThingSmartActivatorActiveDelegate {
    func activatorService(_ service: ThingSmartActivatorActiveProtocol, activatorType type: ThingSmartActivatorTypeModel, didReceiveDevices devices: [ThingSmartActivatorDeviceModel]?, error errorModel: ThingSmartActivatorErrorModel?) {
        if let errorModel = errorModel {
            let cellModel = cellModel(for: errorModel.deviceModel!)
            cellModel.deviceStatus = "Failed"
            updateDeviceStatus(for: cellModel)
//            SVProgressHUD.showError(withStatus: "Failed to Activate BLE Device")
            
            return
        }
        
        guard let device = devices?.first else { return }
        
        let cellModel = cellModel(for: device)
        cellModel.deviceStatus = "succeed"
        updateDeviceStatus(for: cellModel)
        isSuccess = true
    }
}
