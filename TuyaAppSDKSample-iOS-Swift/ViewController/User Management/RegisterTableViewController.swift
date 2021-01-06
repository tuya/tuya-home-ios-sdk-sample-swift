//
//  RegisterTableViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import TuyaSmartBaseKit

class RegisterTableViewController: UITableViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - IBAction
    @IBAction func sendVerificationCode(_ sender: UIButton) {
        let countryCode = countryCodeTextField.text ?? ""
        let emailAddress = emailAddressTextField.text ?? ""
        
        TuyaSmartUser.sharedInstance().sendVerifyCode(byRegisterEmail: countryCode, email: emailAddress) {
            Alert.showBasicAlert(on: self, with: "Verification Code Sent Successfully", message: "Please check your email for the code.")
        } failure: { (error) in
            let errorMessage = error?.localizedDescription ?? ""
            Alert.showBasicAlert(on: self, with: "Failed to Sent Verification Code", message: errorMessage)
        }
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        let countryCode = countryCodeTextField.text ?? ""
        let emailAddress = emailAddressTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let verificationCode = verificationCodeTextField.text ?? ""
        
        TuyaSmartUser.sharedInstance().register(byEmail: countryCode, email: emailAddress, password: password, code: verificationCode) {
            Alert.showBasicAlert(on: self, with: "Registered Successfully", message: "Please navigate back to login your account.")
        } failure: { (error) in
            let errorMessage = error?.localizedDescription ?? ""
            Alert.showBasicAlert(on: self, with: "Failed to Register", message: errorMessage)
        }
    }
}
