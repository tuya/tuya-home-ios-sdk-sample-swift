//
//  DoubleControlVC.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class DoubleControlVC: UITableViewController {

    var homeId: Int64
    var deviceId: String
    var group: ThingDoubleControlGroup?
    
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
        setUpNavigationItem()
        self.loadData {
            self.tableView.reloadData()
        }
    }
    
    func loadData(_ completed: @escaping () -> Void) {
        SVProgressHUD.show()
        ThingDeviceAssociationControlManager.getDoubleControlGroup(withDeviceId: self.deviceId, spaceId: self.homeId) { group in
            SVProgressHUD.dismiss()
            if let did = group?.mainDeviceId, did.count > 0 {
                self.group = group
            }
            completed()
        } failure: { e in
            SVProgressHUD.dismiss()
            completed()
        }
    }
    
    func refresh(_ completed: @escaping () -> Void) {
        ThingDeviceAssociationControlManager.getDoubleControlGroup(withDeviceId: self.deviceId, spaceId: self.homeId) { group in
            if (group?.mainDeviceId != nil) {
                self.group = group
            }
            completed()
        } failure: { e in
            completed()
        }
    }
    
    
    func setUpNavigationItem() {
        let title = "edit"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(edit))
    }
    
    
    @objc func edit() {
        
        let alert = UIAlertController(title: nil, message: "At most three switches can be associated", preferredStyle: .actionSheet)
        
        if (self.group == nil || self.group!.slaveDeviceIds.count < 3) {
            alert.addAction(UIAlertAction(title: "addDevice", style: .default, handler: { action in
                self.add()
            }))
        }

        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (self.group == nil) {return 0}
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {return 1}
        return self.group!.slaveDeviceIds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "reuseIdentifier")
        
        if (indexPath.section == 0) {
           
            let devId = self.group!.mainDeviceId
            let dev = ThingSmartDevice(deviceId: devId)?.deviceModel
            cell.textLabel?.text = dev?.name
            cell.detailTextLabel?.text = "main"
        }else{
            let devId = self.group!.slaveDeviceIds[indexPath.row]
            let dev = ThingSmartDevice(deviceId: devId)?.deviceModel
            cell.textLabel?.text = dev?.name
            cell.detailTextLabel?.text = "slave"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.section == 0) {return}
        
        let devId = self.group!.slaveDeviceIds[indexPath.row]
        update(devId)
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 0) {return false}
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let devId = self.group!.slaveDeviceIds[indexPath.row]
        self.remove(devId)
    }

}

extension DoubleControlVC {
    func add() {
        SVProgressHUD.show()
        ThingDeviceAssociationControlManager.getDoubleControlAvailableSlaveDevices(withMainDeviceId: self.deviceId, spaceId: self.homeId) { devs in
            SVProgressHUD.dismiss()

            let devices = devs?.filter {$0.isRelate == false}
            let alert = UIAlertController(title: "select device", message: nil, preferredStyle: .actionSheet)
            
            devices?.forEach({ device in
                let dev = ThingSmartDevice(deviceId: device.devId)?.deviceModel
                alert.addAction(UIAlertAction(title: dev?.name, style: .default, handler: { action in
                    self.doAdd(device.devId)
                }))
            })

            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        } failure: { e in
            SVProgressHUD.dismiss()
        }
    }
    
    
    func doAdd(_ devId:String) {
        SVProgressHUD.show()
        var devices =  self.group?.slaveDeviceIds ?? []
        devices.append(devId)
        ThingDeviceAssociationControlManager.updateDoubleControl(withMainDeviceId: self.deviceId, slaveDeviceIds: devices, spaceId: self.homeId) {
            self.refresh {
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }
            
        } failure: { e in
            SVProgressHUD.dismiss()
        }
    }
}

extension DoubleControlVC {
    
    func remove(_ devId: String) {
        
        SVProgressHUD.show()
        ThingDeviceAssociationControlManager.removeDoubleControlSlaveDevice(withDeviceId: devId, spaceId: self.homeId) {
            self.refresh {
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
            }
        } failure: { e in
            SVProgressHUD.dismiss()
        }

    }
    
}

extension DoubleControlVC {
    
    func update(_ devId: String) {
        
        let vc = DoubleControlDpRelationVC(homeId: self.homeId, mainDeviceId: self.deviceId, slaveDeviceId: devId) { mainDeviceId, slaveDeviceId, relations in
            SVProgressHUD.show()
            ThingDeviceAssociationControlManager.updateDoubleControlDpRelation(withMainDeviceId: mainDeviceId, slaveDeviceId: slaveDeviceId, relations: relations, spaceId: self.homeId) {
                self.loadData {
                    SVProgressHUD.dismiss()
                    self.tableView.reloadData()
                }
            } failure: { e in
                SVProgressHUD.dismiss()
            }

        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


class DoubleControlDpRelationVC: UITableViewController {
    
    var homeId: Int64
    var mainDeviceId: String
    var slaveDeviceId: String
    var saveHandle: (_ mainDeviceId: String, _ slaveDeviceId: String, _ relations:[String:String]) -> Void
    var group: ThingDoubleControlGroup?
    var dpRelation: ThingDoubleControlDPRelation?
    var mainDPInfos: [ThingDoubleControlDPInfo]?
    var slaveDPInfos: [ThingDoubleControlDPInfo]?
    var relation: [String: String] = [:]

    init(homeId: Int64, mainDeviceId:String, slaveDeviceId:String, saveHandle: @escaping (_ mainDeviceId: String, _ slaveDeviceId: String, _ relations:[String:String]) -> Void) {
        self.homeId = homeId
        self.mainDeviceId = mainDeviceId
        self.slaveDeviceId = slaveDeviceId
        self.saveHandle = saveHandle
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
        let title = "save"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(save))
    }
    
    
    @objc func save() {
        let json = self.relation.reduce(into: Dictionary<String, String>()) { partialResult, pair in
            partialResult["\(pair.value)"] = "\(pair.key)"
        }
        self.saveHandle(self.mainDeviceId, self.slaveDeviceId, json)
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadData(_ completed: @escaping () -> Void) {
        SVProgressHUD.show()
        ThingDeviceAssociationControlManager.getDoubleControlDPRelation(withMainDeviceId: self.mainDeviceId, slaveDeviceId: self.slaveDeviceId, spaceId: self.homeId) { dpRelation in
            
            ThingDeviceAssociationControlManager.getLocalizedDpInfo(withDeviceId: self.mainDeviceId, spaceId: self.homeId) { mainDpInfos in
                
                ThingDeviceAssociationControlManager.getLocalizedDpInfo(withDeviceId: self.slaveDeviceId, spaceId: self.homeId) { slaveDpInfos in
                    SVProgressHUD.dismiss()

                    self.dpRelation = dpRelation
                    self.mainDPInfos = mainDpInfos
                    self.slaveDPInfos = slaveDpInfos
                    self.relation = self.dpRelation?.dpIdMap ?? [:]
                    completed()
                    
                } failure: { e in
                    SVProgressHUD.dismiss()
                    completed()
                }
                
            } failure: { e in
                SVProgressHUD.dismiss()
                completed()
            }
        } failure: { e in
            SVProgressHUD.dismiss()
            completed()
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dpRelation?.subDpIds.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "reuseIdentifier")
        
        
        
        let slaveDpId = self.dpRelation!.subDpIds[indexPath.row]
        let info = self.slaveDPInfos?.filter{"\($0.dpId)" == slaveDpId}.first
        cell.textLabel?.text = info?.name

        let mainDpId = self.relation["\(slaveDpId)"]
        let mainInfo = self.mainDPInfos?.filter{"\($0.dpId)" == mainDpId}.first
        cell.detailTextLabel?.text = mainInfo?.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let slaveDpId = self.dpRelation!.subDpIds[indexPath.row]

        let alert = UIAlertController(title: nil, message: "selectDp", preferredStyle: .actionSheet)
        
        self.dpRelation?.dpIds.forEach({ mainDpId in
            let mainInfo = self.mainDPInfos?.filter{"\($0.dpId)" == mainDpId}.first
            alert.addAction(UIAlertAction(title: mainInfo?.name, style: .default, handler: { action in
                self.update(slaveDpId, mainDpId)
            }))
        })
        
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func update(_ slaveDpId: String, _ mainDpId: String) {
        
        if let rel = self.relation.first(where: {$0.value == mainDpId}) {
            self.relation[rel.key] = nil
        }
        
        self.relation[slaveDpId] = mainDpId
        self.tableView.reloadData()
    }
    

}

