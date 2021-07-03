//
//  SIGMeshTableViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import TuyaSmartActivatorKit
import TuyaSmartBLEMeshKit

class SIGMeshTableViewController: UITableViewController {
    
    var deviceListData:[TuyaSmartSIGMeshDiscoverDeviceInfo] = []
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        TuyaSmartSIGMeshManager.sharedInstance().stopSerachDevice()
        TuyaSmartSIGMeshManager.sharedInstance().stopActiveDevice()
        TuyaSmartSIGMeshManager.sharedInstance().delegate = nil
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SIGMeshDeviceTableViewCellID")
    }
    
    
    @IBAction func searchClicked(_ sender: Any) {
        if  let homeId = Home.current?.homeId {
            print(TuyaSmartHome.init(homeId: homeId))
            let sigMeshModel = TuyaSmartHome.init(homeId: homeId)?.sigMeshModel
            TuyaSmartSIGMeshManager.sharedInstance().startScan(with: .ScanForUnprovision, meshModel: sigMeshModel)
            TuyaSmartSIGMeshManager.sharedInstance().delegate = self
        }
        
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceListData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SIGMeshDeviceTableViewCellID", for: indexPath)
        cell.textLabel?.text = deviceListData[indexPath.row].productId
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if  let homeId = Home.current?.homeId {
            let sigMeshModel = TuyaSmartHome.init(homeId: homeId)?.sigMeshModel
            SVProgressHUD.show(withStatus: NSLocalizedString("Configuring", comment: ""))
            TuyaSmartSIGMeshManager.sharedInstance().startActive(deviceListData, meshModel: sigMeshModel)
        }
    }
    
}


extension SIGMeshTableViewController: TuyaSmartSIGMeshManagerDelegate{
    
    func sigMeshManager(_ manager: TuyaSmartSIGMeshManager, didScanedDevice device: TuyaSmartSIGMeshDiscoverDeviceInfo) {
        deviceListData.append(device)
        tableView.reloadData()
    }
    
    func sigMeshManager(_ manager: TuyaSmartSIGMeshManager, didActiveSubDevice device: TuyaSmartSIGMeshDiscoverDeviceInfo, devId: String, error: Error) {
        if  let homeId = Home.current?.homeId {
            let sigMeshModel = TuyaSmartHome.init(homeId: homeId)?.sigMeshModel
            TuyaSmartSIGMeshManager.sharedInstance().startScan(with: .ScanForProxyed, meshModel: sigMeshModel)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                SVProgressHUD.showSuccess(withStatus: NSLocalizedString("Successfully Added \(device.peripheral.cbPeripheral.name ?? "Unknown")", comment: "Successfully added one device."))
                self.navigationController?.popViewController(animated: true);
            }
        }
    }
    
    func sigMeshManager(_ manager: TuyaSmartSIGMeshManager, didFailToActiveDevice device: TuyaSmartSIGMeshDiscoverDeviceInfo, error: Error) {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
}
