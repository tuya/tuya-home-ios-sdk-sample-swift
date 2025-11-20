//
//  Dictionary+Extension.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

extension Dictionary {
    func convertedJsonString() -> String? {
        guard JSONSerialization.isValidJSONObject(self),
              let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        else { return nil }

        return String(data: jsonData, encoding: .utf8)?
            .replacingOccurrences(of: " ", with: "", options: .literal)
            .replacingOccurrences(of: "\n", with: "", options: .literal)
    }
}
