//
//  CameraSettingSection.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

struct CameraSettingSection {
    let sectionTitle: String
    var items: [CameraSettingItem]
    
    struct CameraSettingItem {
        let localizedStringKey: String
        let dpName: ThingSmartCameraDPKey

        var trailing: ItemTrailing
        let action: ((String?) -> Void)?

        var isHidden = false
        var title: String {
            NSLocalizedString(localizedStringKey, tableName: "IPCLocalizable")
        }

        init(key: String, dpName: ThingSmartCameraDPKey, trailing: ItemTrailing, action: ((String?) -> Void)? = nil) {
            self.localizedStringKey = key
            self.dpName = dpName
            self.trailing = trailing
            self.action = action
        }

        enum ItemTrailing {
            case arrow(content: String)
            case label(title: String)
            case `switch`(isOn: Bool)
        }
    }
}

extension CameraSettingSection {
    enum Section: Int, CaseIterable {
        case basic
        case motionDetection
        case soundDetection
        case storage
        case powerManagement

        var title: String {
            switch self {
            case .basic:
                NSLocalizedString("ipc_settings_page_basic_function_txt", tableName: "IPCLocalizable")
            case .motionDetection:
                NSLocalizedString("ipc_live_page_cstorage_motion_detected", tableName: "IPCLocalizable")
            case .soundDetection:
                NSLocalizedString("ipc_sound_detected_switch_settings", tableName: "IPCLocalizable")
            case .storage:
                NSLocalizedString("ipc_sdcard_settings", tableName: "IPCLocalizable")
            case .powerManagement:
                NSLocalizedString("ipc_basic_batterylock", tableName: "IPCLocalizable")
            }
        }
    }
}
