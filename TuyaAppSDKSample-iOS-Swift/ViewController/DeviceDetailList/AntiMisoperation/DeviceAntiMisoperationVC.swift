//
//  Untitled.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class DeviceAntiMisoperationVC: UIViewController {

    var deviceId: String
    var manager: ThingAntiMisoperationManager
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = NSTextAlignment.right;
        return label
    }()
    
    lazy var switchView: UISwitch = {
        let view = UISwitch()
        view.addTarget(self, action: #selector(updateStatus), for: .valueChanged)
        return view;
    }()

    init(deviceId: String) {
        self.deviceId = deviceId
        self.manager = ThingAntiMisoperationManager(deviceId: deviceId)
        super.init(nibName: nil, bundle: nil)
        self.manager.add(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(label)
        self.view.addSubview(switchView)
        
        self.label.frame = CGRectMake(20, 100, 100, 50);
        self.switchView.frame = CGRectMake(120, 100, 100, 50);
        
        self.loadData()
    }
    
    func loadData() {
        SVProgressHUD.show()
        self.manager.isSupport { support in
            if (!support) {
                SVProgressHUD.dismiss()
                self.switchView.isHidden = true
                self.label.text = "unsupport"
            }else{
                self.manager.getStatus()
                self.switchView.isHidden = false
                self.label.text = "support"
            }
        } failure: { error in
            SVProgressHUD.dismiss()
        }

    }
    
    
    @objc func updateStatus() {
        self.manager.updateStatus(self.switchView.isOn)
    }
    
}

extension DeviceAntiMisoperationVC : ThingAntiMisoperationManagerListener {
    func antiMisoperationManager(_ manager: ThingAntiMisoperationManager, statusDidUpdate status: Bool) {
        SVProgressHUD.dismiss()
        self.switchView.isOn = status
    }
}
