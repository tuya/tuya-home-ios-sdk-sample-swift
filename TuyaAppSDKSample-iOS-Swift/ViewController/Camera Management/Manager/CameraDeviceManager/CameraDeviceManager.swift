//
//  CameraDeviceManager.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class CameraDeviceManager {
    static let shared = CameraDeviceManager()

    private var cameraDevices: NSMapTable<NSString, CameraDevice>
    private let queue = DispatchQueue(label: "com.demo.CameraDeviceManager")

    private init() {
        cameraDevices = NSMapTable.strongToWeakObjects()
    }

    func getCameraDevice(devId: String) -> CameraDevice? {
        queue.sync {
            if let device = cameraDevices.object(forKey: devId as NSString) {
                return device
            } else {
                let newDevice = CameraDevice(deviceId: devId)
                cameraDevices.setObject(newDevice, forKey: devId as NSString)
                return newDevice
            }
        }
    }
}
