//
//  CameraCollectionPointListView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

extension CameraCollectionPointListView {
    private typealias Collection = ThingCameraCollectionPointModel

    private enum ButtonType: CaseIterable {
        case rename
        case delete

        var title: String {
            IPCLocalizedString(key: self == .rename ? "rename" : "remove")
        }
    }
}

struct CameraCollectionPointListView: View {
    @ObservedObject private var viewModel: CameraCollectionPointListViewModel
    @State private var data: [Int] = []

    init(devId: String) {
        self.viewModel = .init(devId: devId)
    }

    var body: some View {
        if viewModel.collections.isEmpty {
            Text("Empty")
                .foregroundColor(.black)
        } else {
            listView {
                ForEach(viewModel.collections, id: \.pointId) {
                    collectionCell(for: $0)
                }
            }
        }
    }

    private func listView(content: () -> some View) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            if #available(iOS 14, *) {
                LazyVStack {
                    content()
                }
                .padding(.top, 8)
            } else {
                VStack {
                    content()
                }
                .padding(.top, 8)
            }
        }
    }

    @ViewBuilder private func collectionCell(for collection: Collection) -> some View {
        HStack {
            DemoAESImageView(path: collection.pic, key: collection.encryption)
                .frame(width: 128, height: 72)
                .cornerRadius(8)

            Text(collection.name)

            Spacer()

            buttonsArea(collection)
        }
        .padding(.trailing, 8)
        .foregroundColor(.black)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal, 8)
    }

    private func buttonsArea(_ collection: Collection) -> some View {
        VStack {
            ForEach(ButtonType.allCases, id: \.title) { type in
                Button {
                    onTapCollection(collection, type: type)
                } label: {
                    Text(type.title)
                        .padding(.vertical, 4)
                        .frame(width: 60)
                        .background(Color.gray.opacity(0.6))
                        .cornerRadius(4)
                }
            }
        }
    }
}

extension CameraCollectionPointListView {
    private func onTapCollection(_ collection: Collection, type: ButtonType) {
        guard viewModel.isSupportOperation else {
            SVProgressHUD.showInfo(withStatus: IPCLocalizedString(key: "Not editable in site patrol mode"))
            return
        }

        let title = [type == .rename ? "edit" : "operation_delete", "Collection Points"].map {
            IPCLocalizedString(key: $0)
        }.joined()

        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)

        if type == .rename {
            alert.addTextField { $0.placeholder = collection.name }
        }

        alert.addAction(.init(title: IPCLocalizedString(key: "cancel"), style: .cancel))
        alert.addAction(.init(
            title: IPCLocalizedString(key: "Confirm"),
            style: .default,
            handler: { _ in
                type == .rename
                ? viewModel.rename(alert.textFields?.first?.text, for: collection)
                : viewModel.delete(collection)
        }))

        UIApplication.shared.tp_topMostViewController?.present(alert, animated: true)
    }
}
