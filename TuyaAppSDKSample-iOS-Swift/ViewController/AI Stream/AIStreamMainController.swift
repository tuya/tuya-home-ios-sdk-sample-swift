//
//  AIStreamMainController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class AIStreamMainController: UITableViewController {
    
    var home: ThingSmartHomeModel? = Home.current
    var device: ThingSmartDeviceModel? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if home?.homeId != Home.current?.homeId {
            home = Home.current
            device = nil
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 1 { // AI Chat use App Identity
                guard let homeId = Home.current?.homeId else {
                    SVProgressHUD.showError(withStatus: "Please select a home first.")
                    return
                }
                let vc = StreamChatController()
                vc.homeId = homeId
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 1 { // Select device
                guard let homeId = Home.current?.homeId,
                      let inHome = ThingSmartHome(homeId: homeId) else {
                    SVProgressHUD.showError(withStatus: "Please select a home first.")
                    return
                }
                let selectDeviceVC = SelectDeviceVC(home: inHome)
                selectDeviceVC.selectDeviceHandler = { [weak self] device in
                    self?.device = device
                    self?.tableView.reloadData()
                }
                self.navigationController?.pushViewController(selectDeviceVC, animated: true)
            } else if indexPath.row == 2 { // AI Chat use Device Agent Identity
                guard let homeId = Home.current?.homeId else {
                    SVProgressHUD.showError(withStatus: "Please select a home first.")
                    return
                }
                guard let devId = self.device?.devId else {
                    SVProgressHUD.showError(withStatus: "Please select a device first.")
                    return
                }
                let vc = StreamChatController()
                vc.homeId = homeId
                vc.devId = devId
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        if (section == 0) {
            if (row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "home-select-cell")!
                cell.detailTextLabel?.text = self.home?.name ?? "Select a home"
                return cell
            } else if (row == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "stream-action-cell")!
                cell.textLabel?.text = "Start AI Chat as App"
                return cell
            }
        } else if (section == 1) {
            if (row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "home-select-cell")!
                cell.detailTextLabel?.text = self.home?.name ?? "Select a home"
                return cell
            } else if (row == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "device-select-cell")!
                cell.detailTextLabel?.text = self.device?.name ?? "Select a device"
                return cell
            } else if (row == 2) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "stream-action-cell")!
                cell.textLabel?.text = "Start AI Chat as Device Agent"
                return cell
            }
        }
        
        return UITableViewCell()
    }
}
