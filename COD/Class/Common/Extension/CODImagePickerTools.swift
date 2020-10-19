//
//  CODImagePickerTools.swift
//  COD
//
//  Created by Sim Tsai on 2020/1/6.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import SwiftyJSON

class CODImagePickerTools: NSObject {
    
    static let `defualt` = CODImagePickerTools()
    
    var avatarID: String?
    private var cropImage: UIImage?
    private var isnNeedCrop: Bool = false
    private var roomID: String?
    
    var fetchImage: ((UIImage) -> ())?
    var fetchImageID: ((String) -> ())?
    var chooseImage: ((UIImage) -> ())?
    
    
    func showPhotoWay(roomID: String?, fetchImage: ((UIImage) -> ())? = nil, fetchImageID: ((String) -> ())? = nil) {
        
        self.roomID = roomID
        
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "拍照", style: UIAlertAction.Style.default){ [weak self] (action:UIAlertAction)in
            self?.initCameraPicker()
        }
        let photoAction = UIAlertAction(title: "从相册中选择", style: UIAlertAction.Style.default){ [weak self] (action:UIAlertAction)in
            self?.initPhotoPicker()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel){ (action:UIAlertAction)in
        }
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoAction)
        actionSheet.addAction(cancelAction)
        
        UIViewController.current()?.present(actionSheet, animated: true, completion: nil)
        
        self.fetchImage = fetchImage
        self.fetchImageID = fetchImageID
        
    }
    
    func showPhotoPicker(chooseImage: ((UIImage) -> ())? = nil) {
        
        self.chooseImage = chooseImage
        
        let tzImgPicker = TZImagePickerController(maxImagesCount: 1, delegate: self)
        tzImgPicker?.isSelectOriginalPhoto = false
        tzImgPicker?.allowPreview = false
        tzImgPicker?.allowTakePicture = false
        tzImgPicker?.allowTakeVideo  = false
        tzImgPicker?.allowCameraLocation = false
        tzImgPicker?.allowPickingVideo = false
        tzImgPicker?.allowPickingGif = false
        tzImgPicker?.showSelectedIndex = false
        tzImgPicker?.showPhotoCannotSelectLayer = true
        tzImgPicker?.delegate = self
        //        tzImgPicker?.statusBarStyle = false
        tzImgPicker?.naviBgColor = UIColor.black
        tzImgPicker?.naviTitleColor = UIColor.white
        //        tzImgPicker?.iconThemeColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1)
        tzImgPicker?.iconThemeColor = UIColor.init(hexString: "007EE5")
        tzImgPicker?.oKButtonTitleColorNormal = UIColor.init(hexString: "007EE5")
        tzImgPicker?.oKButtonTitleColorDisabled = UIColor.init(hexString: "007EE5")?.withAlphaComponent(0.5)
        tzImgPicker?.photoSelImage = UIImage.init(named: "person_selected")
        tzImgPicker?.photoOriginSelImage = UIImage.init(named: "person_selected")
        tzImgPicker?.cancelBtnTitleStr = NSLocalizedString("取消  ", comment: "")
        UIViewController.current()?.present(tzImgPicker ?? UIViewController.init(), animated: true, completion: nil)
    
    
    }
    
    func showCameraPicker(chooseImage: ((UIImage) -> ())? = nil) {
        
        self.chooseImage = chooseImage
        
        if !self.checkAuth() {
            return
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let  cameraPicker = UIImagePickerController()
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = false
            cameraPicker.sourceType = .camera
            //在需要的地方present出来
            UIViewController.current()?.present(cameraPicker, animated: true, completion: nil)
        } else {
            
            print("不支持拍照")
            
        }
        
    }
        
    //从相册中选择
    func initPhotoPicker(){
        
        showPhotoPicker()
        
    }
    
    //拍照
    func initCameraPicker(){
        
        showCameraPicker()
        
    }

    
    //裁剪
    func cropImage(image: UIImage){
        
        let cropVC = CODCropViewController()
        cropVC.isRound = false
        cropVC.targetImage = image
        cropVC.delegate = self
        
        UIViewController.current()?.navigationController?.pushViewController(cropVC)
        
    }
    
    func checkAuth() -> Bool {
        
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .notDetermined {
            self.checkCameraPermission()
        } else if authStatus == .restricted || authStatus == .denied {
            CODAlertViewToSetting_show("无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限" )
        } else if authStatus == .authorized {
            return true
        }
        return false
        
    }
    
    func checkCameraPermission () {
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {granted in
            if !granted {
                
                DispatchQueue.main.async {
                    CODAlertViewToSetting_show("无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限" )
                }
                
            }
        })
        
    }
    
}


extension CODImagePickerTools:UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate,CODCropViewControllerDelegate{
    
    func CODClipImageDidCancel() {
        
    }
    
    func CODClipImageClipping(image: UIImage) {
        
        if self.chooseImage != nil {
            self.chooseImage?(image)
        } else {
            self.uploadHeaderImage(image: image)
        }
        
        
    }
    
    //选择图片
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
        if photos.count > 0 {
            for image in photos {
                
                isnNeedCrop = true
                if let compressImage = ImageCompress.resetImgSize(sourceImage: image, maxImageLenght: KScreenHeight*2, maxSizeKB: 2000) {
                    self.cropImage = UIImage.init(data: compressImage)
                    self.cropImage(image: self.cropImage ?? UIImage() )
                }
                
            }
        }
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        //获得照片
        let image:UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        // 拍照
        if picker.sourceType == .camera {
            //保存相册
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
        }
        isnNeedCrop = true
        
        
        UIViewController.current()?.dismiss(animated: true, completion: {
            if let compressImage = ImageCompress.resetImgSize(sourceImage: image, maxImageLenght: KScreenHeight*2, maxSizeKB: 2000) {
                self.cropImage = UIImage.init(data: compressImage)
                self.cropImage(image: self.cropImage ?? UIImage() )
            }
        })
        
        
    }
    
    
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        
        if error != nil {
            
            print("保存失败")
            
            
        } else {
            
            print("保存成功")
            
            
        }
    }
}



//图片裁剪
extension CODImagePickerTools {
    
    //头像上传
    func uploadHeaderImage(image: UIImage) {
        
        CODProgressHUD.showWithStatus("正在上传头像...")
        UploadTool.upload(fileType: .groupHeader(roomID: self.roomID ?? "", image: image)) { [weak self] response in
            
            if let avatarID = JSON(response.value)["data"]["attId"].string {
                self?.avatarID = avatarID
                self?.uploadImageSuccess(image: image)
                CODProgressHUD.dismiss()
            } else {
                CODProgressHUD.showErrorWithStatus("头像上传失败")
            }

        }
        
    }
    
    func uploadImageSuccess(image: UIImage) {
        guard let avatarId = self.avatarID else {
            return
        }
        let url = URL(string: avatarId.getHeaderImageFullPath(imageType: 2))
        if let _ = SDWebImageManager.shared.cacheKey(for: url) {
            SDImageCache.shared.removeImage(forKey: url?.absoluteString, fromDisk: true) {
            }
        }
        if let _ = SDWebImageManager.shared.cacheKey(for: URL.init(string: avatarId) ) {
            
            SDImageCache.shared.removeImage(forKey: avatarId, fromDisk: true) {
            }
        }
        
        
        self.fetchImage?(image)
        self.fetchImageID?(avatarId)
        
        CODDownLoadManager.sharedInstance.updateAvatar(userPicID: avatarId, complete: nil)
    }
    
    
}
