//
//  CameraCruiseViewModel.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import Combine

class CameraCruiseViewModel: ObservableObject {
    @Published var motionDetectionIsOn = false
    @Published var cruiseModeIsOn = false

    @Published var selectedCruiseMode: CameraCruiseMode = .panoramic
    @Published var selectedCruiseTimeMode: CameraCruiseTimeMode = .allDay

    @Published var startTime: Date = .init()
    @Published var endTime: Date = .init()

    @Published var settingsChanged: Bool = false

    let isSupportCruiseTime: Bool
    let isSupportCruiseMode: Bool

    private var currentSettingModel: CameraCruiseSettingItem {
        .init(
            cruiseMode: selectedCruiseMode,
            cruiseTimeMode: selectedCruiseTimeMode,
            startTime: startTime.hmString,
            endTime: endTime.hmString
        )
    }

    private var snapshot = CameraCruiseSettingItem.default
    private var subscriptions = Set<AnyCancellable>()
    private var ptzManager: ThingSmartPTZManager
    private var dpManager: ThingSmartCameraDPManager

    init(devId: String) {
        ptzManager = .init(deviceId: devId)
        dpManager = .init(deviceId: devId)

        isSupportCruiseMode = dpManager.isSupportDPCode(.init(rawValue: "cruise_mode"))
        isSupportCruiseTime = dpManager.isSupportDPCode(.init(rawValue: "cruise_time"))

        fetchStatus()
        bindValueChange()
    }

    func setMotionIsOn(_ isOn: Bool) {
        guard ptzManager.isSupportMotionTracking() else {
            SVProgressHUD.showError(withStatus: IPCLocalizedString(key: "Motion Tracking is unsupported"))
            return
        }

        SVProgressHUD.show()
        ptzManager.setMotionTrackingState(isOn) { [weak self] in
            self?.motionDetectionIsOn.toggle()
            SVProgressHUD.showSuccess(withStatus: IPCLocalizedString(key: "success"))
        } failure: { error in
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }

    func setCruiseIsOn(_ isOn: Bool) {
        guard ptzManager.isSupportCruise() else {
            SVProgressHUD.showError(withStatus: IPCLocalizedString(key: "Cruise Mode  is unsupported"))
            return
        }

        SVProgressHUD.show()
        ptzManager.setCruiseOpen(isOn) { [weak self] _ in
            self?.cruiseModeIsOn.toggle()
            SVProgressHUD.showSuccess(withStatus: IPCLocalizedString(key: "success"))
        } failure: { error in
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }

    func reset() {
        selectedCruiseMode = snapshot.cruiseMode
        selectedCruiseTimeMode = snapshot.cruiseTimeMode
        startTime = Date(from: snapshot.startTime)
        endTime = Date(from: snapshot.endTime)
        settingsChanged = false
    }

    func save() {
        saveCruiseSettings { errors in
            guard !errors.isEmpty else { return }
            var errors = errors
            popErrors()

            func popErrors() {
                let error = errors.removeFirst()
                SVProgressHUD.showError(withStatus: error)
                guard !errors.isEmpty else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    popErrors()
                }
            }
        }
    }

    private func fetchStatus() {
        if ptzManager.isSupportMotionTracking() {
            motionDetectionIsOn = ptzManager.isOpenMotionTracking()
        }

        if ptzManager.isSupportCruise() {
            cruiseModeIsOn = ptzManager.isOpenCruise()

            if cruiseModeIsOn {
                fetchCruiseInfo()
            }
        }
    }

    private func fetchCruiseInfo() {
        let cruiseMode = ptzManager.getCurrentCruiseMode()
        selectedCruiseMode = cruiseMode == .panoramic ? .panoramic : .collectionPoint
        snapshot.cruiseMode = selectedCruiseMode

        let cruiseTimeMode = ptzManager.getCurrentCruiseTimeMode()
        selectedCruiseTimeMode = cruiseTimeMode == .allDay ? .allDay : .custom
        snapshot.cruiseTimeMode = selectedCruiseTimeMode

        if cruiseTimeMode == .custom {
            fetchCruiseTime()
        }
    }

    private func fetchCruiseTime() {
        let timeStr = ptzManager.getCurrentCruiseTime()
        let components = timeStr.components(separatedBy: "-")
        guard components.count == 2 else { return }

        startTime = Date(from: components[0])
        endTime = Date(from: components[1])
        snapshot.startTime = components[0]
        snapshot.endTime = components[1]
    }

    private func saveCruiseSettings(finishWithErrors: @escaping ([String]) -> Void) {
        var errors: [String] = []
        let group = DispatchGroup()

        SVProgressHUD.show()

        if selectedCruiseMode != snapshot.cruiseMode {
            group.enter()
            ptzManager.setCruiseMode(selectedCruiseMode.mode) { _ in
                group.leave()
            } failure: { error in
                if let error {
                    errors.append(IPCLocalizedString(key: "Cruise Mode") + ": \n" + error.localizedDescription)
                }
                group.leave()
            }
        }

        if selectedCruiseTimeMode != snapshot.cruiseTimeMode {
            group.enter()
            ptzManager.setCruiseTimeMode(selectedCruiseTimeMode.mode) {
                group.leave()
            } failure: { error in
                if let error {
                    errors.append(IPCLocalizedString(key: "Cruise Time") + ": \n" + error.localizedDescription)
                }
                group.leave()
            }
        }

        if startTime.hmString != snapshot.startTime || endTime.hmString != snapshot.endTime {
            group.enter()
            ptzManager.setCruiseCustomWithStartTime(startTime.hmString, endTime: endTime.hmString) {
                group.leave()
            } failure: { error in
                if let error {
                    errors.append(IPCLocalizedString(key: "Cruise Time") + ": \n" + error.localizedDescription)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            if errors.isEmpty {
                settingsChanged = false
                snapshot = currentSettingModel
                SVProgressHUD.showSuccess(withStatus: IPCLocalizedString(key: "success"))
                return
            }
            finishWithErrors(errors)
        }
    }

    private func bindValueChange() {
        let publishers = [
            $selectedCruiseMode.map { _ in ()}.eraseToAnyPublisher(),
            $selectedCruiseTimeMode.map { _ in ()}.eraseToAnyPublisher(),
            $startTime.map { _ in ()}.eraseToAnyPublisher(),
            $endTime.map { _ in ()}.eraseToAnyPublisher()
        ].map { $0.dropFirst() }

        Publishers.MergeMany(publishers)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.settingsChanged = self?.currentSettingModel != self?.snapshot
            }
            .store(in: &subscriptions)
    }
}
