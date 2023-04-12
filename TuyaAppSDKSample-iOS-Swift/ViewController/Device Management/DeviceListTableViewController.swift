//
//  DeviceListTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartDeviceKit

class DeviceListTableViewController: UITableViewController {
    // MARK: - Property
    private var home: ThingSmartHome?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if Home.current != nil {
            home = ThingSmartHome(homeId: Home.current!.homeId)
            home?.delegate = self
            updateHomeDetail()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return home?.deviceList.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "device-list-cell")!
        
        guard let deviceModel = home?.deviceList[indexPath.row] else { return cell }
        
        cell.textLabel?.text = deviceModel.name
        cell.detailTextLabel?.text = deviceModel.isOnline ? NSLocalizedString("Online", comment: "") : NSLocalizedString("Offline", comment: "")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let deviceID = home?.deviceList[indexPath.row].devId else { return }
        guard let device = ThingSmartDevice(deviceId: deviceID) else { return }
        
        let storyboard = UIStoryboard(name: "DeviceList", bundle: nil)
        let isSupportThingModel = device.deviceModel.isSupportThingModelDevice()
        let identifier = isSupportThingModel ? "ThingLinkDeviceControlController" : "DeviceControlTableViewController"
        
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        if isSupportThingModel {
            jumpTuyaLinkDeviceControl(vc as! ThingLinkDeviceControlController, device: device)
        } else {
            jumpNormalDeviceControl(vc as! DeviceControlTableViewController, device: device)
        }
    }

    // MARK: - Private method
    private func updateHomeDetail() {
        home?.getDataWithSuccess({ (model) in
            self.tableView.reloadData()
        }, failure: { [weak self] (error) in
            guard let self = self else { return }
            let errorMessage = error?.localizedDescription ?? ""
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Fetch Home", comment: ""), message: errorMessage)
        })
    }
    
    private func jumpTuyaLinkDeviceControl(_ vc: ThingLinkDeviceControlController, device: ThingSmartDevice) {
        let goTuyaLinkControl = { () -> Void in
            vc.device = device
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if let _ = device.deviceModel.thingModel {
            goTuyaLinkControl()
        } else {
            SVProgressHUD.show(withStatus: NSLocalizedString("Fetching Thing Model", comment: ""))
            device.getThingModel { _ in
                SVProgressHUD.dismiss()
                goTuyaLinkControl()
            } failure: { error in
                SVProgressHUD.showError(withStatus: NSLocalizedString("Failed to Fetch Thing Model", comment: ""))
            }
        }
    }
    
    private func jumpNormalDeviceControl(_ vc: DeviceControlTableViewController, device: ThingSmartDevice) {
        vc.device = device
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension DeviceListTableViewController: ThingSmartHomeDelegate{
    func homeDidUpdateInfo(_ home: ThingSmartHome!) {
        tableView.reloadData()
    }
    
    func home(_ home: ThingSmartHome!, didAddDeivice device: ThingSmartDeviceModel!) {
        tableView.reloadData()
    }
    
    func home(_ home: ThingSmartHome!, didRemoveDeivice devId: String!) {
        tableView.reloadData()
    }
    
    func home(_ home: ThingSmartHome!, deviceInfoUpdate device: ThingSmartDeviceModel!) {
        tableView.reloadData()
    }
    
    func home(_ home: ThingSmartHome!, device: ThingSmartDeviceModel!, dpsUpdate dps: [AnyHashable : Any]!) {
        tableView.reloadData()
    }
}
