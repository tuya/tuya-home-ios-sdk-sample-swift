//
//  EditHomeTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import CoreLocation
import ThingSmartDeviceKit

class EditHomeTableViewController: UITableViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var homeNameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    
    // MARK: - Property
    var home: ThingSmartHome?
    let locationManager = CLLocationManager()
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Cannot Access Location", comment: ""), message: NSLocalizedString("Please make sure if the location access is enabled for the app.", comment: ""))
        }
        
        guard let home = home else { return }
        homeNameTextField.text = home.homeModel.name
        cityTextField.text = home.homeModel.geoName
    }
    
    // MARK: - IBAction
    @IBAction func doneTapped(_ sender: Any) {
        let homeName = homeNameTextField.text ?? ""
        let geoName = cityTextField.text ?? ""
        
        home?.updateInfo(withName: homeName, geoName: geoName, latitude: latitude, longitude: longitude, success: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }, failure: { [weak self] (error) in
            guard let self = self else { return }
            let errorMessage = error?.localizedDescription ?? ""
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Update Home", comment: ""), message: errorMessage)
        })
    }
}


extension EditHomeTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate else { return }
        longitude = location.longitude
        latitude = location.latitude
    }
}
