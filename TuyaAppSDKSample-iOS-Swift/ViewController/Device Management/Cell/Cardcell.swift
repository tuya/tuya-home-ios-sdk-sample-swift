//
//  Cardcell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartDeviceCoreKit

protocol CardCellDelegate : AnyObject {
    func clickCardView(viewModel: CardCellViewModel)
    func clickSwitchView(viewModel: CardCellViewModel, dps:Dictionary<AnyHashable, Any>)
    func clickOperableDpView(viewModel: CardCellViewModel, smartDp: ThingSmartDp)
}

class CardCellViewModel {
    var name : String!
    var icon : String!
    var device : ThingSmartDevice?
    var group : ThingSmartGroup?
    var dpParser : ThingSmartDpParser!
}

typealias OperableDpViewClickBlock = (_ viewModel :ThingSmartDp)-> Void

class OperableDpView : UIView {
    private var iconLabel : UILabel!
    private var title : UILabel!
    private var status : UILabel!
    var iconColor : UIColor?  {
        didSet{
            iconLabel.textColor = iconColor
        }
    }
    
    private var viewModel:ThingSmartDp!
    var clickBlock : OperableDpViewClickBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        iconLabel = UILabel();
        iconLabel.textAlignment = .center
        iconLabel.font = UIFont(name: "iconfont", size: 24)
        
        title = UILabel();
        title.font = UIFont.systemFont(ofSize: 15,weight: .bold)
        title.textAlignment = .center
        
        status = UILabel();
        status.font = UIFont.systemFont(ofSize: 13)
        status.textAlignment = .center
        status.textColor = UIColor.gray
        
        addSubview(iconLabel)
        addSubview(title)
        addSubview(status)
        
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        iconLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        iconLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        iconLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        title.translatesAutoresizingMaskIntoConstraints = false
        title.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 5).isActive = true
        title.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        title.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        
        status.translatesAutoresizingMaskIntoConstraints = false
        status.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        status.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        status.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                         action: #selector(clickView)))
        self.isUserInteractionEnabled = true
    }
    
    @objc private func clickView() {
        guard let cb = clickBlock else { return }
        cb(viewModel)
    }
    
    func update(viewModel:ThingSmartDp) {
        self.viewModel = viewModel
        iconLabel.text = viewModel.iconFont()
        title.text = viewModel.titleStatus
        status.text = viewModel.valueStatus
    }
}

class Cardcell: UITableViewCell {
    @IBOutlet weak var deviceCardView: UIView!
    
    @IBOutlet weak var deviceIcon: UIImageView!
    @IBOutlet weak var deviceName: UILabel!
    
    @IBOutlet weak var deviceDisplayDpStatus: UILabel!
    @IBOutlet weak var deviceDisplayDpStatusTopLayout: NSLayoutConstraint!
    
    @IBOutlet weak var deviceSwitch: UISwitch!
    @IBOutlet weak var deviceSwitchWidthLayout: NSLayoutConstraint!
    
    @IBOutlet weak var deviceOperableDpView: UIView!
    
    @IBOutlet weak var deviceOperableDpViewHeightLayout: NSLayoutConstraint!
    
    weak var cellDelegate : CardCellDelegate?
    
    private var viewModel : CardCellViewModel!
    
    static private let deviceOperableDpViewHeight : CGFloat = 95.0
    
    class func cellHeight(viewModel: CardCellViewModel) -> CGFloat {
        //一排四
        var operableDpLine = viewModel.dpParser.operableDp.count / 4
        operableDpLine += (viewModel.dpParser.operableDp.count % 4 == 0) ? 0 : 1
        
        var h = 90.0;
        if (operableDpLine > 0) {
            h += deviceOperableDpViewHeight * CGFloat(operableDpLine) + 15.0
        }
        return h
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        deviceDisplayDpStatus.font = UIFont(name: "iconfont", size: 13)
        deviceDisplayDpStatus.textColor = UIColor.gray
        deviceOperableDpView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        deviceOperableDpView.layer.cornerRadius = 5
        
        deviceCardView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                   action: #selector(clickCardView)))
        deviceCardView.isUserInteractionEnabled = true
        
        deviceSwitch.addTarget(self, action: #selector(clickSwitchView), for: .touchUpInside)
    }
    
    @objc private func clickCardView() {
        cellDelegate?.clickCardView(viewModel:viewModel)
    }
    @objc private func clickSwitchView() {
        guard let dps = viewModel.dpParser.switchDp?.publishSwitchCommands(deviceSwitch.isOn) else {
            return
        }
        cellDelegate?.clickSwitchView(viewModel:viewModel,dps: dps)
    }
    
    func update(viewModel : CardCellViewModel) {
        self.viewModel = viewModel
        deviceName.text = viewModel.name
        deviceIcon.imageFrom(urlStr: viewModel.icon)
        
        deviceSwitch.isHidden = viewModel.dpParser.switchDp == nil
        deviceSwitch.isOn = (viewModel.dpParser.switchDp != nil) ? viewModel.dpParser.switchDp!.switchStatus : false
        
        dealDisplayDpStatus()
        dealOperableDpView();
    }
    
    private func dealDisplayDpStatus() {
        var displayDpStatus = ""
        var sep = ""
        for smartDp in viewModel.dpParser.displayDp {
            if (smartDp.schemaModel.property?.type != "string") {
                displayDpStatus += sep + smartDp.iconFont() + smartDp.valueStatus
                sep = "  "
            }
        }
        deviceDisplayDpStatus.text = displayDpStatus
        deviceDisplayDpStatusTopLayout.constant = deviceDisplayDpStatus.text?.count == 0 ? 0 : 5
    }
    
    private func dealOperableDpView() {
        deviceOperableDpView.isHidden = viewModel.dpParser.operableDp.count == 0
        
        if (deviceOperableDpView.isHidden) {
            deviceOperableDpViewHeightLayout.constant = 0.0
            return
        }
        deviceOperableDpView.subviews.forEach { subView in
            subView .removeFromSuperview()
        }
        
        var topV : UIView? = nil
        var leftV : UIView? = nil
        var _l = 0
        var _c = 0
        
        
        let colors : [UIColor] = [UIColor(red: 0x60/255.0, green: 0xCE/255.0, blue: 0xFF/255.0, alpha: 1.0),
                                  UIColor(red: 0x44/255.0, green: 0xDB/255.0, blue: 0x5E/255.0, alpha: 1.0),
                                  UIColor(red: 0xFF/255.0, green: 0xAE/255.0, blue: 0x89/255.0, alpha: 1.0),
                                  UIColor(red: 0xFF/255.0, green: 0xD6/255.0, blue: 0x66/255.0, alpha: 1.0),
        ]
        
        var isOnline = true
        var isUpgrading = false
        
        if (viewModel.device != nil) {
            isOnline = viewModel.device!.deviceModel.isOnline
            
            let ota : ThingSmartDeviceOTAModel?
            ota = ThingCoreCacheService.sharedInstance().getDeviceOtaInfo(withDevId: viewModel.device!.deviceModel.devId)
            
            if (ota != nil) {
                isUpgrading = ota!.otaUpgradeStatus == ThingSmartDeviceOTAModelUpgradeStatusUpgrading
            }
        }

        var isActive = isOnline;
        if (viewModel.dpParser.switchDp != nil) {
            isActive = viewModel.dpParser.switchDp!.switchStatus || viewModel.dpParser.switchDp!.writeOnlySwitch;
        }
        
        var isItemEnable = true
        
        if (!isActive || !isOnline || isUpgrading) {
            isItemEnable = false;
        }
        
        for item  in viewModel.dpParser.operableDp {
            let oneDpView = OperableDpView()
            deviceOperableDpView.addSubview(oneDpView)
            oneDpView.update(viewModel: item)
            oneDpView.clickBlock = {[weak self] (viewModel: ThingSmartDp) in
                guard let ws = self else { return }
                ws.cellDelegate?.clickOperableDpView(viewModel: ws.viewModel, smartDp: item)
            }
            oneDpView.alpha = isItemEnable ? 1 : 0.3;
            oneDpView.iconColor = colors[_c%4]
            
            oneDpView.translatesAutoresizingMaskIntoConstraints = false
            if (topV == nil) {
                oneDpView.topAnchor.constraint(equalTo: deviceOperableDpView.topAnchor).isActive = true
            } else {
                oneDpView.topAnchor.constraint(equalTo: topV!.bottomAnchor).isActive = true
            }
            
            if (leftV == nil) {
                oneDpView.leftAnchor.constraint(equalTo: deviceOperableDpView.leftAnchor).isActive = true
            } else {
                oneDpView.leftAnchor.constraint(equalTo: leftV!.rightAnchor).isActive = true
            }
            oneDpView.heightAnchor.constraint(equalToConstant: Cardcell.deviceOperableDpViewHeight).isActive = true
            oneDpView.widthAnchor.constraint(equalTo:deviceOperableDpView.widthAnchor , multiplier: 1.0/4).isActive = true
            
            _c += 1
            leftV = oneDpView
            
            if (_c >= 4) {
                _l += 1
                _c = 0
                topV = oneDpView
                leftV = nil
            }
        }
        _l += (_c == 0) ? 0 : 1
        deviceOperableDpViewHeightLayout.constant = CGFloat(_l) * Cardcell.deviceOperableDpViewHeight
    }
}

extension ThingSmartDp {
    func iconFont() -> String {
        var rtn = CardIconFontServer.sharedInstance.iconForKey(self.iconname)
        
        if (rtn == nil) {
            rtn =  CardIconFontServer.sharedInstance.iconForKey("icon-dp_what")
        }
        
        return rtn ?? self.iconname
    }
}

extension UIImageView {
    static private var _bindUrlKey: String = "_bindUrlKey"
    static private var _urlCache: Dictionary<String, UIImage> = Dictionary()
    
    private var _bindUrl: String? {
        set {
            objc_setAssociatedObject(self, &UIImageView._bindUrlKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        
        get {
            if let rs = objc_getAssociatedObject(self, &UIImageView._bindUrlKey) as? String {
                return rs
            }
            return nil
        }
    }
    
    func imageFrom(urlStr:String?){
        if (_bindUrl == urlStr) {
            return
        }
        _bindUrl = urlStr
        image = nil;
        
        guard let _urlStr = urlStr else {
            return
        }
        let cacheImage = UIImageView._urlCache[_urlStr]
        
        if (cacheImage != nil) {
            self.image = cacheImage
            return
        }
        
        guard let url = URL(string: _urlStr) else { return }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url){
                if (self?._bindUrl != _urlStr) {
                    return
                }
                if let image = UIImage(data:data){
                    DispatchQueue.main.async{
                        UIImageView._urlCache[_urlStr] = image
                        self?.image = image
                    }
                }
            }
        }
    }
}

class CardIconFontServer {
    private lazy var jsonMap: Dictionary<String, String> = {
        guard let path = Bundle.main.path(forResource: "iconfont", ofType: "json") else {
            return [:]
        }
        
        if (!FileManager().fileExists(atPath: path)) {
            return [:]
        }
        
        guard let str = try? String(contentsOfFile: path, encoding: .utf8),
              let data = str.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) else {
            return [:]
        }
        
        return json as? Dictionary<String, String> ?? [:]
    } ()
    
    static let sharedInstance = CardIconFontServer()
    
    func iconForKey(_ key:String) -> String? {
        guard let value = jsonMap[key] else { return nil }
        var c : UInt32 = 0
        let scanner = Scanner(string: value)
        scanner.scanHexInt32(&c)
        return String(format: "%C", u_short(c));
    }
}
