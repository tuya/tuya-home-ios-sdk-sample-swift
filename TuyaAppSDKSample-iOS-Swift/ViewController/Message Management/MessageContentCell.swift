//
//  MessageTableViewCell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import Foundation


protocol MessageContentCellDelegate :AnyObject {
    func change(selected:Bool, msgId:String)
}

class MessageContentCell : UITableViewCell {
 
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chooseSwitch: UISwitch!
    
    weak var delegate : MessageContentCellDelegate?
    var msgId: String!
    
    func update(selected:Bool) {
        chooseSwitch.isOn = selected
    }
    
    @IBAction func change(sender:UISwitch) {
        delegate?.change(selected: sender.isOn, msgId: msgId)
    }
}
