//
//  RemoteLaunch.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class RemoteLaunchVC: UITableViewController {

    var deviceId: String
    var manager: ThingDeviceRebootManager

    var support: Bool = false
    var timer: ThingDeviceRebootTimer?

    init(deviceId: String) {
        self.deviceId = deviceId
        self.manager = ThingDeviceRebootManager(deviceId: deviceId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpNavigationItem() {
        let title = "添加定时重启"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(add))
    }
    
    @objc func add() {
        
        let timer = ThingDeviceRebootTimer()
        timer.time = "12:30"
        timer.status = true
        timer.loops = "0000000" //周日-周六，第一位表示周日，第二位周一，以此类推，0表示不重复，1表示重复，如：0000000表示只执行一次，1111111表示每天执行
        
        SVProgressHUD.show()
        self.manager.add(timer) { tid in
            timer.tid = tid
            SVProgressHUD.dismiss()
            self.timer = timer
            self.reloadView()
        } failure: { error in
            SVProgressHUD.dismiss()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.setUpNavigationItem()

        self.loadData()
    }
    
    func loadData() {
        SVProgressHUD.show()
        self.manager.supportRebootSuccess { support in
            self.support = support
            if (support) {
                self.manager.getTimerSuccess { timer in
                    SVProgressHUD.dismiss()
                    self.timer = timer
                    self.reloadView()
                } failure: { error in
                    SVProgressHUD.dismiss()
                    self.reloadView()

                }
            }else{
                SVProgressHUD.dismiss()
                self.reloadView()
            }
            
        } failure: { error in
            self.support = false
            SVProgressHUD.dismiss()
        }
    }
    
    func reloadView() {
        self.tableView.reloadData()
    }
    
    
    func handle(timer: ThingDeviceRebootTimer) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "更新", style: .default, handler: { action in
            self.update(timer: timer)
        }))

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func update(timer: ThingDeviceRebootTimer) {
        timer.status = !timer.status
        SVProgressHUD.show()
        self.manager.update(timer) {
            self.reloadView()
            SVProgressHUD.dismiss()
        } failure: { error in
            timer.status = !timer.status
            SVProgressHUD.dismiss()
        }
    }
    
    
    func reboot() {
        SVProgressHUD.show()
        self.manager.rebootImmediatelySuccess {
            SVProgressHUD.dismiss()
        } failure: { error in
            SVProgressHUD.dismiss()
        }

    }
}

extension RemoteLaunchVC  {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "RemoteLaunchVCReuseIdentifier")

        if (indexPath.section == 0) {
            cell.textLabel?.text = "support remote reboot or not?"
            cell.detailTextLabel?.text = self.support ? "support" : "unsupport"

        }
        
        if (indexPath.section == 1) {
            cell.textLabel?.text = "reboot now"
            cell.detailTextLabel?.text = self.support ? "support" : "unsupport"
        }
        
        if (indexPath.section == 2) {
            cell.textLabel?.text = "reboot timer"
            cell.detailTextLabel?.text = self.timer != nil ? (self.timer!.status ? self.timer?.time : "closed") : "no timer"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == 1 && self.support) {
            self.reboot()
        }
        
        if (indexPath.section == 2 && self.timer != nil) {
            self.handle(timer: self.timer!)
        }
        
    }
}
