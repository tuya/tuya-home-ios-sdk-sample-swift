//
//  DemoAppOrientationManager.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

extension DemoAppOrientationManager {
    enum DemoAppOrientation {
        case portrait
        case landscapeLeft
        case landscapeRight

        fileprivate var interfaceOrientation: UIInterfaceOrientation {
            switch self {
            case .portrait:
                    .portrait
            case .landscapeLeft:
                    .landscapeLeft
            case .landscapeRight:
                    .landscapeRight
            }
        }

        fileprivate var mask: UIInterfaceOrientationMask {
            switch self {
            case .portrait:
                    .portrait
            case .landscapeLeft:
                    .landscapeLeft
            case .landscapeRight:
                    .landscapeRight
            }
        }
    }
}

class DemoAppOrientationManager {
    static let shared = DemoAppOrientationManager()
    private init() {}

    var supportedOrientations: UIInterfaceOrientationMask {
        currentOrientation == .portrait ? .portrait : [.landscapeLeft, .landscapeRight]
    }

    private var currentOrientation: DemoAppOrientation = .portrait

    func rotate(to orientation: DemoAppOrientation) {
        currentOrientation = orientation

        UIViewController.attemptRotationToDeviceOrientation()

        if #available(iOS 16, *) {
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            scene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation.mask)) {
                print("Error rotating scene geometry: ", $0)
            }
        } else {
            UIDevice.current.setValue(orientation.interfaceOrientation.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}
