//
//  CameraDoorBellManager.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class CameraDoorBellManager: NSObject {
    static let shared = CameraDoorBellManager()

    private let kDoorbellRingTimeoutMaxInterval = 30

    private var messageId: String?

    private weak var doorbellVC: UIViewController?

    private var timeoutIntervalMap: [String: Int] = [:]

    private override init() {
        super.init()
        setupDoorBellMannager()
    }

    func addDoorbellObserver() {
        ThingSmartDoorBellManager.sharedInstance().add(self)
    }

    func removeDoorbellObserver() {
        ThingSmartDoorBellManager.sharedInstance().remove(self)
    }

    func hangupDoorBellCall() {
        assert(messageId != nil)
        ThingSmartDoorBellManager.sharedInstance().hangupDoorBellCall(messageId)
    }

    func setDoorbellRingTimeoutInterval(_ timeout: Int, ofDevId devId: String?) {
        guard let devId else { return }
        timeoutIntervalMap[devId] = timeout
    }

    func testDoorbellCall() {
        let callModel = ThingSmartDoorBellCallModel()
        callModel.messageId = "123"
        let deviceModel = ThingSmartDeviceModel(deviceID: "6cb9ee7ea7b0e6eb56ollo")
        doorBellCall(callModel, didReceivedFromDevice: deviceModel)
    }

    private func setupDoorBellMannager() {
        let manager = ThingSmartDoorBellManager.sharedInstance()
        manager?.ignoreWhenCalling = true
    }

    private func showAlertWithMessage(_ message: String) {
        let alertVC = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertVC.addAction(.init(title: IPCLocalizedString(key: "ty_smart_scene_pop_know"), style: .cancel))
        UIApplication.shared.tp_topMostViewController?.present(alertVC, animated: true)
    }
}

extension CameraDoorBellManager: ThingSmartDoorBellObserver {
    func doorBellCall(_ callModel: ThingSmartDoorBellCallModel!, didReceivedFromDevice deviceModel: ThingSmartDeviceModel!) {
        messageId = callModel.messageId

        let alertVC = UIAlertController(title: nil, message: IPCLocalizedString(key: "Dollbell is ringing"), preferredStyle: .alert)

        let answerAction = UIAlertAction(title: IPCLocalizedString(key: "Answer"), style: .default) { [weak self] _ in
            let vc = CameraDoorbellViewController(devId: deviceModel.devId)
            vc.modalPresentationStyle = .fullScreen

            assert(self?.messageId != nil)
            ThingSmartDoorBellManager.sharedInstance().answerDoorBellCall(self?.messageId)

            UIApplication.shared.tp_topMostViewController?.present(vc, animated: true)
            self?.doorbellVC = vc
        }

        let hangupAction = UIAlertAction(title: IPCLocalizedString(key: "Hangup"), style: .default) { [weak self] _ in
            assert(self?.messageId != nil)
            ThingSmartDoorBellManager.sharedInstance().hangupDoorBellCall(self?.messageId)
        }

        alertVC.addAction(answerAction)
        alertVC.addAction(hangupAction)
        UIApplication.shared.tp_topMostViewController?.present(alertVC, animated: true)
    }

    func doorBellCallDidRefuse(_ callModel: ThingSmartDoorBellCallModel!) {
        doorbellVC?.dismiss(animated: true) { [weak self] in
            self?.showAlertWithMessage("doorbell call did refuse")
        }
    }

    func doorBellCallDidHangUp(_ callModel: ThingSmartDoorBellCallModel!) {
        doorbellVC?.dismiss(animated: true) { [weak self] in
            self?.showAlertWithMessage("doorbell call did hangup")
        }
    }

    func doorBellCallDidAnswered(byOther callModel: ThingSmartDoorBellCallModel!) {
        doorbellVC?.dismiss(animated: true) { [weak self] in
            self?.showAlertWithMessage("doorbell did answer by other")
        }
    }

    func doorBellCallDidCanceled(_ callModel: ThingSmartDoorBellCallModel!, timeOut isTimeOut: Bool) {
        doorbellVC?.dismiss(animated: true) { [weak self] in
            if isTimeOut {
                self?.showAlertWithMessage(IPCLocalizedString(key: "Dollbell is ringing timeOut"))
                return
            }
            self?.showAlertWithMessage(IPCLocalizedString(key: "The device has canceled doorbell ringing"))
        }
    }
}

extension CameraDoorBellManager: ThingSmartDoorBellConfigDataSource {
    func doorbellRingTimeOut(_ defaultRingTimeOut: Int, withDevId devId: String!) -> Int {
        timeoutIntervalMap[devId] ?? kDoorbellRingTimeoutMaxInterval
    }
}
