//
//  SceneDeviceNode.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation

struct SceneDeviceNode {
    enum NodeType: Int {
        case Group
        case Device
    }
    
    var deviceModel: ThingSmartDeviceModel?
    var groupModel: ThingSmartGroupModel?
    
    var name: String {
        if let deviceModel = self.deviceModel {
            return deviceModel.name
        }
        if let groupModel = self.groupModel {
            return groupModel.name
        }
        return ""
    }
    
    var nodeID: String {
        if let deviceModel = self.deviceModel {
            return deviceModel.devId
        }
        if let groupModel = self.groupModel {
            return groupModel.groupId
        }
        return ""
    }
    
    var nodeType: NodeType {
        if self.deviceModel != nil {
            return .Device
        }
        if self.groupModel != nil {
            return .Group
        }
        return .Device
    }
    
    init(deviceModel: ThingSmartDeviceModel? = nil, groupModel: ThingSmartGroupModel? = nil) {
        self.deviceModel = deviceModel
        self.groupModel = groupModel
    }
}
