//
//  BEHomeDetailViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartFamilyBizKit

class BEHomeDetailViewController : UITableViewController {
    var homeModel : ThingSmartHomeModel?

    @IBOutlet weak var homeIdLabel : UILabel!
    @IBOutlet weak var homeNameLabel : UILabel!
    @IBOutlet weak var homeCityLabel : UILabel!
    @IBOutlet weak var weatherLabel : UILabel!
    @IBOutlet weak var tempLabel : UILabel!
    
    override func viewDidLoad() {
        ThingSmartFamilyBiz.sharedInstance().addObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "BEShowEditHome" else { return }

        let destinationVC = segue.destination as! BEEditHomeViewController
        destinationVC.home = homeModel
    }
    
    func setupUI() {
        homeIdLabel.text = String(homeModel!.homeId)
        homeNameLabel.text = homeModel?.name ?? ""
        homeCityLabel.text = homeModel?.geoName ?? ""
        
        ThingSmartFamilyBiz.sharedInstance().getHomeWeatherSketch(withHomeId: homeModel!.homeId) { [weak self] weather in
            guard let self = self else { return }
            self.weatherLabel.text = weather!.condition
            self.tempLabel.text = weather!.temp
        } failure: {[weak self] error in
            guard let self = self else { return }
            let errorMessage = error?.localizedDescription ?? ""
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Fetch Weather", comment: ""), message: errorMessage)
        }
    }
}

extension BEHomeDetailViewController : ThingSmartFamilyBizDelegate {
    func familyBiz(_ familyBiz: ThingSmartFamilyBiz!, didUpdateHome homeModel: ThingSmartHomeModel!) {
        if let home = homeModel {
            self.homeModel = home
            setupUI()
        }
    }
}
