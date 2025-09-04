# FaceID 登录

## 功能概述

涂鸦智能 iOS SDK 提供了 FaceID 生物识别登录功能，可以让用户通过面容识别快速登录账号。该功能基于系统的生物识别框架实现，支持 FaceID 的 iPhone 设备可以使用此功能。

## 接入准备

1. 确保项目依赖了最新版本的涂鸦全屋智能 SDK
2. 导入所需框架：
```swift
import ThingSmartLocalAuthKit
```
3. 在项目的 Info.plist 中添加 FaceID 使用权限说明:
```xml
<key>NSFaceIDUsageDescription</key>
<string>App需要您的同意才能使用Face ID进行登录</string>
```

## ThingBiometricLoginManager 接口详解

### 核心接口

#### 1. 检查设备硬件是否支持 Face ID 登录

**接口说明**

检查设备硬件是否支持 Face ID 登录功能。目前仅支持 Face ID。

```objective-c
- (BOOL)mobileHardwareSupportFaceIDLogin;
```

**返回值**

| 返回值 | 说明 |
| ---- | ---- |
| YES | 设备支持 Face ID 登录 |
| NO | 设备不支持 Face ID 登录 |

**示例代码**

Objc:

```objc
BOOL isSupported = [biometricManager mobileHardwareSupportFaceIDLogin];
if (isSupported) {
    NSLog(@"Device supports Face ID login");
} else {
    NSLog(@"Device does not support Face ID login");
}
```

Swift:

```swift
let isSupported = biometricManager.mobileHardwareSupportFaceIDLogin()
if isSupported {
    print("Device supports Face ID login")
} else {
    print("Device does not support Face ID login")
}
```

#### 2. 检查生物识别登录是否已启用

**接口说明**

检查生物识别登录功能是否已启用。

```objective-c
- (BOOL)isBiometricLoginEnabled:(NSError * __autoreleasing *)error;
```

**参数说明**

| 参数 | 说明 |
| ---- | ---- |
| error | 错误信息指针，如果检查失败会返回具体错误 |

**返回值**

| 返回值 | 说明 |
| ---- | ---- |
| YES | 生物识别登录已启用 |
| NO | 生物识别登录未启用 |

**示例代码**

Objc:

```objc
NSError *error = nil;
BOOL isEnabled = [biometricManager isBiometricLoginEnabled:&error];
if (isEnabled) {
    NSLog(@"Biometric login is enabled");
} else {
    NSLog(@"Biometric login is not enabled: %@", error.localizedDescription);
}
```

Swift:

```swift
do {
    let isEnabled = try biometricManager.isBiometricLoginEnabled()
    if isEnabled {
        print("Biometric login is enabled")
    } else {
        print("Biometric login is not enabled")
    }
} catch {
    print("Error checking biometric login status: \(error.localizedDescription)")
}
```

#### 3. 获取生物识别登录用户账号信息

**接口说明**

获取已存储的生物识别登录用户账号信息。

```objective-c
- (ThingBiometricLogiUserInfo *)getBiometricLoginUserAccountInfo;
```

**返回值**

| 返回值 | 说明 |
| ---- | ---- |
| ThingBiometricLogiUserInfo | 用户信息对象，包含：<br>• userName: 用户名<br>• icon: 头像URL<br>• uid: 用户ID<br>• countryCode: 国家代码<br>• nickName: 昵称 |

**示例代码**

Objc:

```objc
ThingBiometricLogiUserInfo *userInfo = [biometricManager getBiometricLoginUserAccountInfo];
if (userInfo) {
    NSLog(@"User ID: %@", userInfo.uid);
    NSLog(@"Username: %@", userInfo.userName);
    NSLog(@"Nickname: %@", userInfo.nickName);
    NSLog(@"Icon: %@", userInfo.icon);
    NSLog(@"Country Code: %@", userInfo.countryCode);
} else {
    NSLog(@"No biometric login user info found");
}
```

Swift:

```swift
if let userInfo = biometricManager.getBiometricLoginUserAccountInfo() {
    print("User ID: \(userInfo.uid ?? "")")
    print("Username: \(userInfo.userName ?? "")")
    print("Nickname: \(userInfo.nickName ?? "")")
    print("Icon: \(userInfo.icon ?? "")")
    print("Country Code: \(userInfo.countryCode ?? "")")
} else {
    print("No biometric login user info found")
}
```

#### 4. 更新当前账号生物识别登录信息

**接口说明**

更新已存储的用户显示名称和头像等生物识别登录信息。

```objective-c
- (void)updateCurrentAccountBiometricLoginInformation;
```

**示例代码**

Objc:

```objc
[biometricManager updateCurrentAccountBiometricLoginInformation];
NSLog(@"Biometric login information updated");
```

Swift:

```swift
biometricManager.updateCurrentAccountBiometricLoginInformation()
print("Biometric login information updated")
```

#### 5. 启用生物识别登录

**接口说明**

启用生物识别登录功能，包括获取生物识别登录密钥和存储用户信息。

```objective-c
- (void)openBiometricLoginWithEvaluatePolicy:(LAPolicy)policy
      localizedReason:(NSString *)localizedReason
                reply:(void(^)(BOOL success,NSError * __nullable error))reply;
```

**参数说明**

| 参数 | 说明 |
| ---- | ---- |
| policy | 生物识别策略，通常为 `.deviceOwnerAuthenticationWithBiometrics` |
| localizedReason | 认证请求的原因说明，会显示给用户 |
| reply | 完成回调，包含成功状态和错误信息 |

**示例代码**

Objc:

```objc
[biometricManager openBiometricLoginWithEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
      localizedReason:@"Enable Face ID login for your account"
                reply:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        NSLog(@"Face ID enabled successfully");
        // 更新UI状态
        [self updateUIForEnabledFaceID];
    } else {
        NSLog(@"Failed to enable Face ID: %@", error.localizedDescription);
        // 显示错误信息
        [self showErrorAlert:error.localizedDescription];
    }
}];
```

Swift:

```swift
biometricManager.openBiometricLogin(withEvaluatePolicy: .deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "Enable Face ID login for your account") { success, error in
    if success {
        print("Face ID enabled successfully")
        // 更新UI状态
        self.updateUIForEnabledFaceID()
    } else if let error = error {
        print("Failed to enable Face ID: \(error.localizedDescription)")
        // 显示错误信息
        self.showErrorAlert(error.localizedDescription)
    }
}
```

#### 6. 禁用生物识别登录

**接口说明**

禁用生物识别登录功能并清除已存储的生物识别数据。

```objective-c
- (void)closeBiometricLogin:(void(^)(BOOL success, NSError * __nullable error))reply;
```

**参数说明**

| 参数 | 说明 |
| ---- | ---- |
| reply | 完成回调，包含成功状态和错误信息 |

**示例代码**

Objc:

```objc
[biometricManager closeBiometricLogin:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        NSLog(@"Face ID disabled successfully");
        // 更新UI状态
        [self updateUIForDisabledFaceID];
    } else {
        NSLog(@"Failed to disable Face ID: %@", error.localizedDescription);
        // 显示错误信息
        [self showErrorAlert:error.localizedDescription];
    }
}];
```

Swift:

```swift
biometricManager.closeBiometricLogin { success, error in
    if success {
        print("Face ID disabled successfully")
        // 更新UI状态
        self.updateUIForDisabledFaceID()
    } else if let error = error {
        print("Failed to disable Face ID: \(error.localizedDescription)")
        // 显示错误信息
        self.showErrorAlert(error.localizedDescription)
    }
}
```

#### 7. 生物识别登录

**接口说明**

使用生物识别认证进行登录，包括本地认证和服务器验证。

```objective-c
- (void)loginByBiometricWithEvaluatePolicy:(LAPolicy)policy
       localizedReason:(NSString *)localizedReason
                 reply:(void(^)(BOOL success, id result, NSError * __nullable error))reply;
```

**参数说明**

| 参数 | 说明 |
| ---- | ---- |
| policy | 生物识别策略，通常为 `.deviceOwnerAuthenticationWithBiometrics` |
| localizedReason | 认证请求的原因说明，会显示给用户 |
| reply | 完成回调，包含成功状态、结果数据和错误信息 |

**示例代码**

Objc:

```objc
[biometricManager loginByBiometricWithEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
       localizedReason:@"Login with Face ID"
                 reply:^(BOOL success, id result, NSError * _Nullable error) {
    if (success) {
        NSLog(@"Face ID login successful");
        // 处理登录成功
        [self handleSuccessfulLogin:result];
    } else {
        NSLog(@"Face ID login failed: %@", error.localizedDescription);
        // 处理登录失败
        [self handleFailedLogin:error];
    }
}];
```

Swift:

```swift
biometricManager.loginByBiometric(withEvaluatePolicy: .deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: "Login with Face ID") { success, result, error in
    if success {
        print("Face ID login successful")
        // 处理登录成功
        self.handleSuccessfulLogin(result)
    } else if let error = error {
        print("Face ID login failed: \(error.localizedDescription)")
        // 处理登录失败
        self.handleFailedLogin(error)
    }
}
```

## 错误码说明

### ThingSmartLocalAuthError 错误码

| 错误码 | 说明 |
| ---- | ---- |
| ThingSmartLocalAuthErrorBiometricLoginNotOpen (-5001) | 生物识别登录未开启 |
| ThingSmartLocalAuthErrorBiometricLoginInfoModified (-5002) | 生物识别登录信息已修改 |

## 核心功能实现

### 1. 初始化生物识别管理器

```swift
private let biometricManager = ThingBiometricLoginManager()
```

### 2. Face ID 状态检查

```swift
private func checkFaceIDStatus() -> Bool {
    // 检查设备是否支持 Face ID
    guard biometricManager.mobileHardwareSupportFaceIDLogin() else {
        Alert.showBasicAlert(on: self, 
                           with: NSLocalizedString("FaceID Not Available", comment: ""), 
                           message: "Device does not support Face ID")
        return false
    }
    
    // 检查生物识别登录是否已启用
    do {
        let isEnabled = try biometricManager.isBiometricLoginEnabled()
        return isEnabled
    } catch {
        Alert.showBasicAlert(on: self, 
                           with: NSLocalizedString("FaceID Error", comment: ""), 
                           message: error.localizedDescription)
        return false
    }
}
```

### 3. Face ID 登录实现

```swift
@IBAction func faceIDLoginTapped(_ sender: UIButton) {
    if self.checkFaceIDStatus() {
        // 执行 Face ID 认证登录
        biometricManager.loginByBiometric(withEvaluatePolicy: .deviceOwnerAuthenticationWithBiometrics,
                                         localizedReason: "Login with Face ID") { success, result, error in
            if success {
                // 登录成功，重置用户信息
                ThingSmartUser.sharedInstance().reset(userInfo: result as! [AnyHashable: Any], source: 9)
                
                // 跳转到主界面
                let storyboard = UIStoryboard(name: "ThingSmartMain", bundle: nil)
                let vc = storyboard.instantiateInitialViewController()
                self.window?.rootViewController = vc
            } else if let error = error {
                // 处理登录失败
                DispatchQueue.main.async {
                    Alert.showBasicAlert(on: self, 
                                       with: NSLocalizedString("FaceID Login Failed", comment: ""), 
                                       message: error.localizedDescription)
                }
            }
        }
    }
}
```

### 4. 启用 Face ID 登录

```swift
private func openBiometricLogin() {
    biometricManager.openBiometricLogin(withEvaluatePolicy: .deviceOwnerAuthenticationWithBiometrics,
                                       localizedReason: "Enable Face ID login") { success, error in
        DispatchQueue.main.async {
            if success {
                self.syncButton.setTitle("Synchronized", for: .normal)
            } else if let error = error {
                Alert.showBasicAlert(on: self, 
                                   with: NSLocalizedString("FaceID Error", comment: ""), 
                                   message: error.localizedDescription)
            }
        }
    }
}
```

### 5. 禁用 Face ID 登录

```swift
private func closeBiometricLogin() {
    biometricManager.closeBiometricLogin { success, error in
        DispatchQueue.main.async {
            if success {
                self.syncButton.setTitle("Not synchronized", for: .normal)
            } else if let error = error {
                Alert.showBasicAlert(on: self, 
                                   with: NSLocalizedString("FaceID Error", comment: ""), 
                                   message: error.localizedDescription)
            }
        }
    }
}
```

### 6. 获取用户信息

```swift
private func getBiometricUserInfo() {
    if let userInfo = biometricManager.getBiometricLoginUserAccountInfo() {
        print("User ID: \(userInfo.uid ?? "")")
        print("Username: \(userInfo.userName ?? "")")
        print("Nickname: \(userInfo.nickName ?? "")")
        print("Icon: \(userInfo.icon ?? "")")
        print("Country Code: \(userInfo.countryCode ?? "")")
    } else {
        print("No biometric login user info found")
    }
}
```

### 7. 更新用户信息

```swift
private func updateBiometricUserInfo() {
    biometricManager.updateCurrentAccountBiometricLoginInformation()
    print("Biometric login information updated")
}
```

## 使用流程

1. 用户完成普通账号密码登录
2. 调用 `openBiometricLoginWithEvaluatePolicy:localizedReason:reply:` 开启Face ID功能，获取登录凭证
3. 系统自动保存Face ID相关数据
4. 后续登录时可以直接使用 `loginByBiometricWithEvaluatePolicy:localizedReason:reply:` 进行Face ID登录

## 注意事项

1. 必须先调用 `openBiometricLoginWithEvaluatePolicy:localizedReason:reply:` 获取Face ID登录凭证，才能使用Face ID登录
2. 当用户的Face ID信息发生变化时(如添加/删除面容)，需要重新开启Face ID功能
3. 建议在以下情况下清除Face ID登录信息：
   - 用户登出
   - Face ID信息变更
   - 用户主动关闭Face ID登录功能

## 常见问题

### 1. Face ID验证失败
- 检查设备是否支持Face ID：调用 `mobileHardwareSupportFaceIDLogin`
- 确认是否获得了用户授权
- 验证生物识别登录是否已启用：调用 `isBiometricLoginEnabled`
- 确认是否已调用 `openBiometricLoginWithEvaluatePolicy:localizedReason:reply:` 并成功获取登录凭证

### 2. 登录失败
- 检查错误码：
  - `ThingSmartLocalAuthErrorBiometricLoginNotOpen (-5001)`: 生物识别登录未开启
  - `ThingSmartLocalAuthErrorBiometricLoginInfoModified (-5002)`: 生物识别登录信息已修改
- 可能需要重新调用 `openBiometricLoginWithEvaluatePolicy:localizedReason:reply:` 获取新的登录凭证

### 3. 接口调用顺序
- 必须先调用 `openBiometricLoginWithEvaluatePolicy:localizedReason:reply:` 启用Face ID
- 然后才能调用 `loginByBiometricWithEvaluatePolicy:localizedReason:reply:` 进行登录
- 使用完毕后可以调用 `closeBiometricLogin:` 禁用Face ID

### 4. 用户信息管理
- 使用 `getBiometricLoginUserAccountInfo` 获取已存储的用户信息
- 使用 `updateCurrentAccountBiometricLoginInformation` 更新用户显示信息
