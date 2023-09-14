//
//  BEEditHomeViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartFamilyBizKit

class BEEditHomeViewController : UITableViewController {
    
    @IBOutlet weak var nameLabel : UITextField!
    @IBOutlet weak var cityLabel : UITextField!
    @IBOutlet weak var latitudeLabel : UITextField!
    @IBOutlet weak var longitudeLabel : UITextField!
    
    var home : ThingSmartHomeModel?
    
    override func viewWillAppear(_ animated: Bool) {
        if let model = home {
            nameLabel.text = model.name
            cityLabel.text = model.geoName
            latitudeLabel.text = "\(model.latitude)"
            longitudeLabel.text = "\(model.longitude)"
        } else {
            Alert.showBasicAlert(on: self, with: "No Home", message: "")
        }
    }
    
    @IBAction func tapSave() {
        let requestModel = ThingSmartFamilyRequestModel()
        requestModel.name = nameLabel.text ?? ""
        requestModel.geoName = cityLabel.text ?? ""
        requestModel.latitude = Double(latitudeLabel.text ?? "") ?? 0
        requestModel.longitude = Double(longitudeLabel.text ?? "") ?? 0
        
        if let model = home {
            ThingSmartFamilyBiz.sharedInstance().updateFamily(withHomeId: model.homeId, model: requestModel) {
                
                let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.navigationController?.popViewController(animated: true)
                }
                
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("Update Home", comment: ""), actions: [action])
            } failure: {[weak self] error in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to update home", comment: ""), message: errorMessage)
            }
        }
    }
}
