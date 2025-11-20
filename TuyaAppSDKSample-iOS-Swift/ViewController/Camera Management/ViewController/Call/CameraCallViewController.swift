//
//  CameraCallViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import ThingSmartCallChannelKit
import ThingSmartMediaUIKit
import Combine

class CameraCallViewController: CameraConnectBaseViewController, ThingSmartCallInterface {
    weak var actionExecuter: (any ThingCallActionExecuter)?

    var callKit: ThingSmartCallKitExecuter {
        get {
            guard let _callKit else { fatalError("callKit not injected") }
            return _callKit
        } set {
            _callKit = newValue
        }
    }

    private var _callKit: ThingSmartCallKitExecuter? = nil

    private lazy var hangupButton: CameraLoadingButton = {
        let button = CameraLoadingButton(type: .custom)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(hangupActionClicked), for: .touchUpInside)
        button.backgroundColor = .red
        button.cornerRadius = 35
        button.translatesAutoresizingMaskIntoConstraints = false
        button.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 70, height: 70))
        }
        return button
    }()

    private lazy var acceptButton: CameraLoadingButton = {
        let button = CameraLoadingButton(type: .custom)
        button.setTitle(NSLocalizedString("Answer", tableName: "IPCLocalizable"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(acceptActionClicked), for: .touchUpInside)
        button.setBackgroundColor(.green, for: .normal)
        button.setBackgroundColor(.gray, for: .disabled)
        button.isEnabled = false
        button.cornerRadius = 35
        button.translatesAutoresizingMaskIntoConstraints = false
        button.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 70, height: 70))
        }
        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [hangupButton, acceptButton])
        stackView.axis = .horizontal
        stackView.spacing = view.width - 140 - 100
        return stackView
    }()

    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.isHidden = true
        return indicator
    }()

    private lazy var videoContainer = UIView(backgroundColor: .black)

    private let localVideoView: UIView & ThingSmartVideoViewType

    private var call: ThingSmartCallProtocol

    private var heavyTasksExecuted: Bool = false

    private var hasCallResponded: Bool = false

    private var warningSound: SystemSoundID?

    private var ringSoundTimer: AnyCancellable?

    required init(call: any ThingSmartCallProtocol) {
        self.call = call
        let localVideoWidth: CGFloat = 100
        let localVideoHeight = localVideoWidth / 9 * 16
        localVideoView = ThingSmartMediaVideoView(frame: .init(x: 0, y: 0, width: localVideoWidth, height: localVideoHeight))
        super.init(devId: call.targetId)

        let soundFilePath = Bundle.main.path(forResource: "demo_ring", ofType: "caf")
        configurateSoundFile(soundFilePath)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopSoundRinging()
        stopPreview()
        callConfigDeinit()

        print(String(describing: Self.self), "--deinit")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - Life circle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !call.outgoing else { return }
        startSoundRinging()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = cameraDevice?.deviceModel.name
        view.backgroundColor = .lightGray

        setupSubviews()

        if !call.outgoing {
            showLoading()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        UIApplication.shared.isIdleTimerDisabled = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopSoundRinging()
    }

    override func applicationDidEnterBackgroundNotification(_ notification: Notification?) {
        guard UIApplication.shared.tp_topMostViewController is Self else { return }
        hangupActionClicked(sender: nil)
        super.applicationDidEnterBackgroundNotification(notification)
    }

    override func applicationWillEnterForegroundNotification(_ notification: Notification?) {
        guard UIApplication.shared.tp_topMostViewController is Self else { return }
        super.applicationWillEnterForegroundNotification(notification)
    }

    private func callConfigInit() {
        cameraDevice?.bindLocalVideoView(localVideoView)
        cameraDevice?.enterCallState()
        executeConnectIfNeeded()
    }

    private func callConfigDeinit() {
        cameraDevice?.unbindLocalVideoView(localVideoView)
        cameraDevice?.leaveCallState()
        cameraDevice?.removeDelegate(self)
    }
}

// MARK: - ThingSmartCallInterface
extension CameraCallViewController {
    func setupCompleted(_ completed: @escaping ((any Error)?) -> Void) {
        if call.outgoing {
            callConfigInit()
            completed(nil)
            return
        }

        let devId = call.targetId
        CameraDemoDeviceFetcher.fetchDevice(withDevId: devId) { [weak self] deviceModel, error in
            guard let _ = CameraDeviceManager.shared.getCameraDevice(devId: devId) else {
                completed(NSError.nonexistentDeviceError())
                return
            }

            self?.callConfigInit()
            completed(nil)
        }
    }

    func executeHeavyTasksCompleted(_ completed: (((any Error)?) -> Void)? = nil) {
        heavyTasksExecuted = true
        executeHeavyTasksIfNeeded()
    }

    func callPeerDidRespond() {
        hasCallResponded = true
        resetOperationButtons()
        executeHeavyTasksIfNeeded()
    }

    /// 通知界面通话结束
    /// - Parameter error: 错误
    func callEndWithError(_ error: (any Error)?) {
        //接听了，断流，断视频，断声音
        if cameraDevice != nil {
            cameraDeviceMuted(true)
            turnLocalCameraOn(false)

            stopAudioTalk()
            stopVideoTalk()
            stopPreview()
        }

        if let error {
            let errorTip = error.localizedDescription.isEmpty
            ? NSLocalizedString("call_call_finish", tableName: "IPCLocalizable")
            : error.localizedDescription
            showTips(errorTip)
        }
    }
}

// MARK: - ThingSmartCameraDelegate
extension CameraCallViewController {
    func cameraDidConnected(_ camera: (any ThingSmartCameraType)!) {
        connectCompleted()
    }

    func cameraDisconnected(_ camera: (any ThingSmartCameraType)!, specificErrorCode errorCode: Int) {
        DispatchQueue.main.async {
            self.refreshOpreationButtonsEnabled()
            self.hangupActionClicked(sender: nil)
        }
    }

    func cameraDidBeginPreview(_ camera: (any ThingSmartCameraType)!) {
        cameraDevice?.getHD()
        stopLoading()
        previewCompleted()
    }

    func cameraDidStopPreview(_ camera: (any ThingSmartCameraType)!) {

    }

    func cameraDidBeginTalk(_ camera: (any ThingSmartCameraType)!) {

    }

    func cameraDidStopTalk(_ camera: (any ThingSmartCameraType)!) {

    }

    func cameraSnapShootSuccess(_ camera: (any ThingSmartCameraType)!) {
        showSuccessTip(NSLocalizedString("ipc_multi_view_photo_saved", tableName: "IPCLocalizable"))
    }

    func camera(_ camera: (any ThingSmartCameraType)!, resolutionDidChangeWidth width: Int, height: Int) {
        cameraDevice?.getDefinition()
    }

    func camera(_ camera: (any ThingSmartCameraType)!, didOccurredErrorAtStep errStepCode: ThingCameraErrorCode, specificErrorCode errorCode: Int) {
        switch errStepCode {
        case Thing_ERROR_CONNECT_FAILED, Thing_ERROR_CONNECT_DISCONNECT:
            stopLoading()
        case Thing_ERROR_START_PREVIEW_FAILED:
            stopLoading()
        case Thing_ERROR_START_TALK_FAILED:
            showErrorTip(NSLocalizedString("ipc_errmsg_mic_failed", tableName: "IPCLocalizable"))
        case Thing_ERROR_SNAPSHOOT_FAILED:
            showErrorTip(NSLocalizedString("fail", tableName: "IPCLocalizable"))
        case Thing_ERROR_RECORD_FAILED:
            showErrorTip(NSLocalizedString("record failed", tableName: "IPCLocalizable"))
        default:
            showErrorTip("an error occurred: \(errStepCode)")
        }
    }
}

// MARK: - button actions
extension CameraCallViewController {
    @objc
    private func hangupActionClicked(sender: UIButton?) {
        stopSoundRinging()
        guard let sender = sender as? CameraLoadingButton else { return }
        sender.startLoading(withEnabled: false)
        if call.outgoing {
            call.answered
            ? actionExecuter?.interface?(self, onHangUp: call)
            : actionExecuter?.interface?(self, onCancel: call)
        } else {
            call.accepted
            ? actionExecuter?.interface?(self, onHangUp: call)
            : actionExecuter?.interface?(self, onReject: call)
        }
        sender.stopLoading(withEnabled: true)
    }

    @objc
    private func acceptActionClicked(sender: UIButton) {
        stopSoundRinging()
        guard let sender = sender as? CameraLoadingButton else { return }
        sender.startLoading(withEnabled: false)
        actionExecuter?.interface?(self, onAccept: call)
        sender.stopLoading(withEnabled: true)
        resetOperationButtons()
    }
}

// MARK: - Operations
extension CameraCallViewController {
    private func executeConnectIfNeeded() {
        if cameraDevice?.cameraModel.connectState == .connected {
            connectCompleted()
        } else if cameraDevice?.cameraModel.connectState == .connecting {

        } else {
            cameraDevice?.connectWithPlayMode(.preview)
        }
    }

    private func executeVideoTalkIfNeeded() {
        if call.end {
            print("[TwoWayCall] %s call had stopped", #function)
            return
        }
        if !hasCallResponded {
            print("[TwoWayCall] %s call has not accepted", #function)
            return
        }
        if !connected {
            print("[TwoWayCall] %s P2P connect is required", #function)
            return
        }
        if videoTalkExecuted {
            print("[TwoWayCall] %s has started video talk", #function)
            return
        }

        cameraDevice?.startVideoTalk()
    }

    private func executeAudioTalkIfNeeded() {
        if call.end {
            print("[TwoWayCall] %s call had stopped", #function)
            return
        }
        if !hasCallResponded {
            print("[TwoWayCall] %s call has not accepted", #function)
            return
        }
        if !connected {
            print("[TwoWayCall] %s P2P connect is required", #function)
            return
        }
        if audioTalkExecuted {
            print("[TwoWayCall] %s has started audio talk", #function)
            return
        }
        checkMicrophonePermision { [weak self] result in
            result
            ? self?.cameraDevice?.startTalk()
            : self?.showErrorTip(NSLocalizedString("Micro permission denied", tableName: "IPCLocalizable"))
        }
    }

    @discardableResult
    private func executePreviewIfNeeded() -> Bool {
        if call.end {
            print("[TwoWayCall] %s call had stopped", #function)
            return false
        }
        if !connectExecuted {
            print("[TwoWayCall] %s P2P connect is required", #function)
            return false
        }
        if previewed {
            previewCompleted()
        }
        cameraDevice?.startPreview()
        return true
    }

    @discardableResult
    private func executeHeavyTasksIfNeeded() -> Bool {
        guard connected, heavyTasksExecuted, hasCallResponded else { return false }
        cameraDeviceMuted(false)
        executeVideoTalkIfNeeded()
        executeAudioTalkIfNeeded()
        return true
    }

    private func connectCompleted() {
        actionExecuter?.interface?(self, onConnected: call)
        turnLocalCameraOn(true)
        executePreviewIfNeeded()
    }

    private func previewCompleted() {
        DispatchQueue.main.async {
            self.refreshOpreationButtonsEnabled()
        }
    }

    private func executeHeavyTasksCompleted() {
        heavyTasksExecuted = true
        executeHeavyTasksIfNeeded()
    }

    private func turnLocalCameraOn(_ isOn: Bool) {
        checkCameraPermision { [weak self] result in
            guard let self, result else {
                self?.showErrorTip(NSLocalizedString("Camera permission denied", tableName: "IPCLocalizable"))
                return
            }
            if isOn {
                executeVideoTalkIfNeeded()
                cameraDevice?.startLocalVideoCapture()
            } else {
                cameraDevice?.stopLocalVideoCapture()
            }
        }
    }

    private func checkCameraPermision(complete: @escaping (Bool) -> Void) {
        if CameraPermissionUtil.cameraNotDetermined {
            CameraPermissionUtil.requestAccessForCamera(result: complete)
            return
        }
        complete(!CameraPermissionUtil.cameraDenied)
    }

    private func checkMicrophonePermision(complete: @escaping (Bool) -> Void) {
        if CameraPermissionUtil.cameraNotDetermined {
            CameraPermissionUtil.requestAccessForMicro(result: complete)
        } else if CameraPermissionUtil.microDenied {
            complete(false)
        } else {
            complete(true)
        }
    }

    private func cameraDeviceMuted(_ isMute: Bool) {
        cameraDevice?.enableMute(isMute, forPlayMode: .preview)
    }

    private func stopAudioTalk() {
        cameraDevice?.stopTalk()
    }

    private func stopVideoTalk() {
        cameraDevice?.stopVideoTalk()
    }

    private func stopPreview() {
        cameraDevice?.stopPreview()
    }
}

// MARK: - Ringing
extension CameraCallViewController {
    @discardableResult
    private func configurateSoundFile(_ filePath: String?) -> Bool {
        guard let filePath, filePath.count != 0 else {
            warningSound = 0
            return false
        }
        let url = URL(fileURLWithPath: filePath)
        var soundId: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url as CFURL, &soundId)
        warningSound = soundId
        return true
    }

    private func startSoundRinging() {
        actionExecuter?.interface?(self, onRing: call)
        guard let warningSound, warningSound > 0 else { return }
        AudioServicesPlayAlertSound(warningSound)
        ringSoundTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.ringSoundTimerAction()
            }
    }

    private func ringSoundTimerAction() {
        guard let warningSound, warningSound > 0 else { return }
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }

    private func stopSoundRinging() {
        if let warningSound, warningSound > 0 {
            AudioServicesDisposeSystemSoundID(warningSound)
            self.warningSound = 0
        }
        ringSoundTimer?.cancel()
        ringSoundTimer = nil
    }
}

// MARK: - state
extension CameraCallViewController {
    private var previewExecuted: Bool {
        [.loading, .previewing].contains(cameraDevice?.cameraModel.previewState)
    }

    private var previewed: Bool {
        cameraDevice?.cameraModel.previewState == .previewing
    }

    private var connectExecuted: Bool {
        [.connecting, .connected].contains(cameraDevice?.cameraModel.connectState)
    }

    private var connected: Bool {
        cameraDevice?.cameraModel.connectState == .connected
    }

    private var videoTalkExecuted: Bool {
        [.executing, .completed].contains(cameraDevice?.cameraModel.videoTalkState)
    }

    private var audioTalkExecuted: Bool {
        cameraDevice?.cameraModel.isTalkLoading ?? false || cameraDevice?.cameraModel.isTalking ?? false
    }
}

// MARK: - UI & layouts
extension CameraCallViewController {
    private func setupSubviews() {
        view.addSubviews(localVideoView, videoContainer, indicatorView, buttonStackView)

        let localVideoWidth = 100
        let localVideoHeight = localVideoWidth / 9 * 16
        localVideoView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.trailing.equalToSuperview().offset(-20)
            make.size.equalTo(CGSize(width: localVideoWidth, height: localVideoHeight))
        }

        let videoHeight = view.width / 16 * 9
        videoContainer.snp.makeConstraints { make in
            make.top.equalTo(localVideoView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(videoHeight)
        }

        if let videoView {
            videoContainer.addSubview(videoView)
            videoView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        indicatorView.snp.makeConstraints { make in
            make.center.equalTo(videoContainer)
        }

        layoutButtons(isDouble: true)
        resetOperationButtons()
    }

    private func showLoading() {
        indicatorView.isHidden = false
        indicatorView.startAnimating()
    }

    private func stopLoading() {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
    }

    private func refreshOpreationButtonsEnabled() {
        acceptButton.isEnabled = previewed
    }

    private func resetOperationButtons() {
        if call.outgoing {
            acceptButton.isHidden = true
            layoutButtons(isDouble: false)
            if call.answered {
                hangupButton.setTitle(NSLocalizedString("Cancel", tableName: "IPCLocalizable"), for: .normal)
            } else {
                hangupButton.setTitle(NSLocalizedString("Hangup", tableName: "IPCLocalizable"), for: .normal)
            }
        } else {
            if !call.accepted {
                acceptButton.isHidden = false
                hangupButton.setTitle(NSLocalizedString("Refuse", tableName: "IPCLocalizable"), for: .normal)
            } else {
                acceptButton.isHidden = true
                hangupButton.setTitle(NSLocalizedString("Hangup", tableName: "IPCLocalizable"), for: .normal)
            }
        }
    }

    private func layoutButtons(isDouble: Bool) {
        if isDouble {
            buttonStackView.snp.remakeConstraints { make in
                make.top.equalTo(videoContainer.snp.bottom).offset(70)
                make.height.equalTo(70)
                make.leading.equalToSuperview().offset(50)
                make.trailing.equalToSuperview().offset(-50)
            }
            return
        }
        buttonStackView.snp.remakeConstraints { make in
            make.size.equalTo(CGSize(width: 70, height: 70))
            make.top.equalTo(videoContainer.snp.bottom).offset(70)
            make.centerX.equalToSuperview()
        }
    }
}
