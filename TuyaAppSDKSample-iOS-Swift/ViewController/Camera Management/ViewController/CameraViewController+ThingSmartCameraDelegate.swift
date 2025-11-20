//
//  CameraViewController+ThingSmartCameraDelegate.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

extension CameraViewController: ThingSmartCameraDelegate {
    func cameraDidConnected(_ camera: (any ThingSmartCameraType)!) {
        connectManager.startPreview()
    }

    func cameraDidBeginPreview(_ camera: (any ThingSmartCameraType)!) {
        connectManager.getHD()
        splitVideoView?.setShowLocalizer(true)
        stopLoadingIndicator()
        enableAllControls(true)
    }

    func cameraDidStopPreview(_ camera: (any ThingSmartCameraType)!) {

    }

    func cameraDidBeginTalk(_ camera: (any ThingSmartCameraType)!) {
        cameraControlViewModel.isTalking = true
    }

    func cameraDidStopTalk(_ camera: (any ThingSmartCameraType)!) {
        cameraControlViewModel.isTalking = false
    }

    func cameraDidStartRecord(_ camera: (any ThingSmartCameraType)!) {
        cameraControlViewModel.isRecording = true
    }

    func cameraDidStopRecord(_ camera: (any ThingSmartCameraType)!) {
        cameraControlViewModel.isRecording = false
        showSuccessTip(IPCLocalizedString(key: "ipc_multi_view_video_saved"))
    }

    func cameraSnapShootSuccess(_ camera: (any ThingSmartCameraType)!) {
        showSuccessTip(IPCLocalizedString(key: "ipc_multi_view_photo_saved"))
    }

    func camera(_ camera: (any ThingSmartCameraType)!, definitionChanged definition: ThingSmartCameraDefinition) {
        hdButton.stopLoading(withEnabled: true)
        hdButton.isSelected = connectManager.isHD == true
    }

    func camera(_ camera: (any ThingSmartCameraType)!, didReceiveMuteState isMute: Bool, playMode: ThingSmartCameraPlayMode) {
        soundButton.stopLoading(withEnabled: true)
        soundButton.isSelected = !isMute
    }

    func camera(_ camera: (any ThingSmartCameraType)!, resolutionDidChangeWidth width: Int, height: Int) {
        connectManager.getDefinition()
    }

    func camera(_ camera: (any ThingSmartCameraType)!, didOccurredErrorAtStep errStepCode: ThingCameraErrorCode, specificErrorCode errorCode: Int) {
        switch errStepCode {
        case Thing_ERROR_CONNECT_FAILED, Thing_ERROR_CONNECT_DISCONNECT:
            stopLoadingIndicator()
            retryButton.isHidden = false
            enableAllControls(false)
        case Thing_ERROR_START_PREVIEW_FAILED:
            stopLoadingIndicator()
            retryButton.isHidden = false
        case Thing_ERROR_START_TALK_FAILED:
            showErrorTip(NSLocalizedString("ipc_errmsg_mic_failed", tableName: "IPCLocalizable"))
        case Thing_ERROR_SNAPSHOOT_FAILED:
            showErrorTip(NSLocalizedString("fail", tableName: "IPCLocalizable"))
        case Thing_ERROR_RECORD_FAILED:
            showErrorTip(NSLocalizedString("record failed", tableName: "IPCLocalizable"))
        case Thing_ERROR_ENABLE_HD_FAILED:
            hdButton.stopLoading(withEnabled: true)
        case Thing_ERROR_ENABLE_MUTE_FAILED:
            soundButton.stopLoading(withEnabled: true)
        default:
            showErrorTip("Operation failed with errorCode: \(errorCode)")
        }
    }

    func cameraDisconnected(_ camera: (any ThingSmartCameraType)!, specificErrorCode errorCode: Int) {
        if [-3, -105].contains(errorCode), needsReconnect {
            needsReconnect = false
            retryAction()
            return
        }
        hdButton.stopLoading(withEnabled: true)
        soundButton.stopLoading(withEnabled: true)
        retryButton.isHidden = false
        enableAllControls(false)
    }
}

extension CameraViewController {
    private func showLoadingIndicator() {
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        statusLabel.isHidden = false
        statusLabel.text = title
    }

    private func stopLoadingIndicator() {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
        statusLabel.isHidden = true
    }
}
