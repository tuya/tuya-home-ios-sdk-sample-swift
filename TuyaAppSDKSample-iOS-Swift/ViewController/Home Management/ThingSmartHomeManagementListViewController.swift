//
//  ThingSmartHomeManagementListViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartDeviceKit

class ThingSmartHomeManagementListViewController : UITableViewController {
    
    @IBOutlet weak var currentHomeLabel: UILabel!
    // MARK: - Property
    let homeManager = ThingSmartHomeManager()
    
    override func viewDidLoad() {
        initiateCurrentHome()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        currentHomeLabel.text = Home.current?.name ?? NSLocalizedString("No Selection", comment: "User hasn't select a current home.")

        if #available(iOS 13.0, *) {
            currentHomeLabel.textColor = .secondaryLabel
        } else {
            currentHomeLabel.textColor = .systemGray
        }
    }
    
    // MARK: - Private Method
    private func initiateCurrentHome() {
        homeManager.getHomeList { (homeModels) in
            Home.current = homeModels?.first
        } failure: { (error) in
            
        }
    }
}
