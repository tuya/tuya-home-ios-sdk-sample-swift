//
//  QRCodeScanerViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2022 Thing Inc. (https://developer.tuya.com/)

import UIKit

class QRCodeScanerViewController: UIViewController {

    public var scanCallback: ((_ code: String?) -> Void)?
    
    let scanCode = SGScanCode()
    var scanView: SGScanView!
    
    deinit {
        stop()
    }
    
    func start() {
        scanCode.startRunning()
        scanView?.startScanning()
    }
    
    func stop() {
        scanCode.stopRunning()
        scanView?.stopScanning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNav()
        configureUI()
        configureQRCode()
    }
    
    func configureNav() {
        navigationItem.title = "Scan QRCode"
    }
    
    func configureUI() {
        let config = SGScanViewConfigure()
        config.isShowBorder = true
        config.borderColor = UIColor.clear
        config.cornerColor = UIColor.white
        config.cornerWidth = 3
        config.cornerLength = 15
        config.isFromTop = true
        config.scanline = "SGQRCode.bundle/scan_scanline_qq"
        config.color = UIColor.clear
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.size.width , height: view.frame.size.height)
        scanView = SGScanView(frame: frame, configure: config)
        scanView.startScanning()
        scanView.scanFrame = frame
        view.addSubview(scanView!)
    }
    
    func configureQRCode() {
        scanCode.preview = view
        scanCode.delegate = self
        scanCode.startRunning()
    }

}

extension QRCodeScanerViewController: SGScanCodeDelegate {
    func scanCode(_ scanCode: SGScanCode!, result: String!) {
        stop()
        
        if let cb = scanCallback {
            cb(result)
        }
        
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
