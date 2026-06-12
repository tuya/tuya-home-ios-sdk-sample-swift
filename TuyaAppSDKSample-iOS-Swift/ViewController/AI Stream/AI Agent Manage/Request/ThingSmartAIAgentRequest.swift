//
//  ThingSmartAIAgentRequest.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2026 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartBaseKit

/// ATOP request class for AI agent business APIs
///
/// The APIs are grouped into four categories by function:
/// 1. Agent configuration service (m.life.ai.agent.config.*)
/// 2. Agent role service (m.life.ai.agent.role.*)
/// 3. Agent role chat service (m.life.ai.agent.chat.*)
/// 4. Voice service (m.life.ai.timbre.*)
///
/// Each API has a dedicated request model (see ThingSmartAIAgentRequestModel.swift):
/// required parameters are non-optional `let`, optional parameters are optional `var`,
/// so the parameter requirements are reflected directly in the model definition.
///
/// Usage example:
/// ```swift
/// // Note: the request instance must be retained (e.g. as a ViewController property);
/// // releasing it early means callbacks will not be received
/// let agentRequest = ThingSmartAIAgentRequest()
///
/// var req = ThingSmartAIAgentChatHistoryFetchReq(devId: "your-device-id",
///                                                bindRoleType: .roleTemplate,
///                                                roleId: "role-id",
///                                                fetchSize: 20)
/// req.gmtEnd = Int64(Date().timeIntervalSince1970 * 1000)
/// agentRequest.fetchChatHistory(req) { records in
///     print("records: \(records)")
/// } failure: { error in
///     print("error: \(error)")
/// }
/// ```
final class ThingSmartAIAgentRequest: ThingSmartRequest {

    // MARK: - Agent Configuration Service

    /// Fetch the list of supported avatars
    ///
    /// API: `m.life.ai.agent.config.list-support-avatars`
    /// - Parameters:
    ///   - devId: Device ID
    ///   - success: Avatar list
    ///   - failure: Failure callback
    func listSupportAvatars(devId: String,
                            success: @escaping ([ThingSmartAIAgentAvatarResult]) -> Void,
                            failure: @escaping (Error) -> Void) {
        requestList(apiName: "m.life.ai.agent.config.list-support-avatars",
                    version: "1.0",
                    postData: ["devId": devId],
                    success: success,
                    failure: failure)
    }

    /// Fetch the list of supported languages
    ///
    /// API: `m.life.ai.agent.config.list-support-languages`
    /// - Parameters:
    ///   - devId: Device ID
    ///   - success: Language list
    ///   - failure: Failure callback
    func listSupportLanguages(devId: String,
                              success: @escaping ([ThingSmartAIAgentLanguageResult]) -> Void,
                              failure: @escaping (Error) -> Void) {
        requestList(apiName: "m.life.ai.agent.config.list-support-languages",
                    version: "1.0",
                    postData: ["devId": devId],
                    success: success,
                    failure: failure)
    }

    // MARK: - Agent Role Service

    /// Create a custom AI agent role
    ///
    /// API: `m.life.ai.agent.role.custom-role.add`
    /// - Parameters:
    ///   - req: Request model
    ///   - success: roleId of the newly created role
    ///   - failure: Failure callback
    func addCustomRole(_ req: ThingSmartAIAgentCustomRoleAddReq,
                       success: @escaping (String) -> Void,
                       failure: @escaping (Error) -> Void) {
        var postData: [String: Any] = [:]
        postData["devId"] = req.devId
        postData["roleName"] = req.roleName
        postData["roleDesc"] = req.roleDesc
        postData["roleIntroduce"] = req.roleIntroduce
        postData["roleImgUrl"] = req.roleImgUrl
        postData["useLangCode"] = req.useLangCode
        postData["useTimbreId"] = req.useTimbreId
        postData["speed"] = req.speed
        requestString(apiName: "m.life.ai.agent.role.custom-role.add",
                      version: "1.0",
                      postData: postData,
                      success: success,
                      failure: failure)
    }

    /// Query the custom AI agent role list (paged)
    ///
    /// API: `m.life.ai.agent.role.custom-role.page`
    /// - Parameters:
    ///   - req: Request model
    ///   - success: Paged result of custom roles (total/totalPage/list)
    ///   - failure: Failure callback
    func queryCustomRolePage(_ req: ThingSmartAIAgentCustomRolePageReq,
                             success: @escaping (ThingSmartAIAgentCustomRolePageResult) -> Void,
                             failure: @escaping (Error) -> Void) {
        var postData: [String: Any] = [:]
        postData["devId"] = req.devId
        postData["pageNo"] = req.pageNo
        postData["pageSize"] = req.pageSize
        postData["roleCategory"] = req.roleCategory
        requestObject(apiName: "m.life.ai.agent.role.custom-role.page",
                      version: "1.0",
                      postData: postData,
                      success: success,
                      failure: failure)
    }

    /// Query custom AI agent role details
    ///
    /// API: `m.life.ai.agent.role.custom-role.detail`
    /// - Parameters:
    ///   - req: Request model
    ///   - success: Role details
    ///   - failure: Failure callback
    func queryCustomRoleDetail(_ req: ThingSmartAIAgentCustomRoleDetailReq,
                               success: @escaping (ThingSmartAIAgentRoleDetailResult) -> Void,
                               failure: @escaping (Error) -> Void) {
        var postData: [String: Any] = [:]
        postData["devId"] = req.devId
        postData["roleId"] = req.roleId
        requestObject(apiName: "m.life.ai.agent.role.custom-role.detail",
                      version: "1.0",
                      postData: postData,
                      success: success,
                      failure: failure)
    }

    /// Update a custom AI agent role
    ///
    /// API: `m.life.ai.agent.role.custom-role.update`
    /// - Parameters:
    ///   - req: Request model (omitted optional fields are left unchanged)
    ///   - success: Whether the update succeeded
    ///   - failure: Failure callback
    func updateCustomRole(_ req: ThingSmartAIAgentCustomRoleUpdateReq,
                          success: @escaping (Bool) -> Void,
                          failure: @escaping (Error) -> Void) {
        var postData: [String: Any] = [:]
        postData["devId"] = req.devId
        postData["roleId"] = req.roleId
        postData["roleName"] = req.roleName
        postData["roleDesc"] = req.roleDesc
        postData["roleIntroduce"] = req.roleIntroduce
        postData["roleImgUrl"] = req.roleImgUrl
        postData["useLangCode"] = req.useLangCode
        postData["useTimbreId"] = req.useTimbreId
        postData["speed"] = req.speed
        postData["needBind"] = req.needBind
        requestBool(apiName: "m.life.ai.agent.role.custom-role.update",
                    version: "1.0",
                    postData: postData,
                    success: success,
                    failure: failure)
    }

    /// Delete a custom AI agent role
    ///
    /// API: `m.life.ai.agent.role.custom-role.delete`
    /// - Parameters:
    ///   - req: Request model
    ///   - success: Whether the deletion succeeded
    ///   - failure: Failure callback
    func deleteCustomRole(_ req: ThingSmartAIAgentCustomRoleDeleteReq,
                          success: @escaping (Bool) -> Void,
                          failure: @escaping (Error) -> Void) {
        var postData: [String: Any] = [:]
        postData["devId"] = req.devId
        postData["roleId"] = req.roleId
        requestBool(apiName: "m.life.ai.agent.role.custom-role.delete",
                    version: "1.0",
                    postData: postData,
                    success: success,
                    failure: failure)
    }

    /// Query the AI agent role template list
    ///
    /// API: `m.life.ai.agent.role.role-template.list`
    /// - Parameters:
    ///   - req: Request model
    ///   - success: Role template list
    ///   - failure: Failure callback
    func queryRoleTemplateList(_ req: ThingSmartAIAgentRoleTemplateListReq,
                               success: @escaping ([ThingSmartAIAgentRoleTemplateResult]) -> Void,
                               failure: @escaping (Error) -> Void) {
        var postData: [String: Any] = [:]
        postData["devId"] = req.devId
        postData["tagCode"] = req.tagCode
        requestList(apiName: "m.life.ai.agent.role.role-template.list",
                    version: "1.0",
                    postData: postData,
                    success: success,
                    failure: failure)
    }

    /// Query AI agent role template details
    ///
    /// API: `m.life.ai.agent.role.role-template.detail`
    /// - Parameters:
    ///   - req: Request model
    ///   - success: Role template details
    ///   - failure: Failure callback
    func queryRoleTemplateDetail(_ req: ThingSmartAIAgentRoleTemplateDetailReq,
                                 success: @escaping (ThingSmartAIAgentRoleDetailResult) -> Void,
                                 failure: @escaping (Error) -> Void) {
        var postData: [String: Any] = [:]
        postData["devId"] = req.devId
        postData["roleId"] = req.roleId
        requestObject(apiName: "m.life.ai.agent.role.role-template.detail",
                      version: "1.0",
                      postData: postData,
                      success: success,
                      failure: failure)
    }

    /// Bind the AI agent to a role
    ///
    /// API: `m.life.ai.agent.role.bind-with-role`
    /// - Parameters:
    ///   - req: Request model
    ///   - success: Whether the binding succeeded
    ///   - failure: Failure callback
    func bindWithRole(_ req: ThingSmartAIAgentRoleBindReq,
                      success: @escaping (Bool) -> Void,
                      failure: @escaping (Error) -> Void) {
        var postData: [String: Any] = [:]
        postData["devId"] = req.devId
        postData["bindRoleType"] = req.bindRoleType.rawValue
        postData["roleId"] = req.roleId
        requestBool(apiName: "m.life.ai.agent.role.bind-with-role",
                    version: "1.0",
                    postData: postData,
                    success: success,
                    failure: failure)
    }

    /// Query the agent role bound to the agent
    ///
    /// API: `m.life.ai.agent.role.get-bind-role`
    /// - Parameters:
    ///   - devId: Device ID
    ///   - success: Details of the bound role
    ///   - failure: Failure callback
    func getBindRole(devId: String,
                     success: @escaping (ThingSmartAIAgentRoleDetailResult) -> Void,
                     failure: @escaping (Error) -> Void) {
        requestObject(apiName: "m.life.ai.agent.role.get-bind-role",
                      version: "1.0",
                      postData: ["devId": devId],
                      success: success,
                      failure: failure)
    }

    /// Initialize the binding between the role and the agent
    ///
    /// API: `m.life.ai.agent.role.initialize-agent-role-binding`
    /// - Parameters:
    ///   - devId: Device ID
    ///   - success: Details of the role bound after initialization
    ///   - failure: Failure callback
    func initializeAgentRoleBinding(devId: String,
                                    success: @escaping (ThingSmartAIAgentRoleDetailResult) -> Void,
                                    failure: @escaping (Error) -> Void) {
        requestObject(apiName: "m.life.ai.agent.role.initialize-agent-role-binding",
                      version: "1.0",
                      postData: ["devId": devId],
                      success: success,
                      failure: failure)
    }

    // MARK: - Agent Role Chat Service

    /// Query AI agent chat history (cursor-based)
    ///
    /// API: `m.life.ai.agent.chat.history.fetch`
    /// - Parameters:
    ///   - req: Request model (gmtStart / gmtEnd must not both be empty)
    ///   - success: Chat history record list
    ///   - failure: Failure callback
    func fetchChatHistory(_ req: ThingSmartAIAgentChatHistoryFetchReq,
                          success: @escaping ([ThingSmartAIAgentChatRecordResult]) -> Void,
                          failure: @escaping (Error) -> Void) {
        var postData: [String: Any] = [:]
        postData["devId"] = req.devId
        postData["bindRoleType"] = req.bindRoleType.rawValue
        postData["roleId"] = req.roleId
        postData["fetchSize"] = req.fetchSize
        postData["gmtStart"] = req.gmtStart
        postData["gmtEnd"] = req.gmtEnd
        postData["timeAsc"] = req.timeAsc
        requestList(apiName: "m.life.ai.agent.chat.history.fetch",
                    version: "1.0",
                    postData: postData,
                    success: success,
                    failure: failure)
    }

    /// Delete the chat history of an AI agent role
    ///
    /// API: `m.life.ai.agent.chat.history.delete`
    /// - Parameters:
    ///   - req: Request model
    ///   - success: Whether the deletion succeeded
    ///   - failure: Failure callback
    func deleteChatHistory(_ req: ThingSmartAIAgentChatHistoryDeleteReq,
                           success: @escaping (Bool) -> Void,
                           failure: @escaping (Error) -> Void) {
        var postData: [String: Any] = [:]
        postData["devId"] = req.devId
        postData["bindRoleType"] = req.bindRoleType.rawValue
        postData["roleId"] = req.roleId
        postData["clearAllHistory"] = req.clearAllHistory
        postData["requestIds"] = req.requestIds
        requestBool(apiName: "m.life.ai.agent.chat.history.delete",
                    version: "1.0",
                    postData: postData,
                    success: success,
                    failure: failure)
    }

    /// Query the AI agent memory switch
    ///
    /// API: `m.life.ai.agent.chat.memory.get-switch`
    /// - Parameters:
    ///   - devId: Device ID
    ///   - success: Memory switch state
    ///   - failure: Failure callback
    func getMemorySwitch(devId: String,
                         success: @escaping (ThingSmartAIAgentMemorySwitchResult) -> Void,
                         failure: @escaping (Error) -> Void) {
        requestObject(apiName: "m.life.ai.agent.chat.memory.get-switch",
                      version: "1.0",
                      postData: ["devId": devId],
                      success: success,
                      failure: failure)
    }

    /// Query the memory list of an AI agent role
    ///
    /// API: `m.life.ai.agent.chat.memory.list`
    /// - Parameters:
    ///   - req: Request model
    ///   - success: Memory list grouped by scope
    ///   - failure: Failure callback
    func queryMemoryList(_ req: ThingSmartAIAgentMemoryListReq,
                         success: @escaping ([ThingSmartAIAgentMemoryGroupResult]) -> Void,
                         failure: @escaping (Error) -> Void) {
        var postData: [String: Any] = [:]
        postData["devId"] = req.devId
        postData["bindRoleType"] = req.bindRoleType.rawValue
        postData["roleId"] = req.roleId
        requestList(apiName: "m.life.ai.agent.chat.memory.list",
                    version: "1.0",
                    postData: postData,
                    success: success,
                    failure: failure)
    }

    /// Delete memories of an AI agent role
    ///
    /// API: `m.life.ai.agent.chat.memory.delete`
    /// - Parameters:
    ///   - req: Request model
    ///   - success: Whether the deletion succeeded
    ///   - failure: Failure callback
    func deleteMemory(_ req: ThingSmartAIAgentMemoryDeleteReq,
                      success: @escaping (Bool) -> Void,
                      failure: @escaping (Error) -> Void) {
        var postData: [String: Any] = [:]
        postData["devId"] = req.devId
        postData["bindRoleType"] = req.bindRoleType.rawValue
        postData["roleId"] = req.roleId
        postData["clearAllMemory"] = req.clearAllMemory
        postData["memoryKeys"] = req.memoryKeys
        requestBool(apiName: "m.life.ai.agent.chat.memory.delete",
                    version: "1.0",
                    postData: postData,
                    success: success,
                    failure: failure)
    }

    /// Query the chat summary of an AI agent role
    ///
    /// API: `m.life.ai.agent.chat.chat-summary.get`
    /// - Parameters:
    ///   - req: Request model
    ///   - success: List of chat summary entries
    ///   - failure: Failure callback
    func getChatSummary(_ req: ThingSmartAIAgentChatSummaryGetReq,
                        success: @escaping ([String]) -> Void,
                        failure: @escaping (Error) -> Void) {
        var postData: [String: Any] = [:]
        postData["devId"] = req.devId
        postData["bindRoleType"] = req.bindRoleType.rawValue
        postData["roleId"] = req.roleId
        send(apiName: "m.life.ai.agent.chat.chat-summary.get", version: "1.0", postData: postData) { result, error in
            if let error = error {
                failure(error)
                return
            }
            success((result as? [String]) ?? [])
        }
    }

    /// Update the chat summary of an AI agent role
    ///
    /// API: `m.life.ai.agent.chat.chat-summary.update`
    /// - Parameters:
    ///   - req: Request model
    ///   - success: Whether the update succeeded
    ///   - failure: Failure callback
    func updateChatSummary(_ req: ThingSmartAIAgentChatSummaryUpdateReq,
                           success: @escaping (Bool) -> Void,
                           failure: @escaping (Error) -> Void) {
        var postData: [String: Any] = [:]
        postData["devId"] = req.devId
        postData["bindRoleType"] = req.bindRoleType.rawValue
        postData["roleId"] = req.roleId
        postData["summaryItems"] = req.summaryItems
        requestBool(apiName: "m.life.ai.agent.chat.chat-summary.update",
                    version: "1.0",
                    postData: postData,
                    success: success,
                    failure: failure)
    }

    /// Clear the chat context of an AI agent role
    ///
    /// API: `m.life.ai.agent.chat.context.clear`
    /// - Parameters:
    ///   - req: Request model
    ///   - success: Whether the clearing succeeded
    ///   - failure: Failure callback
    func clearChatContext(_ req: ThingSmartAIAgentChatContextClearReq,
                          success: @escaping (Bool) -> Void,
                          failure: @escaping (Error) -> Void) {
        var postData: [String: Any] = [:]
        postData["devId"] = req.devId
        postData["bindRoleType"] = req.bindRoleType.rawValue
        postData["roleId"] = req.roleId
        requestBool(apiName: "m.life.ai.agent.chat.context.clear",
                    version: "1.0",
                    postData: postData,
                    success: success,
                    failure: failure)
    }

    /// Get the current chat emotion
    ///
    /// API: `m.life.ai.agent.chat.chat-emotion.current`
    /// - Parameters:
    ///   - devId: Device ID
    ///   - success: Current chat emotion
    ///   - failure: Failure callback
    func getCurrentChatEmotion(devId: String,
                               success: @escaping (ThingSmartAIAgentChatEmotionResult) -> Void,
                               failure: @escaping (Error) -> Void) {
        requestObject(apiName: "m.life.ai.agent.chat.chat-emotion.current",
                      version: "1.0",
                      postData: ["devId": devId],
                      success: success,
                      failure: failure)
    }

    // MARK: - Voice Service

    /// Fetch the standard voice list (paged)
    ///
    /// API: `m.life.ai.timbre.page`
    /// - Parameters:
    ///   - req: Request model
    ///   - success: Paged result of voices (page/pageSize/total/totalPage/list)
    ///   - failure: Failure callback
    func queryTimbrePage(_ req: ThingSmartAITimbrePageReq,
                         success: @escaping (ThingSmartAITimbrePageResult) -> Void,
                         failure: @escaping (Error) -> Void) {
        var postData: [String: Any] = [:]
        postData["devId"] = req.devId
        postData["pageNo"] = req.pageNo
        postData["pageSize"] = req.pageSize
        postData["tag"] = req.tag
        postData["keyWord"] = req.keyWord
        postData["lang"] = req.lang
        postData["preferredVoiceId"] = req.preferredVoiceId
        postData["categoryTagCode"] = req.categoryTagCode
        requestObject(apiName: "m.life.ai.timbre.page",
                      version: "1.0",
                      postData: postData,
                      success: success,
                      failure: failure)
    }

    // MARK: - Private Methods (unified request + result parsing)

    /// result is a JSON object, parsed into a single model; if the request succeeds but
    /// parsing fails, an empty model (all fields nil) is returned in the callback
    private func requestObject<T: Decodable>(apiName: String,
                                             version: String,
                                             postData: [String: Any],
                                             success: @escaping (T) -> Void,
                                             failure: @escaping (Error) -> Void) {
        send(apiName: apiName, version: version, postData: postData) { result, error in
            if let error = error {
                failure(error)
                return
            }
            var model: T?
            if let result = result, JSONSerialization.isValidJSONObject(result),
               let data = try? JSONSerialization.data(withJSONObject: result) {
                model = try? JSONDecoder().decode(T.self, from: data)
            }
            if model == nil {
                // All result model fields are optional, so empty JSON always decodes into an empty model
                model = try? JSONDecoder().decode(T.self, from: Data("{}".utf8))
            }
            if let model = model {
                success(model)
            }
        }
    }

    /// result is a JSON array, parsed into a model array; if the request succeeds but
    /// parsing fails, an empty array is returned in the callback
    private func requestList<T: Decodable>(apiName: String,
                                           version: String,
                                           postData: [String: Any],
                                           success: @escaping ([T]) -> Void,
                                           failure: @escaping (Error) -> Void) {
        send(apiName: apiName, version: version, postData: postData) { result, error in
            if let error = error {
                failure(error)
                return
            }
            var list: [T] = []
            if let result = result, JSONSerialization.isValidJSONObject(result),
               let data = try? JSONSerialization.data(withJSONObject: result) {
                list = (try? JSONDecoder().decode([T].self, from: data)) ?? []
            }
            success(list)
        }
    }

    /// result is a Bool
    private func requestBool(apiName: String,
                             version: String,
                             postData: [String: Any],
                             success: @escaping (Bool) -> Void,
                             failure: @escaping (Error) -> Void) {
        send(apiName: apiName, version: version, postData: postData) { result, error in
            if let error = error {
                failure(error)
                return
            }
            success((result as? Bool) ?? false)
        }
    }

    /// result is a String
    private func requestString(apiName: String,
                               version: String,
                               postData: [String: Any],
                               success: @escaping (String) -> Void,
                               failure: @escaping (Error) -> Void) {
        send(apiName: apiName, version: version, postData: postData) { result, error in
            if let error = error {
                failure(error)
                return
            }
            success((result as? String) ?? "")
        }
    }

    /// Unified exit point: sends the request via `requestWithApiName:postData:version:success:failure:`
    /// and normalizes the SDK callback into (result, error)
    private func send(apiName: String,
                      version: String,
                      postData: [String: Any],
                      completion: @escaping (Any?, Error?) -> Void) {
        request(withApiName: apiName, postData: postData, version: version, success: { result in
            let object: Any? = result
            completion(object, nil)
        }, failure: { error in
            let err: Error? = error
            completion(nil, err ?? NSError(domain: "com.thing.demo", code: -1))
        })
    }
}
