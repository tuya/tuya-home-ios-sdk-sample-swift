//
//  CameraSDCardViewModel.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class CameraSDCardViewModel: NSObject, ObservableObject {
    @Published var storageInfo: [Int] = Array(repeating: 0, count: 3)

    private var dpManager: ThingSmartCameraDPManager

    init(dpManager: ThingSmartCameraDPManager) {
        self.dpManager = dpManager
        super.init()

        dpManager.addObserver(self)
        fetchData()
    }

    func formatSDCard() {
        guard dpManager.isSupportDP(.sdCardFormatDPName) else { return }

        dpManager.setValue(true, forDP: .sdCardFormatDPName) { _ in

        } failure: { _ in

        }
    }

    private func fetchData() {
        dpManager.value(forDP: .sdCardStorageDPName) { [weak self] result in
            guard let components = (result as? String)?.components(separatedBy: "|").compactMap({ Int($0) }),
                  components.count >= 3 else { return }
            self?.storageInfo = components
        } failure: { error in
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }
}

extension CameraSDCardViewModel: ThingSmartCameraDPObserver {
    func cameraDPDidUpdate(_ manager: ThingSmartCameraDPManager!, dps dpsData: [AnyHashable : Any]!) {
        guard let progress = dpsData[ThingSmartCameraDPKey.sdCardFormatStateDPName] as? Int else { return }
        if progress >= 100 || progress < 0 {
            SVProgressHUD.dismiss()
            SVProgressHUD.setDefaultMaskType(.none)

            DispatchQueue.main.async {
                self.fetchData()
            }
        } else {
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.showProgress(Float(progress) / 100, status: IPCLocalizedString(key: "SD card format progress"))
        }
    }
}
