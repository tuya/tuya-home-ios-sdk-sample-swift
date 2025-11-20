//
//  CameraCallInterfaceManager.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import ThingSmartCallChannelKit

class CameraCallInterfaceManager: NSObject, ThingCallInterfaceManager {
    typealias CameraCallInterfaceType = UIViewController & ThingSmartCallInterface
    
    private var currentVC: CameraCallInterfaceType?

    var identifier: ThingCallInterfaceManagerIdentifier = .screenIPCIdentifier

    func present(_ interface: any ThingSmartCallInterface, completion: @escaping ThingCallInterfaceManagerCompletion) {
        guard let tempInterface = interface as? CameraCallInterfaceType else { return }

        DispatchQueue.main.async {
            tempInterface.modalPresentationStyle = .fullScreen
            if let currentVC = self.currentVC {
                currentVC.dismiss(animated: false)
                UIApplication.shared.tp_topMostViewController?.present(tempInterface, animated: false, completion: completion)
            } else {
                UIApplication.shared.tp_topMostViewController?.present(tempInterface, animated: true, completion: completion)
            }

            self.currentVC = tempInterface
        }
    }

    func dismiss(_ interface: ThingSmartCallInterface, completion: @escaping () -> Void) {
        guard let tempInterface = interface as? CameraCallInterfaceType, tempInterface === currentVC else { return }

        DispatchQueue.main.async {
            self.currentVC?.dismiss(animated: true, completion: completion)
            self.currentVC = nil
        }
    }

    func generateCallInterface(withCall call: any ThingSmartCallProtocol) -> any ThingSmartCallInterface {
        CameraCallViewController(call: call)
    }
}
