//
//  File.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import Foundation

class DeviceOfflineReminderVC: UIViewController {

    var deviceId: String
    
    lazy var label: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.textColor = UIColor.green
        return label
    }()
    
    lazy var statusSwitch: UISwitch = {
        let statusSwitch = UISwitch(frame: CGRectZero)
        statusSwitch.addTarget(self, action: #selector(change(sender:)), for: .valueChanged)
        return statusSwitch
    }()
    
    init(deviceId: String) {
        self.deviceId = deviceId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.label)
        self.view.addSubview(self.statusSwitch)
        
        self.label.frame = CGRect(x: 20, y: 100, width: 150, height: 27)
        self.statusSwitch.frame = CGRect(x: 170, y: 100, width: 0, height: 0)
        self.statusSwitch.isHidden = true
        self.loadData()
        
    }
    
    func loadData() {
        SVProgressHUD.show()
        ThingDeviceOfflineReminderManager.getOfflineReminderSupportStatus(withDeviceId: self.deviceId) { support in
            if (support) {

                ThingDeviceOfflineReminderManager.getOfflineReminderStatus(withDeviceId: self.deviceId) { status in
                    SVProgressHUD.dismiss()
                    self.label.text = "支持"
                    self.statusSwitch.isHidden = false
                    self.statusSwitch.isOn = status
                } failure: { e in
                    SVProgressHUD.dismiss()
                    self.label.text = "支持"
                    self.statusSwitch.isHidden = false
                    self.statusSwitch.isOn = false
                }

                
            }else{
                SVProgressHUD.dismiss()
                self.label.text = "不支持"
                self.statusSwitch.isHidden = true
            }
        } failure: { e in
            SVProgressHUD.dismiss()
        }
    }

    @objc func change(sender: UISwitch) {
        ThingDeviceOfflineReminderManager.updateOfflineReminderStatus(withDeviceId: self.deviceId, status: sender.isOn) {
            
        } failure: { e in
            
        }
    }
    
}
