//
//  BECreateHomeViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import CoreLocation
import ThingSmartFamilyBizKit

class BECreateHomeViewController : UITableViewController {
    @IBOutlet weak var homeName: UITextField!
    @IBOutlet weak var homeCity:UITextField!
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    let locationManager = CLLocationManager()
    
    @IBAction func createHome(_ sender: Any) {
        let homeName = homeName.text ?? ""
        let geoName = homeCity.text ?? ""
        
        let requestModel = ThingSmartFamilyRequestModel()
        requestModel.name = homeName
        requestModel.geoName = geoName
        requestModel.latitude = latitude
        requestModel.longitude = longitude
        
        ThingSmartFamilyBiz.sharedInstance().addFamily(with: requestModel) {[weak self] homeId in
            guard let self = self else { return }
            let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }
            
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("Successfully added new home.", comment: ""), actions: [action])
        } failure: {[weak self] error in
            guard let self = self else { return }
            let errorMessage = error?.localizedDescription ?? ""
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Add New Home", comment: ""), message: errorMessage)
        }
    }
    
    func autoGetCity() {
        ThingSmartFamilyBiz.sharedInstance().getCityInfo(latitude, longitude: longitude) {[weak self] cityModel in
            guard let self = self else {return}
            self.homeCity.text = (cityModel?.province ?? "") + " " + (cityModel?.city ?? "") + " " + (cityModel?.area ?? "")
        } failure: {[weak self] error in
            guard let self = self else {return}
            Alert.showBasicAlert(on: self, with: "Failed to get city info", message: "")
        }
    }
    
    override func viewDidLoad() {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Cannot Access Location", comment: ""), message: NSLocalizedString("Please make sure if the location access is enabled for the app.", comment: ""))
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, indexPath.row == 2 {
            autoGetCity()
        }
    }
}

extension BECreateHomeViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate else { return }
        longitude = location.longitude
        latitude = location.latitude
    }
}
