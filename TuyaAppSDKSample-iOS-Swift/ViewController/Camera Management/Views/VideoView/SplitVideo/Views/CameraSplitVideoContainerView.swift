//
//  CameraSplitVideoContainerView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class CameraSplitVideoContainerView: UIView {
    var frameSize: CGSize = .zero {
        didSet {
            setNeedsLayout()
        }
    }

    private var isLandscape: Bool = false
    private var videoViewDispatcher: DemoSplitVideoViewDispatcher?
    private var needsTriggerLayoutFlag: Bool = false
    private var cameraDevice: CameraDevice?

    init(cameraDevice: CameraDevice, videoViewDispatcher: DemoSplitVideoViewDispatcher) {
        self.cameraDevice = cameraDevice
        self.videoViewDispatcher = videoViewDispatcher
        super.init(frame: .zero)

        backgroundColor = .black
        clipsToBounds = true

        rebindSplitVideoCoverViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        videoViewDispatcher?.destoryBindViews()
        videoViewDispatcher = nil
        cameraDevice = nil
        print("CameraSplitVideoContainerView deinit")
    }

    func setToolBarFolding(_ folding: Bool) {
        videoViewDispatcher?.setToolbarFolding(folding)
    }

    func setSmallVideoViewsHidden(_ hidden: Bool) {
        videoViewDispatcher?.setSmallVideoViewsHidden(hidden)
    }

    func setShowLocalizer(_ show: Bool) {
        videoViewDispatcher?.setShowLocalizer(show)
    }

    func setLandscape(_ isLandscape: Bool) {
        self.isLandscape = isLandscape
        videoViewDispatcher?.relayoutBindViewsBasedOnSuperView(self, isLandscape: isLandscape)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard height != 0, width != 0 else { return }
        videoViewDispatcher?.relayoutBindViewsBasedOnSuperView(self, isLandscape: isLandscape)
    }

    private func rebindSplitVideoCoverViews() {
        videoViewDispatcher?.bindViews.forEach {
            addSubview($0)
        }
        videoViewDispatcher?.rebindVideoNodeViews()
    }

    private func triggerLayoutImmediately() {
        needsTriggerLayoutFlag = true
        DispatchQueue.main.async { [weak self] in
            self?.triggerLayoutImmediatelyIfNeeded()
        }
    }

    private func triggerLayoutImmediatelyIfNeeded() {
        guard needsTriggerLayoutFlag else { return }
        needsTriggerLayoutFlag = false
        setNeedsLayout()
        layoutIfNeeded()
    }
}
