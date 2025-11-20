//
//  CameraCloudViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import ThingCameraUIKit

class CameraCloudViewController: CameraPlaybackBaseViewController {
    override var tableViewCellType: UITableViewCell.Type {
        CameraCloudPlaybackEventCell.self
    }

    private lazy var timeLineContainer = UIView()

    private lazy var dayCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: 80, height: 50)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(CameraCloudDayCollectionViewCell.self, forCellWithReuseIdentifier: "cloudDay")
        return collectionView
    }()

    let devId: String

    private lazy var device: ThingSmartDevice? = .init(deviceId: devId)
    private lazy var cloudManager: ThingSmartCloudManager = .init(deviceId: devId)

    private var selectedDay = ThingSmartCloudDayModel()
    private var timePieces = [ThingSmartCloudTimePieceModel]()
    private var eventModels = [ThingSmartCloudTimeEventModel]()

    private var isRecording = false
    private var isPlaying = false

    init(devId: String) {
        self.devId = devId
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        print("-------- CameraCloudViewController deinit --------")
        self.cloudManager.stopPlayCloudVideo()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(demo_withHex: 0xE8E9EF)
        self.title = IPCLocalizedString(key: "ipc_panel_button_storage")

        cloudManager.delegate = self
        checkCloudState()
        getAICloudSettingInfomation()
        enableAIDetect()
        enableAIDetectEventType()
        setupSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timelineView.frame = timeLineContainer.frame
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func videoViewProvider() -> ThingCameraVideoContainer {
        let container = ThingCameraVideoContainer()
        container.videoView = cloudManager.videoView()
        return container
    }

    override func retryAction() {
        enableAllControl(false)
        checkCloudState()
    }

    override func soundAction() {
        let isMute = cloudManager.isMuted()
        cloudManager.enableMute(!isMute) { [weak self] in
            guard let self else { return }
            muteStateDidChanged(to: cloudManager.isMuted())
        } failure: { [weak self] error in
            self?.showErrorTip(IPCLocalizedString(key: "enable mute failed"))
        }
    }

    override func snapshotAction() {
        checkPhotoPermision { [weak self] result in
            if result {
                if let _ = self?.cloudManager.snapShoot() {
                    self?.showTips(IPCLocalizedString(key: "ipc_multi_view_photo_saved"))
                } else {
                    self?.showErrorTip(IPCLocalizedString(key: "fail"))
                }
            }
        }
    }

    override func pauseAction() {
        if isPlaying {
            if cloudManager.pausePlayCloudVideo() == 0 {
                isPlaying = false;
            } else {
                showErrorTip(IPCLocalizedString(key: "fail"))
            }
        } else {
            if cloudManager.resumePlayCloudVideo() == 0 {
                self.isPlaying = true
            } else {
                showErrorTip(IPCLocalizedString(key: "fail"))
            }
        }

        playStateDidChanged(to: isPlaying)
    }

    override func recordAction() {
        checkPhotoPermision { [weak self] result in
            guard let self, result else { return }

            if isRecording {
                isRecording = false
                if cloudManager.stopRecord() == 0 {
                    showTips(IPCLocalizedString(key: "ipc_multi_view_video_saved"))
                } else {
                    showErrorTip(IPCLocalizedString(key: "record failed"))
                }
            } else {
                if cloudManager.startRecord() == 0 {
                    isRecording = true
                }
            }

            recordStateDidChanged(to: isRecording)
        }
    }

    private func setupSubviews() {
        view.addSubviews(dayCollectionView, timeLineContainer, timelineView, tableView)

        dayCollectionView.snp.makeConstraints { make in
            make.top.equalTo(videoContainer.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }

        timeLineContainer.snp.makeConstraints { make in
            make.top.equalTo(dayCollectionView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(74)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(timeLineContainer.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomStackView.snp.top)
        }
    }

    private func checkCloudState() {
        cloudManager.loadCloudData { [weak self] state in
            guard let self else { return }
            switch state {
            case .noService:
                enableAllControl(false)
                gotoCloudServicePanel()
                showTips(IPCLocalizedString(key: "ipc_cloudstorage_status_off"))
                didOccurError()
            case .noData, .expiredNoData:
                enableAllControl(false)
                showTips(IPCLocalizedString(key: "ipc_cloudstorage_noDataTips"))
                didOccurError(IPCLocalizedString(key: "ipc_cloudstorage_noDataTips"), canRetry: false)
                if state == .expiredNoData {
                    showExpiredAlert()
                }
            case .loadFailed:
                enableAllControl(false)
                showErrorTip(IPCLocalizedString(key: "ty_network_error"))
                didOccurError(IPCLocalizedString(key: "ty_network_error"), canRetry: true)
            case .validData:
                loadData()
            case .expiredData:
                loadData()
                showExpiredAlert()
            @unknown default:
                break
            }
        }
    }
}

// MARK: - cloud actions
extension CameraCloudViewController {
    private func loadData() {
        let indexPath = IndexPath(item: cloudManager.cloudDays.count - 1, section: 0)
        dayCollectionView.reloadData()
        dayCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
        loadTimePiece(for: cloudManager.cloudDays.last)
        queryTimelineData(for: cloudManager.cloudDays.last)
    }

    private func loadTimePiece(for day: ThingSmartCloudDayModel?) {
        guard let day else { return }
        selectedDay = day

        cloudManager.timeLine(withCloudDay: day) { [weak self] pieces in
            guard let self, let pieces else { return }
            timePieces = pieces
            timelineView.sourceModels = pieces
            playCloud(piece: pieces.first, playTime: 0)
        } failure: { [weak self] error in
            guard let error else { return }
            self?.didOccurError(IPCLocalizedString(key: "ipc_errormsg_data_load_failed"), canRetry: true)
            self?.showErrorTip(IPCLocalizedString(key: "ipc_errormsg_data_load_failed") + ": " + error.localizedDescription)
        }

        cloudManager.timeEvents(withCloudDay: day, offset: 0, limit: -1) { [weak self] events in
            guard let self, let events else { return }
            eventModels = events
            tableView.reloadData()
        } failure: { [weak self] error in
            guard let error else { return }
            self?.showErrorTip(IPCLocalizedString(key: "ipc_errormsg_data_load_failed") + ": " + error.localizedDescription)
        }
    }

    private func queryTimelineData(for day: ThingSmartCloudDayModel?) {
        guard let day else { return }

        cloudManager.timeEvents(withCloudDay: day, offset: 0, limit: 15, aiCodes: "all") { _ in

        } failure: { _ in

        }
    }

    private func playCloud(piece: ThingSmartCloudTimePieceModel?, playTime: Int) {
        guard let piece else { return }

        var playTime = playTime
        if piece.contains(playTime) {
            playTime = piece.startTime
        }

        cloudManager.playCloudVideo(
            withStartTime: playTime,
            endTime: selectedDay.endTime,
            isEvent: false
        ) { [weak self] errCode in
            if errCode == 0 {
                self?.isPlaying = true
                self?.didLoadSuccess()
            } else {
                self?.showErrorTip(IPCLocalizedString(key: "ipc_status_stream_failed"))
                self?.didOccurError(IPCLocalizedString(key: "ipc_status_stream_failed"), canRetry: true)
            }
        } onFinished: { [weak self] errCode in
            self?.showTips(IPCLocalizedString(key: "ipc_video_end") + (errCode == 0 ? "" : "with error: \(errCode)"))
            self?.didOccurError(IPCLocalizedString(key: "ipc_video_end"), canRetry: false)
        }
    }
    
    private func playCloud(event: ThingSmartCloudTimeEventModel?) {
        guard let event else { return }
        
        cloudManager.playCloudVideo(
            withStartTime: event.startTime,
            endTime: selectedDay.endTime,
            isEvent: true
        ) { [weak self] errCode in
            if errCode == 0 {
                self?.isPlaying = true
                self?.playStateDidChanged(to: true)
                self?.didLoadSuccess()
            } else {
                self?.showErrorTip(IPCLocalizedString(key: "ipc_status_stream_failed"))
                self?.didOccurError(IPCLocalizedString(key: "ipc_status_stream_failed"), canRetry: true)
            }
        } onFinished: { [weak self] _ in
            self?.showTips(IPCLocalizedString(key: "ipc_video_end"))
            self?.didOccurError(IPCLocalizedString(key: "ipc_video_end"), canRetry: false)
        }
    }

    private func getAICloudSettingInfomation() {
        cloudManager.queryAIDetectConfigSuccess { model in
            guard let model else { return }
            print("isAIDevice: \(model.isAiDevice)")
        } failure: { error in
            print("queryAIDetectConfigSuccess failed: \(error!.localizedDescription)")
        }
    }
    
    private func enableAIDetect() {
        cloudManager.enableAIDetect(false) { result in
            print("enableAIDetect to false result: \(result)")
        } failure: { error in
            print("enableAIDetect to false failed: \(error!.localizedDescription)")
        }
    }
    
    private func enableAIDetectEventType() {
        cloudManager.enableAIDetectEventType("ai_human", enable: false) { result in
            print("enableAIDetectEventType to false result: \(result)")
        } failure: { error in
            print("enableAIDetectEventType to false failed: \(error!.localizedDescription)")
        }
    }
    
    private func showExpiredAlert() {
        let alert = UIAlertController(title: "Cloud service expired", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: IPCLocalizedString(key: "action_cancel"), style: .cancel)
        let confirmAction = UIAlertAction(title: IPCLocalizedString(key: "ty_alert_confirm"), style: .default) { [weak self] _ in
            self?.gotoCloudServicePanel()
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true)
    }
}

// MARK: - ThingTimelineViewDelegate
extension CameraCloudViewController {
    func timelineViewWillBeginDragging(_ timeLineView: ThingTimelineView!) {}
    
    func timelineViewDidEndDragging(_ timeLineView: ThingTimelineView!, willDecelerate decelerate: Bool) {}
    
    func timelineViewDidScroll(_ timeLineView: ThingTimelineView!, time timeInterval: TimeInterval, isDragging: Bool) {}
    
    func timelineView(_ timeLineView: ThingTimelineView!, didEndScrollingAtTime timeInterval: TimeInterval, in source: (any ThingTimelineViewSource)!) {
        guard let source = source as? ThingSmartCloudTimePieceModel else { return }
        playCloud(piece: source, playTime: Int(timeInterval))
    }
}

// MARK: - UICollectionView
extension CameraCloudViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cloudManager.cloudDays?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cloudDay", for: indexPath)
        guard let dayCell = cell as? CameraCloudDayCollectionViewCell else { return cell }
        let dayModel = cloudManager.cloudDays[indexPath.row]
        dayCell.text = dayModel.uploadDay
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dayModel = cloudManager.cloudDays[indexPath.row]
        loadTimePiece(for: dayModel)
    }
}

// MARK: Table View
extension CameraCloudViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        eventModels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: tableViewCellType), for: indexPath)
        guard let eventCell = cell as? CameraCloudPlaybackEventCell else { return cell }

        let eventModel = eventModels[indexPath.row]
        eventCell.setupViews(eventModel, encryptKey: cloudManager.encryptKey)
        return eventCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playCloud(event: eventModels[indexPath.row])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        56
    }
}

// MARK: - ThingSmartCloudManagerDelegate
extension CameraCloudViewController: ThingSmartCloudManagerDelegate {
    func cloudManager(_ cloudManager: ThingSmartCloudManager!, didReceivedFrame frameBuffer: CMSampleBuffer!, videoFrameInfo frameInfo: ThingSmartVideoFrameInfo) {
        if TimeInterval(frameInfo.nTimeStamp) != timelineView.currentTime {
            timelineView.currentTime = TimeInterval(frameInfo.nTimeStamp)
        }
    }
}
