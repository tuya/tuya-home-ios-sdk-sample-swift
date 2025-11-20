//
//  CameraControlViewModel.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import Combine
#if canImport(ThingCloudStorageDebugger)
import ThingCloudStorageDebugger
let kControlCloudDebugEnable = true
#else
let kControlCloudDebugEnable = false
#endif

class CameraControlViewModel: ObservableObject, CameraAlertPlugin {
    typealias ControlConstants = CameraControlButtonItem.ControlConstants

    @Published var controlItems: [CameraControlButtonItem] = []
    @Published var isRecording = false
    @Published var isTalking = false

    private let devId: String
    private let cameraDevice: CameraDevice?

    init(devId: String, cameraDevice: CameraDevice?) {
        self.devId = devId
        self.cameraDevice = cameraDevice
        fetchLocalControlItems()
    }

    deinit {
        print("-------CameraControlViewModel deinit")
    }

    func onTapControl(_ identifier: ControlConstants) {
        switch identifier {
        case .kControlPhoto:
            photoAction()
        case .kControlRecord:
            recordAction()
        case .kControlTalk:
            talkAction()
        case .kControlVideoTalk:
            startVideoCall()
        case .kControlPlayback:
            let vc = CameraPlaybackViewController(devId: devId)
            UIApplication.shared.tp_navigationController?.pushViewController(vc, animated: true)
        case .kControlCloud:
            let vc = CameraCloudViewController(devId: devId)
            UIApplication.shared.tp_navigationController?.pushViewController(vc, animated: true)
        case .kControlMessage:
            let vc = CameraMessageViewController(devId: devId)
            UIApplication.shared.tp_navigationController?.pushViewController(vc, animated: true)
        case .kControlCloudDebug:
#if canImport(ThingCloudStorageDebugger)
            guard let homeId = Home.current?.homeId, let navC = UIApplication.shared.tp_navigationController else {
                return
            }
            ThingCloudStorageDebugger.sharedInstance().start(withDeviceSpaceId: homeId, navigationController: navC)
#endif
        }
    }
}

extension CameraControlViewModel {
    private func fetchLocalControlItems() {
        guard let filePath = Bundle.main.path(forResource: "ipc_preview_toolbar_items", ofType: "json"),
              let jsonString = try? String(contentsOfFile: filePath, encoding: .utf8),
              let jsonData = jsonString.data(using: .utf8) else { return }

        do {
            let decoded = try JSONDecoder().decode([[CameraControlButtonItem]].self, from: jsonData)
            controlItems = decoded.flatMap { $0 }
        } catch {
            print(error.localizedDescription)
        }

        let isSupportCloudStorage = ThingSmartCloudManager.isSupportCloudStorage(devId)
        controlItems = controlItems.map { buttonItem in
            var newButtonItem = buttonItem
            if buttonItem.identifier == .kControlCloud {
                newButtonItem.isHidden = !isSupportCloudStorage
            }
            if buttonItem.identifier == .kControlCloudDebug {
                newButtonItem.isHidden = !kControlCloudDebugEnable
            }
            return newButtonItem
        }

        if !isSupportCloudStorage {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("Cloud Stroage is unsupported", tableName: "IPCLocalizable"))
        }

        addCallButtonIfNeeded()
    }

    private func addCallButtonIfNeeded() {
        DemoCallManager.shared.fetchDeviceCallAbility(by: devId) { [weak self] result, error in
            guard let self else { return }

            if let controlIndex = controlItems.firstIndex(where: {
                $0.identifier == .kControlVideoTalk
            }) {
                controlItems[controlIndex].isHidden = !result
            }
        }
    }
}

// MARK: - Button actions
extension CameraControlViewModel {
    private func talkAction() {
        if CameraPermissionUtil.microNotDetermined {
            CameraPermissionUtil.requestAccessForMicro { [weak self] result in
                if result {
                    self?.performTalk()
                }
            }
        } else if CameraPermissionUtil.microDenied {
            showAlert(withMessage: NSLocalizedString("Micro permission denied", tableName: "IPCLocalizable"))
        } else {
            performTalk()
        }
    }

    private func performTalk() {
        guard let cameraDevice else { return }

        if cameraDevice.cameraModel.isTalking {
            cameraDevice.stopTalk()
            return
        }

        cameraDevice.startTalk()
    }

    private func recordAction() {
        requestPermissionIfNeeded { [weak self] result in
            guard let self, let cameraDevice, result else { return }
            cameraDevice.cameraModel.isRecording ? cameraDevice.stopRecord() : cameraDevice.startRecord()
        }
    }

    private func photoAction() {
        requestPermissionIfNeeded { [weak self] result in
            guard result else { return }
            self?.cameraDevice?.snapshot()
            self?.showTips("Photo saved to photo library")
        }
    }

    private func requestPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
        if CameraPermissionUtil.isPhotoLibraryNotDetermined {
            CameraPermissionUtil.requestPhotoPermission(result: completion)
            return
        }

        if CameraPermissionUtil.isPhotoLibraryAuthorized {
            completion(true)
            return
        }

        showAlert(withMessage: IPCLocalizedString(key: "Photo library permission denied"))
        completion(false)
    }

    private func startVideoCall() {
        guard DemoCallManager.shared.canStartCall else {
            showErrorTip("Cannot start call")
            return
        }

        let extra: [String : Any] = [
            "bizType": "screen_ipc",
            "category": "sp_dpsxj",
            "channelType": 2
        ]

        DemoCallManager.shared.startCall(with: devId, timeout: 60, extra: extra) {

        } failure: { [weak self] error in
            self?.showErrorTip(error?.localizedDescription)
        }
    }
}

// MARK: - Button state
extension CameraControlViewModel {
    func enableControl(isEnabled: Bool, for identifier: ControlConstants) {
        guard let index = controlItems.firstIndex(where: { $0.identifier == identifier }) else { return }
        controlItems[index].isEnabled = isEnabled
    }

    func enableAllControl(isEnabled: Bool) {
        controlItems = controlItems.map { item in
            var newItem = item
            newItem.isEnabled = isEnabled
            return newItem
        }
    }
}
