//
//  TuyaSmartMainTableViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import TuyaSmartDeviceKit

class TuyaSmartMainTableViewController: UITableViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var currentHomeLabel: UILabel!
    
    // MARK: - Property
    let homeManager = TuyaSmartHomeManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initiateCurrentHome()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    
    
    // MARK: - IBAction
    @IBAction func logoutTapped(_ sender: UIButton) {
        let alertViewController = UIAlertController(title: nil, message: NSLocalizedString("You're going to log out this account.", comment: "User tapped the logout button."), preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: NSLocalizedString("Logout", comment: "Confirm logout."), style: .destructive) { [weak self] (action) in
            guard let self = self else { return }
            TuyaSmartUser.sharedInstance().loginOut {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateInitialViewController()
                self.window?.rootViewController = vc
            } failure: {
                [weak self] (error) in
                   guard let self = self else { return }
                   Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Log Out", comment: "Failed to Log Out"), message: error?.localizedDescription ?? "")
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel)
        
        alertViewController.popoverPresentationController?.sourceView = sender
        
        alertViewController.addAction(logoutAction)
        alertViewController.addAction(cancelAction)
        
        self.present(alertViewController, animated: true, completion: nil)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Logout button row tapped
        if indexPath.section == 0 && indexPath.row == 1 {
            logoutButton.sendActions(for: .touchUpInside)
        }
    }
}
