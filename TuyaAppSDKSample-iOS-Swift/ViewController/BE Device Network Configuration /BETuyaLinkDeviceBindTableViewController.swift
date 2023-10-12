//
//  ThingLinkDeviceBindTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2022 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartActivatorKit
import ThingSmartDeviceKit

class BETuyaLinkDeviceBindTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ThingLink Bind"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SVProgressHUD.dismiss()
    }
    
    private var typeModel: ThingSmartActivatorTypeThingLinkModel = {
        let type = ThingSmartActivatorTypeThingLinkModel()
        type.type = ThingSmartActivatorType.thingLink
        type.typeName = NSStringFromThingSmartActivatorType(ThingSmartActivatorType.thingLink)
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
    
    var request: ThingSmartActivatorDiscoveryRequest = {
        let request = ThingSmartActivatorDiscoveryRequest()
        return request
    }()
    
    func bindThingLink(qrcode codeStr: String?) -> Void {
        let homeId = (Home.current?.homeId)!
        SVProgressHUD.show()
        let requestDate = ThingActivatorParseQRCodeRequestData()
        requestDate.code = codeStr ?? ""
        request.requestParseQRCode(withParam: requestDate) { scanCodeModel in
            if scanCodeModel.actionName == "device_net_conn_bind_tuyalink" {
                self.typeModel.uuid = scanCodeModel.actionData?.object(forKey: "uuid") as! String
                self.typeModel.spaceId = homeId
                self.discovery.startActive(self.typeModel, deviceList: [])
            }
        } failure: { error in
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = QRCodeScanerViewController()
        vc.scanCallback = { [weak self] codeStr in
            self?.bindThingLink(qrcode: codeStr)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension BETuyaLinkDeviceBindTableViewController: ThingSmartActivatorActiveDelegate {
    func activatorService(_ service: ThingSmartActivatorActiveProtocol, activatorType type: ThingSmartActivatorTypeModel, didReceiveDevices devices: [ThingSmartActivatorDeviceModel]?, error errorModel: ThingSmartActivatorErrorModel?) {
        if errorModel != nil {
            SVProgressHUD.showError(withStatus: "Bind Failure. (\(errorModel?.error.localizedDescription ?? ""))")
            return
        }

        let device = devices?.first
        SVProgressHUD.show(withStatus: "Bind Success. \n devId: \(device?.uniqueID ?? "") \n name: \(device?.name ?? "")")
    }
}

