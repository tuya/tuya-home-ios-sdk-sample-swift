//
//  CameraLoadingButton.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class CameraLoadingButton: UIButton {
    var normalImageName, selectedImageName: String?

    private lazy var indecatorView: UIActivityIndicatorView = {
        let indecatorView = UIActivityIndicatorView(style: .medium)
        indecatorView.color = .white
        indecatorView.isHidden = true
        indecatorView.isUserInteractionEnabled = false
        return indecatorView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(indecatorView)

        indecatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(bounds.height)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        hideImage(false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startLoading(withEnabled isEnabled: Bool) {
        startLoading()
        self.isEnabled = isEnabled
    }

    func startLoading() {
        guard !indecatorView.isAnimating else { return }
        hideImage(true)
        indecatorView.startAnimating()
    }

    func stopLoading(withEnabled isEnabled: Bool) {
        stopLoading()
        self.isEnabled = isEnabled
    }

    func stopLoading() {
        indecatorView.stopAnimating()
        hideImage(false)
    }

    private func hideImage(_ isHidden: Bool) {
        if isHidden {
            setImage(nil, for: .normal)
            setImage(nil, for: .selected)
            return
        }

        if let normalImageName, let selectedImageName {
            setImage(UIImage(named: normalImageName), for: .normal)
            setImage(UIImage(named: selectedImageName), for: .selected)
        }
    }
}
