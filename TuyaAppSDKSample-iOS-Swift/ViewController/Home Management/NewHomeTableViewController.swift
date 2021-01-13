//
//  NewHomeTableViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import TuyaSmartDeviceKit
import CoreLocation

class NewHomeTableViewController: UITableViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var homeNameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    
    // MARK: - Property
    let homeManager = TuyaSmartHomeManager()
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
            Alert.showBasicAlert(on: self, with: "Cannot Access Location", message: "Please make sure if the location access is enabled for the app.")
        }
    }

    // MARK: - IBAction
    @IBAction func createTapped(_ sender: UIBarButtonItem) {
        let homeName = homeNameTextField.text ?? ""
        let geoName = cityTextField.text ?? ""
        
        homeManager.addHome(withName: homeName, geoName: geoName, rooms: [""], latitude: latitude, longitude: longitude) { [weak self] _ in
            guard let self = self else { return }
            let action = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }
            
            Alert.showBasicAlert(on: self, with: "Success", message: "Successfully added new home.", actions: [action])
            
        } failure: { [weak self] (error) in
            guard let self = self else { return }
            let errorMessage = error?.localizedDescription ?? ""
            Alert.showBasicAlert(on: self, with: "Failed to Add New Home", message: errorMessage)
        }

    }
}

extension NewHomeTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate else { return }
        longitude = location.longitude
        latitude = location.latitude
    }
}
