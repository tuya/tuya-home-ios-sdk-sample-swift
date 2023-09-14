//
//  BERoomListViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartFamilyBizKit

class BERoomListViewController : UITableViewController {
    var currentHome : ThingSmartHomeModel?
    var roomList : [ThingSmartRoomModel] = []
    
    override func viewWillAppear(_ animated: Bool) {
        currentHome = ThingSmartFamilyBiz.sharedInstance().getCurrentFamily()
        if let model = currentHome {
            ThingSmartRoomBiz.sharedInstance().getRoomList(withHomeId: model.homeId) {[weak self] rooms in
                guard let self = self else {return}
                self.roomList = rooms ?? []
                self.tableView.reloadData()
            } failure: { [weak self] error in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: "Failed to Get Room", message: errorMessage)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BERoomListCell")!
        let room = roomList[indexPath.row]
        cell.textLabel?.text = room.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.performSegue(withIdentifier: "BEShowRoom", sender: roomList[indexPath.row])
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "BEShowRoom" else { return }
        guard let model = sender as? ThingSmartRoomModel else { return }
        
        let destinationVC = segue.destination as! BERoomDetailViewController
        destinationVC.room = model
    }
}
