//
//  CameraMessageViewModel.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import Combine

class CameraMessageViewModel: ObservableObject {
    @Published var selection: Int = 0
    @Published var messageTypes = [ThingSmartCameraMessageSchemeModel]()
    @Published var messageModeList = [String: [ThingSmartCameraMessageModel]]()
    @Published var isLoading = true

    private let messageManager: ThingSmartCameraMessage

    private let dateFormatter = DateFormatter()
    private var startTime: TimeInterval = .zero
    private var subscription: AnyCancellable?

    init(devId: String) {
        messageManager = ThingSmartCameraMessage(deviceId: devId, timeZone: NSTimeZone.default)

        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let startTime = dateFormatter.date(from: "2019-09-17")?.timeIntervalSince1970 {
            self.startTime = startTime
        }

        fetchTypes()

        subscription = $selection
            .receive(on: RunLoop.main)
            .sink { [weak self] selection in
                guard let self, !messageTypes.isEmpty else { return }
                fetchMessages(by: messageTypes[selection])
            }
    }

    private func fetchMessages(by type: ThingSmartCameraMessageSchemeModel) {
        guard messageModeList[type.describe] == nil else { return }

        isLoading = true
        messageManager.messages(
            withMessageCodes: type.msgCodes,
            offset: 0,
            limit: 20,
            startTime: Int(startTime),
            endTime: Int(Date().timeIntervalSince1970)
        ) { [weak self] messages in
            self?.messageModeList[type.describe] = messages
            self?.isLoading = false
        } failure: { [weak self] error in
            self?.isLoading = false
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }

    private func fetchTypes() {
        messageManager.getSchemes { [weak self] types in
            self?.messageTypes = types ?? []
            guard let types else { return }
            self?.fetchMessages(by: types[0])
        } failure: { error in
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }
}
