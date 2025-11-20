//
//  CameraCloudDayCollectionViewCell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class CameraCloudDayCollectionViewCell: UICollectionViewCell {
    var text: String = "" {
        didSet {
            textLabel.text = text
        }
    }

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = contentView.bounds
    }
}
