//
//  CameraSettingsView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct CameraSettingsView: View {
    @ObservedObject private var viewModel: CameraSettingsViewModel

    private typealias SettingItem = CameraSettingSection.CameraSettingItem

    init(withDevId devId: String, dpManager: ThingSmartCameraDPManager) {
        viewModel = CameraSettingsViewModel(devId: devId, dpManager: dpManager)
    }

    var body: some View {
        List {
            ForEach(viewModel.settingData, id: \.sectionTitle) { section in
                Section {
                    ForEach(section.items, id: \.dpName) { setting in
                        if !setting.isHidden {
                            settingRow(with: setting)
                        }
                    }
                } header: {
                    Text("\(section.sectionTitle)")
                }
            }

            deleteButton
        }
    }

    private func settingRow(with setting: SettingItem) -> some View {
        HStack {
            Text(setting.title)
                .foregroundColor(.primary)
            Spacer()
            rowTrailing(for: setting)
        }
        .frame(height: 50)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            guard case .arrow = setting.trailing else { return }
            setting.action?(setting.title)
        }
    }

    @ViewBuilder
    private func rowTrailing(for setting: SettingItem) -> some View {
        switch setting.trailing {
        case .arrow(let title):
            HStack {
                Text(title)
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        case .label(let title):
            Text(title)
                .foregroundColor(.secondary)
        case .switch(let isOn):
            Toggle(isOn: Binding {
                isOn
            } set: { [weak viewModel] value in
                viewModel?.dpSwitch(value, dpName: setting.dpName)
            }) {}
        }
    }

    private var deleteButton: some View {
        Button(action: viewModel.removeDevice) {
            HStack {
                Spacer()
                Text(NSLocalizedString("cancel_connect", tableName: "IPCLocalizable"))
                    .foregroundColor(.red)
                Spacer()
            }
        }
    }
}
