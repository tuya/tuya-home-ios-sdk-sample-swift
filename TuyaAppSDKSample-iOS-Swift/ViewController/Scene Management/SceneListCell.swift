//
//  SceneListCell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation

class SceneListCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
   
    var onTappedDeleteCompletion: (()->Void)?
    var onTappedOtherCompletion: (()->Void)?
    
    @IBAction func onTappedDeleteButton(_ sender: Any) {
        if let onTappedDeleteCompletion = onTappedDeleteCompletion {
            onTappedDeleteCompletion()
        }
    }
    
    @IBAction func onTappedOtherButton(_ sender: Any) {
        if let onTappedOtherCompletion = onTappedOtherCompletion {
            onTappedOtherCompletion()
        }
    }
}
