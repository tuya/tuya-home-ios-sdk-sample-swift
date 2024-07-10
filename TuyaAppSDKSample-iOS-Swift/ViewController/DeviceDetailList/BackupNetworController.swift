//
//  BackupNetworController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import SnapKit

class BackupNetworController: UIViewController {

    var deviceId: String
    var info: ThingDeviceNetworkInfo?
    var backups: [ThingSmartBackupWifiModel]?
    var max: Int?
    
    lazy var label: UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.textColor = UIColor.green
        label.textAlignment = .center
        return label
    }()
    
    lazy var manager: ThingDeviceNetworkManager = {
        let manager = ThingDeviceNetworkManager.init(deviceId: self.deviceId)
        return manager
    }()
    
    lazy var tableview: UITableView = {
        return UITableView(frame: CGRectZero, style: .grouped)
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
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.label)
        self.label.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(100)
            make.height.equalTo(30)
        }

        if (self.manager.supportWifiBackupNetwork()) {
            self.label.text = "support"
            self.loadCurrentNetworkInfo()
        }else{
            self.label.text = "do not support"
        }
        
        self.view.addSubview(self.tableview)
        self.tableview.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(self.label.snp.bottom)
            make.bottom.equalTo(-self.view.safeAreaInsets.bottom)
        }
        self.tableview.delegate = self
        self.tableview.dataSource = self
    }
    
    func loadCurrentNetworkInfo() {
        SVProgressHUD.show()
        self.manager.getCurrentNetworkInfo { [weak self] info in
            self?.info = info
            
            if self != nil && self!.manager.canUpdateWifiBackupNetwork(info) {
                self?.manager.getBackupWifiNetworks { [weak self] backups, max in
                    self?.backups = backups
                    self?.max = max
                    self?.tableview.reloadData()
                    SVProgressHUD.dismiss()
                } failure: { e in
                    self?.backups = nil
                    self?.max = nil
                    self?.tableview.reloadData()
                    SVProgressHUD.dismiss()
                }
            }else{
                self?.backups = nil
                self?.max = nil
                self?.tableview.reloadData()
                SVProgressHUD.dismiss()
            }
            
        } failure: { e in
            self.info = nil
            self.backups = nil
            self.max = nil
            self.tableview.reloadData()
            SVProgressHUD.dismiss()
        }
    }
}

extension BackupNetworController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.info != nil ? 5 : 0
        }else {
            return self.backups != nil ? self.backups!.count + 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        }
        
        if (indexPath.section == 0) {
            
            if (indexPath.row == 0) {
                cell?.textLabel?.text = "ssid"
                cell?.detailTextLabel?.text = self.info?.ssid
            }else if (indexPath.row == 1) {
                cell?.textLabel?.text = "signal"
                cell?.detailTextLabel?.text = "\(self.info?.signal ?? 0)"

            }else if (indexPath.row == 2) {
                cell?.textLabel?.text = "type"
                cell?.detailTextLabel?.text = "\(self.info?.network.rawValue ?? 0)"
            }else if (indexPath.row == 3) {
                cell?.textLabel?.text = "canUpdateWifiBackupNetwork"
                cell?.detailTextLabel?.text = self.manager.canUpdateWifiBackupNetwork(self.info!) ? "true":"false"
            }else if (indexPath.row == 4) {
                cell?.textLabel?.text = "canSwitchWifiNetwork"
                cell?.detailTextLabel?.text = self.manager.canSwitchWifiNetwork(self.info!) ? "true":"false"
            }
            
        }else{
            if (indexPath.row < self.backups!.count) {
                cell?.textLabel?.text = self.backups![indexPath.row].ssid
                cell?.detailTextLabel?.text = ""
            }else{
                cell?.textLabel?.text = ""
                cell?.detailTextLabel?.text = "add new backup network"
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 0) {return}
        
        if (indexPath.row == self.backups!.count) {
            self.add()
        }else{
            self.switchOrDelete(self.backups![indexPath.row])
        }
        
    }
    
    func add() {
        if (self.backups!.count >= self.max!) {
            let alert = UIAlertController(title: "can't add any more", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.cancel))
            self.present(alert, animated: true)
        }else{
            let newSSID = "ABC"
            let newPassword = "12345678"
            let newBackup = self.manager.generateBackupWifiModel(withSSID: newSSID, pwd: newPassword)
            var temp = Array(self.backups!)
            temp.append(newBackup)
            
            self.manager.updateBackupWifiNetworks(temp) {
                self.loadCurrentNetworkInfo()
            } failure: { e in
                
            }
        }
    }
    
    
    func switchOrDelete(_ backup:ThingSmartBackupWifiModel) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "delete", style: UIAlertAction.Style.default, handler: { _ in
            self.deleteBackup(backup)
        }))
        alert.addAction(UIAlertAction(title: "switch", style: UIAlertAction.Style.default, handler: { _ in
            self.switchBackup(backup)
        }))

        alert.addAction(UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel))
        self.present(alert, animated: true)

        
    }
    
    func deleteBackup(_ backup:ThingSmartBackupWifiModel) {
        var temp = self.backups?.filter({ $0 != backup})
        self.manager.updateBackupWifiNetworks(temp!) {
            self.loadCurrentNetworkInfo()
        } failure: { e in
            
        }
    }
    
    func switchBackup(_ backup:ThingSmartBackupWifiModel) {
        if (self.manager.canSwitchWifiNetwork(self.info!) == false) {
            let alert = UIAlertController(title: "can't not switch", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.cancel))
            self.present(alert, animated: true)
        }else{
            self.manager.switchBackupWifiNetwork(withHash: backup.hashValue) {
                self.loadCurrentNetworkInfo()
            } failure: { e in
            }
        }
    }
    
}
