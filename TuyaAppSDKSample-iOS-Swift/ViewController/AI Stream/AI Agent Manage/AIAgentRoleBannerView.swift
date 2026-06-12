//
//  AIAgentRoleBannerView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2026 Tuya Inc. (https://developer.tuya.com/)

import UIKit

/// Current role card at the top of the chat page
///
/// Collapsed: avatar + role name + role type/language/voice tags + expand button;
/// Expanded: adds two action buttons, "Edit Role (Role Details for template roles) / Switch Role".
final class AIAgentRoleBannerView: UIView {

    /// Edit role / role details
    var onEditTapped: (() -> Void)?
    /// Switch role
    var onSwitchTapped: (() -> Void)?

    private let avatarView = AIAgentRemoteImageView()
    private let nameLabel = UILabel()
    private let typeTagLabel = AIAgentPaddedLabel()
    private let metaLabel = UILabel()
    private let chevronButton = UIButton(type: .system)
    private let editButton = UIButton(type: .system)
    private let switchButton = UIButton(type: .system)
    private let buttonsRow = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Same color as insetGrouped cells, giving a card look on gray-background pages
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 12

        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 28
        avatarView.tintColor = .systemGray3
        avatarView.setImageURL(nil)

        nameLabel.font = .boldSystemFont(ofSize: 17)
        nameLabel.text = "Loading role..."

        typeTagLabel.font = .systemFont(ofSize: 11)
        typeTagLabel.textColor = .systemOrange
        typeTagLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.12)
        typeTagLabel.layer.cornerRadius = 4
        typeTagLabel.layer.masksToBounds = true
        typeTagLabel.isHidden = true

        metaLabel.font = .systemFont(ofSize: 12)
        metaLabel.textColor = .secondaryLabel
        metaLabel.numberOfLines = 1

        chevronButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        chevronButton.tintColor = .secondaryLabel
        chevronButton.translatesAutoresizingMaskIntoConstraints = false
        chevronButton.addTarget(self, action: #selector(toggleExpand), for: .touchUpInside)

        styleActionButton(editButton, title: "Edit Role", systemImage: "pencil")
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        styleActionButton(switchButton, title: "Switch Role", systemImage: "arrow.left.arrow.right")
        switchButton.addTarget(self, action: #selector(switchTapped), for: .touchUpInside)

        let tagRow = UIStackView(arrangedSubviews: [typeTagLabel, UIView()])
        tagRow.axis = .horizontal

        let infoStack = UIStackView(arrangedSubviews: [nameLabel, tagRow, metaLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 4

        let topRow = UIStackView(arrangedSubviews: [avatarView, infoStack, chevronButton])
        topRow.axis = .horizontal
        topRow.spacing = 12
        topRow.alignment = .center

        buttonsRow.axis = .horizontal
        buttonsRow.spacing = 12
        buttonsRow.distribution = .fillEqually
        buttonsRow.addArrangedSubview(editButton)
        buttonsRow.addArrangedSubview(switchButton)
        buttonsRow.isHidden = true

        // When the button row is hidden, rootStack automatically collapses the corresponding spacing
        let rootStack = UIStackView(arrangedSubviews: [topRow, buttonsRow])
        rootStack.axis = .vertical
        rootStack.spacing = 12
        rootStack.isLayoutMarginsRelativeArrangement = true
        rootStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: topAnchor),
            rootStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            rootStack.bottomAnchor.constraint(equalTo: bottomAnchor),

            avatarView.widthAnchor.constraint(equalToConstant: 56),
            avatarView.heightAnchor.constraint(equalToConstant: 56),
            chevronButton.widthAnchor.constraint(equalToConstant: 28),
            chevronButton.heightAnchor.constraint(equalToConstant: 28),
            editButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func styleActionButton(_ button: UIButton, title: String, systemImage: String) {
        button.setTitle(" " + title, for: .normal)
        button.setImage(UIImage(systemName: systemImage), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        // The card has a white background; buttons use a fill color to distinguish hierarchy (also works in dark mode)
        button.backgroundColor = .tertiarySystemFill
        button.layer.cornerRadius = 20
    }

    /// Refresh role info; a nil role means loading
    func update(role: ThingSmartAIAgentRoleDetailResult?) {
        guard let role = role else {
            nameLabel.text = "Loading role..."
            typeTagLabel.isHidden = true
            metaLabel.text = nil
            return
        }
        avatarView.setImageURL(role.roleImgUrl)
        nameLabel.text = role.roleName ?? "No role bound"

        // When bindRoleType is missing, display as a recommended role (template), consistent with the detail API's fallback
        switch role.bindRoleType ?? 1 {
        case 0:
            typeTagLabel.text = "Custom Role"
        case 2:
            typeTagLabel.text = "Default Role"
        default:
            typeTagLabel.text = "Recommended Role"
        }
        typeTagLabel.isHidden = false

        var metas: [String] = []
        if let lang = role.useLangName ?? role.useLangCode { metas.append(lang) }
        if let timbre = role.useTimbreName { metas.append(timbre) }
        metaLabel.text = metas.joined(separator: " | ")

        // Template/default roles are not editable; show details instead
        let editable = role.bindRoleType == 0
        editButton.setTitle(editable ? " Edit Role" : " Role Details", for: .normal)
        editButton.setImage(UIImage(systemName: editable ? "pencil" : "doc.text.magnifyingglass"), for: .normal)
    }

    /// Role load failure state (can still retry by switching roles)
    func showLoadFailed() {
        nameLabel.text = "Failed to load role"
        typeTagLabel.isHidden = true
        metaLabel.text = "The device may not support agents; expand and switch roles to retry"
    }

    @objc private func toggleExpand() {
        let expand = buttonsRow.isHidden
        chevronButton.setImage(UIImage(systemName: expand ? "chevron.up" : "chevron.down"), for: .normal)
        UIView.animate(withDuration: 0.25) {
            self.buttonsRow.isHidden = !expand
            self.buttonsRow.alpha = expand ? 1 : 0
            self.superview?.layoutIfNeeded()
        }
    }

    @objc private func editTapped() {
        onEditTapped?()
    }

    @objc private func switchTapped() {
        onSwitchTapped?()
    }
}

/// Label with content insets (used for the small role type tag)
final class AIAgentPaddedLabel: UILabel {

    var contentInsets = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + contentInsets.left + contentInsets.right,
                      height: size.height + contentInsets.top + contentInsets.bottom)
    }
}
