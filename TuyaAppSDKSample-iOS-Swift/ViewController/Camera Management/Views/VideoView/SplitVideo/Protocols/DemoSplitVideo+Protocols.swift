//
//  DemoSplitVideo+Protocols.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

protocol DemoSplitVideoViewContextQuoterProtocol: AnyObject {
    var videoViewContext: DemoSplitVideoViewContextProtocol? { get set }
}

protocol DemoSplitVideoViewContextProtocol: AnyObject {
    var videoOperator: DemoSplitVideoOperatorProtocol? { get }
    var viewSizeCounter: DemoSplitVideoViewSizeCounterProtocol? { get }
}

protocol DemoSplitVideoOperatorProtocol: AnyObject {
    var advancedConfig: ThingSmartCameraBase.ThingSmartCameraAdvancedConfig? { get }

    func bindVideoViewIndexPairs(_ videoIndexPairs: [ThingSmartVideoViewIndexPair]) -> Bool

    func unbindVideoViewIndexPairs(_ videoIndexPairs: [ThingSmartVideoViewIndexPair]) -> Bool

    func bindVideoView<V: UIView>(_ videoView: V, videoIndex: ThingSmartVideoIndex) -> Bool where V: ThingSmartVideoViewType

    func unbindVideoView<V: UIView>(_ videoView: V, forVideoIndex videoIndex: ThingSmartVideoIndex) -> Bool where V: ThingSmartVideoViewType
    
    func swapVideoIndex(_ videoIndex: ThingSmartVideoIndex, forVideoIndex: ThingSmartVideoIndex) -> Bool

    func publishLocalizerCoordinateInfo(_ coordinateInfo: String) -> Bool
}

protocol DemoSplitVideoViewSizeCounterProtocol: AnyObject {
    var padding: CGFloat { get }

    var landscapeSmallSize: CGSize { get }
    var landscapeViewMargin: CGFloat { get }
    var landscapeCoverSize: CGSize { get }

    var portraitSmallSize: CGSize { get }
    var portraitNormalSize: CGSize { get }

    var videoViewWidth: CGFloat { get }
    var videoViewHeight: CGFloat { get }
}

protocol DemoSplitVideoViewGestureDelegate: AnyObject {
    func respondWeappedTapGesture(_ tapGesture: UITapGestureRecognizer) -> Bool

    func didTapVideoNodeView(_ videoNodeView: DemoSplitVideoNodeView) -> Bool
}

extension DemoSplitVideoViewGestureDelegate {
    func respondWeappedTapGesture(_ tapGesture: UITapGestureRecognizer) -> Bool { return true }

    func didTapVideoNodeView(_ videoNodeView: DemoSplitVideoNodeView) -> Bool { return true }
}
