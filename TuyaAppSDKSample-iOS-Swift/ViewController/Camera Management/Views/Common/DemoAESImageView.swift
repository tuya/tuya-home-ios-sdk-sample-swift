//
//  DemoAESImageView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI
import ThingEncryptImage

struct DemoAESImageView: UIViewRepresentable {
    typealias UIViewType = UIView

    private let attachPic: String
    private let enablePreview: Bool

    init(attachPic: String, enablePreview: Bool = true) {
        self.attachPic = attachPic
        self.enablePreview = enablePreview
    }

    init(path: String, key: String, enablePreview: Bool = true) {
        let attach = "\(path)@\(key)"
        self.init(attachPic: attach, enablePreview: enablePreview)
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill

        let components = attachPic.components(separatedBy: "@")
        if components.count == 2 {
            let imagePath = components.first!, encryptKey = components.last
            imageView.thing_setAESImage(withPath: imagePath, encryptKey: encryptKey) { image, _, _, _, _ in
                context.coordinator.image = image
            }
        } else if let url = URL(string: attachPic) {
            imageView.thing_setImage(with: url)
        }

        if enablePreview {
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.onTapImage)))
        }

        container.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var image: UIImage?

        @objc
        func onTapImage() {
            guard let image else { return }

            DemoImagePreviewController(image: image).show()
        }
    }
}
