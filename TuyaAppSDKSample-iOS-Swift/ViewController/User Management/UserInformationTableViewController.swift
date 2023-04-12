//
//  UserInformationTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import CoreLocation
import ThingSmartBaseKit

class UserInformationTableViewController: UITableViewController {
    // MARK: IBOutlet
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailAddressLabel: UILabel!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var timeZoneLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var updateGeographicCoordinateButton: UIButton!
    @IBOutlet weak var deactivateAccountButton: UIButton!
    
    // MARK: - Property
    let locationManager = CLLocationManager()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userNameLabel.text = ThingSmartUser.sharedInstance().userName
        phoneNumberLabel.text = ThingSmartUser.sharedInstance().phoneNumber
        emailAddressLabel.text = ThingSmartUser.sharedInstance().email
        countryCodeLabel.text = ThingSmartUser.sharedInstance().countryCode
        timeZoneLabel.text = ThingSmartUser.sharedInstance().timezoneId
        unitLabel.text = ThingSmartUser.sharedInstance().tempUnit == 1 ? NSLocalizedString("Celsius", comment: "") : NSLocalizedString("Fahrenheit", comment: "")
    }
    
    // MARK: - IBAction
    @IBAction func updateGeographicCoordinateTapped(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Cannot Access Location", comment: ""), message: NSLocalizedString("Please make sure if the location access is enabled for the app.", comment: ""))
        }
    }
    
    @IBAction func deactivateAccountTapped(_ sender: UIButton) {
        let alertViewController = UIAlertController(title: nil, message: NSLocalizedString("You're going to deactivate this account.", comment: "User tapped the deactivate account button."), preferredStyle: .actionSheet)
        
        let deactivateAction = UIAlertAction(title: NSLocalizedString("Deactivate", comment: "Confirm deactivate."), style: .destructive) { [weak self] (action) in
            guard let self = self else { return }
            ThingSmartUser.sharedInstance().cancelAccount {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateInitialViewController()
                self.window?.rootViewController = vc
                
            } failure: { [weak self] (error) in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Deactivate", comment: "Failed to deactivate"), message: errorMessage)
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel)
        
        alertViewController.popoverPresentationController?.sourceView = sender
        
        alertViewController.addAction(deactivateAction)
        alertViewController.addAction(cancelAction)
        
        self.present(alertViewController, animated: true, completion: nil)
    }
}

// MARK: - CLLocationManagerDelegate
extension UserInformationTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate else { return }
        ThingSmartSDK.sharedInstance().updateLatitude(location.latitude, longitude: location.longitude)
        Alert.showBasicAlert(on: self, with: "Update Successfully", message: "")
    }
}
