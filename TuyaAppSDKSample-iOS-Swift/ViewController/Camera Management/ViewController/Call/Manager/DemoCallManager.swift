//
//  DemoCallManager.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import ThingSmartCallChannelKit

extension DemoCallManager {
    /// call after ThingSmartSDK start
    static func launchTwowayCallService() {
        ThingSmartCallChannel.sharedInstance.launch()
        shared.callServiceDidLaunch()
    }
}

class DemoCallManager: NSObject {
    static let shared = DemoCallManager()

    var canStartCall: Bool {
        !isCalling
    }

    var isCalling: Bool {
        ThingSmartCallChannel.sharedInstance.isOnCalling()
    }

    private let interfaceManager: CameraCallInterfaceManager

    private override init() {
        interfaceManager = CameraCallInterfaceManager()
        interfaceManager.identifier = .screenIPCIdentifier
        super.init()

        configurateCallSDK()
    }

    func callServiceDidLaunch() {
        print("[Two way call] call service launch success")
    }

    func startCall(
        with targetId: String,
        timeout: Int,
        extra: [String: Any],
        success: @escaping () -> Void,
        failure: @escaping (Error?) -> ()
    ) {
        ThingSmartCallChannel.sharedInstance.startCall(
            withTargetId: targetId,
            timeout: timeout,
            extra: extra,
            success: success,
            failure: failure
        )
    }

    func fetchDeviceCallAbility(by devId: String, completion: @escaping (Bool, Error?) -> Void) {
        ThingSmartCallChannel.sharedInstance.fetchDeviceCallAbility(byDevId: devId, completion: completion)
    }

    // MARK: - 处理voip/push消息
    func handlePushMessageHandle(_ message: [String: Any]) {
        ThingSmartCallChannel.sharedInstance.handlePushMessage(message)
    }

    private func configurateCallSDK() {
        ThingSmartCallChannel.sharedInstance.dataSource = self
        ThingSmartCallChannel.sharedInstance.add(self)
        ThingSmartCallChannel.sharedInstance.registerCallInterfaceManager(interfaceManager)
    }
}

extension DemoCallManager: ThingSmartCallChannelDelegate {
    func callChannel(_ callChannel: ThingSmartCallChannel, didReceiveInvalidPushCall call: any ThingSmartCallProtocol, error: any Error) {
        if call.targetId.isEmpty {
            print("The call is invalid")
        }
    }

    func callChannel(_ callChannel: ThingSmartCallChannel, didReceiveInvalidCall call: any ThingSmartCallProtocol, error: any Error) {
        if (error as NSError).code == ThingSmartCallError.onCalling.rawValue {
            print("channel is on calling")
        }
    }
}

extension DemoCallManager: ThingSmartCallChannelDataSource {
    func callKitExecuter() -> (any ThingSmartCallKitExecuter)? {
        nil
    }
}
