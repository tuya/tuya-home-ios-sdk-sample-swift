//
//  AIAgentRoleEditViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2026 Tuya Inc. (https://developer.tuya.com/)

import UIKit

/// Create / edit custom role page
///
/// Create: m.life.ai.agent.role.custom-role.add;
/// Edit: fetch details first (m.life.ai.agent.role.custom-role.detail) to pre-fill the form, then call m.life.ai.agent.role.custom-role.update on save.
/// Avatar / language / voice are chosen via the corresponding pickers (see AIAgentPickers.swift).
class AIAgentRoleEditViewController: UITableViewController {

    enum Mode {
        case create
        case edit(roleId: String)
    }

    private let devId: String
    private let mode: Mode
    private let agentRequest = ThingSmartAIAgentRequest()

    /// Callback after a successful create/update (fired before the page is closed)
    var onSaved: (() -> Void)?

    // Form data
    private var avatarURL: String?
    private var langCode: String?
    private var langName: String?
    private var timbreId: String?
    private var timbreName: String?

    // Form controls
    private let avatarView = AIAgentRemoteImageView()
    private let nameField = UITextField()
    private let introduceView = UITextView()
    private let descView = UITextView()
    private let speedField = UITextField()
    private let needBindSwitch = UISwitch()

    // Static cells (created once to avoid input controls being re-mounted on reloadData)
    private lazy var avatarCell: UITableViewCell = {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "Select Avatar"
        avatarView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        cell.accessoryView = avatarView
        return cell
    }()
    private lazy var nameCell: UITableViewCell = fieldCell(nameField)
    private lazy var introduceCell: UITableViewCell = textViewCell(introduceView)
    private lazy var descCell: UITableViewCell = textViewCell(descView)
    private lazy var langCell: UITableViewCell = {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = "Language"
        cell.accessoryType = .disclosureIndicator
        return cell
    }()
    private lazy var timbreCell: UITableViewCell = {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = "Voice"
        cell.accessoryType = .disclosureIndicator
        return cell
    }()
    private lazy var speedCell: UITableViewCell = {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "Speech Rate"
        cell.selectionStyle = .none
        speedField.frame = CGRect(x: 0, y: 0, width: 120, height: 30)
        cell.accessoryView = speedField
        return cell
    }()
    private lazy var bindCell: UITableViewCell = {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "Bind to device after saving"
        cell.selectionStyle = .none
        cell.accessoryView = needBindSwitch
        return cell
    }()

    private var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    init(devId: String, mode: Mode) {
        self.devId = devId
        self.mode = mode
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = isEditMode ? "Edit Role" : "Create New Role"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))
        setupControls()
        if case .edit(let roleId) = mode {
            loadDetail(roleId: roleId)
        }
    }

    private func setupControls() {
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 8
        avatarView.tintColor = .systemGray3
        avatarView.setImageURL(nil)

        nameField.placeholder = "Enter role name"
        nameField.clearButtonMode = .whileEditing
        nameField.font = .systemFont(ofSize: 15)

        introduceView.font = .systemFont(ofSize: 15)
        introduceView.backgroundColor = .clear

        descView.font = .systemFont(ofSize: 15)
        descView.backgroundColor = .clear

        speedField.placeholder = "Optional, e.g. 1.0"
        speedField.keyboardType = .decimalPad
        speedField.font = .systemFont(ofSize: 15)
        speedField.textAlignment = .right
    }

    /// Edit mode: fetch role details to pre-fill the form
    private func loadDetail(roleId: String) {
        let req = ThingSmartAIAgentCustomRoleDetailReq(devId: devId, roleId: roleId)
        SVProgressHUD.show()
        agentRequest.queryCustomRoleDetail(req) { [weak self] detail in
            SVProgressHUD.dismiss()
            guard let self = self else { return }
            self.avatarURL = detail.roleImgUrl
            self.langCode = detail.useLangCode
            self.langName = detail.useLangName
            self.timbreId = detail.useTimbreId
            self.timbreName = detail.useTimbreName
            self.avatarView.setImageURL(detail.roleImgUrl)
            self.nameField.text = detail.roleName
            self.introduceView.text = detail.roleIntroduce
            self.descView.text = detail.roleDesc
            self.speedField.text = detail.speed.map { String($0) }
            self.tableView.reloadData()
        } failure: { [weak self] error in
            self?.showAIAgentError(error)
        }
    }

    // MARK: - Save

    @objc private func saveTapped() {
        view.endEditing(true)
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let introduce = (introduceView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let desc = (descView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let speed = (speedField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty else {
            SVProgressHUD.showError(withStatus: "Please enter a role name")
            return
        }
        guard !introduce.isEmpty else {
            SVProgressHUD.showError(withStatus: "Please enter a role introduction")
            return
        }
        // The API requires speed to be in numeric format
        guard speed.isEmpty || Double(speed) != nil else {
            SVProgressHUD.showError(withStatus: "Speech rate must be a number, e.g. 1.0")
            return
        }

        switch mode {
        case .create:
            // Build the create request after validating required fields (required fields are initializer parameters, visible at compile time)
            guard let roleImgUrl = avatarURL else {
                SVProgressHUD.showError(withStatus: "Please select a role avatar")
                return
            }
            guard let useLangCode = langCode else {
                SVProgressHUD.showError(withStatus: "Please select a language")
                return
            }
            var req = ThingSmartAIAgentCustomRoleAddReq(devId: devId,
                                                        roleName: name,
                                                        roleIntroduce: introduce,
                                                        roleImgUrl: roleImgUrl,
                                                        useLangCode: useLangCode)
            req.roleDesc = desc.isEmpty ? nil : desc
            req.useTimbreId = timbreId
            req.speed = speed.isEmpty ? nil : speed
            SVProgressHUD.show()
            agentRequest.addCustomRole(req) { [weak self] roleId in
                SVProgressHUD.showSuccess(withStatus: "Created\nroleId: \(roleId)")
                self?.onSaved?()
                self?.finishEditing()
            } failure: { [weak self] error in
                self?.showAIAgentError(error)
            }
        case .edit(let roleId):
            var req = ThingSmartAIAgentCustomRoleUpdateReq(devId: devId, roleId: roleId)
            req.roleName = name
            req.roleIntroduce = introduce
            req.roleDesc = desc.isEmpty ? nil : desc
            req.roleImgUrl = avatarURL
            req.useLangCode = langCode
            req.useTimbreId = timbreId
            req.speed = speed.isEmpty ? nil : speed
            req.needBind = needBindSwitch.isOn
            SVProgressHUD.show()
            agentRequest.updateCustomRole(req) { [weak self] result in
                if result {
                    SVProgressHUD.showSuccess(withStatus: "Updated")
                    self?.onSaved?()
                    self?.finishEditing()
                } else {
                    SVProgressHUD.showError(withStatus: "Failed to update")
                }
            } failure: { [weak self] error in
                self?.showAIAgentError(error)
            }
        }
    }

    /// Close after a successful save: dismiss when this is the navigation stack's root (presented in a sheet), otherwise pop
    private func finishEditing() {
        if navigationController?.viewControllers.first == self {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Table view

    private enum Section: Int, CaseIterable {
        case avatar
        case name
        case introduce
        case desc
        case voice
        case bind
    }

    private func sectionList() -> [Section] {
        var sections: [Section] = [.avatar, .name, .introduce, .desc, .voice]
        if isEditMode { sections.append(.bind) }
        return sections
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList().count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionList()[section] == .voice ? 3 : 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sectionList()[section] {
        case .avatar: return "Role Avatar (required)"
        case .name: return "Role Name (required)"
        case .introduce: return "Role Introduction (required)"
        case .desc: return "Role Description (optional)"
        case .voice: return "Voice Settings"
        case .bind: return "Bind"
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch sectionList()[section] {
        case .introduce:
            return "Example: You are an astronomer with a wealth of knowledge, skilled at sparking children's curiosity and interest in space."
        case .bind:
            return "When on, the role is bound to the device on save (needBind)"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sectionList()[indexPath.section] {
        case .avatar:
            return avatarCell
        case .name:
            return nameCell
        case .introduce:
            return introduceCell
        case .desc:
            return descCell
        case .voice:
            switch indexPath.row {
            case 0:
                langCell.detailTextLabel?.text = langName ?? langCode ?? "Select"
                return langCell
            case 1:
                timbreCell.detailTextLabel?.text = timbreName ?? timbreId ?? "Select"
                return timbreCell
            default:
                return speedCell
            }
        case .bind:
            return bindCell
        }
    }

    /// Single-line input cell
    private func fieldCell(_ field: UITextField) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(field)
        NSLayoutConstraint.activate([
            field.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            field.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            field.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            field.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            field.heightAnchor.constraint(equalToConstant: 44),
        ])
        return cell
    }

    /// Multi-line input cell
    private func textViewCell(_ textView: UITextView) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        textView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 12),
            textView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -12),
            textView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 4),
            textView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -4),
            textView.heightAnchor.constraint(equalToConstant: 100),
        ])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sectionList()[indexPath.section] {
        case .avatar:
            let picker = AIAgentAvatarPickerViewController(devId: devId) { [weak self] avatar in
                self?.avatarURL = avatar.url
                self?.avatarView.setImageURL(avatar.url)
            }
            navigationController?.pushViewController(picker, animated: true)
        case .voice where indexPath.row == 0:
            let picker = AIAgentLanguagePickerViewController(devId: devId, selectedLangCode: langCode) { [weak self] language in
                self?.langCode = language.langCode
                self?.langName = language.langName
                self?.tableView.reloadData()
            }
            navigationController?.pushViewController(picker, animated: true)
        case .voice where indexPath.row == 1:
            let picker = AIAgentTimbrePickerViewController(devId: devId, selectedVoiceId: timbreId) { [weak self] timbre in
                self?.timbreId = timbre.voiceId
                self?.timbreName = timbre.voiceName
                self?.tableView.reloadData()
            }
            navigationController?.pushViewController(picker, animated: true)
        default:
            break
        }
    }
}
