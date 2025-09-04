//
//  FaceIDLoginViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartLocalAuthKit
import ThingSmartBaseKit

class FaceIDLoginViewController : UIViewController {
    
    // MARK: - Properties
    private let context = ThingBiometricLoginManager()
    
    // MARK: - IBOutlets
    private lazy var settingLabel: UILabel = {
        let label = UILabel()
        label.text = "Face ID Setting"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var syncButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Not synchronized", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(syncButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if checkFaceIDStatus() {
            syncButton.setTitle("Synchronized", for: .normal)
        } else {
            syncButton.setTitle("Not synchronized", for: .normal)
        }
        setupUI()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.addSubview(settingLabel)
        view.addSubview(syncButton)
        
        NSLayoutConstraint.activate([
            settingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            settingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            syncButton.topAnchor.constraint(equalTo: settingLabel.bottomAnchor, constant: 16),
            syncButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func syncButtonTapped() {
        print("Sync button tapped")
        let isFaceIDEnabled = checkFaceIDStatus()

        if isFaceIDEnabled {
            showCloseAlert()
        } else {
            showOpenAlert()
        }
    }
    
    // MARK: - Face ID Methods
    private func checkFaceIDStatus() -> Bool {
        // Check if device can evaluate policy
        var error: NSError?
        let canEvaluate = context.laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if (!canEvaluate) {
            return false
        }
        
        let userInfo = context.getBiometricLoginUserAccountInfo()
        let uid = userInfo.uid
        if uid == ThingSmartUser.sharedInstance().uid {
            return true
        } else {
            return false
        }
    }
    
    private func openLA() {
        context.openBiometricLogin(withEvaluatePolicy:.deviceOwnerAuthenticationWithBiometrics, localizedReason:"Open Face ID Login") { success, error in
            if let error = error {
                return
            }
            if success {
                self.syncButton.setTitle("Synchronized", for: .normal)
            } else {
                self.syncButton.setTitle("Not synchronized", for: .normal)
            }
        }
    }
    
    private func clearLA() {
        context.closeBiometricLogin { success, error  in
            self.syncButton.setTitle("Not synchronized", for: .normal)
        }
    }
    
    private func showOpenAlert() {
        let alert = UIAlertController(title: "Enable login with Face ID?", message: "You can log in with Face ID. We will not store your Face ID information.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.openLA()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func showCloseAlert() {
        let alert = UIAlertController(title: "Disable login with Face ID?", message: "You can no longer log in with Face ID.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.clearLA()
        }))
        present(alert, animated: true, completion: nil)
    }
}
