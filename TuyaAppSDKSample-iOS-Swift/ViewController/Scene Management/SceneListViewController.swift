//
//  SceneListViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartSceneCoreKit

class SceneListViewController: UITableViewController {
    var sceneModelList: [ThingSmartSceneModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "SceneList"
        
        fetchSceneList()
    }
    
    // MARK: - Handle
    func fetchSceneList() {
        guard let homeID = Home.current?.homeId else { return }
        SVProgressHUD.show(withStatus: "Fetch Scene List")
        ThingSmartSceneManager.sharedInstance().getSimpleSceneList(withHomeId: homeID) { [weak self] sceneModels in
            guard let self = self else { return }
            SVProgressHUD.dismiss()
            self.sceneModelList = sceneModels
            self.tableView.reloadData()
        } failure: { error in
            let errorMessage = error?.localizedDescription ?? ""
            SVProgressHUD.showError(withStatus: errorMessage)
        }
    }
    
    func deleteScene(sceneModel: ThingSmartSceneModel) {
        guard let homeID = Home.current?.homeId else { return }

        SVProgressHUD.show(withStatus: "Delete Scene")
        let scene = ThingSmartScene(sceneModel: sceneModel)
        scene?.delete(withHomeId: homeID, success: { ret in
            SVProgressHUD.showSuccess(withStatus: "Delete Successfully")
            self.fetchSceneList()
        }, failure: { error in
            let errorMessage = error?.localizedDescription ?? ""
            SVProgressHUD.showError(withStatus: errorMessage)
        })
    }
    
    func handleScene(sceneModel: ThingSmartSceneModel) {
        let scene = ThingSmartScene(sceneModel: sceneModel)
        if sceneModel.isManual() {
            scene?.execute(success: {
                SVProgressHUD.showSuccess(withStatus: "Execute Successfully")
            }, failure: { error in
                let errorMessage = error?.localizedDescription ?? ""
                SVProgressHUD.showError(withStatus: errorMessage)
            })
        } else {
            if sceneModel.enabled {
                scene?.disableScene(success: {
                    SVProgressHUD.showSuccess(withStatus: "Disable Successfully")
                    sceneModel.enabled = false
                    self.tableView.reloadData()
                }, failure: { error in
                    let errorMessage = error?.localizedDescription ?? ""
                    SVProgressHUD.showError(withStatus: errorMessage)
                })
            } else {
                scene?.enable(success: {
                    SVProgressHUD.showSuccess(withStatus: "Enable Successfully")
                    sceneModel.enabled = true
                    self.tableView.reloadData()
                }, failure: { error in
                    let errorMessage = error?.localizedDescription ?? ""
                    SVProgressHUD.showError(withStatus: errorMessage)
                })
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let sceneModel = sceneModelList?[indexPath.row] else { return }
        
        let storyboard = UIStoryboard(name: "AddScene", bundle: nil)
        let addSceneVC = storyboard.instantiateViewController(withIdentifier: "AddSceneViewController") as! AddSceneViewController
        addSceneVC.sceneModel = sceneModel
        addSceneVC.editCompletion = { [weak self] in
            guard let self = self else { return }
            self.fetchSceneList()
        }
        self.navigationController?.pushViewController(addSceneVC, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sceneModelList?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "list-cell", for: indexPath) as! SceneListCell
        if let sceneModel = sceneModelList?[indexPath.row] {
            cell.nameLabel.text = sceneModel.name
            cell.typeLabel.text = sceneModel.isManual() ? "Manu" : "Auto"
            cell.statusLabel.text = sceneModel.outOfWork == .invalid ? "Invalid" : "Valid"
            
            let title = sceneModel.isManual() ? "Execute" : (sceneModel.enabled ? "Enable" : "Disable")
            cell.otherButton.setTitle(title, for: .normal)
            cell.onTappedDeleteCompletion = { [weak self] in
                guard let self = self else { return }
                self.deleteScene(sceneModel: sceneModel)
            }
            
            cell.onTappedOtherCompletion = { [weak self] in
                guard let self = self else { return }
                self.handleScene(sceneModel: sceneModel)
            }
        }
        return cell
    }
}

