//
//  TextViewTableViewCell.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2022 Thing Inc. (https://developer.tuya.com/)

import UIKit

class TextViewTableViewCell: DeviceStatusBehaveCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textview: UITextView!
    
    // MARK: - Property
    var buttonAction: ((String) -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        controls.append(button)
    }
    
    // MARK: - IBAction
    @IBAction func buttonTapped(_ sender: Any) {
        endEditing(true)
        buttonAction?(textview.text ?? "")
    }
    
}
