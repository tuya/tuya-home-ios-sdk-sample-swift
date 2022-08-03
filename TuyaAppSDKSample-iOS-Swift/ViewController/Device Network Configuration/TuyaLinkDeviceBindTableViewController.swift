//
//  TuyaLinkDeviceBindTableViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2022 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import TuyaSmartActivatorKit
import TuyaSmartDeviceKit

class TuyaLinkDeviceBindTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func bindTuyaLink(qrcode codeStr: String?) -> Void {
        let homeId = Home.current?.homeId
        SVProgressHUD.show()
        let act = TuyaSmartTuyaLinkActivator.init()
        act.bindTuyaLinkDevice(withQRCode: codeStr ?? "", homeId: homeId ?? 0) { device in
            SVProgressHUD.show(withStatus: "Bind Success. \n devId: \(device.devId ?? "") \n name: \(device.name ?? "")")
        } failure: { error in
            SVProgressHUD.showError(withStatus: "Bind Failure. (\(error?.localizedDescription ?? ""))")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = QRCodeScanerViewController()
        vc.scanCallback = { [weak self] codeStr in
            self?.bindTuyaLink(qrcode: codeStr)
        }
    }

}
