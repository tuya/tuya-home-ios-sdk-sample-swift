//
//  CameraCruiseView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct CameraCruiseView: View {
    @ObservedObject private var viewModel: CameraCruiseViewModel

    init(devId: String) {
        viewModel = .init(devId: devId)
    }

    var body: some View {
        VStack {
            baseSettings

            if viewModel.cruiseModeIsOn && viewModel.isSupportCruiseMode {
                cruiseSettings
            }

            Spacer()
        }
        .colorScheme(.light)
    }

    private var baseSettings: some View {
        VStack {
            Toggle(
                IPCLocalizedString(key: "Motion Detect"),
                isOn: Binding {
                    viewModel.motionDetectionIsOn
                } set: {
                    viewModel.setMotionIsOn($0)
                }
            )

            Toggle(
                IPCLocalizedString(key: "Open Cruise"),
                isOn: Binding {
                    viewModel.cruiseModeIsOn
                } set: {
                    viewModel.setCruiseIsOn($0)
                }
            )
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var cruiseSettings: some View {
        VStack {
            modePickersArea
        
            if viewModel.selectedCruiseTimeMode == .custom && viewModel.isSupportCruiseTime {
                datePickerArea
            }

            Spacer()

            if viewModel.settingsChanged {
                confirmButton
            }
        }
    }

    private var modePickersArea: some View {
        VStack(spacing: 0) {
            pickerRow("Cruise Mode", selection: $viewModel.selectedCruiseMode, dataSource: CameraCruiseMode.self)

            if viewModel.isSupportCruiseTime {
                pickerRow("Cruise Time", selection: $viewModel.selectedCruiseTimeMode, dataSource: CameraCruiseTimeMode.self)
            }
        }
        .padding(.top, 8)
    }

    private var datePickerArea: some View {
        HStack(spacing: 0) {
            VStack {
                Text(IPCLocalizedString(key: "Start Time"))
                DatePicker("", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }
            .frame(width: UIScreen.main.bounds.width / 2)

            VStack {
                Text(IPCLocalizedString(key: "End Time"))
                DatePicker("", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }
            .frame(width: UIScreen.main.bounds.width / 2)
        }
        .padding(.horizontal, 64)
        .padding(.top, 8)
    }

    private var confirmButton: some View {
        return HStack(spacing: 32) {
            Button(action: viewModel.reset) {
                buttonTitle("Cancel")
            }

            Button(action: viewModel.save) {
                buttonTitle("Confirm")
            }
        }

        func buttonTitle(_ titleKey: String) -> some View {
            Text(IPCLocalizedString(key: titleKey))
                .padding(.vertical, 8)
                .padding(.horizontal, 32)
                .background(Color.gray.opacity(0.45))
                .cornerRadius(4)
                .padding(.top, 8)
                .padding(.bottom, 32)
        }
    }
}

extension CameraCruiseView {
    private func  pickerRow<T: Hashable & CaseIterable & Identifiable & RawPresentable>(
        _ titleKey: String,
        selection: Binding<T>,
        dataSource: T.Type
    ) -> some View where T.AllCases: RandomAccessCollection {
        HStack {
            Text(IPCLocalizedString(key: titleKey))

            Spacer()

            Picker("", selection: selection.animation()) {
                ForEach(dataSource.allCases) { item in
                    Text(item.title)
                        .tag(item)
                }
            }
            .offset(x: 12)
        }
        .padding(.horizontal)
    }
}
