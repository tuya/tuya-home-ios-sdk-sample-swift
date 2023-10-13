//
//  BEJoinHomeViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartFamilyBizKit

class BEJoinHomeViewController : UITableViewController {
   
    @IBOutlet weak var invitationField : UITextField!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath), cell.tag == 1 {
            tapJoin()
        }
    }
    
    func tapJoin() {
        self.invitationField.resignFirstResponder()
        if let code = invitationField.text {
            ThingSmartFamilyBiz.sharedInstance().joinFamily(withInvitationCode: code) { result in
                let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.navigationController?.popViewController(animated: true)
                }
                
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Success", comment: ""), message: "Join Home", actions: [action])
            } failure: {[weak self] error in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Join Home", comment: ""), message: errorMessage)
            }
        }
    }
}
