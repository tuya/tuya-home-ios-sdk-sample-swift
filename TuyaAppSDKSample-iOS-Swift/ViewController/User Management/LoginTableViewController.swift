//
//  LoginTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartBaseKit
import ThingSmartLocalAuthKit

class LoginTableViewController: UITableViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    @IBOutlet weak var faceIDLoginButton: UIButton!
    
    private let laContext = ThingBiometricLoginManager()
    
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
    
    @IBAction func faceIDLoginTapped(_ sender: UIButton) {

        if self.checkFaceID() {
            // check faceid info
            let userInfo = laContext.getBiometricLoginUserAccountInfo()
            let uid = userInfo.uid
            laContext.loginByBiometric(withEvaluatePolicy:.deviceOwnerAuthenticationWithBiometrics , localizedReason: "Login com Face ID") { success, result, error in
                if success {
                    ThingSmartUser.sharedInstance().reset(userInfo: result as! [AnyHashable : Any], source: 9)
                    let storyboard = UIStoryboard(name: "ThingSmartMain", bundle: nil)
                    let vc = storyboard.instantiateInitialViewController()
                    self.window?.rootViewController = vc
                }
            }
        } else {
            
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
                
                // Login Success, update current Account Infomation
                UserDefaults.standard.set(ThingSmartUser.sharedInstance().uid, forKey: "com.thing.userInfo")

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
                
                // Login Success, update current Account Infomation
                UserDefaults.standard.set(ThingSmartUser.sharedInstance().uid, forKey: "com.thing.userInfo")
                
            } failure: { [weak self] (error) in
                guard let self = self else { return }
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Login", comment: ""), message: error?.localizedDescription ?? "")
            }

        }
    }
    
    private func checkFaceID() -> Bool {
        // Check if device can evaluate policy
        var error: NSError?
        let canEvaluate = laContext.laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if (!canEvaluate) {
            return false
        }
        
        let userInfo = laContext.getBiometricLoginUserAccountInfo()
        let biometricUid = userInfo.uid;
        let lastUid = UserDefaults.standard.object(forKey: "com.thing.userInfo") as? String
        if biometricUid == lastUid {
//            return true
        } else {
            return false
        }
        
        do {
            try laContext.isBiometricLoginEnabled()
        } catch {
            Alert.showBasicAlert(on: self, with: NSLocalizedString("FaceID not available", comment: ""), message: error.localizedDescription)
            return false
        }
        
        return true
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
