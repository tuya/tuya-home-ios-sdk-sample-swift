//
//  Encodable+Extension.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

extension Encodable {
    func jsonObject() -> Any? {
        do {
            let data = try JSONEncoder().encode(self)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
            return (jsonObject is [Any] || jsonObject is [String: Any]) ? jsonObject : nil
        } catch {
            print("Json encode error: \(error.localizedDescription)")
            return nil
        }
    }
}

extension Decodable {
    init?(from json: [AnyHashable: Any?]) {
        guard let data = try? JSONSerialization.data(withJSONObject: json) else { return nil }
        self.init(from: data)
    }
    
    private init?(from data: Data) {
        guard let jsonData = try? JSONDecoder().decode(Self.self, from: data) else { return nil }
        self = jsonData
    }
}
