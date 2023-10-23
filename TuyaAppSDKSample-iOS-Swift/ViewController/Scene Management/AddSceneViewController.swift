//
//  AddSceneViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartSceneCoreKit

class AddSceneViewController: UITableViewController {
    var sceneModel: ThingSmartSceneModel?
    var isEditingScene: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let sceneModel = sceneModel {
            self.title = "Edit Scene"
            self.isEditingScene = true
            self.fetchSceneDetail(sceneModel: sceneModel)
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
        case .Condition: return sceneModel?.conditions != nil ? sceneModel!.conditions.count + 1 : 1
        case .Action: return sceneModel?.actions != nil ? sceneModel!.actions.count + 1 : 1
        case .Precondition: return sceneModel?.preConditions != nil ? sceneModel!.preConditions.count + 1 : 1
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
        
    }
    func buildSmartAction() -> Void {
        
    }
    func buildNotificationAction() -> Void {
        
    }
    func buildDelayAction() -> Void {
        
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
    
    func buildWeatherCondition() {
        
    }
    func buildDeviceCondition() {
        
    }
    func buildTimerCondition() {
        
    }
    func buildGeofenceCondition() {
        
    }
    func buildMemberGoingHomeCondition() {
        
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
