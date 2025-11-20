//
//  CameraBaseViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import UIKit

protocol CameraAlertPlugin: AnyObject {
    func showTips(_ tip: String)

    func showSuccessTip(_ tip: String)

    func showErrorTip(_ tip: String?)

    func showProgress(_ progress: Float, tip: String)

    func dismissTip()

    func showAlert(withMessage msg: String, complete: (() -> Void)?)

    func showAlert(withMessage msg: String, onCancel: @escaping () -> Void, onConfirm: @escaping () -> Void)

    func showAlert(withMessage msg: String)
}

extension CameraAlertPlugin {
    func showTips(_ tip: String) {
        SVProgressHUD.showInfo(withStatus: tip)
    }

    func showSuccessTip(_ tip: String) {
        SVProgressHUD.showSuccess(withStatus: tip)
    }

    func showErrorTip(_ tip: String?) {
        SVProgressHUD.showError(withStatus: tip)
    }

    func showProgress(_ progress: Float, tip: String) {
        SVProgressHUD.showProgress(progress, status: tip + ": \(Int(progress * 100))%")
    }

    func dismissTip() {
        SVProgressHUD.dismiss()
    }

    func showAlert(withMessage msg: String, complete: (() -> Void)?) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel) { _ in
            complete?()
        }
        alert.addAction(action)

        if let self = self as? UIViewController {
            self.present(alert, animated: true)
        } else {
            UIApplication.shared.tp_topMostViewController?.present(alert, animated: true)
        }
    }

    func showAlert(withMessage msg: String, onCancel: @escaping () -> Void, onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: IPCLocalizedString(key: "Cancel"), style: .cancel) { _ in
            onCancel()
        }
        let confirmAction = UIAlertAction(title: IPCLocalizedString(key: "Confirm"), style: .default) { _ in
            onConfirm()
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        if let self = self as? UIViewController {
            self.present(alert, animated: true)
        } else {
            UIApplication.shared.tp_topMostViewController?.present(alert, animated: true)
        }
    }

    func showAlert(withMessage msg: String) {
        showAlert(withMessage: msg, complete: nil)
    }
}

class CameraBaseViewController: UIViewController, CameraAlertPlugin {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    deinit {
        print("\(String(describing: Self.self)) \(#function)")
    }
}
