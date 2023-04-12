//
//  SwitchHomeTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartDeviceKit

class SwitchHomeTableViewController: UITableViewController {
    
    // MARK: - Property
    private let homeManager = ThingSmartHomeManager()
    private var homeList = [ThingSmartHomeModel]()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        homeManager.getHomeList { [weak self] (homeModels) in
            guard let self = self else { return }
            self.homeList = homeModels ?? []
            self.tableView.reloadData()
        } failure: { [weak self] (error) in
            guard let self = self else { return }
            let errorMessage = error?.localizedDescription ?? ""
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Add New Home", comment: ""), message: errorMessage)
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "switch-home-cell")!
        cell.textLabel?.text = homeList[indexPath.row].name
        
        if Home.current?.homeId == homeList[indexPath.row].homeId {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard Home.current?.homeId != homeList[indexPath.row].homeId  else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        Home.current = homeList[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
