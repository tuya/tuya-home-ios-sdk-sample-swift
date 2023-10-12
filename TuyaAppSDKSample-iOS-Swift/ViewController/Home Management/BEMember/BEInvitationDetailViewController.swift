//
//  BEInvitationDetailViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartFamilyBizKit

class BEInvitationDetailViewController : UITableViewController {
    var invitation : ThingSmartHomeInvitationRecordModel?
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var nameField : UITextField!
    @IBOutlet weak var codeLabel : UILabel!
    @IBOutlet weak var validTimeLabel : UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        if let model = invitation {
            nameField.text = model.name
            codeLabel.text = "Invitation Code : " + model.invitationCode
            validTimeLabel.text = "Valid Time : " + String(model.validTime) + " " + "hours"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.tag == 1 {
                tapUpdate()
            } else if cell.tag == 2 {
                tapReinvite()
            } else if cell.tag == 3 {
                tapCancel()
            }
            if indexPath.section != 0 || indexPath.row != 0 {
                nameField.resignFirstResponder()
            }
        }
    }
    
    func tapCancel() {
        if let model = invitation {
            ThingSmartMemberBiz.sharedInstance().cancelInvitation(withInvitationId: model.invitationID) { result in
                let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.navigationController?.popViewController(animated: true)
                }
                
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Success", comment: ""), message: "Cancel Invitation", actions: [action])
            } failure: {[weak self] error in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: "Failed to Cancel Invitation", message: errorMessage)
            }
        }
    }
    
    
    func tapUpdate() {
        if let newName = nameField.text, let model = invitation {
            let requestModel = ThingSmartHomeInvitationInfoRequestModel()
            requestModel.invitationID = model.invitationID
            requestModel.name = newName
            ThingSmartMemberBiz.sharedInstance().updateInvitation(with: requestModel) {[weak self] result in
                guard let self = self else {return}
                let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.navigationController?.popViewController(animated: true)
                }
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Success", comment: ""), message: "Update Invitation", actions: [action])
            } failure: {[weak self] error in
                guard let self = self else {return}
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: "Failed to Update Invitation", message:errorMessage , actions: [])
            }
        }
    }
    
    func tapReinvite() {
        if let model = invitation {
            ThingSmartMemberBiz.sharedInstance().reinviteInvitation(withInvitationId: model.invitationID) {[weak self] resultModel in
                guard let self = self else {return}
                let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.navigationController?.popViewController(animated: true)
                }
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Success", comment: ""), message: "Reinvite Invitation", actions: [action])
            } failure: {[weak self] error in
                guard let self = self else {return}
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: "Failed to Reinvite Invitation", message:errorMessage , actions: [])
            }
        }
    }
    
    @IBAction func tapEdit() {
        if !nameField.isFirstResponder {
            editBtn.setTitle("Done", for: .normal)
            nameField.becomeFirstResponder()
        } else {
            editBtn.setTitle("Edit", for: .normal)
            nameField.resignFirstResponder()
        }
    }
}
