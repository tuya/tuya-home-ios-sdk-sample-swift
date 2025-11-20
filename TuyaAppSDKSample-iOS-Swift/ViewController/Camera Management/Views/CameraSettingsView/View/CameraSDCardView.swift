//
//  CameraSDCardView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct CameraSDCardView: View {
    @ObservedObject var viewModel: CameraSDCardViewModel

    @State private var showAlert: Bool = false

    private static let titles: [String] = [
        "ipc_sdcard_capacity_total",
        "ipc_sdcard_capacity_used",
        "ipc_sdcard_capacity_residue"
    ].map { IPCLocalizedString(key: $0) }

    var body: some View {
        List {
            Section {
                ForEach(Self.titles.indices, id: \.self) { index in
                    row(title: Self.titles[index], value: viewModel.storageInfo[index])
                }
            } header: {
                Text(IPCLocalizedString(key: "ipc_sdcard_capacity"))
            }

            formatButton
        }
    }

    private func row(title: String, value: Int) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(String(format: "%.1fG", Double(value) / 1024 / 1024))
        }
    }

    private var formatButton: some View {
        Button {
            showAlert.toggle()
        } label:{
            HStack {
                Spacer()
                Text(IPCLocalizedString(key: "ipc_sdcard_format"))
                    .foregroundColor(.red)
                Spacer()
            }
        }
        .alert(isPresented: $showAlert) {
            .init(
                title: Text(IPCLocalizedString(key: "ipc_sdcard_format")),
                message: nil,
                primaryButton: .destructive(.init("确认"), action: {
                    viewModel.formatSDCard()
                }),
                secondaryButton: .cancel()
            )
        }
    }
}
