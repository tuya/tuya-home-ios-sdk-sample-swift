//
//  APModeTableViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import TuyaSmartDeviceKit
import TuyaSmartActivatorKit
import SVProgressHUD

class APModeTableViewController: UITableViewController {
    
    @IBOutlet weak var ssidTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var token: String = ""
    private var isSuccess = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestToken()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopConfigWifi()
    }

    @IBAction func searchTapped(_ sender: UIBarButtonItem) {
        startConfiguration()
    }
    
    private func requestToken() {
        guard let homeID = Home.current?.homeId else { return }
        SVProgressHUD.show(withStatus: "Requesting for Token")
        
        TuyaSmartActivator.sharedInstance()?.getTokenWithHomeId(homeID, success: { [weak self] (token) in
            guard let self = self else { return }
            self.token = token ?? ""
            SVProgressHUD.dismiss()
        }, failure: { (error) in
            let errorMessage = error?.localizedDescription ?? ""
            SVProgressHUD.showError(withStatus: errorMessage)
        })
    }
    
    private func startConfiguration() {
        SVProgressHUD.show(withStatus: "Configuring")
        
        let ssid = ssidTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        TuyaSmartActivator.sharedInstance()?.delegate = self
        TuyaSmartActivator.sharedInstance()?.startConfigWiFi(TYActivatorModeAP, ssid: ssid, password: password, token: token, timeout: 100)
    }
    
    private func stopConfigWifi() {
        if !isSuccess {
            SVProgressHUD.dismiss()
        }
        TuyaSmartActivator.sharedInstance()?.delegate = nil
        TuyaSmartActivator.sharedInstance()?.stopConfigWiFi()
    }
    
}

extension APModeTableViewController: TuyaSmartActivatorDelegate {
    func activator(_ activator: TuyaSmartActivator!, didReceiveDevice deviceModel: TuyaSmartDeviceModel!, error: Error!) {
        if deviceModel != nil && error == nil {
            // Success
            let name = deviceModel.name ?? "Unknown Name"
            SVProgressHUD.showSuccess(withStatus: "Successfully Added \(name)")
            isSuccess = true
            navigationController?.popViewController(animated: true)
        }
        
        if let error = error {
            // Error
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
}
