//
//  DemoTabViewRepresented.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct CameraCalendarTabView<Content: View>: UIViewRepresentable {
    typealias UIViewType = DemoTabView

    @Binding var selection: Int
    @Binding var tabViews: [Content]
    @Binding var animate: Bool

    func makeUIView(context: Context) -> DemoTabView {
        let view = DemoTabView(tabViews: tabViews, bounces: true)
        view.didScrollToTab = { context.coordinator.parent.selection = $0 }
        DispatchQueue.main.async {
            view.scrollToTab(tabViews.count - 1, animated: false)
        }
        return view
    }
    
    func updateUIView(_ uiView: DemoTabView, context: Context) {
        DispatchQueue.main.async {
            uiView.rebindViews(tabViews.compactMap { UIHostingController(rootView: $0).view })
            uiView.scrollToTab(selection, animated: context.coordinator.parent.animate)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator {
        var parent: CameraCalendarTabView
        init(_ parent: CameraCalendarTabView) {
            self.parent = parent
        }
    }
}
