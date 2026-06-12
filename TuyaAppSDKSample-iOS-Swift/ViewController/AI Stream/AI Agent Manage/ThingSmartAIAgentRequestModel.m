//
//  ThingSmartAIAgentRequestModel.m
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2026 Tuya Inc. (https://developer.tuya.com/)

#import "ThingSmartAIAgentRequestModel.h"
#import <YYModel/YYModel.h>

@implementation ThingSmartAIAgentReq
@end

@implementation ThingSmartAIAgentAvatarResult
@end

@implementation ThingSmartAIAgentLanguageResult
@end

@implementation ThingSmartAIAgentCustomRoleResult
@end

@implementation ThingSmartAIAgentCustomRolePageResult

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"list": ThingSmartAIAgentCustomRoleResult.class,
    };
}

@end

@implementation ThingSmartAIAgentRoleDetailResult
@end

@implementation ThingSmartAIAgentRoleTemplateResult
@end

@implementation ThingSmartAIAgentChatMessageResult
@end

@implementation ThingSmartAIAgentChatRecordResult

// YYModel: object types inside container properties
+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"question": ThingSmartAIAgentChatMessageResult.class,
        @"answer": ThingSmartAIAgentChatMessageResult.class,
    };
}

@end

@implementation ThingSmartAIAgentMemorySwitchResult
@end

@implementation ThingSmartAIAgentMemoryResult
@end

@implementation ThingSmartAIAgentMemoryGroupResult

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"memoryList": ThingSmartAIAgentMemoryResult.class,
    };
}

@end

@implementation ThingSmartAIAgentChatEmotionResult
@end

@implementation ThingSmartAITimbreResult
@end

@implementation ThingSmartAITimbrePageResult

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"list": ThingSmartAITimbreResult.class,
    };
}

@end
