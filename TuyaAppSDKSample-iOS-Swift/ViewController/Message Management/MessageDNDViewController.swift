//
//  MessageDNDViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartMessageKit
class MessageDNDViewController : UITableViewController {
    let setting = ThingSmartMessageSetting()
    var dndList : [MessageDNDModel] = []
    
    var settingStatus : Bool = false
    
    @IBAction func addTimer() {
        let requestModel = ThingSmartMessageSettingDNDRequestModel()
        requestModel.isAllDevIDs = true
        requestModel.startTime = "08:00"
        requestModel.endTime = "12:00"
        requestModel.loops = "0111110"
        
        setting.addDND(with: requestModel) {
            self.loadData()
        } failure: { error in
            
        }

    }
    
    override func viewDidLoad() {
        setting.getDeviceDNDSettingstatusSuccess { result in
            self.settingStatus = result
        } failure: { error in
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }
    
    func loadData() {
        setting.getDNDListSuccess { result in
            var list : [MessageDNDModel] = []
            if let result = result {
                for obj in result {
                    if let data = try? JSONSerialization.data(withJSONObject: obj, options: JSONSerialization.WritingOptions.init())  {
                        if var model = try? JSONDecoder.init().decode(MessageDNDModel.self, from: data) {
                            list.append(model)
                        }
                    }
                }
            }
            self.dndList = list
            self.tableView.reloadData()
        } failure: { error in
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return dndList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DNDSettingCell")! as? MessageDNDSettingCell
            cell?.settingSwitch.isOn = settingStatus
            return cell!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageDNDCell")!
        cell.textLabel?.text = dndList[indexPath.row].startTime + "-" + dndList[indexPath.row].endTime
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowDNDDetail" else { return }
        guard let cell = sender as? UITableViewCell else {
            return
        }
        
        if let indexPath = tableView.indexPath(for: cell) {
            let model = dndList[indexPath.row]
            let destinationVC = segue.destination as! MessageDNDDetailViewController
            destinationVC.dndModel = model
        }
    }
}
