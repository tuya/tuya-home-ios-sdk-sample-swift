//
//  DemoSplitVideoViewManager.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class DemoSplitVideoViewManager: NSObject, ThingSmartCameraDelegate {
    var splitVideoView: CameraSplitVideoContainerView? {
        guard isSupportVideoSplitting,
              let _ = cameraAdvancedConfig?.split_video_sum_info.align_info else {
            return nil
        }

        return CameraSplitVideoContainerView(cameraDevice: cameraDevice, videoViewDispatcher: videoViewDispatcher)
    }

    private(set) var isSupportVideoSplitting: Bool = false

    private var cameraDevice: CameraDevice
    private var cameraAdvancedConfig: ThingSmartCameraM.ThingSmartCameraAdvancedConfig?
    private var videoOperator: DemoSplitVideoOperator
    private var videoViewDispatcher: DemoSplitVideoViewDispatcher
    private var videoViewContext: DemoSplitVideoViewContext
    private var viewSizeCounter: DemoSplitVideoViewSizeCounter

    init(cameraDevice: CameraDevice) {
        self.cameraDevice = cameraDevice

        videoOperator = DemoSplitVideoOperator(cameraDevice: cameraDevice)

        viewSizeCounter = DemoSplitVideoViewSizeCounter(videoSizeRate: 0, padding: 0)

        cameraAdvancedConfig = videoOperator.advancedConfig as? ThingSmartCameraM.ThingSmartCameraAdvancedConfig

        isSupportVideoSplitting = cameraAdvancedConfig?.isSupportedVideoSplitting ?? false

        videoViewContext = DemoSplitVideoViewContext(videoOperator: videoOperator, viewSizeCounter: viewSizeCounter)

        videoViewDispatcher = DemoSplitVideoViewDispatcher(advancedConfig: cameraAdvancedConfig, videoViewContext: videoViewContext)

        super.init()
        cameraDevice.addDelegate(self)
    }

    deinit {
        print("DemoSplitVideoViewManager deinit")
        cameraDevice.removeDelegate(self)
    }

    func camera(_ camera: (any ThingSmartCameraType)!, resolutionDidChangeWith videoExtInfo: (any ThingSmartVideoExtInfo)!) {
        videoViewDispatcher.modifyVideoExtInfo(videoExtInfo)
    }
}
