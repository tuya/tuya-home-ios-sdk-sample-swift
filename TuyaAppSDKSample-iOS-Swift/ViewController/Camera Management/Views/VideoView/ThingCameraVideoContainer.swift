//
//  ThingCameraVideoContainer.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

protocol ThingCameraVideoContainerDelegate: AnyObject {
    func videoContainer<V: UIView>(_ videoContainer: V?, didTap tapRecognizer: UITapGestureRecognizer) where V: CameraVideoGestureViewDelegate

    func videoContainer<V: UIView>(_ videoContainer: V?, didDoubleTap tapRecognizer: UITapGestureRecognizer) where V: CameraVideoGestureViewDelegate

    func videoContainer<V: UIView>(_ videoContainer: V?, didZoomScale scale: CGFloat) where V: CameraVideoGestureViewDelegate
}

extension ThingCameraVideoContainerDelegate {
    func videoContainer<V: UIView>(_ videoContainer: V?, didTap tapRecognizer: UITapGestureRecognizer) where V: CameraVideoGestureViewDelegate {}

    func videoContainer<V: UIView>(_ videoContainer: V?, didDoubleTap tapRecognizer: UITapGestureRecognizer) where V: CameraVideoGestureViewDelegate {}

    func videoContainer<V: UIView>(_ videoContainer: V?, didZoomScale scale: CGFloat) where V: CameraVideoGestureViewDelegate {}
}

protocol ThingCameraVideoContainerProtocol: AnyObject {
    var delegate: ThingCameraVideoContainerDelegate? { get set }

    func clearImage()
}

class ThingCameraVideoContainer: UIView {
    weak var delegate: ThingCameraVideoContainerDelegate?

    var videoView: UIView? {
        didSet {
            if let oldValue {
                oldValue.removeFromSuperview()
            }
            setVideoView()
        }
    }

    var videoOffset: CGPoint {
        didSet {
            videoContainer.setContentOffset(videoOffset, animated: true)
        }
    }

    var videoScale: CGFloat {
        get {
            videoContainer.zoomScale
        }
        set {
            setVideoScale(newValue, animated: false)
        }
    }

    var minScale: CGFloat {
        get {
            videoContainer.minimumZoomScale
        }
        set {
            videoContainer.minimumZoomScale = newValue
        }
    }

    var maxScale: CGFloat {
        get {
            videoContainer.maximumZoomScale
        }
        set {
            videoContainer.maximumZoomScale = newValue
        }
    }

    var preferredScale: CGFloat
    var layoutContentView: ((_ contentView: UIView) -> Void)?

    lazy var videoGestureView: CameraVideoGestureView = {
        let videoGestureView = CameraVideoGestureView()
        videoGestureView.delegate = self
        return videoGestureView
    }()

    private lazy var videoContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bouncesZoom = false
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        scrollView.isMultipleTouchEnabled = true
        scrollView.scrollsToTop = false
        scrollView.bounces = false
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        return scrollView
    }()

    override init(frame: CGRect) {
        videoOffset = .zero
        preferredScale = 1.0
        super.init(frame: frame)

        addSubview(videoContainer)
        videoContainer.addSubview(videoGestureView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        videoGestureView.frame = bounds
        let scale = videoContainer.zoomScale
        videoContainer.zoomScale = 1.0
        videoContainer.frame = bounds

        if let layoutContentView {
            layoutContentView(videoGestureView)
        } else {
            let height = min(frame.height, frame.width / 16.0 * 9.0)
            videoGestureView.frame = CGRect(x: 0, y: 0, width: frame.width, height: height)
            videoGestureView.center = CGPoint(x: videoGestureView.center.x, y: frame.height / 2)
        }
        videoContainer.contentSize = videoContainer.frame.size
        videoView?.frame = videoGestureView.bounds
        videoContainer.zoomScale = scale
        videoContainer.contentOffset = videoOffset
    }

    func setVideoScale(_ scale: CGFloat, animated: Bool) {
        videoContainer.setZoomScale(scale, animated: animated)
        guard videoOffset.x != 0 || videoOffset.y != 0 else { return }
        videoContainer.setContentOffset(videoOffset, animated: false)
    }

    func thing_clear() {
        guard let videoView = videoView as? ThingSmartVideoViewType else { return }
        videoView.thing_clear()
    }

    private func clearImage() {
        guard let videoView = videoView as? ThingSmartVideoViewType else { return }
        videoView.thing_clear()
    }

    private func setVideoView() {
        guard let videoView else { return }

        thing_clear()
        videoView.isUserInteractionEnabled = true
        videoGestureView.addSubview(videoView)
        videoView.frame = videoGestureView.frame
        videoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

// MARK: - CameraVideoGestureViewDelegate
extension ThingCameraVideoContainer: CameraVideoGestureViewDelegate {
    func gestureView(_ gestureView: CameraVideoGestureView, didRecognizedDoubleTapGesture doubleTapRecognizer: UITapGestureRecognizer) {
        if videoScale > 1 {
            setVideoScale(1, animated: true)
        } else {
            setVideoScale(3.0, animated: true)
        }
        delegate?.videoContainer(self, didDoubleTap: doubleTapRecognizer)
    }

    func gestureView(_ gestureView: CameraVideoGestureView, didRecognizedTapGesture tapRecognizer: UITapGestureRecognizer) {
        delegate?.videoContainer(self, didTap: tapRecognizer)
    }
}

// MARK: - UIScrollViewDelegate
extension ThingCameraVideoContainer: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        videoGestureView
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.contentInset = .zero
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        refreshContentViewCenter(scrollView)
        delegate?.videoContainer(self, didZoomScale: scrollView.zoomScale)
    }

    private func refreshContentViewCenter(_ scrollView: UIScrollView) {
        let offsetX = scrollView.frame.width > scrollView.contentSize.width
        ? (scrollView.frame.width - scrollView.contentSize.width) / 2 : 0
        let offsetY = scrollView.frame.height > scrollView.contentSize.height
        ? (scrollView.frame.height - scrollView.contentSize.height) / 2 : 0
        videoGestureView.center = CGPoint(
            x: scrollView.contentSize.width / 2 + offsetX,
            y: scrollView.contentSize.height / 2 + offsetY
        )
    }
}
