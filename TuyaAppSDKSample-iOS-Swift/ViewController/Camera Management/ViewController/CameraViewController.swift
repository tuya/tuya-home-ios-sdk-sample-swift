//
//  CameraViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI
import Combine

class CameraViewController: CameraBaseViewController {
    // MARK: - Video Views
    private var splitVideoViewManager: DemoSplitVideoViewManager?

    private(set) lazy var splitVideoView: CameraSplitVideoContainerView? = {
        splitVideoViewManager?.splitVideoView
    }()

    private lazy var videoView: ThingCameraVideoContainer? = {
        connectManager.videoView
    }()

    private lazy var videoContainer: UIView = {
        let container = UIView()
        container.backgroundColor = .black
        return container
    }()

    private(set) lazy var indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.color = .white
        indicatorView.isHidden = true
        return indicatorView
    }()

    private(set) lazy var soundButton: CameraLoadingButton = {
        let button = CameraLoadingButton(type: .custom)
        (button.normalImageName, button.selectedImageName) = ("ty_camera_soundOff_icon", "ty_camera_soundOn_icon")
        button.addTarget(self, action: #selector(soundAction), for: .touchUpInside)
        return button
    }()

    private(set) lazy var hdButton: CameraLoadingButton = {
        let button = CameraLoadingButton(type: .custom)
        (button.normalImageName, button.selectedImageName) = ("ty_camera_control_sd_normal", "ty_camera_control_hd_normal")
        button.addTarget(self, action: #selector(hdAction), for: .touchUpInside)
        return button
    }()

    private lazy var fullScreenButton: CameraLoadingButton = {
        let button = CameraLoadingButton(type: .custom)
        button.addTarget(self, action: #selector(fullScreenAction), for: .touchUpInside)
        button.setImage(UIImage(named: "demo_camera_control_fullscreen"), for: .normal)
        button.backgroundColor = .black.withAlphaComponent(0.3)
        button.cornerRadius = 6
        button.clipsToBounds = true
        return button
    }()

    private lazy var toolbarFoldingButton: CameraLoadingButton = {
        let button = CameraLoadingButton(type: .custom)
        button.addTarget(self, action: #selector(toolbarFoldingAction), for: .touchUpInside)
        button.setImage(UIImage(named: "demo_camera_toolbar_fold"), for: .normal)
        button.setImage(UIImage(named: "demo_camera_toolbar_unfold"), for: .selected)
        button.backgroundColor = .black.withAlphaComponent(0.3)
        button.cornerRadius = 6
        button.clipsToBounds = true
        return button
    }()

    private lazy var operationToolbar: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 8
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.backgroundColor = .clear
        [soundButton, hdButton, UIView(), fullScreenButton, toolbarFoldingButton]
            .forEach {
                if $0 is CameraLoadingButton {
                    $0.snp.makeConstraints { $0.width.equalTo(44) }
                }
                stack.addArrangedSubview($0)
            }
        return stack
    }()

    private(set) lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.isHidden = true
        return label
    }()

    private(set) lazy var retryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(NSLocalizedString("connect failed, click retry", tableName: "IPCLocalizable", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
        return button
    }()

    private lazy var backPageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .black.withAlphaComponent(0.3)
        button.setImage(UIImage(named: "demo_camera_page_back"), for: .normal)
        button.addTarget(self, action: #selector(backPageAction), for: .touchUpInside)
        button.cornerRadius = 22
        button.clipsToBounds = true
        button.isHidden = true
        return button
    }()

    private(set) lazy var cameraControlViewModel = CameraControlViewModel(
        devId: devId,
        cameraDevice: connectManager.cameraDevice
    )

    private(set) lazy var cameraControlTabView: DemoTabView = {
        let tabViews = [
            AnyView(CameraControlView().environmentObject(cameraControlViewModel)),
            AnyView(CameraPTZControlView(devId: devId)),
            AnyView(CameraCollectionPointListView(devId: devId)),
            AnyView(CameraCruiseView(devId: devId))
        ]

        let tabView = DemoTabView(tabViews: tabViews)
        return tabView
    }()

    private(set) lazy var bottomSwitchView: CameraBottomSwitchView = CameraBottomSwitchView()

    var needsReconnect: Bool = false

    private let devId: String
    private var subscriptions = Set<AnyCancellable>()
    let connectManager: CameraConnectManager

    init(devId: String) {
        self.devId = devId
        connectManager = .init(devId: devId)
        super.init(nibName: nil, bundle: nil)

        needsReconnect = true
        setCameraDeviceOutLineFeatures()

        if let cameraDevice = connectManager.cameraDevice {
            splitVideoViewManager = DemoSplitVideoViewManager(cameraDevice: cameraDevice)
        }
    }

    deinit {
        self.connectManager.destroy()
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = connectManager.cameraDevice?.deviceModel.name
        setupSubviews()
        bindEvents()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        connectManager.addDelegate(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        retryAction()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        connectManager.stopPreview()
        connectManager.removeDelegate(self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        connectManager.stopPreview()
    }

    private func setupSubviews() {
        view.backgroundColor = .white
        layoutVideoView()
        layoutBottomSwitchView()
        layoutTabContentView()
        addRightBarButtonItem()
    }

    private func addRightBarButtonItem() {
        let button = UIBarButtonItem(
            image: UIImage(named: "tp_top_bar_more"),
            style: .plain,
            target: self,
            action: #selector(settingsAction)
        )
        navigationItem.rightBarButtonItem = button
    }
}

// MARK: - Operations
extension CameraViewController {
    func connectCamera() {
        enableAllControls(false)
        connectManager.connect(playMode: .preview)
    }

    private func setCameraDeviceOutLineFeatures() {
        connectManager.setOutOffBoundsEnable(true)

        var outlineProperty = CameraDeviceOutlineProperty()
        outlineProperty.type = 1
        outlineProperty.index = 0
        outlineProperty.rgb = 0x4200c8
        outlineProperty.shape = .full
        outlineProperty.brushWidth = .wide

        var flashFps = CameraDeviceOutlineFlashFps()
        flashFps.drawKeepFrames = .fast
        flashFps.stopKeepFrames = .fast
        outlineProperty.flashFps = flashFps

        connectManager.setOutOffBoundsFeatures([outlineProperty])
    }

    func enableAllControls(_ isEnable: Bool) {
        cameraControlViewModel.enableAllControl(isEnabled: isEnable)
        operationToolbar.arrangedSubviews.forEach {
            if let button = $0 as? UIButton {
                button.isEnabled = isEnable
            }
        }
    }
}

// MARK: - Actions
extension CameraViewController {
    @objc
    private func settingsAction() {
        guard let dpManager = connectManager.cameraDevice?.dpManager else { return }
        //let viewModel = CameraSettingsViewModel(devId: devId, dpManager: dpManager)
        let settingVC = UIHostingController(rootView: CameraSettingsView(withDevId: devId, dpManager: dpManager))
        settingVC.title = IPCLocalizedString(key: "setup")
        UIApplication.shared.tp_navigationController?.pushViewController(settingVC, animated: true)
    }

    @objc
    func retryAction() {
        guard connectManager.isOnline else {
            statusLabel.isHidden = false
            statusLabel.text = NSLocalizedString("title_device_offline", tableName: "IPCLocalizable")
            enableAllControls(false)
            return
        }

        [.connecting, .connected].contains(connectManager.connectState)
        ? connectManager.startPreview() : connectCamera()

        if connectManager.previewState != .previewing {
            showLoadingWithTitle(NSLocalizedString("loading", tableName: "IPCLocalizable"))
            retryButton.isHidden = true
        }
    }

    @objc
    private func soundAction(sender: CameraLoadingButton) {
        sender.startLoading(withEnabled: false)
        connectManager.toggleMute(for: .preview)
    }

    @objc
    private func hdAction(sender: CameraLoadingButton) {
        sender.startLoading(withEnabled: false)
        connectManager.toggleHD()
    }

    @objc
    private func toolbarFoldingAction(sender: CameraLoadingButton) {
        sender.isSelected.toggle()
        videoView?.setVideoScale(1, animated: false)
        splitVideoView?.setToolBarFolding(sender.isSelected)
        cameraControlTabView.resetLayout()
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.setVideoViewFolding()
            self?.view.layoutIfNeeded()
        }
    }

    @objc
    private func fullScreenAction() {
        setFullScreen(true)
    }

    @objc
    private func backPageAction() {
        setFullScreen(false)
    }

    private func setFullScreen(_ isFullScreen: Bool) {
        operationToolbar.isHidden = isFullScreen
        bottomSwitchView.isHidden = isFullScreen
        cameraControlTabView.isHidden = isFullScreen
        backPageButton.isHidden = !isFullScreen
        splitVideoView?.setLandscape(isFullScreen)
        navigationController?.setNavigationBarHidden(isFullScreen, animated: true)
        DemoAppOrientationManager.shared.rotate(to: isFullScreen ? .landscapeRight : .portrait)

        if isFullScreen {
            bottomSwitchView.snp.removeConstraints()
            videoContainer.snp.remakeConstraints { make in
                make.top.leading.equalToSuperview()
                make.width.equalTo(fullScreenVideoWidth)
                make.height.equalTo(fullScreenVideoHeight)
            }
            return
        }

        videoContainer.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.width.equalTo(videoWidth)
            make.height.equalTo(videoHeight)
        }

        layoutBottomSwitchView()
        setVideoViewFolding()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.cameraControlTabView.scrollToTab(self.cameraControlTabView.currentSelection, animated: false)
            self.cameraControlTabView.resetLayout()
        }
    }

    private func setVideoViewFolding() {
        videoContainer.snp.updateConstraints { make in
            make.height.equalTo(videoHeight * (toolbarFoldingButton.isSelected ? 2 : 1))
        }
    }
}

// MARK: - Layouts
extension CameraViewController {
    private func layoutVideoView() {
        view.addSubviews(videoContainer, backPageButton)
        [videoView, splitVideoView, operationToolbar, statusLabel, indicatorView, retryButton]
            .forEach {
                if let subview = $0 { videoContainer.addSubview(subview) }
            }

        videoContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.width.equalTo(videoWidth)
            make.height.equalTo(videoHeight)
        }
        videoView?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        splitVideoView?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        operationToolbar.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.bottom.equalToSuperview().offset(-2)
        }
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(indicatorView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        indicatorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
        }
        retryButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        backPageButton.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(-10)
            make.top.equalTo(10)
            make.width.height.equalTo(44)
        }
    }

    private func layoutBottomSwitchView() {
        view.addSubview(bottomSwitchView)
        bottomSwitchView.snp.makeConstraints { make in
            make.bottom.width.equalToSuperview()
            make.height.equalTo(bottomSwitchViewHeight)
        }
    }

    private func layoutTabContentView() {
        view.addSubview(cameraControlTabView)
        cameraControlTabView.snp.makeConstraints { make in
            make.top.equalTo(videoContainer.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomSwitchView.snp.top)
        }
    }
}

// MARK: - Events
extension CameraViewController {
    private func bindEvents() {
        bottomSwitchView.onSelectTab
            .receive(on: RunLoop.main)
            .sink { [weak self] selection in
                self?.cameraControlTabView.scrollToTab(selection.rawValue, animated: true)
            }
            .store(in: &subscriptions)

        cameraControlTabView.didScrollToTab = { [weak self] tab in
            guard let selection = CameraBottomSwitchView.CameraBottomButtonType(rawValue: tab) else { return }
            self?.bottomSwitchView.setSelection(selection)
        }
    }
}

// MARK: - loading and alert
extension CameraViewController {
    private func showLoadingWithTitle(_ title: String) {
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        statusLabel.isHidden = false
        statusLabel.text = title
    }

    private func stopLoading() {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
        statusLabel.isHidden = true
    }
}

extension CameraViewController: CameraApplicationEventDelegate {
    func applicationDidEnterBackground() {
        guard UIApplication.shared.tp_topMostViewController is Self else { return }
        connectManager.stopPreview()
        connectManager.disconnect()
    }

    func applicationWillEnterForeground() {
        guard UIApplication.shared.tp_topMostViewController is Self else { return }
        retryAction()
    }
}
