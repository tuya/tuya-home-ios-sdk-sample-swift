//
//  ThingSmartAIAgentRequest.m
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2026 Tuya Inc. (https://developer.tuya.com/)

#import "ThingSmartAIAgentRequest.h"
#import <YYModel/YYModel.h>

@implementation ThingSmartAIAgentRequest

#pragma mark - Agent Configuration Services

- (void)listSupportAvatarsWithDevId:(NSString *)devId
                            success:(nullable void (^)(NSArray<ThingSmartAIAgentAvatarResult *> *))success
                            failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = devId;
    [self requestListWithApiName:@"m.life.ai.agent.config.list-support-avatars"
                        postData:postData
                      modelClass:ThingSmartAIAgentAvatarResult.class
                         success:success
                         failure:failure];
}

- (void)listSupportLanguagesWithDevId:(NSString *)devId
                              success:(nullable void (^)(NSArray<ThingSmartAIAgentLanguageResult *> *))success
                              failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = devId;
    [self requestListWithApiName:@"m.life.ai.agent.config.list-support-languages"
                        postData:postData
                      modelClass:ThingSmartAIAgentLanguageResult.class
                         success:success
                         failure:failure];
}

#pragma mark - Agent Role Services

- (void)addCustomRole:(ThingSmartAIAgentReq *)req
              success:(nullable void (^)(NSString *))success
              failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = req.devId;
    postData[@"roleName"] = req.roleName;
    postData[@"roleDesc"] = req.roleDesc;
    postData[@"roleIntroduce"] = req.roleIntroduce;
    postData[@"roleImgUrl"] = req.roleImgUrl;
    postData[@"useLangCode"] = req.useLangCode;
    postData[@"useTimbreId"] = req.useTimbreId;
    postData[@"speed"] = req.speed;
    [self requestStringWithApiName:@"m.life.ai.agent.role.custom-role.add"
                          postData:postData
                           success:success
                           failure:failure];
}

- (void)queryCustomRolePage:(ThingSmartAIAgentReq *)req
                    success:(nullable void (^)(ThingSmartAIAgentCustomRolePageResult *))success
                    failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = req.devId;
    postData[@"pageNo"] = @(req.pageNo);
    postData[@"pageSize"] = @(req.pageSize);
    postData[@"roleCategory"] = req.roleCategory;
    [self requestObjectWithApiName:@"m.life.ai.agent.role.custom-role.page"
                          postData:postData
                        modelClass:ThingSmartAIAgentCustomRolePageResult.class
                           success:success
                           failure:failure];
}

- (void)queryCustomRoleDetail:(ThingSmartAIAgentReq *)req
                      success:(nullable void (^)(ThingSmartAIAgentRoleDetailResult *))success
                      failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = req.devId;
    postData[@"roleId"] = req.roleId;
    [self requestObjectWithApiName:@"m.life.ai.agent.role.custom-role.detail"
                          postData:postData
                        modelClass:ThingSmartAIAgentRoleDetailResult.class
                           success:success
                           failure:failure];
}

- (void)updateCustomRole:(ThingSmartAIAgentReq *)req
                 success:(nullable ThingSuccessBOOL)success
                 failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = req.devId;
    postData[@"roleId"] = req.roleId;
    postData[@"roleName"] = req.roleName;
    postData[@"roleDesc"] = req.roleDesc;
    postData[@"roleIntroduce"] = req.roleIntroduce;
    postData[@"roleImgUrl"] = req.roleImgUrl;
    postData[@"useLangCode"] = req.useLangCode;
    postData[@"useTimbreId"] = req.useTimbreId;
    postData[@"speed"] = req.speed;
    postData[@"needBind"] = req.needBind;
    [self requestBoolWithApiName:@"m.life.ai.agent.role.custom-role.update"
                        postData:postData
                         success:success
                         failure:failure];
}

- (void)deleteCustomRole:(ThingSmartAIAgentReq *)req
                 success:(nullable ThingSuccessBOOL)success
                 failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = req.devId;
    postData[@"roleId"] = req.roleId;
    [self requestBoolWithApiName:@"m.life.ai.agent.role.custom-role.delete"
                        postData:postData
                         success:success
                         failure:failure];
}

- (void)queryRoleTemplateList:(ThingSmartAIAgentReq *)req
                      success:(nullable void (^)(NSArray<ThingSmartAIAgentRoleTemplateResult *> *))success
                      failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = req.devId;
    postData[@"tagCode"] = req.tagCode;
    [self requestListWithApiName:@"m.life.ai.agent.role.role-template.list"
                        postData:postData
                      modelClass:ThingSmartAIAgentRoleTemplateResult.class
                         success:success
                         failure:failure];
}

- (void)queryRoleTemplateDetail:(ThingSmartAIAgentReq *)req
                        success:(nullable void (^)(ThingSmartAIAgentRoleDetailResult *))success
                        failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = req.devId;
    postData[@"roleId"] = req.roleId;
    [self requestObjectWithApiName:@"m.life.ai.agent.role.role-template.detail"
                          postData:postData
                        modelClass:ThingSmartAIAgentRoleDetailResult.class
                           success:success
                           failure:failure];
}

- (void)bindWithRole:(ThingSmartAIAgentReq *)req
             success:(nullable ThingSuccessBOOL)success
             failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = req.devId;
    postData[@"bindRoleType"] = @(req.bindRoleType);
    postData[@"roleId"] = req.roleId;
    [self requestBoolWithApiName:@"m.life.ai.agent.role.bind-with-role"
                        postData:postData
                         success:success
                         failure:failure];
}

- (void)getBindRoleWithDevId:(NSString *)devId
                     success:(nullable void (^)(ThingSmartAIAgentRoleDetailResult *))success
                     failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = devId;
    [self requestObjectWithApiName:@"m.life.ai.agent.role.get-bind-role"
                          postData:postData
                        modelClass:ThingSmartAIAgentRoleDetailResult.class
                           success:success
                           failure:failure];
}

- (void)initializeAgentRoleBindingWithDevId:(NSString *)devId
                                    success:(nullable void (^)(ThingSmartAIAgentRoleDetailResult *))success
                                    failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = devId;
    [self requestObjectWithApiName:@"m.life.ai.agent.role.initialize-agent-role-binding"
                          postData:postData
                        modelClass:ThingSmartAIAgentRoleDetailResult.class
                           success:success
                           failure:failure];
}

#pragma mark - Agent Role Chat Services

- (void)fetchChatHistory:(ThingSmartAIAgentReq *)req
                 success:(nullable void (^)(NSArray<ThingSmartAIAgentChatRecordResult *> *))success
                 failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = req.devId;
    postData[@"bindRoleType"] = @(req.bindRoleType);
    postData[@"roleId"] = req.roleId;
    postData[@"fetchSize"] = @(req.fetchSize);
    postData[@"gmtStart"] = req.gmtStart;
    postData[@"gmtEnd"] = req.gmtEnd;
    postData[@"timeAsc"] = req.timeAsc;
    [self requestListWithApiName:@"m.life.ai.agent.chat.history.fetch"
                        postData:postData
                      modelClass:ThingSmartAIAgentChatRecordResult.class
                         success:success
                         failure:failure];
}

- (void)deleteChatHistory:(ThingSmartAIAgentReq *)req
                  success:(nullable ThingSuccessBOOL)success
                  failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = req.devId;
    postData[@"bindRoleType"] = @(req.bindRoleType);
    postData[@"roleId"] = req.roleId;
    postData[@"clearAllHistory"] = @(req.clearAllHistory);
    postData[@"requestIds"] = req.requestIds;
    [self requestBoolWithApiName:@"m.life.ai.agent.chat.history.delete"
                        postData:postData
                         success:success
                         failure:failure];
}

- (void)getMemorySwitchWithDevId:(NSString *)devId
                         success:(nullable void (^)(ThingSmartAIAgentMemorySwitchResult *))success
                         failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = devId;
    [self requestObjectWithApiName:@"m.life.ai.agent.chat.memory.get-switch"
                          postData:postData
                        modelClass:ThingSmartAIAgentMemorySwitchResult.class
                           success:success
                           failure:failure];
}

- (void)queryMemoryList:(ThingSmartAIAgentReq *)req
                success:(nullable void (^)(NSArray<ThingSmartAIAgentMemoryGroupResult *> *))success
                failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = req.devId;
    postData[@"bindRoleType"] = @(req.bindRoleType);
    postData[@"roleId"] = req.roleId;
    [self requestListWithApiName:@"m.life.ai.agent.chat.memory.list"
                        postData:postData
                      modelClass:ThingSmartAIAgentMemoryGroupResult.class
                         success:success
                         failure:failure];
}

- (void)deleteMemory:(ThingSmartAIAgentReq *)req
             success:(nullable ThingSuccessBOOL)success
             failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = req.devId;
    postData[@"bindRoleType"] = @(req.bindRoleType);
    postData[@"roleId"] = req.roleId;
    postData[@"clearAllMemory"] = @(req.clearAllMemory);
    postData[@"memoryKeys"] = req.memoryKeys;
    [self requestBoolWithApiName:@"m.life.ai.agent.chat.memory.delete"
                        postData:postData
                         success:success
                         failure:failure];
}

- (void)getChatSummary:(ThingSmartAIAgentReq *)req
               success:(nullable ThingSuccessList)success
               failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = req.devId;
    postData[@"bindRoleType"] = @(req.bindRoleType);
    postData[@"roleId"] = req.roleId;
    [self requestWithApiName:@"m.life.ai.agent.chat.chat-summary.get"
                    postData:postData
                     version:@"1.0"
                     success:^(id result) {
        if (success) success(result);
    } failure:failure];
}

- (void)updateChatSummary:(ThingSmartAIAgentReq *)req
                  success:(nullable ThingSuccessBOOL)success
                  failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = req.devId;
    postData[@"bindRoleType"] = @(req.bindRoleType);
    postData[@"roleId"] = req.roleId;
    postData[@"summaryItems"] = req.summaryItems;
    [self requestBoolWithApiName:@"m.life.ai.agent.chat.chat-summary.update"
                        postData:postData
                         success:success
                         failure:failure];
}

- (void)clearChatContext:(ThingSmartAIAgentReq *)req
                 success:(nullable ThingSuccessBOOL)success
                 failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = req.devId;
    postData[@"bindRoleType"] = @(req.bindRoleType);
    postData[@"roleId"] = req.roleId;
    [self requestBoolWithApiName:@"m.life.ai.agent.chat.context.clear"
                        postData:postData
                         success:success
                         failure:failure];
}

- (void)getCurrentChatEmotionWithDevId:(NSString *)devId
                               success:(nullable void (^)(ThingSmartAIAgentChatEmotionResult *))success
                               failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = devId;
    [self requestObjectWithApiName:@"m.life.ai.agent.chat.chat-emotion.current"
                          postData:postData
                        modelClass:ThingSmartAIAgentChatEmotionResult.class
                           success:success
                           failure:failure];
}

#pragma mark - Voice Services

- (void)queryTimbrePage:(ThingSmartAIAgentReq *)req
                success:(nullable void (^)(ThingSmartAITimbrePageResult *))success
                failure:(nullable ThingFailureError)failure {
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    postData[@"devId"] = req.devId;
    postData[@"pageNo"] = @(req.pageNo);
    postData[@"pageSize"] = @(req.pageSize);
    postData[@"tag"] = req.tag;
    postData[@"keyWord"] = req.keyWord;
    postData[@"lang"] = req.lang;
    postData[@"preferredVoiceId"] = req.preferredVoiceId;
    postData[@"categoryTagCode"] = req.categoryTagCode;
    [self requestObjectWithApiName:@"m.life.ai.timbre.page"
                          postData:postData
                        modelClass:ThingSmartAITimbrePageResult.class
                           success:success
                           failure:failure];
}

#pragma mark - Private Methods (unified request + result parsing)

/// result is a JSON object; parse it into a single model
- (void)requestObjectWithApiName:(NSString *)apiName
                        postData:(NSDictionary *)postData
                      modelClass:(Class)modelClass
                         success:(nullable void (^)(id model))success
                         failure:(nullable ThingFailureError)failure {
    [self requestWithApiName:apiName
                    postData:postData
                     version:@"1.0"
                     success:^(id result) {
        if (success) success([modelClass yy_modelWithJSON:result]);
    } failure:failure];
}

/// result is a JSON array; parse it into an array of models
- (void)requestListWithApiName:(NSString *)apiName
                      postData:(NSDictionary *)postData
                    modelClass:(Class)modelClass
                       success:(nullable void (^)(id list))success
                       failure:(nullable ThingFailureError)failure {
    [self requestWithApiName:apiName
                    postData:postData
                     version:@"1.0"
                     success:^(id result) {
        if (success) success([NSArray yy_modelArrayWithClass:modelClass json:result]);
    } failure:failure];
}

/// result is a Bool
- (void)requestBoolWithApiName:(NSString *)apiName
                      postData:(NSDictionary *)postData
                       success:(nullable ThingSuccessBOOL)success
                       failure:(nullable ThingFailureError)failure {
    [self requestWithApiName:apiName
                    postData:postData
                     version:@"1.0"
                     success:^(id result) {
        if (success) success([result boolValue]);
    } failure:failure];
}

/// result is a String
- (void)requestStringWithApiName:(NSString *)apiName
                        postData:(NSDictionary *)postData
                         success:(nullable void (^)(NSString *result))success
                         failure:(nullable ThingFailureError)failure {
    [self requestWithApiName:apiName
                    postData:postData
                     version:@"1.0"
                     success:^(id result) {
        if (success) success(result);
    } failure:failure];
}

@end
