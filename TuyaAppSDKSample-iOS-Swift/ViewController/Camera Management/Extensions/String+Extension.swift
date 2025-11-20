//
//  String+Extension.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

extension String {
    func p_objectFromJSONString() -> Any? {
        guard let jsonData = data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
    }
}

func NSLocalizedString(_ key: String, tableName: String) -> String {
    NSLocalizedString(key, tableName: tableName, comment: "")
}

func IPCLocalizedString(key: String) -> String {
    NSLocalizedString(key, tableName: "IPCLocalizable")
}
