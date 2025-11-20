//
//  DemoSplitVideoViewSizeCounter.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class DemoSplitVideoViewSizeCounter: DemoSplitVideoViewSizeCounterProtocol {
    var landscapeSmallSize: CGSize {
        if isValid(landscapeSmallSizeCache) {
            return landscapeSmallSizeCache
        }
        let height = portraitSmallSizeHeight == .zero ? 105 : portraitSmallSizeHeight
        let width = height / sizeRate
        landscapeSmallSizeCache = CGSize(width: width, height: height)
        return landscapeSmallSizeCache
    }

    var landscapeCoverSize: CGSize {
        let sizeRate: CGFloat = 320 / 812
        let width = videoViewWidth
        let height = videoViewHeight
        let realWidth = max(width, height) * sizeRate
        let realHeight = min(width, height)
        return CGSize(width: realWidth, height: realHeight)
    }

    var portraitSmallSize: CGSize {
        if isValid(portraitSmallSizeCache) {
            return portraitSmallSizeCache
        }
        let width = (videoViewWidth - padding) / 2
        let height = width * sizeRate
        portraitSmallSizeHeight = height
        portraitSmallSizeCache = CGSize(width: width, height: height)
        return portraitSmallSizeCache
    }

    var portraitNormalSize: CGSize {
        if isValid(portraitNormalSizeCache) {
            return portraitNormalSizeCache
        }
        let height = videoViewWidth * sizeRate
        portraitNormalSizeCache = CGSize(width: videoViewWidth, height: height)
        return portraitNormalSizeCache
    }

    var videoViewWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    var videoViewHeight: CGFloat {
        UIScreen.main.bounds.height
    }

    var padding: CGFloat
    var landscapeViewMargin: CGFloat = 10

    private var sizeRate: CGFloat
    private var portraitSmallSizeHeight: CGFloat = .zero

    private var landscapeSmallSizeCache: CGSize = .zero
    private var portraitSmallSizeCache: CGSize = .zero
    private var portraitNormalSizeCache: CGSize = .zero

    init(videoSizeRate: CGFloat, padding: CGFloat) {
        self.sizeRate = videoSizeRate == 0 ? 9 / 16 : videoSizeRate
        self.padding = padding == 0 ? 2 : padding
    }

    private func isValid(_ size: CGSize) -> Bool {
        size.width != 0 && size.height != 0
    }
}
