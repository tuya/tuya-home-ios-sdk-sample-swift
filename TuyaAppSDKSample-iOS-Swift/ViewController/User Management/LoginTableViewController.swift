//
//  LoginTableViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import TuyaSmartBaseKit

class LoginTableViewController: UITableViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        let account = accountTextField.text ?? ""
        
        // Simply examine weather the account is an email address of a phone number. Tuya SDK will handle the validation.
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
            TuyaSmartUser.sharedInstance().login(byEmail: countryCode,
                                                 email: account,
                                                 password: password) { [weak self] in
                guard let self = self else { return }
                let storyboard = UIStoryboard(name: "TuyaSmartMain", bundle: nil)
                let vc = storyboard.instantiateInitialViewController()
                self.window?.rootViewController = vc

            } failure: { [weak self] (error) in
                guard let self = self else { return }
                Alert.showBasicAlert(on: self, with: "Failed to Login", message: error?.localizedDescription ?? "")
            }

        case .phone:
            TuyaSmartUser.sharedInstance().login(byPhone: countryCode, phoneNumber: account, password: password) { [weak self] in
                guard let self = self else { return }
                let storyboard = UIStoryboard(name: "TuyaSmartMain", bundle: nil)
                let vc = storyboard.instantiateInitialViewController()
                self.window?.rootViewController = vc
                
            } failure: { [weak self] (error) in
                guard let self = self else { return }
                Alert.showBasicAlert(on: self, with: "Failed to Login", message: error?.localizedDescription ?? "")
            }

        }
    }
}
