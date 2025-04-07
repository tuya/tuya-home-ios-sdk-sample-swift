//
//  TuyaAppSDKWidgetData.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartBaseKit
import ThingSmartDeviceCoreKit
import ThingSmartDeviceKit

class TuyaAppSDKWidgetDataManager {
    static let shared = TuyaAppSDKWidgetDataManager()
    
    private init() {
        /*
         * Init SDK, must set app group id
         */
        ThingSmartSDK.sharedInstance().appGroupId = "your group id"
        ThingSmartSDK.sharedInstance().env = ThingEnv.release
        ThingSmartSDK.sharedInstance().start(withAppKey: AppKey.appKey, secretKey: AppKey.secretKey)
    }
    
    func setup() {
        // initialize bussiness
    }
    
    func getDataList() async -> [ThingSmartDeviceModel]? {
        await withCheckedContinuation { continuation in
            ThingSmartHomeManager().getHomeList { homeList in
                if let firstHome = homeList?.first {
                    if let home = ThingSmartHome(homeId: firstHome.homeId) {
                        home.getDataWithSuccess { homeModel in
                            continuation.resume(returning: home.deviceList)
                        } failure: { error in
                            continuation.resume(returning: nil)
                        }
                    } else {
                        continuation.resume(returning: nil)
                    }
                } else {
                    continuation.resume(returning: nil)
                }
            } failure: { error in
                continuation.resume(returning: nil)
            }
        }
    }
    
    func transToModel(with deviceList:[ThingSmartDeviceModel]?) async -> [TuyaAppSDKWidgetModel] {
        guard let deviceList = deviceList else { return [] }
        var list : [TuyaAppSDKWidgetModel] = []
        for deviceModel in deviceList {
            let image = await downloadImage(with: deviceModel.iconUrl)
            let switchStatus = deviceModel.switchDps.count > 0 ? deviceModel.switchDpsValue() : nil;
            let model = TuyaAppSDKWidgetModel(name: deviceModel.name, image: image, isOnline: deviceModel.isOnline, switchStatus: switchStatus, devId: deviceModel.devId)
            list.append(model)
        }
        return list
    }
    
    func downloadImage(with urlString:String?) async -> UIImage? {
        await withCheckedContinuation { continuation in
            if let urlStr = urlString, let url = URL(string: urlStr) {
                SDImageLoadersManager.shared.requestImage(with: url, context: nil, progress: nil) { image, date, error, finished in
                    if finished  {
                        continuation.resume(returning: image)
                    }
                }
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
    
}
