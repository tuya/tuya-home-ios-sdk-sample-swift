# Tuya iOS HomeSDK Sample for Swift

This sample demonstrates the use of Tuya iOS Smart Life App SDK to build an IoT app from scratch.Tuya iOS Smart Life App SDK is divided into several function groups to give developers a clear insight into the implementation of different features, including the user registration process, home management for different users, device network configuration, and controls. For device network configuration, the EZ mode and AP mode are implemented. This allows developers to pair devices over Wi-Fi and control the devices over LAN and MQTT. For device control, a common panel is used to send and receive any types of data points.

<img src="https://github.com/tuya/tuya-home-ios-sdk-sample-swift/raw/main/snapshot.png" alt="Tuya Smart app" width="300"/>

## Self-developed Smart Life App Service
Self-Developed Smart Life App is one of Tuya’s IoT app development solutions. This solution provides the services that enable connections between the app and the cloud. It also supports a full range of services and capabilities that customers can use to independently develop mobile apps. The Smart Life App SDK used in this sample is included in the Self-developed Smart Life App Service.

Self-Developed Smart Life App is classified into the **Trial** and **Official** editions:

- **Self-Developed App Trial**: provided for a free trial. It supports up to 100,000 cloud API calls per month and up to 20 registered end users in total.

- **Self-Developed App Official**: provided for commercial use and costs $5,000/year (¥33,500/year) for the initial subscription and $2,000/year (¥13,500/year) for subsequent annual renewal. It is supplied with the Custom Domain Name service and up to 100 million cloud API calls per month.

For more information, please check the [Pricing](https://developer.tuya.com/en/docs/app-development/app-sdk-price?id=Kbu0tcr2cbx3o).

## Prerequisites
* Xcode 12.0 and later
* iOS 12 and later


## Use the sample
1. The Tuya iOS Smart Life App SDK is distributed through [CocoaPods](http://cocoapods.org/) and other dependencies in this sample. Make sure that you have installed CocoaPods. If not, run the following command to install CocoaPods first:

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
