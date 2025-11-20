//
//  DemoSplitVideoNodeView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import ThingSmartMediaUIKit

class DemoSplitVideoNodeView: CameraSplitVideoBaseView {
    var isMainView: Bool = false
    weak var gestureDelegate: DemoSplitVideoViewGestureDelegate?

    var currentVideoIndex: ThingSmartVideoIndex

    var frameSize: CGSize? {
        didSet {
            guard let frameSize, frameSize.width != 0, frameSize.height != 0 else { return }
            guard let oldValue, !oldValue.equalTo(frameSize) else { return }
            triggerLayoutImmediately()
        }
    }

    private var videoViewHToWRate: CGFloat {
        guard var sizeRate = splitVideoInfo.frame_infos.first?.sizeRate else { return .zero }
        if let frameSize, frameSize.height > 0 && frameSize.width > 0 {
            sizeRate = frameSize.height / frameSize.width
        }
        return sizeRate
    }

    private(set) var videoView: UIView & ThingSmartVideoViewType
    private(set) var splitVideoInfo: DemoSplitVideoInfo

    private weak var videoViewContext: DemoSplitVideoViewContextProtocol?

    init(videoViewContext: DemoSplitVideoViewContextProtocol, splitVideoInfo: DemoSplitVideoInfo) {
        self.videoViewContext = videoViewContext
        self.splitVideoInfo = splitVideoInfo
        videoView = ThingSmartMediaVideoView(frame: .zero)
        currentVideoIndex = splitVideoInfo.index
        super.init(frame: .zero)

        backgroundColor = .black
        addSubview(videoView)

        _ = videoViewContext.videoOperator?.bindVideoView(videoView, videoIndex: splitVideoInfo.index)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        _ = videoViewContext?.videoOperator?.unbindVideoView(videoView, forVideoIndex: splitVideoInfo.index)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard height != 0, width != 0 else { return }
        let selfViewHTowRate = height / width
        var videoViewWidth = width
        var videoViewHeight = width * videoViewHToWRate
        if videoViewHToWRate > selfViewHTowRate {
            videoViewHeight = height
            videoViewWidth = videoViewHeight / videoViewHToWRate
        }
        videoView.snp.makeConstraints { make in
            make.width.equalTo(videoViewWidth)
            make.height.equalTo(videoViewHeight)
            make.center.equalToSuperview()
        }
    }

    func resetVideoIndex() {
        _ = videoViewContext?.videoOperator?.bindVideoView(videoView, videoIndex: splitVideoInfo.index)
    }

    @objc
    private func tapAction(recognizer: UITapGestureRecognizer) {
        _ = gestureDelegate?.respondWeappedTapGesture(recognizer)
    }
}
