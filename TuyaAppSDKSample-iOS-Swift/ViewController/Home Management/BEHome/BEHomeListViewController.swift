//
//  BEHomeListViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartFamilyBizKit

class BEHomeListViewController : UITableViewController {
    var homes : [ThingSmartHomeModel] = []
    
    override func viewWillAppear(_ animated: Bool) {
        homes = []
        ThingSmartFamilyBiz.sharedInstance().getFamilyList(success: { [weak self] homeList in
            guard let self = self else {return}
            if let homeList = homeList {
                for home in homeList {
                    switch home.dealStatus {
                    case .accept :
                        self.homes.append(home)
                    case .pending:
                        print("pending")
                    case .reject:
                        print("reject")
                    @unknown default:
                        fatalError()
                    }
                }
            }
            self.tableView.reloadData()
        }, failure: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BEHomeListCell")!
        cell.textLabel?.text = homes[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.performSegue(withIdentifier: "BEShowDetail", sender: homes[indexPath.row])
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "BEShowDetail" else { return }
        guard let model = sender as? ThingSmartHomeModel else { return }
        
        let destinationVC = segue.destination as! BEHomeDetailViewController
        destinationVC.homeModel = model
    }
}
