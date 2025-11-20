//
//  DemoSplitVideoInfoProcesser.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import ThingSmartCameraM

class DemoSplitVideoInfoProcesser: AnyObject {
    private init() {}

    static func processVideoSplitInfo(
        with advancedConfig: ThingSmartCameraBase.ThingSmartCameraAdvancedConfig?
    ) -> [[DemoSplitVideoInfo]] {
        guard let innerAdvancedConfig = advancedConfig as? ThingSmartCameraM.ThingSmartCameraAdvancedConfig else {
            return []
        }

        var videoInfos = [[DemoSplitVideoInfo]]()

        let split_video_sum_info = innerAdvancedConfig.split_video_sum_info
        let align_group = split_video_sum_info.align_info.align_group
        let localizer_group = split_video_sum_info.align_info.localizer_group
        let split_info = split_video_sum_info.split_info

        align_group.forEach { videoIndexes in
            var subVideoInfos = [DemoSplitVideoInfo]()
            videoIndexes.forEach { videoIndex in
                let video_info = queryVideoInfo(from: split_info, atIndex: videoIndex)
                if let video_info {
                    let isLocalizer = localizer_group.contains(videoIndex)
                    let isFirstIndex = split_info.first == video_info
                    let videoInfo = DemoSplitVideoInfo(
                        video_info: video_info,
                        isLocalizer: isLocalizer,
                        isFirstIndex: isFirstIndex
                    )
                    subVideoInfos.append(videoInfo)
                }
            }
            if !subVideoInfos.isEmpty {
                videoInfos.append(subVideoInfos)
            }
        }
        return videoInfos
    }

    private static func queryVideoInfo (
        from originalInfos: [thing_ipc_split_video_info]?,
        atIndex: thing_ipc_split_video_index
    )  -> thing_ipc_split_video_info? {
        originalInfos?.first(where: { $0.index == atIndex.intValue })
    }
}
