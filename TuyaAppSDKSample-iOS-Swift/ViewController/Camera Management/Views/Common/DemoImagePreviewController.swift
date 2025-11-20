//
//  DemoImagePreviewView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class DemoImagePreviewController: UIViewController {
    private let image: UIImage?

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSelf)))
        return imageView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        scrollView.delegate = self
        return scrollView
    }()

    func show(in vc: UIViewController? = nil) {
        if let vc {
            vc.present(self, animated: true)
            return
        }
        UIApplication.shared.tp_topMostViewController?.present(self, animated: true)
    }

    init(image: UIImage?) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        imageView.frame = .init(x: 0, y: 0, width: view.width, height: view.width * 9.0 / 16.0)
        imageView.center = view.center
    }

    @objc
    private func dismissSelf() {
        dismiss(animated: true)
    }
}

extension DemoImagePreviewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? ((scrollView.frame.size.width - scrollView.contentSize.width) * 0.5) : 0.0;
        let offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? ((scrollView.frame.size.height - scrollView.contentSize.height) * 0.5) : 0.0;
        self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    }
}
