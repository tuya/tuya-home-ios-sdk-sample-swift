//
//  BEAddRoomViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartFamilyBizKit

class BEAddRoomViewController : UITableViewController {
    @IBOutlet weak var roomNameField : UITextField!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath), cell.tag == 1 {
            tapAdd()
        }
    }
    
    func tapAdd() {
        let roomName = roomNameField.text ?? ""
        if let currentHome = ThingSmartFamilyBiz.sharedInstance().getCurrentFamily() {
            ThingSmartRoomBiz.sharedInstance().addHomeRoom(withName: roomName, homeId: currentHome.homeId) { [weak self] roomModel in
                guard let self = self else { return }
                let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.navigationController?.popViewController(animated: true)
                }
                
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Success", comment: ""), message: "Add Room", actions: [action])
            } failure: {[weak self] error in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: "Failed to Add Room", message: errorMessage)
            }
        }
    }
}
