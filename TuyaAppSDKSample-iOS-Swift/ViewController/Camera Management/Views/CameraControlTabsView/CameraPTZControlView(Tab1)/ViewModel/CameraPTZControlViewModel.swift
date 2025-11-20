//
//  CameraPTZControlViewModel.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class CameraPTZControlViewModel {
    private let ptzManager: ThingSmartPTZManager

    var isSupportCollectionPoint: Bool

    init(devId: String) {
        ptzManager = ThingSmartPTZManager(deviceId: devId)
        isSupportCollectionPoint = ptzManager.isSupportCollectionPoint()
    }
}

// MARK: - Direction
extension CameraPTZControlViewModel {
    func directionBtnStart(_ direction: CameraPTZControlDirection) {
        guard ptzManager.isSupportPTZControl() else {
            SVProgressHUD.showInfo(withStatus: IPCLocalizedString(key: "PTZ Control  is unsupported"))
            return
        }

        ptzManager.startPTZ(with: direction.ptzDirection) { _ in

        } failure: { error in
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }

    func directionBtnEnded(_ direction: CameraPTZControlDirection) {
        guard ptzManager.isSupportPTZControl() else {
            SVProgressHUD.showInfo(withStatus: IPCLocalizedString(key: "PTZ Control  is unsupported"))
            return
        }

        ptzManager.stopPTZ { _ in

        } failure: { error in
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }
}

// MARK: - Zoom
extension CameraPTZControlViewModel {
    func startZoomIn() {
        performZoom(isEnlarge: true)
    }

    func startZoomOut() {
        performZoom(isEnlarge: false)
    }

    func stopZoom() {
        guard ptzManager.isSupportZoomAction() else {
            SVProgressHUD.showInfo(withStatus: IPCLocalizedString(key: "Zoom Action is unsupported"))
            return
        }

        ptzManager.stopZoomAction { _ in

        } failure: { error in
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }

    private func performZoom(isEnlarge: Bool) {
        guard ptzManager.isSupportZoomAction() else {
            SVProgressHUD.showInfo(withStatus: IPCLocalizedString(key: "Zoom Action is unsupported"))
            return
        }

        ptzManager.startPTZZoom(withIsEnlarge: isEnlarge) { _ in

        } failure: { error in
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }
}

// MARK: - Collection
extension CameraPTZControlViewModel {
    func addCollectionPoint(_ pointName: String?) {
        guard isSupportCollectionPoint else {
            SVProgressHUD.showInfo(withStatus: IPCLocalizedString(key: "add collection point is unsupported"))
            return
        }

        let pointName = pointName?.trimmingCharacters(in: .whitespaces) ?? "Default"
        ptzManager.addCollectionPoint(withName: pointName) {

        } failure: { error in
            SVProgressHUD.showInfo(withStatus: error?.localizedDescription)
        }
    }

    func savePreset1(for num: Int) {
        guard ptzManager.isSupportPresetPoint() else {
            SVProgressHUD.showInfo(withStatus: IPCLocalizedString(key: "Preset Point is unsupported"))
            return
        }

        let presetPoints = ptzManager.requestSupportedPresetPoints()

        guard presetPoints.count >= num,
              let wrapped = presetPoints[num - 1] as? String,
              let index = Int(wrapped) else { return }

        ptzManager.setPresetPointWith(index) { _ in
            SVProgressHUD.showSuccess(withStatus: IPCLocalizedString(key: "success"))
        } failure: { error in
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }
}
