//
//  CameraMessageImageDownloader.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import ThingEncryptImage
import Photos

class CameraMessageImageDownloader {
    static let shared = CameraMessageImageDownloader()
    
    private var assetCollection: PHAssetCollection? = nil

    private init() {}
    
    func download(with attachPic: String) {
        let components = attachPic.components(separatedBy: "@")
        var imagePath: String
        var encryptKey: String?
        
        if components.count == 2 {
            imagePath = components[0]
            encryptKey = components[1]
        } else {
            imagePath = attachPic
        }

        SVProgressHUD.setStatus(IPCLocalizedString(key: "ipc_detect_image_downloading_text"))
        ThingEncryptImageDownloader.sharedManager().downloadEncryptImage(
            withPath: imagePath,
            encryptKey: encryptKey
        ) { [weak self] image, _, _, _, error in
            if let image {
                SVProgressHUD.showSuccess(withStatus: IPCLocalizedString(key: "ipc_cloud_download_complete"))
                self?.saveImage(image)
                return
            }

            if error != nil {
                SVProgressHUD.showError(withStatus: IPCLocalizedString(key: "ipc_cloud_download_failed"))
            }
        }
    }
    
    private func saveImage(_ image: UIImage) {
        requetPermissionIfNeeded { [weak self] in
            self?.addToPhotoLibrary(image)
        }
    }
    
    private func requetPermissionIfNeeded(onAccept: @escaping () -> Void) {
        if CameraPermissionUtil.isPhotoLibraryDenied {
            CameraPermissionUtil.requestPhotoPermission { result in
                guard result else { return }
                onAccept()
            }
            return
        }
        
        if CameraPermissionUtil.isPhotoLibraryDenied {
            SVProgressHUD.showError(withStatus: IPCLocalizedString(key: "Photo library permission denied"))
            return
        }
        onAccept()
    }
    
    private func addToPhotoLibrary(_ image: UIImage) {
        guard let assetCollection = currentAppAssetCollection() else { return }
        var placeHolder: PHObjectPlaceholder?

        do {
            try PHPhotoLibrary.shared().performChangesAndWait {
                placeHolder = PHAssetChangeRequest.creationRequestForAsset(from: image).placeholderForCreatedAsset
            }
            
            try PHPhotoLibrary.shared().performChangesAndWait {
                let request = PHAssetCollectionChangeRequest(for: assetCollection)
                request?.insertAssets([placeHolder] as NSFastEnumeration, at: NSIndexSet(index: 0) as IndexSet)
            }
        } catch {
            
        }
    }
    
    private func currentAppAssetCollection() -> PHAssetCollection? {
        if let assetCollection { return assetCollection }
        
        let title = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "DemoAppAlbum"
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        
        collections.enumerateObjects { collection, idx, stop in
            if title == collection.localizedTitle {
                self.assetCollection = collection
                stop.pointee = true
            }
        }
        
        if assetCollection == nil {
            do {
                try PHPhotoLibrary.shared().performChangesAndWait { [weak self] in
                    let retCollectionID = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title).placeholderForCreatedAssetCollection.localIdentifier
                    
                    self?.assetCollection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [retCollectionID], options: nil).firstObject
                }
            } catch {
                
            }
        }
        
        return assetCollection
    }
}
