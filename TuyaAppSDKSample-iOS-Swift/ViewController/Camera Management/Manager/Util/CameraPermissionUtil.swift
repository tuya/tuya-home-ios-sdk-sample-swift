//
//  CameraPermissionUtil.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import Photos

struct CameraPermissionUtil {
    // MARK: - Photo Permission
    static var isPhotoLibraryNotDetermined: Bool {
        PHPhotoLibrary.authorizationStatus() == .notDetermined
    }

    static var isPhotoLibraryDenied: Bool {
         [.restricted, .denied].contains(PHPhotoLibrary.authorizationStatus())
    }

    static var isPhotoLibraryAuthorized: Bool {
        PHPhotoLibrary.authorizationStatus() == .authorized
    }

    static func requestPhotoPermission(result: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                result(status == .authorized)
            }
        }
    }

    // MARK: - Microphone Permission
    static var microNotDetermined: Bool {
        AVCaptureDevice.authorizationStatus(for: .audio) == .notDetermined
    }

    static var microDenied: Bool {
        AVAudioSession.sharedInstance().recordPermission == .denied
    }

    static func requestAccessForMicro(result: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                result(granted)
            }
        }
    }

    // MARK: - Camera Permission
    static var cameraNotDetermined: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
    }

    static var cameraDenied: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .denied
    }

    static func requestAccessForCamera(result: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                result(granted)
            }
        }
    }

    private init() {}
}
