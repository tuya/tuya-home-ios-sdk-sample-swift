//
//  CameraDpStatusLocalizedTitle.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

protocol DpStatusLocalizable {
    var localizedString: String { get }
}

extension ThingSmartCameraNightvision: DpStatusLocalizable {
    var localizedString: String {
        switch self {
        case .auto:
            NSLocalizedString("ipc_basic_night_vision_auto", tableName: "IPCLocalizable")
        case .on:
            NSLocalizedString("ipc_basic_night_vision_on", tableName: "IPCLocalizable")
        case .off:
            NSLocalizedString("ipc_basic_night_vision_off", tableName: "IPCLocalizable")
        default: ""
        }
    }
}

extension ThingSmartCameraPIR: DpStatusLocalizable {
    var localizedString: String {
        switch self {
        case .stateLow:
            NSLocalizedString("ipc_settings_status_low", tableName: "IPCLocalizable")
        case .stateMedium:
            NSLocalizedString("ipc_settings_status_mid", tableName: "IPCLocalizable")
        case .stateHigh:
            NSLocalizedString("ipc_settings_status_high", tableName: "IPCLocalizable")
        default:
            NSLocalizedString("ipc_settings_status_off", tableName: "IPCLocalizable")
        }
    }
}

extension ThingSmartCameraMotion: DpStatusLocalizable {
    var localizedString: String {
        switch self {
        case .low:
            NSLocalizedString("ipc_motion_sensitivity_low", tableName: "IPCLocalizable")
        case .medium:
            NSLocalizedString("ipc_motion_sensitivity_mid", tableName: "IPCLocalizable")
        case .high:
            NSLocalizedString("ipc_motion_sensitivity_high", tableName: "IPCLocalizable")
        default: ""
        }
    }
}

extension ThingSmartCameraDecibel: DpStatusLocalizable {
    var localizedString: String {
        switch self {
        case .low:
            NSLocalizedString("ipc_sound_sensitivity_low", tableName: "IPCLocalizable")
        case .high:
            NSLocalizedString("ipc_sound_sensitivity_high", tableName: "IPCLocalizable")
        default: ""
        }
    }
}

extension ThingSmartCameraSDCardStatus: DpStatusLocalizable {
    var localizedString: String {
        switch self {
        case .normal:
            NSLocalizedString("Normally", tableName: "IPCLocalizable")
        case .exception:
            NSLocalizedString("Abnormally", tableName: "IPCLocalizable")
        case .memoryLow:
            NSLocalizedString("Insufficient capacity", tableName: "IPCLocalizable")
        case .formatting:
            NSLocalizedString("ipc_status_sdcard_format", tableName: "IPCLocalizable")
        default:
            NSLocalizedString("pps_no_sdcard", tableName: "IPCLocalizable")
        }
    }
}

extension ThingSmartCameraRecordMode: DpStatusLocalizable {
    var localizedString: String {
        switch self {
        case .event:
            NSLocalizedString("ipc_sdcard_record_mode_event", tableName: "IPCLocalizable")
        default:
            NSLocalizedString("ipc_sdcard_record_mode_ctns", tableName: "IPCLocalizable")
        }
    }
}

extension ThingSmartCameraPowerMode: DpStatusLocalizable {
    var localizedString: String {
        switch self {
        case .plug:
            NSLocalizedString("ipc_electric_power_source_wire", tableName: "IPCLocalizable")
        default:
            NSLocalizedString("ipc_electric_power_source_batt", tableName: "IPCLocalizable")
        }
    }
}
