//
//  MessageNoticeViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartMessageKit

class MessageNoticeViewController : UITableViewController {
    let message = ThingSmartMessage()
    var messageList : [ThingSmartMessageListModel] = []
    
    override func viewDidLoad() {
        let requestModel = ThingSmartMessageListRequestModel()
        requestModel.msgType = .notice
        requestModel.limit = 15
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
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
