//
//  ZigbeeSubdeviceTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartDeviceKit
import ThingSmartActivatorKit
import ThingSmartActivatorDiscoveryManager

class BEZigbeeSubdeviceTableViewController: UITableViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var gatewayNameLabel: UILabel!
    
    // MARK: - Property
    var gateway: ThingSmartDeviceModel?
    private var isSuccess = false
    var deviceList:[ThingSmartActivatorDeviceModel] = []
    
    private var typeModel: ThingSmartActivatorTypeSubDeviceModel = {
        let type = ThingSmartActivatorTypeSubDeviceModel()
        type.type = ThingSmartActivatorType.subDevice
        type.typeName = NSStringFromThingSmartActivatorType(ThingSmartActivatorType.subDevice)
        type.timeout = 120
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let gatewayName = gateway?.name
        if ((gatewayName) != nil) {
            gatewayNameLabel.text = gatewayName
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopConfiguring()
    }
    
    override func viewDidLoad() {
        
    }
    
    private func stopConfiguring() {
        guard let deviceID = gateway?.devId else { return }
        
        if !isSuccess {
            SVProgressHUD.dismiss()
        }
        discovery.stopSearch([typeModel], clearCache: true)
        discovery.stopActive([typeModel], clearCache: true)
        discovery.removeDelegate(self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "Choose Gateway",
              let vc = segue.destination as? BEChooseGatewayTableViewController
        else { return }
        
        vc.selectedGateway = gateway
        vc.delegate = self
    }

    // MARK: - IBAction
    @IBAction func searchTapped(_ sender: UIBarButtonItem) {
        guard let gateway = gateway else {
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Select Zigbee Gateway", comment: ""), message: NSLocalizedString("You must have one Zigbee gateway selected.", comment: ""))
            return
        }
        
        SVProgressHUD.show(withStatus: NSLocalizedString("Configuring", comment: ""))
        typeModel.gwDevId = gateway.devId
        discovery.startSearch([typeModel])
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return deviceList.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "zigbeeDeviceCell")!
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "zigbeeDeviceCell")!
            cell.textLabel?.text = deviceList[indexPath.row].name
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
    }
}

extension BEZigbeeSubdeviceTableViewController: ThingSmartActivatorSearchDelegate {
    func activatorService(_ service: ThingSmartActivatorSearchProtocol, activatorType type: ThingSmartActivatorTypeModel, didFindDevice device: ThingSmartActivatorDeviceModel?, error errorModel: ThingSmartActivatorErrorModel?) {
        if device != nil && errorModel == nil {
            // Success
            let name = device?.name ?? NSLocalizedString("Unknown Name", comment: "Unknown name device.")
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("Successfully Added \(name)", comment: "Successfully added one device."))
            isSuccess = true
            
            
//            deviceList.append(device!)
//            tableView.reloadData()
            SVProgressHUD.dismiss()
        }
        
        if let error = errorModel?.error {
            // Error
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    func activatorService(_ service: ThingSmartActivatorSearchProtocol, activatorType type: ThingSmartActivatorTypeModel, didUpdateDevice device: ThingSmartActivatorDeviceModel) {
        
    }
}

extension BEZigbeeSubdeviceTableViewController: BEZigbeeGatewayPayload {
    func didFinishSelecting(_ gateway: ThingSmartDeviceModel?) {
        self.gateway = gateway
    }
}
