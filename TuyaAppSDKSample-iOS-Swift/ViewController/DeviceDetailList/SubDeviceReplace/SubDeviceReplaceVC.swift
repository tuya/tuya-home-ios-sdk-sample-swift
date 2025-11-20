//
//  SubDeviceReplaceVC.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class SubDeviceReplaceVC: UITableViewController {

    var deviceId: String
    var manager: ThingSubDeviceReplaceManager
    var support: Bool = false
    var devIds: [String] = []
    
    init(deviceId: String) {
        self.deviceId = deviceId
        self.manager = ThingSubDeviceReplaceManager(deviceId: deviceId, role: .replacee)
        super.init(nibName: nil, bundle: nil)
        self.manager.add(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.loadData()
    }

    func loadData() {
        SVProgressHUD.show()
        self.manager.supportReplace { support in
            self.support = support
            if (!support) {
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
            }else{
                self.manager.getCompatibleSubDevices { devIds in
                    SVProgressHUD.dismiss()
                    self.devIds = devIds
                    self.tableView.reloadData()
                } failure: { error in
                    SVProgressHUD.dismiss()
                    self.tableView.reloadData()
                }
            }
        } failure: { error in
            self.support = false;
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
        }
    }
    
    
    var replacer: String? = nil;
    
    func replace(_ deviceId: String) {
        
        SVProgressHUD.show()
        self.manager.replace(withOtherDevice: deviceId, timeout: 30) { replaceId in
            self.replacer = deviceId;
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
        } failure: { error in
            self.replacer = nil;
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
        }

    }
    
}

extension SubDeviceReplaceVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {return 1};
        return self.devIds.count > 0 ? self.devIds.count : 1;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        }
        
        if (indexPath.section == 0) {
            cell?.textLabel?.text = self.support ? "support" : "not support"
            cell?.textLabel?.textColor = UIColor.darkGray
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell?.accessoryView = nil;

        }else{
            
            if (self.devIds.count > 0) {
                let devId = self.devIds[indexPath.row]
                let model: ThingSmartDeviceModel? = ThingCoreCacheService.sharedInstance().getDeviceInfo(withDevId: devId)
                cell?.textLabel?.text = model?.name
                cell?.textLabel?.textColor = UIColor.darkGray
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 16)
                
                if (devId == self.replacer) {
                    let view = UIActivityIndicatorView(style: .gray)
                    view.startAnimating()
                    cell?.accessoryView = view;
                }else{
                    cell?.accessoryView = nil;
                }
                
            }else{
                cell?.textLabel?.text = "not devices can be used to replace current device"
                cell?.textLabel?.textColor = UIColor.lightGray
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 12)
                cell?.accessoryView = nil;
            }
            
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Does current device support subdevice Replace"
        }else{
            return "Select a device to replace current device"
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if (indexPath.section == 0 || self.devIds.count == 0) {return}
        
        let devId = self.devIds[indexPath.row]
        self.replace(devId)
    }

}


extension SubDeviceReplaceVC : ThingSubDeviceReplaceManagerListener {
    
    public func manager(_ manager: ThingSubDeviceReplaceManager, replaceDidCompleteWithResult success: Bool, error: (any Error)?) {
        self.replacer = nil;
        self.tableView.reloadData()
        if (success) {
            SVProgressHUD.showSuccess(withStatus: "replace success")
        }else{
            SVProgressHUD.showError(withStatus: error?.localizedDescription ?? "replace fail")
        }

    }
    
    
}

