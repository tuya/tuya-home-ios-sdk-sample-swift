//
//  BECreateDefaultHomeViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartFamilyBizKit

class BECreateDefaultHomeViewController : UITableViewController {
    
    @IBOutlet weak var nameField : UITextField!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath), cell.tag == 1 {
            tapCreate()
        }
    }
    
    func tapCreate() {
        let name = nameField.text ?? ""
        ThingSmartFamilyBiz.sharedInstance().createDefaultFamily(withName: name) {[weak self] homeId in
            guard let self = self else { return }
            let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }
            
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("Successfully added new home.", comment: ""), actions: [action])
        } failure: { [weak self] error in
            guard let self = self else { return }
            let errorMessage = error?.localizedDescription ?? ""
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Add New Home", comment: ""), message: errorMessage)
        }
    }
}
