//
//  BEDeleteHomeViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartFamilyBizKit

class BEDeleteHomeViewController : UITableViewController {
    var homes : [ThingSmartHomeModel] = []
    var selectHomeModel : ThingSmartHomeModel?
    var index : IndexPath?
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "BEDeleteHomeCell")!
        cell.textLabel?.text = homes[indexPath.row].name
        cell.accessoryType = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectHomeModel = homes[indexPath.row]
        index = indexPath
        
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
    
    @IBAction func deleteFamily() {
        if let homeModel = selectHomeModel, let indexPath = index {
            ThingSmartFamilyBiz.sharedInstance().deleteFamily(withHomeId: homeModel.homeId) {[weak self] in
                guard let self = self else {return}
                Alert.showBasicAlert(on: self, with: "Success", message: "Delete home \(homeModel.name!)")
                self.homes.remove(at: indexPath.row)
                
                self.selectHomeModel = nil
                self.index = nil
                tableView.reloadData()
            } failure: { [weak self] error in
                guard let self = self else {return}
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: "Failed to delete home", message: "\(errorMessage)")
            }
        } else {
            Alert.showBasicAlert(on: self, with: "No home to delete", message:"")
        }
    }
}
