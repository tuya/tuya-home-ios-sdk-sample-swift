//
//  GatewayTransferController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import SnapKit

class GatewayTransferController: UIViewController {
    
    var deviceId: String
    var ids: [String]?
    
    lazy var label: UILabel = {
        let view = UILabel(frame: CGRectZero)
        view.textColor = UIColor.green
        view.textAlignment = .center
        return view
    }()
    
    lazy var manager: ThingGatewayTransferManager = {
        let manager = ThingGatewayTransferManager.init(deviceId: self.deviceId)
        return manager
    }()
    
    lazy var tableview: UITableView = {
        return UITableView(frame: CGRectZero, style: .grouped)
    }()
    
    
    init(deviceId: String) {
        self.deviceId = deviceId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.label)
        self.label.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(100)
            make.height.equalTo(30)
        }
        
        self.view.addSubview(self.tableview)
        self.tableview.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(self.label.snp.bottom)
            make.bottom.equalTo(-self.view.safeAreaInsets.bottom)
        }
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.manager.addListener(self)
        
        
        self.loadData()
    }
    
    func loadData() {
        SVProgressHUD.show()
        self.manager.deviceSupportsTransfer {[weak self] support in

            self?.manager.deviceTransferInfo(success: { info in
                if (info.status == .none) {
                    
                    self?.manager.gateways(success: { ids in
                        self?.ids = ids;
                        self?.label.text = "support"
                        SVProgressHUD.dismiss()

                    }, failure: { e in
                        self?.ids = nil;
                        
                        self?.label.text = "support"
                        SVProgressHUD.dismiss()
                    })
                    
                }else{
                    self?.label.text = "device is transferring"
                    SVProgressHUD.dismiss()
                }
            }, failure: { e in
                self?.label.text = "do not support"
                SVProgressHUD.dismiss()
            })
            
        } failure: {[weak self] e in
            self?.label.text = "do not support"
            SVProgressHUD.dismiss()
        }
    }
}

extension GatewayTransferController: ThingGatewayTransferManagerDelegate {
    func transferManager(_ manager: ThingGatewayTransferManager, statusDidUpdate model: ThingGatewayTransferInfo) {
        if (model.status == .failed || model.status == .finish) {
            SVProgressHUD.dismiss()
            self.loadData()
        }
    }
}

extension GatewayTransferController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ids != nil ? self.ids!.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = self.ids![indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.transfer(self.ids![indexPath.row])
    }
    
    func transfer(_ id: String) {
        SVProgressHUD.show()
        self.manager.transfer(fromGateway: id) { ThingGatewayTransferInfo in
            
        } failure: { e in
            
        }
    }
    
}
