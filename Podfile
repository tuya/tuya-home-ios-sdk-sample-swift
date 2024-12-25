source 'https://github.com/CocoaPods/Specs'
source 'https://github.com/tuya/tuya-pod-specs.git'

platform :ios, '12.0'

target 'TuyaAppSDKSample-iOS-Swift' do
  use_modular_headers!
  
  # Secret key
  # Build and obtain ThingSmartCryption from iot.tuya.com
  # After purchasing the official version, you need to rebuild the SDK on the IoT platform and reintegrate it
  # ./ios_core_sdk represents the directory where ios_core_sdk.tar.gz is extracted, located at the same level as the podfile
  # If you use a custom directory, you can modify the path to your custom directory structure
  pod 'ThingSmartCryption', :path => './ios_core_sdk'
  
  # [Required] Basic
  pod 'ThingSmartHomeKit', '~> 6.0.0'
  pod 'ThingSmartBusinessExtensionKit', '~> 6.0.0'
  
  # [Optional] Bluetooth
  pod 'ThingSmartBusinessExtensionKitBLEExtra','~> 6.0.0'
  
  # [Optional] Matter
  pod 'ThingSmartMatterKit', '~> 5.18.0'
  pod 'ThingSmartMatterExtensionKit', '~> 5.17.0'
  pod 'ThingSmartBusinessExtensionKitMatterExtra','~> 6.0.0'
  
  # [Optional] HomeKit Device
  pod 'ThingSmartAppleDeviceKit', '~> 6.0.0'
  
  # [Optional] Special category
  pod 'ThingSmartCameraKit', '~> 6.0.0'
  pod 'ThingSmartOutdoorKit', '~> 6.0.0'
  pod 'ThingSmartSweeperKit', '~> 5.3.0'
  pod 'ThingSmartLockKit', '~> 6.0.0'
  
  # The following components are only required for this demo and are not necessary when integrating into your own project.
  pod 'SVProgressHUD'
  pod 'SGQRCode', '~> 4.1.0'
  pod 'SnapKit'
end


# when you see the error:
# "No profiles for 'com.thingclips.test1001.MatterExtension' were found: Xcode couldn't find any iOS App Development provisioning profiles matching 'com.thingclips.test1001.MatterExtension' or development teams do not support the Matter Allow Setup Payload capability."
# Resolve it by removing the MatterExtension target and rebuilding the project.
target 'MatterExtension' do
  pod 'ThingSmartMatterExtensionKit', '~> 5.17.0'
end

target 'TuyaAppSDKWidgetExtension' do
  pod 'ThingSmartHomeKit', '~> 6.0.0'
  pod 'ThingSmartBusinessExtensionKit', '~> 6.0.0'
  pod 'SDWebImage'
end



post_install do |installer|
  `cd TuyaAppSDKSample-iOS-Swift; [[ -f AppKey.swift ]] || cp AppKey.swift.default AppKey.swift;`
  
  
  installer.pod_target_subprojects.each do |subproject|
    subproject.targets.each do |sub_target|
      sub_target.build_configurations.each do |config|

        config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
        config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "11.0"
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"

      end
    end
  end
end

