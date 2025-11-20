//
//  CameraControlView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct CameraControlView: View {
    private static let numberOfColumns = 4
    private static let itemWidth = UIScreen.main.bounds.width / CGFloat(numberOfColumns)

    @EnvironmentObject private var viewModel: CameraControlViewModel

    var visiableControls: [CameraControlButtonItem] {
        viewModel.controlItems.filter { $0.isHidden == false }
    }

    var body: some View {
        Group {
            if #available(iOS 14, *) {
                lazyButtonGrid
            } else {
                buttonGrid
            }
        }
    }

    @available(iOS 14.0, *) private var lazyButtonGrid: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: (0..<Self.numberOfColumns).map { _ in .init(.fixed(Self.itemWidth), spacing: 0) },
                spacing: 0
            ) {
                ForEach(visiableControls, id: \.identifier) { item in
                   itemCell(for: item)
                }
            }
            .overlay(Color.black.frame(height: 1), alignment: .top)
        }
    }

    private var buttonGrid: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(chunkItems().indices, id: \.self) { rowIndex in
                    HStack(spacing: 0) {
                        ForEach(chunkItems()[rowIndex], id: \.identifier) { item in
                            itemCell(for: item)
                        }
                    }
                }
            }
            .overlay(Color.black.frame(height: 1), alignment: .top)
        }
    }

    @ViewBuilder
    private func itemCell(for item: CameraControlButtonItem) -> some View {
        if let title = item.title, let image = item.imagePath, !item.isHidden {
            Button {
                guard let identifier = item.identifier else { return }
                viewModel.onTapControl(identifier)
            } label: {
                VStack {
                    Image(uiImage: UIImage(named: image)!)
                        .renderingMode(.template)
                    Text(NSLocalizedString(title, tableName: "IPCLocalizable"))
                }
                .foregroundColor(colorFor(item.identifier))
            }
            .disabled(!item.isEnabled)
            .opacity(item.isEnabled ? 1 : 0.45)
            .frame(width: Self.itemWidth, height: Self.itemWidth)
            .overlay(Color.black.frame(width: 1), alignment: .trailing)
            .overlay(Color.black.frame(height: 1), alignment: .bottom)
        }
    }

    private func colorFor(_ identifier: CameraControlButtonItem.ControlConstants?) -> Color {
        if (identifier == .kControlTalk && viewModel.isTalking)
            || (identifier == .kControlRecord && viewModel.isRecording) {
            return .blue
        }
        return .black
    }
}

extension CameraControlView {
    private func chunkItems() -> [[CameraControlButtonItem]] {
        let origin = visiableControls
        var chunks = [[CameraControlButtonItem]]()
        var chunk = [CameraControlButtonItem]()

        origin.forEach {
            chunk.append($0)
            if chunk.count == Self.numberOfColumns {
                chunks.append(chunk)
                chunk.removeAll()
            }
        }

        if !chunk.isEmpty {
            chunks.append(chunk)
        }

        return chunks
    }
}
