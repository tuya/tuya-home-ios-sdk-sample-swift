//
//  ThingSmartAIAgentRequestModel.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2026 Tuya Inc. (https://developer.tuya.com/)

import Foundation

/// Bound role type
enum ThingSmartAIAgentBindRoleType: Int {
    /// Custom agent role
    case customRole = 0
    /// Agent role template
    case roleTemplate = 1
    /// Default role in single-role scenario
    case singleSceneDefaultRole = 2
}

// MARK: - Request Models (Req)
//
// Each API has a dedicated Req model: required parameters are non-optional `let`
// (must be provided at initialization), optional parameters are optional `var`
// (omit at initialization or assign as needed).
// APIs that take only a devId have no model; the parameter is passed directly.

/// Request for creating a custom role (m.life.ai.agent.role.custom-role.add)
struct ThingSmartAIAgentCustomRoleAddReq {
    /// Device ID
    let devId: String
    /// Role name
    let roleName: String
    /// Role introduction
    let roleIntroduce: String
    /// Role image
    let roleImgUrl: String
    /// Language code used by the role
    let useLangCode: String
    /// Role description (optional)
    var roleDesc: String?
    /// Voice used by the role (optional)
    var useTimbreId: String?
    /// Speech speed used by the role (optional)
    var speed: String?
}

/// Request for querying the custom role list with pagination (m.life.ai.agent.role.custom-role.page)
struct ThingSmartAIAgentCustomRolePageReq {
    /// Device ID
    let devId: String
    /// Page number (starting from 1)
    let pageNo: Int
    /// Page size
    let pageSize: Int
    /// Role category (optional)
    var roleCategory: String?
}

/// Request for querying custom role details (m.life.ai.agent.role.custom-role.detail)
struct ThingSmartAIAgentCustomRoleDetailReq {
    /// Device ID
    let devId: String
    /// Role ID
    let roleId: String
}

/// Request for updating a custom role (m.life.ai.agent.role.custom-role.update)
///
/// Omitted optional fields are left unchanged.
struct ThingSmartAIAgentCustomRoleUpdateReq {
    /// Device ID
    let devId: String
    /// Role ID
    let roleId: String
    /// Role name (optional)
    var roleName: String?
    /// Role description (optional)
    var roleDesc: String?
    /// Role introduction (optional)
    var roleIntroduce: String?
    /// Role image (optional)
    var roleImgUrl: String?
    /// Language code used by the role (optional)
    var useLangCode: String?
    /// Voice used by the role (optional)
    var useTimbreId: String?
    /// Speech speed used by the role (optional)
    var speed: String?
    /// Whether to bind to the device after saving (optional)
    var needBind: Bool?
}

/// Request for deleting a custom role (m.life.ai.agent.role.custom-role.delete)
struct ThingSmartAIAgentCustomRoleDeleteReq {
    /// Device ID
    let devId: String
    /// Role ID
    let roleId: String
}

/// Request for querying the role template list (m.life.ai.agent.role.role-template.list)
struct ThingSmartAIAgentRoleTemplateListReq {
    /// Device ID
    let devId: String
    /// Tag (optional)
    var tagCode: String?
}

/// Request for querying role template details (m.life.ai.agent.role.role-template.detail)
struct ThingSmartAIAgentRoleTemplateDetailReq {
    /// Device ID
    let devId: String
    /// Role ID
    let roleId: String
}

/// Request for binding the agent to a role (m.life.ai.agent.role.bind-with-role)
struct ThingSmartAIAgentRoleBindReq {
    /// Device ID
    let devId: String
    /// Bound role type
    let bindRoleType: ThingSmartAIAgentBindRoleType
    /// Role ID
    let roleId: String
}

/// Request for querying chat history (m.life.ai.agent.chat.history.fetch)
///
/// Cursor-based pagination: gmtStart / gmtEnd must not both be empty.
struct ThingSmartAIAgentChatHistoryFetchReq {
    /// Device ID
    let devId: String
    /// Bound role type
    let bindRoleType: ThingSmartAIAgentBindRoleType
    /// Role ID
    let roleId: String
    /// Number of records to fetch
    let fetchSize: Int
    /// Start timestamp, 13-digit milliseconds (must not be empty together with gmtEnd)
    var gmtStart: Int64?
    /// End timestamp, 13-digit milliseconds (must not be empty together with gmtStart)
    var gmtEnd: Int64?
    /// Whether to sort by time ascending; defaults to descending (optional)
    var timeAsc: Bool?
}

/// Request for deleting chat history (m.life.ai.agent.chat.history.delete)
struct ThingSmartAIAgentChatHistoryDeleteReq {
    /// Device ID
    let devId: String
    /// Bound role type
    let bindRoleType: ThingSmartAIAgentBindRoleType
    /// Role ID
    let roleId: String
    /// Whether to clear all chat history
    let clearAllHistory: Bool
    /// requestIds of the records to delete, comma-separated (used when clearAllHistory is false)
    var requestIds: String?
}

/// Request for querying the memory list (m.life.ai.agent.chat.memory.list)
struct ThingSmartAIAgentMemoryListReq {
    /// Device ID
    let devId: String
    /// Bound role type
    let bindRoleType: ThingSmartAIAgentBindRoleType
    /// Role ID
    let roleId: String
}

/// Request for deleting memories (m.life.ai.agent.chat.memory.delete)
struct ThingSmartAIAgentMemoryDeleteReq {
    /// Device ID
    let devId: String
    /// Bound role type
    let bindRoleType: ThingSmartAIAgentBindRoleType
    /// Role ID
    let roleId: String
    /// Whether to clear all memories
    let clearAllMemory: Bool
    /// memoryKeys of the memories to delete, comma-separated (used when clearAllMemory is false)
    var memoryKeys: String?
}

/// Request for querying the chat summary (m.life.ai.agent.chat.chat-summary.get)
struct ThingSmartAIAgentChatSummaryGetReq {
    /// Device ID
    let devId: String
    /// Bound role type
    let bindRoleType: ThingSmartAIAgentBindRoleType
    /// Role ID
    let roleId: String
}

/// Request for updating the chat summary (m.life.ai.agent.chat.chat-summary.update)
struct ThingSmartAIAgentChatSummaryUpdateReq {
    /// Device ID
    let devId: String
    /// Bound role type
    let bindRoleType: ThingSmartAIAgentBindRoleType
    /// Role ID
    let roleId: String
    /// Chat summary content; multiple entries separated by \n\n, replaces the whole summary
    let summaryItems: String
}

/// Request for clearing the chat context (m.life.ai.agent.chat.context.clear)
struct ThingSmartAIAgentChatContextClearReq {
    /// Device ID
    let devId: String
    /// Bound role type
    let bindRoleType: ThingSmartAIAgentBindRoleType
    /// Role ID
    let roleId: String
}

/// Request for the standard voice list with pagination (m.life.ai.timbre.page)
struct ThingSmartAITimbrePageReq {
    /// Device ID
    let devId: String
    /// Page number (starting from 1)
    let pageNo: Int
    /// Page size
    let pageSize: Int
    /// Voice tag (optional)
    var tag: String?
    /// Keyword search (optional)
    var keyWord: String?
    /// Supported language (optional)
    var lang: String?
    /// Voice ID to show first (optional)
    var preferredVoiceId: String?
    /// Voice category tag code (optional)
    var categoryTagCode: String?
}

// MARK: - Result Models (Agent Configuration Service)

/// Avatar info
struct ThingSmartAIAgentAvatarResult: Decodable {
    /// Avatar ID
    let avatarId: String?
    /// Avatar URL
    let url: String?
}

/// Language info
struct ThingSmartAIAgentLanguageResult: Decodable {
    /// Language code
    let langCode: String?
    /// Language name
    let langName: String?
    /// Whether it is the default language
    let hasDefault: Bool?
}

// MARK: - Result Models (Agent Role Service)

/// Custom role list item
struct ThingSmartAIAgentCustomRoleResult: Decodable {
    /// Role ID
    let roleId: String?
    /// Role name
    let roleName: String?
    /// Role description
    let roleDesc: String?
    /// Role introduction
    let roleIntroduce: String?
    /// Role image
    let roleImgUrl: String?
    /// Language code used by the role
    let useLangCode: String?
    /// Language name used by the role
    let useLangName: String?
    /// Voice used by the role
    let useTimbreId: String?
    /// Name of the voice used by the role
    let useTimbreName: String?
    /// Template ID
    let templateId: String?
    /// Latest reply text
    let lastTextAnswer: String?
}

/// Paged result of custom roles
struct ThingSmartAIAgentCustomRolePageResult: Decodable {
    /// Total count
    let total: Int?
    /// Total pages
    let totalPage: Int?
    /// Custom role list
    let list: [ThingSmartAIAgentCustomRoleResult]?
}

/// Role details
///
/// Custom role details / role template details / the role bound to the agent
/// return the same fields, so they share this model.
struct ThingSmartAIAgentRoleDetailResult: Decodable {
    /// Role ID
    let roleId: String?
    /// Role name
    let roleName: String?
    /// Role description
    let roleDesc: String?
    /// Role introduction
    let roleIntroduce: String?
    /// Role image
    let roleImgUrl: String?
    /// Language code used by the role
    let useLangCode: String?
    /// Language name used by the role
    let useLangName: String?
    /// Voice used by the role
    let useTimbreId: String?
    /// Whether it is a custom voice clone
    let isUserCloneTimbre: Bool?
    /// Name of the voice used by the role
    let useTimbreName: String?
    /// Voice languages supported by the role, comma-separated
    let useTimbreSupportLangs: String?
    /// Role tags
    let useTimbreTags: [String]?
    /// Voice speed
    let speed: Double?
    /// Voice tone
    let tone: Double?
    /// Template ID
    let templateId: String?
    /// Bound role type (0 - custom agent role, 1 - agent role template, 2 - default role in single-role scenario)
    let bindRoleType: Int?
    /// Latest reply text
    let lastTextAnswer: String?
}

/// Role template list item
struct ThingSmartAIAgentRoleTemplateResult: Decodable {
    /// Role template ID
    let templateId: String?
    /// Role ID
    let roleId: String?
    /// Role code
    let roleCode: String?
    /// Role name
    let roleName: String?
    /// Role introduction
    let roleDesc: String?
    /// Role icon
    let roleImgUrl: String?
    /// Role traits
    let roleIntroduce: String?
    /// Language code used by the role
    let useLangCode: String?
    /// Language name used by the role
    let useLangName: String?
    /// Voice used by the role
    let useTimbreId: String?
    /// Name of the voice used by the role
    let useTimbreName: String?
    /// Voice languages supported by the role, comma-separated
    let useTimbreSupportLangs: String?
    /// Names of the voice languages supported by the role, comma-separated
    let useTimbreSupportLangNames: String?
    /// Default flag (1 means default)
    let defaultFlag: Int?
    /// Latest reply text
    let lastTextAnswer: String?
}

// MARK: - Result Models (Agent Role Chat Service)

/// Chat message content
struct ThingSmartAIAgentChatMessageResult: Decodable {
    /// Message content
    let context: String?
    /// Type
    let type: String?
}

/// Chat history record
struct ThingSmartAIAgentChatRecordResult: Decodable {
    /// Chat time
    let createTime: String?
    /// Request ID
    let requestId: String?
    /// Question
    let question: [ThingSmartAIAgentChatMessageResult]?
    /// Answer
    let answer: [ThingSmartAIAgentChatMessageResult]?
    /// Creation timestamp
    let gmtCreate: Int64?
}

/// Memory switch state
struct ThingSmartAIAgentMemorySwitchResult: Decodable {
    /// Summary switch
    let summaryOpen: Bool?
    /// Memory switch
    let memoryOpen: Bool?
}

/// Memory entry
struct ThingSmartAIAgentMemoryResult: Decodable {
    /// Memory key
    let memoryKey: String?
    /// Memory value
    let memoryValue: String?
    /// Memory name
    let memoryName: String?
    /// Memory scope
    let effectiveScope: Int?
    /// Memory scope name
    let effectiveScopeName: String?
    /// Whether the memory is shared
    let shareMemory: Bool?
}

/// Memory group (by scope)
struct ThingSmartAIAgentMemoryGroupResult: Decodable {
    /// Memory scope
    let effectiveScope: Int?
    /// Memory scope name
    let effectiveScopeName: String?
    /// Memory list
    let memoryList: [ThingSmartAIAgentMemoryResult]?
}

/// Current chat emotion
struct ThingSmartAIAgentChatEmotionResult: Decodable {
    /// Whether emotion is enabled
    let emotionOpen: Bool?
    /// Emotion
    let emotion: String?
    /// Text
    let text: String?
    /// Image URL
    let url: String?
    /// Creation time
    let gmtCreate: Int64?
    /// Modification time
    let gmtModified: Int64?
}

// MARK: - Result Models (Voice Service)

/// Voice info
struct ThingSmartAITimbreResult: Decodable {
    /// Voice identifier
    let voiceId: String?
    /// Voice name
    let voiceName: String?
    /// Description tag list
    let descTags: [String]?
    /// Supported language list
    let supportLangs: [String]?
    /// Voice speed
    let speed: Double?
    /// Voice tone
    let tone: Double?
    /// Demo audio URL
    let demoUrl: String?
}

/// Paged result of voices
struct ThingSmartAITimbrePageResult: Decodable {
    /// Current page number
    let page: Int?
    /// Page size
    let pageSize: Int?
    /// Total count
    let total: Int?
    /// Total pages
    let totalPage: Int?
    /// Voice list
    let list: [ThingSmartAITimbreResult]?
}
