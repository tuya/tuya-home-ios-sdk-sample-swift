//
//  CameraPTZSectorButtonView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct CameraPTZSectorButtonView: View {
    let direction: CameraPTZControlDirection
    let radius = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 2 - 96
    let onStart: (CameraPTZControlDirection) -> Void
    let onEnded: (CameraPTZControlDirection) -> Void

    @State private var isPressed = false

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let path = Path { path in
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: direction.arc.startAngle,
                    endAngle: direction.arc.endAngle,
                    clockwise: false
                )
                path.closeSubpath()
            }

            path
                .fill(Color.gray.opacity(0.3))
                .overlay(path.stroke(Color.blue, lineWidth: 2))
                .contentShape(path)
                .opacity(isPressed ? 0.45 : 1)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            guard !isPressed else { return }
                            isPressed = true
                            onStart(direction)
                        }
                        .onEnded { _ in
                            isPressed = false
                            onEnded(direction)
                        }
                )
        }
        .frame(width: radius * 2, height: radius * 2)
    }
}
