//
//  CameraSplitVideoBaseView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class CameraSplitVideoBaseView: UIView {
    func triggerLayoutImmediately()  {
        setNeedsLayout()
        layoutIfNeeded()
    }

    deinit {
        print("\(#function)")
    }
}
