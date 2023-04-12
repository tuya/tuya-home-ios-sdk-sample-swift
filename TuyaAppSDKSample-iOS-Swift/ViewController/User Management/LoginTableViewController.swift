//
//  LoginTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartBaseKit

class LoginTableViewController: UITableViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        let account = accountTextField.text ?? ""
        
        // Simply examine weather the account is an email address of a phone number. Thing SDK will handle the validation.
        if account.contains("@") {
            login(by: .email)
        } else {
            login(by: .phone)
        }
    }
    
    // MARK: - Private Method
    private func login(by type: AccountType) {
        let countryCode = countryCodeTextField.text ?? ""
        let account = accountTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        switch type {
        case .email:
            ThingSmartUser.sharedInstance().login(byEmail: countryCode,
                                                 email: account,
                                                 password: password) { [weak self] in
                guard let self = self else { return }
                let storyboard = UIStoryboard(name: "ThingSmartMain", bundle: nil)
                let vc = storyboard.instantiateInitialViewController()
                self.window?.rootViewController = vc

            } failure: { [weak self] (error) in
                guard let self = self else { return }
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Login", comment: ""), message: error?.localizedDescription ?? "")
            }

        case .phone:
            ThingSmartUser.sharedInstance().login(byPhone: countryCode, phoneNumber: account, password: password) { [weak self] in
                guard let self = self else { return }
                let storyboard = UIStoryboard(name: "ThingSmartMain", bundle: nil)
                let vc = storyboard.instantiateInitialViewController()
                self.window?.rootViewController = vc
                
            } failure: { [weak self] (error) in
                guard let self = self else { return }
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Login", comment: ""), message: error?.localizedDescription ?? "")
            }

        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            loginButton.sendActions(for: .touchUpInside)
        } else if indexPath.section == 2 {
            forgetPasswordButton.sendActions(for: .touchUpInside)
        }
    }
}
