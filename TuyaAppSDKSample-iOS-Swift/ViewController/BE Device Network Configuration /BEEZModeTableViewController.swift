//
//  EZModeTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartActivatorKit
import ThingSmartActivatorDiscoveryManager

class BEEZModeTableViewController: UITableViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var ssidTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Property
    private var token: String = ""
    private var isSuccess = false
    lazy var discovery: ThingSmartActivatorDiscovery = {
        let discovery = ThingSmartActivatorDiscovery()
        discovery.register(withActivatorList: [self.typeModel])
        discovery.setupDelegate(self)
        discovery.loadConfig()
        return discovery
    }()
    
    private lazy var typeModel: ThingSmartActivatorTypeEZModel = {
        let type = ThingSmartActivatorTypeEZModel()
        type.type = ThingSmartActivatorType.ezSearch
        type.typeName = NSStringFromThingSmartActivatorType(ThingSmartActivatorType.ezSearch)
        type.timeout = 120
        return type
    }()
    
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
        guard let homeID = Home.current?.homeId else { return }
        let ssid = ssidTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        typeModel.ssid = ssid
        typeModel.password = password
        typeModel.token = self.token
        typeModel.spaceId = homeID
        discovery.startSearch([typeModel])
    }
    
    private func stopConfigWifi() {
        if !isSuccess {
            SVProgressHUD.dismiss()
        }
        discovery.stopSearch([self.typeModel], clearCache: true)
        discovery.removeDelegate(self)
    }
    
}

extension BEEZModeTableViewController: ThingSmartActivatorSearchDelegate {
    
    func activatorService(_ service: ThingSmartActivatorSearchProtocol, activatorType type: ThingSmartActivatorTypeModel, didFindDevice device: ThingSmartActivatorDeviceModel?, error errorModel: ThingSmartActivatorErrorModel?) {
        if (errorModel != nil) {
            // Error
            SVProgressHUD.showError(withStatus: errorModel?.error.localizedDescription)
            return
        }
        
        if (device != nil) {
            if device?.step == ThingActivatorStep.found {
                // device find
            }
        }
    }
    
    func activatorService(_ service: ThingSmartActivatorSearchProtocol, activatorType type: ThingSmartActivatorTypeModel, didUpdateDevice device: ThingSmartActivatorDeviceModel) {
        if device.step == ThingActivatorStep.intialized {
            // Success
            let name = device.name
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("Successfully Added \(name)", comment: "Successfully added one device."))
            isSuccess = true
            navigationController?.popViewController(animated: true)
        }
    }

}
