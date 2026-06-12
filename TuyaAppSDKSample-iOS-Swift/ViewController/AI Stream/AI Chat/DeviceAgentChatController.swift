//
//  DeviceAgentChatController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartStreamChannelKit
import SnapKit

/// AI chat page using the device agent identity
///
/// Adds agent-role-related UI on top of the base chat capabilities:
/// - Current role card at the top (expand to edit the role / switch roles)
/// - More menu at the top-right (role detail / memory management / chat history / current mood)
/// - Management pages are presented as modal sheets; the role refreshes on dismissal, and the session is recreated when the role changes
final class DeviceAgentChatController: StreamChatBaseController {

    /// Device ID
    let devId: String

    /// AI Agent ATOP request instance; must be retained, or callbacks will be lost if released early
    private let agentRequest = ThingSmartAIAgentRequest()
    /// Currently bound agent role
    private var boundRole: ThingSmartAIAgentRoleDetailResult?
    private lazy var roleBanner: AIAgentRoleBannerView = {
        let banner = AIAgentRoleBannerView()
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.onEditTapped = { [weak self] in
            self?.editBoundRole()
        }
        banner.onSwitchTapped = { [weak self] in
            self?.switchRole()
        }
        return banner
    }()

    init(homeId: Int64, devId: String) {
        self.devId = devId
        super.init(homeId: homeId)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Base class customization points

    /// Connect the stream channel using the device agent identity
    override func makeStreamClient() -> ThingSmartStreamClient? {
        return ThingSmartStreamClient(forAgentDevice: devId)
    }

    /// Attach the device ID when creating the session
    override var agentDeviceId: String? { devId }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Insert the current role card at the top; the table top now follows the card bottom
        view.addSubview(roleBanner)
        roleBanner.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            // Align with the insetGrouped card horizontal margins (20pt)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
        }
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(roleBanner.snp.bottom).offset(8)
            make.left.right.equalTo(view)
            make.bottom.equalTo(actionView.snp.top)
        }

        // More menu next to the real-time call entry
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "More", style: .plain, target: self, action: #selector(moreTapped)),
            makeRealtimeCallBarButtonItem(),
        ]
        loadBoundRole()
    }

    // MARK: - Role loading

    /// Query the bound role and refresh the top card; auto-initialize the binding if none exists
    private func loadBoundRole() {
        agentRequest.getBindRole(devId: devId) { [weak self] detail in
            if detail.roleId == nil {
                self?.initializeRoleBinding()
            } else {
                self?.boundRole = detail
                self?.roleBanner.update(role: detail)
            }
        } failure: { [weak self] _ in
            self?.initializeRoleBinding()
        }
    }

    private func initializeRoleBinding() {
        agentRequest.initializeAgentRoleBinding(devId: devId) { [weak self] detail in
            self?.boundRole = detail
            self?.roleBanner.update(role: detail)
        } failure: { [weak self] error in
            print("initialize-agent-role-binding failed: \(String(describing: error))")
            self?.roleBanner.showLoadFailed()
        }
    }

    /// Refresh the bound role after the sheet is dismissed; if the role changed, the old session is still bound to the old role and must be closed and recreated
    private func refreshBoundRole(previousRoleId: String?) {
        agentRequest.getBindRole(devId: devId) { [weak self] detail in
            guard let self = self else { return }
            self.boundRole = detail
            self.roleBanner.update(role: detail)
            if let newRoleId = detail.roleId, newRoleId != previousRoleId {
                self.recreateSession()
            }
        } failure: { _ in
            // Keep the current state if the refresh fails; the active session is unaffected
        }
    }

    /// Chat-related pages need the bound role's roleId and bindRoleType
    private func boundRoleInfo() -> (roleId: String, type: ThingSmartAIAgentBindRoleType)? {
        guard let roleId = boundRole?.roleId else {
            SVProgressHUD.showError(withStatus: "Role info not available, please try again later")
            return nil
        }
        // Fall back to the role template when bindRoleType is missing or invalid
        let type: ThingSmartAIAgentBindRoleType
        if let rawType = boundRole?.bindRoleType, let parsed = ThingSmartAIAgentBindRoleType(rawValue: rawType) {
            type = parsed
        } else {
            type = .roleTemplate
        }
        return (roleId, type)
    }

    // MARK: - More menu

    /// More menu: memory management / chat history / current mood
    @objc private func moreTapped() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Memory Management", style: .default) { [weak self] _ in
            guard let self = self, let role = self.boundRoleInfo() else { return }
            self.presentAgentSheet(AIAgentMemoryViewController(devId: self.devId, roleId: role.roleId, bindRoleType: role.type))
        })
        sheet.addAction(UIAlertAction(title: "Chat History", style: .default) { [weak self] _ in
            guard let self = self, let role = self.boundRoleInfo() else { return }
            self.presentAgentSheet(AIAgentChatHistoryViewController(devId: self.devId, roleId: role.roleId, bindRoleType: role.type))
        })
        sheet.addAction(UIAlertAction(title: "Current Mood", style: .default) { [weak self] _ in
            self?.showCurrentEmotion()
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // actionSheet needs an anchor on iPad (use the first bar button, i.e. More itself)
        sheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?.first
        present(sheet, animated: true)
    }

    /// Query and present the role detail by binding type (custom-role.detail / role-template.detail)
    private func showBoundRoleDetail() {
        guard let role = boundRoleInfo() else { return }

        let success: (ThingSmartAIAgentRoleDetailResult) -> Void = { [weak self] detail in
            SVProgressHUD.dismiss()
            self?.showAIAgentInfo(title: "Role Detail", message: detail.aiAgentDetailText)
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

    /// Query and present the current chat mood (chat-emotion.current)
    private func showCurrentEmotion() {
        SVProgressHUD.show()
        agentRequest.getCurrentChatEmotion(devId: devId) { [weak self] emotion in
            SVProgressHUD.dismiss()
            let message: String
            if emotion.emotionOpen == false {
                message = "Mood feature is not enabled"
            } else if let text = emotion.text ?? emotion.emotion, !text.isEmpty {
                message = [
                    "Mood: \(emotion.emotion ?? "-")",
                    "Description: \(text)",
                ].joined(separator: "\n")
            } else {
                message = "I can't tell your recent mood yet. Come chat with me!"
            }
            self?.showAIAgentInfo(title: "Current Mood", message: message)
        } failure: { [weak self] error in
            self?.showAIAgentError(error)
        }
    }

    // MARK: - Role card actions

    /// Edit the role (custom role) / view role detail (template or default role)
    private func editBoundRole() {
        guard let role = boundRole, let roleId = role.roleId else {
            SVProgressHUD.showError(withStatus: "Role info not available, please try again later")
            return
        }
        if let rawType = role.bindRoleType, ThingSmartAIAgentBindRoleType(rawValue: rawType) == .customRole {
            presentAgentSheet(AIAgentRoleEditViewController(devId: devId, mode: .edit(roleId: roleId)))
        } else {
            showAIAgentInfo(title: "Role Detail", message: role.aiAgentDetailText)
        }
    }

    /// Switch roles (reuses AIAgentRoleListViewController)
    private func switchRole() {
        presentAgentSheet(AIAgentRoleListViewController(devId: devId, currentRoleId: boundRole?.roleId))
    }

    /// Present management pages as modal sheets: pushing would trigger this page's viewDidDisappear and destroy the chat session,
    /// while a sheet does not; after the sheet is dismissed (swipe-down or programmatic dismiss), refresh the role card and recreate the session if the role changed
    private func presentAgentSheet(_ viewController: UIViewController) {
        let nav = AIAgentSheetNavController(rootViewController: viewController)
        let previousRoleId = boundRole?.roleId
        nav.onDeinit = { [weak self] in
            DispatchQueue.main.async {
                self?.refreshBoundRole(previousRoleId: previousRoleId)
            }
        }
        present(nav, animated: true)
    }
}
