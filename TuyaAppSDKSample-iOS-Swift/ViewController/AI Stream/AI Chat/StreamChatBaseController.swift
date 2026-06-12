//
//  StreamChatBaseController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartStreamChannelKit
import ThingSmartStreamBizKit
import IQKeyboardManagerSwift
import SnapKit

/// Base class for AI chat: identity-agnostic AI foundation capabilities
///
/// Includes: stream channel connection and session management, chat events and
/// text/audio/image send & receive, message list and input bar UI skeleton,
/// player/recorder/amplitude waveform, and the various SDK callbacks.
///
/// Identity differences are delegated to subclasses via two customization points:
/// - `makeStreamClient()`: which identity to create the stream channel client with
/// - `agentDeviceId`: the device ID attached when creating a session (nil for App identity)
///
/// Subclasses:
/// - `StreamAppChatController`: App identity
/// - `DeviceAgentChatController`: device agent identity (role card + More menu)
class StreamChatBaseController: UIViewController {

    // MARK: - Public Properties
    /// Home ID (used to query the agentToken)
    let homeId: Int64

    // You need to obtain `solutionCode` and `miniProgramId` first.
    /// Agent solution code (reused when creating a session on this page and entering LiveChat)
    var solutionCode = ""
    /// Mini program ID (reused when creating a session on this page and entering LiveChat)
    var miniProgramId = ""

    init(homeId: Int64) {
        self.homeId = homeId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Subclass Customization Points

    /// Which identity to create the stream channel client with; defaults to App identity, overridden by the device agent subclass
    func makeStreamClient() -> ThingSmartStreamClient? {
        return ThingSmartStreamClient.forApp()
    }

    /// Device ID for the device agent identity (attached when creating a session); nil for App identity
    var agentDeviceId: String? { nil }

    // MARK: - UI (subclasses may adjust constraints)
    lazy var tableView: UITableView = {
        let screenBounds = UIScreen.main.bounds
        var style: UITableView.Style = .grouped
        if #available(iOS 13.0, *) {
            style = .insetGrouped
        }
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: screenBounds.width, height: screenBounds.height), style: style)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    lazy var actionView: StreamActionView = {
        let actionView = StreamActionView(frame: .zero)
        actionView.delegate = self
        return actionView
    }()

    // MARK: - Private Properties
    // Do not use lazy loading (triggering lazy init in deinit creates a weak reference
    // to the deallocating self and crashes); initialize on page entry (viewDidLoad) instead.
    // If you already have complete player/recorder components, you can use your own.
    private var player: ThingStreamPlayer!
    private var recorder: ThingStreamRecorder!
    /// Recording amplitude calculation provided by the SDK (FFT spectrum magnitudes, normalized), drives the input bar recording waveform
    private lazy var amplitudeVisualizer: ThingStreamAmplitudeVisualizer = {
        let visualizer = ThingStreamAmplitudeVisualizer(sampleRate: 16000, bitsPerSample: 16)
        // Number of amplitude bars output per frame
        visualizer.fftSize = 50
        return visualizer
    }()

    private var client: ThingSmartStreamClient?
    private var connectionId: String?
    private var sessionId: String?
    private var eventId: String?

    private var chatInfoDict: [String: StreamChatMessage] = [:]
    private var chatEventIdList: [String] = []
    /// Whether the first appearance has completed (distinguishes "first entry" from "returning from a subpage such as the call page")
    private var hasAppearedOnce = false
    /// Session is being created (prevents duplicate session creation from the connect callback and the connection state callback)
    private var isCreatingSession = false
    /// Currently on the LiveChat call page (this page leaves the shared client's callbacks during the call, and recreates the session on return)
    private var isInLiveChat = false

    // MARK: - Lifecycle
    deinit {
        print("\(type(of: self)) deinit")
        IQKeyboardManager.shared.enable = false

        player?.stop()
        recorder?.stop()
        recorder?.destory()

        client?.remove(self)
        if let sessionId = sessionId {
            client?.closeSession(sessionId, with: .OK, completion: nil)
        }
        client?.destory()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the player/recorder on page entry
        player = ThingStreamPlayer()
        player.delegate = self
        recorder = ThingStreamRecorder(delegate: self)

        chatInfoDict = [:]
        chatEventIdList = []

        title = "AI Stream Chat Demo"
        // Same color as the insetGrouped list, so a top inserted view does not expose a black background around it
        view.backgroundColor = .systemGroupedBackground
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false

        // Real-time AI call entry (subclasses with other buttons can combine via makeRealtimeCallBarButtonItem())
        navigationItem.rightBarButtonItem = makeRealtimeCallBarButtonItem()

        view.addSubview(tableView)
        view.addSubview(actionView)

        // Default layout: the list fills the area above the input bar; subclasses that insert a view at the top can remake the tableView constraints
        tableView.snp.makeConstraints { make in
            make.left.top.right.equalTo(view)
            make.bottom.equalTo(actionView.snp.top)
        }

        // The input bar height adapts to its content (preview/interrupt rows collapse and expand), pinned to the bottom of the screen
        actionView.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
            make.left.right.equalTo(view)
        }

        thingsdk_dispatch_async_on_default_global_thread {
            let config = ThingStreamRecorderExtendConfig.defaultOpus()
            self.recorder.update(config)
            self.recorder.initVoiceDetector()
        }

        // Connect to AI stream server
        connectToStream()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard hasAppearedOnce else {
            hasAppearedOnce = true
            return
        }

        // Returning from the call page or similar: play-while-record on the call page rewrites the shared
        // voice engine (mode/sample rate), and the engine is destroyed on exit; when idle, re-initialize
        // the recording engine with this page's config to avoid starting on leftover state
        if recorder?.isRecording != true, player?.isPlaying != true {
            thingsdk_dispatch_async_on_default_global_thread {
                let config = ThingStreamRecorderExtendConfig.defaultOpus()
                self.recorder.update(config)
                self.recorder.initVoiceDetector()
            }
        }

        if isInLiveChat {
            // Returning from LiveChat: take over the shared client's callbacks again;
            // this page's session may have been closed by the server during the call (unnoticed
            // since this page left the callbacks), so deterministically recreate the session
            isInLiveChat = false
            if let client = client {
                client.remove(self)
                client.add(self)
                if client.isConnected() {
                    recreateSession()
                } else {
                    connectToStream()
                }
            }
        } else if let client = client, !client.isConnected() {
            // When the connection was closed externally or dropped for other reasons, reconnect and recreate the session automatically
            connectToStream()
        } else if sessionId?.isEmpty ?? true {
            // Recreate when the connection is alive but the session has become invalid (e.g., closed by the server)
            createSession()
        }
    }

    // MARK: - Stream Action
    private func connectToStream() {
        // The connection identity is decided by the subclass via makeStreamClient()
        if client == nil {
            client = makeStreamClient()
        }

        guard let client = client else { return }
        // The reconnect path reaches here again; remove first to avoid registering the multicast delegate twice
        client.remove(self)
        client.add(self)

        // If already connected, just create session
        if client.isConnected() {
            connectionId = client.connectionID
            createSession()
            tableView.reloadData()
            return
        }

        // If not connected, connect to the stream server
        client.connect { [weak self] connectionId in
            // connect success, callback connection Id
            self?.connectionId = connectionId
            self?.createSession()
            self?.tableView.reloadData()
        }
    }

    func createSession() {
        // Then, ensure that the channel is connected
        guard let client = client, client.isConnected() else {
            // The client connection is not established yet
            return
        }
        guard !isCreatingSession else { return }

        // After connected, create a session before chat
        if solutionCode.count == 0 || miniProgramId.count == 0 {
            let alert = UIAlertController(title: "Please check", message: "1. Open `StreamChatBaseController.swift` -> config `solutionCode` and `miniProgramId`\n2. select create-session method: `Normal` or `Convenient`", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alert, animated: true)
            return;
        }
        isCreatingSession = true

        // Warnig: please ensure that the `solutionCode`,`miniProgramId` is correct, otherwise the token query will fail.
        let params = ThingStreamQueryAgentTokenParams()
        params.solutionCode = solutionCode // agent id
        params.ownerId = String(homeId) // home id
        params.api = "m.life.ai.token.get"
        params.apiVerion = "1.0"
        var extParams : [String : Any] = [
            "miniProgramId": miniProgramId, // mini app id
            "onlyAsr": false, // only ASR or not
            "needTts": true // need tts or not
        ]
        if let deviceId = agentDeviceId {
            extParams["deviceId"] = deviceId
        }
        params.extParams = extParams

        let tempPath = NSHomeDirectory().appending("/Documents/")

//        // Normal: Request the agent token first and then create the session.
//        //   The `tokenResponse` is valid and reusable for a period of time, if you want create multiple sessions, you can reuse the same token.
//        client.queryAgentToken(params, success: { [weak self] tokenResponse in
//            print("Query agentToken success: \(tokenResponse)")
//            self?.client?.createSession(withToken: tokenResponse, bizTag: 0, reuseDataChannel: false, sessionId: nil, cacheBasePath: tempPath, userData: "") { [weak self] result, error in
//                if let result = result {
//                    self?.sessionId = result.sessionID
//                    self?.tableView.reloadData()
//                    print("Create success: \(result.sessionID)")
//                } else {
//                    print("Create fail: \(String(describing: error))")
//                }
//            }
//        }, failure: { error in
//            print("Query agentToken fail: \(error)")
//        })

        // Convenient: Request the agent token to create a session in one function
        client.createSession(withQueryParams: params, reuseDataChannel: false, cacheBasePath: tempPath, userData: "") { [weak self] result, error in
            self?.isCreatingSession = false
            if let result = result {
                self?.sessionId = result.sessionID
                self?.tableView.reloadData()
                print("Create success: \(result.sessionID)")
            } else {
                print("Create fail: \(String(describing: error))")
            }
        }
    }

    // MARK: - Realtime Call

    /// Real-time AI call entry button (subclasses can combine it with other top-right buttons)
    func makeRealtimeCallBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(title: "LiveChat", style: .plain, target: self, action: #selector(realtimeCallTapped))
    }

    /// Enter the real-time AI call page (connects with the current page's identity, regardless of App / device)
    @objc private func realtimeCallTapped() {
        // First interrupt any unfinished reply and reset the input bar, so the bottom is not stuck in a waiting/playing state on return
        streamActionViewDidClickChatBreak()
        actionView.chatBreakShow(false)
        if player?.isPlaying == true {
            player.stop()
        }
        if recorder?.isRecording == true {
            recorder.stop()
            actionView.resetState()
        }

        // Leave the shared client's multicast callbacks during the call, so this page does not respond to the call's TTS/events (e.g., accidentally starting this page's player)
        isInLiveChat = true
        client?.remove(self)

        // Session parameters (solutionCode / miniProgramId) are passed through from this page to the call page
        let vc = StreamRealtimeCallController(homeId: homeId,
                                              devId: agentDeviceId,
                                              solutionCode: solutionCode,
                                              miniProgramId: miniProgramId)
        navigationController?.pushViewController(vc, animated: true)
    }

    /// Close the current session and recreate it (called by subclasses, e.g., after switching the agent role)
    func recreateSession() {
        if let sessionId = sessionId {
            client?.closeSession(sessionId, with: .closeByClient, completion: nil)
            self.sessionId = nil
            tableView.reloadData()
        }
        createSession()
    }

    // MARK: - Chat Event
    private func sendEventStart(success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        // When the session is not established, no longer return silently; go through the unified failure handling (toast + restore UI)
        guard let client = client, let sessionId = sessionId else {
            failure(NSError(domain: "com.thing.demo", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Session not created. Please tap \"Click to create sessionId\" first"]))
            return
        }

        eventId = nil

        client.sendEventStart(sessionId, userData: nil, success: { [weak self] eventId in
            let chatInfo = self?.createChatInfo(eventId)
            chatInfo?.sendContent = "..."
            self?.eventId = eventId
            self?.tableView.reloadData()
            success(eventId)
        }, failure: { error in
            if let error = error {
                failure(error)
            }
        })
    }

    private func sendEventEnd() {
        guard let client = client, let eventId = eventId, let sessionId = sessionId else { return }

        actionView.resetState()
        client.sendEventEnd(eventId, sessionId: sessionId, userData: nil) { result, error in
            if !result {
                print("Failed to send event end: \(String(describing: error))")
            } else {
                print("Event end sent successfully")
            }
        }
    }

    private func sendChatBreak() {
        guard let client = client, let eventId = eventId, let sessionId = sessionId else { return }
        client.sendEventChatBreak(eventId, sessionId: sessionId, completion: nil)
    }

    // MARK: - Send Text Packet
    private func sendText(_ text: String, sucHandler: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        guard let client = client, let sessionId = sessionId, let eventId = eventId else { return }

        let chatInfo = getChatInfoByEventId(eventId)
        chatInfo?.sendContent = text
        tableView.reloadData()

        let model = ThingStreamTextPacketModel.packet(withText: text, sessionID: sessionId, dataChannel: nil)
        client.sendTextData(model) { result, error in
            if !result {
                if let error = error {
                    failure(error)
                }
                return
            }
            sucHandler()
        }
    }

    // MARK: - Record & Send Audio Packet
    private func sendAudioPacketStart() {
        guard let client = client, let sessionId = sessionId else { return }

        // first packet must have codecType, channels ....
        // If you already have complete player components, you can use your own.
        // Note: this demo recorder use opus.
        let model = self.recorder.firstAudioPacket()
        model.sessionID = sessionId
        client.sendAudioData(model) { [weak self] success, error in
            print("success send audio start: \(String(describing: self?.eventId))")
            if !success {
                self?.actionView.resetState()
                self?.recorder.stop()
            }
        }

        if let selectedImage = actionView.selectedImage {
            sendImage(selectedImage, sucHandler: {
                print("Image sent successfully")
            }, failure: { error in
                print("Failed to send image: \(error)")
            })
        }
    }

    private func sendAudioPacketMiddle(_ voicePacket: ThingStreamAudioPacketModel) {
        guard let client = client, let sessionId = sessionId else { return }

        voicePacket.sessionID = sessionId
        client.sendAudioData(voicePacket) { [weak self] success, error in
            print("success send audio ing: \(String(describing: self?.eventId)), \(voicePacket.payload?.count)")
            if !success {
                self?.actionView.resetState()
                self?.recorder.stop()
            }
        }
    }

    private func sendAudioPacketEnd() {
        guard let client = client, let sessionId = sessionId else { return }

        guard let model = ThingStreamAudioPacketModel.packet(withPayload: nil, sessionID: sessionId, dataChannel: nil, streamFlag: .streamEnd) else { return }
        client.sendAudioData(model) { [weak self] success, error in
            print("success send audio end: \(String(describing: self?.eventId))")
            self?.sendEventEnd()
        }
    }

    // MARK: - Send Image Data Stream
    private func sendImage(_ image: UIImage, sucHandler: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        guard let client = client, let sessionId = sessionId, let eventId = eventId else { return }

        let chatInfo = getChatInfoByEventId(eventId)
        chatInfo?.sendImage = image
        tableView.reloadData()

        // send image, this method will copress image to JPEG format
        guard let model = ThingStreamImagePacketModel.packet(with: image, orFilePath: nil, sessionID: sessionId, dataChannel: nil) else { return }
        client.sendImageData(model, progress: nil) { success, error in
            if !success {
                if let error = error {
                    failure(error)
                }
                return
            }
            sucHandler()
        }
    }

    // MARK: - Private Methods
    private func getChatInfoByEventId(_ eventId: String?) -> StreamChatMessage? {
        guard let eventId = eventId, !eventId.isEmpty else { return nil }
        return chatInfoDict[eventId]
    }

    @discardableResult
    private func createChatInfo(_ eventId: String?) -> StreamChatMessage? {
        guard let eventId = eventId, !eventId.isEmpty else { return nil }

        let chatInfo = StreamChatMessage()
        chatInfo.eventId = eventId
        chatEventIdList.append(eventId)
        chatInfoDict[eventId] = chatInfo
        return chatInfo
    }

    /// On send failure, remove the corresponding local placeholder message so the list returns to its pre-send state
    private func removeChatInfo(eventId: String?) {
        guard let eventId = eventId, !eventId.isEmpty else { return }
        chatInfoDict.removeValue(forKey: eventId)
        chatEventIdList.removeAll { $0 == eventId }
        if self.eventId == eventId {
            self.eventId = nil
        }
        tableView.reloadData()
    }

    @objc func scrollToBottom() {
        tableView.reloadData()

        if let eventId = eventId, let indexRow = chatEventIdList.firstIndex(of: eventId) {
            let indexPath = IndexPath(row: indexRow, section: 1)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension StreamChatBaseController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return chatEventIdList.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        } else if indexPath.section == 1 {
            let eventId = chatEventIdList[indexPath.row]
            if let message = chatInfoDict[eventId] {
                return StreamChatMessageCell.heightForMessage(message, withWidth: tableView.bounds.width)
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Stream Channel State"
        } else if section == 1 {
            return "Chat Messages"
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "connect_info")
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "connect_info")
            }

            if indexPath.row == 0 {
                let status = ["Idle", "Connecting", "Authing", "Connected", "Closed by server", "Closed"]
                let statusText = status[Int(client?.state.rawValue ?? 0)]
                cell?.textLabel?.text = "Connection Status: \(statusText)"
                cell?.detailTextLabel?.text = connectionId ?? "Not Connected"
            } else if indexPath.row == 1 {
                if client?.state != .connected {
                    cell?.textLabel?.text = "Connection is down, please wait connection established"
                    cell?.detailTextLabel?.text = "Session not created"
                } else {
                    cell?.textLabel?.text = (sessionId?.isEmpty ?? true) ? "Click to create sessionId" : "Current sessionId"
                    cell?.detailTextLabel?.text = sessionId ?? "Session not created"
                }
            }
            return cell!
        } else if indexPath.section == 1 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "StreamChatMessageCell") as? StreamChatMessageCell
            if cell == nil {
                cell = StreamChatMessageCell(style: .default, reuseIdentifier: "StreamChatMessageCell")
            }
            let eventId = chatEventIdList[indexPath.row]
            if let message = getChatInfoByEventId(eventId) {
                cell?.configureCellWithMessage(message)
            }
            return cell!
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 && indexPath.row == 1 {
            // Create session
            if sessionId?.isEmpty ?? true {
                createSession()
            }
        }
    }
}

// MARK: - StreamActionViewDelegate
extension StreamChatBaseController: StreamActionViewDelegate {

    // MARK: Pick Image
    func streamActionViewDidClickPickImage() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            self?.presentImagePicker(with: .camera)
        })
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default) { [weak self] _ in
            self?.presentImagePicker(with: .photoLibrary)
        })
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }

    private func presentImagePicker(with sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            let message = sourceType == .camera ? "Camera is not available" : "Album is not available"
            let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: Switch Action
    func streamActionViewDidClickSwitchActionType(_ actionType: StreamActionBtnType) {
        switch actionType {
        case .record:
            // init need almost 300ms ~ 600ms, early init voice detector is recommended.
            // If you already have complete recording components, you can use your own.
            let config = ThingStreamRecorderExtendConfig.defaultOpus()
            recorder.update(config)
            recorder.initVoiceDetector()
        case .textInput:
            actionView.textField.becomeFirstResponder()
        default:
            break
        }
    }

    // MARK: Record Action
    func streamActionViewDidClickRecordButton(_ isStartRecording: Bool) {
        if isStartRecording {
            // If you already have complete recording components, you can use your own.
            let startSuccess = recorder.start()
            if !startSuccess { // start fail
                actionView.resetState()
                SVProgressHUD.showError(withStatus: "Failed to start recording")
                return
            }
            // Send event start & first audio packet format
            sendEventStart(success: { [weak self] eventId in
                // Send first audio packet format
                self?.sendAudioPacketStart()
            }, failure: { [weak self] error in
                print("Failed to start event: \(error)")
                self?.actionView.resetState()
                self?.actionView.chatBreakShow(false)
                self?.recorder.stop()
                SVProgressHUD.showError(withStatus: "Send failed\n\(error.localizedDescription)")
            })
        } else {
            // Stop recording
            recorder.stop()
            sendAudioPacketEnd()
        }
    }

    // MARK: Chat Break
    func streamActionViewDidClickChatBreak() {
        // Send a chat break to actively interrupt (whether sending or receiving is fine)
        guard let client = client, let eventId = eventId, let sessionId = sessionId else { return }

        client.sendEventChatBreak(eventId, sessionId: sessionId) { result, error in
            print("Chat break sent: \(result ? "Success" : "Failed")")
        }

        actionView.resetState()
        getChatInfoByEventId(eventId)?.isBreak = true
        self.eventId = nil
        tableView.reloadData()

        if recorder.isRecording == true { // Stop recorder
            recorder.stop()
        }
        if player.isPlaying == true { // Stop Play
            player.stop()
        }
    }

    // MARK: Send Text Action
    func streamActionViewDidClickSendContent(_ content: String) {
        let image = actionView.selectedImage

        // If any step in the send pipeline fails: show the error, remove the local placeholder message, and restore the input bar to its pre-send state
        let handleSendFailure: (String, Error, String?) -> Void = { [weak self] stage, error, eventId in
            print("Failed to \(stage): \(error)")
            guard let self = self else { return }
            self.removeChatInfo(eventId: eventId)
            self.actionView.restoreAfterSendFailure(content: content, image: image)
            SVProgressHUD.showError(withStatus: "Send failed\n\(error.localizedDescription)")
        }

        sendEventStart(success: { [weak self] eventId in
            self?.sendText(content, sucHandler: {
                if image == nil { // Only has text content, send EventEnd directly
                    self?.sendEventEnd()
                }
            }, failure: { error in
                handleSendFailure("send text", error, eventId)
            })

            guard let image = image else { return }
            // Has a picture, wait picture sent and then send `EventEnd`.
            self?.sendImage(image, sucHandler: {
                self?.sendEventEnd()
            }, failure: { error in
                handleSendFailure("send image", error, eventId)
            })
        }, failure: { error in
            handleSendFailure("start event", error, nil)
        })
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension StreamChatBaseController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage = info[.editedImage] as? UIImage
        if selectedImage == nil {
            selectedImage = info[.originalImage] as? UIImage
        }
        picker.dismiss(animated: true) { [weak self] in
            self?.actionView.showSelectedImage(selectedImage)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - ThingSmartStreamClientDelegate
extension StreamChatBaseController: ThingSmartStreamClientDelegate {

    func streamClient(_ client: ThingSmartStreamClient, connectState: ThingSmartStreamConnectState, error: Error?) {
        if connectState == .connected { // connection is established
            connectionId = client.connectionID
            // After reconnect succeeds (including paths like SDK auto-reconnect that bypass the connect callback), automatically recreate the session if it has become invalid
            if sessionId?.isEmpty ?? true {
                createSession()
            }
        } else if connectState == .closedByServer {
            // connection closed by server
            sessionId = nil
            connectionId = nil
        } else if connectState == .closed {
            // connection closed by self. (User logout / App Background
            sessionId = nil
            connectionId = nil
        }
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }

    func streamClientSessionId(_ sessionID: String, changedSessionState sessionState: ThingSmartStreamSessionState, error: Error?) {
        print("session changed: \(sessionID), \(sessionState.rawValue), \(String(describing: error))")
        if sessionState == .agentTokenExpired {
            sessionId = nil
            tableView.reloadData()

            client?.closeSession(sessionID, with: .closeByClient)

            player.stop()
            recorder.stop()
            actionView.resetState()

            // Token expired, need to query a new `agentToken` and create session again.
            // createSession()
        } else if sessionState == .closedByServer {
            sessionId = nil
            tableView.reloadData()

            player.stop()
            recorder.stop()
            actionView.resetState()

            // Closed by cloud server, If it is necessary to continue using it, then create session again.
            // createSession()
        }
    }

    func streamClientDidReceiveEvent(_ packet: ThingStreamEventPacketModel) {
        if packet.eventType == .start {
            // Handle start event
        } else if packet.eventType == .end {
            actionView.chatBreakShow(false)
            scrollToBottom()
        } else if packet.eventType == .serverVAD {
            print("Server VAD detected")
            recorder.stop()
            actionView.resetState()
            // After server VAD auto-stops recording, also enter the waiting-for-reply state; the right button shows ■ to interrupt
            actionView.chatBreakShow(true)
        }
    }

    func streamClientDidReceiveText(_ packet: ThingStreamTextPacketModel) {
        guard let eventId = eventId, let info = getChatInfoByEventId(eventId) else { return }
        guard let payload = packet.payload else { return }
        // parse json
        guard let textBody = try? JSONSerialization.jsonObject(with: payload, options: .mutableLeaves) as? [String: Any] else { return }
        let bizType = textBody["bizType"] as? String
        let data = textBody["data"] as? [String: Any]

        if bizType == "ASR" { // asr
            let text = data?["text"] as? String
            info.sendContent = text ?? ""
        } else if bizType == "NLG" { // nlg
            let text = data?["content"] as? String ?? ""
            let appendMode = data?["appendMode"] as? String
            if appendMode == "append" {
                info.nlg.append(text)
            } else {
                info.nlg = NSMutableString(string: text)
            }
        } else if bizType == "SKILL" { // skill
            if let skillData = data {
                info.skill = String(data: try! JSONSerialization.data(withJSONObject: skillData), encoding: .utf8) ?? ""
            }
        }

        // refresh message list
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(scrollToBottom), object: nil)
        perform(#selector(scrollToBottom), with: nil, afterDelay: 0.1)
    }

    func streamClientDidReceiveAudio(_ packet: ThingStreamAudioPacketModel) {
        if packet.streamFlag == .streamStart {
            guard let codec = ThingStreamPlayerSupportAudioCodec(rawValue: UInt(packet.codecType.rawValue)) else {
                print("not support this audio codec type: \(packet.codecType)")
                return
            }
            // If you already have complete player components, you can use your own.
            player.configSampleRate(packet.sampleRate, channels: packet.channels, bitDepth: UInt32(packet.bitDepth), codecType: codec)
            player.play()
        }

        if (player.isPlaying) {
            let isLast = packet.streamFlag == .streamEnd
            player.feedData(packet.payload ?? Data(), isLast: isLast)
        }
    }
}

// MARK: - ThingStreamRecorderDelegate
extension StreamChatBaseController: ThingStreamRecorderDelegate {

    func recorderDidRecVoice(_ voiceData: Data) {
        // Callback is on the recording thread: move fft / lazy init to the main thread to avoid data races
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // The SDK's fft output is already normalized and returns a fixed number of bars per fftSize; refresh the waveform with the whole frame directly
            let levels = self.amplitudeVisualizer.fft(voiceData).map { CGFloat($0.doubleValue) }
            guard !levels.isEmpty else { return }
            self.actionView.updateRecordingLevels(levels)
        }
    }

    func recorderDidRecVoicePacket(_ packet: ThingStreamAudioPacketModel) {
        sendAudioPacketMiddle(packet);
    }

    func recorderDidHappendedError(_ error: Error) {
        sendChatBreak()
        recorder.stop()
        print("Recorder encountered an error: \(error)")
    }
}

// MARK: - ThingStreamPlayerDelegate
extension StreamChatBaseController: ThingStreamPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: ThingStreamPlayer) {
        // Handle player finished playing
    }

    func audioPlayer(_ player: ThingStreamPlayer, didEncounterError error: Error) {
        // Handle player error
    }

    func audioPlayerDidStartBuffering(_ player: ThingStreamPlayer) {
        // Handle player start buffering
    }

    func audioPlayerDidStopBuffering(_ player: ThingStreamPlayer) {
        // Handle player stop buffering
    }
}
