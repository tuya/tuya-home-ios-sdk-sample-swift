//
//  CameraPTZControlView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct CameraPTZControlView: View {
    private let viewModel: CameraPTZControlViewModel

    init(devId: String) {
        viewModel = CameraPTZControlViewModel(devId: devId)
    }

    @State private var viewHeight: CGFloat = 0

    var body: some View {
        GeometryReader { pxy in
            Color.clear.onAppear { viewHeight = max(viewHeight, pxy.size.height) }

            ScrollView(showsIndicators: false) {
                VStack {
                    directionButtonArea
                    buttonsArea
                    Spacer()
                }
                .frame(width: pxy.size.width, height: viewHeight)
            }
            .animation(.easeInOut(duration: 0.2))
        }
    }

    private var directionButtonArea: some View {
        ZStack {
            ForEach(CameraPTZControlDirection.allCases, id: \.self) {
                CameraPTZSectorButtonView(
                    direction: $0,
                    onStart: viewModel.directionBtnStart(_:),
                    onEnded: viewModel.directionBtnEnded(_:)
                )
            }
        }
        .overlay(directionArrows)
        .padding(.top, 8)
    }

    private var directionArrows: some View {
        ZStack {
            VStack {
                Image(systemName: "chevron.up")
                Spacer()
                Image(systemName: "chevron.down")
            }
            .padding(.vertical)

            HStack {
                Image(systemName: "chevron.left")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding(.horizontal)
        }
        .foregroundColor(.black)
    }

    private var buttonsArea: some View {
        HStack(spacing: 16) {
            collectionButtons
            zoomButtons
        }
        .padding(.top, 8)
    }

    private var collectionButtons: some View {
        return VStack {
            Button(action: showTextField){
                buttonLabel(IPCLocalizedString(key: "Add Collection Point"))
            }

            Button(action: { viewModel.savePreset1(for: 1) }) {
                buttonLabel(IPCLocalizedString(key: "Saved As Preset1"))
            }

            Button(action: { viewModel.savePreset1(for: 2) }) {
                buttonLabel(IPCLocalizedString(key: "Saved As Preset2"))
            }
        }
    }

    private var zoomButtons: some View {
        VStack {
            DemoLongPressButton {
                buttonLabel(IPCLocalizedString(key: "ZOOM IN"))
            } onStart: {
                viewModel.startZoomIn()
            } onEnded: {
                viewModel.stopZoom()
            }

            DemoLongPressButton {
                buttonLabel(IPCLocalizedString(key: "ZOOM OUT"))
            } onStart: {
                viewModel.startZoomOut()
            } onEnded: {
                viewModel.stopZoom()
            }
        }
        .foregroundColor(.black)
    }

    private func buttonLabel(_ title: String) -> some View {
        Text(title)
            .padding(.vertical, 6)
            .frame(width: 160)
            .background(Color.gray.opacity(0.35))
            .cornerRadius(6)
            .foregroundColor(.black)
    }
}

extension CameraPTZControlView {
    private func showTextField() {
        guard viewModel.isSupportCollectionPoint else {
            SVProgressHUD.showInfo(withStatus: IPCLocalizedString(key: "add collection point is unsupported"))
            return
        }

        let alertController = UIAlertController(title: IPCLocalizedString(key: "Add Collection Point"), message: nil, preferredStyle: .alert)

        alertController.addTextField { textfield in
            textfield.placeholder = IPCLocalizedString(key: "Input Name")
        }

        let cancelAction = UIAlertAction(title: IPCLocalizedString(key: "Cancel"), style: .cancel)
        let confirmAction = UIAlertAction(title: IPCLocalizedString(key: "Confirm"), style: .default) { [weak viewModel] _ in
            viewModel?.addCollectionPoint(alertController.textFields?.first?.text)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        UIApplication.shared.tp_topMostViewController?.present(alertController, animated: true)
    }
}
