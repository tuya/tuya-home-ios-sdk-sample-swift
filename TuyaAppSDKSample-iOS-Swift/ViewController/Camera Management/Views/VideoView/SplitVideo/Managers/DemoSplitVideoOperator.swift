//
//  DemoSplitVideoOperator.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class DemoSplitVideoOperator: DemoSplitVideoOperatorProtocol {
    weak var advancedConfig: ThingSmartCameraBase.ThingSmartCameraAdvancedConfig?

    private weak var cameraDevice: CameraDevice?

    init(cameraDevice: CameraDevice) {
        self.cameraDevice = cameraDevice
        advancedConfig = cameraDevice.camera.advancedConfig
    }

    func bindVideoViewIndexPairs(_ videoIndexPairs: [ThingSmartVideoViewIndexPair]) -> Bool {
        cameraDevice?.camera.register?(videoIndexPairs) ?? false
    }

    func unbindVideoViewIndexPairs(_ videoIndexPairs: [ThingSmartVideoViewIndexPair]) -> Bool {
        cameraDevice?.camera.uninstallVideoViewIndexPairs?(videoIndexPairs) ?? false
    }

    func swapVideoIndex(_ videoIndex: ThingSmartVideoIndex, forVideoIndex: ThingSmartVideoIndex) -> Bool {
        cameraDevice?.camera.swapVideoIndex?(videoIndex, forVideoIndex: forVideoIndex) ?? false
    }

    func bindVideoView<V>(_ videoView: V, videoIndex: ThingSmartVideoIndex) -> Bool where V : UIView, V : ThingSmartVideoViewType {
        let pairInfo = DemoVideoViewIndexPair(videoView: videoView, videoIndex: videoIndex)
        return bindVideoViewIndexPairs([pairInfo])
    }

    func unbindVideoView<V>(_ videoView: V, forVideoIndex videoIndex: ThingSmartVideoIndex) -> Bool where V : UIView, V : ThingSmartVideoViewType {
        let pairInfo = DemoVideoViewIndexPair(videoView: videoView, videoIndex: videoIndex)
        return unbindVideoViewIndexPairs([pairInfo])
    }

    func publishLocalizerCoordinateInfo(_ coordinateInfo: String) -> Bool {
        print("publish localizer coordinate \(coordinateInfo) to device \(cameraDevice?.deviceModel.devId)")
        let isSupport = cameraDevice?.dpManager.isSupportDPCode(Self.kSplitVideoLocalizerCoordinateDPCode) ?? false
        guard isSupport else { return false }
        cameraDevice?.dpManager.setValue(coordinateInfo, forDP: Self.kSplitVideoLocalizerCoordinateDPCode, success: nil, failure: nil)
        return true
    }
}
