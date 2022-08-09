source 'https://cdn.cocoapods.org/'
source 'https://github.com/tuya/TuyaPublicSpecs.git'

target 'TuyaAppSDKSample-iOS-Swift' do
  use_modular_headers!

  pod 'SVProgressHUD'
  pod 'SGQRCode', '~> 4.1.0'

  pod 'TuyaSmartHomeKit'
end

post_install do |installer|
  `cd TuyaAppSDKSample-iOS-Swift; [[ -f AppKey.swift ]] || cp AppKey.swift.default AppKey.swift;`
end
