//
//  ThingLinkActionMsgSendController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2022 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartDeviceKit

class ThingLinkActionMsgSendController: UITableViewController {

    public var action: ThingSmartThingAction?
    public var callback: ((_ dict: [String: Any]?) -> Void)?
    
    private var payload: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = action?.code
    }

    @IBAction func clickBackBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func clickSendBtn(_ sender: Any) {
        self.callback?(self.payload)
        self.dismiss(animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return action?.inputParams.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        guard let inputs = action?.inputParams,
              let params = inputs[indexPath.row] as? [String: Any],
              let code = params["code"] as? String,
              let spec = params["typeSpec"] as? [String: Any],
              let typeSpec = ThingSmartSchemaPropertyModel.yy_model(with:  spec)
        else { return defaultCell }
        
        let cellIdentifier = DeviceControlCell.cellIdentifier(with: typeSpec.type ?? "")
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.rawValue)!
        
        let isReadOnly = false
        
        switch cellIdentifier {
        case .switchCell:
            guard let cell = cell as? SwitchTableViewCell else { break }
            
            cell.label.text = code
            cell.switchButton.isOn = false
            cell.isReadOnly = isReadOnly
            
            cell.switchAction = { [weak self] switchButton in
                self?.payload[code] = switchButton.isOn
            }

        case .sliderCell:
            guard let cell = cell as? SliderTableViewCell else { break }
            
            cell.label.text = code
            cell.detailLabel.text = ""
            cell.slider.minimumValue = Float(typeSpec.min)
            cell.slider.maximumValue = Float(typeSpec.max)
            cell.slider.isContinuous = false
            cell.slider.value = Float(typeSpec.min)
            cell.isReadOnly = isReadOnly
            
            cell.sliderAction = { [weak self] slider in
                let step = Float(typeSpec.step)
                let roundedValue = round(slider.value / step) * step
                self?.payload[code] = Int(roundedValue)
            }
            
        case .enumCell:
            guard let cell = cell as? EnumTableViewCell,
                  let range = typeSpec.range as? [String]
            else { break }
            
            cell.label.text = code
            cell.optionArray = range
            cell.currentOption = range.first
            cell.isReadOnly = isReadOnly
            
            cell.selectAction = { [weak self] option in
                self?.payload[code] = option
            }
            
        case .stringCell:
            guard let cell = cell as? StringTableViewCell else { break }
            cell.label.text = code
            cell.textField.text = ""
            cell.isReadOnly = isReadOnly
            
            cell.buttonAction = { [weak self] text in
                self?.payload[code] = text
            }
            
        case .labelCell:
            guard let cell = cell as? LabelTableViewCell else { break }
            cell.label.text = code
            cell.detailLabel.text = ""
        
        case .textviewCell:
            guard let cell = cell as? TextViewTableViewCell else { break }
            
            cell.title.text = code
            cell.textview.text = ""
            cell.buttonAction = { [weak self] text in
                guard let value = text.data(using: .utf8),
                      let data = try? JSONSerialization.jsonObject(with: value)
                else {
                    SVProgressHUD.showError(withStatus: "Not json string")
                    return
                }
                self?.payload[code] = data
            }
        }
        
        return cell
        
        return defaultCell
    }

}
