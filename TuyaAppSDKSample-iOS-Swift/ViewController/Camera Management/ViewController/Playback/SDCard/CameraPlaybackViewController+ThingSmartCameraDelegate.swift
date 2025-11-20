//
//  CameraPlaybackViewController+ThingSmartCameraDelegatee.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

// MARK: - connect
extension CameraPlaybackViewController: ThingSmartCameraDelegate {
    func cameraDidConnected(_ camera: (any ThingSmartCameraType)!) {
        startPlayback()
    }

    func cameraDisconnected(_ camera: (any ThingSmartCameraType)!, specificErrorCode errorCode: Int) {
        if [-3, -105].contains(errorCode) && needReconnect {
            needReconnect = false
            retryAction()
            return
        }
        enableView(true)
        enableAllControl(false)
        didOccurError(canRetry: true)
    }

    func camera(_ camera: (any ThingSmartCameraType)!, didOccurredErrorAtStep errStepCode: ThingCameraErrorCode, specificErrorCode errorCode: Int) {
        switch errStepCode {
        case Thing_ERROR_CONNECT_FAILED, Thing_ERROR_CONNECT_DISCONNECT:
            didOccurError(canRetry: true)
            enableAllControl(false)
        case Thing_ERROR_START_PREVIEW_FAILED:
            didOccurError(canRetry: true)
        case Thing_ERROR_START_PLAYBACK_FAILED:
            showErrorTip(NSLocalizedString("ipc_errmsg_record_play_failed", tableName: "IPCLocalizable"))
        case Thing_ERROR_PAUSE_PLAYBACK_FAILED:
            showErrorTip(NSLocalizedString("fail", tableName: "IPCLocalizable"))
        case Thing_ERROR_RESUME_PLAYBACK_FAILED:
            showErrorTip(NSLocalizedString("fail", tableName: "IPCLocalizable"))
        case Thing_ERROR_SNAPSHOOT_FAILED:
            showErrorTip(NSLocalizedString("fail", tableName: "IPCLocalizable"))
        case Thing_ERROR_RECORD_FAILED:
            showErrorTip(NSLocalizedString("record failed", tableName: "IPCLocalizable"))
        default: break
        }
    }

    func camera(_ camera: (any ThingSmartCameraType)!, thing_didReceiveVideoFrame sampleBuffer: CMSampleBuffer!, frameInfo: ThingSmartVideoFrameInfo) {
        guard playTime ?? 0 != frameInfo.nTimeStamp else { return }
        playTime = Int(frameInfo.nTimeStamp)
        if !timelineView.isDecelerating && !timelineView.isDragging {
            timelineView.currentTime = TimeInterval(frameInfo.nTimeStamp)
        }
    }
}

// MARK: - Date callback
extension CameraPlaybackViewController {
    func camera(_ camera: (any ThingSmartCameraType)!, didReceiveRecordDayQueryData days: [NSNumber]!) {
        calendarViewModel.savePlaybackDays(days.map { $0.intValue })
        didLoadSuccess()
        requestTimeSlice(with: currentDate)
    }

    func camera(_ camera: (any ThingSmartCameraType)!, didReceiveTimeSliceQueryData timeSlices: [[AnyHashable : Any]]!) {
        guard !timeSlices.isEmpty else {
            didOccurError(IPCLocalizedString(key: "ipc_playback_no_records_today"), canRetry: false)
            return
        }

        timeLineModels = timeSlices.compactMap {
            CameraTimeLineModel(from: [
                "startTime": $0["startTime"],
                "endTime": $0["endTime"]
            ])
        }
        timelineView.sourceModels = timeLineModels
        timelineView.setCurrentTime(0, animated: true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - play & opeartions
extension CameraPlaybackViewController {
    func cameraDidBeginPreview(_ camera: (any ThingSmartCameraType)!) {
        connectManager.getHD()
    }

    func cameraDidBeginPlayback(_ camera: (any ThingSmartCameraType)!) {
        enableAllControl(true)
        didLoadSuccess()
    }

    func cameraDidPausePlayback(_ camera: (any ThingSmartCameraType)!) {
        playStateDidChanged(to: false)
    }

    func cameraDidResumePlayback(_ camera: (any ThingSmartCameraType)!) {
        enableAllControl(true)
        didLoadSuccess()
        playStateDidChanged(to: true)
    }

    func camera(_ camera: (any ThingSmartCameraType)!, didReceiveMuteState isMute: Bool, playMode: ThingSmartCameraPlayMode) {
        muteStateDidChanged(to: isMute)
    }

    func cameraSnapShootSuccess(_ camera: (any ThingSmartCameraType)!) {
        showSuccessTip(NSLocalizedString("ipc_multi_view_photo_saved", tableName: "IPCLocalizable"))
    }

    func cameraDidStartRecord(_ camera: (any ThingSmartCameraType)!) {
        recordStateDidChanged(to: true)
    }

    func cameraDidStopRecord(_ camera: (any ThingSmartCameraType)!) {
        recordStateDidChanged(to: false)
        showSuccessTip(NSLocalizedString("ipc_multi_view_video_saved", tableName: "IPCLocalizable"))
    }

    func cameraPlaybackDidFinished(_ camera: (any ThingSmartCameraType)!) {
        enableAllControl(false)
        didOccurError(IPCLocalizedString(key: "ipc_video_end"), canRetry: false)
    }

    func cameraDidStopPlayback(_ camera: (any ThingSmartCameraType)!) {}
}
