//
//  DemoVideoInnerLocalizerView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class DemoVideoInnerLocalizerView: UIView {
    lazy var centerImageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "demo_localizer_normal"), for: .normal)
        button.setImage(UIImage(named: "demo_localizer_selected"), for: .selected)
        button.adjustsImageWhenHighlighted = false
        button.isUserInteractionEnabled = false
        return button
    }()

    lazy var innerTopLineView: UIView = { generateNormalInnerLineView() }()
    lazy var innerBottomLineView: UIView = { generateNormalInnerLineView() }()
    lazy var innerLeftLineView: UIView = { generateNormalInnerLineView() }()
    lazy var innerRightLineView: UIView = { generateNormalInnerLineView() }()

    private var selectedColor: UIColor
    private var normalColor: UIColor

    init(frame: CGRect, normalColor: UIColor, selectedColor: UIColor) {
        self.normalColor = normalColor
        self.selectedColor = selectedColor
        super.init(frame: frame)

        backgroundColor = .clear
        cornerRadius = frame.width / 2
        borderWidth = 1
        borderColor = normalColor

        addSubviews(centerImageButton, innerTopLineView, innerBottomLineView, innerLeftLineView, innerRightLineView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        centerImageButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(Self.kInnerLocalizerImageViewWidth)
        }
        innerTopLineView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.equalTo(Self.kLocalizerInnerLineViewWidth)
            make.height.equalTo(Self.kLocalizerInnerLineViewHeight)
        }
        innerBottomLineView.snp.makeConstraints { make in
            make.bottom.centerX.equalToSuperview()
            make.width.equalTo(Self.kLocalizerInnerLineViewWidth)
            make.height.equalTo(Self.kLocalizerInnerLineViewHeight)
        }
        innerLeftLineView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.equalTo(Self.kLocalizerInnerLineViewHeight)
            make.height.equalTo(Self.kLocalizerInnerLineViewWidth)
        }
        innerRightLineView.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.equalTo(Self.kLocalizerInnerLineViewHeight)
            make.height.equalTo(Self.kLocalizerInnerLineViewWidth)
        }
    }

    func refreshUIApperance(with selected: Bool) {
        centerImageButton.isSelected = selected
        let currentColor = selected ? selectedColor : normalColor
        innerTopLineView.backgroundColor = currentColor
        innerBottomLineView.backgroundColor = currentColor
        innerLeftLineView.backgroundColor = currentColor
        innerRightLineView.backgroundColor = currentColor
        borderColor = currentColor
    }

    private func generateNormalInnerLineView() -> UIView {
        let lineView = UIView()
        lineView.backgroundColor = normalColor
        return lineView
    }
}
