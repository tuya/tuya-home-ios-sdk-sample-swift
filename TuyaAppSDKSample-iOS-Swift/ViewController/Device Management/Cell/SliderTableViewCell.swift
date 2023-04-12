//
//  StepperTableViewCell.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit

class SliderTableViewCell: DeviceStatusBehaveCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    // MARK: - Property
    var sliderAction: ((UISlider) -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        controls.append(slider)
    }

    // MARK: - IBAction
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        sliderAction?(sender)
    }

}
