//
//  RequestHandler.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import MatterSupport
import ThingSmartMatterExtensionKit

// The extension is launched in response to `MatterAddDeviceRequest.perform()` and this class is the entry point
// for the extension operations.
class RequestHandler: MatterAddDeviceExtensionRequestHandler {
    
    override init() {
        super.init()
        ThingMatterExtensionSupport.shared.setMatterConfigKey(configKey: "your group id")
    }
    
    override func validateDeviceCredential(_ deviceCredential: MatterAddDeviceExtensionRequestHandler.DeviceCredential) async throws {
        ThingMatterExtensionSupport.shared.validateDeviceCredential(deviceCredential)
    }

    override func selectWiFiNetwork(from wifiScanResults: [MatterAddDeviceExtensionRequestHandler.WiFiScanResult]) async throws -> MatterAddDeviceExtensionRequestHandler.WiFiNetworkAssociation {
        // Use this function to select a Wi-Fi network for the device if your ecosystem has special requirements.
        // Or, return `.defaultSystemNetwork` to use the iOS device's current network.
        return ThingMatterExtensionSupport.shared.selectWiFiNetwork(from: wifiScanResults)
    }

    override func selectThreadNetwork(from threadScanResults: [MatterAddDeviceExtensionRequestHandler.ThreadScanResult]) async throws -> MatterAddDeviceExtensionRequestHandler.ThreadNetworkAssociation {
        // Use this function to select a Thread network for the device if your ecosystem has special requirements.
        // Or, return `.defaultSystemNetwork` to use the default Thread network.
        return ThingMatterExtensionSupport.shared.selectThreadNetwork(from: threadScanResults)
    }

    override func commissionDevice(in home: MatterAddDeviceRequest.Home?, onboardingPayload: String, commissioningID: UUID) async throws {
        // Use this function to commission the device with your Matter stack.
        ThingMatterExtensionSupport.shared.commissionDevice(in: home, onboardingPayload: onboardingPayload, commissioningID: commissioningID)
    }

    override func rooms(in home: MatterAddDeviceRequest.Home?) async -> [MatterAddDeviceRequest.Room] {
        // Use this function to return the rooms your ecosystem manages.
        // If your ecosystem manages multiple homes, ensure you are returning rooms that belong to the provided home.
        return ThingMatterExtensionSupport.shared.rooms(in: home)
    }

    override func configureDevice(named name: String, in room: MatterAddDeviceRequest.Room?) async {
        // Use this function to configure the (now) commissioned device with the given name and room.
        ThingMatterExtensionSupport.shared.configureDevice(named: name, in: room)
    }
}
