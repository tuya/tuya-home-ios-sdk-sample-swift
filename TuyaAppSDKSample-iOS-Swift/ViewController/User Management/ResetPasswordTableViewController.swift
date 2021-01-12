//
//  ResetPasswordTableViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import TuyaSmartBaseKit

class ResetPasswordTableViewController: UITableViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - IBAction
    @IBAction func sendVerificationCode(_ sender: UIButton) {
        let countryCode = countryCodeTextField.text ?? ""
        let account = accountTextField.text ?? ""
        
        if account.contains("@") {
            TuyaSmartUser.sharedInstance().sendVerifyCode(byEmail: countryCode, email: account) { [weak self] in
                guard let self = self else { return }
                Alert.showBasicAlert(on: self, with: "Verification Code Sent Successfully", message: "Please check your email for the code.")
                
            } failure: { [weak self] (error) in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: "Failed to Sent Verification Code", message: errorMessage)
            }

        } else {
            TuyaSmartUser.sharedInstance().sendVerifyCode(countryCode, phoneNumber: account, type: 2) {  [weak self] in
                guard let self = self else { return }
                Alert.showBasicAlert(on: self, with: "Verification Code Sent Successfully", message: "Please check your message for the code.")
                
            } failure: { [weak self] (error) in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: "Failed to Sent Verification Code", message: errorMessage)
            }

        }
    }
    
    @IBAction func resetPassword(_ sender: UIButton) {
        let countryCode = countryCodeTextField.text ?? ""
        let account = accountTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let verificationCode = verificationCodeTextField.text ?? ""
        
        if account.contains("@") {
            TuyaSmartUser.sharedInstance().resetPassword(byEmail: countryCode, email: account, newPassword: password, code: verificationCode) { [weak self] in
                guard let self = self else { return }
                Alert.showBasicAlert(on: self, with: "Password Reset Successfully", message: "Please navigate back.")
            } failure: { [weak self] (error) in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: "Failed to Reset Password", message: errorMessage)
            }

        } else {
            TuyaSmartUser.sharedInstance().resetPassword(byPhone: countryCode, phoneNumber: account, newPassword: password, code: verificationCode) { [weak self] in
                guard let self = self else { return }
                Alert.showBasicAlert(on: self, with: "Password Reset Successfully", message: "Please navigate back.")
                
            } failure: { [weak self] (error) in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: "Failed to Reset Password", message: errorMessage)
            }

        }
    }
}
