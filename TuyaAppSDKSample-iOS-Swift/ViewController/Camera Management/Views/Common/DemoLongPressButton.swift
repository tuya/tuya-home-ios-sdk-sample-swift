//
//  DemoLongPressButton.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct DemoLongPressButton<Label: View>: View {
    @ViewBuilder let label: () -> Label
    let onStart: () -> Void
    let onEnded: () -> Void

    @State private var isPressed = false

    var body: some View {
        label()
            .opacity(isPressed ? 0.35 : 1)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isPressed else { return }
                        isPressed = true
                        onStart()
                    }
                    .onEnded { _ in
                        isPressed = false
                        onEnded()
                    }
            )
    }
}
