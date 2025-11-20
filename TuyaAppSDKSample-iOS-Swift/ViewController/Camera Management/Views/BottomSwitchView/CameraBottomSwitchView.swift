//
//  CameraBottomSwitchView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import Combine

extension CameraBottomSwitchView {
    private static let kCameraBottomSwitchViewBtnBaseTag = 100

    enum CameraBottomButtonType: Int, CaseIterable {
        case main
        case ptz
        case cp
        case cruise

        var title: String {
            switch self {
            case .main:
                NSLocalizedString("Main", tableName: "IPCLocalizable", comment: "")
            case .ptz:
                NSLocalizedString("PTZ", tableName: "IPCLocalizable", comment: "")
            case .cp:
                NSLocalizedString("Collection Points", tableName: "IPCLocalizable", comment: "")
            case .cruise:
                NSLocalizedString("Cruise", tableName: "IPCLocalizable", comment: "")
            }
        }
    }
}

class CameraBottomSwitchView: UIView {
    var onSelectTab = PassthroughSubject<CameraBottomButtonType, Never>()

    private lazy var bottomStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.distribution = .fillEqually
        makeButtons().forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()

    private var dataSource = CameraBottomButtonType.allCases

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(bottomStackView)
        bottomStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelection(_ selection: CameraBottomButtonType) {
        guard let view = viewWithTag(selection.rawValue + Self.kCameraBottomSwitchViewBtnBaseTag),
              let button = view as? UIButton else { return }
        button.isSelected = true

        CameraBottomButtonType.allCases.filter {
            $0 != selection
        }.map {
            viewWithTag($0.rawValue + Self.kCameraBottomSwitchViewBtnBaseTag)
        }.forEach {
            ($0 as? UIButton)?.isSelected = false
        }
    }

    private func makeButtons() -> [UIButton] {
        dataSource.reduce(into: []) {
            let button = UIButton(type: .custom)
            button.setTitle($1.title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(.red, for: .selected)
            button.titleLabel?.font = .systemFont(ofSize: $1.title.count >= 15 ? 11 : 13)
            button.tag = Self.kCameraBottomSwitchViewBtnBaseTag + $1.rawValue
            button.isSelected = $1 == .main
            button.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
            $0.append(button)
        }
    }

    @objc
    private func btnClick(sender: UIButton) {
        let rawValue = sender.tag - Self.kCameraBottomSwitchViewBtnBaseTag
        guard let selection = CameraBottomButtonType(rawValue: rawValue) else { return }

        sender.isSelected = true
        setSelection(selection)

        onSelectTab.send(selection)
    }
}
