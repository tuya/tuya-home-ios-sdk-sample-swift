//
//  CameraCloudViewController+Biz.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

#if canImport(ThingSmartCloudServiceBizBundle)
let bizExists: Bool = true
#else
let bizExists = false
#endif

extension CameraCloudViewController {
    func gotoCloudServicePanel() {
        guard moduleExists(),
              ThingSmartCloudManager.isSupportCloudStorage(devId),
              let homeId = Home.current?.homeId else { return }

        let param: ThingSmartCameraVASParams = .init(
            spaceId: homeId,
            languageCode: Locale.preferredLanguages.first ?? "en",
            hybridType: .miniApp,
            categoryCode: .cloud,
            devId: devId,
            extInfo: nil
        )

        ThingSmartCameraVAS().fetchValueAddedServiceUrl(with: param) { result in
            guard let url = result?.url else { return }
            ThingModule.routeService()?.openRoute(url, withParams: nil)
        } failure: { [weak self] error in
            self?.showErrorTip(error?.localizedDescription)
        }
    }

    private func moduleExists() -> Bool {
        if (!bizExists) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showAlert(withMessage: IPCLocalizedString(key: "please import ThingSmartCloudServiceBizBundle")) { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }

        return bizExists
    }
}
