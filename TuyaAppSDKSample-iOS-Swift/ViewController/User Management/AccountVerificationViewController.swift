//
//  AccountVerificationViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Created by AI Assistant on 2024
//

import UIKit

class AccountVerificationViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: AccountVerificationDelegate?
    private var verificationCode: String = ""
    private var accountType: AccountType = .phone
    private var displayAccount: String = ""
    private var currentLoadingAlert: UIAlertController?
    
    enum AccountType {
        case phone
        case email
    }
    
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
        label.text = "Enter Verification Code"
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var codeInputStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var codeInputFields: [UITextField] = []
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var resendLink: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Didn't receive code?", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(resendLinkTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var getCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Verification Code", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(getCodeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var verifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Verify", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray4
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.addTarget(self, action: #selector(verifyButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var customKeyboard: UIView = {
        let keyboardView = UIView()
        keyboardView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        return keyboardView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAccountInfo()
        setupUI()
        setupCodeInputFields()
        setupCustomKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Setup
    private func setupAccountInfo() {
        let email = ThingSmartUser.sharedInstance().email
        let phoneNumber = ThingSmartUser.sharedInstance().phoneNumber
        
        // 按照提供的逻辑：优先使用邮箱，如果邮箱无效则使用手机号的后半部分
        if isValidEmail(email) {
            accountType = .email
            displayAccount = email
        } else if !phoneNumber.isEmpty {
            accountType = .phone
            // 提取手机号的后半部分（去掉国家代码）
            let components = phoneNumber.components(separatedBy: "-")
            displayAccount = components.last ?? phoneNumber
        } else {
            // 默认使用手机号
            accountType = .phone
            displayAccount = "Unknown Account"
        }
    }
    
    private func setupUI() {
        title = "Enter Verification Code"
        view.backgroundColor = .systemBackground
        
        // 添加滚动视图
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 添加内容
        contentView.addSubview(titleLabel)
        contentView.addSubview(codeInputStackView)
        contentView.addSubview(instructionLabel)
        contentView.addSubview(resendLink)
        contentView.addSubview(getCodeButton)
        contentView.addSubview(verifyButton)
        
        // 添加自定义键盘
        view.addSubview(customKeyboard)
        
        // 设置约束
        NSLayoutConstraint.activate([
            // ScrollView约束
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: customKeyboard.topAnchor),
            
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
            
            // 验证码输入框约束
            codeInputStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            codeInputStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            codeInputStackView.heightAnchor.constraint(equalToConstant: 50),
            codeInputStackView.widthAnchor.constraint(equalToConstant: 300),
            
            // 说明文字约束
            instructionLabel.topAnchor.constraint(equalTo: codeInputStackView.bottomAnchor, constant: 30),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 重新发送链接约束
            resendLink.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20),
            resendLink.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // 获取验证码按钮约束
            getCodeButton.topAnchor.constraint(equalTo: resendLink.bottomAnchor, constant: 30),
            getCodeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            getCodeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            getCodeButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 开始验证按钮约束
            verifyButton.topAnchor.constraint(equalTo: getCodeButton.bottomAnchor, constant: 20),
            verifyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            verifyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            verifyButton.heightAnchor.constraint(equalToConstant: 50),
            verifyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // 自定义键盘约束
            customKeyboard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customKeyboard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customKeyboard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customKeyboard.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupCodeInputFields() {
        for i in 0..<6 {
            let textField = UITextField()
            textField.textAlignment = .center
            textField.font = UIFont.systemFont(ofSize: 24, weight: .medium)
            textField.keyboardType = .numberPad
            textField.backgroundColor = .systemBackground
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.systemGray4.cgColor
            textField.layer.cornerRadius = 8
            textField.tag = i
            textField.delegate = self
            
            // 添加点击手势
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(codeFieldTapped(_:)))
            textField.addGestureRecognizer(tapGesture)
            
            codeInputFields.append(textField)
            codeInputStackView.addArrangedSubview(textField)
        }
        
        // 设置第一个输入框为活跃状态
        codeInputFields[0].becomeFirstResponder()
    }
    
    private func setupCustomKeyboard() {
        let buttonTitles = [
            ["1", "2 ABC", "3 DEF"],
            ["4 GHI", "5 JKL", "6 MNO"],
            ["7 PQRS", "8 TUV", "9 WXYZ"],
            ["", "0", "⌫"]
        ]
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 1
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for row in buttonTitles {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 1
            
            for (index, title) in row.enumerated() {
                let button = UIButton(type: .system)
                button.setTitle(title, for: .normal)
                button.setTitleColor(.label, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
                button.backgroundColor = .white
                button.layer.borderWidth = 0.5
                button.layer.borderColor = UIColor.systemGray4.cgColor
                
                if title == "⌫" {
                    button.setTitle("", for: .normal)
                    button.setImage(UIImage(systemName: "delete.left"), for: .normal)
                    button.tintColor = .label
                    button.addTarget(self, action: #selector(backspaceTapped), for: .touchUpInside)
                } else if !title.isEmpty {
                    button.addTarget(self, action: #selector(numberTapped(_:)), for: .touchUpInside)
                }
                
                rowStackView.addArrangedSubview(button)
            }
            
            stackView.addArrangedSubview(rowStackView)
        }
        
        customKeyboard.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: customKeyboard.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: customKeyboard.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: customKeyboard.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: customKeyboard.bottomAnchor)
        ])
    }
    
    
    // MARK: - Helper Methods
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func updateInstructionText() {
        let accountText = accountType == .email ? displayAccount : "\(ThingSmartUser.sharedInstance().countryCode ?? "")-\(displayAccount)"
        instructionLabel.text = "Verification code has been sent to your \(accountType == .email ? "email" : "phone"). \(accountText)"
    }
    
    private func showSendFailureMessage(_ errorMessage: String) {
        // 隐藏"未收到验证码？"链接
        resendLink.isHidden = true
        
        // 在instructionLabel中显示失败消息
        instructionLabel.text = "Failed to send verification code: \(errorMessage)"
        instructionLabel.textColor = .systemRed
        
        // 3秒后恢复原始状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.resendLink.isHidden = false
            self?.instructionLabel.textColor = .secondaryLabel
            self?.updateInstructionText()
        }
    }
    
    // MARK: - Actions
    @objc private func codeFieldTapped(_ gesture: UITapGestureRecognizer) {
        guard let textField = gesture.view as? UITextField else { return }
        textField.becomeFirstResponder()
    }
    
    @objc private func numberTapped(_ sender: UIButton) {
        guard let number = sender.titleLabel?.text?.components(separatedBy: " ").first else { return }
        inputNumber(number)
    }
    
    @objc private func backspaceTapped() {
        if !verificationCode.isEmpty {
            verificationCode.removeLast()
            updateCodeDisplay()
        }
    }
    
    @objc private func resendLinkTapped() {
        resendCode()
    }
    
    @objc private func getCodeButtonTapped() {
        resendCode()
    }
    
    @objc private func verifyButtonTapped() {
        verifyCode()
    }
    
    // MARK: - Helper Methods
    private func inputNumber(_ number: String) {
        if verificationCode.count < 6 {
            verificationCode += number
            updateCodeDisplay()
        }
    }
    
    private func updateCodeDisplay() {
        for (index, textField) in codeInputFields.enumerated() {
            if index < verificationCode.count {
                textField.text = String(verificationCode[verificationCode.index(verificationCode.startIndex, offsetBy: index)])
                textField.layer.borderColor = UIColor.systemBlue.cgColor
            } else {
                textField.text = ""
                textField.layer.borderColor = UIColor.systemGray4.cgColor
            }
        }
        
        // 更新验证按钮状态
        updateVerifyButton()
        
        // 设置下一个输入框为活跃状态
        let nextIndex = min(verificationCode.count, 5)
        if nextIndex < 6 {
            codeInputFields[nextIndex].becomeFirstResponder()
        }
    }
    
    private func updateVerifyButton() {
        let isCodeComplete = verificationCode.count == 6
        verifyButton.isEnabled = isCodeComplete
        verifyButton.backgroundColor = isCodeComplete ? .systemBlue : .systemGray4
    }
    
    private func verifyCode() {
        
        // 创建验证请求模型
        let requestModel = ThingSmartAccountAuthenticationRequestModel()
        requestModel.countryCode = ThingSmartUser.sharedInstance().countryCode
        requestModel.userName = displayAccount
        requestModel.authCode = verificationCode
        
        // 根据账号类型设置验证类型
        let email = ThingSmartUser.sharedInstance().email
        if !email.isEmpty {
            requestModel.accountType = .email
        } else {
            requestModel.accountType = .phone
        }
        
        requestModel.verifyType = .authCode
        
        // 调用验证接口
        ThingSmartUser.sharedInstance().getLogoutCode(
            byAuthorizingAccount: requestModel,
            success: { [weak self] result in
                // 验证成功，通知代理并传递authModel
                self?.delegate?.didCompleteAccountVerification(with: result)
                self?.showSuccessAlert()
            },
            failure: { [weak self] error in
                self?.showErrorAlert(message: "Verification failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        )
    }
    
    private func resendCode() {
        verificationCode = ""
        updateCodeDisplay()
        
        // 显示加载提示
        showLoadingAlert(message: "Sending verification code...")
        
        let email = ThingSmartUser.sharedInstance().email
        let phoneNumber = ThingSmartUser.sharedInstance().phoneNumber
        
        // 按照提供的逻辑：优先使用邮箱，如果邮箱无效则使用手机号的后半部分
        let accountText: String
        if isValidEmail(email) {
            accountText = email
            accountType = .email
        } else if !phoneNumber.isEmpty {
            // 提取手机号的后半部分（去掉国家代码）
            let components = phoneNumber.components(separatedBy: "-")
            accountText = components.last ?? phoneNumber
            accountType = .phone
        } else {
            dismiss(animated: true) {
                self.showSendFailureMessage("Unable to get account information")
            }
            return
        }
        
        displayAccount = accountText
        
        ThingSmartUser.sharedInstance().sendVerifyCode(
            withUserName: accountText,
            region: ThingSmartUser.sharedInstance().regionCode,
            countryCode: ThingSmartUser.sharedInstance().countryCode,
            type: 10
        ) { [weak self] in
            DispatchQueue.main.async {
                self?.hideLoadingAlert()
                self?.updateInstructionText()
            }
        } failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.hideLoadingAlert()
                self?.showSendFailureMessage(error?.localizedDescription ?? "Unknown error")
            }
        }
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

// MARK: - UITextFieldDelegate
extension AccountVerificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 只允许输入数字
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        if !allowedCharacters.isSuperset(of: characterSet) {
            return false
        }
        
        // 限制输入长度
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if newText.count > 1 {
            return false
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // 当输入框内容改变时，更新验证码
        if let text = textField.text, !text.isEmpty {
            let index = textField.tag
            if index < verificationCode.count {
                let startIndex = verificationCode.index(verificationCode.startIndex, offsetBy: index)
                let endIndex = verificationCode.index(after: startIndex)
                verificationCode.replaceSubrange(startIndex..<endIndex, with: text)
            } else {
                verificationCode += text
            }
        }
        
        updateCodeDisplay()
    }
}
