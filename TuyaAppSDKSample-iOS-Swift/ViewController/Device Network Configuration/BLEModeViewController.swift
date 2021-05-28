//
//  BLEModeViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import TuyaSmartBLEKit

class BLEModeViewController: UIViewController {

    // MARK: - Property
    private var isSuccess = false
    
    // MARK: - Lifecycle
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopConfigBLE()
    }
   
    // MARK: - IBAction
    @IBAction func searchTapped(_ sender: UIBarButtonItem) {
        TuyaSmartBLEManager.sharedInstance().delegate = self
        
        // Start finding un-paired BLE devices.
        TuyaSmartBLEManager.sharedInstance().startListening(true)
        
        SVProgressHUD.show(withStatus: NSLocalizedString("Searching", comment: ""))
    }
    
    // MARK: - Private method
    private func stopConfigBLE() {
        if !isSuccess {
            SVProgressHUD.dismiss()
        }

        TuyaSmartBLEManager.sharedInstance().delegate = nil
        TuyaSmartBLEManager.sharedInstance().stopListening(true)
    }

}

// MARK: - TuyaSmartBLEManagerDelegate
extension BLEModeViewController: TuyaSmartBLEManagerDelegate {
    
    // When the BLE detector finds one un-paired BLE device, this delegate method will be called.
    func didDiscoveryDevice(withDeviceInfo deviceInfo: TYBLEAdvModel) {
        guard let homeID = Home.current?.homeId else {
            SVProgressHUD.showError(withStatus: NSLocalizedString("No Home Selected", comment: ""))
            return
        }
        
        let type = deviceInfo.bleType
        
        guard
            type == TYSmartBLETypeBLESecurity ||
            type == TYSmartBLETypeBLEPlus
        else {
            return
        }
        
        SVProgressHUD.show(withStatus: NSLocalizedString("Activating", comment: "Active BLE."))
        
        // Trying to active the single BLE device.
        TuyaSmartBLEManager.sharedInstance().activeBLE(deviceInfo, homeId: homeID) { model in
            let name = model.name ?? NSLocalizedString("Unknown Name", comment: "Unknown name device.")
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("Successfully Added \(name)", comment: "Successfully added one device."))
            self.isSuccess = true
            self.navigationController?.popViewController(animated: true)
            
        } failure: {
            SVProgressHUD.showError(withStatus: NSLocalizedString("Failed to Activate BLE Device", comment: ""))
        }
    }
}
