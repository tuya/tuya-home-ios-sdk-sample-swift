//
//  ThingSmartAIAgentRequestModel.h
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2026 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Bind role type
typedef NS_ENUM(NSInteger, ThingSmartAIAgentBindRoleType) {
    /// Custom agent role
    ThingSmartAIAgentBindRoleTypeCustomRole = 0,
    /// Agent role template
    ThingSmartAIAgentBindRoleTypeRoleTemplate = 1,
    /// Default role in single-role scenarios
    ThingSmartAIAgentBindRoleTypeSingleSceneDefaultRole = 2,
};

#pragma mark - Request Model (Req)
@interface ThingSmartAIAgentReq : NSObject

/// Device ID (required by all APIs)
@property (nonatomic, copy, nullable) NSString *devId;

/// Role ID (its exact meaning depends on bindRoleType)
@property (nonatomic, copy, nullable) NSString *roleId;

/// Bind role type (0 - custom agent role, 1 - agent role template, 2 - default role in single-role scenarios)
@property (nonatomic, assign) ThingSmartAIAgentBindRoleType bindRoleType;

#pragma mark Role

/// Role name
@property (nonatomic, copy, nullable) NSString *roleName;

/// Role description
@property (nonatomic, copy, nullable) NSString *roleDesc;

/// Role introduction
@property (nonatomic, copy, nullable) NSString *roleIntroduce;

/// Role image
@property (nonatomic, copy, nullable) NSString *roleImgUrl;

/// Language used by the role
@property (nonatomic, copy, nullable) NSString *useLangCode;

/// Voice used by the role
@property (nonatomic, copy, nullable) NSString *useTimbreId;

/// Speech speed used by the role
@property (nonatomic, copy, nullable) NSString *speed;

/// Whether binding is needed (used when updating a custom role, optional)
@property (nonatomic, strong, nullable) NSNumber *needBind;

/// Role category (used when querying the custom role list, optional)
@property (nonatomic, copy, nullable) NSString *roleCategory;

/// Tag (used when querying the role template list, optional)
@property (nonatomic, copy, nullable) NSString *tagCode;

#pragma mark Pagination

/// Page number
@property (nonatomic, assign) NSInteger pageNo;

/// Page size
@property (nonatomic, assign) NSInteger pageSize;

#pragma mark Chat

/// Start timestamp (13-digit; cannot be empty together with the end timestamp)
@property (nonatomic, strong, nullable) NSNumber *gmtStart;

/// End timestamp (13-digit; cannot be empty together with the start timestamp)
@property (nonatomic, strong, nullable) NSNumber *gmtEnd;

/// Number of records to fetch (required when querying chat history)
@property (nonatomic, assign) NSInteger fetchSize;

/// Whether to sort by time in ascending order (descending by default, optional)
@property (nonatomic, strong, nullable) NSNumber *timeAsc;

/// Whether to clear all chat history
@property (nonatomic, assign) BOOL clearAllHistory;

/// requestId(s) of the chat history records to delete (comma-separated for multiple, optional)
@property (nonatomic, copy, nullable) NSString *requestIds;

/// Whether to clear all memories
@property (nonatomic, assign) BOOL clearAllMemory;

/// memoryKey(s) of the memories to delete (comma-separated for multiple, optional)
@property (nonatomic, copy, nullable) NSString *memoryKeys;

/// Chat summary (items can be separated by \n\n)
@property (nonatomic, copy, nullable) NSString *summaryItems;

#pragma mark Voice

/// Voice tag (optional)
@property (nonatomic, copy, nullable) NSString *tag;

/// Keyword (optional)
@property (nonatomic, copy, nullable) NSString *keyWord;

/// Supported language (optional)
@property (nonatomic, copy, nullable) NSString *lang;

/// Voice ID to show first (optional)
@property (nonatomic, copy, nullable) NSString *preferredVoiceId;

/// Voice category tag code (optional)
@property (nonatomic, copy, nullable) NSString *categoryTagCode;

@end

#pragma mark - Response Models (Agent Configuration Services)

/// Avatar info
@interface ThingSmartAIAgentAvatarResult : NSObject
/// Avatar ID
@property (nonatomic, copy, nullable) NSString *avatarId;
/// Avatar URL
@property (nonatomic, copy, nullable) NSString *url;
@end

/// Language info
@interface ThingSmartAIAgentLanguageResult : NSObject
/// Language code
@property (nonatomic, copy, nullable) NSString *langCode;
/// Language name
@property (nonatomic, copy, nullable) NSString *langName;
/// Whether this is the default language
@property (nonatomic, assign) BOOL hasDefault;
@end

#pragma mark - Response Models (Agent Role Services)

/// Custom role list item
@interface ThingSmartAIAgentCustomRoleResult : NSObject
/// Role ID
@property (nonatomic, copy, nullable) NSString *roleId;
/// Role name
@property (nonatomic, copy, nullable) NSString *roleName;
/// Role description
@property (nonatomic, copy, nullable) NSString *roleDesc;
/// Role introduction
@property (nonatomic, copy, nullable) NSString *roleIntroduce;
/// Role image
@property (nonatomic, copy, nullable) NSString *roleImgUrl;
/// Language code used by the role
@property (nonatomic, copy, nullable) NSString *useLangCode;
/// Language name used by the role
@property (nonatomic, copy, nullable) NSString *useLangName;
/// Voice used by the role
@property (nonatomic, copy, nullable) NSString *useTimbreId;
/// Name of the voice used by the role
@property (nonatomic, copy, nullable) NSString *useTimbreName;
/// Template ID
@property (nonatomic, copy, nullable) NSString *templateId;
/// Most recent reply text
@property (nonatomic, copy, nullable) NSString *lastTextAnswer;
@end

/// Custom role page result
@interface ThingSmartAIAgentCustomRolePageResult : NSObject
/// Total count
@property (nonatomic, assign) NSInteger total;
/// Total pages
@property (nonatomic, assign) NSInteger totalPage;
/// Custom role list
@property (nonatomic, strong, nullable) NSArray<ThingSmartAIAgentCustomRoleResult *> *list;
@end

/// Role details
///
/// Custom role details, role template details, and the role bound to the agent return the same fields and share this model.
@interface ThingSmartAIAgentRoleDetailResult : NSObject
/// Role ID
@property (nonatomic, copy, nullable) NSString *roleId;
/// Role name
@property (nonatomic, copy, nullable) NSString *roleName;
/// Role description
@property (nonatomic, copy, nullable) NSString *roleDesc;
/// Role introduction
@property (nonatomic, copy, nullable) NSString *roleIntroduce;
/// Role image
@property (nonatomic, copy, nullable) NSString *roleImgUrl;
/// Language code used by the role
@property (nonatomic, copy, nullable) NSString *useLangCode;
/// Language name used by the role
@property (nonatomic, copy, nullable) NSString *useLangName;
/// Voice used by the role
@property (nonatomic, copy, nullable) NSString *useTimbreId;
/// Whether it is a user voice clone
@property (nonatomic, assign) BOOL isUserCloneTimbre;
/// Name of the voice used by the role
@property (nonatomic, copy, nullable) NSString *useTimbreName;
/// Voice languages supported by the role, comma-separated for multiple
@property (nonatomic, copy, nullable) NSString *useTimbreSupportLangs;
/// Role tags
@property (nonatomic, strong, nullable) NSArray<NSString *> *useTimbreTags;
/// Voice speed
@property (nonatomic, assign) double speed;
/// Voice tone
@property (nonatomic, assign) double tone;
/// Template ID
@property (nonatomic, copy, nullable) NSString *templateId;
/// Bind role type (0 - custom agent role, 1 - agent role template, 2 - default role in single-role scenarios)
@property (nonatomic, assign) NSInteger bindRoleType;
/// Most recent reply text
@property (nonatomic, copy, nullable) NSString *lastTextAnswer;
@end

/// Role template list item
@interface ThingSmartAIAgentRoleTemplateResult : NSObject
/// Role template ID
@property (nonatomic, copy, nullable) NSString *templateId;
/// Role ID
@property (nonatomic, copy, nullable) NSString *roleId;
/// Role code
@property (nonatomic, copy, nullable) NSString *roleCode;
/// Role name
@property (nonatomic, copy, nullable) NSString *roleName;
/// Role introduction
@property (nonatomic, copy, nullable) NSString *roleDesc;
/// Role icon
@property (nonatomic, copy, nullable) NSString *roleImgUrl;
/// Role traits
@property (nonatomic, copy, nullable) NSString *roleIntroduce;
/// Language code used by the role
@property (nonatomic, copy, nullable) NSString *useLangCode;
/// Language name used by the role
@property (nonatomic, copy, nullable) NSString *useLangName;
/// Voice used by the role
@property (nonatomic, copy, nullable) NSString *useTimbreId;
/// Name of the voice used by the role
@property (nonatomic, copy, nullable) NSString *useTimbreName;
/// Voice languages supported by the role, comma-separated for multiple
@property (nonatomic, copy, nullable) NSString *useTimbreSupportLangs;
/// Names of the voice languages supported by the role, comma-separated for multiple
@property (nonatomic, copy, nullable) NSString *useTimbreSupportLangNames;
/// Default flag (1 means default)
@property (nonatomic, assign) NSInteger defaultFlag;
/// Most recent reply text
@property (nonatomic, copy, nullable) NSString *lastTextAnswer;
@end

#pragma mark - Response Models (Agent Role Chat Services)

/// Chat message content
@interface ThingSmartAIAgentChatMessageResult : NSObject
/// Message content
@property (nonatomic, copy, nullable) NSString *context;
/// Type
@property (nonatomic, copy, nullable) NSString *type;
@end

/// Chat history record
@interface ThingSmartAIAgentChatRecordResult : NSObject
/// Chat time
@property (nonatomic, copy, nullable) NSString *createTime;
/// Request ID
@property (nonatomic, copy, nullable) NSString *requestId;
/// Question
@property (nonatomic, strong, nullable) NSArray<ThingSmartAIAgentChatMessageResult *> *question;
/// Answer
@property (nonatomic, strong, nullable) NSArray<ThingSmartAIAgentChatMessageResult *> *answer;
/// Creation timestamp
@property (nonatomic, assign) long long gmtCreate;
@end

/// Memory switch state
@interface ThingSmartAIAgentMemorySwitchResult : NSObject
/// Summary switch
@property (nonatomic, assign) BOOL summaryOpen;
/// Memory switch
@property (nonatomic, assign) BOOL memoryOpen;
@end

/// Memory entry
@interface ThingSmartAIAgentMemoryResult : NSObject
/// Memory key
@property (nonatomic, copy, nullable) NSString *memoryKey;
/// Memory value
@property (nonatomic, copy, nullable) NSString *memoryValue;
/// Memory name
@property (nonatomic, copy, nullable) NSString *memoryName;
/// Memory scope
@property (nonatomic, assign) NSInteger effectiveScope;
/// Memory scope name
@property (nonatomic, copy, nullable) NSString *effectiveScopeName;
/// Whether the memory is shared
@property (nonatomic, assign) BOOL shareMemory;
@end

/// Memory group (by scope)
@interface ThingSmartAIAgentMemoryGroupResult : NSObject
/// Memory scope
@property (nonatomic, assign) NSInteger effectiveScope;
/// Memory scope name
@property (nonatomic, copy, nullable) NSString *effectiveScopeName;
/// Memory list
@property (nonatomic, strong, nullable) NSArray<ThingSmartAIAgentMemoryResult *> *memoryList;
@end

/// Current chat emotion
@interface ThingSmartAIAgentChatEmotionResult : NSObject
/// Whether emotion is enabled
@property (nonatomic, assign) BOOL emotionOpen;
/// Emotion
@property (nonatomic, copy, nullable) NSString *emotion;
/// Text
@property (nonatomic, copy, nullable) NSString *text;
/// Image URL
@property (nonatomic, copy, nullable) NSString *url;
/// Creation time
@property (nonatomic, assign) long long gmtCreate;
/// Modification time
@property (nonatomic, assign) long long gmtModified;
@end

#pragma mark - Response Models (Voice Services)

/// Voice info
@interface ThingSmartAITimbreResult : NSObject
/// Voice identifier
@property (nonatomic, copy, nullable) NSString *voiceId;
/// Voice name
@property (nonatomic, copy, nullable) NSString *voiceName;
/// Description tag list
@property (nonatomic, strong, nullable) NSArray<NSString *> *descTags;
/// Supported language list
@property (nonatomic, strong, nullable) NSArray<NSString *> *supportLangs;
/// Voice speed
@property (nonatomic, assign) double speed;
/// Voice tone
@property (nonatomic, assign) double tone;
/// Demo audio URL
@property (nonatomic, copy, nullable) NSString *demoUrl;
@end

/// Voice page result
@interface ThingSmartAITimbrePageResult : NSObject
/// Current page number
@property (nonatomic, assign) NSInteger page;
/// Page size
@property (nonatomic, assign) NSInteger pageSize;
/// Total count
@property (nonatomic, assign) NSInteger total;
/// Total pages
@property (nonatomic, assign) NSInteger totalPage;
/// Voice list
@property (nonatomic, strong, nullable) NSArray<ThingSmartAITimbreResult *> *list;
@end

NS_ASSUME_NONNULL_END
