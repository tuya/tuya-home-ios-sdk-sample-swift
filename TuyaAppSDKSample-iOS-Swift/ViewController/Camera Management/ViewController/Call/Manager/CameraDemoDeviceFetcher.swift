//
//  CameraDemoDeviceFetcher.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import ThingSmartCallChannelKit

class CameraDemoDeviceFetcher {
    static func fetchDevice(withDevId devId: String?, completion: @escaping (ThingSmartDeviceModel?, NSError?) -> Void) {
        guard let devId else {
            completion(
                nil,
                NSError.thingcall_errorWithErrorCode(
                    ThingSmartCallError.invalidParams.rawValue,
                    errorMsg: "devId is null",
                    extra: ["innerCode": -1]
                )
            )
            return
        }

        let deviceModel = ThingCoreCacheService.sharedInstance().getDeviceInfo(withDevId: devId) as ThingSmartDeviceModel?

        if deviceModel != nil {
            completion(deviceModel, nil)
            return
        }

        ThingSmartDevice.syncDeviceInfo(withDevId: devId) { deviceModel in
            let deviceModel = deviceModel as ThingSmartDeviceModel?
            if let deviceModel {
                completion(deviceModel, nil)
            } else {
                completion(nil, NSError.thingcall_errorWithErrorCode(ThingSmartCallError.invalidResponse.rawValue, errorMsg: "sync device info failed", extra: ["innerCode": -1]))
            }
        } failure: { error in
            completion(nil, NSError.thingcall_errorWithErrorCode(ThingSmartCallError.requestFailed.rawValue, errorMsg: error?.localizedDescription ?? "", extra: ["innerCode": -1]))
        }
    }
}
