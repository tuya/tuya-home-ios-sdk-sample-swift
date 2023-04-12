//
//  NewHomeTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import CoreLocation
import ThingSmartDeviceKit

class NewHomeTableViewController: UITableViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var homeNameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    
    // MARK: - Property
    let homeManager = ThingSmartHomeManager()
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
    }

    // MARK: - IBAction
    @IBAction func createTapped(_ sender: UIBarButtonItem) {
        let homeName = homeNameTextField.text ?? ""
        let geoName = cityTextField.text ?? ""
        
        homeManager.addHome(withName: homeName, geoName: geoName, rooms: [""], latitude: latitude, longitude: longitude) { [weak self] _ in
            guard let self = self else { return }
            let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }
            
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("Successfully added new home.", comment: ""), actions: [action])
            
        } failure: { [weak self] (error) in
            guard let self = self else { return }
            let errorMessage = error?.localizedDescription ?? ""
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Add New Home", comment: ""), message: errorMessage)
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
