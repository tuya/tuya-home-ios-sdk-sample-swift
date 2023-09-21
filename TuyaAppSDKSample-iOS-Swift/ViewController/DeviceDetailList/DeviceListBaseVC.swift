//
//  DeviceListBaseVC.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class DeviceListBaseVC: UITableViewController {

    var home: ThingSmartHome
    var isGroup: Bool = false
    
    init(home: ThingSmartHome) {
        self.home = home
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.white
            self.navigationController?.navigationBar.standardAppearance = appearance;
            self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        } else {
            // Fallback on earlier versions
        }

        
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DeviceDetailListViewControllerReuseIdentifier")
        home.delegate = self
        updateHomeDetail()
        self.setUpNavigationItem()
        ThingSmartBizCore.sharedInstance().registerService(ThingDeviceDetailExternalProtocol.self, withInstance: self)
//        ThingSmartBizCore.sharedInstance().registerService(ThingFamilyProtocol.self, withInstance: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.alpha = 1
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationItem.hidesBackButton = false
        self.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.backItem?.hidesBackButton = false
    }
    
    // MARK: - Private method
    private func updateHomeDetail() {
        home.getDataWithSuccess({ (model) in
            self.tableView.reloadData()
        }, failure: { [weak self] (error) in
            guard let self = self else { return }
            let errorMessage = error?.localizedDescription ?? ""
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Fetch Home", comment: ""), message: errorMessage)
        })
    }
    

    func setUpNavigationItem() {
        let title = self.isGroup ? "设备" : "群组"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(typeChange))
    }
    
    @objc func typeChange() {
        self.isGroup = !self.isGroup;
        self.setUpNavigationItem()
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isGroup ? self.home.groupList.count : self.home.deviceList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "DeviceDetailListViewControllerReuseIdentifier")

        let title = self.isGroup ? self.home.groupList[indexPath.row].name : self.home.deviceList[indexPath.row].name
        cell.textLabel?.text = title
        
        cell.detailTextLabel?.text = self.isGroup ? "" : (self.home.deviceList[indexPath.row].isOnline ? NSLocalizedString("Online", comment: "") : NSLocalizedString("Offline", comment: ""))        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.handle(index: indexPath.row)
    }

    func handle(index: Int) {}
    
}


extension DeviceListBaseVC: ThingSmartHomeDelegate {
    func homeDidUpdateInfo(_ home: ThingSmartHome!) {
        tableView.reloadData()
    }
    
    func home(_ home: ThingSmartHome!, didAddDeivice device: ThingSmartDeviceModel!) {
        tableView.reloadData()
    }
    
    func home(_ home: ThingSmartHome!, didRemoveDeivice devId: String!) {
        tableView.reloadData()
    }
    
    func home(_ home: ThingSmartHome!, deviceInfoUpdate device: ThingSmartDeviceModel!) {
        tableView.reloadData()
    }
    
    func home(_ home: ThingSmartHome!, device: ThingSmartDeviceModel!, dpsUpdate dps: [AnyHashable : Any]!) {
        tableView.reloadData()
    }
}


extension DeviceListBaseVC: ThingFamilyProtocol {
    
    func getCurrentHome() -> ThingSmartHome {
        return self.home
    }
    
    func currentFamilyId() -> Int64 {
        return self.home.homeId
    }
    
    func checkAdminAndRightLimit(_ alert: Bool) -> Bool {
        return true
    }
}
