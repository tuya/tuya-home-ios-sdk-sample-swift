//
//  ZigbeeSubdeviceTableViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import TuyaSmartDeviceKit
import TuyaSmartActivatorKit

class ZigbeeSubdeviceTableViewController: UITableViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var gatewayNameLabel: UILabel!
    
    // MARK: - Property
    var gateway: TuyaSmartDeviceModel?
    private var isSuccess = false

    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        gatewayNameLabel.text = gateway?.name
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopConfiguring()
    }
    
    private func stopConfiguring() {
        guard let deviceID = gateway?.devId else { return }
        
        if !isSuccess {
            SVProgressHUD.dismiss()
        }
        TuyaSmartActivator.sharedInstance()?.delegate = nil
        TuyaSmartActivator.sharedInstance()?.stopActiveSubDevice(withGwId: deviceID)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "choose-gateway-segue",
              let vc = segue.destination as? ChooseGatewayTableViewController
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
        
        TuyaSmartActivator.sharedInstance()?.delegate = self
        
        TuyaSmartActivator.sharedInstance()?.activeSubDevice(withGwId: gateway.devId, timeout: 100)
    }
}

extension ZigbeeSubdeviceTableViewController: TuyaSmartActivatorDelegate {
    func activator(_ activator: TuyaSmartActivator!, didReceiveDevice deviceModel: TuyaSmartDeviceModel!, error: Error!) {
        if deviceModel != nil && error == nil {
            // Success
            let name = deviceModel.name ?? NSLocalizedString("Unknown Name", comment: "Unknown name device.")
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("Successfully Added \(name)", comment: "Successfully added one device."))
            isSuccess = true
            navigationController?.popViewController(animated: true)
        }
        
        if let error = error {
            // Error
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    
}

extension ZigbeeSubdeviceTableViewController: ZigbeeGatewayPayload {
    func didFinishSelecting(_ gateway: TuyaSmartDeviceModel?) {
        self.gateway = gateway
    }
}
