//
//  StepperTableViewCell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class StepperTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    // MARK: - Property
    var stepperAction: ((UIStepper) -> Void)?

    @IBAction func stepperTapped(_ sender: UIStepper) {
        stepperAction?(sender)
    }
}
