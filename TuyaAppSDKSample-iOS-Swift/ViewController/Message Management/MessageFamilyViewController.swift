//
//  MessageFamilyViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartMessageKit
import ThingSmartBaseKit

class MessageFamilyViewController : UITableViewController, MessageContentCellDelegate {
    
    let message = ThingSmartMessage()
    var messageList : [ThingSmartMessageListModel] = []
    var deleteIds : [String] = []
    
    override func viewDidLoad() {
        loadData()
    }
    
    func loadData() {
        let requestModel = ThingSmartMessageListRequestModel()
        requestModel.msgType = .family
        requestModel.limit = 30
        requestModel.offset = 0
        message.fetchList(with: requestModel) {[weak self] list in
            guard let self = self else {return}
            self.messageList = list
            self.tableView.reloadData()
        } failure: { error in
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageContentCell")! as? MessageContentCell
        cell?.titleLabel.text = messageList[indexPath.row].msgTypeContent
        cell?.contentLabel.text = messageList[indexPath.row].msgContent
        cell?.msgId = messageList[indexPath.row].msgId
        cell?.chooseSwitch.isOn = false
        cell?.delegate = self
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func change(selected: Bool, msgId: String) {
        if selected {
            deleteIds.append(msgId)
        } else {
            deleteIds.removeAll { obj in
                obj == msgId
            }
        }
    }
    
    @IBAction func delete() {
        let requestModel = ThingSmartMessageListDeleteRequestModel()
        requestModel.msgIds = deleteIds
        requestModel.msgType = .family
        
        message.delete(with: requestModel) { result in
            self.loadData()
        } failure: { error in
            
        }

    }
    
    
}
