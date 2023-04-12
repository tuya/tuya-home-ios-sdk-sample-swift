//
//  BLEModeViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartBLEKit

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
        ThingSmartBLEManager.sharedInstance().delegate = self
        
        // Start finding un-paired BLE devices.
        ThingSmartBLEManager.sharedInstance().startListening(true)
        
        SVProgressHUD.show(withStatus: NSLocalizedString("Searching", comment: ""))
    }
    
    // MARK: - Private method
    private func stopConfigBLE() {
        if !isSuccess {
            SVProgressHUD.dismiss()
        }

        ThingSmartBLEManager.sharedInstance().delegate = nil
        ThingSmartBLEManager.sharedInstance().stopListening(true)
    }

}

// MARK: - ThingSmartBLEManagerDelegate
extension BLEModeViewController: ThingSmartBLEManagerDelegate {
    
    // When the BLE detector finds one un-paired BLE device, this delegate method will be called.
    func didDiscoveryDevice(withDeviceInfo deviceInfo: ThingBLEAdvModel) {
        guard let homeID = Home.current?.homeId else {
            SVProgressHUD.showError(withStatus: NSLocalizedString("No Home Selected", comment: ""))
            return
        }
        
        let bleType = deviceInfo.bleType
        if bleType == ThingSmartBLETypeBLEWifi ||
            bleType == ThingSmartBLETypeBLEWifiSecurity ||
            bleType == ThingSmartBLETypeBLEWifiPlugPlay ||
            bleType == ThingSmartBLETypeBLEWifiPriorBLE ||
            bleType == ThingSmartBLETypeBLELTESecurity {
            print("Please use Dual Mode to pair: %@", deviceInfo.uuid ?? "")
            return
        }
        
        SVProgressHUD.show(withStatus: NSLocalizedString("Activating", comment: "Active BLE."))
        
        // Trying to active the single BLE device.
        ThingSmartBLEManager.sharedInstance().activeBLE(deviceInfo, homeId: homeID) { model in
            let name = model.name ?? NSLocalizedString("Unknown Name", comment: "Unknown name device.")
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("Successfully Added \(name)", comment: "Successfully added one device."))
            self.isSuccess = true
            self.navigationController?.popViewController(animated: true)
            
        } failure: {
            SVProgressHUD.showError(withStatus: NSLocalizedString("Failed to Activate BLE Device", comment: ""))
        }
    }
}
