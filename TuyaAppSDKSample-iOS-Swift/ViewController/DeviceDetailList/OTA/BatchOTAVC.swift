//
//  BatchOTAVC.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class BatchOTAVC: UITableViewController {

    var homeId: Int64
    var deviceId: String
    var needOTA: Bool = false
    var supportBatchOTA: Bool = false
    var patchOTADeviceIds: [String] = []
    var patchOTADeviceMap: [String: ThingSmartDevice] = [:]
    var patchOTAStatusMap: [String: String] = [:]

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
    
    func loadData(_ complete: @escaping () -> Void) {
        
        let support = ThingUpgradeManager.deviceSupportUpgrade(deviceId)
        if (support == false) {
            needOTA = false;
            complete()
            return;
        }
        
        SVProgressHUD.show()
        ThingUpgradeManager.getUpgradeInfo(withDeviceId: deviceId) { info in
            
            if (!info.needUpgrade || info.isUpgrading) {
                SVProgressHUD.dismiss()
                self.needOTA = false
                complete()
                return
            }
            
            self.needOTA = true
            ThingUpgradeListManager.sharedInstance().getDeviceBatchOTAInfo(self.deviceId) { result in
                SVProgressHUD.dismiss()
                let deviceIds = result.deviceList?.compactMap({ item in
                    return item["devId"] as? String
                })
                self.supportBatchOTA = result.supportGroup
                self.patchOTADeviceIds = deviceIds ?? []
                self.patchOTADeviceMap = self.patchOTADeviceIds.reduce(into: Dictionary<String, ThingSmartDevice>(), { partialResult, devId in
                    let device = ThingSmartDevice(deviceId: devId)
                    device?.delegate = self
                    partialResult[devId] = device
                })
                complete()
            } failure: { error in
                SVProgressHUD.dismiss()
                complete()
            }
            
        } failure: { error in
            SVProgressHUD.dismiss()
            complete()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 2
        }else{
            return patchOTADeviceIds.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "AssociationControlVCReuseIdentifier")
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.textLabel?.text = "need OTA"
                cell.detailTextLabel?.text = needOTA ? "true" : "false"
            } else {
                cell.textLabel?.text = "support batch OTA"
                cell.detailTextLabel?.text = supportBatchOTA ? "true" : "false"
            }
        }else{
            let deviceId = patchOTADeviceIds[indexPath.row]
            let device = patchOTADeviceMap[deviceId]
            let status = patchOTAStatusMap[deviceId]

            cell.textLabel?.text = device?.deviceModel.name
            cell.detailTextLabel?.text = status
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section != 0 {return}
        
        if (indexPath.row == 0) {
            // single OTA
            singleOta()
        } else {
            // batch OTA
            batchOta()
        }
    }
    
    func singleOta() {
        // single OTA
    }
    
    func batchOta() {
        SVProgressHUD.show()
        ThingUpgradeListManager.sharedInstance().batchUpgrade(withDevIds: self.patchOTADeviceIds) { result in
            SVProgressHUD.dismiss()

            print("upgrading device ids: \(result.comfirmSuccessDevIds), failed device ids: \(result.comfirmFailureDevIds), unsubmit device ids: \(result.unsubmitDevIds)")
        } failure: { error in
            SVProgressHUD.dismiss()
        }
    }

}


extension BatchOTAVC: ThingSmartDeviceDelegate {
    
    func device(_ device: ThingSmartDevice, otaUpdateStatusChanged statusModel: ThingSmartFirmwareUpgradeStatusModel) {
        // update upgrade status of UI as single OTA
        
        if (statusModel.upgradeStatus == ThingSmartDeviceUpgradeStatus(3)) {
            patchOTAStatusMap[device.devId] = "success"
        }else if (statusModel.upgradeStatus == ThingSmartDeviceUpgradeStatus(2)) {
            patchOTAStatusMap[device.devId] = "upgrading"
        }else if (statusModel.upgradeStatus == ThingSmartDeviceUpgradeStatus(4)) {
            patchOTAStatusMap[device.devId] = "failure"
        }

        self.tableView.reloadData()
    }
    
}
