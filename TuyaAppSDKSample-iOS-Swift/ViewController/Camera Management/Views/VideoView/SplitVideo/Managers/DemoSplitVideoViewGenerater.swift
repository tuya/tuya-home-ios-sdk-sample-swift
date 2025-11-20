//
//  DemoSplitVideoViewGenerater.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class DemoSplitVideoViewGenerater: NSObject {
    var allViews: [DemoSplitVideoNodeView]? {
        Array(allVideoViews)
    }

    // MARK: - Portrait
    var topViews: [DemoSplitVideoNodeView] {
        guard let firstGroup = videoViews.first else { return [] }
        return Array(firstGroup.prefix(Self.kDemoCameraSplitVideoViewMaxCount))
    }

    var bottomViews: [DemoSplitVideoNodeView] {
        guard videoViews.count > 1, let lastGroup = videoViews.last else { return [] }
        return Array(lastGroup.prefix(Self.kDemoCameraSplitVideoViewMaxCount))
    }

    // MARK: - Landscape
    var bigViews: [DemoSplitVideoNodeView] {
        if !cachedBigViews.isEmpty { return cachedBigViews }
        guard let firstVideo = videoViews.first?.first else { return [] }
        firstVideo.isMainView = true
        return [firstVideo]
    }

    var smallViews: [DemoSplitVideoNodeView] {
        if !cachedSmallViews.isEmpty { return cachedBigViews }
        var tmpSmallViews: [DemoSplitVideoNodeView] = []
        if let fitstGroup = videoViews.first {
            tmpSmallViews.append(contentsOf: fitstGroup.dropFirst())
        }
        if videoViews.count > 1, let lastGroup = videoViews.last {
            tmpSmallViews.append(contentsOf: lastGroup)
        }
        tmpSmallViews.forEach { $0.isMainView = false }
        return tmpSmallViews
    }

    private var videoViews = [[DemoSplitVideoNodeView]]()
    private var allVideoViews = Set<DemoSplitVideoNodeView>()
    private var cachedBigViews = [DemoSplitVideoNodeView]()
    private var cachedSmallViews = [DemoSplitVideoNodeView]()

    private static let kDemoCameraSplitVideoViewMaxCount = 2

    init(
        advancedConfig: ThingSmartCameraBase.ThingSmartCameraAdvancedConfig?,
        videoViewContext: DemoSplitVideoViewContextProtocol
    ) {
        super.init()

        let videoInfos = DemoSplitVideoInfoProcesser.processVideoSplitInfo(with: advancedConfig)
        var videoViews = [[DemoSplitVideoNodeView]]()
        var bigViews = [DemoSplitVideoNodeView]()
        var smallViews = [DemoSplitVideoNodeView]()

        videoInfos.forEach { subVideoInfos in
            var subVideoViews: [DemoSplitVideoNodeView] = []

            subVideoInfos.forEach { subVideoInfo in
                let videoNodeView = DemoSplitVideoNodeView(
                    videoViewContext: videoViewContext,
                    splitVideoInfo: subVideoInfo
                )
                subVideoViews.append(videoNodeView)
                allVideoViews.insert(videoNodeView)
                if subVideoInfo.isFirstIndex {
                    videoNodeView.isMainView = true
                    bigViews.append(videoNodeView)
                } else {
                    videoNodeView.isMainView = false
                    smallViews.append(videoNodeView)
                }
            }
            videoViews.append(subVideoViews)
        }
        self.videoViews = videoViews
        cachedBigViews = bigViews
        cachedSmallViews = smallViews
    }
}
