//
//  CameraCalendarView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct CameraCalendarView: View {
    @Environment(\.presentationMode) private var presentationMode

    @ObservedObject private var viewModel: CameraCalendarViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                titleArea

                Spacer()

                weekdayLabels

                CameraCalendarTabView(
                    selection: $viewModel.selection,
                    tabViews: Binding {
                        [0, 1, 2].map {
                            viewModel.months[$0]
                        }.map {
                            CameraCalendarMonthlyView(
                                month: $0,
                                playbackDays: viewModel.playbackDays[$0.components.monthKey ?? ""],
                                selectedDay: $viewModel.selectedDay,
                                onTapDay: viewModel.onSelectDay
                            )
                        }
                    } set: { _ in },
                    animate: $viewModel.animate
                )
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .frame(width: 300, height: 365)
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(
            Color.black.opacity(0.4)
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
        )
        .onDisappear {
            viewModel.onDisAppera()
        }
        .onReceive(viewModel.$selectedDay.dropFirst()) { _ in
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var titleArea: some View {
        HStack {
            Button {
                viewModel.jumpToMonth(for: .prev)
            } label: {
                Image(uiImage: UIImage(named: "pps_left_arrow")!)
                    .frame(width: 50, height: 50)
            }

            Text(viewModel.title)

            Button {
                viewModel.jumpToMonth(for: .next)
            } label: {
                Image(uiImage: UIImage(named: "pps_right_arrow")!)
                    .frame(width: 50, height: 50)
            }
        }
    }

    private var weekdayLabels: some View {
        HStack(spacing: 0) {
            ForEach(CameraCalendarMonth.weekDayTitles, id: \.self) { title in
                Text(title)
                    .font(.system(size: 10))
                    .frame(width: 40)
            }
        }
        .padding(.bottom, 8)
    }
}

extension CameraCalendarView {
    static func show(viewModel: CameraCalendarViewModel) {
        let vc = UIHostingController(
            rootView: CameraCalendarView(viewModel: viewModel).edgesIgnoringSafeArea(.all)
        )
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = .clear
        UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
    }
}
