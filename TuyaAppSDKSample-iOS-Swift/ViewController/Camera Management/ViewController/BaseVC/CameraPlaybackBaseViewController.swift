//
//  CameraPlaybackBaseViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import ThingCameraUIKit

class CameraPlaybackBaseViewController: CameraBaseViewController {
    final private(set) lazy var timelineView: ThingTimelineView = {
        let isLocalPlayback = self is CameraPlaybackViewController
        let timelineView = ThingTimelineView()
        timelineView.timeHeaderHeight = 24
        timelineView.showShortMark = true
        timelineView.spacePerUnit = 90
        timelineView.timeTextTop = 6
        timelineView.delegate = self
        timelineView.backgroundGradientColors = []
        timelineView.contentGradientColors = [(0x4f67ee, 0.62), (0x4d67ff, 0.09)].map {
            UIColor(demo_withHex: $0.0, alpha: $0.1).cgColor
        }
        timelineView.contentGradientLocations = [0.0, 1.0]
        timelineView.tickMarkColor = UIColor.black.withAlphaComponent(0.1)
        timelineView.timeZone = NSTimeZone.local
        timelineView.backgroundColor = isLocalPlayback ? UIColor(demo_withHex: 0xf5f5f5) : .white
        timelineView.timeStringAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 9),
            NSAttributedString.Key.foregroundColor: isLocalPlayback ? UIColor(demo_withHex: 0x999999) : .init(demo_withHex: 0x333300)
        ]
        if (!isLocalPlayback) {
            timelineView.selectionTimeBackgroundColor = .black
            timelineView.selectionTimeTextColor = .white
        }
        return timelineView
    }()

    final private(set) lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(tableViewCellType, forCellReuseIdentifier: String(describing: tableViewCellType))
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()

    final private(set) lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [photoButton, pauseButton, recordButton])
        stackView.axis = .horizontal
        return stackView
    }()

    final private(set) lazy var videoContainer: UIView = .init()

    final private(set) lazy var videoView: ThingCameraVideoContainer = {
        videoViewProvider()
    }()

    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.color = .white
        indicatorView.isHidden = false
        return indicatorView
    }()

    private lazy var stateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.isHidden = true
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("connect failed, click retry", tableName: "IPCLocalizable"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        button.addTarget(self, action: #selector(hideButton(sender: )), for: .touchUpInside)
        return button
    }()

    private lazy var soundButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ty_camera_soundOff_icon"), for: .normal)
        button.setImage(UIImage(named: "ty_camera_soundOn_icon"), for: .selected)
        button.addTarget(self, action: #selector(soundAction), for: .touchUpInside)
        return button
    }()

    private lazy var photoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ty_camera_photo_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(snapshotAction), for: .touchUpInside)
        button.snp.makeConstraints { $0.width.equalTo(videoWidth / 3) }
        return button
    }()

    private lazy var recordButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ty_camera_rec_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(recordAction), for: .touchUpInside)
        button.snp.makeConstraints { $0.width.equalTo(videoWidth / 3) }
        return button
    }()

    private lazy var pauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ty_camera_tool_pause_normal")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setImage(UIImage(named: "ty_camera_tool_play_normal")?.withRenderingMode(.alwaysTemplate), for: .selected)
        button.tintColor = .black
        button.addTarget(self, action: #selector(pauseAction), for: .touchUpInside)
        button.snp.makeConstraints { $0.width.equalTo(videoWidth / 3) }
        return button
    }()

    var tableViewCellType: UITableViewCell.Type {
        fatalError("subclasses must override this property")
    }

    func videoViewProvider() -> ThingCameraVideoContainer {
        fatalError("subclasses must override this method")
    }

    @objc
    func retryAction() {
        fatalError("subclasses must override this method")
    }

    @objc
    func soundAction() {
        fatalError("subclasses must override this method")
    }

    @objc
    func snapshotAction() {
        fatalError("subclasses must override this method")
    }

    @objc
    func recordAction() {
        fatalError("subclasses must override this method")
    }

    @objc
    func pauseAction() {
        fatalError("subclasses must override this method")
    }

    @objc
    private func hideButton(sender: UIButton) {
        sender.isHidden = true
    }

    final func checkPhotoPermision(completion: @escaping (Bool) -> Void) {
        if CameraPermissionUtil.isPhotoLibraryNotDetermined {
            CameraPermissionUtil.requestPhotoPermission(result: completion)
        } else if CameraPermissionUtil.isPhotoLibraryDenied {
            showAlert(withMessage: NSLocalizedString("Photo library permission denied", tableName: "IPCLocalizable"))
            completion(false)
            return
        }
        completion(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        indicatorView.startAnimating()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .black
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = .systemBlue
    }

    private func setupSubviews() {
        view.addSubviews(videoContainer, bottomStackView)
        videoContainer.addSubviews(videoView, soundButton, indicatorView, stateLabel, retryButton)
        videoContainer.backgroundColor = .black

        videoContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(videoHeight)
        }

        self.videoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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

        soundButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 44, height: 44))
            make.leading.equalTo(8)
            make.bottom.equalTo(-8)
        }

        bottomStackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
    }
}

// MARK: UI updates
extension CameraPlaybackBaseViewController {
    final func didStartPlayback() {
        stateLabel.isHidden = true
        retryButton.isHidden = true
        indicatorView.isHidden = true
        indicatorView.stopAnimating()
    }

    final func muteStateDidChanged(to isMute: Bool) {
        soundButton.isSelected = !isMute
    }

    final func playStateDidChanged(to isPlaying: Bool) {
        pauseButton.isSelected = !isPlaying
        recordButton.isEnabled = isPlaying
    }

    final func recordStateDidChanged(to isRecording: Bool) {
        let isLocalPlayback = self is CameraPlaybackViewController
        let recordingColor: UIColor = isLocalPlayback ? .blue : .red
        recordButton.tintColor = isRecording ? recordingColor : .black
        pauseButton.isEnabled = !isRecording
    }

    final func enableAllControl(_ enable: Bool) {
        [soundButton, photoButton, pauseButton, recordButton].forEach {
            $0.isEnabled = enable
        }
    }

    final func showLoading(title: String) {
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        stateLabel.isHidden = false
        stateLabel.text = title
    }

    final func didOccurError(_ error: String? = nil, canRetry: Bool = true) {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
        retryButton.isHidden = !canRetry

        if let error, error.isEmpty {
            stateLabel.isHidden = true
            return
        }

        stateLabel.isHidden = false
        stateLabel.text = error
    }

    final func didLoadSuccess() {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
        retryButton.isHidden = true
        stateLabel.isHidden = true
    }
}

extension CameraPlaybackBaseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError()
    }
}

// MARK: - ThingTimelineViewDelegate
extension CameraPlaybackBaseViewController: ThingTimelineViewDelegate {}
