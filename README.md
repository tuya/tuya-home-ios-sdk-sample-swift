# Tuya iOS HomeSDK Sample for Swift

This sample demonstrates the use of Tuya iOS HomeSDK to build an IoT app from scratch. Tuya iOS HomeSDK is divided into several function groups to give developers a clear insight into the implementation of different features, including the user registration process, home management for different users, device network configuration, and controls. For device network configuration, the EZ mode and AP mode are implemented. This allows developers to pair devices over Wi-Fi and control the devices over LAN and MQTT. For device control, a common panel is used to send and receive any types of data points.

<img src="https://github.com/tuya/tuya-home-ios-sdk-sample-swift/raw/main/snapshot.png" alt="Tuya Smart app" width="300"/>

## Prerequisites
* Xcode 12.0 and later
* iOS 12 and later


## Use the sample
1. The Tuya iOS HomeSDK is distributed through [CocoaPods](http://cocoapods.org/) and other dependencies in this sample. Make sure that you have installed CocoaPods. If not, run the following command to install CocoaPods first:

```bash
sudo gem install cocoapods
pod setup
```

2. Clone or download this sample, change the directory to the one that includes **Podfile**, and then run the following command:

```bash
pod install
```

3. This sample requires you to have a pair of keys and a security image from the [Tuya IoT Platform](https://developer.tuya.com/), and register a developer account if you don't have one. Then, perform the following steps:
	1. Log in to the [Tuya IoT platform](https://iot.tuya.com). In the left-side navigation pane, choose **App** > **SDK Development**.
	2. Click **Create** to create an app.
	3. Fill in the required information. Make sure that you enter the valid Bundle ID. It cannot be changed afterward.
	4. You can find the AppKey, AppSecret, and security image under the **Obtain Key** tag.

4. Open the `TuyaAppSDKSample-iOS-Swift.xcworkspace` pod generated for you.
5. Fill in the AppKey and AppSecret in the **AppKey.swift** file.

```swift
struct AppKey {
    static let appKey = "Your AppKey"
    static let secretKey = "Your SecretKey"
}
```

6. Download the security image, rename it to `t_s.bmp`, and then drag it to the workspace to be at the same level as `Info.plist`.

**Note**: The bundle ID, AppKey, AppSecret, and security image must be the same as your app on the [Tuya IoT Platform](https://iot.tuya.com). Otherwise, the sample cannot request the API.

## References
For more information about Tuya iOS HomeSDK, see [App SDK](https://developer.tuya.com/en/docs/app-development).
