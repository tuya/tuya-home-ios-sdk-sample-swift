智能生活 App SDK 提供了手机号码和密码的注册和登录能力。

<a id="WhiteList"></a>

## 查询验证码服务可用地区

为了加强用户信息的数据安全，涂鸦优化了验证码发送流程，并添加了账号限制。只有验证码服务可用的地区，才可以发送验证码。

:::important
如果您想为 App 启用手机号码验证服务，那您需要开通和配置 [手机号码短信验证服务](https://www.tuya.com/vas/commodity/APP_SMS)。该服务让您的 App 用户可以通过手机号码直接注册账号或绑定已有的 App 账号，并可以直接通过手机号码完成登录 App、找回密码等操作。详细操作说明，请参考 [开通和配置手机号码短信验证服务](https://developer.tuya.com/cn/docs/iot/verify-with-mobile-number-sms?id=Kb8eo0nqzmi3u)。
:::

```objective-c
- (void)getWhiteListWhoCanSendMobileCodeSuccess:(ThingSuccessString)success
                                        failure:(ThingFailureError)failure;
```

**参数说明**

| 参数 | 说明 |
| ---- | ---- |
| success | 接口发送成功回调 |
| failure | 接口发送失败回调，`error` 表示失败原因 |

Objc:

```objc
[[ThingSmartUser sharedInstance] getWhiteListWhoCanSendMobileCodeSuccess:^(NSString *regions) {

} failure:^(NSError *error) {

}];
```

Swift:

```swift
ThingSmartUser.sharedInstance().getWhiteListWhoCanSendMobileCodeSuccess({ regions in

}, failure: { error in

})
```

<a id="verification"></a>

## 发送手机号码验证码

:::important
您需要确保您能使用本接口。详情请调用 [`getWhiteListWhoCanSendMobileCodeSuccess`](#WhiteList) 查看使用权限。
:::

**接口说明**

发送验证码，用于手机号码的验证码登录、注册、密码重置等。

```objective-c
- (void)sendVerifyCodeWithUserName:(NSString *)userName
                            region:(NSString *)region
                       countryCode:(NSString *)countryCode
                              type:(NSInteger)type
                           success:(ThingSuccessHandler)success
                           failure:(ThingFailureError)failure;
```

**参数说明**

| 参数 | 说明 |
| ---- | ---- |
| userName | 手机号码 |
| region | 用户注册地区，可以通过 `[ThingSmartUser regionListWithCountryCode:success:failure:]` 或者 `[ThingSmartUser getDefaultRegionWithCountryCode:]` 获取 |
| countryCode | 国家码，例如 `86` |
| type | 发送验证码类型。取值：<ul><li> 1：使用手机号码注册账号时，发送验证码 </li><li> 2：使用手机号码登录账号时，发送验证码  </li><li> 3：重置手机号码注册的账号的密码时，发送验证码  </li></ul> |
| success | 接口发送成功回调 |
| failure | 接口发送失败回调，`error` 表示失败原因 |

**示例代码**

Objc:

```objective-c
[[ThingSmartUser sharedInstance] sendVerifyCodeWithUserName:@"yourUsename"
                                                    region:region
                                               countryCode:@"yourCountryCode"
                                                      type:1
                                                   success:^{
    NSLog(@"sendVerifyCode success");
} failure:^(NSError *error) {
    NSLog(@"sendVerifyCode failure: %@", error);
}];
```

Swift:

```swift
ThingSmartUser.sharedInstance().sendVerifyCode(withUserName: "yourUsename", region: region, countryCode: "yourCountryCode", type: 1, success: {
    print("sendVerifyCode success")
}, failure: { error in
    if let error = error {
        print("sendVerifyCode failure: \(error)")
    }
})
```

<a id="proofing"></a>

## 校验填入的验证码

**接口说明**

手机号码账号注册、登录、重设密码时验证码的校验。

```objective-c
- (void)checkCodeWithUserName:(NSString *)userName
                       region:(NSString *_Nullable)region
                  countryCode:(NSString *)countryCode
                         code:(NSString *)code
                         type:(NSInteger)type
                      success:(ThingSuccessBOOL)success
                      failure:(ThingFailureError)failure;
```

**参数说明**

| 参数 | 说明 |
| ---- | ---- |
| userName | 手机号或邮箱 |
| region | 区域，默认填 nil |
| countryCode | 国家码，例如 `86` |
| code | 经过验证码发送接口，收到的验证码 |
| type | 发送验证码类型。取值：<ul><li> 1：使用手机号码注册账号时，校验验证码 </li><li> 2：使用手机号码登录账号时，校验验证码  </li><li> 3：重置手机号码注册的账号的密码时，校验验证码  </li></ul> |
| success | 接口发送成功回调 |
| failure | 接口发送失败回调，`error` 表示失败原因 |

**示例代码**

Objc:

```objective-c
[[ThingSmartUser sharedInstance] checkCodeWithUserName:@"email_or_phone_number" region:@"region" countryCode:@"your_country_code" code:@"verify_code" type:1 success:^(BOOL result) {
		if (result) {
				NSLog(@"valid code!");
    } else {
				NSLog(@"invalid code!");
    }
} failure:^(NSError *error) {
		NSLog(@"check code failure: %@", error);
}];
```

Swift:

```swift
ThingSmartUser.sharedInstance()?.checkCode(withUserName: "email_or_phone_number", region: "region", countryCode: "your_country_code", code: "verify_code", type: type, success: { (result) in
		if result {
				print("valid code!")
		} else {
				print("invalid code!")
		}
}, failure: { (error) in
		if let error = error {
				print("check code failure: \(error)")
		}
})
```

## 使用手机号码注册账号

使用手机号码注册账号前，您需要先 [获取验证码](#verification)。

**接口说明**

```objective-c
- (void)registerByPhone:(NSString *)countryCode
            phoneNumber:(NSString *)phoneNumber
               password:(NSString *)password
                   code:(NSString *)code
                success:(nullable ThingSuccessHandler)success
                failure:(nullable ThingFailureError)failure;
```

**参数说明**

| 参数 | 说明 |
| ---- | ---- |
| countryCode | 国家码，例如 `86` |
| phoneNumber | 手机号码 |
| password | 密码 |
| code | 经过验证码发送接口，收到的验证码 |
| success | 接口发送成功回调 |
| failure | 接口发送失败回调，`error` 表示失败原因 |

**示例代码**

Objc:

```objective-c
[[ThingSmartUser sharedInstance] registerByPhone:@"your_country_code" phoneNumber:@"your_phone_number" password:@"your_password" code:@"verify_code" success:^{
    NSLog(@"register success");
} failure:^(NSError *error) {
    NSLog(@"register failure: %@", error);
}];
```

Swift:

```swift
ThingSmartUser.sharedInstance()?.register(byPhone: "your_country_code", phoneNumber: "your_phone_number", password: "your_password", code: "verify_code", success: {
    print("register success")
}, failure: { (error) in
    if let e = error {
        print("register failure: \(e)")
    }
})
```

## 使用手机号码和密码登录账号

**接口说明**

```objective-c
- (void)loginByPhone:(NSString *)countryCode
         phoneNumber:(NSString *)phoneNumber
            password:(NSString *)password
             success:(nullable ThingSuccessHandler)success
             failure:(nullable ThingFailureError)failure;
```

**参数说明**

| 参数 | 说明 |
| ---- | ---- |
| countryCode | 国家码，例如 `86` |
| phoneNumber | 手机号码 |
| password | 密码 |
| success | 接口发送成功回调 |
| failure | 接口发送失败回调，`error` 表示失败原因 |

**示例代码**

Objc:

```objective-c
[[ThingSmartUser sharedInstance] loginByPhone:@"your_country_code" phoneNumber:@"your_phone_number" password:@"your_password" success:^{
		NSLog(@"login success");
} failure:^(NSError *error) {
		NSLog(@"login failure: %@", error);
}];
```

Swift:

```swift
ThingSmartUser.sharedInstance()?.login(byPhone: "your_country_code", phoneNumber: "your_phone_number", password: "your_password", success: {
    print("login success")
}, failure: { (error) in
    if let e = error {
        print("login failure: \(e)")
    }
})
```

## 使用手机号码和验证码登录账号

您需要先调用 [验证码发送接口](#verification)，发送验证码，再将收到的验证码填入对应的参数中。

**接口说明**

```objective-c
- (void)loginWithMobile:(NSString *)mobile
            countryCode:(NSString *)countryCode
                   code:(NSString *)code
                success:(ThingSuccessHandler)success
                failure:(ThingFailureError)failure;
```

**参数说明**

| 参数 | 说明 |
| ---- | ---- |
| mobile | 手机号码 |
| countryCode | 国家码，例如 `86` |
| code | 经过验证码发送接口，收到的验证码 |
| success | 接口发送成功回调 |
| failure | 接口发送失败回调，`error` 表示失败原因 |

**示例代码**

Objc:

```objective-c
[[ThingSmartUser sharedInstance] loginWithMobile:@"your_phone_number" countryCode:@"your_country_code" code:@"verify_code" success:^{
		NSLog(@"login success");
} failure:^(NSError *error) {
    NSLog(@"login failure: %@", error);
}];
```

Swift:

```swift
ThingSmartUser.sharedInstance()?.login(withMobile: "your_phone_number", countryCode: "your_country_code", code: "verify_code", success: {
    print("login success")
}, failure: { (error) in
    if let e = error {
        print("login failure: \(e)")
    }
})
```

## 重置手机号码注册的账号密码

重置密码前，您需要先 [获取验证码](#verification)。

**接口说明**

```objective-c
- (void)resetPasswordByPhone:(NSString *)countryCode
                 phoneNumber:(NSString *)phoneNumber
                 newPassword:(NSString *)newPassword
                        code:(NSString *)code
                     success:(nullable ThingSuccessHandler)success
                     failure:(nullable ThingFailureError)failure;
```

**参数说明**

| 参数 | 说明 |
| ---- | ---- |
| countryCode | 国家码，例如 `86` |
| phoneNumber | 手机号码 |
| newPassword | 新密码 |
| code | 经过验证码发送接口，收到的验证码 |
| success | 接口发送成功回调 |
| failure | 接口发送失败回调，`error` 表示失败原因 |

**示例代码**

Objc:

```objc
- (void)resetPasswordByPhone {
	[ThingSmartUser sharedInstance] resetPasswordByPhone:@"your_country_code" phoneNumber:@"your_phone_number" newPassword:@"your_password" code:@"verify_code" success:^{
		NSLog(@"resetPasswordByPhone success");
	} failure:^(NSError *error) {
		NSLog(@"resetPasswordByPhone failure: %@", error);
	}];
}
```

Swift:

```swift
func resetPasswordByPhone() {
    ThingSmartUser.sharedInstance()?.resetPassword(byPhone: "your_country_code", phoneNumber: "your_phone_number", newPassword: "your_password", code: "verify_code", success: {
        print("resetPasswordByPhone success")
    }, failure: { (error) in
        if let e = error {
            print("resetPasswordByPhone failure: \(e)")
        }
    })
}
```

## 为账号绑定邮箱

绑定邮箱，包括获取绑定验证码接口和绑定邮箱接口。

### 获取绑定验证码

**接口说明**

```ObjC
- (void)sendBindingVerificationCodeWithEmail:(NSString *)email
                                 countryCode:(NSString *)countryCode
                                     success:(nullable ThingSuccessHandler)success
                                     failure:(nullable ThingFailureError)failure;
```

**参数说明**

| 参数 | 说明 |
| ---- | ---- |
| countryCode | 手机号码所在的国家区号，例如 `86` 表示中国大陆地区 |
| email | 邮箱地址 |
| success | 接口发送成功回调 |
| failure | 接口发送失败回调，`error` 表示失败原因 |

### 绑定邮箱地址

**接口说明**

```ObjC
- (void)bindEmail:(NSString *)email
  withCountryCode:(NSString *)countryCode
             code:(NSString *)code
              sId:(NSString *)sId
          success:(nullable ThingSuccessHandler)success
          failure:(nullable ThingFailureError)failure;
```

**参数说明**

| 参数 | 说明 |
| ---- | ---- |
| countryCode | 手机号码所在的国家区号，例如 `86` 表示中国大陆地区 |
| email | 邮箱地址 |
| code | 验证码 |
| sId | 用户登录的会话（session）ID，您可以在 `user` 对象中获取 `sessionID` |
| success | 接口发送成功回调 |
| failure | 接口发送失败回调，`error` 表示失败原因 |

**示例代码**

ObjC：

```ObjC
//获取绑定验证码
[[ThingSmartUser sharedInstance] sendBindingVerificationCodeWithEmail:@"yourEmail" countryCode:@"yourCountryCode" success:^{

} failure:^(NSError *error) {

}];

//绑定邮箱
[[ThingSmartUser sharedInstance] bindEmail:@"yourEmail" withCountryCode:@"yourCountryCode" code:@"yourVerifyCode" sId:@"yourSId" success:^{

} failure:^(NSError *error) {

}];
```

Swift:

```Swift
ThingSmartUser.sharedInstance().sendBindingVerificationCode(withEmail: "yourEmail", countryCode: "yourCountryCode") {
    print("login success")
} failure: { error in
    if let e = error {
        print("login failure: \(e)")
    }
}

ThingSmartUser.sharedInstance().bindEmail("yourEmail", withCountryCode: "yourCountryCode", code: "yourVerifyCode", sId: "sId") {
    print("login success")
} failure: { error in
    if let e = error {
        print("login failure: \(e)")
    }
}
```

:::info
重置密码后，如果有多个 App 都同时登录了这个账号，那么其他设备上的 App 会触发 Session 失效的回调。您需要自行实现回调后的动作，如跳转到登录页面等。详情请参考 [Session 过期的处理](https://developer.tuya.com/cn/docs/app-development/iOS-user-infoupdate?id=Kaixuudvdx84h#session)。
:::