//
//  ThingSmartAIAgentRequest.h
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2026 Tuya Inc. (https://developer.tuya.com/)

#import <ThingSmartBaseKit/ThingSmartBaseKit.h>
#import "ThingSmartAIAgentRequestModel.h"

NS_ASSUME_NONNULL_BEGIN

/// ATOP API request class for the AI agent business.
///
/// The APIs are grouped into four categories by function:
/// 1. Agent configuration services (m.life.ai.agent.config.*)
/// 2. Agent role services (m.life.ai.agent.role.*)
/// 3. Agent role chat services (m.life.ai.agent.chat.*)
/// 4. Voice services (m.life.ai.timbre.*)
///
/// Usage example:
/// @code
/// // Note: the request instance must be retained (e.g., as a property of the view controller); if it is released early, callbacks will not be received.
/// self.agentRequest = [[ThingSmartAIAgentRequest alloc] init];
///
/// ThingSmartAIAgentReq *req = [[ThingSmartAIAgentReq alloc] init];
/// req.devId = @"your-device-id";
/// req.bindRoleType = ThingSmartAIAgentBindRoleTypeRoleTemplate;
/// req.roleId = @"role-id";
/// req.fetchSize = 20;
/// req.gmtEnd = @((long long)([NSDate date].timeIntervalSince1970 * 1000));
/// [self.agentRequest fetchChatHistory:req success:^(NSArray<ThingSmartAIAgentChatRecordResult *> *records) {
///     NSLog(@"records: %@", records);
/// } failure:^(NSError *error) {
///     NSLog(@"error: %@", error);
/// }];
/// @endcode
@interface ThingSmartAIAgentRequest : ThingSmartRequest

#pragma mark - Agent Configuration Services

/// Fetch the list of supported avatars
///
/// API: `m.life.ai.agent.config.list-support-avatars`
/// @param devId Device ID
/// @param success Avatar list
/// @param failure Failure callback
- (void)listSupportAvatarsWithDevId:(NSString *)devId
                            success:(nullable void (^)(NSArray<ThingSmartAIAgentAvatarResult *> *avatars))success
                            failure:(nullable ThingFailureError)failure;

/// Fetch the list of supported languages
///
/// API: `m.life.ai.agent.config.list-support-languages`
/// @param devId Device ID
/// @param success Language list
/// @param failure Failure callback
- (void)listSupportLanguagesWithDevId:(NSString *)devId
                              success:(nullable void (^)(NSArray<ThingSmartAIAgentLanguageResult *> *languages))success
                              failure:(nullable ThingFailureError)failure;

#pragma mark - Agent Role Services

/// Create a custom role for the AI agent
///
/// API: `m.life.ai.agent.role.custom-role.add`
/// @param req Fields used: devId (required), roleName (required), roleIntroduce (required), roleImgUrl (required),
///            useLangCode (required), roleDesc, useTimbreId, speed
/// @param success roleId of the newly created role
/// @param failure Failure callback
- (void)addCustomRole:(ThingSmartAIAgentReq *)req
              success:(nullable void (^)(NSString *roleId))success
              failure:(nullable ThingFailureError)failure;

/// Query the AI agent custom role list (paginated)
///
/// API: `m.life.ai.agent.role.custom-role.page`
/// @param req Fields used: devId (required), pageNo (required), pageSize (required), roleCategory
/// @param success Custom role list
/// @param failure Failure callback
- (void)queryCustomRolePage:(ThingSmartAIAgentReq *)req
                    success:(nullable void (^)(ThingSmartAIAgentCustomRolePageResult *pageResult))success
                    failure:(nullable ThingFailureError)failure;

/// Query AI agent custom role details
///
/// API: `m.life.ai.agent.role.custom-role.detail`
/// @param req Fields used: devId (required), roleId (required)
/// @param success Role details
/// @param failure Failure callback
- (void)queryCustomRoleDetail:(ThingSmartAIAgentReq *)req
                      success:(nullable void (^)(ThingSmartAIAgentRoleDetailResult *detail))success
                      failure:(nullable ThingFailureError)failure;

/// Update a custom role of the AI agent
///
/// API: `m.life.ai.agent.role.custom-role.update`
/// @param req Fields used: devId (required), roleId (required), roleName, roleDesc, roleIntroduce,
///            roleImgUrl, useLangCode, useTimbreId, speed, needBind
/// @param success Whether the update succeeded
/// @param failure Failure callback
- (void)updateCustomRole:(ThingSmartAIAgentReq *)req
                 success:(nullable ThingSuccessBOOL)success
                 failure:(nullable ThingFailureError)failure;

/// Delete a custom role of the AI agent
///
/// API: `m.life.ai.agent.role.custom-role.delete`
/// @param req Fields used: devId (required), roleId (required)
/// @param success Whether the deletion succeeded
/// @param failure Failure callback
- (void)deleteCustomRole:(ThingSmartAIAgentReq *)req
                 success:(nullable ThingSuccessBOOL)success
                 failure:(nullable ThingFailureError)failure;

/// Query the AI agent role template list
///
/// API: `m.life.ai.agent.role.role-template.list`
/// @param req Fields used: devId (required), tagCode
/// @param success Role template list
/// @param failure Failure callback
- (void)queryRoleTemplateList:(ThingSmartAIAgentReq *)req
                      success:(nullable void (^)(NSArray<ThingSmartAIAgentRoleTemplateResult *> *templates))success
                      failure:(nullable ThingFailureError)failure;

/// Query AI agent role template details
///
/// API: `m.life.ai.agent.role.role-template.detail`
/// @param req Fields used: devId (required), roleId (required)
/// @param success Role template details
/// @param failure Failure callback
- (void)queryRoleTemplateDetail:(ThingSmartAIAgentReq *)req
                        success:(nullable void (^)(ThingSmartAIAgentRoleDetailResult *detail))success
                        failure:(nullable ThingFailureError)failure;

/// Bind a role to the AI agent
///
/// API: `m.life.ai.agent.role.bind-with-role`
/// @param req Fields used: devId (required), bindRoleType (required), roleId (required)
/// @param success Whether the binding succeeded
/// @param failure Failure callback
- (void)bindWithRole:(ThingSmartAIAgentReq *)req
             success:(nullable ThingSuccessBOOL)success
             failure:(nullable ThingFailureError)failure;

/// Query the agent role bound to the agent
///
/// API: `m.life.ai.agent.role.get-bind-role`
/// @param devId Device ID
/// @param success Details of the bound role
/// @param failure Failure callback
- (void)getBindRoleWithDevId:(NSString *)devId
                     success:(nullable void (^)(ThingSmartAIAgentRoleDetailResult *detail))success
                     failure:(nullable ThingFailureError)failure;

/// Initialize the binding between a role and the agent
///
/// API: `m.life.ai.agent.role.initialize-agent-role-binding`
/// @param devId Device ID
/// @param success Details of the role bound after initialization
/// @param failure Failure callback
- (void)initializeAgentRoleBindingWithDevId:(NSString *)devId
                                    success:(nullable void (^)(ThingSmartAIAgentRoleDetailResult *detail))success
                                    failure:(nullable ThingFailureError)failure;

#pragma mark - Agent Role Chat Services

/// Query the AI agent chat history (cursor-based)
///
/// API: `m.life.ai.agent.chat.history.fetch`
/// @param req Fields used: devId (required), bindRoleType (required), roleId (required), fetchSize (required),
///            gmtStart, gmtEnd (the start and end timestamps cannot both be empty), timeAsc
/// @param success Chat history record list
/// @param failure Failure callback
- (void)fetchChatHistory:(ThingSmartAIAgentReq *)req
                 success:(nullable void (^)(NSArray<ThingSmartAIAgentChatRecordResult *> *records))success
                 failure:(nullable ThingFailureError)failure;

/// Delete the chat history of an AI agent role
///
/// API: `m.life.ai.agent.chat.history.delete`
/// @param req Fields used: devId (required), bindRoleType (required), roleId (required), clearAllHistory (required), requestIds
/// @param success Whether the deletion succeeded
/// @param failure Failure callback
- (void)deleteChatHistory:(ThingSmartAIAgentReq *)req
                  success:(nullable ThingSuccessBOOL)success
                  failure:(nullable ThingFailureError)failure;

/// Query the memory switch of the AI agent
///
/// API: `m.life.ai.agent.chat.memory.get-switch`
/// @param devId Device ID
/// @param success Memory switch state
/// @param failure Failure callback
- (void)getMemorySwitchWithDevId:(NSString *)devId
                         success:(nullable void (^)(ThingSmartAIAgentMemorySwitchResult *memorySwitch))success
                         failure:(nullable ThingFailureError)failure;

/// Query the memory list of an AI agent role
///
/// API: `m.life.ai.agent.chat.memory.list`
/// @param req Fields used: devId (required), bindRoleType (required), roleId (required)
/// @param success Memory list grouped by scope
/// @param failure Failure callback
- (void)queryMemoryList:(ThingSmartAIAgentReq *)req
                success:(nullable void (^)(NSArray<ThingSmartAIAgentMemoryGroupResult *> *groups))success
                failure:(nullable ThingFailureError)failure;

/// Delete memories of an AI agent role
///
/// API: `m.life.ai.agent.chat.memory.delete`
/// @param req Fields used: devId (required), bindRoleType (required), roleId (required), clearAllMemory (required), memoryKeys
/// @param success Whether the deletion succeeded
/// @param failure Failure callback
- (void)deleteMemory:(ThingSmartAIAgentReq *)req
             success:(nullable ThingSuccessBOOL)success
             failure:(nullable ThingFailureError)failure;

/// Query the chat summary of an AI agent role
///
/// API: `m.life.ai.agent.chat.chat-summary.get`
/// @param req Fields used: devId (required), bindRoleType (required), roleId (required)
/// @param success Chat summary item list
/// @param failure Failure callback
- (void)getChatSummary:(ThingSmartAIAgentReq *)req
               success:(nullable ThingSuccessList)success
               failure:(nullable ThingFailureError)failure;

/// Update the chat summary of an AI agent role
///
/// API: `m.life.ai.agent.chat.chat-summary.update`
/// @param req Fields used: devId (required), bindRoleType (required), roleId (required), summaryItems (required)
/// @param success Whether the update succeeded
/// @param failure Failure callback
- (void)updateChatSummary:(ThingSmartAIAgentReq *)req
                  success:(nullable ThingSuccessBOOL)success
                  failure:(nullable ThingFailureError)failure;

/// Clear the chat context of an AI agent role
///
/// API: `m.life.ai.agent.chat.context.clear`
/// @param req Fields used: devId (required), bindRoleType (required), roleId (required)
/// @param success Whether the clearing succeeded
/// @param failure Failure callback
- (void)clearChatContext:(ThingSmartAIAgentReq *)req
                 success:(nullable ThingSuccessBOOL)success
                 failure:(nullable ThingFailureError)failure;

/// Fetch the current chat emotion
///
/// API: `m.life.ai.agent.chat.chat-emotion.current`
/// @param devId Device ID
/// @param success Current chat emotion
/// @param failure Failure callback
- (void)getCurrentChatEmotionWithDevId:(NSString *)devId
                               success:(nullable void (^)(ThingSmartAIAgentChatEmotionResult *emotion))success
                               failure:(nullable ThingFailureError)failure;

#pragma mark - Voice Services

/// Fetch the standard voice list (paginated)
///
/// API: `m.life.ai.timbre.page`
/// @param req Fields used: devId (required), pageNo (required), pageSize (required), tag, keyWord, lang,
///            preferredVoiceId, categoryTagCode
/// @param success Voice page result (page/pageSize/total/totalPage/list)
/// @param failure Failure callback
- (void)queryTimbrePage:(ThingSmartAIAgentReq *)req
                success:(nullable void (^)(ThingSmartAITimbrePageResult *pageResult))success
                failure:(nullable ThingFailureError)failure;

@end

NS_ASSUME_NONNULL_END
