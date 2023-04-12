//
//  DeviceDetailTableViewController.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartDeviceKit

class DeviceDetailTableViewController: UITableViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var deviceIDLabel: UILabel!
    @IBOutlet weak var IPAddressLabel: UILabel!
    @IBOutlet weak var MACAddressLabel: UILabel!
    @IBOutlet weak var removeDeviceButton: UIButton!
    
    // MARK: - Property
    var device: ThingSmartDevice?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        deviceIDLabel.text = device?.deviceModel.devId
        IPAddressLabel.text = device?.deviceModel.ip
        MACAddressLabel.text = device?.deviceModel.mac
    }

    // MARK: - IBAction
    @IBAction func removeDeviceTapped(_ sender: UIButton) {
        let removeAction = UIAlertAction(title: NSLocalizedString("Remove", comment: "Perform remove device action"), style: .destructive) { [weak self] (action) in
            guard let self = self else { return }
            self.device?.remove({
                guard let vc = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3] else { return }
                self.navigationController?.popToViewController(vc, animated: true)
            }, failure: { (error) in
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Remove", comment: "Failed to remove the device"), message: errorMessage)
            })
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        
        let alert = UIAlertController(title: NSLocalizedString("Remove the Device?", comment: ""), message: NSLocalizedString("If you choose to remove the device, you'll no long hold control over this device.", comment: ""), preferredStyle: .actionSheet)
        alert.addAction(removeAction)
        alert.addAction(cancelAction)
        
        alert.popoverPresentationController?.sourceView = sender
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.section == 1 else { return }
        removeDeviceButton.sendActions(for: .touchUpInside)
    }
    
}
