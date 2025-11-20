//
//  CameraPlaybackViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import ThingCameraUIKit

class CameraPlaybackViewController: CameraPlaybackBaseViewController {
    private lazy var calenderButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(NSLocalizedString("ipc_panel_button_calendar", tableName: "IPCLocalizable"), for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(showCalendar), for: .touchUpInside)
        return button
    }()

    private lazy var timeLineViewContainer = UIView()

    private lazy var timeLineLabel: ThingCameraTimeLabel = {
        let label = ThingCameraTimeLabel()
        label.position = 2
        label.isHidden = true
        label.thing_backgroundColor = .black
        label.textColor = .white
        return label
    }()

    var currentDate: ThingSmartPlaybackDate?
    var timeLineModels: [CameraTimeLineModel] = []
    var playTime: Int?
    var needReconnect: Bool = true

    let connectManager: CameraConnectManager
    private(set) lazy var calendarViewModel = CameraCalendarViewModel()

    private var playBackSpeedMap: [Int: Int] = [:]
    private var fetchSDCardStatusFlag = false
    private let dateFormatter = DateFormatter(format: "MM-dd HH:mm:ss")

    override var tableViewCellType: UITableViewCell.Type {
        UITableViewCell.self
    }

    init(devId: String) {
        connectManager = .init(devId: devId)
        super.init(nibName: nil, bundle: nil)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        connectManager.stopPlayback()
        connectManager.removeDelegate(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = calendarViewModel.currentMonth.monthKey
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: calenderButton)

        setupSubviews()
        fetchSDCardStatus()
        setupCalendar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        connectManager.addDelegate(self)
        videoView.thing_clear()

        guard fetchSDCardStatusFlag else { return }

        retryAction()
        if connectManager.connectState == .connected {
            startPlayback()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        connectManager.removeDelegate(self)
        connectManager.stopPlayback()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissTip()
        stopDownloadingPlayback()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timelineView.frame = timeLineViewContainer.frame
    }

    func enableView(_ enable: Bool) {
        view.isUserInteractionEnabled = enable
        calenderButton.isEnabled = enable
    }

    override func videoViewProvider() -> ThingCameraVideoContainer {
        connectManager.videoView ?? .init()
    }
    
    override func retryAction() {
        enableAllControl(false)
        connectManager.connect()
        showLoading(title: NSLocalizedString("loading", tableName: "IPCLocalizable"))
    }

    override func soundAction() {
        connectManager.toggleMute(for: .playback)
    }

    @objc
    override func recordAction() {
        checkPhotoPermision { [weak self] result in
            guard result, let self else { return }
            connectManager.toggleRecord()
        }
    }

    @objc
    override func pauseAction() {
        connectManager.togglePause()
    }

    @objc
    override func snapshotAction() {
        checkPhotoPermision { [weak self] result in
            guard result else { return }
            self?.connectManager.snapshot()
        }
    }

    private func setupSubviews() {
        view.addSubviews(timeLineViewContainer, timelineView, tableView, timeLineLabel)

        timeLineViewContainer.snp.makeConstraints { make in
            make.top.equalTo(videoContainer.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
        }

        timeLineLabel.snp.makeConstraints { make in
            make.width.equalTo(74)
            make.height.equalTo(22)
            make.centerX.equalToSuperview()
            make.top.equalTo(timeLineViewContainer)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(timeLineViewContainer.snp.bottom)
            make.bottom.equalTo(bottomStackView.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(300)
        }
    }
}

// MARK: - Camera Activities
extension CameraPlaybackViewController {
    func startPlayback() {
        videoView.thing_clear()
        getRecordAndPlay(playbackDate: .init())
    }

    func requestTimeSlice(with date: ThingSmartPlaybackDate?) {
        guard let date else { return }
        let monthKey = "\(date.year)-\(date.month)"
        let days = calendarViewModel.playbackDays[monthKey] ?? []
        guard !days.isEmpty/*, ThingSmartPlaybackDate.isToday(date)*/ else { return }
        connectManager.fetchRecordTimeSlices(date: date)
    }

    private func fetchSDCardStatus() {
        connectManager.fetchSDCardStatus { [weak self] status, error in
            guard let self else { return }

            if [.normal, .memoryLow].contains(status) {
                fetchSDCardStatusFlag = true
                retryAction()
                if connectManager.connectState == .connected {
                    startPlayback()
                }
            } else {
                let message = status?.localizedString ?? IPCLocalizedString(key: "ipc_status_sdcard_format")
                showAlert(withMessage: message) { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            }

            showSuportedPlaybackSpeed()
        }
    }

    private func getRecordAndPlay(_ date: Date? = nil, playbackDate: ThingSmartPlaybackDate? = nil) {
        var playbackDate = playbackDate
        if let date { playbackDate = ThingSmartPlaybackDate(date: date) }
        guard let playbackDate else { return }

        title = "\(playbackDate.year)-\(playbackDate.month)-\(playbackDate.day)"
        currentDate = playbackDate
        showLoading(title: "")
        if calendarViewModel.playbackDays["\(playbackDate.year)-\(playbackDate.month)"] == nil {
            connectManager.queryRecordDays(year: playbackDate.year, month: playbackDate.month)
            return
        }
        requestTimeSlice(with: playbackDate)
    }

    private func playback(withTime playTime: Int, timelineModel: CameraTimeLineModel) {
        showLoading(title: "")
        connectManager.startPlayback(playTime: playTime, timelineModel: timelineModel)
    }

    private func downloadPlaybackVideo(with timelineModel: CameraTimeLineModel) {
        guard connectManager.isSupportPlaybackDownload else {
            showErrorTip(NSLocalizedString("ipc_playback_download_unsupported_tip", tableName: "IPCLocalizable"))
            return
        }

        let filePath = CameraLocalPathUtil.shared.generateRandomLocalPath()
        guard !filePath.isEmpty, let start = timelineModel.startTime, let end = timelineModel.stopTime else { return }
        enableView(false)
        let timeRange = NSMakeRange(start, end - start)
        
        if connectManager.downloadPlayBackVideo(
            range: timeRange,
            filePath: filePath,
            success: { [weak self] filePath in
                self?.dismissTip()
                self?.showSuccessTip(IPCLocalizedString(key: "ipc_playback_download_success"))
                self?.enableView(true)
            }, progress: { [weak self]  progress in
                self?.showProgress(Float(progress) / 100, tip: IPCLocalizedString(key: "ipc_playback_download_progress"))
                if progress == 100 {
                    self?.dismissTip()
                }
            }, failure: { [weak self]  failure in
                self?.showErrorTip(failure?.localizedDescription ?? IPCLocalizedString(key: "ipc_playback_download_fail"))
                self?.enableView(true)
            }
        ) == 0 {
            showProgress(1 / 100, tip: NSLocalizedString("ipc_playback_download_progress", tableName: "IPCLocalizable"))
        }
    }

    private func stopDownloadingPlayback() {
        connectManager.stopDownloadPlaybackVideo { _ in }
    }

    private func deletePlaybackFragements(at indexPath: IndexPath) {
        connectManager.deletePlayback(fragements: [timeLineModels[indexPath.row]]) { [weak self] errorMsg in
            self?.showErrorTip(errorMsg)
        } onFinish: { [weak self] errorMsg in
            if let errorMsg {
                self?.showErrorTip(errorMsg)
                return
            }
            self?.timeLineModels.remove(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            self?.showSuccessTip(IPCLocalizedString(key: "ipc_playback_delete_success"))
        }
    }

    private func deletePlaybackDate(_ date: ThingSmartPlaybackDate) {
        connectManager.deletePlaybackDay(date: date) { [weak self] errorMsg in
            self?.showErrorTip(errorMsg)
        } onFinish: { [weak self] errorMsg in
            if let errorMsg {
                self?.showErrorTip(errorMsg)
                return
            }
            self?.showSuccessTip(IPCLocalizedString(key: "ipc_playback_delete_success"))
        }
    }
}

// MARK: - Calendar
extension CameraPlaybackViewController {
    private func setupCalendar() {
        calendarViewModel.cameraDevice = connectManager.cameraDevice

        calendarViewModel.onSelectDay = { [weak self] date in
            self?.getRecordAndPlay(date)
        }

        calendarViewModel.onSelectMonth = { [weak self] year, month in
            self?.onSelecteMonth(month, in: year)
        }
    }

    private func onSelecteMonth(_ month: Int, in year: Int) {
        showLoading(title: "")
    }

    @objc
    private func showCalendar() {
        calendarViewModel.fetchPlaybackDaysIfNeed()
        CameraCalendarView.show(viewModel: calendarViewModel)
    }
}

// MARK: - tableView
extension CameraPlaybackViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        timeLineModels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let timeLineModel = timeLineModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: tableViewCellType), for: indexPath)

        if let startDate = timeLineModel.startDate, let endDate = timeLineModel.stopDate {
            let startTime = dateFormatter.string(from: startDate)
            let endTime = dateFormatter.string(from: endDate)
            cell.textLabel?.text = "\(startTime) - \(endTime)"
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let timeLineModel = timeLineModels[indexPath.row]
        showAlert(withMessage: NSLocalizedString("ipc_playback_download_confirm_tip", tableName: "IPCLocalizable")) {

        } onConfirm: { [weak self] in
            self?.downloadPlaybackVideo(with: timeLineModel)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        deletePlaybackFragements(at: indexPath)
    }
}

// MARK: - ThingTimelineViewDelegate
extension CameraPlaybackViewController {
    func timelineViewDidScroll(_ timeLineView: ThingTimelineView!, time timeInterval: TimeInterval, isDragging: Bool) {
        timeLineLabel.isHidden = false
        timeLineLabel.timeStr = NSDate.thingsdk_timeString(withTimeInterval: timeInterval, timeZone: NSTimeZone.local)
    }

    func timelineView(_ timeLineView: ThingTimelineView!, didEndScrollingAtTime timeInterval: TimeInterval, in source: (any ThingTimelineViewSource)!) {
        timeLineLabel.isHidden = true
        guard let model = source as? CameraTimeLineModel else { return }
        playback(withTime: Int(timeInterval), timelineModel: model)
    }
}

extension CameraPlaybackViewController {
    private func showSuportedPlaybackSpeed() {
        let supportedSpeeds = connectManager.supportedPlaySpeeds
        guard !supportedSpeeds.isEmpty else { return }

        let message = supportedSpeeds.map {
            UInt($0)
        }.compactMap {
            ThingSmartCameraPlayBackSpeed(rawValue: $0)?.speedTitle
        }.joined(separator: "\n")
        showTips(message)
    }
}

extension CameraPlaybackViewController: CameraApplicationEventDelegate {
    func applicationDidEnterBackground() {
        guard UIApplication.shared.tp_topMostViewController is Self else { return }
        connectManager.stopPlayback()
        if connectManager.isDownloading == true {
            stopDownloadingPlayback()
        }
    }

    func applicationWillEnterForeground() {
        guard UIApplication.shared.tp_topMostViewController is Self else { return }
        retryAction()
    }
}

extension ThingSmartCameraPlayBackSpeed {
    var speedTitle: String? {
        switch self {
        case ._05TIMES:  "0.5x"
        case ._10TIMES:  "1x"
        case ._20TIMES:  "2x"
        case ._40TIMES:  "4x"
        case ._80TIMES:  "8x"
        case ._160TIMES: "16x"
        case ._320TIMES: "32x"
        default: "undefined"
        }
    }
}
