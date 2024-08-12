//
//  MessageDNDDetailViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartMessageKit

class MessageDNDDetailViewController : UITableViewController {
    var dndModel : MessageDNDModel?
    let messageSetting = ThingSmartMessageSetting()
    var selectMap : [Int : Bool] = [:]
    
    override func viewDidLoad() {
        if let dndModel = dndModel {
            for (index, show) in dndModel.loops.enumerated() {
                selectMap[index] = show == "1"
            }
        }
        
        messageSetting.getDNDDeviceListSuccess { result in
            print(result)
        } failure: { error in
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        
        if section == 1 {
            return 7
        }
        
        if section == 2 {
            return 1
        }
        
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimeCell", for: indexPath) as? MessageDNDTimeCell
            if indexPath.row == 0 {
                cell?.titleLabel.text = "Start"
                cell?.inputFiled.text = dndModel?.startTime
            } else if indexPath.row == 1 {
                cell?.titleLabel.text = "End"
                cell?.inputFiled.text = dndModel?.endTime
            }
            return cell!
        }
        
        if section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RepeatCell", for: indexPath) as? MessageDNDRepeatCell
            let row = indexPath.row
            cell?.update(index: row, selected: selectMap[row] ?? false)
            return cell!
        }
        
        
        if section == 2  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as? MessageDNDDeviceCell
            cell?.titlelabel.text = "Include all device"
            cell?.actionSwitch.isOn = dndModel?.allDevIds ?? false
            cell?.block = { [weak self] result in
                self?.dndModel?.allDevIds = result
            }
            return cell!
        }
       
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SaveCell", for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteCell", for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let row = indexPath.row
            selectMap[row] = !selectMap[row]!
            let cell = tableView.cellForRow(at: indexPath) as? MessageDNDRepeatCell
            cell?.update(selected: selectMap[row]!)
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                updateDND()
            } else {
                deleteDND()
            }
        }
    }
    
    func updateDND() {
        let startCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? MessageDNDTimeCell
        let endCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? MessageDNDTimeCell
        
        let requestModel = ThingSmartMessageSettingDNDRequestModel()
        requestModel.startTime = startCell?.inputFiled.text ?? ""
        requestModel.endTime = endCell?.inputFiled.text ?? ""
        
        var loops = ""
        for i in 0..<7 {
            let choose = selectMap[i]
            if let choose = choose, choose {
                loops += "1"
            } else {
                loops += "0"
            }
        }
        requestModel.loops = loops
        requestModel.isAllDevIDs = dndModel?.allDevIds ?? false
        
        messageSetting.modifyDND(withTimerID: dndModel!.timerId, dndRequestModel: requestModel) {
            self.navigationController?.popViewController(animated: true)
        } failure: { error in
            
        }

    }
    
    func deleteDND() {
        messageSetting.removeDND(withTimerID: dndModel?.timerId ?? 0) {
            self.navigationController?.popViewController(animated: true)
        } failure: { error in
            
        }
    }
}
