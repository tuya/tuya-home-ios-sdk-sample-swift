//
//  BEMatterTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2022 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartActivatorKit
import ThingSmartDeviceKit

class BEMatterTableViewController: UITableViewController {

    
    @IBOutlet weak var ssid: UITextField!
    @IBOutlet weak var password: UITextField!
    var deviceTypeModel: ThingMatterDeviceDiscoveriedType?
    private var isSuccess = false
    
    
    /// UI
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Matter"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopConfigWifi()
    }
    
    private var typeModel: ThingSmartActivatorTypeMatterModel = {
        let type = ThingSmartActivatorTypeMatterModel()
        type.type = ThingSmartActivatorType.matter
        type.typeName = NSStringFromThingSmartActivatorType(ThingSmartActivatorType.matter)
        type.timeout = 180
        return type
    }()
    
    lazy var discovery: ThingSmartActivatorDiscovery = {
        let discovery = ThingSmartActivatorDiscovery()
        discovery.register(withActivatorList: [self.typeModel])
        discovery.setupDelegate(self)
        discovery.loadConfig()
        return discovery
    }()
    
    func bindMatter(qrcode codeStr: String?) -> Void {
        let homeId = (Home.current?.homeId)!
        let payload = self.discovery.parseSetupCode(codeStr ?? "")
        let activator = ThingSmartActivator()
        activator.getTokenWithHomeId(homeId, success: { [weak self] (token) in
            guard let self = self else { return }
            self.typeModel.token = token ?? ""
            self.typeModel.spaceId = homeId
            self.discovery.startActive(self.typeModel, deviceList:[payload])
            SVProgressHUD.show(withStatus: NSLocalizedString("Configuring", comment: ""))
        }, failure: { (error) in
            let errorMessage = error?.localizedDescription ?? ""
            SVProgressHUD.showError(withStatus: errorMessage)
        })
    }
    
    private func stopConfigWifi() {
        SVProgressHUD.dismiss()
        discovery.stopActive([typeModel], clearCache: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = QRCodeScanerViewController()
        vc.scanCallback = { [weak self] codeStr in
            self?.bindMatter(qrcode: codeStr)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension BEMatterTableViewController: ThingSmartActivatorActiveDelegate {
    func activatorService(_ service: ThingSmartActivatorActiveProtocol, activatorType type: ThingSmartActivatorTypeModel, didReceiveDevices devices: [ThingSmartActivatorDeviceModel]?, error errorModel: ThingSmartActivatorErrorModel?) {
        if errorModel != nil {
            SVProgressHUD.showError(withStatus: "Bind Failure. (\(errorModel?.error.localizedDescription ?? ""))")
            return
        }

        let device = devices?.first
        isSuccess = true
        SVProgressHUD.show(withStatus: "Bind Success. \n devId: \(device?.uniqueID ?? "") \n name: \(device?.name ?? "")")
    }
}

extension BEMatterTableViewController: ThingSmartActivatorDeviceExpandDelegate {
    func matterDeviceDiscoveryed(_ typeModel: ThingMatterDeviceDiscoveriedType) {
        deviceTypeModel = typeModel
    }
    
    func matterCommissioningSessionEstablishmentComplete(_ deviceModel: ThingSmartActivatorDeviceModel) {
        if deviceTypeModel?.deviceType == .wifi {
            self.typeModel.ssid = ssid.text ?? ""
            self.typeModel.password = password.text ?? ""
            self.discovery.continueCommissionDevice(deviceModel, typeModel: self.typeModel)
        }
        
        ///
        if deviceTypeModel?.deviceType == .thread {
            self.typeModel.gwDevId = "your gateway id"
            self.discovery.continueCommissionDevice(deviceModel, typeModel: self.typeModel)
        }
        
    }
    
    func matterDeviceAttestation(_ device: UnsafeMutableRawPointer, error: Error) {
        let alertControl = UIAlertController(title: "Attestation", message: "Should Continue?", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Continue", style: .default) { _ in
            self.discovery.continueCommissioningDevice(device, ignoreAttestationFailure: true, error: nil)
        }
        let canAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.discovery.continueCommissioningDevice(device, ignoreAttestationFailure: false, error: nil)
        }
        
        alertControl.addAction(alertAction)
        alertControl.addAction(canAction)
        
        self.present(alertControl, animated: true)
    }
    
}
