//
//  NewHomeTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import CoreLocation
import ThingSmartDeviceKit

class NewHomeTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var homeNameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    
    // MARK: - Property
    let homeManager = ThingSmartHomeManager()
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        
        requestLocationAuthorization()
    }
    
    func requestLocationAuthorization() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    // CLLocationManagerDelegate method
     func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
         checkAuthorizationStatus()
     }

     // Check the authorization status
     func checkAuthorizationStatus() {
         let status: CLAuthorizationStatus
         if #available(iOS 14.0, *) {
             // Use instance property for iOS 14 and later
             status = locationManager.authorizationStatus
         } else {
             // Use class method for iOS versions below 14
             status = CLLocationManager.authorizationStatus()
         }

         switch status {
         case .notDetermined:
             // User has not yet made a choice regarding location services
             print("Authorization status not determined")
             Alert.showBasicAlert(on: self, with: NSLocalizedString("Cannot Access Location", comment: ""), message: NSLocalizedString("Please make sure if the location access is enabled for the app.", comment: ""))
         case .restricted, .denied:
             // User has denied or restricted location services
             print("Location services are not authorized")
             Alert.showBasicAlert(on: self, with: NSLocalizedString("Cannot Access Location", comment: ""), message: NSLocalizedString("Please make sure if the location access is enabled for the app.", comment: ""))
         case .authorizedWhenInUse, .authorizedAlways:
             // User has authorized location services
             locationManager.startUpdatingLocation()
             print("Location services are enabled")
         @unknown default:
             // Handle any unknown authorization status
             print("Unknown authorization status")
         }
     }

     // Handle location updates
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         if let location = locations.first {
             print("Current location: \(location)")
             longitude = location.coordinate.longitude
             latitude = location.coordinate.latitude
             
             locationManager.stopUpdatingLocation()
             
             
             geocoder.reverseGeocodeLocation(location) {[weak self] (placemarks, error) in
                 if let error = error {
                     print("Reverse geocoding failed: \(error.localizedDescription)")
                     return
                 }
                 
                 if let placemark = placemarks?.first {
                     // Extract city information
                     if let city = placemark.locality {
                         print("Current city: \(city)")
                         self?.cityTextField.text = city
                     } else {
                         print("City information not available")
                     }
                 }
             }

         }
     }

     // Handle location update failures
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("Failed to find user's location: \(error.localizedDescription)")
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
