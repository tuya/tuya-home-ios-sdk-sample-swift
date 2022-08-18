//
//  DualModeTableViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import TuyaSmartBLEKit

class DualModeTableViewController: UITableViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var ssidTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Property
    private var isSuccess = false

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopConfiguring()
    }

    @IBAction func searchTapped(_ sender: UIBarButtonItem) {
        TuyaSmartBLEManager.sharedInstance().delegate = self
        
        // Start finding un-paired BLE devices, it's the same process as single BLE mode.
        TuyaSmartBLEManager.sharedInstance().startListening(true)
        
        SVProgressHUD.show(withStatus: NSLocalizedString("Searching", comment: ""))
        
    }
    
    // MARK: - Private method
    private func stopConfiguring() {
        if !isSuccess {
            SVProgressHUD.dismiss()
        }
        
        TuyaSmartBLEManager.sharedInstance().delegate = nil
        TuyaSmartBLEManager.sharedInstance().stopListening(true)
        
        TuyaSmartBLEWifiActivator.sharedInstance().bleWifiDelegate = nil
        TuyaSmartBLEWifiActivator.sharedInstance().stopDiscover()
    }
}

extension DualModeTableViewController: TuyaSmartBLEManagerDelegate {
    
    // When the BLE detector finds one un-paired BLE device, this delegate method will be called.
    func didDiscoveryDevice(withDeviceInfo deviceInfo: TYBLEAdvModel) {
        guard let homeID = Home.current?.homeId else {
            SVProgressHUD.showError(withStatus: NSLocalizedString("No Home Selected", comment: ""))
            return
        }
        
        let bleType = deviceInfo.bleType
        if bleType == TYSmartBLETypeUnknow ||
            bleType == TYSmartBLETypeBLE ||
            bleType == TYSmartBLETypeBLESecurity ||
            bleType == TYSmartBLETypeBLEPlus ||
            bleType == TYSmartBLETypeBLEZigbee ||
            bleType == TYSmartBLETypeBLEBeacon {
            print("Please use BLE to pair: %@", deviceInfo.uuid ?? "")
            return
        }
        
        SVProgressHUD.show(withStatus: NSLocalizedString("Sending Data to the Device", comment: "Sending Data to the BLE Device"))
        
        // Found a BLE device, then try to config that using TuyaSmartBLEWifiActivator.
        
        TuyaSmartBLEWifiActivator.sharedInstance().bleWifiDelegate = self
        
        TuyaSmartBLEWifiActivator.sharedInstance().startConfigBLEWifiDevice(withUUID: deviceInfo.uuid, homeId: homeID, productId: deviceInfo.productId, ssid: ssidTextField.text ?? "", password: passwordTextField.text ?? "", timeout: 100) {
            SVProgressHUD.show(withStatus: NSLocalizedString("Configuring", comment: ""))
        } failure: {
            SVProgressHUD.showError(withStatus: NSLocalizedString("Failed to Send Data to the Device", comment: ""))
        }

    }
}

extension DualModeTableViewController: TuyaSmartBLEWifiActivatorDelegate {
    
    // When the device connected to the router and activate itself successfully to the cloud, this delegate method will be called.
    func bleWifiActivator(_ activator: TuyaSmartBLEWifiActivator, didReceiveBLEWifiConfigDevice deviceModel: TuyaSmartDeviceModel?, error: Error?) {
        
        guard error == nil,
              let deviceModel = deviceModel else {
            return
        }
        
        let name = deviceModel.name ?? NSLocalizedString("Unknown Name", comment: "Unknown name device.")
        

        SVProgressHUD.showSuccess(withStatus: NSLocalizedString("Successfully Added \(name)", comment: "Successfully added one device."))
        isSuccess = true
        self.navigationController?.popViewController(animated: true)
    }
}
