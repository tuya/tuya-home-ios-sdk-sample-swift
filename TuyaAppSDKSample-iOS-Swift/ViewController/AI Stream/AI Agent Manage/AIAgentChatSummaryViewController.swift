//
//  AIAgentChatSummaryViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2026 Tuya Inc. (https://developer.tuya.com/)

import UIKit

/// Chat summary page
///
/// Queries (m.life.ai.agent.chat.chat-summary.get) and lists the items one by one.
/// Tap an item / the + button in the top-right corner to edit in an overlay, swipe left to delete; changes are kept locally only.
/// Tap "Save" to join all items with \n\n and submit as a full overwrite (m.life.ai.agent.chat.chat-summary.update), then re-query to confirm.
class AIAgentChatSummaryViewController: UITableViewController {

    private let devId: String
    private let roleId: String
    private let bindRoleType: ThingSmartAIAgentBindRoleType
    private let agentRequest = ThingSmartAIAgentRequest()

    private var items: [String] = []
    private let emptyLabel = UILabel()

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
        title = "Chat Summary"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped)),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped)),
        ]

        emptyLabel.text = "No chat summary yet. Tap + in the top-right corner to add one"
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .systemFont(ofSize: 14)
        emptyLabel.textAlignment = .center
        tableView.backgroundView = emptyLabel
        emptyLabel.isHidden = true

        loadSummary(showLoading: true)
    }

    private func loadSummary(showLoading: Bool) {
        if showLoading { SVProgressHUD.show() }
        let req = ThingSmartAIAgentChatSummaryGetReq(devId: devId, bindRoleType: bindRoleType, roleId: roleId)
        agentRequest.getChatSummary(req) { [weak self] items in
            SVProgressHUD.dismiss()
            guard let self = self else { return }
            self.items = items
            self.refreshList()
        } failure: { [weak self] error in
            self?.showAIAgentError(error)
        }
    }

    private func refreshList() {
        emptyLabel.isHidden = !items.isEmpty
        tableView.reloadData()
    }

    // MARK: - Actions

    /// Submit all items as a full overwrite; re-query after success to confirm the server-side content
    @objc private func saveTapped() {
        let req = ThingSmartAIAgentChatSummaryUpdateReq(devId: devId,
                                                        bindRoleType: bindRoleType,
                                                        roleId: roleId,
                                                        summaryItems: items.joined(separator: "\n\n"))
        SVProgressHUD.show()
        agentRequest.updateChatSummary(req) { [weak self] result in
            if result {
                SVProgressHUD.showSuccess(withStatus: "Saved")
                self?.loadSummary(showLoading: false)
            } else {
                SVProgressHUD.showError(withStatus: "Save failed")
            }
        } failure: { [weak self] error in
            self?.showAIAgentError(error)
        }
    }

    @objc private func addTapped() {
        presentEditOverlay(overlayTitle: "Add Summary Item", text: "") { [weak self] text in
            guard let self = self else { return }
            self.items.append(text)
            self.refreshList()
        }
    }

    /// Present the edit overlay on the current page (attached to the navigation controller's view so it does not scroll with the list)
    private func presentEditOverlay(overlayTitle: String, text: String, onConfirm: @escaping (String) -> Void) {
        let host: UIView = navigationController?.view ?? view
        AIAgentSummaryEditOverlay.show(in: host, title: overlayTitle, text: text, onConfirm: onConfirm)
    }

    // MARK: - Table view

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard !items.isEmpty else { return nil }
        return "Tap an item to edit, swipe left to delete. After editing, tap \"Save\" in the top-right corner to submit a full overwrite (summaryItems)"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 15)
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        presentEditOverlay(overlayTitle: "Edit Summary Item", text: items[row]) { [weak self] text in
            guard let self = self, row < self.items.count else { return }
            self.items[row] = text
            self.refreshList()
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self, indexPath.row < self.items.count else {
                completion(false)
                return
            }
            self.items.remove(at: indexPath.row)
            self.refreshList()
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

// MARK: - Edit overlay

/// Single-summary edit overlay: semi-transparent mask + card (title + UITextView + Cancel/OK)
///
/// The card is pinned to the upper half of the screen to avoid being covered by the keyboard;
/// tapping the mask or "Cancel" dismisses it, and "OK" validates non-empty text before calling back.
private final class AIAgentSummaryEditOverlay: UIView {

    private let onConfirm: (String) -> Void
    private let textView = UITextView()

    static func show(in container: UIView, title: String, text: String, onConfirm: @escaping (String) -> Void) {
        let overlay = AIAgentSummaryEditOverlay(title: title, text: text, onConfirm: onConfirm)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: container.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        overlay.alpha = 0
        UIView.animate(withDuration: 0.2) {
            overlay.alpha = 1
        } completion: { _ in
            overlay.textView.becomeFirstResponder()
        }
    }

    private init(title: String, text: String, onConfirm: @escaping (String) -> Void) {
        self.onConfirm = onConfirm
        super.init(frame: .zero)

        // Semi-transparent mask; tapping the blank area cancels
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
        let tap = UITapGestureRecognizer(target: self, action: #selector(cancelTapped))
        tap.delegate = self
        addGestureRecognizer(tap)

        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = .center

        textView.text = text
        textView.font = .systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.separator.cgColor
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.heightAnchor.constraint(equalToConstant: 160).isActive = true

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("OK", for: .normal)
        confirmButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        let buttonsRow = UIStackView(arrangedSubviews: [cancelButton, confirmButton])
        buttonsRow.axis = .horizontal
        buttonsRow.distribution = .fillEqually
        buttonsRow.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let stack = UIStackView(arrangedSubviews: [titleLabel, textView, buttonsRow])
        stack.axis = .vertical
        stack.spacing = 12
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(card)
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            // Pin the card to the upper half of the screen to leave room for the keyboard
            card.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 60),
            card.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func cancelTapped() {
        dismissOverlay()
    }

    @objc private func confirmTapped() {
        let text = (textView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            SVProgressHUD.showError(withStatus: "Content cannot be empty")
            return
        }
        onConfirm(text)
        dismissOverlay()
    }

    private func dismissOverlay() {
        endEditing(true)
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate (only respond to taps on the blank mask area)

extension AIAgentSummaryEditOverlay: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Taps inside the card do not trigger cancel
        return touch.view === self
    }
}
