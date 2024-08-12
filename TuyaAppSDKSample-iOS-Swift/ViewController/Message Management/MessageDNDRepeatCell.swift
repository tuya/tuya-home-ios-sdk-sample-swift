//
//  MessageDNDRepeatCell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import Foundation

class MessageDNDRepeatCell : UITableViewCell {
    @IBOutlet weak var checkView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func update(index:Int, selected:Bool) {
        switch index {
        case 0:
            titleLabel.text = "Sunday"
        case 1:
            titleLabel.text = "Monday"
        case 2:
            titleLabel.text = "Tuesday"
        case 3:
            titleLabel.text = "Wednesday"
        case 4:
            titleLabel.text = "Thursday"
        case 5:
            titleLabel.text = "Friday"
        case 6:
            titleLabel.text = "Saturday"
        default:
            titleLabel.text = ""
        }
        
        checkView.isHidden = !selected
    }
    
    func update(selected:Bool) {
        checkView.isHidden = !selected
    }
}
