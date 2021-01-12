//
//  UserInformationTableViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import TuyaSmartBaseKit

class UserInformationTableViewController: UITableViewController {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailAddressLabel: UILabel!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var timeZoneLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameLabel.text = TuyaSmartUser.sharedInstance().userName
        phoneNumberLabel.text = TuyaSmartUser.sharedInstance().phoneNumber
        emailAddressLabel.text = TuyaSmartUser.sharedInstance().email
        countryCodeLabel.text = TuyaSmartUser.sharedInstance().countryCode
        timeZoneLabel.text = TuyaSmartUser.sharedInstance().timezoneId
    }
}
