//
//  CameraLocalPathUtil.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class CameraLocalPathUtil {
    private let dateFormatter = DateFormatter()
    private var innerPlaybackLocalPath: String?

    static let shared = CameraLocalPathUtil()

    private init() {
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US")
        setupPlaybackLocalPath()
    }
    
    /**
     生成一个随机本地地址
     */
    func generateRandomLocalPath() -> String {
        let filePrefix = filePrefix(With: Date()).appending(".mp4")
        return innerPlaybackLocalPath?.appending(filePrefix) ?? ""
    }
    
    private func setupPlaybackLocalPath() {
        let directories = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        guard let path = directories.first?.appending("playback") else { return }

        innerPlaybackLocalPath = path

        var isDirectory: ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)

        if isExist && !isDirectory.boolValue {
            try? FileManager.default.removeItem(atPath: path)
            try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false)
        } else if !isExist {
            try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false)
        }
    }

    private func filePrefix(With date: Date) -> String {
        dateFormatter.dateFormat = "yyyy_MM_dd_HH_mm_ss_S"
        let dateString = dateFormatter.string(from: date)
        return "\(dateString)_\(randomString(withLength: 6))"
    }

    private func randomString(withLength length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let random = (0..<length).compactMap { _ in
            letters.randomElement()
        }
        return String(random)
    }
}
