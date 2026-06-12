//
//  AIAgentRoleListViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2026 Tuya Inc. (https://developer.tuya.com/)

import UIKit

/// Role switching page
///
/// Recommended: role template list (m.life.ai.agent.role.role-template.list), tap to view template details;
/// Created by me: paged custom role list (m.life.ai.agent.role.custom-role.page), tap to edit, swipe left to delete;
/// Both lists can bind a role via the "Apply" button (m.life.ai.agent.role.bind-with-role).
class AIAgentRoleListViewController: UIViewController {

    private let devId: String
    private var currentRoleId: String?
    private let agentRequest = ThingSmartAIAgentRequest()

    private var templates: [ThingSmartAIAgentRoleTemplateResult] = []
    private var customRoles: [ThingSmartAIAgentCustomRoleResult] = []
    private var customPageNo = 0
    private var customHasMore = true
    private var customLoading = false
    private let pageSize = 20

    private let segmentedControl = UISegmentedControl(items: ["Recommended", "Created by Me"])
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let createButton = UIButton(type: .system)
    private let emptyLabel = UILabel()

    private var isCustomTab: Bool { segmentedControl.selectedSegmentIndex == 1 }

    init(devId: String, currentRoleId: String?) {
        self.devId = devId
        self.currentRoleId = currentRoleId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        loadTemplates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh the custom role list after returning from create / edit role
        if isCustomTab {
            reloadCustomRoles()
        }
    }

    private func setupViews() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        navigationItem.titleView = segmentedControl

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 84
        tableView.register(AIAgentRoleCell.self, forCellReuseIdentifier: AIAgentRoleCell.reuseId)

        emptyLabel.text = "No roles yet"
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .systemFont(ofSize: 14)
        emptyLabel.textAlignment = .center
        tableView.backgroundView = emptyLabel
        emptyLabel.isHidden = true

        createButton.setTitle("Create New Role", for: .normal)
        createButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        createButton.setTitleColor(.white, for: .normal)
        createButton.backgroundColor = .systemBlue
        createButton.layer.cornerRadius = 22
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)

        view.addSubview(tableView)
        view.addSubview(createButton)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -8),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            createButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    // MARK: - Data loading

    @objc private func segmentChanged() {
        if isCustomTab {
            reloadCustomRoles()
        } else {
            if templates.isEmpty { loadTemplates() }
        }
        updateEmptyState()
        tableView.reloadData()
    }

    private func loadTemplates() {
        let req = ThingSmartAIAgentRoleTemplateListReq(devId: devId)
        SVProgressHUD.show()
        agentRequest.queryRoleTemplateList(req) { [weak self] templates in
            SVProgressHUD.dismiss()
            guard let self = self else { return }
            self.templates = templates
            if !self.isCustomTab {
                self.updateEmptyState()
                self.tableView.reloadData()
            }
        } failure: { [weak self] error in
            self?.showAIAgentError(error)
        }
    }

    /// Reload custom roles from the first page
    private func reloadCustomRoles() {
        customPageNo = 0
        customHasMore = true
        customRoles = []
        loadMoreCustomRoles()
    }

    private func loadMoreCustomRoles() {
        guard customHasMore, !customLoading else { return }
        customLoading = true
        let req = ThingSmartAIAgentCustomRolePageReq(devId: devId, pageNo: customPageNo + 1, pageSize: pageSize)
        if customRoles.isEmpty { SVProgressHUD.show() }
        agentRequest.queryCustomRolePage(req) { [weak self] pageResult in
            SVProgressHUD.dismiss()
            guard let self = self else { return }
            self.customLoading = false
            self.customPageNo += 1
            let pageList = pageResult.list ?? []
            self.customRoles.append(contentsOf: pageList)
            // Use this page's returned count to decide whether there is a next page; don't rely on the possibly missing totalPage
            self.customHasMore = pageList.count >= self.pageSize
            if self.isCustomTab {
                self.updateEmptyState()
                self.tableView.reloadData()
            }
        } failure: { [weak self] error in
            self?.customLoading = false
            self?.showAIAgentError(error)
        }
    }

    private func updateEmptyState() {
        emptyLabel.isHidden = !(isCustomTab ? customRoles.isEmpty : templates.isEmpty)
    }

    // MARK: - Actions

    @objc private func createTapped() {
        let vc = AIAgentRoleEditViewController(devId: devId, mode: .create)
        vc.onSaved = { [weak self] in
            // After a successful creation, switch to the "Created by Me" tab; viewWillAppear refreshes the list when returning to this page
            self?.segmentedControl.selectedSegmentIndex = 1
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func bindRole(roleId: String, type: ThingSmartAIAgentBindRoleType) {
        let req = ThingSmartAIAgentRoleBindReq(devId: devId, bindRoleType: type, roleId: roleId)
        SVProgressHUD.show()
        agentRequest.bindWithRole(req) { [weak self] result in
            guard let self = self else { SVProgressHUD.dismiss(); return }
            if result {
                SVProgressHUD.showSuccess(withStatus: "Applied")
                self.currentRoleId = roleId
                // Return to the chat page automatically after applying (dismiss the whole sheet when presented modally, pop when pushed)
                if self.navigationController?.viewControllers.first == self, self.presentingViewController != nil {
                    self.dismiss(animated: true)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                SVProgressHUD.showError(withStatus: "Failed to apply")
            }
        } failure: { [weak self] error in
            self?.showAIAgentError(error)
        }
    }

    /// View role template details (m.life.ai.agent.role.role-template.detail)
    private func showTemplateDetail(roleId: String) {
        let req = ThingSmartAIAgentRoleTemplateDetailReq(devId: devId, roleId: roleId)
        SVProgressHUD.show()
        agentRequest.queryRoleTemplateDetail(req) { [weak self] detail in
            SVProgressHUD.dismiss()
            self?.showAIAgentInfo(title: "Role Template Details", message: detail.aiAgentDetailText)
        } failure: { [weak self] error in
            self?.showAIAgentError(error)
        }
    }

    /// Delete by roleId (the list may change while the confirmation alert is shown, so don't rely on indexPath)
    private func deleteCustomRole(roleId: String) {
        let req = ThingSmartAIAgentCustomRoleDeleteReq(devId: devId, roleId: roleId)
        SVProgressHUD.show()
        agentRequest.deleteCustomRole(req) { [weak self] result in
            guard let self = self else { SVProgressHUD.dismiss(); return }
            if result {
                SVProgressHUD.showSuccess(withStatus: "Deleted")
                self.customRoles.removeAll { $0.roleId == roleId }
                self.updateEmptyState()
                self.tableView.reloadData()
            } else {
                SVProgressHUD.showError(withStatus: "Failed to delete")
            }
        } failure: { [weak self] error in
            self?.showAIAgentError(error)
        }
    }
}

// MARK: - UITableViewDataSource / UITableViewDelegate

extension AIAgentRoleListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isCustomTab ? customRoles.count : templates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AIAgentRoleCell.reuseId, for: indexPath) as! AIAgentRoleCell
        if isCustomTab {
            let role = customRoles[indexPath.row]
            cell.configure(imgUrl: role.roleImgUrl,
                           name: role.roleName,
                           introduce: role.roleIntroduce,
                           meta: [role.useLangName ?? role.useLangCode, role.useTimbreName].compactMap { $0 }.joined(separator: " | "),
                           isCurrent: role.roleId != nil && role.roleId == currentRoleId)
            cell.applyHandler = { [weak self] in
                guard let roleId = role.roleId else { return }
                self?.bindRole(roleId: roleId, type: .customRole)
            }
        } else {
            let template = templates[indexPath.row]
            cell.configure(imgUrl: template.roleImgUrl,
                           name: template.roleName,
                           introduce: template.roleIntroduce ?? template.roleDesc,
                           meta: [template.useLangName ?? template.useLangCode, template.useTimbreName].compactMap { $0 }.joined(separator: " | "),
                           isCurrent: template.roleId != nil && template.roleId == currentRoleId)
            cell.applyHandler = { [weak self] in
                guard let roleId = template.roleId else { return }
                self?.bindRole(roleId: roleId, type: .roleTemplate)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isCustomTab {
            guard let roleId = customRoles[indexPath.row].roleId else { return }
            let vc = AIAgentRoleEditViewController(devId: devId, mode: .edit(roleId: roleId))
            navigationController?.pushViewController(vc, animated: true)
        } else {
            guard let roleId = templates[indexPath.row].roleId else { return }
            showTemplateDetail(roleId: roleId)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Load the next page of custom roles
        if isCustomTab, indexPath.row == customRoles.count - 1 {
            loadMoreCustomRoles()
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard isCustomTab, let roleId = customRoles[indexPath.row].roleId else { return nil }
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else { return }
            self.confirmAIAgentAction(title: "Delete this custom role?") {
                self.deleteCustomRole(roleId: roleId)
            }
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

// MARK: - Role Cell

/// Role list cell: avatar + name + introduction + language/voice, with an "Apply" button or "Current" badge on the right
final class AIAgentRoleCell: UITableViewCell {

    static let reuseId = "AIAgentRoleCell"

    var applyHandler: (() -> Void)?

    private let avatarView = AIAgentRemoteImageView()
    private let nameLabel = UILabel()
    private let introduceLabel = UILabel()
    private let metaLabel = UILabel()
    private let applyButton = UIButton(type: .system)
    private let currentLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        accessoryType = .disclosureIndicator

        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 8
        avatarView.tintColor = .systemGray3

        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        introduceLabel.font = .systemFont(ofSize: 13)
        introduceLabel.textColor = .secondaryLabel
        introduceLabel.numberOfLines = 2
        metaLabel.font = .systemFont(ofSize: 12)
        metaLabel.textColor = .tertiaryLabel

        applyButton.setTitle("Apply", for: .normal)
        applyButton.titleLabel?.font = .systemFont(ofSize: 13)
        applyButton.layer.cornerRadius = 12
        applyButton.layer.borderWidth = 1
        applyButton.layer.borderColor = UIColor.systemBlue.cgColor
        applyButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        applyButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)

        currentLabel.text = "Current"
        currentLabel.font = .systemFont(ofSize: 13)
        currentLabel.textColor = .secondaryLabel
        currentLabel.translatesAutoresizingMaskIntoConstraints = false
        currentLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, introduceLabel, metaLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(avatarView)
        contentView.addSubview(textStack)
        contentView.addSubview(applyButton)
        contentView.addSubview(currentLabel)
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 48),
            avatarView.heightAnchor.constraint(equalToConstant: 48),

            textStack.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            applyButton.leadingAnchor.constraint(greaterThanOrEqualTo: textStack.trailingAnchor, constant: 8),
            applyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            applyButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            currentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            currentLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            currentLabel.leadingAnchor.constraint(greaterThanOrEqualTo: textStack.trailingAnchor, constant: 8),
        ])
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 68).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(imgUrl: String?, name: String?, introduce: String?, meta: String, isCurrent: Bool) {
        avatarView.setImageURL(imgUrl)
        nameLabel.text = name ?? "-"
        introduceLabel.text = introduce
        introduceLabel.isHidden = (introduce?.isEmpty ?? true)
        metaLabel.text = meta
        metaLabel.isHidden = meta.isEmpty
        applyButton.isHidden = isCurrent
        currentLabel.isHidden = !isCurrent
    }

    @objc private func applyTapped() {
        applyHandler?()
    }
}
