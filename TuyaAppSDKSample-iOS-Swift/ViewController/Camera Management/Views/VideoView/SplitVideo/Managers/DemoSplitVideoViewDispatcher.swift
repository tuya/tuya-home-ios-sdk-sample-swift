//
//  DemoSplitVideoViewDispatcher.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class DemoSplitVideoViewDispatcher: AnyObject {
    private(set) var bindViews: [CameraSplitVideoView] = []

    private weak var advancedConfig: ThingSmartCameraM.ThingSmartCameraAdvancedConfig?
    private weak var videoViewContext: DemoSplitVideoViewContextProtocol?
    private var videoViewGenerater: DemoSplitVideoViewGenerater

    private var toolbarFolding: Bool = false
    private var smallVideoViewsHidden: Bool = false
    private var isLandscape: Bool = false

    private var topView: CameraSplitVideoView
    private var bottomView: CameraSplitVideoView

    init(
        advancedConfig: ThingSmartCameraBase.ThingSmartCameraAdvancedConfig?,
        videoViewContext: DemoSplitVideoViewContextProtocol
    ) {
        self.advancedConfig = advancedConfig as? ThingSmartCameraM.ThingSmartCameraAdvancedConfig
        self.videoViewContext = videoViewContext
        videoViewGenerater = DemoSplitVideoViewGenerater(
            advancedConfig: advancedConfig,
            videoViewContext: videoViewContext
        )

        topView = CameraSplitVideoView()
        bottomView = CameraSplitVideoView()

        topView.gestureDelegate = self
        topView.videoViewContext = videoViewContext
        bottomView.gestureDelegate = self
        bottomView.videoViewContext = videoViewContext

        bindViews = [topView, bottomView]

        let allVideoViews = videoViewGenerater.allViews
        let _ = allVideoViews?.reduce(into: []) { partialResult, videoView in
            let pairInfo = DemoVideoViewIndexPair(videoView: videoView.videoView, videoIndex: videoView.splitVideoInfo.index)
            partialResult.append(pairInfo)
        }
    }

    func setToolbarFolding(_ folding: Bool) {
        toolbarFolding = folding
        bindViews.forEach {
            $0.setToolbarFolding(folding)
        }
    }

    func setSmallVideoViewsHidden(_ hidden: Bool) {
        smallVideoViewsHidden = hidden
        UIView.animate(withDuration: bottomView.animatedDuration) {
            self.bottomView.alpha = self.smallVideoViewsHidden ? 0 : 1
        } completion: { _ in
            self.bottomView.isHidden = self.smallVideoViewsHidden
        }
    }

    func setShowLocalizer(_ show: Bool) {
        bindViews.forEach {
            if $0.hasLocalizer {
                $0.setShowLocalizer(show)
            }
        }
    }

    func rebindVideoNodeViews() {
        if isLandscape {
            topView.rebindVideoNodeViews(videoViewGenerater.bigViews)
            bottomView.rebindVideoNodeViews(videoViewGenerater.smallViews)
        } else {
            topView.rebindVideoNodeViews(videoViewGenerater.topViews)
            bottomView.rebindVideoNodeViews(videoViewGenerater.bottomViews)
        }
    }

    func relayoutBindViewsBasedOnSuperView(_ superView: UIView, isLandscape: Bool) {
        topView.isLandscape = isLandscape
        bottomView.isLandscape = isLandscape

        if self.isLandscape != isLandscape {
            self.isLandscape.toggle()
            rebindVideoNodeViews()
        }

        if isLandscape, let landscapeCoverSize = videoViewContext?.viewSizeCounter?.landscapeCoverSize {
            topView.frame = superView.bounds
            bottomView.frame = CGRectMake(
                superView.width - landscapeCoverSize.width,
                0,
                landscapeCoverSize.width,
                landscapeCoverSize.height
            )
            topView.triggerLayoutImmediately()
            bottomView.triggerLayoutImmediately()
            return
        }

        layoutPortraitMode(in: superView)
    }

    func destoryBindViews() {
        topView.destory()
        bottomView.destory()
    }

    func modifyVideoExtInfo(_ extInfo: ThingSmartVideoExtInfo) {
        guard let allVideoViews = videoViewGenerater.allViews else { return }
        for videoView in allVideoViews {
            if videoView.splitVideoInfo.index == extInfo.videoIndex {
                videoView.frameSize = extInfo.frameSize
                break
            }
        }
    }

    private func layoutPortraitMode(in superView: UIView) {
        guard let viewSizeCounter = videoViewContext?.viewSizeCounter else { return }

        bottomView.alpha = 1
        bottomView.isHidden = false

        let topViewNodesCount = topView.videoNodeViews?.count ?? 0
        let bottomViewNodesCount = bottomView.videoNodeViews?.count ?? 0

        let portraitSmallSize = viewSizeCounter.portraitSmallSize
        let portraitNormalSize = viewSizeCounter.portraitNormalSize

        var mediaViewsSizeW = portraitNormalSize.width

        var topViewSizeH = topViewNodesCount > 1 ? portraitSmallSize.height : portraitNormalSize.height
        var bottomViewSizeH: CGFloat = {
            switch bottomViewNodesCount {
            case 1: topViewSizeH
            case 2...: portraitSmallSize.height
            default: 0
            }
        }()

        let isBinocularCamera = topViewNodesCount <= 1 && bottomViewNodesCount <= 1
        let needSmallSize = !toolbarFolding && isBinocularCamera
        let padding = viewSizeCounter.padding

        var frameOffset = max(0, (superView.height - (topViewSizeH + bottomViewSizeH + (bottomViewSizeH != 0 ? padding : 0))) / 2)

        if needSmallSize {
            topViewSizeH = portraitSmallSize.height
            bottomViewSizeH = bottomViewNodesCount == 0 ? 0 : portraitSmallSize.height
            mediaViewsSizeW = (mediaViewsSizeW - padding) / 2
            frameOffset = max(0, (superView.height - topViewSizeH) / 2)
        }

        let topViewFrame = CGRectMake(0, frameOffset, mediaViewsSizeW, topViewSizeH)
        var bottomViewFrame = CGRectMake(0, topViewFrame.maxY + padding, mediaViewsSizeW, bottomViewSizeH)
        if needSmallSize {
            bottomViewFrame = CGRectMake(topViewFrame.maxX + padding, topViewFrame.minY, mediaViewsSizeW, bottomViewSizeH)
        }

        topView.frame = topViewFrame
        bottomView.frame = bottomViewFrame

        topView.triggerLayoutImmediately()
        bottomView.triggerLayoutImmediately()
    }
}

extension DemoSplitVideoViewDispatcher: DemoSplitVideoViewGestureDelegate {
    func didTapVideoNodeView(_ videoNodeView: DemoSplitVideoNodeView) -> Bool {
        guard isLandscape else { return false }

        if let filteredVideoNodeView = filterTappedVideoNodeView(videoNodeView),
           let mainVideoNodeView = topView.videoNodeViews?.first {

            let videoIndex = mainVideoNodeView.currentVideoIndex
            let forVideoIndex = filteredVideoNodeView.currentVideoIndex

            let succeed = videoViewContext?.videoOperator?.swapVideoIndex(videoIndex, forVideoIndex: forVideoIndex) ?? false
            if succeed {
                mainVideoNodeView.triggerLayoutImmediately()
                filteredVideoNodeView.triggerLayoutImmediately()
                mainVideoNodeView.currentVideoIndex = forVideoIndex
                filteredVideoNodeView.currentVideoIndex = videoIndex
            }
            return succeed
        }

        return false
    }

    private func filterTappedVideoNodeView(_ tappedView: UIView) -> DemoSplitVideoNodeView? {
        var result: DemoSplitVideoNodeView?
        bindViews.forEach { view in
            view.videoNodeViews?.forEach { nodeView in
                if nodeView == tappedView { result = nodeView }
            }
        }
        return result
    }
}
