//
//  TimeZoneTableViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import TuyaSmartBaseKit

class TimeZoneTableViewController: UITableViewController {
    
    let timeZoneList = TimeZone.knownTimeZoneIdentifiers

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeZoneList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let timeZoneIdentifier = timeZoneList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "time-zone-cell")!
        cell.textLabel?.text = timeZoneIdentifier
        
        if TuyaSmartUser.sharedInstance().timezoneId == timeZoneIdentifier {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedTimeZone = timeZoneList[indexPath.row]
        
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        TuyaSmartUser.sharedInstance().updateTimeZone(withTimeZoneId: selectedTimeZone) {
            
        } failure: { [weak self] (error) in
            guard let self = self else { return }
            let errorMessage = error?.localizedDescription ?? ""
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Update Time Zone", comment: ""), message: errorMessage)
        }
        
    }
}
