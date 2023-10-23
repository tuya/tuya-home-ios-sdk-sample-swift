//
//  SceneAddCell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation

class SceneAddCell: UITableViewCell {
    
    @IBOutlet weak var addButton: UIButton!
    var onTappedAddCompletion:(()->Void)?
    
    @IBAction func onTappedAdd(_ sender: Any) {
        if let onTappedAddCompletion = onTappedAddCompletion {
            onTappedAddCompletion()
        }
    }
}
