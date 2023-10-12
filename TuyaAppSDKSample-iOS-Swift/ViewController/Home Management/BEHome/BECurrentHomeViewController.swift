//
//  BECurrentHomeViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartFamilyBizKit

class BECurrentHomeViewController : UITableViewController {
    var homes : [ThingSmartHomeModel] = []
    
    override func viewDidLoad() {
        ThingSmartFamilyBiz.sharedInstance().getFamilyList(success: { homeList in
            self.homes = homeList ?? []
            self.tableView.reloadData()
        }, failure: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BECurrentHomeCell")!
        cell.textLabel?.text = homes[indexPath.row].name
        
        let currentHomeId = ThingSmartFamilyBiz.sharedInstance().getCurrentFamilyId()
        if currentHomeId == homes[indexPath.row].homeId {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentHomeId = homes[indexPath.row].homeId
        ThingSmartFamilyBiz.sharedInstance().setCurrentFamilyId(currentHomeId)
        
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
