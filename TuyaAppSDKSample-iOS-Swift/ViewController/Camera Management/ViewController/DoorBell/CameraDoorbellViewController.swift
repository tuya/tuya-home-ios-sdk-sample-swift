//
//  CameraDoorbellViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class CameraDoorbellViewController: CameraConnectBaseViewController {
    private lazy var videoContainer = UIView(backgroundColor: UIColor.black)

    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.isHidden = true
        return indicator
    }()

    private lazy var stateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton()
        button.setTitle(IPCLocalizedString(key: "connect failed, click retry"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        return button
    }()

    private lazy var hangupButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ty_camera_hangup"), for: .normal)
        button.addTarget(self, action: #selector(hangupAction), for: .touchUpInside)
        return button
    }()

    private lazy var hangupTextButton: UIButton = {
        let button = UIButton()
        button.setTitle(IPCLocalizedString(key: "Hangup"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(hangupAction), for: .touchUpInside)
        return button
    }()

    private var needReconnect = false

    override init(devId: String) {
        super.init(devId: devId)
        needReconnect = true
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("------CameraDoorbellViewController deinit")
        cameraDevice?.stopPreview()
        cameraDevice?.removeDelegate(self)
        cameraDevice?.leaveCallState()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
        cameraDevice?.enterCallState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retryAction()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraDevice?.stopPreview()
    }

    override func applicationWillEnterForegroundNotification(_ notification: Notification?) {
        retryAction()
        super.applicationWillEnterForegroundNotification(notification)
    }

    override func applicationDidEnterBackgroundNotification(_ notification: Notification?) {
        cameraDevice?.stopPreview()
        super.applicationDidEnterBackgroundNotification(notification)
    }

    private func startPreview() {
        guard let videoView else { return }

        cameraDevice?.startPreview()

        if videoView.superview === videoContainer { return }
        videoContainer.addSubview(videoView)
        videoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupSubviews() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .black

        view.addSubviews(videoContainer, hangupButton, hangupTextButton)
        videoContainer.addSubviews(indicatorView, stateLabel, retryButton)

        videoContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(videoHeight)
            make.center.equalToSuperview()
        }

        indicatorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
        }

        stateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        retryButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        hangupButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 80, height: 80))
            make.top.equalTo(videoContainer.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }

        hangupTextButton.snp.makeConstraints { make in
            make.top.equalTo(hangupButton.snp.bottom).offset(5)
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
        }
    }
}

// MARK: - objc methed
extension CameraDoorbellViewController {
    @objc
    private func retryAction() {
        guard let cameraDevice else { return }
        if !cameraDevice.deviceModel.isOnline {
            stateLabel.isHidden = false
            stateLabel.text = IPCLocalizedString(key: "title_device_offline")
            return
        }

        [.connecting, .connected].contains(cameraDevice.cameraModel.connectState)
        ? cameraDevice.startPreview() : cameraDevice.connectWithPlayMode(.preview)

        if cameraDevice.cameraModel.previewState != .previewing {
            showLoadingWithTitle(IPCLocalizedString(key: "loading"))
            retryButton.isHidden = true
        }
    }

    @objc
    private func talkAction() {
        if CameraPermissionUtil.microNotDetermined {
            CameraPermissionUtil.requestAccessForMicro { [weak self] result in
                guard result else { return }
                self?.cameraDevice?.startTalk()
            }
            return
        }

        if CameraPermissionUtil.microDenied {
            showAlert(withMessage: IPCLocalizedString(key: "Micro permission denied"))
            return
        }
        cameraDevice?.startTalk()
    }

    @objc
    private func hangupAction() {
        CameraDoorBellManager.shared.hangupDoorBellCall()
        dismiss(animated: true)
    }
}

// MARK: - ThingSmartCameraDelegate
extension CameraDoorbellViewController {
    func cameraDidConnected(_ camera: (any ThingSmartCameraType)!) {
        startPreview()
    }
    
    func cameraDisconnected(_ camera: (any ThingSmartCameraType)!, specificErrorCode errorCode: Int) {
        if [-3, -105].contains(errorCode) && needReconnect {
            needReconnect = false
            retryAction()
            return
        }
        retryButton.isHidden = false
    }
    
    func cameraDidBeginPreview(_ camera: (any ThingSmartCameraType)!) {
        cameraDevice?.getHD()
        stopLoading()
        cameraDevice?.enableMute(false, forPlayMode: .preview)
        talkAction()
    }
    
    func cameraDidStopPreview(_ camera: (any ThingSmartCameraType)!) {

    }

    func camera(_ camera: (any ThingSmartCameraType)!, didOccurredErrorAtStep errStepCode: ThingCameraErrorCode, specificErrorCode errorCode: Int) {
        switch errStepCode {
        case Thing_ERROR_CONNECT_FAILED, Thing_ERROR_CONNECT_DISCONNECT:
            stopLoading()
            retryButton.isHidden = false
        case Thing_ERROR_START_PLAYBACK_FAILED, Thing_ERROR_QUERY_RECORD_DAY_FAILED, Thing_ERROR_QUERY_EVENTLIST_SIFT_FAILED, Thing_ERROR_QUERY_TIMESLICE_FAILED:
            stopLoading()
            retryButton.isHidden = false
        case Thing_ERROR_START_TALK_FAILED:
            showErrorTip(IPCLocalizedString(key: "ipc_errmsg_mic_failed"))
        default:
            break
        }
    }
}

extension CameraDoorbellViewController: ThingSmartCameraDPObserver {

}

// MARK: - loading and alert
extension CameraDoorbellViewController {
    private func showLoadingWithTitle(_ title: String) {
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        stateLabel.isHidden = false
        stateLabel.text = title
    }

    private func stopLoading() {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
        stateLabel.isHidden = true
    }
}
