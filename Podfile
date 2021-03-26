source 'https://cdn.cocoapods.org/'
source 'https://github.com/TuyaInc/TuyaPublicSpecs.git'

target 'TuyaAppSDKSample-iOS-Swift' do
  pod 'SVProgressHUD'
  pod 'TuyaSmartHomeKit'
end

post_install do |installer|
  `cd TuyaAppSDKSample-iOS-Swift; [[ -f AppKey.swift ]] || cp AppKey.swift.default AppKey.swift;`
end
