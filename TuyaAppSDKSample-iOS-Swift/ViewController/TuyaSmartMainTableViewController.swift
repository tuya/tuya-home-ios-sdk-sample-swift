//
//  TuyaSmartMainTableViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import TuyaSmartBaseKit

class TuyaSmartMainTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        TuyaSmartUser.sharedInstance().loginOut { [weak self] in
            guard let self = self else { return }
            
            let alertViewController = UIAlertController(title: nil, message: "You're going to log out this account.", preferredStyle: .actionSheet)
            let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { (action) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateInitialViewController()
                self.window?.rootViewController = vc
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            alertViewController.addAction(logoutAction)
            alertViewController.addAction(cancelAction)
            
            self.present(alertViewController, animated: true, completion: nil)
            
            
        } failure: { [weak self] (error) in
            guard let self = self else { return }
            Alert.showBasicAlert(on: self, with: "Failed to Log Out", message: error?.localizedDescription ?? "")
        }

    }
    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
