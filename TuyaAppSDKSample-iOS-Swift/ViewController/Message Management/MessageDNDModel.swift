//
//  MessageDNDModel.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import Foundation

class MessageDNDModel : Codable {
    var timerId : Int
    var startTime : String
    var endTime : String
    var devIds : String
    var loops : String
    var timezoneId : String
    var timezone : String
    var allDevIds : Bool
    
    enum CodingKeys: String, CodingKey {
        case timerId = "id"
        case startTime
        case endTime
        case devIds
        case loops
        case timezoneId
        case timezone
        case allDevIds
    }
}
