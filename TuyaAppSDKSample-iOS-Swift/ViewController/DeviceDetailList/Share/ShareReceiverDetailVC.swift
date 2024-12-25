//
//  ShareReceiverDetailVC.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class ShareReceiverDetailVC: UITableViewController {

    var homeId: Int64
    var resType: ThingShareResType
    var resId: String
    var member:ThingSmartShareMemberModel
        
    init(homeId: Int64, resType:ThingShareResType, resId:String, member:ThingSmartShareMemberModel) {
        self.homeId = homeId
        self.resType = resType
        self.resId = resId
        self.member = member
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return  self.resType == .device ? 3 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 2) {
            return self.member.shareMode == .period ? 1 : 0
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "DeviceDetailListViewControllerReuseIdentifier")

        if (indexPath.section == 0) {
            cell.textLabel?.text = self.member.userName
            cell.detailTextLabel?.text = "\(self.member.memberId)"
        }else if (indexPath.section == 1) {
            cell.textLabel?.text = "mode"
            cell.detailTextLabel?.text = self.member.shareMode == .period ? "period" : "forever"
        }else{
            cell.textLabel?.text = "expire"
            let date = Date(timeIntervalSince1970: Double(self.member.endTime/1000))
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy-MM-dd"
            cell.detailTextLabel?.text = fmt.string(from: date)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == 1) {
            self.edit()
        }
    }
    
    func edit() {
        let mode: ThingShareValidationType = self.member.shareMode == .period ? .forever : .period
        let text = mode == .period ? "period" : "forever"

        let alertController = UIAlertController(title: nil, message: "change to \(text)?", preferredStyle: .alert)
        
        if (mode == .period) {
            let datePicker = UIDatePicker()
            datePicker.date = Date()
            alertController.view.addSubview(datePicker)
            datePicker.datePickerMode = .date
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                datePicker.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor),
                datePicker.centerYAnchor.constraint(equalTo: alertController.view.centerYAnchor),
                datePicker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 50),
                datePicker.widthAnchor.constraint(equalToConstant: 250),
                datePicker.heightAnchor.constraint(equalToConstant: 200)
            ])
            
            let confirmAction = UIAlertAction(title: "ok", style: .default) { (_) in
                let selectedDate = datePicker.date
                self.modify(mode: mode, date: Int64(selectedDate.timeIntervalSince1970 * 1000))
            }
            alertController.addAction(confirmAction)
        }else{
            let confirmAction = UIAlertAction(title: "ok", style: .default) { (_) in
                self.modify(mode: mode, date: 0)
            }
            alertController.addAction(confirmAction)
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    func modify(mode:ThingShareValidationType, date:Int64) {
        SVProgressHUD.show()
        ThingDeviceShareManager.updateShareExpirationDate(self.member.memberId, resId: self.resId, resType: self.resType, mode: mode, endTime: date) {
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: "success")
            self.member.shareMode = mode
            self.member.endTime = Int(date)
            self.tableView.reloadData()
        } failure: { e in
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: "failure")
        }
    }
    
}
