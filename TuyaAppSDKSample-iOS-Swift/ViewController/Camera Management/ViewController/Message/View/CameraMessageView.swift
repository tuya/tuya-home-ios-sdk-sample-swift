//
//  CameraMessageView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct CameraMessageView: View {
    @ObservedObject var viewModel: CameraMessageViewModel

    var body: some View {
        VStack {
            messageTypes

            DemoTabViewRepresented(
                selection: $viewModel.selection,
                tabs: Binding {
                    viewModel.messageTypes.map {
                        CameraMessageListView(messages: viewModel.messageModeList[$0.describe])
                    }
                } set: { _ in }
            )
        }
        .overlay(indicator)
    }

    private var messageTypes: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.messageTypes.map { $0.describe }, id: \.self) { type in
                    let index = viewModel.messageTypes.firstIndex(where: { $0.describe == type }) ?? 0
                    let isSelected = index == viewModel.selection

                    Button {
                        viewModel.selection = index
                    } label: {
                        Text(type)
                            .font(.system(size: 12))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .foregroundColor(isSelected ? .red : .primary)
                            .background(GeometryReader { proxy in
                                (isSelected ? Color.blue : Color.gray.opacity(0.3))
                                    .cornerRadius(proxy.size.height / 2)
                            })
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder private var indicator: some View {
        if #available(iOS 14, *), viewModel.isLoading {
            ProgressView()
        }
    }
}
