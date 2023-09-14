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
        ThingSmartFamilyBiz.sharedInstance().loadCurrentFamily()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentHomeName.text = ThingSmartFamilyBiz.sharedInstance().getCurrentFamily()?.name ?? "未选择"
    }
}
