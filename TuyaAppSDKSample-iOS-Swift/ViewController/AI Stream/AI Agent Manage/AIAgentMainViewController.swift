//
//  AIAgentMainViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2026 Tuya Inc. (https://developer.tuya.com/)

import UIKit

/// AI agent management home page
///
/// Shows the currently bound role (m.life.ai.agent.role.get-bind-role) and chat emotion (m.life.ai.agent.chat.chat-emotion.current),
/// with entries for switching roles / role chat / role memory; automatically initializes the binding when no role is bound (m.life.ai.agent.role.initialize-agent-role-binding).
class AIAgentMainViewController: UITableViewController {

    private let devId: String
    private let agentRequest = ThingSmartAIAgentRequest()

    private var boundRole: ThingSmartAIAgentRoleDetailResult?
    private var emotion: ThingSmartAIAgentChatEmotionResult?
    private var hasAppeared = false

    private let avatarView = AIAgentRemoteImageView()
    private let nameLabel = UILabel()
    private let emotionLabel = UILabel()

    init(devId: String) {
        self.devId = devId
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Agent Management"
        setupHeader()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        loadBoundRole(showLoading: true)
        loadEmotion()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Refresh the bound role and emotion after returning from sub-pages such as role switching
        if hasAppeared {
            loadBoundRole(showLoading: false)
            loadEmotion()
        }
        hasAppeared = true
    }

    // MARK: - Header (current role + emotion)

    private func setupHeader() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 190))

        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 40
        avatarView.tintColor = .systemGray3
        avatarView.setImageURL(nil)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.textAlignment = .center
        nameLabel.text = "Loading..."

        emotionLabel.translatesAutoresizingMaskIntoConstraints = false
        emotionLabel.font = .systemFont(ofSize: 13)
        emotionLabel.textColor = .secondaryLabel
        emotionLabel.textAlignment = .center
        emotionLabel.numberOfLines = 0

        header.addSubview(avatarView)
        header.addSubview(nameLabel)
        header.addSubview(emotionLabel)
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: header.topAnchor, constant: 24),
            avatarView.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 80),
            avatarView.heightAnchor.constraint(equalToConstant: 80),
            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -20),
            emotionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emotionLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            emotionLabel.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -20),
        ])
        tableView.tableHeaderView = header
    }

    // MARK: - Data loading

    @objc private func refreshTriggered() {
        loadBoundRole(showLoading: false)
        loadEmotion()
    }

    /// Query the bound role; try to initialize the binding when no role is bound (roleId is nil) or the query fails
    private func loadBoundRole(showLoading: Bool) {
        if showLoading { SVProgressHUD.show() }
        agentRequest.getBindRole(devId: devId) { [weak self] detail in
            guard let self = self else { SVProgressHUD.dismiss(); return }
            self.refreshControl?.endRefreshing()
            if detail.roleId == nil {
                self.initializeBinding()
            } else {
                SVProgressHUD.dismiss()
                self.boundRole = detail
                self.applyBoundRole()
            }
        } failure: { [weak self] _ in
            self?.refreshControl?.endRefreshing()
            self?.initializeBinding()
        }
    }

    private func initializeBinding(manual: Bool = false) {
        if manual { SVProgressHUD.show() }
        agentRequest.initializeAgentRoleBinding(devId: devId) { [weak self] detail in
            guard let self = self else { SVProgressHUD.dismiss(); return }
            if manual {
                SVProgressHUD.showSuccess(withStatus: "Binding initialized")
            } else {
                SVProgressHUD.dismiss()
            }
            self.boundRole = detail
            self.applyBoundRole()
        } failure: { [weak self] error in
            self?.nameLabel.text = "No role bound"
            self?.showAIAgentError(error)
        }
    }

    private func applyBoundRole() {
        avatarView.setImageURL(boundRole?.roleImgUrl)
        nameLabel.text = boundRole?.roleName ?? "No role bound"
        tableView.reloadData()
    }

    private func loadEmotion() {
        agentRequest.getCurrentChatEmotion(devId: devId) { [weak self] emotion in
            guard let self = self else { return }
            self.emotion = emotion
            let text = emotion.text ?? emotion.emotion
            self.emotionLabel.text = (text?.isEmpty == false) ? text : "No recent mood yet. Come chat with me!"
            self.tableView.reloadData()
        } failure: { [weak self] _ in
            self?.emotionLabel.text = "No recent mood yet. Come chat with me!"
        }
    }

    // MARK: - Table view

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 3
        default: return 1
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Role"
        case 1: return "Chat"
        default: return "Binding"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.accessoryType = .disclosureIndicator
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.textLabel?.text = "Switch Role"
            cell.detailTextLabel?.text = boundRole?.roleName
        case (0, 1):
            cell.textLabel?.text = "Bound Role Details"
        case (1, 0):
            cell.textLabel?.text = "Role Chat History"
        case (1, 1):
            cell.textLabel?.text = "Role Memory"
        case (1, 2):
            cell.textLabel?.text = "Current Mood"
            let text = emotion?.text ?? emotion?.emotion
            cell.detailTextLabel?.text = (text?.isEmpty == false) ? text : "-"
            cell.accessoryType = .none
        default:
            cell.textLabel?.text = "Reinitialize Role Binding"
            cell.textLabel?.textColor = .systemBlue
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let vc = AIAgentRoleListViewController(devId: devId, currentRoleId: boundRole?.roleId)
            navigationController?.pushViewController(vc, animated: true)
        case (0, 1):
            showBoundRoleDetail()
        case (1, 0):
            guard let role = boundRoleInfo() else { return }
            let vc = AIAgentChatHistoryViewController(devId: devId, roleId: role.roleId, bindRoleType: role.type)
            navigationController?.pushViewController(vc, animated: true)
        case (1, 1):
            guard let role = boundRoleInfo() else { return }
            let vc = AIAgentMemoryViewController(devId: devId, roleId: role.roleId, bindRoleType: role.type)
            navigationController?.pushViewController(vc, animated: true)
        case (1, 2):
            loadEmotion()
        default:
            initializeBinding(manual: true)
        }
    }

    /// Chat-related pages require the bound role's roleId and bindRoleType
    private func boundRoleInfo() -> (roleId: String, type: ThingSmartAIAgentBindRoleType)? {
        guard let roleId = boundRole?.roleId else {
            SVProgressHUD.showError(withStatus: "Please bind a role first")
            return nil
        }
        // Fall back to role template when bindRoleType is missing or invalid
        let type: ThingSmartAIAgentBindRoleType
        if let rawType = boundRole?.bindRoleType, let parsed = ThingSmartAIAgentBindRoleType(rawValue: rawType) {
            type = parsed
        } else {
            type = .roleTemplate
        }
        return (roleId, type)
    }

    /// Call the corresponding detail API by binding type (custom-role.detail / role-template.detail)
    private func showBoundRoleDetail() {
        guard let role = boundRoleInfo() else { return }

        let success: (ThingSmartAIAgentRoleDetailResult) -> Void = { [weak self] detail in
            SVProgressHUD.dismiss()
            self?.showAIAgentInfo(title: "Bound Role Details", message: detail.aiAgentDetailText)
        }
        let failure: (Error) -> Void = { [weak self] error in
            self?.showAIAgentError(error)
        }

        SVProgressHUD.show()
        if role.type == .customRole {
            let req = ThingSmartAIAgentCustomRoleDetailReq(devId: devId, roleId: role.roleId)
            agentRequest.queryCustomRoleDetail(req, success: success, failure: failure)
        } else {
            let req = ThingSmartAIAgentRoleTemplateDetailReq(devId: devId, roleId: role.roleId)
            agentRequest.queryRoleTemplateDetail(req, success: success, failure: failure)
        }
    }
}
