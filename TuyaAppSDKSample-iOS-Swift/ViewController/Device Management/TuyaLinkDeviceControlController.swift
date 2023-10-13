//
//  ThingLinkDeviceControlController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2022 Thing Inc. (https://developer.tuya.com/)

import UIKit
import NotificationCenter

class ThingLinkDeviceControlController: UITableViewController {

    // MARK: - Property
    var device: ThingSmartDevice?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = device?.deviceModel.name
        device?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(deviceHasRemoved(_:)), name: .SVProgressHUDDidDisappear, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        detectDeviceAvailability()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        SVProgressHUD.dismiss()
        NotificationCenter.default.removeObserver(self, name: .SVProgressHUDDidDisappear, object: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "show-device-detail" else { return }
        let vc = segue.destination as! DeviceDetailTableViewController
        vc.device = device
    }
    
    // MARK: -  Private Method
    private func detectDeviceAvailability() {
        if let isOnline = device?.deviceModel.isOnline, !isOnline {
            NotificationCenter.default.post(name: .deviceOffline, object: nil)
            SVProgressHUD.show(withStatus: NSLocalizedString("The device is offline. The control panel is unavailable.", comment: ""))
        } else {
            NotificationCenter.default.post(name: .deviceOnline, object: nil)
            SVProgressHUD.dismiss()
        }
    }
    
    @objc private func deviceHasRemoved(_ notification: Notification) {
        guard let key = notification.userInfo?[SVProgressHUDStatusUserInfoKey] as? String,
              key.contains("removed")
        else { return }
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Publish message
    private func publishProperty(payload: [String: Any]) {
        self.device?.publishThingMessage(with: .property, payload: payload, success: {
            
        }, failure: { error in
            SVProgressHUD.showError(withStatus: error?.localizedDescription ?? "")
        })
    }
    
    private func publishAction(_ action: String, payload: [String: Any]) {
        self.device?.publishThingMessage(with: .action, payload: [
            "actionCode": action,
            "inputParams": payload
        ], success: {
            
        }, failure: { error in
            SVProgressHUD.showError(withStatus: error?.localizedDescription ?? "")
        })
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let thing = self.device?.deviceModel.thingModel else { return 0 }
        if section == 0 {
            return thing.services.first?.properties.count ?? 0
        } else if section == 1 {
            return thing.services.first?.actions.count ?? 0
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "properties"
        } else if section == 1 {
            return "actions"
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        guard let device = device,
              let thing = device.deviceModel.thingModel,
              let service = thing.services.first
        else { return defaultCell }
        
        if indexPath.section == 0 {
            let properties = service.properties
            let property = properties[indexPath.row]
            let typeSpec = ThingSmartSchemaPropertyModel.yy_model(with: property.typeSpec)
            
            let cellIdentifier = DeviceControlCell.cellIdentifier(with: typeSpec?.type ?? "")
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.rawValue)!
            
            let isReadOnly = property.accessMode.elementsEqual("ro")
            let dpID     = String(property.abilityId)
            
            guard let dps = device.deviceModel.dps,
                  let typeSpec = typeSpec
            else { return cell }
            
            switch cellIdentifier {
            case .switchCell:
                guard let cell = cell as? SwitchTableViewCell,
                      let isOn = dps[dpID] as? Bool
                else { break }
                
                cell.label.text = property.code
                cell.switchButton.isOn = isOn
                cell.isReadOnly = isReadOnly
                
                cell.switchAction = { [weak self] switchButton in
                    self?.publishProperty(payload: [property.code : switchButton.isOn])
                }

            case .sliderCell:
                guard let cell = cell as? SliderTableViewCell,
                      let value = dps[dpID] as? Int
                else { break }
                
                cell.label.text = property.code
                cell.detailLabel.text = String(value)
                cell.slider.minimumValue = Float(typeSpec.min)
                cell.slider.maximumValue = Float(typeSpec.max)
                cell.slider.isContinuous = false
                cell.slider.value = Float(value)
                cell.isReadOnly = isReadOnly
                
                cell.sliderAction = { [weak self] slider in
                    let step = Float(typeSpec.step)
                    let roundedValue = round(slider.value / step) * step
                    self?.publishProperty(payload: [property.code : Int(roundedValue)])
                }
                
            case .enumCell:
                guard let cell = cell as? EnumTableViewCell,
                      let option = dps[dpID] as? String,
                      let range = typeSpec.range as? [String]
                else { break }
                
                cell.label.text = property.code
                cell.optionArray = range
                cell.currentOption = option
                cell.isReadOnly = isReadOnly
                
                cell.selectAction = { [weak self] option in
                    self?.publishProperty(payload: [property.code : option])
                }
                
            case .stringCell:
                guard let cell = cell as? StringTableViewCell else { break }
                
                let value = dps[dpID] ?? ""
                var text = ""
                
                ((value as? Int) != nil) ? (text = String(value as! Int)) : (text = value as? String ?? "")
                
                cell.label.text = property.code
                cell.textField.text = text
                cell.isReadOnly = isReadOnly
                
                cell.buttonAction = { [weak self] text in
                    self?.publishProperty(payload: [property.code : text])
                }
                
            case .labelCell:
                guard let cell = cell as? LabelTableViewCell,
                      let value = dps[dpID]
                else { break }
                
                var text = ""

                ((value as? Int) != nil) ? (text = String(value as! Int)) : (text = value as? String ?? "")
                
                cell.label.text = property.code
                cell.detailLabel.text = text
            
            case .textviewCell:
                guard let cell = cell as? TextViewTableViewCell,
                      let value = dps[dpID]
                else { break }
                
                cell.title.text = property.code
                cell.textview.text = ""
                if let data = try? JSONSerialization.data(withJSONObject: value, options: []) as Data,
                   let s = String.init(data: data, encoding: .utf8) {
                    cell.textview.text = s
                }
                cell.buttonAction = { [weak self] text in
                    guard let value = text.data(using: .utf8),
                          let data = try? JSONSerialization.jsonObject(with: value)
                    else {
                        SVProgressHUD.showError(withStatus: "Not json string")
                        return
                    }
                    self?.publishProperty(payload: [property.code : data])
                }
            }
            
            return cell
        } else if indexPath.section == 1 {
            let actions = service.actions
            let action = actions[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "default-cell")
            cell?.textLabel?.text = action.code
            return cell!
        }
        
        return defaultCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            guard let actions = self.device?.deviceModel.thingModel?.services.first?.actions else { return }
            let action = actions[indexPath.row]
            
            let storyboard = UIStoryboard(name: "DeviceList", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ThingLinkActionMsgSendController") as! ThingLinkActionMsgSendController
            vc.action = action
            vc.callback = { [weak self] payload in
                guard let payload = payload,
                      let self = self
                else { return }
                
                self.publishAction(action.code, payload: payload)
            }
            
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true)
        }
    }
}

extension ThingLinkDeviceControlController: ThingSmartDeviceDelegate {
    func deviceInfoUpdate(_ device: ThingSmartDevice) {
        detectDeviceAvailability()
        tableView.reloadData()
    }
    
    func deviceRemoved(_ device: ThingSmartDevice) {
        NotificationCenter.default.post(name: .deviceOffline, object: nil)
        SVProgressHUD.showError(withStatus: NSLocalizedString("The device has been removed.", comment: ""))
    }
    
    func device(_ device: ThingSmartDevice, didReceiveThingMessageWith thingMessageType: ThingSmartThingMessageType, payload: [AnyHashable : Any]) {
        switch thingMessageType {
        case .property:
            detectDeviceAvailability()
            tableView.reloadData()
        case .action:
            print("---action: \(payload)")
            if let code = payload["actionCode"] as? String,
               let outputParams = payload["outputParams"] as? [String: Any] {
                Alert.showBasicAlert(on: self, with: code, message: outputParams.description, actions: [UIAlertAction(title: "ok", style: .default)])
            }
        case .event:
            print("---event: \(payload)")
            if let code = payload["eventCode"] as? String,
               let outputParams = payload["outputParams"] as? [String: Any] {
                Alert.showBasicAlert(on: self, with: code, message: outputParams.description, actions: [UIAlertAction(title: "ok", style: .default)])
            }
        @unknown default:
            break
        }
    }
    
    func device(_ device: ThingSmartDevice, dpsUpdate dps: [AnyHashable : Any]) {
        print("---dps update: \(dps)")
    }
}
