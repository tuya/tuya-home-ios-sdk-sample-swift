//
//  AddSceneViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartSceneCoreKit
import ThingSmartDeviceCoreKit

class AddSceneViewController: UITableViewController {
    var sceneModel: ThingSmartSceneModel?
    var isEditingScene: Bool = false
    
    var actions: [ThingSmartSceneActionModel]? = []
    var conditions: [ThingSmartSceneConditionModel]? = []
    var preconditions: [ThingSmartScenePreConditionModel]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let sceneModel = sceneModel {
            self.title = "Edit Scene"
            self.isEditingScene = true
            self.fetchSceneDetail(sceneModel: sceneModel)
            self.actions = sceneModel.actions
            self.conditions = sceneModel.conditions
            self.preconditions = sceneModel.preConditions
        } else {
            self.title = "Add Scene"
            sceneModel = ThingSmartSceneModel()
        }
    }
    
    // MARK: - Request
    func fetchSceneDetail(sceneModel: ThingSmartSceneModel) -> Void {
        guard let homeID = Home.current?.homeId else { return }
        SVProgressHUD.show(withStatus: "Fetch Scene Detail")
        ThingSmartSceneManager.sharedInstance().getSceneDetail(withHomeId: homeID, sceneId: sceneModel.sceneId) { [weak self] model in
            SVProgressHUD.dismiss()
            guard let self = self else { return }
            self.tableView.reloadData()
        } failure: { error in
            let errorMessage = error?.localizedDescription ?? ""
            SVProgressHUD.showError(withStatus: errorMessage)
        }
    }
    
    // MARK: - Handle
    
    func changeConditionType() {
        let alertController = UIAlertController(title: "Select Condition Type", message: "", preferredStyle: .actionSheet)
        let allAction = UIAlertAction(title: "When all conditions are met", style: .default) { action in
            self.sceneModel?.matchType = .all
            self.tableView.reloadData()
        }
        let anyAction = UIAlertAction(title: "When either condition is met", style: .default) { action in
            self.sceneModel?.matchType = .any
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(allAction)
        alertController.addAction(anyAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 0 {
            changeConditionType()
        }
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SectionType(rawValue: section) {
        case .Name, .Match: return 1
        case .Condition: return conditions != nil ? conditions!.count + 1 : 1
        case .Action: return actions != nil ? actions!.count + 1 : 1
        case .Precondition: return preconditions != nil ? preconditions!.count + 1 : 1
        case .none:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SectionType(rawValue: section)?.headerTitle() ?? "Unknow"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SectionType(rawValue: indexPath.section)?.cellIdentifier() ?? "add-cell", for: indexPath) as UITableViewCell
        switch SectionType(rawValue: indexPath.section) {
        case .Name:
            if let cell = cell as? SceneNameCell {
                cell.nameTextFiled.text = sceneModel?.name
                cell.nameDidEditedCompletion = {[weak self] in
                    guard let self = self else { return }
                    self.sceneModel?.name = $0
                }
            }
        case .Match:
            if let cell = cell as? SceneTypeCell {
                cell.showLabel.text = "Condition Type"
                cell.detailLabel.text = sceneModel?.matchType == .all ? "When all conditions are met" : "When either condition is met"
            }
        case .Condition:
            if let conditions = sceneModel?.conditions, indexPath.row < conditions.count {
                guard let cell = cell as? SceneShowCell else {
                    return cell
                }
            } else {
                let addCell = tableView.dequeueReusableCell(withIdentifier: "add-cell", for: indexPath) as! SceneAddCell
                addCell.onTappedAddCompletion = { [weak self] in
                    guard let self = self else { return }
                    self.addCondition()
                }
                return addCell
            }
        case .Action:
            if let actions = sceneModel?.actions, indexPath.row < actions.count {
                guard let cell = cell as? SceneShowCell else {
                    return cell
                }
            } else {
                let addCell = tableView.dequeueReusableCell(withIdentifier: "add-cell", for: indexPath) as! SceneAddCell
                addCell.onTappedAddCompletion = { [weak self] in
                    guard let self = self else { return }
                    self.addAction()
                }
                return addCell
            }
        case .Precondition:
            if let preConditions = sceneModel?.preConditions, indexPath.row < preConditions.count {
                guard let cell = cell as? SceneShowCell else { return cell }
            } else {
                let addCell = tableView.dequeueReusableCell(withIdentifier: "add-cell", for: indexPath) as! SceneAddCell
                addCell.onTappedAddCompletion = { [weak self] in
                    guard let self = self else { return }
                    self.addPrecondition()
                }
                return addCell
            }
        case .none:
            return cell

        }
        return cell
    }
    
    // MARK: - Action
    func addAction() {
        let alertController = UIAlertController(title: "Select Action", message: "", preferredStyle: .actionSheet)
        let deviceA = UIAlertAction(title: "Select Device", style: .default) { action in
            self.buildDeviceAction()
        }
        let smartA = UIAlertAction(title: "Select Smart", style: .default) { action in
            self.buildSmartAction()
        }
        let notificationA = UIAlertAction(title: "Select Notification", style: .default) { action in
            self.buildNotificationAction()
        }
        let delayA = UIAlertAction(title: "Select Delay", style: .default) { action in
            self.buildDelayAction()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(deviceA)
        alertController.addAction(smartA)
        alertController.addAction(notificationA)
        alertController.addAction(delayA)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true)
    }
    
    func buildDeviceAction() -> Void {
        guard let deviceModel = ThingSmartDevice(deviceId: "vdevo169804274554735")?.deviceModel else {
            return
        }
        
        ThingSmartSceneManager.sharedInstance().getNewActionDeviceDPList(withDevId: "vdevo169804274554735") { featureModels in
            let featureModel = featureModels[0]
            let deviceAction = ThingSmartSceneActionFactory.deviceAction(withFeature: featureModel, devId: deviceModel.devId, deviceName: deviceModel.name)
        } failure: { error in
            let errorMessage = error?.localizedDescription ?? ""
            SVProgressHUD.showError(withStatus: errorMessage)
        }
    }
    
    func buildSmartAction() -> Void {
        let selectTapToRunAction = ThingSmartSceneActionFactory.createTriggerSceneAction(withSceneId: "95DRMY8qcCNJ9q1K", sceneName: "测试呀")
        
        let automationAction = ThingSmartSceneActionFactory.createSwitchAutoAction(withSceneId: "l7LQXCgId7zPvzNC", sceneName: "测试生效时间段", type: AutoSwitchType(rawValue: 0)!)
        
        self.actions?.append(selectTapToRunAction)
        self.actions?.append(automationAction)
        
        self.tableView.reloadData()
    }
    
    func buildNotificationAction() -> Void {
        let notificaitonAction = ThingSmartSceneActionFactory.createSendNotificationAction()
        self.actions?.append(notificaitonAction)
        self.tableView.reloadData()
    }
    
    func buildDelayAction() -> Void {
        let delayAction = ThingSmartSceneActionFactory.createDelayAction(withHours: "0", minutes: "0", seconds: "60")
        self.actions?.append(delayAction)
        self.tableView.reloadData()

    }
    
    // MARK: - Condition
    func addCondition() {
        let alertController = UIAlertController(title: "Select Condition", message: "", preferredStyle: .actionSheet)
        let weatherC = UIAlertAction(title: "Select Weather", style: .default) { action in
            self.buildWeatherCondition()
        }
        let deviceC = UIAlertAction(title: "Select Device", style: .default) { action in
            self.buildDeviceCondition()
        }
        let scheducleC = UIAlertAction(title: "Select Timer", style: .default) { action in
            self.buildTimerCondition()
        }
        let geofenceC = UIAlertAction(title: "Select Geofence", style: .default) { action in
            self.buildGeofenceCondition()
        }
        let memberGohomeC = UIAlertAction(title: "Select Member Going Home", style: .default) { action in
            self.buildMemberGoingHomeCondition()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(weatherC)
        alertController.addAction(deviceC)
        alertController.addAction(scheducleC)
        alertController.addAction(geofenceC)
        alertController.addAction(memberGohomeC)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true)
    }
    
    func getCityModel() -> ThingSmartCityModel {
        let cityModel = ThingSmartCityModel()
        cityModel.cityId = 5621253
        cityModel.city = "Hangzhou"
        return cityModel
    }
    
    func buildWeatherCondition() {
        guard let homeID = Home.current?.homeId else {return}
        
        let categoryListRequestParams = TSceneConditionCategoryListRequestParams()
        categoryListRequestParams.showFahrenheit = true
        categoryListRequestParams.condAbility = 6
        
        // Fetch weather condition list
        ThingSmartSceneManager.sharedInstance().getConditionCategoryListWihtHomeId(homeID, conditionCategoryParams: categoryListRequestParams) { categoryListModel in
//            let devConditions = categoryListModel?.devConditions
            let envConditions = categoryListModel?.envConditions
        
            if let weatherDPModel = envConditions?[1] {
                let weatherExpr = ThingSmartSceneConditionExprBuilder.createEnumExpr(withType: weatherDPModel.entitySubId, chooseValue: "comfort", exprType: .whether)
                let cityModel = self.getCityModel()
                let weatherCondition = ThingSmartSceneConditionFactory.createWhetherCondition(withCity: cityModel, dpModel: weatherDPModel, exprModel: weatherExpr)!

                self.conditions?.append(weatherCondition)
                self.tableView.reloadData()
            }
        } failure: { error in
            let errorMessage = error?.localizedDescription ?? ""
            SVProgressHUD.showError(withStatus: errorMessage)
        }
    }
    
    func buildDeviceCondition() {
        let deviceModel = ThingSmartDevice(deviceId: "vdevo169804274554735")?.deviceModel
        ThingSmartSceneManager.sharedInstance().getCondicationDeviceDPList(withDevId: "vdevo169804274554735") { dpModels in
            let dpModel = dpModels[0]
            dpModel.selectedRow = 0
            
            let deviceValueExpr = ThingSmartSceneConditionExprBuilder.createValueExpr(withType: dpModel.entitySubId, operater: "==", chooseValue: 1000, exprType: .device)
            let deviceCondition = ThingSmartSceneConditionFactory.createDeviceCondition(withDevice: deviceModel, dpModel: dpModel, exprModel: deviceValueExpr)!
            
            self.conditions?.append(deviceCondition)
            self.tableView.reloadData()
        } failure: { error in
            let errorMessage = error?.localizedDescription ?? ""
            SVProgressHUD.showError(withStatus: errorMessage)
        }
    }
    
    func buildTimerCondition() {
        let timeExpr = ThingSmartSceneConditionExprBuilder.createTimerExpr(withTimeZoneId: NSTimeZone.default.identifier, loops: "1111111", date: "20231010", time: "20:30")
        let timerCondition = ThingSmartSceneConditionFactory.createTimerCondition(with: timeExpr)!
        self.conditions?.append(timerCondition)
        self.tableView.reloadData()
    }
    
    func buildGeofenceCondition() {
        let geofenceCondition = ThingSmartSceneConditionFactory.createGeoFenceCondition(withGeoType: .reach, geoLati: 30.30288959184809, geoLonti: 120.0640840491766, geoRadius: 100, geoTitle: "HUACE Film")!
        self.conditions?.append(geofenceCondition)
        self.tableView.reloadData()
    }
    
    func buildMemberGoingHomeCondition() {
        let memberGoingHomeCondition = ThingSmartSceneConditionFactory.memberBackHomeCondition(withDevId: "vdevo155919804483178", entitySubIds: "1,2,3,4,5,6,7", memberIds: "id1,id2,id3", memberNames: "name1,name2,name3")!
        self.conditions?.append(memberGoingHomeCondition)
        self.tableView.reloadData()
    }
    
    // MARK: - Precondition
    func addPrecondition() {
        let alertController = UIAlertController(title: "Select Precondition", message: "", preferredStyle: .actionSheet)
        let alldayP = UIAlertAction(title: "Select Allday", style: .default) { action in
            self.buildAlldayPrecondition()
        }
        let daytimeP = UIAlertAction(title: "Select Daytime", style: .default) { action in
            self.buildDaytimePrecondition()
        }
        let nightP = UIAlertAction(title: "Select Night", style: .default) { action in
            self.buildNightPrecondition()
        }
        let customP = UIAlertAction(title: "Select Custom", style: .default) { action in
            self.buildCustomPrecondition()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(alldayP)
        alertController.addAction(daytimeP)
        alertController.addAction(nightP)
        alertController.addAction(customP)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true)
    }
    
    func buildAlldayPrecondition() {
        
    }
    func buildDaytimePrecondition() {
        
    }
    func buildNightPrecondition() {
        
    }
    func buildCustomPrecondition() {
        
    }
}

enum SectionType: Int {
    case Name = 0
    case Match
    case Condition
    case Action
    case Precondition
    
    func headerTitle() -> String {
        switch self {
        case .Name: return "Name"
        case .Match: return "Condition Type"
        case .Condition: return "Condition"
        case .Action: return "Action"
        case .Precondition: return "Precondition"
        }
    }
    
    func cellIdentifier()->String {
        switch self {
        case .Name: return "name-cell"
        case .Match: return "type-cell"
        case .Condition: return "condition-cell"
        case .Action: return "condition-cell"
        case .Precondition: return "condition-cell"
        }
    }
}
