//
//  BEInvitedHomeViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartFamilyBizKit

class BEInvitedHomeViewController : UITableViewController {
    var homes : [ThingSmartHomeModel] = []
    
    override func viewDidLoad() {
        ThingSmartFamilyBiz.sharedInstance().getFamilyList(success: { [weak self] homeList in
            guard let self = self else {return}
            if let homeList = homeList {
                for home in homeList {
                    switch home.dealStatus {
                    case .accept :
                        print("accept")
                    case .pending:
                        self.homes.append(home)
                    case .reject:
                        print("reject")
                    @unknown default:
                        fatalError()
                    }
                }
            }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "BEInvitedHomeCell")!
        cell.textLabel?.text = homes[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = homes[indexPath.row]
        
        let action = UIAlertAction(title: "Accept", style: .default) { [weak self] _ in
            guard let self = self else { return }
            ThingSmartFamilyBiz.sharedInstance().acceptJoinFamily(withHomeId: model.homeId) {[weak self] _ in
                guard let self = self else {return}
                homes.remove(at: indexPath.row)
                self.tableView.reloadData()
            } failure: {[weak self] error in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Accept Home", comment: ""), message: errorMessage)
            }
        }
        
        let action2 =  UIAlertAction(title: "Reject", style: .default) { [weak self] _ in
            guard let self = self else { return }
            ThingSmartFamilyBiz.sharedInstance().rejectJoinFamily(withHomeId: model.homeId) {[weak self] _ in
                guard let self = self else {return}
                homes.remove(at: indexPath.row)
                self.tableView.reloadData()
            } failure: {[weak self] error in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Reject Home", comment: ""), message: errorMessage)
            }
        }
        
        Alert.showBasicAlert(on: self, with: "是否接受加入家庭", message: "", actions: [action, action2])
    }
}
