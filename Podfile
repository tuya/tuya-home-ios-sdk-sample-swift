source 'https://github.com/CocoaPods/Specs'
source 'https://github.com/tuya/tuya-pod-specs.git'


target 'TuyaAppSDKSample-iOS-Swift' do
  use_modular_headers!

  pod 'SVProgressHUD'
  pod 'SGQRCode', '~> 4.1.0'
  pod 'SnapKit'

  # 从 iot.tuya.com 构建和获取 ThingSmartCryption
    #  购买正式版后，需重新在 IoT 平台构建 SDK 并重新集成
    # ./ios_core_sdk 代表将 `ios_core_sdk.tar.gz` 解压之后所在目录与 `podfile` 同级
    # 若自定义存放目录，可以修改 `path` 为自定义目录层级
  pod 'ThingSmartCryption', :path => './ios_core_sdk'

  pod 'ThingSmartHomeKit', '~> 5.16.0'
  pod 'ThingSmartMatterKit', '~> 5.11.0'
  pod 'ThingSmartMatterExtensionKit', '~> 5.0.0'
  pod 'ThingSmartAppleDeviceKit', '~> 5.2.0'
  pod 'ThingSmartCameraKit', '~> 5.16.0'
  pod 'ThingSmartOutdoorKit', '~> 5.4.0'
  pod 'ThingSmartSweeperKit', '~> 5.0.0'
  pod 'ThingSmartLockKit', '~> 5.5.0'
  
  pod 'ThingSmartBusinessExtensionKit', '~> 5.16.0'
  pod 'ThingSmartBusinessExtensionKitBLEExtra','~> 5.16.0'
  pod 'ThingSmartBusinessExtensionKitMatterExtra','~> 5.16.0'
  
end

target 'MatterExtension' do

 pod 'ThingSmartMatterExtensionKit', '~> 5.0.5'
 
end

post_install do |installer|
  `cd TuyaAppSDKSample-iOS-Swift; [[ -f AppKey.swift ]] || cp AppKey.swift.default AppKey.swift;`
  
  
  installer.pod_target_subprojects.each do |subproject|
    subproject.targets.each do |sub_target|
      sub_target.build_configurations.each do |config|

        config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
        config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "11.0"
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"

        # replace to your teamid
        # config.build_settings["DEVELOPMENT_TEAM"] = "Your Team"
        
        
      end
    end
  end
end

