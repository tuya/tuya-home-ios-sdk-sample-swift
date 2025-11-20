//
//  DeviceLogoutVerificationViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Created by AI Assistant on 2024
//

import UIKit

// MARK: - Protocol
protocol AccountVerificationDelegate: AnyObject {
    func didCompleteAccountVerification(with authModel: ThingSmartAccountAuthenticationModel)
}

class DeviceLogoutVerificationViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: DeviceLogoutVerificationDelegate?
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Security Verification"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "To ensure your account security, please choose one of the following verification methods"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var accountVerificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Account Verification", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(accountVerificationTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var passwordVerificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Password Verification", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(passwordVerificationTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Security Verification"
        view.backgroundColor = .systemGroupedBackground
        
        // 添加滚动视图
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 添加内容
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(accountVerificationButton)
        contentView.addSubview(passwordVerificationButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            // ScrollView约束
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView约束
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 标题约束
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 描述约束
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 账号验证按钮约束
            accountVerificationButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 60),
            accountVerificationButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            accountVerificationButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            accountVerificationButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 密码验证按钮约束
            passwordVerificationButton.topAnchor.constraint(equalTo: accountVerificationButton.bottomAnchor, constant: 20),
            passwordVerificationButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordVerificationButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            passwordVerificationButton.heightAnchor.constraint(equalToConstant: 50),
            passwordVerificationButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Actions
    @objc private func accountVerificationTapped() {
        showAccountVerification()
    }
    
    @objc private func passwordVerificationTapped() {
        showPasswordVerification()
    }
    
    // MARK: - Verification Methods
    private func showAccountVerification() {
        // 跳转到验证码输入页面
        let verificationVC = AccountVerificationViewController()
        verificationVC.delegate = self
        navigationController?.pushViewController(verificationVC, animated: true)
    }
    
    private func showPasswordVerification() {
        // 跳转到密码验证页面
        let passwordVC = PasswordVerificationViewController()
        passwordVC.delegate = self
        navigationController?.pushViewController(passwordVC, animated: true)
    }
    
    private func performAccountVerification(account: String, code: String) {
        // 模拟账号验证过程
        showLoadingAlert(message: "Verifying account...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.dismiss(animated: true) {
                // 模拟验证成功
                self?.showSuccessAlert(message: "Account verification successful")
            }
        }
    }
    
    private func performPasswordVerification(password: String) {
        // 模拟密码验证过程
        showLoadingAlert(message: "Verifying password...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.dismiss(animated: true) {
                // 模拟验证成功
                self?.showSuccessAlert(message: "Password verification successful")
            }
        }
    }
    
    // MARK: - Alert Methods
    private func showLoadingAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        
        present(alert, animated: true)
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(
            title: "Verification Successful",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.delegate?.didCompleteVerification()
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Verification Failed",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - AccountVerificationDelegate
extension DeviceLogoutVerificationViewController: AccountVerificationDelegate {
    func didCompleteAccountVerification(with authModel: ThingSmartAccountAuthenticationModel) {
        // 账号验证完成后，执行登出操作并传递authModel
        delegate?.didCompleteAccountVerification(with: authModel)
    }
}
