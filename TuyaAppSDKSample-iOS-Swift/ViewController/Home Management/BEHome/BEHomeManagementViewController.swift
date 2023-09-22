//
//  BEHomeManagement.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartFamilyBizKit

class BEHomeManagementViewController : UITableViewController {
    
    @IBOutlet weak var currentHomeName: UILabel!
    
    override func viewDidLoad() {
        ThingSmartFamilyBiz.sharedInstance().getFamilyList { _ in
            ThingSmartFamilyBiz.sharedInstance().launchCurrentFamily(withAppGroupName: "")
        } failure: { error in
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let home = ThingSmartFamilyBiz.sharedInstance().getCurrentFamily() {
            currentHomeName.text = home.name
        } else {
            currentHomeName.text = "No Selection"
        }
    }
}
