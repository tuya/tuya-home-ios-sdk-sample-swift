//
//  CameraSettingsViewModel.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import ThingSmartUtil
import SwiftUI

class CameraSettingsViewModel: ObservableObject {
    @Published var settingData: [CameraSettingSection]

    private let device: ThingSmartDevice?
    private let dpManager: ThingSmartCameraDPManager

    private var dpSectionMap: [ThingSmartCameraDPKey: Section] = [:]

    private static var kOutOffBoundsDPCode: ThingSmartCameraDPKey {
        "out_off_bounds" as NSString as ThingSmartCameraDPKey
    }

    private static var kOutOffBoundsSetDPCode: ThingSmartCameraDPKey {
        "out_off_bounds_set" as NSString as ThingSmartCameraDPKey
    }

    private typealias Section = CameraSettingSection.Section
    private typealias Setting = CameraSettingSection.CameraSettingItem

    // 临时变量，避免每次append触发视图刷新
    private lazy var fetchedData: [CameraSettingSection] = settingData

    init(devId: String, dpManager: ThingSmartCameraDPManager) {
        device = ThingSmartDevice.init(deviceId: devId)
        self.dpManager = dpManager

        settingData = CameraSettingSection.Section.allCases.map {
            CameraSettingSection(sectionTitle: $0.title, items: [])
        }

        fetchData()
    }

    func dpSwitch(_ isOn: Bool, dpName: ThingSmartCameraDPKey) {
        guard dpName != Self.kOutOffBoundsDPCode else {
            outOffBoundsAction(isOn: isOn)
            return
        }

        setDp(isOn, forKey: dpName)
    }

    func removeDevice() {
        let alertController = UIAlertController(
            title: nil,
            message: NSLocalizedString("device_confirm_remove", tableName: "IPCLocalizable"),
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: NSLocalizedString("ipc_confirm_cancel", tableName: "IPCLocalizable"), style: .cancel)
        let confirmAction = UIAlertAction(
            title: NSLocalizedString("ipc_confirm_sure", tableName: "IPCLocalizable"),
            style: .destructive
        ) { [weak self] _ in
            self?.device?.remove({
                let navigationController = UIApplication.shared.tp_navigationController
                if let vc = navigationController?.viewControllers.first(where: { $0 is DeviceListTableViewController }) {
                    navigationController?.popToViewController(vc, animated: true)
                } else {
                    navigationController?.popToRootViewController(animated: true)
                }
                //UIApplication.shared.tp_topMostViewController?.dismiss(animated: true)
            }, failure: { error in
                SVProgressHUD.showError(withStatus: "Failed to remove device: \(error?.localizedDescription ?? "")")
            })
        }
        [cancelAction, confirmAction].forEach { alertController.addAction($0) }
        UIApplication.shared.tp_topMostViewController?.present(alertController, animated: true)
    }
}

// MARK: - Data
extension CameraSettingsViewModel {
    private func fetchData() {
        if let indicatorOn = dpValue(for: .basicIndicatorDPName, as: Bool.self) {
            let dpName = ThingSmartCameraDPKey.basicIndicatorDPName
            appendSetting(
                in: .basic,
                item: .init(key: "ipc_basic_status_indicator", dpName: dpName, trailing: .switch(isOn: indicatorOn))
            )
        }

        if let flipOn = dpValue(for: .basicFlipDPName, as: Bool.self) {
            let dpName = ThingSmartCameraDPKey.basicFlipDPName
            appendSetting(
                in: .basic,
                item: .init(key: "ipc_basic_picture_flip", dpName: dpName, trailing: .switch(isOn: flipOn))
            )
        }

        if let osdOn = dpValue(for: .basicOSDDPName, as: Bool.self) {
            let dpName = ThingSmartCameraDPKey.basicOSDDPName
            appendSetting(in: .basic, item: .init(key: "ipc_basic_osd_watermark", dpName: dpName, trailing: .switch(isOn: osdOn)))
        }

        if let privateOn = dpValue(for: .basicPrivateDPName, as: Bool.self) {
            let dpName = ThingSmartCameraDPKey.basicPrivateDPName
            appendSetting(in: .basic, item: .init(key: "ipc_basic_hibernate", dpName: dpName, trailing: .switch(isOn: privateOn)))
        }

        if let nightvisionState = dpValue(for: .basicNightvisionDPName, as: NSString.self) as? ThingSmartCameraNightvision {
            let dpName = ThingSmartCameraDPKey.basicNightvisionDPName
            appendSetting(in: .basic, item: .init(key: "ipc_basic_night_vision", dpName: dpName, trailing: .arrow(content: nightvisionState.localizedString)) { [weak self] title in
                self?.nightvisionAction(title: title)
            })
        }

        if let pirState = dpValue(for: .basicPIRDPName, as: NSString.self) as? ThingSmartCameraPIR {
            let dpName = ThingSmartCameraDPKey.basicPIRDPName
            appendSetting(in: .basic, item: .init(key: "ipc_pir_switch", dpName: dpName, trailing: .arrow(content: pirState.localizedString)) { [weak self] title in
                self?.pirAction(title: title)
            })
        }

        if let motionDetectOn = dpValue(for: .motionDetectDPName, as: Bool.self) {
            let dpName = ThingSmartCameraDPKey.motionDetectDPName
            appendSetting(
                in: .motionDetection,
                item: .init(key: "ipc_live_page_cstorage_motion_detected", dpName: dpName, trailing: .switch(isOn: motionDetectOn))
            )

            if let motionSensitivity = dpValue(for: .motionSensitivityDPName, as: NSString.self) as? ThingSmartCameraMotion {
                let dpName = ThingSmartCameraDPKey.motionSensitivityDPName
                var settingItem: Setting = .init(key: "ipc_motion_sensitivity_settings", dpName: dpName, trailing: .arrow(content: motionSensitivity.localizedString)) { [weak self] title in
                    self?.motionSensitivityAction(title: title)
                }
                settingItem.isHidden = !motionDetectOn
                appendSetting(in: .motionDetection, item: settingItem)
            }
        }

        if let outOffBoundsOn = dpValue(for: Self.kOutOffBoundsDPCode, as: Bool.self) {
            let dpName = Self.kOutOffBoundsDPCode
            appendSetting(
                in: .motionDetection,
                item: .init(key: "ipc_live_page_cstorage_out_of_bounds", dpName: dpName, trailing: .switch(isOn: outOffBoundsOn))
            )
        }

        if let decibelDetectOn = dpValue(for: .decibelDetectDPName, as: Bool.self) {
            let dpName = ThingSmartCameraDPKey.decibelDetectDPName
            appendSetting(
                in: .soundDetection,
                item: .init(key: "ipc_sound_detect_switch", dpName: dpName, trailing: .switch(isOn: decibelDetectOn))
            )

            if let decibelSensitivity = dpValue(for: .decibelSensitivityDPName, as: NSString.self) as? ThingSmartCameraDecibel {
                var settingItem: Setting = .init(
                    key: "ipc_motion_sensitivity_settings",
                    dpName: .decibelSensitivityDPName,
                    trailing: .arrow(content: decibelSensitivity.localizedString)
                ) { [weak self] title in
                    self?.decibelSensitivityAction(title: title)
                }
                settingItem.isHidden = !decibelDetectOn
                appendSetting(in: .soundDetection, item: settingItem)
            }
        }

        if let sdCardStatusRaw = dpValue(for: .sdCardStatusDPName, as: UInt.self),
           let sdCardStatus = ThingSmartCameraSDCardStatus(rawValue: sdCardStatusRaw) {
            let dpName = ThingSmartCameraDPKey.sdCardStatusDPName
            appendSetting(
                in: .storage,
                item: .init(
                    key: "ipc_sdcard_settings",
                    dpName: dpName,
                    trailing: .arrow(content: sdCardStatus.localizedString)
                ) { [weak self] title in
                    self?.sdCardAction(title: title)
                }
            )
        }

        if let sdRecordOn = dpValue(for: .sdCardRecordDPName, as: Bool.self) {
            let dpName = ThingSmartCameraDPKey.sdCardRecordDPName
            appendSetting(
                in: .storage,
                item: .init(key: "ipc_sdcard_record_switch", dpName: dpName, trailing: .switch(isOn: sdRecordOn))
            )
        }

        if let recordMode = dpValue(for: .recordModeDPName, as: NSString.self) as? ThingSmartCameraRecordMode {
            appendSetting(
                in: .storage,
                item: .init(
                    key: "ipc_sdcard_record_mode_settings",
                    dpName: .recordModeDPName,
                    trailing: .arrow(content: recordMode.localizedString),
                    action: { [weak self] title in
                        self?.recordModeAction(title: title)
                    }
                )
            )
        }

        if let batteryLockOn = dpValue(for: .wirelessBatteryLockDPName, as: Bool.self) {
            let dpName = ThingSmartCameraDPKey.wirelessBatteryLockDPName
            appendSetting(
                in: .powerManagement,
                item: .init(key: "ipc_basic_batterylock", dpName: dpName, trailing: .switch(isOn: batteryLockOn))
            )
        }

        if let powerMode = dpValue(for: .wirelessPowerModeDPName, as: NSString.self) as? ThingSmartCameraPowerMode {
            let dpName = ThingSmartCameraDPKey.wirelessPowerModeDPName
            appendSetting(
                in: .powerManagement,
                item: .init(key: "ipc_electric_power_source", dpName: dpName, trailing: .label(title: powerMode.localizedString))
            )
        }

        if let electricity = dpValue(for: .wirelessElectricityDPName, as: Int.self) {
            let dpName = ThingSmartCameraDPKey.wirelessElectricityDPName
            let content = "\(electricity)%"
            appendSetting(
                in: .powerManagement,
                item: .init(key: "ipc_electric_percentage", dpName: dpName, trailing: .label(title: content))
            )
        }

        fetchedData.removeAll(where: \.items.isEmpty)
        settingData = fetchedData
        fetchedData.removeAll()
    }

    private func updateSetting(for dpName: ThingSmartCameraDPKey) {
        guard let sectionIndex = settingData.firstIndex(where: { $0.items.contains(where: { $0.dpName == dpName }) }),
              let itemIndex = settingData[sectionIndex].items.firstIndex(where: { $0.dpName == dpName }) else {
            return
        }
        let settingItem = settingData[sectionIndex].items[itemIndex]

        if (dpName as NSString as ThingSmartCameraDPKey) == ThingSmartCameraDPKey.sdCardStatusDPName,
           let newValue = dpValue(for: dpName, as: Int.self) as? DpStatusLocalizable {
            settingData[sectionIndex].items[itemIndex].trailing = .arrow(content: newValue.localizedString)
            return
        }

        switch settingItem.trailing {
        case .arrow:
            guard let newValue = dpValue(for: dpName, as: NSString.self),
                  let contnet = localizedTitle(by: dpName, with: newValue) else { return }
            settingData[sectionIndex].items[itemIndex].trailing = .arrow(content: contnet)
        case .label:
            guard let newValue = dpValue(for: dpName, as: NSString.self),
                  let contnet = localizedTitle(by: dpName, with: newValue) else { return }
            settingData[sectionIndex].items[itemIndex].trailing = .label(title: contnet)
        case .switch:
            if let newValue = dpValue(for: dpName, as: Bool.self) {
                settingData[sectionIndex].items[itemIndex].trailing = .switch(isOn: newValue)
                if dpName == .motionDetectDPName {
                    updateSetting(for: .motionSensitivityDPName) { item in
                        item.isHidden = !newValue
                    }
                } else if dpName == .decibelDetectDPName {
                    updateSetting(for: .decibelSensitivityDPName) { item in
                        item.isHidden = !newValue
                    }
                }
            }
        }
    }

    private func updateSetting(for dpName: ThingSmartCameraDPKey, modifier: (inout Setting) -> Void) {
        guard let section = dpSectionMap[dpName] else { return }
        let items = settingData[section.rawValue]
        guard let index = items.items.firstIndex(where: { $0.dpName == dpName }) else { return }
        withAnimation {
            modifier(&settingData[section.rawValue].items[index])
        }
    }

    private func appendSetting(in section: Section, item: CameraSettingSection.CameraSettingItem) {
        fetchedData[section.rawValue].items.append(item)
        dpSectionMap[item.dpName] = section
    }
}

// MARK: - Actions
extension CameraSettingsViewModel {
    private func nightvisionAction(title: String? = nil) {
        let options = [ThingSmartCameraNightvision.auto, .on, .off]
        showActionSheet(by: options, for: .basicNightvisionDPName, title: title)
    }

    private func pirAction(title: String? = nil) {
        let options = [ThingSmartCameraPIR.stateHigh, .stateMedium, .stateLow, .stateOff]
        showActionSheet(by: options, for: .basicPIRDPName, title: title)
    }

    private func motionSensitivityAction(title: String? = nil) {
        let options = [ThingSmartCameraMotion.high, .medium, .low]
        showActionSheet(by: options, for: .motionSensitivityDPName, title: title)
    }

    private func decibelSensitivityAction(title: String? = nil) {
        let options = [ThingSmartCameraDecibel.high, .low]
        showActionSheet(by: options, for: .decibelSensitivityDPName, title: title)
    }

    private func recordModeAction(title: String? = nil) {
        let options = [ThingSmartCameraRecordMode.event, .always]
        showActionSheet(by: options, for: .recordModeDPName, title: title)
    }

    private func outOffBoundsAction(isOn: Bool) {
        setDp(isOn, forKey: Self.kOutOffBoundsDPCode)
        guard isOn else { return }

        let params = [
            "points": [2, 10, 50, 30, 100, 31, 60, 50, 81, 92, 50, 70, 21, 87, 40, 50]
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: [params], options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            setDp(jsonString, forKey: Self.kOutOffBoundsSetDPCode)
        }
    }

    private func sdCardAction(title: String?) {
        let viewModel = CameraSDCardViewModel(dpManager: dpManager)
        let vc = UIHostingController(rootView: CameraSDCardView(viewModel: viewModel))
        UIApplication.shared.tp_navigationController?.pushViewController(vc, animated: true)
    }

    private func showActionSheet<T: DpStatusLocalizable>(by options: [T], for dpName: ThingSmartCameraDPKey, title: String? = nil) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        options.forEach { option in
            let action = UIAlertAction(title: option.localizedString, style: .default) { [weak self] _ in
                self?.setDp(option, forKey: dpName)
            }
            alert.addAction(action)
        }
        alert.addAction(.init(title: NSLocalizedString("Cancel", tableName: "IPCLocalizable"), style: .cancel))
        UIApplication.shared.tp_topMostViewController?.present(alert, animated: true)
    }
}

// MARK: - DP
extension CameraSettingsViewModel {
    private func setDp(_ value: Any, forKey dpKey: ThingSmartCameraDPKey) {
        SVProgressHUD.show()

        dpManager.setValue(value, forDP: dpKey) { [weak self] _ in
            self?.updateSetting(for: dpKey)
            SVProgressHUD.dismiss()
        } failure: { [weak self] error in
            self?.updateSetting(for: dpKey)
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }

    private func dpValue<T>(for dp: ThingSmartCameraDPKey, as type: T.Type) -> T? {
        guard dpManager.isSupportDP(dp) else { return nil }
        let result = dpManager.value(forDP: dp) as? NSObject

        if T.self == Bool.self {
            return result?.thingsdk_toBool() as? T
        }
        if T.self == NSString.self {
            return result?.thingsdk_toString() as? T
        }
        if T.self == Int.self {
            return result?.thingsdk_toInt() as? T
        }
        if T.self == UInt.self {
            return result?.thingsdk_toUInt() as? T
        }
        return nil
    }

    private func localizedTitle(by dpName: ThingSmartCameraDPKey, with rawValue: Any) -> String? {
        if let rawValue = rawValue as? NSString {
            switch dpName {
            case .basicNightvisionDPName:
                return (rawValue as ThingSmartCameraNightvision).localizedString
            case .basicPIRDPName:
                return (rawValue as ThingSmartCameraPIR).localizedString
            case .motionSensitivityDPName:
                return (rawValue as ThingSmartCameraMotion).localizedString
            case .decibelSensitivityDPName:
                return (rawValue as ThingSmartCameraDecibel).localizedString
            case .recordModeDPName:
                return (rawValue as ThingSmartCameraRecordMode).localizedString
            case .wirelessPowerModeDPName:
                return (rawValue as ThingSmartCameraPowerMode).localizedString
            default:
                return nil
            }
        }

        if let rawValue = rawValue as? Int, dpName == .sdCardStatusDPName {
            return ThingSmartCameraSDCardStatus(rawValue: UInt(rawValue))?.localizedString
        }
        return nil
    }
}
