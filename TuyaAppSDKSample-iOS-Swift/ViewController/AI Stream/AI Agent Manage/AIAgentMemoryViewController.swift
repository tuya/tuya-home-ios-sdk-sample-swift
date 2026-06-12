//
//  AIAgentMemoryViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2026 Tuya Inc. (https://developer.tuya.com/)

import UIKit

/// Role memory page
///
/// Shows the memory switch (m.life.ai.agent.chat.memory.get-switch) and the memory list grouped by scope (m.life.ai.agent.chat.memory.list).
/// Supports clearing chat history (m.life.ai.agent.chat.history.delete), clearing the context (m.life.ai.agent.chat.context.clear),
/// deleting a single / all memories (m.life.ai.agent.chat.memory.delete), and an entry to the chat summary page.
class AIAgentMemoryViewController: UITableViewController {

    private let devId: String
    private let roleId: String
    private let bindRoleType: ThingSmartAIAgentBindRoleType
    private let agentRequest = ThingSmartAIAgentRequest()

    private var memorySwitch: ThingSmartAIAgentMemorySwitchResult?
    private var memoryGroups: [ThingSmartAIAgentMemoryGroupResult] = []

    private enum ActionRow: Int, CaseIterable {
        case clearHistory
        case clearContext
        case chatSummary
        case clearAllMemory

        var title: String {
            switch self {
            case .clearHistory: return "Clear Chat History"
            case .clearContext: return "Clear Context"
            case .chatSummary: return "Chat Summary"
            case .clearAllMemory: return "Clear All Long-Term Memory"
            }
        }
    }

    init(devId: String, roleId: String, bindRoleType: ThingSmartAIAgentBindRoleType) {
        self.devId = devId
        self.roleId = roleId
        self.bindRoleType = bindRoleType
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Role Memory"
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        SVProgressHUD.show()
        loadData()
    }

    // MARK: - Data loading

    @objc private func loadData() {
        agentRequest.getMemorySwitch(devId: devId) { [weak self] memorySwitch in
            self?.memorySwitch = memorySwitch
            self?.tableView.reloadData()
        } failure: { _ in
            // A failed switch query does not block the page; keep showing "-"
        }

        let listReq = ThingSmartAIAgentMemoryListReq(devId: devId, bindRoleType: bindRoleType, roleId: roleId)
        agentRequest.queryMemoryList(listReq) { [weak self] groups in
            SVProgressHUD.dismiss()
            guard let self = self else { return }
            self.refreshControl?.endRefreshing()
            self.memoryGroups = groups
            self.tableView.reloadData()
        } failure: { [weak self] error in
            self?.refreshControl?.endRefreshing()
            self?.showAIAgentError(error)
        }
    }

    // MARK: - Actions

    private func clearHistory() {
        confirmAIAgentAction(title: "Clear all chat history for this role?") { [weak self] in
            guard let self = self else { return }
            let req = ThingSmartAIAgentChatHistoryDeleteReq(devId: self.devId,
                                                            bindRoleType: self.bindRoleType,
                                                            roleId: self.roleId,
                                                            clearAllHistory: true)
            SVProgressHUD.show()
            self.agentRequest.deleteChatHistory(req) { result in
                result ? SVProgressHUD.showSuccess(withStatus: "Chat history cleared")
                       : SVProgressHUD.showError(withStatus: "Clear failed")
            } failure: { [weak self] error in
                self?.showAIAgentError(error)
            }
        }
    }

    private func clearContext() {
        confirmAIAgentAction(title: "Clear context?", message: "Short-term memory generated from recent conversations will be cleared") { [weak self] in
            guard let self = self else { return }
            let req = ThingSmartAIAgentChatContextClearReq(devId: self.devId,
                                                           bindRoleType: self.bindRoleType,
                                                           roleId: self.roleId)
            SVProgressHUD.show()
            self.agentRequest.clearChatContext(req) { result in
                result ? SVProgressHUD.showSuccess(withStatus: "Context cleared")
                       : SVProgressHUD.showError(withStatus: "Clear failed")
            } failure: { [weak self] error in
                self?.showAIAgentError(error)
            }
        }
    }

    private func clearAllMemory() {
        confirmAIAgentAction(title: "Clear all long-term memory?", message: "clearAllMemory = true") { [weak self] in
            guard let self = self else { return }
            let req = ThingSmartAIAgentMemoryDeleteReq(devId: self.devId,
                                                       bindRoleType: self.bindRoleType,
                                                       roleId: self.roleId,
                                                       clearAllMemory: true)
            SVProgressHUD.show()
            self.agentRequest.deleteMemory(req) { [weak self] result in
                if result {
                    SVProgressHUD.showSuccess(withStatus: "All memory cleared")
                    self?.loadData()
                } else {
                    SVProgressHUD.showError(withStatus: "Clear failed")
                }
            } failure: { [weak self] error in
                self?.showAIAgentError(error)
            }
        }
    }

    private func deleteMemory(groupIndex: Int, itemIndex: Int) {
        guard let memoryKey = memoryGroups[groupIndex].memoryList?[itemIndex].memoryKey else {
            SVProgressHUD.showError(withStatus: "This memory has no memoryKey and cannot be deleted")
            return
        }
        var req = ThingSmartAIAgentMemoryDeleteReq(devId: devId,
                                                   bindRoleType: bindRoleType,
                                                   roleId: roleId,
                                                   clearAllMemory: false)
        req.memoryKeys = memoryKey
        SVProgressHUD.show()
        agentRequest.deleteMemory(req) { [weak self] result in
            if result {
                SVProgressHUD.showSuccess(withStatus: "Deleted")
                self?.loadData()
            } else {
                SVProgressHUD.showError(withStatus: "Delete failed")
            }
        } failure: { [weak self] error in
            self?.showAIAgentError(error)
        }
    }

    // MARK: - Table view

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Switches + actions + memory groups
        return 2 + memoryGroups.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return ActionRow.allCases.count
        default: return memoryGroups[section - 2].memoryList?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Memory Switches"
        case 1: return "Actions"
        default:
            let group = memoryGroups[section - 2]
            return "Long-Term Memory - \(group.effectiveScopeName ?? "Scope \(group.effectiveScope ?? 0)")"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.selectionStyle = .none
            if indexPath.row == 0 {
                cell.textLabel?.text = "Memory Switch"
                cell.detailTextLabel?.text = memorySwitch.map { ($0.memoryOpen ?? false) ? "On" : "Off" } ?? "-"
            } else {
                cell.textLabel?.text = "Summary Switch"
                cell.detailTextLabel?.text = memorySwitch.map { ($0.summaryOpen ?? false) ? "On" : "Off" } ?? "-"
            }
            return cell
        case 1:
            let action = ActionRow(rawValue: indexPath.row)!
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = action.title
            switch action {
            case .chatSummary:
                cell.accessoryType = .disclosureIndicator
            case .clearHistory, .clearContext:
                cell.textLabel?.textColor = .systemBlue
            case .clearAllMemory:
                cell.textLabel?.textColor = .systemRed
            }
            return cell
        default:
            let memory = memoryGroups[indexPath.section - 2].memoryList?[indexPath.row]
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.selectionStyle = .none
            var title = memory?.memoryName ?? memory?.memoryKey ?? "-"
            if memory?.shareMemory == true {
                title += " (shared)"
            }
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = memory?.memoryValue
            cell.detailTextLabel?.textColor = .secondaryLabel
            cell.detailTextLabel?.numberOfLines = 0
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 1, let action = ActionRow(rawValue: indexPath.row) else { return }
        switch action {
        case .clearHistory:
            clearHistory()
        case .clearContext:
            clearContext()
        case .chatSummary:
            let vc = AIAgentChatSummaryViewController(devId: devId, roleId: roleId, bindRoleType: bindRoleType)
            navigationController?.pushViewController(vc, animated: true)
        case .clearAllMemory:
            clearAllMemory()
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section >= 2 else { return nil }
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else { return }
            self.confirmAIAgentAction(title: "Delete this memory?") {
                self.deleteMemory(groupIndex: indexPath.section - 2, itemIndex: indexPath.row)
            }
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
