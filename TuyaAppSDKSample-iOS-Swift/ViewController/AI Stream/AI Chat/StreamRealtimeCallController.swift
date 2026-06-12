//
//  StreamRealtimeCallController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartStreamChannelKit
import ThingSmartStreamBizKit
import SnapKit

/// Real-time AI call page (works for both App / device agent identity, no role management UI)
///
/// Differences from normal chat:
/// - On entering the call, eventStart is sent only once (enabling cloud VAD and auto-interrupt),
///   then audio is pushed continuously; the cloud handles sentence segmentation, replies, and
///   interrupting output on its own. The eventId in response packets is the main eventId with a
///   suffix appended (bizId); ASR / NLG messages of each round are correlated by bizId
/// - Recording does not use local VAD (vadModelPath = nil); playback enables supportPlayWhileRecord to play while recording
///
/// UI: the upper part is the ASR/NLG chat list (same as normal chat);
/// the bottom is the call bar: hang up on the left (close the connection and exit the page),
/// recording amplitude in the middle, mute on the right (stop sending audio to the cloud).
final class StreamRealtimeCallController: UIViewController {

    private let homeId: Int64
    /// If non-empty, connect with the device agent identity; otherwise connect with the App identity
    private let devId: String?

    // Session parameters are passed in from the previous chat page (note: real-time calls require an agent solution that supports cloud VAD / auto-interrupt)
    private let solutionCode: String
    private let miniProgramId: String

    private var client: ThingSmartStreamClient?
    private var player: ThingStreamPlayer!
    private var recorder: ThingStreamRecorder!
    /// Recording amplitude calculation provided by the SDK, drives the call bar waveform
    private lazy var amplitudeVisualizer: ThingStreamAmplitudeVisualizer = {
        let visualizer = ThingStreamAmplitudeVisualizer(sampleRate: 16000, bitsPerSample: 16)
        visualizer.fftSize = 50
        return visualizer
    }()

    private var connectionId: String?
    private var sessionId: String?
    /// Main eventId of the call (eventStart is sent only once on entering the call)
    private var callEventId: String?
    /// Muted: recording continues, but no audio is sent to the cloud
    private var isMuted = false
    /// Hung up / exited; do not resume recording anymore
    private var isCallEnded = false

    private var chatInfoDict: [String: StreamChatMessage] = [:]
    private var chatEventIdList: [String] = []

    // MARK: - UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: UIScreen.main.bounds, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    private let callBar = UIView()
    private let waveformView = StreamWaveformView()
    private let hangupButton = UIButton(type: .system)
    private let muteButton = UIButton(type: .system)
    private let muteLabel = UILabel()

    init(homeId: Int64, devId: String?, solutionCode: String, miniProgramId: String) {
        self.homeId = homeId
        self.devId = devId
        self.solutionCode = solutionCode
        self.miniProgramId = miniProgramId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    deinit {
        print("StreamRealtimeCallController deinit")
        teardownCall()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "LiveChat"
        view.backgroundColor = .systemGroupedBackground

        // Initialize the player/recorder on page entry (recording does not use local VAD; the cloud handles sentence segmentation)
        player = ThingStreamPlayer()
        player.delegate = self
        recorder = ThingStreamRecorder(delegate: self)
        thingsdk_dispatch_async_on_default_global_thread {
            let config = ThingStreamRecorderExtendConfig.defaultOpus()
            config.vadModelPath = nil
            self.recorder.update(config)
            self.recorder.initVoiceDetector()
        }

        setupUI()
        connectToStream()
    }

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(callBar)

        callBar.backgroundColor = .systemBackground
        let topLine = UIView()
        topLine.backgroundColor = .separator
        callBar.addSubview(topLine)

        // Hang up on the left: red round button
        hangupButton.setImage(UIImage(systemName: "phone.down.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)), for: .normal)
        hangupButton.tintColor = .white
        hangupButton.backgroundColor = .systemRed
        hangupButton.layer.cornerRadius = 32
        hangupButton.addTarget(self, action: #selector(hangupTapped), for: .touchUpInside)
        let hangupLabel = UILabel()
        hangupLabel.text = "Hang Up"
        hangupLabel.font = .systemFont(ofSize: 12)
        hangupLabel.textColor = .secondaryLabel
        hangupLabel.textAlignment = .center

        // Mute on the right: recording continues, only stops sending to the cloud
        muteButton.layer.cornerRadius = 32
        muteButton.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        muteLabel.font = .systemFont(ofSize: 12)
        muteLabel.textColor = .secondaryLabel
        muteLabel.textAlignment = .center

        callBar.addSubview(hangupButton)
        callBar.addSubview(hangupLabel)
        callBar.addSubview(muteButton)
        callBar.addSubview(muteLabel)
        callBar.addSubview(waveformView)

        callBar.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view)
        }
        tableView.snp.makeConstraints { make in
            make.left.top.right.equalTo(view)
            make.bottom.equalTo(callBar.snp.top)
        }
        topLine.snp.makeConstraints { make in
            make.top.left.right.equalTo(callBar)
            make.height.equalTo(0.5)
        }
        hangupButton.snp.makeConstraints { make in
            make.left.equalTo(callBar).offset(32)
            make.top.equalTo(callBar).offset(20)
            make.width.height.equalTo(64)
        }
        hangupLabel.snp.makeConstraints { make in
            make.centerX.equalTo(hangupButton)
            make.top.equalTo(hangupButton.snp.bottom).offset(6)
        }
        muteButton.snp.makeConstraints { make in
            make.right.equalTo(callBar).offset(-32)
            make.top.equalTo(callBar).offset(20)
            make.width.height.equalTo(64)
        }
        muteLabel.snp.makeConstraints { make in
            make.centerX.equalTo(muteButton)
            make.top.equalTo(muteButton.snp.bottom).offset(6)
            make.bottom.equalTo(callBar.safeAreaLayoutGuide.snp.bottom).offset(-12)
        }
        // Recording amplitude in the middle
        waveformView.snp.makeConstraints { make in
            make.left.equalTo(hangupButton.snp.right).offset(16)
            make.right.equalTo(muteButton.snp.left).offset(-16)
            make.centerY.equalTo(hangupButton)
            make.height.equalTo(44)
        }

        applyMuteState()
    }

    private func applyMuteState() {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        if isMuted {
            muteButton.setImage(UIImage(systemName: "mic.slash.fill", withConfiguration: config), for: .normal)
            muteButton.tintColor = .white
            muteButton.backgroundColor = .systemOrange
            muteLabel.text = "Muted"
        } else {
            muteButton.setImage(UIImage(systemName: "mic.fill", withConfiguration: config), for: .normal)
            muteButton.tintColor = .label
            muteButton.backgroundColor = .tertiarySystemFill
            muteLabel.text = "Mute"
        }
    }

    // MARK: - Actions

    /// Hang up: end the call, close the connection, and exit the page
    @objc private func hangupTapped() {
        teardownCall()
        navigationController?.popViewController(animated: true)
    }

    /// Mute: stop sending audio to the cloud (recording keeps running); the waveform freezes as a row of minimal dots
    @objc private func muteTapped() {
        isMuted.toggle()
        applyMuteState()
        if isMuted {
            waveformView.update(Array(repeating: 0, count: 50))
        }
    }

    /// Call teardown: stop recording and playback, end the main event, close this page's session
    ///
    /// Note: the ThingSmartStreamClient for the same identity is a shared instance (multicast delegate);
    /// do NOT destory/disconnect here, or it would kill the connection the chat page is still using.
    /// Destroying the connection is the chat page's responsibility in its own deinit.
    private func teardownCall() {
        isCallEnded = true
        player?.stop()
        recorder?.stop()
        recorder?.destory()

        if let client = client {
            client.remove(self)
            if let callEventId = callEventId, let sessionId = sessionId {
                client.sendEventEnd(callEventId, sessionId: sessionId, userData: nil, completion: nil)
            }
            if let sessionId = sessionId {
                client.closeSession(sessionId, with: .OK, completion: nil)
            }
        }
        client = nil
        callEventId = nil
        sessionId = nil
    }

    // MARK: - Connection & Session

    private func connectToStream() {
        if client == nil {
            if let devId = devId, !devId.isEmpty {
                client = ThingSmartStreamClient(forAgentDevice: devId)
            } else {
                client = ThingSmartStreamClient.forApp()
            }
        }

        guard let client = client else { return }
        client.add(self)

        if client.isConnected() {
            connectionId = client.connectionID
            createSession()
            tableView.reloadData()
            return
        }

        client.connect { [weak self] connectionId in
            self?.connectionId = connectionId
            self?.createSession()
            self?.tableView.reloadData()
        }
    }

    private func createSession() {
        guard let client = client, client.isConnected() else { return }

        let params = ThingStreamQueryAgentTokenParams()
        params.solutionCode = solutionCode
        params.ownerId = String(homeId)
        params.api = "m.life.ai.token.get"
        params.apiVerion = "1.0"
        var extParams: [String: Any] = [
            "miniProgramId": miniProgramId,
            "needTts": true,
            "needAsr": true,
        ]
        if let devId = devId, !devId.isEmpty {
            extParams["deviceId"] = devId
        }
        params.extParams = extParams

        let tempPath = NSHomeDirectory().appending("/Documents/")
        client.createSession(withQueryParams: params, reuseDataChannel: false, cacheBasePath: tempPath, userData: "") { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                self.sessionId = result.sessionID
                self.tableView.reloadData()
                print("[RealtimeCall] Create session success: \(result.sessionID)")
                // Start the call as soon as the session is ready
                self.startCall()
            } else {
                print("[RealtimeCall] Create session fail: \(String(describing: error))")
                SVProgressHUD.showError(withStatus: "Failed to create session\n\(error?.localizedDescription ?? "")")
            }
        }
    }

    // MARK: - Call (one eventStart + continuous audio push)

    /// Start the call: send eventStart once (enable cloud VAD / auto-interrupt), then push audio continuously
    private func startCall() {
        guard callEventId == nil, let client = client, let sessionId = sessionId else { return }

        // See the comments in ThingStreamAttribute.h for the chatAttributes format
        let chatAttributes = "{\"chatAttributes\":{\"asr.enableVad\":true,\"processing.interrupt\":true}}"
        client.sendEventStart(sessionId, userData: chatAttributes, success: { [weak self] eventId in
            print("[RealtimeCall] Event start: \(eventId)")
            self?.callEventId = eventId
            self?.startStreamingAudio()
        }, failure: { [weak self] error in
            print("[RealtimeCall] Event start fail: \(String(describing: error))")
            SVProgressHUD.showError(withStatus: "Failed to start call\n\(error?.localizedDescription ?? "")")
        })
    }

    /// Start recording and keep streaming (the cloud handles sentence segmentation and interrupts; recording no longer stops locally)
    private func startStreamingAudio() {
        guard let client = client, let sessionId = sessionId else { return }

        let startSuccess = recorder.start()
        guard startSuccess else {
            SVProgressHUD.showError(withStatus: "Failed to start recording")
            return
        }

        // The first packet must carry the audio format info
        let model = recorder.firstAudioPacket()
        model.sessionID = sessionId
        client.sendAudioData(model) { success, _ in
            print("[RealtimeCall] Send audio start packet: \(success)")
        }
    }
}

// MARK: - ThingStreamRecorderDelegate
extension StreamRealtimeCallController: ThingStreamRecorderDelegate {

    func recorderDidRecVoicePacket(_ packet: ThingStreamAudioPacketModel) {
        // When muted, only stop sending; recording and the waveform continue
        guard !isMuted, let client = client, let sessionId = sessionId else { return }
        packet.sessionID = sessionId
        client.sendAudioData(packet) { success, _ in
            if !success {
                print("[RealtimeCall] Send audio packet failed")
            }
        }
    }

    func recorderDidRecVoice(_ voiceData: Data) {
        // Callback is on the recording thread: move fft and UI updates to the main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // The waveform stays still while muted
            guard !self.isMuted else { return }
            let levels = self.amplitudeVisualizer.fft(voiceData).map { CGFloat($0.doubleValue) }
            guard !levels.isEmpty else { return }
            self.waveformView.update(levels)
        }
    }

    func recorderDidHappendedError(_ error: Error) {
        print("[RealtimeCall] Recorder error: \(error)")
    }
}

// MARK: - ThingSmartStreamClientDelegate
extension StreamRealtimeCallController: ThingSmartStreamClientDelegate {

    func streamClient(_ client: ThingSmartStreamClient, connectState: ThingSmartStreamConnectState, error: Error?) {
        if connectState == .connected {
            connectionId = client.connectionID
        } else {
            sessionId = nil
            connectionId = nil
            callEventId = nil
        }
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }

    func streamClientSessionId(_ sessionID: String, changedSessionState sessionState: ThingSmartStreamSessionState, error: Error?) {
        print("[RealtimeCall] Session changed: \(sessionID), \(sessionState.rawValue)")
        if sessionState == .agentTokenExpired || sessionState == .closedByServer {
            sessionId = nil
            callEventId = nil
            player.stop()
            recorder.stop()
            tableView.reloadData()
        }
    }

    /// The cloud appends a suffix to the main eventId to return each round's response eventId (i.e., the bizId in text response packets)
    func streamClientDidReceiveEvent(_ packet: ThingStreamEventPacketModel) {
        print("[RealtimeCall] Event: \(packet.eventId ?? "-") type: \(packet.eventType.rawValue)")
        if packet.eventType == .end {
            scrollToBottom()
        } else if packet.eventType == .serverVAD {
            print("[RealtimeCall] Server VAD")
        }
    }

    /// Correlate each round's ASR / NLG messages by bizId (the suffixed eventId)
    func streamClientDidReceiveText(_ packet: ThingStreamTextPacketModel) {
        guard let payload = packet.payload,
              let textBody = try? JSONSerialization.jsonObject(with: payload, options: .mutableLeaves) as? [String: Any] else { return }
        let bizType = textBody["bizType"] as? String
        let data = textBody["data"] as? [String: Any]
        guard let bizId = textBody["bizId"] as? String, !bizId.isEmpty else { return }

        if bizType == "ASR" {
            let text = (data?["text"] as? String) ?? ""
            // Do not create a message for empty text; create the round's user message on the first valid ASR
            guard !text.isEmpty else { return }
            let info: StreamChatMessage
            if let exist = chatInfoDict[bizId] {
                info = exist
            } else {
                info = StreamChatMessage()
                info.eventId = bizId
                chatEventIdList.append(bizId)
                chatInfoDict[bizId] = info
            }
            info.sendContent = text
            reloadChatMessages()
        } else if bizType == "NLG" {
            let text = (data?["content"] as? String) ?? ""
            let appendMode = data?["appendMode"] as? String
            // NLG messages are identified by bizId_nlg and inserted right after the round's user message
            let nlgEventId = bizId + "_nlg"
            let nlgMessage: StreamChatMessage
            if let exist = chatInfoDict[nlgEventId] {
                nlgMessage = exist
            } else {
                nlgMessage = StreamChatMessage()
                nlgMessage.eventId = nlgEventId
                if let userIndex = chatEventIdList.firstIndex(of: bizId) {
                    chatEventIdList.insert(nlgEventId, at: userIndex + 1)
                } else {
                    chatEventIdList.append(nlgEventId)
                }
                chatInfoDict[nlgEventId] = nlgMessage
            }
            if appendMode == "append" {
                nlgMessage.nlg.append(text)
            } else if !text.isEmpty {
                nlgMessage.nlg = NSMutableString(string: text)
            }
            reloadChatMessages()
        } else if bizType == "SKILL" {
            if let skillData = data,
               let nlgMessage = chatInfoDict[bizId + "_nlg"],
               let jsonData = try? JSONSerialization.data(withJSONObject: skillData) {
                nlgMessage.skill = String(data: jsonData, encoding: .utf8) ?? ""
                reloadChatMessages()
            }
        }
    }

    func streamClientDidReceiveAudio(_ packet: ThingStreamAudioPacketModel) {
        if packet.streamFlag == .streamStart {
            guard let codec = ThingStreamPlayerSupportAudioCodec(rawValue: UInt(packet.codecType.rawValue)) else {
                print("[RealtimeCall] Unsupported codec: \(packet.codecType)")
                return
            }
            if player.isPlaying {
                player.stop()
            }
            // Play while recording during the call
            player.supportPlayWhileRecord = true
            player.configSampleRate(packet.sampleRate, channels: packet.channels, bitDepth: UInt32(packet.bitDepth), codecType: codec)
            player.play()
            // When the player rebuilds the shared voice engine (ThingStreamVoiceHelper) with the TTS parameters,
            // it also stops the ongoing recording; play() finishes the engine rebuild synchronously, so resume
            // recording immediately here to keep capturing audio during the call (the recording packet callback resamples back to 16k internally)
            resumeRecordingIfNeeded()
        }

        if player.isPlaying {
            let isLast = packet.streamFlag == .streamEnd
            player.feedData(packet.payload ?? Data(), isLast: isLast)
        }
    }

    /// Automatically resume recording after it was stopped by the shared engine rebuild (only if the call is not over and recording is actually not running)
    private func resumeRecordingIfNeeded() {
        guard !isCallEnded, callEventId != nil, recorder?.isRecording == false else { return }
        let success = recorder.start()
        print("[RealtimeCall] Resume recording after voice engine rebuilt: \(success)")
    }
}

// MARK: - ThingStreamPlayerDelegate
extension StreamRealtimeCallController: ThingStreamPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: ThingStreamPlayer) {}

    func audioPlayer(_ player: ThingStreamPlayer, didEncounterError error: Error) {
        print("[RealtimeCall] Player error: \(error)")
    }

    func audioPlayerDidStartBuffering(_ player: ThingStreamPlayer) {}

    func audioPlayerDidStopBuffering(_ player: ThingStreamPlayer) {}
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension StreamRealtimeCallController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : chatEventIdList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        }
        let eventId = chatEventIdList[indexPath.row]
        if let message = chatInfoDict[eventId] {
            return StreamChatMessageCell.heightForMessage(message, withWidth: tableView.bounds.width)
        }
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Realtime Call State" : "Chat Messages"
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "call_info")
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "call_info")
            }
            if indexPath.row == 0 {
                let status = ["Idle", "Connecting", "Authing", "Connected", "Closed by server", "Closed"]
                let statusText = status[Int(client?.state.rawValue ?? 0)]
                cell?.textLabel?.text = "Connection Status: \(statusText)"
                cell?.detailTextLabel?.text = connectionId ?? "Not Connected"
            } else {
                cell?.textLabel?.text = (callEventId?.isEmpty ?? true) ? "Calling not started" : "Current call eventId"
                cell?.detailTextLabel?.text = callEventId ?? (sessionId ?? "Session not created")
            }
            return cell!
        }

        var cell = tableView.dequeueReusableCell(withIdentifier: "StreamChatMessageCell") as? StreamChatMessageCell
        if cell == nil {
            cell = StreamChatMessageCell(style: .default, reuseIdentifier: "StreamChatMessageCell")
        }
        let eventId = chatEventIdList[indexPath.row]
        if let message = chatInfoDict[eventId] {
            cell?.configureCellWithMessage(message)
        }
        return cell!
    }

    // MARK: - Reload & Scroll

    private func reloadChatMessages() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(scrollToBottomOnly), object: nil)
        tableView.reloadData()
        perform(#selector(scrollToBottomOnly), with: nil, afterDelay: 0.1)
    }

    @objc private func scrollToBottomOnly() {
        guard !chatEventIdList.isEmpty else { return }
        let indexPath = IndexPath(row: chatEventIdList.count - 1, section: 1)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    private func scrollToBottom() {
        tableView.reloadData()
        scrollToBottomOnly()
    }
}
