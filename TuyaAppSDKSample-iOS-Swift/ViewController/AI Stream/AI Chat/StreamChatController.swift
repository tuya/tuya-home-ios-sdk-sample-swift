//
//  StreamChatController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartStreamChannelKit
import ThingSmartStreamBizKit
import IQKeyboardManagerSwift
import SnapKit

class StreamChatController: UIViewController {
    
    // MARK: - Public Properties
    var devId: String?
    var homeId: Int64 = 0
    
    // MARK: - Private Properties
    private lazy var tableView: UITableView = {
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
    private lazy var actionView: StreamActionView = {
        let screenBounds = UIScreen.main.bounds
        let actionView = StreamActionView(frame: CGRect(x: 0, y: 0, width: screenBounds.width, height: 130))
        actionView.delegate = self
        return actionView
    }()
    // If you already have complete player components, you can use your own.
    private lazy var player: ThingStreamPlayer = {
        let player = ThingStreamPlayer()
        player.delegate = self
        return player
    }()
    // If you already have complete recorder components, you can use your own.
    private lazy var recorder: ThingStreamRecorder = {
        let recorder = ThingStreamRecorder(delegate: self)
        return recorder
    }()
    
    private var sections: [Any] = []
    
    private var client: ThingSmartStreamClient?
    private var connectionId: String?
    private var sessionId: String?
    private var eventId: String?
    
    private var chatInfoDict: [String: StreamChatMessage] = [:]
    private var chatEventIdList: [String] = []
    
    // MARK: - Lifecycle
    deinit {
        print("StreamChatController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatInfoDict = [:]
        chatEventIdList = []
        
        title = "AI Stream Chat Demo"
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        view.addSubview(tableView)
        view.addSubview(actionView)
        
        tableView.snp.makeConstraints { make in
            make.left.top.right.equalTo(view)
            make.bottom.equalTo(view.snp.bottom).offset(-135)
        }
        
        actionView.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
            make.left.right.equalTo(view)
            make.height.equalTo(135)
        }
        
        // Connect to AI stream server
        connectToStream()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = false
        
        player.stop()
        recorder.stop()
        recorder.destory()
        
        client?.remove(self)
        if let sessionId = sessionId {
            client?.closeSession(sessionId, with: .OK, completion: nil)
        }
        client?.destory()
    }
    
    // MARK: - Stream Action
    private func connectToStream() {
        // First, select an identity to connect ai-stream server
        // clent  = ThingSmartStreamClient.init(forAgentDevice: #your_device_id)
        // client = ThingSmartStreamClient.forApp()
        
        if client == nil {
            if let devId = devId, !devId.isEmpty {
                client = ThingSmartStreamClient.init(forAgentDevice: devId)
            } else {
                client = ThingSmartStreamClient.forApp()
            }
        }
        
        guard let client = client else { return }
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
    
    private func createSession() {
        // Then, ensure that the channel is connected
        guard let client = client, client.isConnected() else {
            // The client connection is not established yet
            return
        }
        
        // After connected, create a session before chat
        
        // Warnig: please ensure that the `solutionCode`,`miniProgramId` is correct, otherwise the token query will fail.
        let params = ThingStreamQueryAgentTokenParams()
        params.solutionCode = "your_agent_id"; // agent id
        params.ownerId = String(homeId) // home id
        params.api = "m.life.ai.token.get"
        params.apiVerion = "1.0"
        params.extParams = [
//            "miniProgramId": "your_mini_app_id",
            "onlyAsr": false, // only ASR or not
            "needTts": false // need tts or not
        ];

//        // Normal: Request the agent token first and then create the session.
//        //   The `tokenResponse` is valid and reusable for a period of time, if you want create multiple sessions, you can reuse the same token.
//        client.queryAgentToken(params, success: { [weak self] tokenResponse in
//            print("Query agentToken success: \(tokenResponse)")
//            let tempPath = NSHomeDirectory().appending("/Documents/")
//            self?.client?.createSession(withToken: tokenResponse, bizTag: 0, reuseDataChannel: false, sessionId: nil, cacheBasePath: tempPath, userDatas: []) { [weak self] result, error in
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

//        // Convenient: Request the agent token to create a session in one function
//        client.createSession(withQueryParams: params, reuseDataChannel: false, cacheBasePath: nil, userDatas: nil) { result, error in
//            if let result = result {
//                print("Create success: \(result.sessionID)")
//            } else {
//                print("Create fail: \(String(describing: error))")
//            }
//        }
    }
    
    // MARK: - Chat Event
    private func sendEventStart(success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        guard let client = client, let sessionId = sessionId else { return }
        
        eventId = nil
        
        client.sendEventStart(sessionId, userDatas: nil, success: { [weak self] eventId in
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
        client.sendEventEnd(eventId, sessionId: sessionId, userDatas: nil) { result, error in
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
        client.sendTextData(model) { [weak self] result, error in
            if !result {
                if let error = error {
                    failure(error)
                }
                return
            }
            self?.client?.sendEventPayloadsEnd(eventId, sessionId: sessionId, dataChannel: "text", userDatas: nil) { result, error in
                if !result {
                    if let error = error {
                        failure(error)
                    }
                    return
                }
                sucHandler()
            }
        }
    }
    
    // MARK: - Record & Send Audio Packet
    private func sendAudioPacketStart() {
        guard let client = client, let sessionId = sessionId else { return }
        
        // first packet must have codecType, channels ....
        // If you already have complete player components, you can use your own.
        // Note: this demo recorder only supports PCM, mono, 16bit, 16000Hz audio format, so we can hardcode these values.
        guard let model = ThingStreamAudioPacketModel.packet(withPayload: nil, sessionID: sessionId, dataChannel: nil, streamFlag: .streamStart, codecType: .PCM, channels: .mono, sampleRate: 16000, bitDepth: 16) else { return }
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
    
    private func sendAudioPacketMiddle(_ voiceData: Data) {
        guard let client = client, let sessionId = sessionId else { return }
        
        guard let model = ThingStreamAudioPacketModel.packet(withPayload: voiceData, sessionID: sessionId, dataChannel: nil, streamFlag: .streaming) else { return }
        client.sendAudioData(model) { [weak self] success, error in
            print("success send audio ing: \(String(describing: self?.eventId)), \(voiceData.count)")
            if !success {
                self?.actionView.resetState()
                self?.recorder.stop()
            }
        }
    }
    
    private func sendAudioPacketEnd() {
        guard let client = client, let sessionId = sessionId, let eventId = eventId else { return }
        
        guard let model = ThingStreamAudioPacketModel.packet(withPayload: nil, sessionID: sessionId, dataChannel: nil, streamFlag: .streamEnd) else { return }
        client.sendAudioData(model) { [weak self] success, error in
            print("success send audio end: \(String(describing: self?.eventId))")
            self?.client?.sendEventPayloadsEnd(eventId, sessionId: sessionId, dataChannel: "audio", userDatas: nil, completion: nil)
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
        client.sendImageData(model, progress: nil) { [weak self] success, error in
            if !success {
                if let error = error {
                    failure(error)
                }
                return
            }
            self?.client?.sendEventPayloadsEnd(eventId, sessionId: sessionId, dataChannel: "image", userDatas: nil) { success, error in
                if !success {
                    if let error = error {
                        failure(error)
                    }
                    return
                }
                sucHandler()
            }
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
    
    @objc func scrollToBottom() {
        tableView.reloadData()
        
        if let eventId = eventId, let indexRow = chatEventIdList.firstIndex(of: eventId) {
            let indexPath = IndexPath(row: indexRow, section: 1)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension StreamChatController: UITableViewDelegate, UITableViewDataSource {
    
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
extension StreamChatController: StreamActionViewDelegate {
    
    // MARK: Pick Image
    func streamActionViewDidClickPickImage() {
        let actionSheet = UIAlertController(title: nil, message: "Pick Image", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            self?.presentImagePicker(with: .camera)
        })
        actionSheet.addAction(UIAlertAction(title: "Select Image", style: .default) { [weak self] _ in
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
                return
            }
            // Send event start & first audio packet format
            sendEventStart(success: { [weak self] eventId in
                // Send first audio packet format
                self?.sendAudioPacketStart()
            }, failure: { [weak self] error in
                print("Failed to start event: \(error)")
                self?.actionView.resetState()
                self?.recorder.stop()
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
        sendEventStart(success: { [weak self] eventId in
            self?.sendText(content, sucHandler: {
                if image == nil { // Only has text content, send EventEnd directly
                    self?.sendEventEnd()
                }
            }, failure: { error in
                print("Failed to send text: \(error)")
                self?.actionView.resetState()
            })
            
            guard let image = image else { return }
            // Has a picture, wait picture sent and then send `EventEnd`.
            self?.sendImage(image, sucHandler: {
                self?.sendEventEnd()
            }, failure: { error in
                print("Failed to send image: \(error)")
                self?.actionView.resetState()
            })
        }, failure: { [weak self] error in
            print("Failed to start event: \(error)")
            self?.actionView.resetState()
        })
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension StreamChatController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
extension StreamChatController: ThingSmartStreamClientDelegate {
    
    func streamClient(_ client: ThingSmartStreamClient, connectState: ThingSmartStreamConnectState, error: Error?) {
        if connectState == .connected { // connection is established
            connectionId = client.connectionID
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
            if packet.codecType != .PCM {
                print("Unsupported audio codec type: \(packet.codecType)")
                return
            }
            // If you already have complete player components, you can use your own.
            // Note: this demo player now only supports PCM, mono, 16bit, 16000Hz audio format.
            player.configSampleRate(packet.sampleRate, channels: packet.channels, bitDepth: UInt32(packet.bitDepth), codecType: .PCM)
            player.play()
        }
        
        if (player.isPlaying) {
            let isLast = packet.streamFlag == .streamEnd
            player.feedData(packet.payload ?? Data(), isLast: isLast)
        }
    }
}

// MARK: - ThingStreamRecorderDelegate
extension StreamChatController: ThingStreamRecorderDelegate {
    
    func recorderDidRecVoice(_ voiceData: Data) {
        sendAudioPacketMiddle(voiceData)
    }
    
    func recorderDidHappendedError(_ error: Error) {
        sendChatBreak()
        recorder.stop()
        print("Recorder encountered an error: \(error)")
    }
}

// MARK: - ThingStreamPlayerDelegate
extension StreamChatController: ThingStreamPlayerDelegate {
    
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
