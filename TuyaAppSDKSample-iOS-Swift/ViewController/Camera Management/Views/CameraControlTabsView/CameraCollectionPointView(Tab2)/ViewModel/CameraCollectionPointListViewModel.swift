//
//  CameraCollectionPointListViewModel.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import Combine

class CameraCollectionPointListViewModel: ObservableObject {
    typealias Collection = ThingCameraCollectionPointModel

    @Published var collections = [Collection]()

    var isSupportOperation: Bool {
        ptzManager.couldOperateCollectionPoint()
    }

    private let ptzManager: ThingSmartPTZManager
    private var subscription: AnyCancellable?

    init(devId: String) {
        ptzManager = .init(deviceId: devId)
        fetchCollections()
        observeSelectin()
    }

    func rename(_ name: String?, for collection: Collection) {
        guard let name else { return }

        ptzManager.renameCollectionPoint(collection, name: name) { [weak self] in
            self?.fetchCollections()
            SVProgressHUD.showSuccess(withStatus: IPCLocalizedString(key: "success"))
        } failure: { error in
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }

    func delete(_ collection: Collection) {
        ptzManager.deleteCollectionPoints([collection]) { [weak self] in
            self?.fetchCollections()
            SVProgressHUD.showSuccess(withStatus: IPCLocalizedString(key: "success"))
        } failure: { error in
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }

    private func fetchCollections() {
        guard ptzManager.isSupportCollectionPoint() else { return }

        ptzManager.requestCollectionPointList { [weak self] result in
            guard let result = result as? [Collection] else { return }
            self?.collections = result
        } failure: { error in
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }
    
    private func observeSelectin() {
        subscription = NotificationCenter.default.publisher(for: DemoTabView.tabDidChange)
            .sink { [weak self] notf in
                guard let selection = notf.userInfo?["currentSelection"] as? Int,
                      selection == 2 else { return }
                self?.fetchCollections()
            }
    }
}
