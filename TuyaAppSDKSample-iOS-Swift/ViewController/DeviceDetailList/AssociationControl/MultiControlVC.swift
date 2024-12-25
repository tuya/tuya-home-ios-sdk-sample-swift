//
//  MultiControlVC.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class MultiControlVC: UITableViewController {

    var homeId: Int64
    var deviceId: String
    var dps: [ThingMultiControlDpInfo]? = nil
    
    init(homeId: Int64, deviceId:String) {
        self.homeId = homeId
        self.deviceId = deviceId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadData {
            self.tableView.reloadData()
        }
    }
    
    func loadData(_ completed: @escaping () -> Void) {
        SVProgressHUD.show()
        ThingDeviceAssociationControlManager.getMultiControlDp(withDeviceId: deviceId) { dps in
            SVProgressHUD.dismiss()
            self.dps = dps
            completed()
        } failure: { error in
            SVProgressHUD.dismiss()
            completed()
        }
    }
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dps?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "reuseIdentifier")
        
        cell.textLabel?.text = self.dps?[indexPath.row].dpName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dp: ThingMultiControlDpInfo = self.dps![indexPath.row]
        multiDetail(dp)
    }
    
    func multiDetail(_ dp: ThingMultiControlDpInfo) {
        let vc = MultiDetailVC(homeId: homeId, deviceId: deviceId, dp: dp)
        self.navigationController?.pushViewController(vc, animated: true)
    }

}



class MultiDetailVC: UITableViewController {

    var homeId: Int64
    var deviceId: String
    var dp: ThingMultiControlDpInfo
    var group : ThingMultiControlGroupInfo?
    
    init(homeId: Int64, deviceId:String, dp:ThingMultiControlDpInfo) {
        self.homeId = homeId
        self.deviceId = deviceId
        self.dp = dp
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationItem()
        self.loadData {
            self.tableView.reloadData()
        }
    }
    
    
    func setUpNavigationItem() {
        let title = "edit"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(edit))
    }
    
    @objc func edit() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if (self.group != nil) {
            alert.addAction(UIAlertAction(title: "rename", style: .default, handler: { action in
                self.rename()
            }))
            
            alert.addAction(UIAlertAction(title: self.group!.multiGroup.enabled ? "disable" : "enable", style: .default, handler: { action in
                self.enable()
            }))
        }
        
        if (self.group == nil || self.group!.multiGroup.groupDetail.count < self.group!.bindMaxValue) {
            alert.addAction(UIAlertAction(title: "addDevice", style: .default, handler: { action in
                self.add()
            }))
        }

        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func add() {
        SVProgressHUD.show()
        ThingDeviceAssociationControlManager.getMultiControlDevices(withDeviceId: self.deviceId, spaceId: self.homeId) { devices in
            SVProgressHUD.dismiss()
            
            let alert = UIAlertController(title: "select device", message: nil, preferredStyle: .actionSheet)
            
            devices?.forEach({ device in
                alert.addAction(UIAlertAction(title: device.name, style: .default, handler: { action in
                    self.doAdd(device)
                }))
            })

            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)

        } failure: { e in
            SVProgressHUD.dismiss()
        }
    }
    
    
    func doAdd(_ device:ThingMultiControlDevice) {
        SVProgressHUD.show()
        ThingDeviceAssociationControlManager.getAvailableMultiControlDp(withDeviceId: device.devId, targetDevice: self.deviceId, targetDpId: self.dp.dpId, spaceId: self.homeId) { info in
            SVProgressHUD.dismiss()
                        
            var dpIds: [Int64] = []
            
            info?.mcGroups.forEach({ group in
                group.groupDetail.forEach { dev in
                    if (device.devId == dev.devId) {
                        dpIds.append(dev.dpId)
                    }
                }
            })
            
            
            info?.parentRules.forEach({ rule in
                rule.dpList.forEach { dpInfo in
                    dpIds.append(dpInfo.dpId)
                }
            })
            
            var dps = info?.datapoints
            dps?.removeAll(where: { dp in
                dpIds.contains(dp.dpId)
            })
            
            
            let alert = UIAlertController(title: "select dp", message: nil, preferredStyle: .actionSheet)
            
            dps?.forEach({ dp in
                alert.addAction(UIAlertAction(title: dp.name, style: .default, handler: { action in
                    self.doAddDp(device.devId, dpId: dp.dpId)
                }))
            })

            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)

            
            
        } failure: { e in
            SVProgressHUD.dismiss()
        }

    }

    func doAddDp(_ deviceId:String, dpId:Int64) {
        SVProgressHUD.show()
        var json: Array<Dictionary<String, Any>> = self.group!.multiGroup.groupDetail.reduce(into: Array<Dictionary<String, Int64>>(), { partialResult, device in
            if (device.devId != deviceId) {
                partialResult.append(["devId": device.devId, "dpId": device.dpId])
            }
        })
        
        if (json.count == 0) {
            json.append(["devId": self.deviceId, "dpId": self.dp.dpId])
        }
        json.append(["devId": deviceId, "dpId": dpId])
        
        ThingDeviceAssociationControlManager.updateMultiControlGroup(self.group!.multiGroup.multiControlGroupId, name: self.group!.multiGroup.groupName, spaceId: self.homeId, deviceDps: json) { group in
            ThingDeviceAssociationControlManager.getMultiControlGroup(withDeviceId: self.deviceId, dpId: self.dp.dpId) { group in
                SVProgressHUD.dismiss()
                self.group = group
                self.title = group?.multiGroup.groupName ?? ""
                self.tableView.reloadData()
            } failure: { e in
                SVProgressHUD.dismiss()
            }
        } failure: { e in
            SVProgressHUD.dismiss()
        }
    }

    
    
    func rename() {
        
        let alertController = UIAlertController(title: "rename", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "input the new name"
        }
        let confirmAction = UIAlertAction(title: "ok", style: .default) { (_) in
            guard let textField = alertController.textFields?.first, let text = textField.text else {return}
            self.doRename(text)
        }
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func doRename(_ name:String) {
        SVProgressHUD.show()
        
        let json: Array<Dictionary<String, Any>> = self.group?.multiGroup.groupDetail.reduce(into: Array<Dictionary<String, Int64>>(), { partialResult, device in
            partialResult.append(["devId": device.devId, "dpId": device.dpId])
        }) ?? []
        
        ThingDeviceAssociationControlManager.updateMultiControlGroup(self.group!.multiGroup.multiControlGroupId, name: name, spaceId: self.homeId, deviceDps: json) { group in
            ThingDeviceAssociationControlManager.getMultiControlGroup(withDeviceId: self.deviceId, dpId: self.dp.dpId) { group in
                SVProgressHUD.dismiss()
                self.group = group
                self.title = group?.multiGroup.groupName ?? ""
                self.tableView.reloadData()
            } failure: { e in
                SVProgressHUD.dismiss()
            }

        } failure: { e in
            SVProgressHUD.dismiss()
        }

    }
    
    
    func enable() {
        ThingDeviceAssociationControlManager.updateMultiControlGroupStatus(self.group!.multiGroup.multiControlGroupId, enable: !self.group!.multiGroup.enabled) { _ in
            self.group?.multiGroup.enabled = !self.group!.multiGroup.enabled
        } failure: { e in
            
        }
    }
    
    func loadData(_ completed:@escaping () -> Void) {
        SVProgressHUD.show()
        ThingDeviceAssociationControlManager.getMultiControlGroup(withDeviceId: deviceId, dpId: dp.dpId) { group in
            SVProgressHUD.dismiss()
            self.group = group
            self.title = group?.multiGroup.groupName ?? ""
            completed()
        } failure: { e in
            SVProgressHUD.dismiss()
            completed()
        }
    }
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.group?.multiGroup.groupDetail.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "reuseIdentifier")
        
        cell.textLabel?.text = self.group?.multiGroup.groupDetail[indexPath.row].devName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let device = self.group!.multiGroup.groupDetail[indexPath.row]
        if (device.devId != self.deviceId) {
            updateDp(groupDevice: self.group!.multiGroup.groupDetail[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let device = self.group!.multiGroup.groupDetail[indexPath.row]
        return device.devId != self.deviceId
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.remove(groupDevice: self.group!.multiGroup.groupDetail[indexPath.row])
    }
    
    func remove(groupDevice: ThingMultiControlGroupDevice) {
        SVProgressHUD.show()
        var json: Array<Dictionary<String, Any>> = self.group!.multiGroup.groupDetail.reduce(into: Array<Dictionary<String, Int64>>(), { partialResult, device in
            if (device != groupDevice) {
                partialResult.append(["devId": device.devId, "dpId": device.dpId])
            }
        })
        if (json.count == 1) {json = []}
        
        ThingDeviceAssociationControlManager.updateMultiControlGroup(self.group!.multiGroup.multiControlGroupId, name: self.group!.multiGroup.groupName, spaceId: self.homeId, deviceDps: json) { group in
            ThingDeviceAssociationControlManager.getMultiControlGroup(withDeviceId: self.deviceId, dpId: self.dp.dpId) { group in
                SVProgressHUD.dismiss()
                self.group = group
                self.title = group?.multiGroup.groupName ?? ""
                self.tableView.reloadData()
            } failure: { e in
                SVProgressHUD.dismiss()
            }
        } failure: { e in
            SVProgressHUD.dismiss()
        }
    }
    
    func updateDp(groupDevice: ThingMultiControlGroupDevice) {        
        SVProgressHUD.show()
        ThingDeviceAssociationControlManager.getAvailableMultiControlDp(withDeviceId: groupDevice.devId, targetDevice: self.deviceId, targetDpId: self.dp.dpId, spaceId: self.homeId) { info in
            SVProgressHUD.dismiss()
                        
            var dpIds: [Int64] = []
            
            info?.mcGroups.forEach({ group in
                group.groupDetail.forEach { device in
                    if (device.devId == groupDevice.devId) {
                        dpIds.append(device.dpId)
                    }
                }
            })
            
            
            info?.parentRules.forEach({ rule in
                rule.dpList.forEach { dpInfo in
                    dpIds.append(dpInfo.dpId)
                }
            })
            
            var dps = info?.datapoints
            dps?.removeAll(where: { dp in
                dpIds.contains(dp.dpId)
            })
            
            
            let alert = UIAlertController(title: "current dp: \(groupDevice.dpName)", message: nil, preferredStyle: .actionSheet)
            
            dps?.forEach({ dp in
                alert.addAction(UIAlertAction(title: dp.name, style: .default, handler: { action in
                    self.bind(groupDevice.devId, dpId: dp.dpId)
                }))
            })

            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)

            
            
        } failure: { e in
            SVProgressHUD.dismiss()
        }
    }

    func bind(_ deviceId: String, dpId: Int64) {
        
        SVProgressHUD.show()
        let json: Array<Dictionary<String, Any>> = self.group!.multiGroup.groupDetail.reduce(into: Array<Dictionary<String, Int64>>(), { partialResult, device in
            if (device.devId != deviceId) {
                partialResult.append(["devId": device.devId, "dpId": device.dpId])
            }else{
                partialResult.append(["devId": device.devId, "dpId": dpId])
            }
        })
        
        ThingDeviceAssociationControlManager.updateMultiControlGroup(self.group!.multiGroup.multiControlGroupId, name: self.group!.multiGroup.groupName, spaceId: self.homeId, deviceDps: json) { group in
            
            ThingDeviceAssociationControlManager.getMultiControlGroup(withDeviceId: self.deviceId, dpId: self.dp.dpId) { group in
                SVProgressHUD.dismiss()
                self.group = group
                self.title = group?.multiGroup.groupName ?? ""
                self.tableView.reloadData()
            } failure: { e in
                SVProgressHUD.dismiss()
            }
            
        } failure: { e in
            SVProgressHUD.dismiss()
        }

    }
}
