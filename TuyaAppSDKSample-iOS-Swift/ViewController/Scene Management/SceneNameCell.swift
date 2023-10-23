//
//  SceneNameCell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import Foundation

class SceneNameCell: UITableViewCell {
    @IBOutlet weak var nameTextFiled: UITextField!
    var nameDidEditedCompletion:((String)->Void)?
    
    @IBAction func editingNameDidEnd(_ sender: Any) {
        print("editingNameDidEnd")
        if let completion = nameDidEditedCompletion {
            completion(self.nameTextFiled.text ?? "")
        }
    }
    
    @IBAction func editingNameChanged(_ sender: Any) {
        print("editingNameChanged")
    }
    
    @IBAction func edtingDidExit(_ sender: Any) {
        print("edtingDidExit")
    }
}
