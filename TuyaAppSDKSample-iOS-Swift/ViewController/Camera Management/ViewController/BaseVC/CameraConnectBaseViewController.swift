//
//  CameraConnectBaseViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import Combine

let videoWidth = UIScreen.main.bounds.width
let videoHeight = videoWidth / 16 * 9

class CameraConnectBaseViewController: CameraBaseViewController, ThingSmartCameraDelegate {
    private(set) var devId: String
    private(set) var cameraDevice: CameraDevice?

    private(set) var videoView: ThingCameraVideoContainer?

    private var subscriptions = Set<AnyCancellable>()

    init(devId: String) {
        self.devId = devId
        cameraDevice = CameraDeviceManager.shared.getCameraDevice(devId: devId)
        videoView = ThingCameraVideoContainer()
        videoView?.videoView = cameraDevice?.videoView
        super.init(nibName: nil, bundle: nil)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        cameraDevice?.addDelegate(self)
        cameraDevice?.bindVideoRenderView()
        videoView?.videoView = cameraDevice?.videoView
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraDevice?.removeDelegate(self)
        cameraDevice?.unbindVideoRenderView()
    }

    func disconnect() {
        cameraDevice?.disconnect()
    }

    func applicationDidEnterBackgroundNotification(_ notification: Notification?) {
        disconnect()
    }

    func applicationWillEnterForegroundNotification(_ notification: Notification?) {
        
    }

    private func addObservers() {
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                self?.audioSessionDidInterruptNotification(notification)
            }
            .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] noti in
                self?.applicationDidEnterBackgroundNotification(noti)
            }
            .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] noti in
                self?.applicationWillEnterForegroundNotification(noti)
            }
            .store(in: &subscriptions)
    }

    private func audioSessionDidInterruptNotification(_ notification: Notification) {
        if let type = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? Int {
            if type == AVAudioSession.InterruptionType.began.rawValue {
                applicationDidEnterBackgroundNotification(nil)
            } else  if type == AVAudioSession.InterruptionType.ended.rawValue {
                applicationWillEnterForegroundNotification(nil)
            }
        }
    }
}
