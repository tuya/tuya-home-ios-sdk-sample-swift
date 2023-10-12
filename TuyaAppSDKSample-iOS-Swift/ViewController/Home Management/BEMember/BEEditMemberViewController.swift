//
//  BEEditMemberViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartFamilyBizKit

class BEEditMemberViewController : UITableViewController {
    var member : ThingSmartHomeMemberModel?
    
    @IBOutlet weak var nameField : UITextField!
    @IBOutlet weak var roleField : UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        if let member = member {
            nameField.text = member.name
            switch member.role {
            case .member : roleField.text = "0"
            case .admin : roleField.text = "1"
            case .owner : roleField.text = "2"
            case .unknown : roleField.text = ""
            case .custom: roleField.text = ""
            @unknown default: break
            }
        }
    }
    
    @IBAction func save() {
        let role = roleField.text
        
        let requestModel = ThingSmartHomeMemberRequestModel()
        requestModel.memberId = member!.memberId
        requestModel.name = nameField.text ?? ""
        
        if role == "0" {
            requestModel.role = .member
        } else if role == "1" {
            requestModel.role = .admin
        } else if role == "2" {
            requestModel.role = .owner
        }
        
        member?.name = requestModel.name
        member?.role = requestModel.role
        
        ThingSmartMemberBiz.sharedInstance().updateHomeMemberInfo(with: requestModel) {[weak self] in
            
            guard let self = self else { return }
            let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }
            
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Success", comment: ""), message: "Edit Member", actions: [action])
        } failure: {[weak self] error in
            guard let self = self else { return }
            let errorMessage = error?.localizedDescription ?? ""
            Alert.showBasicAlert(on: self, with: "Failed to Edit Member", message: errorMessage)
        }

    }
}
