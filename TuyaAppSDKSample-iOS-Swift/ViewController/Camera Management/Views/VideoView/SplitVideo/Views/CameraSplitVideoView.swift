//
//  CameraSplitVideoView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class CameraSplitVideoView: CameraSplitVideoBaseView, DemoSplitVideoViewContextQuoterProtocol {
    weak var videoViewContext: DemoSplitVideoViewContextProtocol?
    weak var gestureDelegate: DemoSplitVideoViewGestureDelegate?

    var animatedDuration: TimeInterval
    var toolbarFolding: Bool = false

    var hasLocalizer: Bool {
        isSupportLocalizer
    }

    var isLandscape: Bool = false {
        didSet {
            if isLandscape {
                localizerView.showLocalizerView(false)
            }
            landscapeGradientLayer.isHidden = !isLandscape
        }
    }

    private(set) var videoNodeViews: [DemoSplitVideoNodeView]? {
        didSet {
            videoNodeViews?.forEach {
                $0.translatesAutoresizingMaskIntoConstraints = true
            }
        }
    }

    private var smallVideoViewsHidden: Bool = false
    private var showLocalizer: Bool = false

    private var sizeRate: CGFloat
    private var padding: CGFloat

    private var localizerLayoutStyle: CameraSplitVideoViewLocalizerLayoutStyle

    private var isSupportLocalizer: Bool {
        guard !isLandscape else { return false }
        return localizerLayoutStyle != .hidden
    }

    private lazy var localizerView: DemoVideoLocalizerView = {
        let localizerView = DemoVideoLocalizerView()
        localizerView.movedCompletion = { [weak self] coordinateInfo in
            _ = self?.videoViewContext?.videoOperator?.publishLocalizerCoordinateInfo(coordinateInfo)
        }
        return localizerView
    }()

    private lazy var landscapeGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        if let size = videoViewContext?.viewSizeCounter?.landscapeCoverSize {
            layer.frame = CGRect(origin: .init(x: 0, y: 0), size: size)
        }
        layer.contentsScale = UIScreen.main.scale
        layer.colors = [UIColor.clear, UIColor.black.withAlphaComponent(0.4)].map { $0.cgColor }
        layer.locations = [0, 1]
        layer.startPoint = .init(x: 0, y: 0)
        layer.endPoint = .init(x: 0, y: 1)
        self.layer.addSublayer(layer)
        return layer
    }()

    override init(frame: CGRect) {
        sizeRate = 9 / 16
        padding = 2
        animatedDuration = 0.3
        localizerLayoutStyle = .hidden
        super.init(frame: frame)
        addSubviews(localizerView)
        localizerView.translatesAutoresizingMaskIntoConstraints = true
    }

    deinit {
        print("CameraSplitVideoView - \(#function)")
        videoNodeViews?.forEach { $0.removeFromSuperview() }
        videoNodeViews = nil
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setToolbarFolding(_ folding: Bool) {
        toolbarFolding = folding
        localizerView.hideLocalizerViewImmediately()
    }

    func setSmallVideoViewsHidden(_ hidden: Bool) {
        smallVideoViewsHidden = hidden
    }

    func setShowLocalizer(_ show: Bool) {
        showLocalizer = show
        localizerView.showLocalizerView(show)
    }

    func destory() {
        videoNodeViews?.forEach { $0.removeFromSuperview() }
        videoNodeViews = nil
    }

    func rebindVideoNodeViews(_ videoNodesViews: [DemoSplitVideoNodeView]) {
        self.videoNodeViews = videoNodesViews
        guard !videoNodesViews.isEmpty else { return }
        videoNodesViews.forEach {
            $0.gestureDelegate = self
            $0.resetVideoIndex()
            addSubviews($0)
        }
        refreshLocalizerViewLayoutStyle()
        triggerLayoutImmediately()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard width != 0, height != 0, let videoViewContext, let videoNodeViews else { return }

        if isLandscape {
            if let firstSplitVideoNodeView = videoNodeViews.first {
                if firstSplitVideoNodeView.isMainView {
                    firstSplitVideoNodeView.frame = bounds
                } else {
                    let landscapeSmallSize = videoViewContext.viewSizeCounter?.landscapeSmallSize ?? .zero
                    let landscapeMargin = videoViewContext.viewSizeCounter?.landscapeViewMargin ?? .zero

                    let videoViewsHeight = CGFloat(videoNodeViews.count) * landscapeSmallSize.height
                    + CGFloat(max(0, videoNodeViews.count - 1)) * landscapeMargin

                    let videoViewsYOffset = (height - videoViewsHeight) / 2

                    let subviewWidth = landscapeSmallSize.width
                    let subviewHeight = landscapeSmallSize.height

                    videoNodeViews.enumerated().forEach { index, subview in
                        subview.frame = CGRect(
                            x: landscapeMargin,
                            y: videoViewsYOffset + CGFloat(index) * (subviewHeight + landscapeMargin),
                            width: subviewWidth,
                            height: subviewHeight
                        )
                    }
                }
                let landscapeGradientLayerSize = videoViewContext.viewSizeCounter?.landscapeCoverSize ?? .zero
                landscapeGradientLayer.frame = CGRectMake(
                    width - landscapeGradientLayerSize.width,
                    0,
                    landscapeGradientLayerSize.width,
                    landscapeGradientLayerSize.height
                )
            }
        } else {
            let totalPadding = CGFloat(max(0, videoNodeViews.count - 1)) * padding
            let subviewWidth = (width - totalPadding) / CGFloat(max(videoNodeViews.count, 1))
            let subviewHeight = subviewWidth * sizeRate
            videoNodeViews.enumerated().forEach { index, subview in
                subview.frame = CGRectMake(
                    CGFloat(index) * (subviewWidth + padding),
                    0,
                    subviewWidth,
                    subviewHeight
                )
            }
            if isSupportLocalizer {
                reloadLocalizerViewLayout()
            }
        }
    }

    private func refreshLocalizerViewLayoutStyle() {
        localizerLayoutStyle = .hidden

        if let firstVideoNode = videoNodeViews?.first, let lastVideoNode = videoNodeViews?.last {
            if firstVideoNode.splitVideoInfo.isLocalizer && lastVideoNode.splitVideoInfo.isLocalizer {
                localizerLayoutStyle = .full
            } else if firstVideoNode.splitVideoInfo.isLocalizer {
                localizerLayoutStyle = .halfLeft
            } else if lastVideoNode.splitVideoInfo.isLocalizer {
                localizerLayoutStyle = .halfRight
            }
        }
    }

    private func reloadLocalizerViewLayout() {
        bringSubviewToFront(localizerView)
        switch localizerLayoutStyle {
        case .hidden:
            break
        case .halfLeft:
            guard let firstViewFrame = videoNodeViews?.first?.frame else { return }
            localizerView.frame = firstViewFrame
        case .halfRight:
            guard let lastViewFrame = videoNodeViews?.last?.frame else { return }
            localizerView.frame = lastViewFrame
        case .full:
            localizerView.frame = bounds
        }
        localizerView.triggerLayoutImmediately()
    }

    private func hideLocalizerViewIfNeeded() {
        guard !isSupportLocalizer else { return }
        localizerView.showLocalizerView(false)
    }
}

extension CameraSplitVideoView: DemoSplitVideoViewGestureDelegate {
    func respondWeappedTapGesture(_ tapGesture: UITapGestureRecognizer) -> Bool {
        let tapPoint = tapGesture.location(in: self)
        var containsTapPoint = false
        containsTapPoint = localizerView.frame.contains(tapPoint)
        if containsTapPoint && isSupportLocalizer && showLocalizer {
            localizerView.showLocalizerView(true)
            return true
        }

        var wrapped = false
        let videoNodeView = filterNodeView(subview: tapGesture.view) as? DemoSplitVideoNodeView
        if let videoNodeView {
            wrapped = gestureDelegate?.didTapVideoNodeView(videoNodeView) ?? false
        }

        if !wrapped {
            _ = gestureDelegate?.respondWeappedTapGesture(tapGesture)
        }

        return wrapped

        func filterNodeView(subview: UIView?) -> UIView? {
            var currentSubview = subview
            while let superview = currentSubview?.superview {
                if currentSubview is DemoSplitVideoNodeView || currentSubview is UIWindow {
                    break
                }
                currentSubview = superview
            }
            return currentSubview
        }
    }
}
