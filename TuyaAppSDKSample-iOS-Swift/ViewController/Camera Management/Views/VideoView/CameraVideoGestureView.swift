//
//  CameraVideoGestureView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

protocol CameraVideoGestureViewDelegate: AnyObject {
    func gestureView(_ gestureView: CameraVideoGestureView, didRecognizedPinchGesture pinchRecognizer: UIPinchGestureRecognizer, scaled scale: CGFloat, centerPoint cPoint: CGPoint)

    func gestureView(_ gestureView: CameraVideoGestureView, didRecognizedTapGesture tapRecognizer: UITapGestureRecognizer)

    func gestureView(_ gestureView: CameraVideoGestureView, didRecognizedDoubleTapGesture doubleTapRecognizer: UITapGestureRecognizer)

    func gestureView(_ gestureView: CameraVideoGestureView, didRecognizedPanGesture panRecognizer: UIPanGestureRecognizer, offser: CGPoint)
}

extension CameraVideoGestureViewDelegate {
    func gestureView(_ gestureView: CameraVideoGestureView, didRecognizedPinchGesture pinchRecognizer: UIPinchGestureRecognizer, scaled scale: CGFloat, centerPoint cPoint: CGPoint) {}

    func gestureView(_ gestureView: CameraVideoGestureView, didRecognizedTapGesture tapRecognizer: UITapGestureRecognizer){}

    func gestureView(_ gestureView: CameraVideoGestureView, didRecognizedDoubleTapGesture doubleTapRecognizer: UITapGestureRecognizer){}

    func gestureView(_ gestureView: CameraVideoGestureView, didRecognizedPanGesture panRecognizer: UIPanGestureRecognizer, offser: CGPoint){}
}

class CameraVideoGestureView: UIView, CameraVideoGestureViewDelegate, UIGestureRecognizerDelegate {
    weak var delegate: CameraVideoGestureViewDelegate?

    private var centerPoint: CGPoint = .zero

    init() {
        super.init(frame: .zero)
        addGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addGestures() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction))
        pinch.delegate = self
        addGestureRecognizer(pinch)

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tap.delegate = self
        addGestureRecognizer(tap)

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        addGestureRecognizer(doubleTap)
        tap.require(toFail: doubleTap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        pan.delegate = self
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        addGestureRecognizer(pan)
    }

    @objc
    private func pinchAction(recognizer: UIPinchGestureRecognizer) {
        guard recognizer.numberOfTouches >= 2 else { return }

        if recognizer.state == .began {
            let p1 = recognizer.location(ofTouch: 0, in: self)
            let p2 = recognizer.location(ofTouch: 1, in: self)
            centerPoint = .init(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
        }
        delegate?.gestureView(self, didRecognizedPinchGesture: recognizer, scaled: recognizer.scale,centerPoint: centerPoint)
        if recognizer.state == .ended {
            centerPoint = .zero
        }
    }

    @objc
    private func tapAction(recognizer: UITapGestureRecognizer) {
        delegate?.gestureView(self, didRecognizedTapGesture: recognizer)
    }

    @objc
    private func doubleTapAction(recognizer: UITapGestureRecognizer) {
        delegate?.gestureView(self, didRecognizedDoubleTapGesture: recognizer)
    }

    @objc
    private func panAction(recognizer: UIPanGestureRecognizer) {
        let point = recognizer.translation(in: self)
        delegate?.gestureView(self, didRecognizedPanGesture: recognizer, offser: point)
        recognizer.setTranslation(.zero, in: self)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
