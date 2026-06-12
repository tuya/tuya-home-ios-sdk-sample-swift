//
//  AIAgentChatHistoryViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2026 Tuya Inc. (https://developer.tuya.com/)

import UIKit

/// Role chat history page
///
/// Cursor-based pagination of historical conversations (m.life.ai.agent.chat.history.fetch).
/// Swipe left to delete a single record by requestId, or tap the top-right button to clear all (m.life.ai.agent.chat.history.delete).
class AIAgentChatHistoryViewController: UITableViewController {

    private let devId: String
    private let roleId: String
    private let bindRoleType: ThingSmartAIAgentBindRoleType
    private let agentRequest = ThingSmartAIAgentRequest()

    private var records: [ThingSmartAIAgentChatRecordResult] = []
    /// Cursor: end timestamp for the next page query (gmtCreate of the current oldest record - 1)
    private var nextGmtEnd = Int64(Date().timeIntervalSince1970 * 1000)
    private var hasMore = true
    private var loading = false
    private let fetchSize = 20

    private let emptyLabel = UILabel()

    init(devId: String, roleId: String, bindRoleType: ThingSmartAIAgentBindRoleType) {
        self.devId = devId
        self.roleId = roleId
        self.bindRoleType = bindRoleType
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Role Chat History"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAllTapped))
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.register(AIAgentChatRecordCell.self, forCellReuseIdentifier: AIAgentChatRecordCell.reuseId)

        emptyLabel.text = "No chat history"
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .systemFont(ofSize: 14)
        emptyLabel.textAlignment = .center
        tableView.backgroundView = emptyLabel
        emptyLabel.isHidden = true

        loadMore()
    }

    // MARK: - Data loading

    private func loadMore() {
        guard hasMore, !loading else { return }
        loading = true
        var req = ThingSmartAIAgentChatHistoryFetchReq(devId: devId, bindRoleType: bindRoleType, roleId: roleId, fetchSize: fetchSize)
        req.gmtEnd = nextGmtEnd
        // Explicitly request descending order so the cursor advances in the right direction
        req.timeAsc = false
        if records.isEmpty { SVProgressHUD.show() }
        agentRequest.fetchChatHistory(req) { [weak self] records in
            SVProgressHUD.dismiss()
            guard let self = self else { return }
            self.loading = false
            self.records.append(contentsOf: records)
            // Records are returned in descending time order by default; the last one is the current oldest record, used as the next-page cursor
            if records.count < self.fetchSize {
                self.hasMore = false
            } else if let oldest = records.compactMap({ $0.gmtCreate }).min() {
                self.nextGmtEnd = oldest - 1
            } else {
                self.hasMore = false
            }
            self.emptyLabel.isHidden = !self.records.isEmpty
            self.tableView.reloadData()
        } failure: { [weak self] error in
            self?.loading = false
            self?.showAIAgentError(error)
        }
    }

    // MARK: - Deletion

    @objc private func clearAllTapped() {
        confirmAIAgentAction(title: "Clear all chat history?", message: "clearAllHistory = true") { [weak self] in
            guard let self = self else { return }
            let req = ThingSmartAIAgentChatHistoryDeleteReq(devId: self.devId,
                                                            bindRoleType: self.bindRoleType,
                                                            roleId: self.roleId,
                                                            clearAllHistory: true)
            SVProgressHUD.show()
            self.agentRequest.deleteChatHistory(req) { [weak self] result in
                guard let self = self else { SVProgressHUD.dismiss(); return }
                if result {
                    SVProgressHUD.showSuccess(withStatus: "Cleared")
                    self.records = []
                    self.hasMore = false
                    self.emptyLabel.isHidden = false
                    self.tableView.reloadData()
                } else {
                    SVProgressHUD.showError(withStatus: "Clear failed")
                }
            } failure: { [weak self] error in
                self?.showAIAgentError(error)
            }
        }
    }

    /// Delete a single record by requestId (the list may change while the confirmation alert is shown, so indexPath cannot be relied on)
    private func deleteRecord(requestId: String) {
        var req = ThingSmartAIAgentChatHistoryDeleteReq(devId: devId,
                                                        bindRoleType: bindRoleType,
                                                        roleId: roleId,
                                                        clearAllHistory: false)
        req.requestIds = requestId
        SVProgressHUD.show()
        agentRequest.deleteChatHistory(req) { [weak self] result in
            guard let self = self else { SVProgressHUD.dismiss(); return }
            if result {
                SVProgressHUD.showSuccess(withStatus: "Deleted")
                self.records.removeAll { $0.requestId == requestId }
                self.emptyLabel.isHidden = !self.records.isEmpty
                self.tableView.reloadData()
            } else {
                SVProgressHUD.showError(withStatus: "Delete failed")
            }
        } failure: { [weak self] error in
            self?.showAIAgentError(error)
        }
    }

    // MARK: - Table view

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AIAgentChatRecordCell.reuseId, for: indexPath) as! AIAgentChatRecordCell
        cell.configure(record: records[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == records.count - 1 {
            loadMore()
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let requestId = records[indexPath.row].requestId else { return nil }
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else { return }
            self.confirmAIAgentAction(title: "Delete this chat record?") {
                self.deleteRecord(requestId: requestId)
            }
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

// MARK: - Chat record cell

/// Chat record cell: time + question + answer
final class AIAgentChatRecordCell: UITableViewCell {

    static let reuseId = "AIAgentChatRecordCell"

    private let timeLabel = UILabel()
    private let questionLabel = UILabel()
    private let answerLabel = UILabel()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.textColor = .tertiaryLabel
        questionLabel.font = .systemFont(ofSize: 14, weight: .medium)
        questionLabel.numberOfLines = 0
        answerLabel.font = .systemFont(ofSize: 14)
        answerLabel.textColor = .secondaryLabel
        answerLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [timeLabel, questionLabel, answerLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(record: ThingSmartAIAgentChatRecordResult) {
        if let createTime = record.createTime, !createTime.isEmpty {
            timeLabel.text = createTime
        } else if let gmtCreate = record.gmtCreate {
            timeLabel.text = Self.timeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(gmtCreate) / 1000))
        } else {
            timeLabel.text = "-"
        }
        let question = record.question?.compactMap { $0.context }.joined(separator: " ") ?? ""
        let answer = record.answer?.compactMap { $0.context }.joined(separator: " ") ?? ""
        questionLabel.text = "Q: " + (question.isEmpty ? "-" : question)
        answerLabel.text = "A: " + (answer.isEmpty ? "-" : answer)
    }
}
