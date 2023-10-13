//
//  BEMemberListViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartFamilyBizKit

class BEMemberListViewController : UITableViewController {
    var currentHome : ThingSmartHomeModel?
    var memberList : [ThingSmartHomeMemberModel] = []
    
    override func viewWillAppear(_ animated: Bool) {
        currentHome = ThingSmartFamilyBiz.sharedInstance().getCurrentFamily()
        if let model = currentHome {
            ThingSmartMemberBiz.sharedInstance().getHomeMemberList(withHomeId: model.homeId) {[weak self] members  in
                guard let self = self else { return }
                self.memberList = members
                self.tableView.reloadData()
            } failure: {[weak self] error in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: "Failed to get member list", message: errorMessage)
            }
        } else {
            memberList = []
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BEMemberListCell")!
        let member = memberList[indexPath.row]
        cell.textLabel?.text = member.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.performSegue(withIdentifier: "BEShowMember", sender: memberList[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "BEShowMember" else { return }
        guard let model = sender as? ThingSmartHomeMemberModel else { return }
        
        let destinationVC = segue.destination as! BEMemberDetailViewController
        destinationVC.member = model
    }
}
