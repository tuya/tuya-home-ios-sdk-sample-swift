//
//  SceneSectionType.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation

enum SectionType: Int {
    case Name = 0
    case Match
    case Condition
    case Action
    case Precondition
    
    func headerTitle() -> String {
        switch self {
        case .Name: return "Name"
        case .Match: return "Condition Type"
        case .Condition: return "Condition"
        case .Action: return "Action"
        case .Precondition: return "Precondition"
        }
    }
    
    func cellIdentifier()->String {
        switch self {
        case .Name: return "name-cell"
        case .Match: return "type-cell"
        case .Condition: return "condition-cell"
        case .Action: return "condition-cell"
        case .Precondition: return "condition-cell"
        }
    }
}
