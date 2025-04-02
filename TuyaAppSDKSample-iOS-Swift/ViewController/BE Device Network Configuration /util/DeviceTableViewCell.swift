//
//  DeviceTableViewCell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import Foundation

class BEDeviceCellModel {
    let deviceModel: ThingSmartActivatorDeviceModel
    var deviceStatus: String
    
    init(deviceModel: ThingSmartActivatorDeviceModel) {
        self.deviceModel = deviceModel
        self.deviceStatus = "Add"
    }
    
    var name: String {
        return deviceModel.name
    }
    
    func updateStatus(_ status: String) {
        self.deviceStatus = status
    }
}

class DeviceTableViewCell: UITableViewCell {
    static let identifier = "DeviceTableViewCell"
    
    private let deviceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let deviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(deviceImageView)
        contentView.addSubview(deviceNameLabel)
        contentView.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            deviceImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            deviceImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deviceImageView.widthAnchor.constraint(equalToConstant: 40),
            deviceImageView.heightAnchor.constraint(equalToConstant: 40),
            
            deviceNameLabel.leadingAnchor.constraint(equalTo: deviceImageView.trailingAnchor, constant: 12),
            deviceNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with cellModel: BEDeviceCellModel) {
        deviceNameLabel.text = cellModel.deviceModel.name
        
        // 设置设备图标（这里使用默认图标，你可以根据实际需求设置不同设备的图标）
        deviceImageView.image = UIImage(named: "device_default")
        
        // 根据设备状态设置显示
        switch cellModel.deviceStatus {
        case "succeed":
            statusLabel.text = "succeed"
            statusLabel.textColor = .systemGreen
        case "Add":
            statusLabel.text = "Add"
            statusLabel.textColor = .systemBlue
        case "Failed":
            statusLabel.text = "Failed"
            statusLabel.textColor = .systemGray
        default:
            statusLabel.text = "Adding"
            statusLabel.textColor = .systemOrange
        }
    }
}
