//
//  BECreateInvitationViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartFamilyBizKit

class BECreateInvitationViewController : UITableViewController {
    @IBOutlet weak var invitationCodeLabel : UILabel!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, indexPath.row == 1 {
            tapCreate()
        }
    }
    
    func tapCreate() {
        if let home = ThingSmartFamilyBiz.sharedInstance().getCurrentFamily() {
            ThingSmartMemberBiz.sharedInstance().createInvitation(withHomeId: home.homeId) {[weak self] resultModel in
                guard let self = self else {return}
                self.invitationCodeLabel.text = resultModel.invitationCode
            } failure: { error in
                
            }
        } else {
            Alert.showBasicAlert(on: self, with: "Failed to Create Invitation", message: "No Home")
        }
    }
}
