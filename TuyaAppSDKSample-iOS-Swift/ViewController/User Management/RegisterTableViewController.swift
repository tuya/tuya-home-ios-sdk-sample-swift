//
//  RegisterTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartBaseKit

class RegisterTableViewController: UITableViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var sendVerificationCodeButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
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
        let account = accountTextField.text ?? ""

        if account.contains("@") {
            registerAccount(by: .email)
        } else {
            registerAccount(by: .phone)
        }
    }
    
    // MARK: - Private Method
    private func sendVerificationCode(by type: AccountType) {
        let countryCode = countryCodeTextField.text ?? ""
        let account = accountTextField.text ?? ""
        
        switch type {
        case .email:
            ThingSmartUser.sharedInstance().sendVerifyCode(byRegisterEmail: countryCode, email: account) {  [weak self] in
                guard let self = self else { return }
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Verification Code Sent Successfully", comment: ""), message: NSLocalizedString("Please check your email for the code.", comment: ""))
                
            } failure: { [weak self] (error) in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Sent Verification Code", comment: ""), message: errorMessage)
            }

        case .phone:
            ThingSmartUser.sharedInstance().sendVerifyCode(withUserName: account, region: nil, countryCode: countryCode, type: 1) {
                [weak self] in
                guard let self = self else { return }
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Verification Code Sent Successfully", comment: ""), message: NSLocalizedString("Please check your message for the code.", comment: ""))
            } failure: { [weak self] (error) in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Sent Verification Code", comment: ""), message: errorMessage)
            }
        }
    }
    
    private func registerAccount(by type: AccountType) {
        let countryCode = countryCodeTextField.text ?? ""
        let account = accountTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let verificationCode = verificationCodeTextField.text ?? ""
        
        switch type {
        case .email:
            ThingSmartUser.sharedInstance().register(byEmail: countryCode, email: account, password: password, code: verificationCode) { [weak self] in
                guard let self = self else { return }
                
                let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                }
                
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Registered Successfully", comment: ""), message: NSLocalizedString("Please navigate back to login your account.", comment: ""), actions: [action])
            } failure: { [weak self] (error) in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Register", comment: ""), message: errorMessage)
            }
        case .phone:
            ThingSmartUser.sharedInstance().register(byPhone: countryCode, phoneNumber: account, password: password, code: verificationCode) { [weak self] in
                guard let self = self else { return }
                
                let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                }
                
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Registered Successfully", comment: ""), message: NSLocalizedString("Please navigate back to login your account.", comment: ""), actions: [action])
                
            } failure: { [weak self] (error) in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Register", comment: ""), message: errorMessage)
            }
        }
        
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0, indexPath.row == 4 {
            sendVerificationCodeButton.sendActions(for: .touchUpInside)
        } else if indexPath.section == 1 {
            registerButton.sendActions(for: .touchUpInside)
        }
    }
    
}
