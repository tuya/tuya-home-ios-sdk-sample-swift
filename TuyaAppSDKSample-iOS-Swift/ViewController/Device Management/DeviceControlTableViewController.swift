//
//  DeviceControlTableViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import TuyaSmartDeviceKit
import SVProgressHUD

class DeviceControlTableViewController: UITableViewController {

    // MARK: - Property
    var device: TuyaSmartDevice?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        detectDeviceAvailability()
        navigationItem.title = device?.deviceModel.name
        device?.delegate = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        SVProgressHUD.dismiss()
    }
    
    // MARK: -  Private Method
    private func detectDeviceAvailability() {
        if let isOnline = device?.deviceModel.isOnline, !isOnline {
            SVProgressHUD.show(withStatus: "The device is offline. The control panel is unavailable.")
        } else {
            SVProgressHUD.dismiss()
        }
    }
    
    private func publishMessage(with dps: NSDictionary) {
        guard let dps = dps as? [AnyHashable : Any] else { return }

        device?.publishDps(dps, success: {

        }, failure: { (error) in
            let errorMessage = error?.localizedDescription ?? ""
            SVProgressHUD.showError(withStatus: errorMessage)
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return device?.deviceModel.schemaArray.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        guard let device = device else { return defaultCell }
        
        let schema = device.deviceModel.schemaArray[indexPath.row]
        let dps = device.deviceModel.dps
        let cellIdentifier = DeviceControlCell.cellIdentifier(with: schema)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.rawValue)!
        
        switch cellIdentifier {
        case .switchCell:
            guard let cell = cell as? SwitchTableViewCell,
                  let dps = dps,
                  let dpID = schema.dpId,
                  let isOn = dps[dpID] as? Bool
            else { break }
            
            cell.label.text = schema.name
            cell.switchButton.isOn = isOn
            
            cell.switchAction = { [weak self] switchButton in
                guard let self = self,
                      let dpID = schema.dpId
                else { return }
                
                self.publishMessage(with: [dpID : switchButton.isOn])
            }

        case .sliderCell:
            guard let cell = cell as? SliderTableViewCell,
                  let dps = dps,
                  let dpID = schema.dpId,
                  let value = dps[dpID] as? Int
            else { break }
            
            cell.label.text = schema.name
            cell.detailLabel.text = String(value)
            cell.slider.minimumValue = Float(schema.property.min)
            cell.slider.maximumValue = Float(schema.property.max)
            cell.slider.isContinuous = false
            cell.slider.value = Float(value)
            
            cell.sliderAction = { [weak self] slider in
                guard let self = self,
                      let dpID = schema.dpId
                else { return }
                
                let step = Float(schema.property.step)
                let roundedValue = round(slider.value / step) * step
                self.publishMessage(with: [dpID : Int(roundedValue)])
            }
            
        case .enumCell:
            guard let cell = cell as? EnumTableViewCell,
                  let dps = dps,
                  let dpID = schema.dpId,
                  let option = dps[dpID] as? String,
                  let range = schema.property.range as? [String]
            else { break }
            
            cell.label.text = schema.name
            cell.optionArray = range
            cell.currentOption = option
            cell.selectAction = { [weak self] option in
                guard let self = self else { return }
                self.publishMessage(with: [dpID : option])
            }
            
        case .stringCell:
            guard let cell = cell as? StringTableViewCell,
                  let dps = dps,
                  let dpID = schema.dpId,
                  let text = dps[dpID] as? String
            else { break }
            
            cell.label.text = schema.name
            cell.textField.text = text
            cell.buttonAction = { [weak self] text in
                guard let self = self else { return }
                self.publishMessage(with: [dpID : text])
            }
            
        case .labelCell:
            guard let cell = cell as? LabelTableViewCell,
                  let dps = dps,
                  let dpID = schema.dpId,
                  let text = dps[dpID] as? String
            else { break }
            
            cell.label.text = schema.name
            cell.detailLabel.text = text
        }

        return cell
    }

}

extension DeviceControlTableViewController: TuyaSmartDeviceDelegate {
    func deviceInfoUpdate(_ device: TuyaSmartDevice) {
        detectDeviceAvailability()
        tableView.reloadData()
    }
    
    func device(_ device: TuyaSmartDevice, dpsUpdate dps: [AnyHashable : Any]) {
        detectDeviceAvailability()
        tableView.reloadData()
    }
}
