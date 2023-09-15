source 'https://github.com/CocoaPods/Specs'
source 'https://registry.code.tuya-inc.top/tuyaIOS/TYSpecs.git'

source 'https://github.com/tuya/TuyaPublicSpecs.git'
source 'https://github.com/tuya/tuya-pod-specs.git'


target 'TuyaAppSDKSample-iOS-Swift' do
  use_modular_headers!

  pod 'SVProgressHUD'
  pod 'SGQRCode', '~> 4.1.0'

#  pod 'ThingSmartHomeKit', '~> 5.1.0'

  pod 'ThingSmartHomeKit', '~> 5.0.0'
  pod 'ThingSmartCryption', :path => '/Users/revive/tuya-home-ios-sdk-sample-objc/ios_core_sdk'
  pod 'ThingSmartActivatorDiscoveryManager', '0.4.23'
  pod 'ThingBLEHomeManager', '1.14.1'
  pod 'ThingBLEInterfaceImpl', '0.12.2'
  pod 'ThingBLEMeshInterfaceImpl', '0.2.0'
  pod 'ThingBluetoothInterface', '1.14.1'
  pod 'ThingFamilyAPI', '1.3.1'
  pod 'ThingActivatorRequestSkt', '0.2.2'
  pod 'ThingSmartMatterKit', '5.5.0-rc.1'
  
  pod 'ThingSmartFamilyBizKit', '1.8.1'
    pod 'ThingSmartDeviceKit', '5.4.3'
end

target 'MatterExtension' do

  pod 'ThingSmartMatterExtensionKit', '5.0.5'
  
end

post_install do |installer|
  `cd TuyaAppSDKSample-iOS-Swift; [[ -f AppKey.swift ]] || cp AppKey.swift.default AppKey.swift;`
end
