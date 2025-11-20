//
//  CameraMessageViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

class CameraMessageViewController: UIHostingController<CameraMessageView> {
    init(devId: String) {
        let viewModel = CameraMessageViewModel(devId: devId)
        super.init(rootView: CameraMessageView(viewModel: viewModel))
    }

    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
