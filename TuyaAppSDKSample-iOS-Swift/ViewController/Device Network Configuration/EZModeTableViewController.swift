//
//  EZModeTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartActivatorKit

class EZModeTableViewController: UITableViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var ssidTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Property
    private var token: String = ""
    private var isSuccess = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopConfigWifi()
    }
    
    // MARK: - IBAction
    @IBAction func searchTapped(_ sender: UIBarButtonItem) {
        startConfiguration()
    }
    
    // MARK: - Private Method
    private func startConfiguration() {
        guard let homeID = Home.current?.homeId else { return }
        SVProgressHUD.show(withStatus: NSLocalizedString("Requesting for Token", comment: ""))
        
        ThingSmartActivator.sharedInstance()?.getTokenWithHomeId(homeID, success: { [weak self] (token) in
            guard let self = self else { return }
            self.token = token ?? ""
            self.startConfiguration(with: self.token)
        }, failure: { (error) in
            let errorMessage = error?.localizedDescription ?? ""
            SVProgressHUD.showError(withStatus: errorMessage)
        })
    }
     
    private func startConfiguration(with token: String) {
        SVProgressHUD.show(withStatus: NSLocalizedString("Configuring", comment: ""))
        
        let ssid = ssidTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        ThingSmartActivator.sharedInstance()?.delegate = self
        ThingSmartActivator.sharedInstance()?.startConfigWiFi(.EZ, ssid: ssid, password: password, token: token, timeout: 100)
    }
    
    private func stopConfigWifi() {
        if !isSuccess {
            SVProgressHUD.dismiss()
        }
        ThingSmartActivator.sharedInstance()?.delegate = nil
        ThingSmartActivator.sharedInstance()?.stopConfigWiFi()
    }
    
}

extension EZModeTableViewController: ThingSmartActivatorDelegate {
    func activator(_ activator: ThingSmartActivator!, didReceiveDevice deviceModel: ThingSmartDeviceModel!, error: Error!) {
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
