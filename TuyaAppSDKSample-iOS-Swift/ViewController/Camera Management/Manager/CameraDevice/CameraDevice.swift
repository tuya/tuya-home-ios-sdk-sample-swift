//
//  CameraDevice.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class CameraDevice: ThingSmartDevice {
    private(set) lazy var dpManager: ThingSmartCameraDPManager = {
        ThingSmartCameraDPManager(deviceId: deviceModel.devId)
    }()

    private(set) var cameraModel = CameraDeviceModel()

    private(set) var camera: ThingSmartCameraType!

    var videoView: (UIView & ThingSmartVideoViewType)? {
        camera.videoView()
    }

    var isSupportedVideoSplitting: Bool {
        camera.advancedConfig.isSupportedVideoSplitting;
    }

    private(set) var lastMuted: Bool = false

    private var innerObjectOutlineEnabled: Bool = false
    private var innerOutOffBoundsEnabled: Bool = false

    private var isOnCallState: Bool = false

    private var deviceTasks: [CameraDeviceTask] = []
    private var runningTask: CameraDeviceTask?
    private var deviceTasksLock = DispatchSemaphore(value: 1)

    private var innerObjectOutlineFeature: CameraDeviceOutlineProperty?
    private var innerOutOffBoundsFeatures: [CameraDeviceOutlineProperty]?

    private var innerDelegates = NSHashTable<AnyObject>.weakObjects()

    override init?(deviceId devId: String) {
        super.init(deviceId: devId)

        camera = ThingSmartCameraFactory.camera(
            withP2PType: deviceModel.p2pType(),
            deviceId: deviceModel.devId,
            delegate: self
        )

        isOnCallState = false

        if let features = deviceModel.cameraDeviceFeatures() {
            _ = camera.setDeviceFeatures?(features)
        }

        if let cameraAbility = ThingSmartCameraAbility(deviceModel: deviceModel) {
            cameraModel.resetCameraAbility(cameraAbility)
        }
    }

    deinit {
        print("-------- CameraDevice deinit -------")
        clearAllTasks()
        camera?.destory()
        camera?.disConnect()
    }

    func destory() {
        camera.destory()
    }

    func modifyCameraModel(_ modify: (inout CameraDeviceModel) -> Void) {
        modify(&cameraModel)
    }

    func allInnerDelegates() -> [AnyObject] {
        innerDelegates.allObjects
    }
}

// MARK: - Bind & Connect
extension CameraDevice {
    func addDelegate(_ delegate: ThingSmartCameraDelegate) {
        innerDelegates.add(delegate)
    }

    func removeDelegate(_ delegate: ThingSmartCameraDelegate) {
        innerDelegates.remove(delegate)
    }

    func bindVideoRenderView() {
        camera.videoView().thing_clear()
        camera.registerVideoRenderView?(nil)
    }

    func unbindVideoRenderView() {
        camera.uninstallVideoRenderView?(nil)
    }

    func bindLocalVideoView<V: UIView>(_ videoView: V) where V: ThingSmartVideoViewType {
        camera.bindLocalVideoView?(videoView)
    }

    func unbindLocalVideoView<V: UIView>(_ videoView: V) where V: ThingSmartVideoViewType {
        camera.unbindLocalVideoView?(videoView)
    }

    func connect() {
        connectWithPlayMode(.none)
    }

    func connectWithPlayMode(_ playMode: ThingSmartCameraPlayMode) {
        if cameraModel.connectState == .connecting || cameraModel.connectState == .connected {
            return
        }

        if playMode == .preview, deviceModel.isLowPowerDevice() {
            awake(success: nil, failure: nil)
        }
        cameraModel.connectState = .connecting
        camera.connect?(with: .auto)
    }

    func disconnect() {
        stopPreview()
        stopPlayback()
        camera.disConnect()
        cameraModel.connectState = .disconnected
        cameraModel.previewState = .idle
        cameraModel.videoTalkState = .idle
        cameraModel.isVideoTalkPaused = false
        cameraModel.isMuteLoading = false
    }
}

// MARK: - Preview
extension CameraDevice {
    func startPreview() {
        if cameraModel.previewState == .loading || cameraModel.previewState == .previewing {
            return
        }
        cameraModel.previewState = .loading
        camera.startPreview()
        lastMuted = cameraModel.mutedForPreview

        setOutLineEnable()
        setSmartRectFeatures()
    }

    func stopPreview() {
        guard !isOnCallState else { return }
        stopTalk()
        stopRecord()
        camera.stopPreview()
        cameraModel.previewState = .idle
    }

    func enableMute(_ mute: Bool, forPlayMode playMode: ThingSmartCameraPlayMode) {
        if playMode == .preview {
            cameraModel.mutedForPreview = mute
        } else if playMode == .playback {
            cameraModel.mutedForPlayback = mute
        }
        cameraModel.isMuteLoading = true
        camera.enableMute(mute, for: playMode)
        lastMuted = mute
    }
}

// MARK: - Call
extension CameraDevice {
    func enterCallState() {
        isOnCallState = true
    }

    func leaveCallState() {
        isOnCallState = false
    }
}

// MARK: - Playback
extension CameraDevice {
    func queryRecordDays(year: UInt, month: UInt) {
        camera.queryRecordDays(withYear: year, month: month)
    }

    func queryRecordTimeSlicesWithPlaybackDate(_ playbackDate: ThingSmartPlaybackDate) {
        if cameraModel.isSupportNewRecordEvent {
            camera.newQueryRecordTimeSlice(
                withYear: UInt(playbackDate.year),
                month: UInt(playbackDate.month),
                day: UInt(playbackDate.day)
            )
            return
        }
        camera.queryRecordTimeSlice(
            withYear: UInt(playbackDate.year),
            month: UInt(playbackDate.month),
            day: UInt(playbackDate.day)
        )
    }

    func startPlaybackWithPlayTime(_ playTime: Int, timeLineModel: CameraTimeLineModel) {
        let playTime = timeLineModel.containsPlayTime(playTime) ? playTime : timeLineModel.startTime ?? 0
        guard let startTime = timeLineModel.startTime,
              let stopTime = timeLineModel.stopTime else { return }
        startPlayback(playTime: playTime, startTime: startTime, stopTime: stopTime)
    }

    func startPlayback(playTime: Int, startTime: Int, stopTime: Int) {
        camera.startPlayback(playTime, startTime: startTime, stopTime: stopTime)
        lastMuted = cameraModel.mutedForPlayback
    }

    func pausePlayback() {
        guard !cameraModel.isPlaybackPaused else { return }
        camera.pausePlayback()
    }

    func resumePlayback() {
        guard cameraModel.isPlaybackPaused else { return }
        camera.resumePlayback()
    }

    func stopPlayback() {
        guard [.loading, .playbacking].contains(cameraModel.playbackState) else { return }
        stopRecord()
        camera.stopPlayback()
    }

    func getSupportedPlaySpeedList() -> [Double] {
        camera.getSupportPlaySpeedList?() as? [Double] ?? []
    }

    func isSupportPlaybackDelete() -> Bool {
        camera.isSupportPlaybackDelete?() ?? false
    }

    func deletePlaybackDataWithDay(
        _ day: String,
        onResponse: @escaping (_ errCode: Int32) -> Void,
        onFinish: @escaping (_ errCode: Int32) -> Void
    ) {
        _ = camera.deletePlayBackData?(withDay: day, onResponse: onResponse, onFinish: onFinish)
    }

    func isSupportPlaybackFragmentsDelete() -> Bool {
        camera.isSupportPlaybackDeleteBySlice?() ?? false
    }

    @discardableResult
    func deletePlaybackDataWithFragment(
        _ fragment: String,
        onResponse: @escaping (_ errCode: Int32) -> Void,
        onFinish: @escaping (_ errCode: Int32) -> Void
    ) -> Int32? {
        camera.deletePlayBackData?(withFragments: fragment, onResponse: onResponse, onFinish: onFinish)
    }

    func isSupportPlaybackDownload() -> Bool {
        camera.isSupportPlaybackDownload?() ?? false
    }

    func downloadPlayBackVideo(
        withRange timeRange: NSRange,
        filePath: String,
        success: @escaping (_ filePath: String?) -> Void,
        progress: @escaping (_ progress: UInt) -> Void,
        failure: @escaping (_ failure: Error?) -> Void
    ) -> Int32? {
        guard !cameraModel.isDownloading else { return -1 }
        let result = camera.downloadPlayBackVideo?(
            with: timeRange,
            filePath: filePath,
            success: { [weak self] filePath in
                self?.cameraModel.isDownloading = false
                success(filePath)
            },
            progress: progress,
            failure: { [weak self] error in
                self?.cameraModel.isDownloading = false
                failure(error)
            }
        )
        cameraModel.isDownloading = result == 0
        return result
    }

    @discardableResult
    func stopPlayBackDownload(withResponse callback: @escaping (_ errCode: Int32) -> Void) -> Int32? {
        cameraModel.isDownloading = false
        return camera.stopPlayBackDownload?(response: callback)
    }
}

// MARK: - Quality
extension CameraDevice {
    func getHD() {
        camera.getHD()
    }

    func getDefinition() {
        camera.getDefinition()
    }

    func setDefinition(definition: ThingSmartCameraDefinition) {
        camera.setDefinition(definition)
        setOutLineEnable()
        setSmartRectFeatures()
    }
}

// MARK: - Talk
extension CameraDevice {
    func startTalk() {
        guard !cameraModel.isTalking && !cameraModel.isTalkLoading else { return }
        cameraModel.isTalkLoading = true
        camera.startAudioTalk()
    }

    func stopTalk() {
        guard cameraModel.isTalking || cameraModel.isTalkLoading else { return }
        cameraModel.isTalkLoading = false
        cameraModel.isTalking = false
        camera.stopAudioTalk()
    }

    @discardableResult
    func startVideoTalk() -> Int {
        if cameraModel.videoTalkState == .executing
            || cameraModel.videoTalkState == .completed
            || (cameraModel.connectState != .connected) { return -1 }
        cameraModel.videoTalkState = .executing
        return Int(camera.startVideoTalk())
    }

    @discardableResult
    func stopVideoTalk() -> Int {
        guard [.executing, .completed].contains(cameraModel.videoTalkState) else {
            return -1
        }
        return Int(camera.stopVideoTalk())
    }

    /**
        pause send video talk
     */
    func pauseVideoTalk() -> Int {
        guard cameraModel.connectState == .connected
                && cameraModel.videoTalkState == .completed
                && !cameraModel.isVideoTalkPaused else { return -1 }
        return Int(camera.pauseVideoTalk())
    }

    /**
        resume send video talk
     */
    func resumeVideoTalk() -> Int {
        guard cameraModel.connectState == .connected
                && cameraModel.videoTalkState == .completed
                && cameraModel.isVideoTalkPaused else { return -1 }
        return Int(camera.resumeVideoTalk())
    }

}

// MARK: - Capture
extension CameraDevice {
    /**
     open local video capture
     */
    @discardableResult
    func startLocalVideoCapture() -> Int {
        guard ![.executing, .completed].contains(cameraModel.videoCaptureState) else { return 0 }
        cameraModel.videoCaptureState = .executing
        let retCode = camera.startLocalVideoCapture(with: nil)
        cameraModel.videoCaptureState = .completed
        if retCode < 0 {
            cameraModel.videoCaptureState = .failed
        }
        return Int(retCode)
    }

    /**
     close the local video capture.
     */
    @discardableResult
    func stopLocalVideoCapture() -> Int {
        cameraModel.videoCaptureState = .idle
        return Int(camera.stopLocalVideoCapture())
    }

    /**
     switch local camera position
     */
    func switchLocalCameraPosition() -> Int {
        guard cameraModel.videoCaptureState == .executing || cameraModel.videoCaptureState == .completed else {
            return -1
        }
        return Int(camera.switchLocalCameraPosition())
    }
}

// MARK: - Record
extension CameraDevice {
    /**
     start audio record
     */
    func startAudioRecord() -> Int {
        Int(camera.startAudioRecord(with: nil))
    }

    /**
     stop audio record
     */
    func stopAudioRecord() -> Int {
        Int(camera.stopAudioRecord())
    }

    func startRecord() {
        guard !cameraModel.isRecording else { return }
        cameraModel.isRecordLoading = true
        camera.startRecord()
    }

    func stopRecord() {
        guard cameraModel.isRecording else { return }
        cameraModel.isRecording = false
        cameraModel.isRecordLoading = false
        camera.stopRecord()
    }

    @discardableResult
    func snapshot() -> UIImage {
        camera.snapShoot()
    }
}

// MARK: - Outline
extension CameraDevice {
    //set ipc_object_outline switch, set before startPreview
    func setObjectOutlineEnable(_ enable: Bool) {
        innerObjectOutlineEnabled = enable
    }

    //set out_off_bounds switch, set before startPreview
    func setOutOffBoundsEnable(_ enable: Bool) {
        innerOutOffBoundsEnabled = enable
    }

    //set ipc_object_outline feature, set before startPreview
    func setObjectOutlineFeature(_ feature: CameraDeviceOutlineProperty) {
        innerObjectOutlineFeature = feature
    }

    //set out_off_bounds features, set before startPreview
    func setOutOffBoundsFeatures(_ features: [CameraDeviceOutlineProperty]) {
        innerOutOffBoundsFeatures = features
    }
}

// MARK: - Task
extension CameraDevice {
    private func appendTask(_ task: CameraDeviceTask) {
        addTask(task)
        syncRunTask()
    }

    private func clearAllTasks() {
        deviceTasksLock.wait()
        runningTask = nil
        deviceTasksLock.signal()
    }

    private func addTask(_ task: CameraDeviceTask) {
        deviceTasksLock.wait()
        deviceTasks.append(task)
        deviceTasksLock.signal()
    }

    private func removeTask(_ task: CameraDeviceTask?) {
        guard let task else { return }
        deviceTasksLock.wait()
        deviceTasks.removeAll { $0.taskEvent == task.taskEvent }
        deviceTasksLock.signal()
    }

    private func syncRunTask() {
        guard !(runningTask?.isRunning == true) else { return }
        if runningTask != nil {
            runningTask?.isRunning = true
            if runningTask?.taskEvent == .startPreview {
                startPreview()
            } else if runningTask?.taskEvent == .stopPreview {
                stopPreview()
            }
        } else {
            runningTask = nextDeviceTask()
        }
    }

    private func nextDeviceTask() -> CameraDeviceTask? {
        var deviceTask: CameraDeviceTask?
        deviceTasksLock.wait()
        deviceTask = deviceTasks.first
        deviceTasksLock.signal()
        return deviceTask
    }

    func task(event: CameraDeviceTask.CameraDeviceTaskEvent, completeWithError: @escaping (String) -> Void) {
        var task: CameraDeviceTask? = nil
        if runningTask?.taskEvent == event {
            task = runningTask
            removeTask(task)
            runningTask = nil
        }
        guard var task else { return }
        task.isRunning = false
        syncRunTask()
    }
}

// MARK: - Private
extension CameraDevice {
    private func setOutLineEnable() {
        let enable = innerObjectOutlineEnabled || innerOutOffBoundsEnabled
        _ = camera.setOutLineEnable?(enable)
    }

    private func setSmartRectFeatures() {
        var allFrameFeatures = [CameraDeviceOutlineProperty]()

        //智能画框/ipc_object_outline
        if let innerObjectOutlineFeature {
            allFrameFeatures.append(innerObjectOutlineFeature)
        }

        //越线框/out_off_bounds
        if let innerOutOffBoundsFeatures {
            allFrameFeatures.append(contentsOf: innerOutOffBoundsFeatures)
        }

        let resultFeatures = [
            "SmartRectFeature": allFrameFeatures.jsonObject()
        ]
        let featuresJson = resultFeatures.convertedJsonString()
        _ = camera.setSmartRectFeatures?(featuresJson)
    }

    private func enableMute(_ muted: Bool) {
        if cameraModel.isOnPreviewMode {
            cameraModel.mutedForPreview = muted
        } else {
            cameraModel.mutedForPlayback = muted
        }
        let playMode: ThingSmartCameraPlayMode = cameraModel.isOnPreviewMode ? .preview : .playback
        camera.enableMute(muted, for: playMode)
    }
}
