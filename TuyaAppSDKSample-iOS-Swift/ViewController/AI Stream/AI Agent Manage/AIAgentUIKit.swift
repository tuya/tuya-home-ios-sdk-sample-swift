//
//  AIAgentUIKit.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2026 Tuya Inc. (https://developer.tuya.com/)

import UIKit

/// Simple remote image view (demo only: in-memory cache + reuse race protection, avoiding a third-party image library)
final class AIAgentRemoteImageView: UIImageView {

    private static let cache = NSCache<NSString, UIImage>()
    private var currentURLString: String?

    func setImageURL(_ urlString: String?, placeholderSystemName: String = "person.crop.circle") {
        currentURLString = urlString
        image = UIImage(systemName: placeholderSystemName)
        guard let urlString = urlString, !urlString.isEmpty, let url = URL(string: urlString) else { return }
        if let cached = Self.cache.object(forKey: urlString as NSString) {
            image = cached
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            Self.cache.setObject(image, forKey: urlString as NSString)
            DispatchQueue.main.async {
                guard let self = self, self.currentURLString == urlString else { return }
                self.image = image
            }
        }.resume()
    }
}

/// Navigation controller that hosts the AI agent management pages as a modal sheet
///
/// Pushing from the chat page (StreamChatBaseController and its subclasses) would interrupt the chat session,
/// so the management pages are presented as a sheet instead of pushed; the deinit callback refreshes external state
/// after the sheet is closed (whether by swipe-down gesture or programmatic dismiss).
final class AIAgentSheetNavController: UINavigationController {

    var onDeinit: (() -> Void)?

    deinit {
        onDeinit?()
    }
}

extension UIViewController {

    /// Unified error toast
    func showAIAgentError(_ error: Error) {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }

    /// Confirmation alert for destructive actions
    func confirmAIAgentAction(title: String, message: String? = nil, confirmTitle: String = "Confirm", handler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: confirmTitle, style: .destructive) { _ in handler() })
        present(alert, animated: true)
    }

    /// Information alert (role details, etc.)
    func showAIAgentInfo(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ThingSmartAIAgentRoleDetailResult {

    /// Multi-line role detail text for alert display
    var aiAgentDetailText: String {
        return [
            "roleId: \(roleId ?? "-")",
            "Name: \(roleName ?? "-")",
            "Introduction: \(roleIntroduce ?? "-")",
            "Description: \(roleDesc ?? "-")",
            "Language: \(useLangName ?? useLangCode ?? "-")",
            "Voice: \(useTimbreName ?? useTimbreId ?? "-")",
            "Speech rate: \(speed.map { String($0) } ?? "-")",
            "Binding type: \(bindRoleType.map { String($0) } ?? "-")",
            "Last reply: \(lastTextAnswer ?? "-")",
        ].joined(separator: "\n")
    }
}
