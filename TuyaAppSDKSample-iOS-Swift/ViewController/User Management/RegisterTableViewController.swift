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
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - IBAction
    @IBAction func sendVerificationCode(_ sender: UIButton) {
        let account = accountTextField.text ?? ""
        
        if account.contains("@") {
            sendVerificationCode(by: .email)
        } else {
            sendVerificationCode(by: .phone)
        }
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        let countryCode = countryCodeTextField.text ?? ""
        let emailAddress = accountTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let verificationCode = verificationCodeTextField.text ?? ""
        
        TuyaSmartUser.sharedInstance().register(byEmail: countryCode, email: emailAddress, password: password, code: verificationCode) { [weak self] in
            guard let self = self else { return }
            Alert.showBasicAlert(on: self, with: "Registered Successfully", message: "Please navigate back to login your account.")
        } failure: { [weak self] (error) in
            guard let self = self else { return }
            let errorMessage = error?.localizedDescription ?? ""
            Alert.showBasicAlert(on: self, with: "Failed to Register", message: errorMessage)
        }
    }
    
    private func sendVerificationCode(by type: AccountType) {
        let countryCode = countryCodeTextField.text ?? ""
        let account = accountTextField.text ?? ""
        
        switch type {
        case .email:
            TuyaSmartUser.sharedInstance().sendVerifyCode(byRegisterEmail: countryCode, email: account) {  [weak self] in
                guard let self = self else { return }
                Alert.showBasicAlert(on: self, with: "Verification Code Sent Successfully", message: "Please check your email for the code.")
                
            } failure: { [weak self] (error) in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: "Failed to Sent Verification Code", message: errorMessage)
            }

        case .phone:
            TuyaSmartUser.sharedInstance().sendVerifyCode(countryCode, phoneNumber: account, type: 1) {  [weak self] in
                guard let self = self else { return }
                Alert.showBasicAlert(on: self, with: "Verification Code Sent Successfully", message: "Please check your message for the code.")
                
            } failure: { [weak self] (error) in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: "Failed to Sent Verification Code", message: errorMessage)
                
            }

        }
    }
}
