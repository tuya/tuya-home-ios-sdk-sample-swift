//
//  MatterViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartMatterKit
import ThingSmartActivatorKit

class MatterViewController: UIViewController {
    
    let tableView = UITableView()
    
    let headerTitleView = UIView()
    
    let titleLabel = UILabel()
    
    let statusView = UITextView()
    
    let scanButton = UIButton()
    
    var deviceList = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
    }
    
    func loadUI(){
        tableView.frame = self.view.bounds
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .white
        
        headerTitleView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 200)
        tableView.tableHeaderView = headerTitleView
        
        headerTitleView.addSubview(titleLabel)
        titleLabel.text = "Matter"
        titleLabel.font = UIFont.systemFont(ofSize: 30)
        titleLabel.frame = CGRectMake(0, 0, view.bounds.size.width, 30)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        
        headerTitleView.addSubview(statusView)
        statusView.font =  UIFont.systemFont(ofSize: 16)
        statusView.text = "Wait for activator"
        statusView.frame = CGRect(x: 0, y: 30, width: view.bounds.size.width, height: 170)
        statusView.textColor = .black
        
        ThingSmartMatterActivator.sharedInstance().delegate = self
    }
    
}

extension MatterViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        }else{
            return self.deviceList.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = tableView .dequeueReusableCell(withIdentifier: "matterCell")
        if(cell == nil){
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "matterCell")
        }
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 20)
        if(indexPath.section == 0){
            cell?.textLabel?.text = NSLocalizedString("Scan Matter QRCode", comment: "")
        }else{
            cell?.textLabel?.text = self.deviceList[indexPath.row]
        }
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if(indexPath.section == 0){
            let vc = QRCodeScanerViewController()
            vc.scanCallback = { [weak self] codeStr in
                let paylaod = ThingSmartMatterActivator.sharedInstance().parseSetupCode(codeStr ?? "")
                if let p = paylaod{
                    ThingSmartActivator.sharedInstance().getTokenWithHomeId(Home.current!.homeId) { token in
                        guard let t = token else {return}
                        let builder = ThingSmartConnectDeviceBuilder.init(payload: p, spaceId: Home.current!.homeId, token: t)
                        ThingSmartMatterActivator.sharedInstance().connectDevice(with: builder, timeout: 200)
                        self?.statusView.text = "Start Activator"
                    } failure: { _ in

                    }
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        }else{
            //do nothing
        }
    }
}

extension MatterViewController : ThingSmartMatterActivatorDelegate{
    func matterDeviceDiscoveryed(_ isThingDevice: Bool, deviceType: ThingSmartMatterDeviceType) {
        print("Discoveryed matter device")
    }
    
    func matterDevice(_ payload: ThingSmartMatterSetupPayload, activatorFailed error: Error) {
        let text = self.statusView.text
        self.statusView.text = "\(text ?? "")\nActivator Failed! error: \(error.localizedDescription)"
        
        scrollToBottom()
    }
    
    func matterDeviceActivatorSuccess(_ matterDevice: ThingSmartMatterDeviceModel) {
        let text = self.statusView.text
        self.statusView.text = "\(text ?? "")\nActivator Success!"
        self.deviceList.append(matterDevice.deviceModel?.name ?? "")
        self.tableView.reloadData()
        
        scrollToBottom()
    }
    
    func matterDeviceAttestation(_ device: UnsafeMutableRawPointer, error: Error) {
        let alertControl = UIAlertController(title: "Attestation", message: "Should Continue?", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Continue", style: .default) { _ in
            ThingSmartMatterActivator.sharedInstance().continueCommissioningDevice(device, ignoreAttestationFailure: true, error: nil)
        }
        let canAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            ThingSmartMatterActivator.sharedInstance().continueCommissioningDevice(device, ignoreAttestationFailure: false, error: nil)
        }
        
        alertControl.addAction(alertAction)
        alertControl.addAction(canAction)
        
        self.present(alertControl, animated: true)
        
    }
    
    func matterSupportComplete(_ gatewayName: String) {
        let text = self.statusView.text
        self.statusView.text = "\(text ?? "")\nMatter Suppport Complete!"
        
        scrollToBottom()
    }
    
    func matterRoutingComplete(_ routingType: ThingMatterRoutingType) {
        print("route complete!")
        scrollToBottom()
    }
    
    func matterCommissioningSessionEstablishmentComplete(_ deviceModel: ThingSmartMatterDeviceModel) {
        if(deviceModel.matterType == .WIFI){
            let model = ThingSmartMatterCommissionModel.init(sSid: "Your WIFI Name", password: "Your WIFI Password")
            ThingSmartMatterActivator.sharedInstance().commissionDevice(deviceModel, commissionModel: model)
        }
        let text = self.statusView.text
        self.statusView.text = "\(text ?? "")\nMatter Pase Complete!"
        
        scrollToBottom()
    }
    
    //5.5.0才有
//    func matterCommissioningStatusUpdate(_ status: ThingMatterStatus) {
//        let text = self.statusView.text
//        switch status{
//        case .discovery:
//            self.statusView.text = "\(text ?? "")\nMatter Discoverying!"
//            break
//
//        case .connecting:
//            self.statusView.text = "\(text ?? "")\nMatter Connectting!"
//            break
//        case .nocSigning:
//            self.statusView.text = "\(text ?? "")\nMatter Noc Signing!"
//            break
//        case .commissioning:
//            self.statusView.text = "\(text ?? "")\nMatter Commissioning!"
//            break
//        case .activing:
//            self.statusView.text = "\(text ?? "")\nMatter Activing!"
//            break
//        @unknown default:
//            break
//        }
//
//        scrollToBottom()
//    }
    
    private func scrollToBottom(){
        self.statusView.layoutManager.allowsNonContiguousLayout = false;
        self.statusView.scrollRangeToVisible(NSRange.init(location: self.statusView.text?.count ?? 0 , length: 1))
    }
}
