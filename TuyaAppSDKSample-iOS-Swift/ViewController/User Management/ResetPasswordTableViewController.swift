//
//  ResetPasswordTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartBaseKit

class ResetPasswordTableViewController: UITableViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var sendVerificationCodeButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - IBAction
    @IBAction func sendVerificationCode(_ sender: UIButton) {
        let countryCode = countryCodeTextField.text ?? ""
        let account = accountTextField.text ?? ""
        
        if account.contains("@") {
            ThingSmartUser.sharedInstance().sendVerifyCode(byEmail: countryCode, email: account) { [weak self] in
                guard let self = self else { return }
                Alert.showBasicAlert(on: self, with: NSLocalizedString(NSLocalizedString("Failed to Login", comment: ""), comment: ""), message: NSLocalizedString("Please check your email for the code.", comment: ""))
                
            } failure: { [weak self] (error) in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Sent Verification Code", comment: ""), message: errorMessage)
            }

        } else {
            ThingSmartUser.sharedInstance().sendVerifyCode(withUserName: account, region: nil, countryCode: countryCode, type: 2) {
                [weak self] in
                guard let self = self else { return }
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Verification Code Sent Successfully", comment: ""), message: NSLocalizedString("Please check your message for the code.", comment: ""))
            } failure: {
                [weak self] (error) in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Sent Verification Code", comment: ""), message: errorMessage)
            }

        }
    }
    
    @IBAction func resetPassword(_ sender: UIButton) {
        let countryCode = countryCodeTextField.text ?? ""
        let account = accountTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let verificationCode = verificationCodeTextField.text ?? ""
        
        if account.contains("@") {
            ThingSmartUser.sharedInstance().resetPassword(byEmail: countryCode, email: account, newPassword: password, code: verificationCode) { [weak self] in
                guard let self = self else { return }
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Password Reset Successfully", comment: ""), message: NSLocalizedString("Please navigate back.", comment: ""))
            } failure: { [weak self] (error) in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Reset Password", comment: ""), message: errorMessage)
            }

        } else {
            ThingSmartUser.sharedInstance().resetPassword(byPhone: countryCode, phoneNumber: account, newPassword: password, code: verificationCode) { [weak self] in
                guard let self = self else { return }
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Password Reset Successfully", comment: ""), message: NSLocalizedString("Password Reset Successfully", comment: ""))
                
            } failure: { [weak self] (error) in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Reset Password", comment: ""), message: errorMessage)
            }

        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1, indexPath.row == 1 {
            sendVerificationCodeButton.sendActions(for: .touchUpInside)
        } else if indexPath.section == 2 {
            resetButton.sendActions(for: .touchUpInside)
        }
    }
}
