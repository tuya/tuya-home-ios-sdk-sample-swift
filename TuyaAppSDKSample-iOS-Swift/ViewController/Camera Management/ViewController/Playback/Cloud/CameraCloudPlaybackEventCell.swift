//
//  CameraCloudPlaybackEventCell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class CameraCloudPlaybackEventCell: UITableViewCell {
    private lazy var eventImageView: UIImageView = .init()

    private lazy var eventNameLabel: UILabel = .init()

    private lazy var eventSubtitle: UILabel = .init()

    private static let dateFormatter = DateFormatter(format: "HH:mm:ss")

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubviews(eventImageView, eventNameLabel, eventSubtitle)

        eventImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showImagePreview))
        eventImageView.addGestureRecognizer(tapGesture)

        eventImageView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 88, height: 50))
        }

        eventNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(eventImageView.snp.trailing).offset(16)
            make.bottom.equalTo(contentView.snp.centerY).offset(-2)
        }

        eventSubtitle.snp.makeConstraints { make in
            make.leading.equalTo(eventNameLabel)
            make.top.equalTo(contentView.snp.centerY).offset(2)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews(_ event: ThingSmartCloudTimeEventModel, encryptKey: String) {
        eventNameLabel.font = .systemFont(ofSize: 16)
        eventSubtitle.font = .systemFont(ofSize: 12)
        eventImageView.thing_setAESImage(withPath: event.snapshotUrl, encryptKey: encryptKey)
        eventNameLabel.text = event.describe
        eventSubtitle.text = Self.dateFormatter.string(
            from: Date(timeIntervalSince1970: TimeInterval(event.startTime))
        )
    }

    @objc
    private func showImagePreview() {
        DemoImagePreviewController(image: eventImageView.image).show()
    }
}
