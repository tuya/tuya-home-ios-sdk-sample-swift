//
//  DemoVideoLocalizerView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import Combine

class DemoVideoLocalizerView: CameraSplitVideoBaseView {
    var movedCompletion: ((String) -> Void)?

    var isSelected: Bool = false {
        didSet {
            guard isSelected != oldValue else { return }
            innerLocalizerView.refreshUIApperance(with: isSelected)
            let currentColor = isSelected ? selectedColor : normalColor
            outerTopLineView.backgroundColor = currentColor
            outerBottomLineView.backgroundColor = currentColor
            outerLeftLineView.backgroundColor = currentColor
            outerRightLineView.backgroundColor = currentColor
        }
    }

    private(set) var isLocalizerShown: Bool = false

    private var selectedColor: UIColor
    private var normalColor: UIColor

    private lazy var innerLocalizerView: DemoVideoInnerLocalizerView = {
        DemoVideoInnerLocalizerView(
            frame: .init(x: 0, y: 0, width: 23, height: 23),
            normalColor: normalColor,
            selectedColor: selectedColor
        )
    }()
    // 定位器辅助线
    private lazy var outerTopLineView: UIView = { generateNormalOuterLineView() }()
    private lazy var outerBottomLineView: UIView = { generateNormalOuterLineView() }()
    private lazy var outerLeftLineView: UIView = { generateNormalOuterLineView() }()
    private lazy var outerRightLineView: UIView = { generateNormalOuterLineView() }()

    private var isFirstIn: Bool = true

    private var timer: AnyCancellable?

    private let localizerLockQueue = DispatchQueue(label: "com.demo.localizerLockQueue", attributes: .concurrent)

    private var safeLocalizerShown: Bool {
        localizerLockQueue.sync {
            isLocalizerShown
        }
    }

    override init(frame: CGRect) {
        isFirstIn = true
        selectedColor = .init(demo_withHex: 0xFF592A)
        normalColor = .white
        super.init(frame: frame)

        addSubviews(innerLocalizerView, outerTopLineView, outerBottomLineView, outerLeftLineView, outerRightLineView)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(localizerViewPanAction))
        panGesture.delegate = self
        innerLocalizerView.addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(localizerViewTapAction))
        tapGesture.delegate = self
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)

        safeSetLocalizerShown(false)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard self.width != 0, self.height != 0 else { return }
        if isFirstIn {
            isFirstIn = false
            innerLocalizerView.center = CGPoint(x: self.width / 2, y: self.height / 2)
        }
        realtimeReloadOuterLineViewsFrame()
    }

    func showLocalizerView(_ show: Bool) {
        if show {
            showLocalizerAnimated()
        } else {
            hideLocalizerAnimated()
        }
    }

    func hideLocalizerViewImmediately() {
        safeSetLocalizerShown(false)
        invalidateTimer()
    }

    private func showLocalizerAnimated() {
        guard width != 0, height != 0, !safeLocalizerShown else { return }
        //每次展示前都要以中心位置进行展示
        innerLocalizerView.center = CGPoint(x: width * 0.5, y: height * 0.5)
        realtimeReloadOuterLineViewsFrame()

        isSelected = false
        invalidateTimer()

        UIView.animate(withDuration: 0.25) {
            self.safeSetLocalizerShown(true)
        }

        startTimer()
    }

    private func hideLocalizerAnimated() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.safeSetLocalizerShown(false)
        } completion: { [weak self] _ in
            self?.invalidateTimer()
        }
    }

    private func generateNormalOuterLineView() -> UIView {
        let lineView = UIView()
        lineView.backgroundColor = .white
        return lineView
    }

    private func safeSetLocalizerShown(_ shown: Bool) {
        localizerLockQueue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async { [weak self] in
                self?.isHidden = !shown
            }
            isLocalizerShown = shown
        }
    }
}

// MARK: - Frames
extension DemoVideoLocalizerView {
    private func realtimeReloadOuterLineViewsFrame() {
        outerTopLineView.frame = outerTopLineViewFrame
        outerBottomLineView.frame = outerBottomLineViewFrame
        outerLeftLineView.frame = outerleftLineViewFrame
        outerRightLineView.frame = outerRightLineViewFrame
    }

    private var outerTopLineViewFrame: CGRect {
        CGRectMake(
            innerLocalizerView.center.x - Self.kLocalizerOuterLineViewWidth * 0.5,
            0,
            Self.kLocalizerOuterLineViewWidth,
            innerLocalizerView.frame.origin.y - Self.kLocalizerOuterLineViewMargin
        )
    }

    private var outerBottomLineViewFrame: CGRect {
        let bottom = innerLocalizerView.frame.origin.y + innerLocalizerView.frame.size.height
        let originY = bottom + Self.kLocalizerOuterLineViewMargin
        return CGRectMake(
            innerLocalizerView.center.x - Self.kLocalizerOuterLineViewMargin * 0.5,
            originY,
            Self.kLocalizerOuterLineViewWidth,
            height - originY
        )
    }

    private var outerleftLineViewFrame: CGRect {
        CGRectMake(
            0,
            innerLocalizerView.center.y - Self.kLocalizerOuterLineViewWidth * 0.5,
            innerLocalizerView.frame.origin.x - Self.kLocalizerOuterLineViewMargin,
            Self.kLocalizerOuterLineViewWidth
        )
    }

    private var outerRightLineViewFrame: CGRect {
        let right = innerLocalizerView.frame.origin.x + innerLocalizerView.frame.size.width
        let originX = right + Self.kLocalizerOuterLineViewMargin
        return CGRectMake(
            originX, innerLocalizerView.center.y - Self.kLocalizerOuterLineViewWidth * 0.5,
            width - originX,
            Self.kLocalizerOuterLineViewWidth
        )
    }
}

// MARK: - Timer
extension DemoVideoLocalizerView {
    private func startTimer() {
        invalidateTimer()
        timer = Timer.publish(every: 3, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.hideLocalizerAnimated()
            }
    }

    private func invalidateTimer() {
        timer?.cancel()
        timer = nil
    }
}

// MARK: - Gesture
extension DemoVideoLocalizerView: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard gestureRecognizer != self else { return true }
        if let gestureRecognizers,
           gestureRecognizers.contains(gestureRecognizer),
           gestureRecognizers.contains(otherGestureRecognizer) {
            return true
        }
        return false
    }

    private func updateLocalizerViewTimerWhenGestureRecorgerStateChange(_ recognizer: UIGestureRecognizer) {
        let center = innerLocalizerView.center
        let x = center.x / width
        let y = center.y / height

        let dpInfo = String(format: "%.0f,%.0f", x * 100, y * 100)

        // 结束手势时，开启timer
        if recognizer.state == .ended {
            startTimer()
            if let movedCompletion {
                movedCompletion(dpInfo)
            }
        }

        if recognizer.state == .began {
            invalidateTimer()
        }
        isSelected = true
    }

    @objc
    private func localizerViewPanAction(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        // 更新瞄准器位置
        var center = innerLocalizerView.center
        center.x += translation.x
        center.y += translation.y

        realtimeReloadOuterLineViewsFrame()

        // 结束手势时开启timer
        updateLocalizerViewTimerWhenGestureRecorgerStateChange(recognizer)

        recognizer.setTranslation(.zero, in: self)
        var newCenter = CGPoint(x: center.x, y: center.y)
        // 超出虚线区域范围不可操作
        if center.x <= 0 { newCenter.x = 0 }
        if center.x >= width { newCenter.x = width }
        if center.y <= 0 { newCenter.y = 0 }
        if center.y >= height { newCenter.y = height }
        innerLocalizerView.center = newCenter
    }

    @objc
    private func localizerViewTapAction(_ recognizer: UITapGestureRecognizer) {
        let tapCenter = recognizer.location(in: recognizer.view)
        // 虚线范围外的区域不可点击
        if tapCenter.x < 0 || tapCenter.x > width || tapCenter.y < 0 || tapCenter.y > height {
            return
        }
        // 定位器展示过程中再次触发点击手势，修改定位器中点
        if safeLocalizerShown {
            innerLocalizerView.center = tapCenter
            realtimeReloadOuterLineViewsFrame()
            updateLocalizerViewTimerWhenGestureRecorgerStateChange(recognizer)
            return
        }
        showLocalizerView(true)
    }
}
