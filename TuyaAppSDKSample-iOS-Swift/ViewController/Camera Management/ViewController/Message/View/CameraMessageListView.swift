//
//  CameraMessageListView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct CameraMessageListView: View {
    let messages: [ThingSmartCameraMessageModel]?

    var body: some View {
        List {
            ForEach(messages ?? [], id: \.msgId) { message in
                listCell(for: message)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        CameraMessageImageDownloader.shared.download(with: message.attachPic)
                    }
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private func listCell(for message: ThingSmartCameraMessageModel) -> some View {
        HStack {
            DemoAESImageView(attachPic: message.attachPic)
                .frame(width: 88, height: 50)

            VStack(alignment: .leading, spacing: 8) {
                Text(message.msgTitle)
                    .font(.system(size: 17))

                Text(message.msgContent)
                    .font(.system(size: 12))
            }
            .padding(.leading, 8)

            Spacer()
        }
    }

    private var placeholder: some View {
        Color.clear.frame(width: 88, height: 50)
    }
}
