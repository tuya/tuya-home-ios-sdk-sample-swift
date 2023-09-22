//
//  DeviceDetailKitVC.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class DeviceDetailKitVC: DeviceListBaseVC {

    override func handle(index: Int) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if (self.isGroup) {
            if (index >= home.groupList.count) {return}
            let group = self.home.groupList[index]

            alert.addAction(UIAlertAction(title: "定时", style: .default, handler: { action in
                let vc = DeviceDetailKitTimerVC(bizId: group.groupId, isGroup: true)
                self.navigationController?.pushViewController(vc, animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "编辑群组", style: .default, handler: { action in
                self.editGroup(with: group)
            }))
            
            alert.addAction(UIAlertAction(title: "删除群组", style: .default, handler: { action in
                self.deleteGroup(with: group)
            }))
            
                        
        }else{
            if (index >= home.deviceList.count) {return}
            let device = self.home.deviceList[index]
            
            alert.addAction(UIAlertAction(title: "设备信息", style: .default, handler: { action in
                let vc = DeviceDetailKitInfoVC(deviceId: device.devId)
                self.navigationController?.pushViewController(vc, animated: true)
            }))
            
            
            alert.addAction(UIAlertAction(title: "定时", style: .default, handler: { action in
                let vc = DeviceDetailKitTimerVC(bizId: device.devId, isGroup: false)
                self.navigationController?.pushViewController(vc, animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "创建群组", style: .default, handler: { action in
                self.createGroup(with: device)
            }))
            
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        self.present(alert, animated: true)
    }
    
    
    var service: ThingGroupServiceProtocol?
    func createGroup(with device: ThingSmartDeviceModel) {
        //根据设备id查询群组类型
        let groupType = ThingGroupMakerHelper.groupBizType(fromDeviceId: device.devId)

        //根据群组类型构建参数
        var params: [AnyHashable: AnyObject] = [:]
        params["devId"] = device.devId! as AnyObject

        if (groupType == .bleMesh || groupType == .sigMesh || groupType == .beacon) {
            let impl = ThingModule.service(ofOptionalProtocol: ThingBusinessGroupProtocol.self) as? ThingBusinessGroupProtocol
            let deviceList = impl?.deviceListForCurrentSpace() ?? []
            params["deviceList"] = deviceList as AnyObject
        }


        // 创建服务
        self.service = ThingGroupServiceMaker.groupServiceMaker(withBuildQuery: params)
        
        
        SVProgressHUD.show()
        //获取群组下符合条件的设备列表
        self.service?.fetchDeviceList?(success: { list in
            
            guard let listIds = list?.compactMap({ return $0.devId }) else {
                SVProgressHUD.dismiss()
                return
            }
            
            self.service?.createGroup?(withName: "My group Name", deviceList: listIds, process: { process in
                
            }, success: { groupId in
                SVProgressHUD.dismiss()
                return
            }, failure: { e in
                SVProgressHUD.dismiss()
                return
            })
            
        }, failure: { e in
            SVProgressHUD.dismiss()
            return
        })
    }
    
    
    func editGroup(with group: ThingSmartGroupModel) {
        //根据群组id查询群组类型
        let groupType = ThingGroupMakerHelper.groupBizType(fromDeviceId: group.groupId)

        //根据群组类型构建参数
        var params: [AnyHashable: AnyObject] = [:]
        params["groupId"] = group.groupId! as AnyObject

        if (groupType == .bleMesh || groupType == .sigMesh || groupType == .beacon) {
            let impl = ThingModule.service(ofOptionalProtocol: ThingBusinessGroupProtocol.self) as? ThingBusinessGroupProtocol
            let deviceList = impl?.deviceListForCurrentSpace() ?? []
            params["deviceList"] = deviceList as AnyObject
        }
        
        
        // 创建服务
        self.service = ThingGroupServiceMaker.groupServiceMaker(withBuildQuery: params)
        
        SVProgressHUD.show()
        //获取群组下符合条件的设备列表
        self.service?.fetchDeviceList?(success: { list in
            
            guard let listIds = list?.compactMap({ return $0.devId }) else {
                SVProgressHUD.dismiss()
                return
            }
            
            
            //更新群组设备
            self.service?.updateGroup?(withDeviceList: listIds, process: { process in
                
            }, success: { groupId in
                SVProgressHUD.dismiss()
                return
            }, failure: { e in
                SVProgressHUD.dismiss()
                return
            })
            
        }, failure: { e in
            SVProgressHUD.dismiss()
            return
        })
    }
    
    
    func deleteGroup(with group: ThingSmartGroupModel) {
        //根据群组id查询群组类型
        let groupType = ThingGroupMakerHelper.groupBizType(fromDeviceId: group.groupId)

        //根据群组类型构建参数
        var params: [AnyHashable: AnyObject] = [:]
        params["groupId"] = group.groupId! as AnyObject

        if (groupType == .bleMesh || groupType == .sigMesh || groupType == .beacon) {
            let impl = ThingModule.service(ofOptionalProtocol: ThingBusinessGroupProtocol.self) as? ThingBusinessGroupProtocol
            let deviceList = impl?.deviceListForCurrentSpace() ?? []
            params["deviceList"] = deviceList as AnyObject
        }
        
        
        // 创建服务
        self.service = ThingGroupServiceMaker.groupServiceMaker(withBuildQuery: params)
        
        SVProgressHUD.show()
        self.service?.removeGroup?(withGroupId: group.groupId, success: {
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
            return
        }, failure: { e in
            SVProgressHUD.dismiss()
            return
        })
    }
    
}
