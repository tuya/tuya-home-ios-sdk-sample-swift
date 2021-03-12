//
//  ChooseGatewayTableViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import TuyaSmartDeviceKit

protocol ZigbeeGatewayPayload {
    func didFinishSelecting(_ gateway: TuyaSmartDeviceModel?)
}

class ChooseGatewayTableViewController: UITableViewController {
    
    // MARK: - Property
    var gatewayList: [TuyaSmartDeviceModel] = []
    var home: TuyaSmartHome?
    var delegate: ZigbeeGatewayPayload?
    
    var selectedGateway: TuyaSmartDeviceModel?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getGatewayList()
        
        if selectedGateway == nil {
            selectedGateway = gatewayList.first
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.didFinishSelecting(selectedGateway)
    }
    
    // MARK: - Private method
    private func getGatewayList() {
        if Home.current != nil {
            home = TuyaSmartHome(homeId: Home.current!.homeId)
            
            guard let list = home?.deviceList else { return }
            gatewayList = list.filter { $0.deviceType == TuyaSmartDeviceModelTypeZigbeeGateway }
            
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gatewayList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "choose-gateway-cell")!
        cell.textLabel?.text = gatewayList[indexPath.row].name

        cell.accessoryType = selectedGateway == gatewayList[indexPath.row] ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        
        selectedGateway = gatewayList[indexPath.row]
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
