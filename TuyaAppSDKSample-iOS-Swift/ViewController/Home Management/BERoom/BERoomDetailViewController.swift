//
//  BERoomDetailViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartFamilyBizKit

class BERoomDetailViewController : UITableViewController {
    var room : ThingSmartRoomModel?
    var currentHome : ThingSmartHomeModel?
    
    @IBOutlet weak var roomIdLabel : UILabel!
    @IBOutlet weak var roomNameLabel : UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        currentHome = ThingSmartFamilyBiz.sharedInstance().getCurrentFamily()
        if let model = room {
            roomIdLabel.text = "\(model.roomId)"
            roomNameLabel.text = model.name
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath), cell.tag == 1 {
           tapDelete()
        }
    }
    
    func tapDelete() {
        if let room = room, let home = currentHome {
            ThingSmartRoomBiz.sharedInstance().removeHomeRoom(withRoomId: room.roomId, homeId: home.homeId) {[weak self] in
                guard let self = self else { return }
                let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.navigationController?.popViewController(animated: true)
                }
                
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Success", comment: ""), message: "Delete Room", actions: [action])
            } failure: { error in
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "BEShowEditRoom" else { return }

        let destinationVC = segue.destination as! BEEditRoomViewController
        destinationVC.room = room
        destinationVC.homeId = currentHome?.homeId ?? 0
    }
}
