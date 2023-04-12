//
//  TemperatureUnitTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartBaseKit

class TemperatureUnitTableViewController: UITableViewController {
    
    @IBOutlet weak var celsiusCell: UITableViewCell!
    @IBOutlet weak var fahrenheitCell: UITableViewCell!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ThingSmartUser.sharedInstance().tempUnit == 1 {
            celsiusCell.accessoryType = .checkmark
        } else if ThingSmartUser.sharedInstance().tempUnit == 2 {
            fahrenheitCell.accessoryType = .checkmark
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            celsiusCell.accessoryType = .checkmark
            fahrenheitCell.accessoryType = .none
        } else {
            celsiusCell.accessoryType = .none
            fahrenheitCell.accessoryType = .checkmark
        }
        
        ThingSmartUser.sharedInstance().updateTempUnit(withTempUnit: indexPath.row + 1) {
            
        } failure: { [weak self] (error) in
            guard let self = self else { return }
            let errorMessage = error?.localizedDescription ?? ""
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Update Unit", comment: ""), message: errorMessage)
        }
    }


}
