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
    var currentPrecondition: ThingSmartScenePreConditionModel?
    
    var editCompletion: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let sceneModel = self.sceneModel {
            self.title = "Edit Scene"
            self.isEditingScene = true
            self.fetchSceneDetail(sceneModel: sceneModel)

        } else {
            self.title = "Add Scene"
            sceneModel = ThingSmartSceneModel()
        }
        
        if let _ = self.navigationController {
            let barItemTitle = self.isEditingScene ? "Edit" : "Add"
            let rightButton = UIBarButtonItem(title: barItemTitle, style: .plain, target: self, action: #selector(buttonClicked))
            navigationItem.rightBarButtonItem = rightButton
        }
    }
    
    // MARK: - Request
    func fetchSceneDetail(sceneModel: ThingSmartSceneModel) -> Void {
        guard let homeID = Home.current?.homeId else { return }
        SVProgressHUD.show(withStatus: "Fetch Scene Detail")
        ThingSmartSceneManager.sharedInstance().getSceneDetail(withHomeId: homeID, sceneId: sceneModel.sceneId) { [weak self] model in
            SVProgressHUD.dismiss()
            guard let self = self else { return }
            
            self.actions = model.actions ?? []
            self.conditions = model.conditions ?? []
            self.preconditions = model.preConditions ?? []
            
            self.currentPrecondition = model.preConditions?[0]
            self.tableView.reloadData()
        } failure: { error in
            let errorMessage = error?.localizedDescription ?? ""
            SVProgressHUD.showError(withStatus: errorMessage)
        }
    }
    
    // MARK: - Handle
    @objc func buttonClicked() {
        guard let homeID = Home.current?.homeId else {
            SVProgressHUD.showError(withStatus: "HomeID is Empty")
            return
        }
        guard let name = sceneModel?.name, !name.isEmpty else {
            SVProgressHUD.showError(withStatus: "Name is Empty")
            return
        }
        guard let actions = actions, !actions.isEmpty else {
            SVProgressHUD.showError(withStatus: "Actions are not be nil")
            return
        }
        
        if let conditions = conditions, !conditions.isEmpty {
            self.sceneModel?.conditions = conditions
            if let precondition = currentPrecondition {
                sceneModel?.preConditions = [precondition]
            }
            sceneModel?.ruleGenre = .auto
        } else {
            self.sceneModel?.matchType = .any
            sceneModel?.ruleGenre = .manual
        }
        self.sceneModel?.actions = actions

        let scene = ThingSmartScene(sceneModel: sceneModel)
        
        let requestInfo = TSceneRequestInfo()
        requestInfo.sceneModel = sceneModel!
        requestInfo.needCleanGidSid = true
        
        if self.isEditingScene {
            SVProgressHUD.show(withStatus: "Editing Scene")
            scene?.edit(requestInfo, success: { sceneModel in
                SVProgressHUD.showSuccess(withStatus: "Edit Success")
                self.navigationController?.popViewController(animated: true)
                if let editCompletion = self.editCompletion {
                    editCompletion()
                }
            }, failure: { error in
                let errorMessage = error?.localizedDescription ?? ""
                SVProgressHUD.showError(withStatus: errorMessage)
            })
        } else {
            SVProgressHUD.show(withStatus: "Adding Scene")
            ThingSmartScene.add(requestInfo, homeID: homeID) { sceneModel in
                SVProgressHUD.showSuccess(withStatus: "Add Success")
                self.navigationController?.popViewController(animated: true)
            } failure: { error in
                let errorMessage = error?.localizedDescription ?? ""
                SVProgressHUD.showError(withStatus: errorMessage)
            }
        }
    }
    
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
        case .Precondition: return currentPrecondition != nil ? 2 : 1
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
            if let conditions = conditions, indexPath.row < conditions.count {
                guard let cell = cell as? SceneShowCell else { return cell }
                // condition at indexpath
                let condition = conditions[indexPath.row]
                
                var res = ""
                for firstElement in condition.expr {
                    if let dictionaryValue = firstElement as? [String: AnyObject] {
                        for (key, value) in dictionaryValue {
                            res.append("\(key): \(value),")
                        }
                    }
                    if let arrayValue = firstElement as? [AnyObject] {
                        for secondElement in arrayValue {
                            if let secondArrayValue = secondElement as? [AnyObject] {
                                for thirdElement in secondArrayValue {
                                    if let thirdArrayValue = thirdElement as? [AnyObject] {
                                        for lastElement in thirdArrayValue {
                                            if let stringElement = lastElement as? String {
                                                res.append("\(stringElement), ")
                                            }
                                        }
                                    }
                                    if let stringElement = thirdElement as? String {
                                        res.append("\(stringElement), ")
                                    }
                                }
                            }
                            
                            if let stringElement = secondElement as? String {
                                res.append("\(stringElement), ")
                            }
                        }
                    }
                    if let stringElement = firstElement as? String {
                        res.append("\(stringElement), ")
                    }
                }
                cell.detailLabel.text = "expr: \(res)"
            } else {
                let addCell = tableView.dequeueReusableCell(withIdentifier: "add-cell", for: indexPath) as! SceneAddCell
                addCell.onTappedAddCompletion = { [weak self] in
                    guard let self = self else { return }
                    self.addCondition()
                }
                return addCell
            }
        case .Action:
            if let actions = actions, indexPath.row < actions.count {
                guard let cell = cell as? SceneShowCell else { return cell }
                let action = actions[indexPath.row]
                
                var res = ""
                if let executorProperty = action.executorProperty {
                    for (key, value) in executorProperty {
                        res.append("\(key):")
                        res.append("\(value), ")
                    }
                }
                if let actionExecutor = action.actionExecutor {
                    res.append("\(actionExecutor), ")
                }
                cell.detailLabel.text = res
                
            } else {
                let addCell = tableView.dequeueReusableCell(withIdentifier: "add-cell", for: indexPath) as! SceneAddCell
                addCell.onTappedAddCompletion = { [weak self] in
                    guard let self = self else { return }
                    self.addAction()
                }
                return addCell
            }
        case .Precondition:
            if let precondition = currentPrecondition, indexPath.row < 1 {
                guard let cell = cell as? SceneShowCell else { return cell }
                
                var res = ""
                for (key, value) in precondition.expr {
                    res.append("\(key): \(value), ")
                }
                cell.detailLabel.text = res
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
            if let dpModel = featureModel.dataPoints.first {
                dpModel.selectedRow = 0
            }
            let deviceAction = ThingSmartSceneActionFactory.deviceAction(withFeature: featureModel, devId: deviceModel.devId, deviceName: deviceModel.name)
            
            self.actions?.append(deviceAction)
            self.tableView.reloadData()
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
            if let deviceCondition = ThingSmartSceneConditionFactory.createDeviceCondition(withDevice: deviceModel, dpModel: dpModel, exprModel: deviceValueExpr) {
                
                self.conditions?.append(deviceCondition)
                self.tableView.reloadData()
            }

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
        let preconditionParams = TSmartScenePreconditionParam()
        preconditionParams.sceneID = currentPrecondition?.scenarioId ?? ""
        preconditionParams.conditionID = currentPrecondition?.conditionId ?? ""
        preconditionParams.preconditionType = .allDay
        preconditionParams.cityId = "5621253"
        preconditionParams.cityName = "Hangzhou"
        preconditionParams.loops = "1111111"
        preconditionParams.timeZoneId = TimeZone.current.identifier
        
        let alldayPrecondition = ThingSmartScenePreConditionFactory.scenePrecondition(with: preconditionParams)
        
        currentPrecondition = alldayPrecondition
        self.tableView.reloadData()
    }
    
    func buildDaytimePrecondition() {
        let preconditionParams = TSmartScenePreconditionParam()
        preconditionParams.sceneID = currentPrecondition?.scenarioId ?? ""
        preconditionParams.conditionID = currentPrecondition?.conditionId ?? ""
        preconditionParams.preconditionType = .daytime
        preconditionParams.cityId = "5621253"
        preconditionParams.cityName = "Hangzhou"
        preconditionParams.loops = "1111111"
        preconditionParams.timeZoneId = TimeZone.current.identifier
        
        let daytimePrecondition = ThingSmartScenePreConditionFactory.scenePrecondition(with: preconditionParams)
        currentPrecondition = daytimePrecondition
        self.tableView.reloadData()
    }
    
    func buildNightPrecondition() {
        let preconditionParams = TSmartScenePreconditionParam()
        preconditionParams.sceneID = currentPrecondition?.scenarioId ?? ""
        preconditionParams.conditionID = currentPrecondition?.conditionId ?? ""
        preconditionParams.preconditionType = .night
        preconditionParams.cityId = "5621253"
        preconditionParams.cityName = "Hangzhou"
        preconditionParams.loops = "1111111"
        preconditionParams.timeZoneId = TimeZone.current.identifier
        
        let nightPrecondition = ThingSmartScenePreConditionFactory.scenePrecondition(with: preconditionParams)
        currentPrecondition = nightPrecondition
        self.tableView.reloadData()
    }
    
    func buildCustomPrecondition() {
        let preconditionParams = TSmartScenePreconditionParam()
        preconditionParams.sceneID = currentPrecondition?.scenarioId ?? ""
        preconditionParams.conditionID = currentPrecondition?.conditionId ?? ""
        preconditionParams.preconditionType = .custom
        preconditionParams.cityId = "5621253"
        preconditionParams.cityName = "Hangzhou"
        preconditionParams.loops = "1111111"
        preconditionParams.timeZoneId = TimeZone.current.identifier
        preconditionParams.beginDate = "07:00"
        preconditionParams.endDate = "20:00"
        
        let customPrecondition = ThingSmartScenePreConditionFactory.scenePrecondition(with: preconditionParams)
        currentPrecondition = customPrecondition
        self.tableView.reloadData()
    }
}


