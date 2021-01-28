# Tuya iOS HomeSDK Sample for Swift

This sample demonstrates the use of Tuya iOS HomeSDK to build an IoT App from scratch. It divides into several function groups to give developers a clear insight into the implementation for different features, includes the user registration process, home management for different users, device network configuration, and controls. For device network configuration, EZ mode and AP mode are implemented, which let developers pair devices over Wi-Fi, as well as control them via LAN and MQTT. For device control, it supplies a common panel for sending and receiving any kind types of data points.

## Requirements
* Xcode 12.0 and later
* iOS 12 and later


## Using this Sample
1. The Tuya HomeSDK is distributed through [CocoaPods](http://cocoapods.org/), as well as other dependencies in this sample. Please make sure you have CocoaPods installed, if not, install it first:

```bash
sudo gem install cocoapods
pod setup
```

2. Clone or download this sample, change the directory to the one with **Podfile** in it, then run the following command:

```bash
pod install
```

3. This sample requires you to have a pair of keys and a secure image from [Tuya IoT Platform](https://developer.tuya.com/), register a developer account if you don't have one, then follow the following steps:
	1. In the IoT platform, under the `App` side panel, choose `SDK Development`.
	2. Creating an App by clicking `Create` button.
	3. Fill in the required information. Please make sure you type in the correct Bundle ID, it cannot be changed afterward.
	4. You can find the AppKey, AppSecret, and security image under the `Obtain Key` tag.

4. Open the `TuyaAppSDKSample-iOS-Swift.xcworkspace` that pod generated for you.
5. Fill in the AppKey and AppSecret in `AppKey.swift` file.

```swift
struct AppKey {
    static let appKey = "Your AppKey"
    static let secretKey = "Your SecretKey"
}
```

6. Download the security image and rename it to `t_s.bmp`, then drag it into the workspace to be at the same level as `Info.plist`.

**Note:** The bundle ID, AppKey, AppSecret, and security image must be the same as your App in Tuya IoT Platform; otherwise, the sample cannot successfully request the API.