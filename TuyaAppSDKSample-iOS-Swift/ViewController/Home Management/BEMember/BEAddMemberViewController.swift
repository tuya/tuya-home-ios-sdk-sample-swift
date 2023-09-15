//
//  BEAddMemberViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartFamilyBizKit

class BEAddMemberViewController : UITableViewController {
    @IBOutlet weak var homeField : UITextField!
    @IBOutlet weak var nameField : UITextField!
    @IBOutlet weak var codeField : UITextField!
    @IBOutlet weak var accountField : UITextField!
    @IBOutlet weak var roleField : UITextField!
    
    
    func tapAdd() {
        let role = roleField.text
        var homeId : Int64?
        
        if let text = homeField.text {
            homeId = Int64(text) ?? nil
        }
        
        guard let homeId = homeId else {
            Alert.showBasicAlert(on: self, with: "Failed to Add Member", message: "Home Id is invalid")
            return
        }
        
        let requestModel = ThingSmartHomeAddMemberRequestModel()
        requestModel.name = nameField.text ?? ""
        requestModel.account = accountField.text ?? ""
        requestModel.countryCode = codeField.text ?? ""
        
        
        if role == "0" {
            requestModel.role = .member
        } else if role == "1" {
            requestModel.role = .admin
        } else {
            Alert.showBasicAlert(on: self, with: "Failed to Add Member", message: "role value is invalid, input 0 or 1")
            return
        }
        
        ThingSmartMemberBiz.sharedInstance().addHomeMember(with: requestModel, homeId: homeId) {[weak self] member in
            guard let self = self else { return }
            let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }
            
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Success", comment: ""), message: "Add Member", actions: [action])
        } failure: { [weak self] error in
            guard let self = self else { return }
            let errorMessage = error?.localizedDescription ?? ""
            Alert.showBasicAlert(on: self, with: "Failed to Add Member", message: errorMessage)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath), cell.tag == 1 {
            tapAdd()
        }
    }
}
