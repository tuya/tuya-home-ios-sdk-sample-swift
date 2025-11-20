//
//  CameraConnectManager.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import Combine

protocol CameraApplicationEventDelegate: AnyObject {
    func applicationDidEnterBackground()
    func applicationWillEnterForeground()
}

class CameraConnectManager {
    private(set) var devId: String
    private(set) var cameraDevice: CameraDevice?
    private(set) var videoView: ThingCameraVideoContainer?
    private var subscriptions = Set<AnyCancellable>()
    private weak var delegate: (CameraApplicationEventDelegate & ThingSmartCameraDelegate)?

    init(devId: String) {
        self.devId = devId
        cameraDevice = CameraDeviceManager.shared.getCameraDevice(devId: devId)
        videoView = .init()
        bindEvents()
    }

    var isOnline: Bool {
        cameraDevice?.deviceModel.isOnline ?? false
    }

    var connectState: CameraDeviceModel.CameraDeviceConnectState {
        cameraDevice?.cameraModel.connectState ?? .disconnected
    }
    
    var previewState: CameraDeviceModel.CameraDevicePreviewState {
        cameraDevice?.cameraModel.previewState ?? .idle
    }
    
    var isPreviewMuted: Bool {
        cameraDevice?.cameraModel.mutedForPreview ?? true
    }
    
    var isPlaybackMuted: Bool {
        cameraDevice?.cameraModel.mutedForPlayback ?? true
    }
    
    var isPlaybackPaused: Bool {
        cameraDevice?.cameraModel.isPlaybackPaused ?? false
    }
    
    var isHD: Bool {
        cameraDevice?.cameraModel.isHD ?? false
    }
    
    var supportedPlaySpeeds: [Double] {
        cameraDevice?.getSupportedPlaySpeedList() ?? []
    }
    
    var isSupportPlaybackDownload: Bool {
        cameraDevice?.isSupportPlaybackDownload() ?? false
    }
    
    var isSupportPlaybackFragmentsDelete: Bool {
        cameraDevice?.isSupportPlaybackFragmentsDelete() ?? false
    }
    
    var isSupportPlaybackDayDelete: Bool {
        cameraDevice?.isSupportPlaybackDelete() ?? false
    }
    
    var isDownloading: Bool {
        cameraDevice?.cameraModel.isDownloading ?? false
    }
    
    var isRecording: Bool {
        cameraDevice?.cameraModel.isRecording ?? false
    }
        
    func connect(playMode: ThingSmartCameraPlayMode) {
        cameraDevice?.connectWithPlayMode(playMode)
    }

    func connect() {
        guard let cameraDevice, ![.connecting, .connected].contains(cameraDevice.cameraModel.connectState) else { return }
        cameraDevice.connect()
    }

    func disconnect() {
        cameraDevice?.disconnect()
    }
    
    func setOutOffBoundsEnable(_ enable: Bool) {
        cameraDevice?.setOutOffBoundsEnable(enable)
    }

    func setOutOffBoundsFeatures(_ features: [CameraDeviceOutlineProperty]) {
        cameraDevice?.setOutOffBoundsFeatures(features)
    }
    
    func startPreview() {
        cameraDevice?.stopPlayback()
        cameraDevice?.startPreview()
        cameraDevice?.enableMute(cameraDevice?.cameraModel.mutedForPreview ?? true, forPlayMode: .preview)
    }
    
    func startPlayback(playTime: Int, timelineModel: CameraTimeLineModel) {
        cameraDevice?.startPlaybackWithPlayTime(playTime, timeLineModel: timelineModel)
        cameraDevice?.enableMute(cameraDevice?.cameraModel.mutedForPlayback ?? true, forPlayMode: .playback)
    }
    
    func toggleMute(for mode: ThingSmartCameraPlayMode) {
        switch mode {
        case .preview:
            cameraDevice?.enableMute(!isPreviewMuted, forPlayMode: .preview)
        case .playback:
            cameraDevice?.enableMute(!isPlaybackMuted, forPlayMode: .playback)
        default:
            break
        }
    }
    
    func getHD() {
        cameraDevice?.getHD()
    }
    
    func getDefinition() {
        cameraDevice?.getDefinition()
    }
    
    func toggleHD() {
        let isHD = cameraDevice?.cameraModel.isHD ?? false
        cameraDevice?.setDefinition(definition: isHD ? .standard : .high)
    }
    
    func toggleRecord() {
        isRecording ? cameraDevice?.stopRecord() : cameraDevice?.startRecord()
    }
    
    func togglePause() {
        if isPlaybackPaused {
            cameraDevice?.resumePlayback()
            return
        }

        if cameraDevice?.cameraModel.playbackState == .playbacking {
            cameraDevice?.stopRecord()
            cameraDevice?.pausePlayback()
        }
    }

    func snapshot() {
        cameraDevice?.snapshot()
    }
    
    func stopPreview() {
        cameraDevice?.stopPreview()
        videoView?.thing_clear()
    }
    
    func stopPlayback() {
        cameraDevice?.stopPlayback()
        videoView?.thing_clear()
    }
    
    func fetchRecordTimeSlices(date: ThingSmartPlaybackDate?) {
        guard let date else { return }
        cameraDevice?.queryRecordTimeSlicesWithPlaybackDate(date)
    }
    
    func fetchSDCardStatus(completion: @escaping (ThingSmartCameraSDCardStatus?, NSError?) -> Void ) {
        cameraDevice?.dpManager.value(forDP: .sdCardStatusDPName) { result in
            if let rawValue = result as? UInt,
               let status = ThingSmartCameraSDCardStatus.init(rawValue: rawValue) {
                completion(status, nil)
            } else {
                completion(nil, .init())
            }
        } failure: { error in
            completion(nil, error as NSError?)
        }
    }

    func queryRecordDays(year: Int, month: Int) {
        cameraDevice?.queryRecordDays(year: UInt(year), month: UInt(month))
    }

    func downloadPlayBackVideo(
        range timeRange: NSRange,
        filePath: String,
        success: @escaping (_ filePath: String?) -> Void,
        progress: @escaping (_ progress: UInt) -> Void,
        failure: @escaping (_ failure: Error?) -> Void
    ) -> Int {
        Int((cameraDevice?.downloadPlayBackVideo(withRange: timeRange, filePath: filePath, success: success, progress: progress, failure: failure)) ?? -1)
    }
    
    func stopDownloadPlaybackVideo(completion: @escaping (_ success: Bool) -> Void) {
        cameraDevice?.stopPlayBackDownload { errCode in
            completion(errCode == 0)
        }
    }

    func deletePlayback(
        fragements: [CameraTimeLineModel],
        onResponse: @escaping (_ errorMsg: String?) -> Void,
        onFinish: @escaping (_ errorMsg: String?) -> Void
    ) {
        guard isSupportPlaybackFragmentsDelete else {
            onResponse(IPCLocalizedString(key: "ipc_playback_delete_unsupported_tip"))
            return
        }

        let dic = ["fragements": fragements]
        guard let jsonData = try? JSONEncoder().encode(dic), let jsonString = String(data: jsonData, encoding: .utf8) else {
            onResponse("failed to encode fragements data")
            return
        }

        cameraDevice?.deletePlaybackDataWithFragment(jsonString) { errCode in
            let msg = errCode == 0 ? nil : IPCLocalizedString(key: "ipc_playback_delete_fail")
            onResponse(msg)
        } onFinish: { errCode in
            let msg = errCode == 0 ? nil : IPCLocalizedString(key: "ipc_playback_delete_fail")
            onFinish(msg)
        }
    }
    
    func deletePlaybackDay(
        date: ThingSmartPlaybackDate,
        onResponse: @escaping (_ errorMsg: String?) -> Void,
        onFinish: @escaping (_ errorMsg: String?) -> Void
    ) {
        guard isSupportPlaybackDayDelete else {
            onResponse(IPCLocalizedString(key: "ipc_playback_delete_unsupported_tip"))
            return
        }

        let dayStr = String(format: "%d%02d%02d", date.year, date.month, date.day)

        cameraDevice?.deletePlaybackDataWithDay(dayStr) { errCode in
            let msg = errCode == 0 ? nil : IPCLocalizedString(key: "ipc_playback_delete_fail")
            onResponse(msg)
        } onFinish: { errCode in
            let msg = errCode == 0 ? nil : IPCLocalizedString(key: "ipc_playback_delete_fail")
            onFinish(msg)
        }
    }

    func addDelegate(_ delegate: CameraApplicationEventDelegate & ThingSmartCameraDelegate) {
        self.delegate = delegate
        cameraDevice?.addDelegate(delegate)
        videoView?.videoView = cameraDevice?.videoView
        cameraDevice?.bindVideoRenderView()
    }

    func removeDelegate(_ delegate: CameraApplicationEventDelegate & ThingSmartCameraDelegate) {
        self.delegate = nil
        cameraDevice?.unbindVideoRenderView()
        cameraDevice?.removeDelegate(delegate)
        cameraDevice?.videoView?.thing_clear()
    }

    func destroy() {
        cameraDevice?.disconnect()
        cameraDevice = nil;
    }
}

extension CameraConnectManager {
    private func bindEvents() {
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] noti in
                self?.delegate?.applicationDidEnterBackground()
            }
            .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] noti in
                self?.cameraDevice?.disconnect()
                self?.delegate?.applicationWillEnterForeground()
            }
            .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                self?.audioSessionDidInterruptNotification(notification)
            }
            .store(in: &subscriptions)
    }

    private func audioSessionDidInterruptNotification(_ notification: Notification) {
        if let type = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? Int {
            if type == AVAudioSession.InterruptionType.began.rawValue {
                self.delegate?.applicationDidEnterBackground()
            } else  if type == AVAudioSession.InterruptionType.ended.rawValue {
                self.delegate?.applicationWillEnterForeground()
            }
        }
    }
}
