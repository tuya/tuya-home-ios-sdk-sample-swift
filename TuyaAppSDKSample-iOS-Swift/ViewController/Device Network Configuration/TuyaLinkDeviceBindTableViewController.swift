//
//  ThingLinkDeviceBindTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2022 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartActivatorKit
import ThingSmartDeviceKit

class ThingLinkDeviceBindTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ThingLink Bind"
    }
    
    func bindThingLink(qrcode codeStr: String?) -> Void {
        let homeId = Home.current?.homeId
        SVProgressHUD.show()
        let act = ThingSmartThingLinkActivator.init()
        act.bindThingLinkDevice(withQRCode: codeStr ?? "", homeId: homeId ?? 0) { device in
            SVProgressHUD.show(withStatus: "Bind Success. \n devId: \(device.devId ?? "") \n name: \(device.name ?? "")")
        } failure: { error in
            SVProgressHUD.showError(withStatus: "Bind Failure. (\(error?.localizedDescription ?? ""))")
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
