//
//  DemoTabViewRepresented.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct DemoTabViewRepresented<Content: View>: UIViewRepresentable {
    typealias UIViewType = DemoTabView
    
    @Binding var selection: Int
    @Binding var tabs: [Content]

    func makeUIView(context: Context) -> DemoTabView {
        let view = DemoTabView(tabViews: tabs, bounces: true)
        view.didScrollToTab = { tab in
            context.coordinator.parent.selection = tab
        }
        return view
    }

    func updateUIView(_ uiView: DemoTabView, context: Context) {
        uiView.scrollToTab(selection, animated: true)
        uiView.rebindViews(tabs.map { UIHostingController(rootView: $0).view })
        context.coordinator.oldTabs = tabs
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator {
        var parent: DemoTabViewRepresented
        var oldTabs: [Content] = []

        init(_ parent: DemoTabViewRepresented) {
            self.parent = parent
            oldTabs = parent.tabs
        }
    }
}
