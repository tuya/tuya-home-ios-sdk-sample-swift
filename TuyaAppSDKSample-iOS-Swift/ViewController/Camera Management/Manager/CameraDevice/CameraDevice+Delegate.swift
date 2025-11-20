//
//  CameraDevice+Delegate.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

extension CameraDevice: ThingSmartCameraDelegate {
    /// [en] - the p2p channel did connected.
    ///
    /// [zh] p2p 通道已连接
    /// - Parameter : camera:  Camera
    func cameraDidConnected(_ camera: (any ThingSmartCameraType)!) {
        self.camera.enterPlayback()
        let features = deviceModel.cameraDeviceFeatures()
        if let features {
            _ = camera.setDeviceFeatures?(features)
        }
        modifyCameraModel { $0.connectState = .connected }
        allInnerDelegates().forEach { delegate in
            delegate.cameraDidConnected?(camera)
        }
    }

    /**
     新 P2P 通道已断开 (The new P2P channel did disconnect)
     - Parameters:
       - camera: 摄像头实例 (The camera instance)
       - errorCode:
         - [EN] Error code reference: `ThingCameraSDK.framework/TYDefines`
         - [ZH] 具体参考: `ThingCameraSDK.framework/TYDefines`
     */
    func cameraDisconnected(_ camera: (any ThingSmartCameraType)!, specificErrorCode errorCode: Int) {
        let isBusy = errorCode == -23 || errorCode == -104 || errorCode == -113
        modifyCameraModel {
            $0.connectState = isBusy ? .busy : .disconnected
            $0.previewState = .idle
            $0.playbackState = .idle
            $0.videoTalkState = .idle
            $0.isVideoTalkPaused = false
            $0.isPlaybackPaused = false
            $0.isDownloading = false
            $0.isTalking = $0.isTalkLoading == false
        }
        allInnerDelegates().forEach { delegate in
            delegate.cameraDisconnected?(camera, specificErrorCode: errorCode)
        }
    }

    /**
     回放通道已连接 (The playback channel did connect)

     - Parameter camera: 摄像头实例 (The camera instance)
     */
    func cameraDidConnectPlaybackChannel(_ camera: (any ThingSmartCameraType)!) {
        allInnerDelegates().forEach { delegate in
            delegate.cameraDidConnectPlaybackChannel?(camera)
        }
    }

    /**
     摄像头已经开始播放实时视频 (The camera did began play live video.)

     - Parameter camera: 摄像头实例 (The camera instance)
     */
    func cameraDidBeginPreview(_ camera: (any ThingSmartCameraType)!) {
        modifyCameraModel { $0.previewState = .previewing }
        allInnerDelegates().forEach { delegate in
            delegate.cameraDidBeginPreview?(camera)
        }
    }

    /**
     摄像头实时视频已停止 (The camera did stop live video.)

     - Parameter camera: 摄像头实例 (The camera instance)
     */
    func cameraDidStopPreview(_ camera: (any ThingSmartCameraType)!) {
        modifyCameraModel { $0.previewState = .idle }
        allInnerDelegates().forEach { delegate in
            delegate.cameraDidStopPreview?(camera)
        }
    }

    /**
     摄像头SD卡视频回放已开始 (The camera did began playback record video in the SD card.)

     - Parameter camera: 摄像头实例 (The camera instance)
     */
    func cameraDidBeginPlayback(_ camera: (any ThingSmartCameraType)!) {
        modifyCameraModel {
            $0.playbackState = .playbacking
            $0.isPlaybackPaused = false
        }
        allInnerDelegates().forEach { delegate in
            delegate.cameraDidBeginPlayback?(camera)
        }
    }

    /**
     摄像头SD卡视频回放已暂停 (The camera did pause playback record video in the SD card.)

     - Parameter camera: 摄像头实例 (The camera instance)
     */
    func cameraDidPausePlayback(_ camera: (any ThingSmartCameraType)!) {
        modifyCameraModel { $0.isPlaybackPaused = true }
        allInnerDelegates().forEach { delegate in
            delegate.cameraDidPausePlayback?(camera)
        }
    }

    /**
     摄像头SD卡视频回放已恢复播放 (The camera did resume playback record video in the SD card.)

     - Parameter camera: 摄像头实例 (The camera instance)
     */
    func cameraDidResumePlayback(_ camera: (any ThingSmartCameraType)!) {
        modifyCameraModel { $0.isPlaybackPaused = false }
        allInnerDelegates().forEach { delegate in
            delegate.cameraDidResumePlayback?(camera)
        }
    }

    /**
     摄像头SD卡视频回放已中止 (The camera did stop playback record video in the SD card.)

     - Parameter camera: 摄像头实例 (The camera instance)
     */
    func cameraDidStopPlayback(_ camera: (any ThingSmartCameraType)!) {
        modifyCameraModel {
            $0.playbackState = .idle
            $0.isPlaybackPaused = false
        }
        allInnerDelegates().forEach { delegate in
            delegate.cameraDidStopPlayback?(camera)
        }
    }

    /**
     摄像头SD卡视频回放已结束 (The record video in the SD card playback finished.)

     - Parameter camera: 摄像头实例 (The camera instance)
     */
    func cameraPlaybackDidFinished(_ camera: (any ThingSmartCameraType)!) {
        modifyCameraModel {
            $0.playbackState = .idle
            $0.isPlaybackPaused = false
        }
        allInnerDelegates().forEach { delegate in
            delegate.cameraPlaybackDidFinished?(camera)
        }
    }

    /**
     摄像头SD卡视频回放结束时状态 (The record video in the SD card playback finished.)

     - Parameter camera: 摄像头实例 (The camera instance)
     - Parameter status: 结束状态 (The camera finish status)
     */
    func camera(_ camera: (any ThingSmartCameraType)!, playbackDidFinishedWithStatus status: Int) {
        allInnerDelegates().forEach { delegate in
            delegate.camera?(camera, playbackDidFinishedWithStatus: status)
        }
    }

    func camera(
        _ camera: (any ThingSmartCameraType)!,
        playbackTimeSlice timeSlice: [AnyHashable : Any]!,
        didFinishedWithStatus status: Int
    ) {
        modifyCameraModel { $0.playbackState = .idle }
        // 自动播放下一段时，可能重复收到播放结束的回调，如果已经开始加载下一段，将 playbackloading 设置为 NO 会导致状态错误
        // self.cameraModel.playbackLoading = NO;
        modifyCameraModel { $0.isPlaybackPaused = false }
        allInnerDelegates().forEach { delegate in
            delegate.camera?(camera, playbackTimeSlice: timeSlice, didFinishedWithStatus: status)
        }
    }

    /**
     收到的第一帧视频。此方法将会在每一次 'startPreview/startPlayback/resumePlayback' 成功时被调用 ( Receive first video frame.
    Tthis method will call when every 'startPreview/startPlayback/resumePlayback' sucess.)

     - Parameter camera: 摄像头实例 (The camera instance)
     - Parameter image: 第一帧图片 (Fisrt frame images)
     */
    func camera(_ camera: (any ThingSmartCameraType)!, didReceiveFirstFrame image: UIImage!) {
        if cameraModel.previewState == .loading {
            modifyCameraModel { $0.previewState = .previewing }
        } else if cameraModel.playbackState == .loading {
            modifyCameraModel { $0.playbackState = .playbacking }
        }
        allInnerDelegates().forEach { delegate in
            delegate.camera?(camera, didReceiveFirstFrame: image)
        }
    }

    /**
     开始与设备进行对讲，方法会在 'startTalk' 成时被调用 (Begin talk to the device. will call when 'startTalk' success.)

     - Parameter camera: 摄像头实例 (The camera instance)
     */
    func cameraDidBeginTalk(_ camera: (any ThingSmartCameraType)!) {
        modifyCameraModel {
            $0.isTalking = true
            $0.isTalkLoading = false
        }
        allInnerDelegates().forEach { delegate in
            delegate.cameraDidBeginTalk?(camera)
        }
    }

    /**
     与设备对讲已经结束，方法会在 'stopTalk' 成功时被调用 (Talk to the device did stop. will call when 'stopTalk' success.)

     - Parameter camera: 摄像头实例 (The camera instance)
     */
    func cameraDidStopTalk(_ camera: (any ThingSmartCameraType)!) {
        modifyCameraModel {
            $0.isTalkLoading = false
            $0.isTalking = false
        }
        allInnerDelegates().forEach { delegate in
            delegate.cameraDidStopTalk?(camera)
        }
    }

    /**
     视频截图已成功保存到相册 (The video screenshot has saved in the photo album.)

     - Parameter camera: 摄像头实例 (The camera instance)
     */
    func cameraSnapShootSuccess(_ camera: (any ThingSmartCameraType)!) {
        allInnerDelegates().forEach { delegate in
            delegate.cameraSnapShootSuccess?(camera)
        }
    }

    /**
     视频录制已成功开始 (Video recording did start success.)

     - Parameter camera: 摄像头实例 (The camera instance)
     */
    func cameraDidStartRecord(_ camera: (any ThingSmartCameraType)!) {
        modifyCameraModel {
            $0.isRecording = true
            $0.isRecordLoading = false
        }
        allInnerDelegates().forEach { delegate in
            delegate.cameraDidStartRecord?(camera)
        }
    }

    /**
     视频录制已经成功停止，视频已成功保存到相册 (Video recording did stop sucess, and the video has saved in photo album success.)

     - Parameter camera: 摄像头实例 (The camera instance)
     */
    func cameraDidStopRecord(_ camera: (any ThingSmartCameraType)!) {
        modifyCameraModel {
            $0.isRecording = false
            $0.isRecordLoading = false
        }
        allInnerDelegates().forEach { delegate in
            delegate.cameraDidStopRecord?(camera)
        }
    }

    /**
     收到视频清晰度状态，方法会在 'getHD' 成功 或者清晰度改变的时候被调用 (Did receive definition state. will call when 'getHD' success or the definition has changed.)

     - Parameter camera: 摄像头实例 (The camera instance)
     - Parameter definition: 清晰度 (definition)
     */
    func camera(_ camera: (any ThingSmartCameraType)!, definitionChanged definition: ThingSmartCameraDefinition) {
        modifyCameraModel {
            $0.isHD = definition.rawValue >= ThingSmartCameraDefinition.high.rawValue
        }
        allInnerDelegates().forEach { delegate in
            delegate.camera?(camera, definitionChanged: definition)
        }
    }

    /**
     方法会在请求回放事件筛选列表成功后调用 (Called when query data of the playback event list sift success.)

     - Parameter camera: 摄像头实例 (The camera instance)
     - Parameter titles: 标题的数组， ex: ["有人留言", "有人呼叫"] (The array of title，ex: ["Message left", "Call"])
     - Parameter eventIds: 事件id的数组， ex: [1, 2] (The array of eventIds，ex: [1, 2])
     */
    func camera(_ camera: (any ThingSmartCameraType)!, didReceiveEventListSiftData titles: [String]!, eventIds: [NSNumber]!) {
        allInnerDelegates().forEach { delegate in
            delegate.camera?(camera, didReceiveEventListSiftData: titles, eventIds: eventIds)
        }
    }

    /**
     方法会在按日期查询回放视频数据成功后被调用 (Called when query date of the playback record success.)

     - Parameter camera: 摄像头实例 (The camera instance)
     - Parameter days: 日期的数组， ex: [1, 2, 5, 6, 31] 代表这个月中的 1，2，5，6，31 号有视频录制数据 (the array of days，ex: [1, 2, 5, 6, 31] express in this month, 1，2，5，6，31  has video record.)
     */
    func camera(_ camera: (any ThingSmartCameraType)!, didReceiveRecordDayQueryData days: [NSNumber]!) {
        allInnerDelegates().forEach { delegate in
            delegate.camera?(camera, didReceiveRecordDayQueryData: days)
        }
    }

    /**
     方法将会在查询一天内视频回放片段数据成功后被调用 (Called when query video record slice of one day success.)

     - Parameter camera: camera
     - Parameter timeSlices: [^en]the array of playback video record information. the element is a NSDictionary, content like this:
       kThingSmartPlaybackPeriodStartDate  ： startTime(NSDate)
       kThingSmartPlaybackPeriodStopDate   ： stopTime(NSDate)
       kThingSmartPlaybackPeriodStartTime  ： startTime(NSNumer, unix timestamp)
       kThingSmartPlaybackPeriodStopTime   ： stopTime(NSNumer, unix timestamp)[^en]
       [^zh]回放视频数据信息数组，数组内元素为NSDictionary类型，如下:
       kThingSmartPlaybackPeriodStartDate  ： startTime(NSDate)
       kThingSmartPlaybackPeriodStopDate   ： stopTime(NSDate)
       kThingSmartPlaybackPeriodStartTime  ： startTime(NSNumer, unix timestamp)
       kThingSmartPlaybackPeriodStopTime   ： stopTime(NSNumer, unix timestamp)[$zh]
     */
    func camera(_ camera: (any ThingSmartCameraType)!, didReceiveTimeSliceQueryData timeSlices: [[AnyHashable : Any]]!) {
        allInnerDelegates().forEach { delegate in
            delegate.camera?(camera, didReceiveTimeSliceQueryData: timeSlices)
        }
    }

    /**
     收到静音状态，方法会在 'enableMute:' 成功之后被调用，默认为 YES (Did receive mute state. will call when 'enableMute:' success. default is YES.)

     - Parameter camera: 摄像头实例 (The camera instance)
     - Parameter days: 是否为静音 (is muted)
     */
    func camera(_ camera: (any ThingSmartCameraType)!, didReceiveMuteState isMute: Bool, playMode: ThingSmartCameraPlayMode) {
        modifyCameraModel { $0.isMuteLoading = false }
        if playMode == .preview {
            modifyCameraModel { $0.mutedForPreview = isMute }
        } else if playMode == .playback {
            modifyCameraModel { $0.mutedForPlayback = isMute }
        }
        allInnerDelegates().forEach { delegate in
            delegate.camera?(camera, didReceiveMuteState: isMute, playMode: playMode)
        }
    }

    /**
     camera 控制出现了一个错误，附带错误码 (The control of camera has occurred an error with specific reason code.)

     - Parameter camera: 摄像头实例 (The camera instance)
     - Parameter errStepCode: 具体参考 ThingCameraErrorCode (reference the ThingCameraErrorCode)
     - Parameter errorCode: 具体参考ThingCameraSDK.framework/TYDefines (errorCode reference ThingCameraSDK.framework/TYDefines)
     */
    func camera(
        _ camera: (any ThingSmartCameraType)!,
        didOccurredErrorAtStep errStepCode: ThingCameraErrorCode,
        specificErrorCode errorCode: Int
    ) {
        switch errStepCode {
            case Thing_ERROR_CONNECT_FAILED, Thing_ERROR_CONNECT_DISCONNECT:
                modifyCameraModel {
                    $0.connectState = [-23, -104, -113].contains(errorCode) ? .busy : .failed
                }
            case Thing_ERROR_START_PREVIEW_FAILED:
                camera.stopPreview()
                modifyCameraModel { $0.previewState = .failed }
            case Thing_ERROR_START_PLAYBACK_FAILED:
                stopPlayback()
                modifyCameraModel { $0.playbackState = .failed }
            case Thing_ERROR_START_TALK_FAILED:
                modifyCameraModel {
                    $0.isTalkLoading = false
                    $0.isTalking = false
                }
            case Thing_ERROR_RECORD_FAILED:
                modifyCameraModel {
                    $0.isRecordLoading = false
                    $0.isRecording = false
                }
            case Thing_ERROR_ENABLE_MUTE_FAILED:
                modifyCameraModel { $0.isMuteLoading = false }
            case Thing_ERROR_QUERY_TIMESLICE_FAILED, Thing_ERROR_QUERY_RECORD_DAY_FAILED, Thing_ERROR_QUERY_EVENTLIST_SIFT_FAILED:
                modifyCameraModel { $0.playbackState = .failed }
            case Thing_ERROR_ENABLE_HD_FAILED:
                break
            case Thing_ERROR_PAUSE_PLAYBACK_FAILED, Thing_ERROR_RESUME_PLAYBACK_FAILED:
                break
            case Thing_ERROR_SNAPSHOOT_FAILED:
                break
            default:
                break
            }
        allInnerDelegates().forEach { delegate in
            delegate.camera?(camera, didOccurredErrorAtStep: errStepCode, specificErrorCode: errorCode)
        }
    }

    /**
     视频清晰度已经修改 (The definition of the video did chagned.)

     - Parameter camera: 摄像头实例 (The camera instance)
     - Parameter width: video width
     - Parameter height: video height
     */
    func camera(_ camera: (any ThingSmartCameraType)!, resolutionDidChangeWidth width: Int, height: Int) {
        allInnerDelegates().forEach { delegate in
            delegate.camera?(camera, resolutionDidChangeWidth: width, height: height)
        }
    }

    func camera(
        _ camera: (any ThingSmartCameraType)!,
        resolutionDidChangeWith videoExtInfo: (any ThingSmartVideoExtInfo)!
    ) {
        if videoExtInfo.videoIndex == -1 {
            allInnerDelegates().forEach { delegate in
                delegate.camera?(
                    camera,
                    resolutionDidChangeWidth: Int(videoExtInfo.frameSize.width),
                    height: Int(videoExtInfo.frameSize.height)
                )
            }
            return
        }
        allInnerDelegates().forEach { delegate in
            delegate.camera?(camera, resolutionDidChangeWith: videoExtInfo)
        }
    }

    /**
     如果 'isRecvFrame' 是true，并且 'p2pType' 是 1， 视频数据将不会在SDK中解码，通过此方法可以获取到原始视频帧数据 (If 'isRecvFrame' is true, and p2pType is "1", the video data will not decode in the SDK, and could get the orginal video frame data through this method.)

     - Parameter camera: 摄像头实例 (The camera instance)
     - Parameter frameData: 原始视频帧数据 (original video frame data)
     - Parameter size: 视频帧数尺寸 (video frame data size)
     - Parameter frameInfo: 视频帧头信息 (frame header info)
     */
    func camera(
        _ camera: (any ThingSmartCameraType)!,
        thing_didReceiveFrameData frameData: UnsafePointer<CChar>!,
        dataSize size: UInt32,
        frameInfo: ThingSmartVideoStreamInfo
    ) {
        allInnerDelegates().forEach { delegate in
            delegate.camera?(camera, thing_didReceiveFrameData: frameData, dataSize: size, frameInfo: frameInfo)
        }
    }

    /**
     如果 'isRecvFrame' 为true，并且 'p2pType' 大于 2，可以通过此方法j获得解码后的 YUV 帧数据 (If 'isRecvFrame' is true, and p2pType is greater than 2, could get the decoded YUV frame data through this method.)

     - Parameter camera: 摄像头实例 (The camera instance)
     - Parameter wisampleBufferdth: YUV 视频帧数据 (video frame YUV data)
     - Parameter frameInfo: 数据帧头信息 (frame header info)
     */
    func camera(_ camera: (any ThingSmartCameraType)!, thing_didReceiveVideoFrame sampleBuffer: CMSampleBuffer!, frameInfo: ThingSmartVideoFrameInfo) {
        allInnerDelegates().forEach { delegate in
            delegate.camera?(camera, thing_didReceiveVideoFrame: sampleBuffer, frameInfo: frameInfo)
        }
    }

    /**
     p2p2 以上的设备，如果 p2pType 大于 2， 此方法会返回录制的音频数据。如果你需要修改音频数据，务必不要改变音频数据的长度，并在修改操作需要在代理方法中同步进行。 (If p2pType is greater than 2, could get audio record data when talking through this method. if yout want change the audio data, must keep the audio data length same，and synchronize.)

     - Parameter camera: 摄像头实例 (The camera instance)
     - Parameter pcm: 音频数据 (audio data)
     - Parameter length: 数据长度 (date length)
     - Parameter sampleRate: 音频样本比率 (audio sample rate)
     */
    func camera(_ camera: (any ThingSmartCameraType)!, thing_didRecieveAudioRecordDataWithPCM pcm: UnsafePointer<UInt8>!, length: Int32, sampleRate: Int32) { // typo
        allInnerDelegates().forEach { delegate in
            delegate.camera?(camera, thing_didRecieveAudioRecordDataWithPCM: pcm, length: length, sampleRate: sampleRate)
        }
    }

    func camera(_ camera: (any ThingSmartCameraType)!, thing_didSpeedPlayWith playBackSpeed: ThingSmartCameraPlayBackSpeed) {
        allInnerDelegates().forEach { delegate in
            delegate.camera?(camera, thing_didSpeedPlayWith: playBackSpeed)
        }
    }

    func cameraDidStartVideoTalk(_ camera: (any ThingSmartCameraType)!) {
        modifyCameraModel {
            $0.videoTalkState = .completed
            $0.isVideoTalkPaused = false
        }
    }

    func cameraDidStopVideoTalk(_ camera: (any ThingSmartCameraType)!) {
        modifyCameraModel {
            $0.videoTalkState = .idle
            $0.isVideoTalkPaused = false
        }
    }

    func cameraDidPauseVideoTalk(_ camera: (any ThingSmartCameraType)!) {
        modifyCameraModel { $0.isVideoTalkPaused = true }
    }

    func cameraDidResumeVideoTalk(_ camera: (any ThingSmartCameraType)!) {
        modifyCameraModel { $0.isVideoTalkPaused = false }
    }

    func camera(_ camera: (any ThingSmartCameraType)!, didReceiveLocalVideoFirstFrame image: UIImage!, localVideoInfo: (any ThingSmartLocalVideoInfoType)!) {
        print("s-size\(#function),width: \(localVideoInfo.width), height: \(localVideoInfo.height)")
    }

    func camera(_ camera: (any ThingSmartCameraType)!, didReceiveLocalVideoSampleBuffer sampleBuffer: CMSampleBuffer!, localVideoInfo: (any ThingSmartLocalVideoInfoType)!) {}

}
