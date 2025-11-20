//
//  CameraViewController+Properties.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

extension CameraViewController {
    var bottomSwitchViewHeight: CGFloat {
        44 + (UIApplication.shared.tp_mainWindow()?.safeAreaInsets.bottom ?? 0)
    }

    var videoWidth: CGFloat {
        min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    }

    var videoHeight: CGFloat {
        videoWidth / 16 * 9
    }

    var fullScreenVideoWidth: CGFloat {
        max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    }

    var fullScreenVideoHeight: CGFloat {
        fullScreenVideoWidth / 16 * 9
    }
}
