//
//  PasswordVerificationViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Created by AI Assistant on 2024
//

import UIKit

class PasswordVerificationViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: AccountVerificationDelegate?
    private var password: String = ""
    private var currentLoadingAlert: UIAlertController?
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter your login password"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Password verification is only supported for accounts registered with phone numbers and without bound email addresses"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray4
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        passwordTextField.becomeFirstResponder()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Password Verification"
        view.backgroundColor = .systemGroupedBackground
        
        // 添加导航栏返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        // 添加子视图
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(instructionLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(confirmButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            instructionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            instructionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            subtitleLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            passwordTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            confirmButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 40),
            confirmButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            confirmButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            confirmButton.heightAnchor.constraint(equalToConstant: 50),
            confirmButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func passwordChanged() {
        password = passwordTextField.text ?? ""
        updateConfirmButton()
    }
    
    @objc private func confirmButtonTapped() {
        guard !password.isEmpty else { return }
        
        passwordTextField.resignFirstResponder()
        verifyPassword()
        
    }
    
    // MARK: - Verification
    private func verifyPassword() {
        
        // 创建验证请求模型
        let requestModel = ThingSmartAccountAuthenticationRequestModel()
        requestModel.countryCode = ThingSmartUser.sharedInstance().countryCode
        
        // 按照提供的逻辑处理手机号：去掉国家码和"-"
        let phone = ThingSmartUser.sharedInstance().phoneNumber
        if phone.contains("-") {
            requestModel.userName = phone.components(separatedBy: "-").last ?? phone
        } else {
            requestModel.userName = phone
        }
        
        requestModel.password = password
        requestModel.ifencrypt = 1
        requestModel.accountType = .phone
        
        requestModel.verifyType = .password
        
        // 调用验证接口
        ThingSmartUser.sharedInstance().getLogoutCode(
            byAuthorizingAccount: requestModel,
            success: { [weak self] result in
                DispatchQueue.main.async {
                    // 验证成功，通知代理并传递authModel
                    self?.delegate?.didCompleteAccountVerification(with: result)
                    // 延迟显示成功提示，确保加载提示完全隐藏
                    self?.showSuccessAlert()
                }
            },
            failure: { [weak self] error in
                DispatchQueue.main.async {
                    self?.hideLoadingAlert()
                    // 延迟显示错误提示，确保加载提示完全隐藏
                    self?.showErrorAlert(message: "Password verification failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        )
    }
    
    // MARK: - Helper Methods
    private func updateConfirmButton() {
        let isValid = !password.isEmpty
        confirmButton.isEnabled = isValid
        confirmButton.backgroundColor = isValid ? .systemBlue : .systemGray4
    }
    
    // MARK: - Alert Methods
    private func showLoadingAlert(message: String) {
        // 先隐藏之前的loading alert
        hideLoadingAlert()
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        currentLoadingAlert = alert
        present(alert, animated: true)
    }
    
    private func hideLoadingAlert() {
        if let alert = currentLoadingAlert {
            alert.dismiss(animated: true)
            currentLoadingAlert = nil
        }
    }
    
    private func showSuccessAlert(message: String = "Verification Successful") {
        let alert = UIAlertController(
            title: "Verification Successful",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let viewControllers = self.navigationController?.viewControllers {
                for viewController in viewControllers {
                    if viewController is MultiDeviceLoginViewController {
                        self.navigationController?.popToViewController(viewController, animated: true)
                        break
                    }
                }
            }
        }))
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
