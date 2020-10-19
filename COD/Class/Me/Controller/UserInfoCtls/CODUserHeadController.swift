//
//  CODUserHeadController.swift
//  COD
//
//  Created by XinHoo on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
class CODUserHeadController: BaseViewController {
    
    private var cropImage: UIImage?
    private var isnNeedCrop: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
//        if appdelegate.isNetwork {
//            let headImageUrl = UserManager.sharedInstance.avatar ?? ""
//
//            if let url = URL(string: headImageUrl.getHeaderImageFullPath(imageType: 2)) {
//
//                self.headerView.image = SDImageCache.shared.imageFromCache(forKey: CODImageCache.default.getCacheKey(url: url))
//                self.headerView.sd_setImage(with: url, placeholderImage: nil, options: [.refreshCached, .transformAnimatedImage, .forceTransition, ])
//            }
//
//
//
//        }
        
        let headImageUrl = UserManager.sharedInstance.avatar ?? ""
        headerView.cod_loadHeader(url: URL(string: headImageUrl.getHeaderImageFullPath(imageType: 2)))
        
        self.navigationItem.title = NSLocalizedString("个人头像", comment: "")
        self.setupUI()
        
    }
    
    fileprivate lazy var headerView: UIImageView = {
        let imgView = UIImageView()
        let url = URL(string: UserManager.sharedInstance.avatar!.getHeaderImageFullPath(imageType: 2))
        let placeholder_image = UIImage(named: "default_header_94")
//        imgView.sd_setImage(with: url, placeholderImage: placeholder_image, options: [.retryFailed,.fromLoaderOnly], context: nil)
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()

    func initHeaderView() {
        
        self.view.addSubview(headerView)
        let headerViewW = kScreenWidth - 6
        
        headerView.layer.cornerRadius = headerViewW/2
        headerView.clipsToBounds = true
        headerView.snp.makeConstraints({ (make) in
            make.height.equalTo(headerViewW)
            make.width.equalTo(self.headerView.snp.height)
            make.top.greaterThanOrEqualTo(self.view).offset(3)
            make.bottom.lessThanOrEqualTo(self.view).offset(-3)
            make.left.greaterThanOrEqualTo(self.view).offset(3)
            make.right.lessThanOrEqualTo(self.view).offset(-3)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        })
        headerView.layer.cornerRadius  = headerView.frame.size.width / 2;
        headerView.layer.masksToBounds = true
        
//        CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: UserManager.sharedInstance.avatar!) { (image) in
//            cell.headView.image = image
//        }
    }
    
    
    
    //点击事件
    override func navRightClick() {
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        weak var weakSelf = self
        let cameraAction = UIAlertAction(title: "拍照", style: UIAlertAction.Style.default){ (action:UIAlertAction)in
            
            weakSelf?.initCameraPicker()
            
        }
        let photoAction = UIAlertAction(title: "从相册中选择", style: UIAlertAction.Style.default){ (action:UIAlertAction)in
            
            weakSelf?.initPhotoPicker()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel){ (action:UIAlertAction)in
        }
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }


}

extension CODUserHeadController{
    
    func setupUI() {
        
        self.setBackButton()
        
        self.rightButton.frame = CGRect(x: 0, y: 0, width: 60, height: 20)
        self.rightButton.setTitleColor(UIColor.white, for: .normal)
        self.rightButton.titleLabel?.numberOfLines = 0
        self.rightButton.setImage(UIImage.init(named: "nav_show_more_icon"), for: .normal)
        self.rightButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 15, bottom: 0, right: 0)
//        self.rightTextButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        self.setRightButton()
        self.initHeaderView()
        self.view.backgroundColor = UIColor.white
        
    }
    
}
extension CODUserHeadController{
    
    //从相册中选择
    func initPhotoPicker(){
        
        if !self.checkAuth() {
            return
        }
        
        let tzImgPicker = CustomUtil.getImagePickController(maxImagesCount: 1, delegate: self)
        tzImgPicker?.isSelectOriginalPhoto = false
        tzImgPicker?.allowPreview = false
        tzImgPicker?.allowTakePicture = false
        tzImgPicker?.allowTakeVideo  = false
        tzImgPicker?.allowCameraLocation = false
        tzImgPicker?.allowPickingVideo = false
        tzImgPicker?.allowPickingGif = false
        tzImgPicker?.delegate = self
        self.present(tzImgPicker ?? UIViewController.init(), animated: true, completion: nil)
        
    }
    
    //拍照
    func initCameraPicker(){
        
        if !self.checkAuth() {
            return
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let  cameraPicker = UIImagePickerController()
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = false
            cameraPicker.sourceType = .camera
            //在需要的地方present出来
            cameraPicker.modalPresentationStyle = .overFullScreen
            self.present(cameraPicker, animated: true, completion: nil)
        } else {
            
            print("不支持拍照")
            
        }
        
    }
    
    //裁剪
    func cropImage(image: UIImage){
        
        let cropVC = CODCropViewController()
        cropVC.isRound = false
        cropVC.targetImage = image
        cropVC.delegate = self
        self.navigationController?.pushViewController(cropVC)
        
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
extension CODUserHeadController:UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate,CODCropViewControllerDelegate{
    func CODClipImageDidCancel() {
        
    }
    
    func CODClipImageClipping(image: UIImage) {
        self.headerView.image = image
        self.uploadHeaderImage(image: image)
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
        if let compressImage = ImageCompress.resetImgSize(sourceImage: image, maxImageLenght: KScreenHeight*2, maxSizeKB: 2000) {
            self.cropImage = UIImage.init(data: compressImage)
            self.cropImage(image: self.cropImage ?? UIImage() )
        }

        self.dismiss(animated: true, completion: nil)
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
extension CODUserHeadController{
    
    //头像上传
    func uploadHeaderImage(image: UIImage) {
        CODProgressHUD.showWithStatus("正在上传头像...")
        UploadTool.upload(fileType: .header(image: image)) { [weak self] response in
            
            if !response.result.isFailure {
                CODProgressHUD.showSuccessWithStatus("头像上传成功")
                self?.uploadImageSuccess(image: image)
            } else {
                CODProgressHUD.showErrorWithStatus("头像上传失败")
            }
            
        }
    }
    
    func uploadImageSuccess(image: UIImage) {
        let headImageUrl = UserManager.sharedInstance.avatar ?? ""
        
        self.headerView.image = image
        
        if let url = URL(string: headImageUrl.getHeaderImageFullPath(imageType: 2)) {
        
            SDImageCache.shared.store(image, forKey: CODImageCache.default.getCacheKey(url: url), toDisk: true, completion: nil)
            SDImageCache.shared.removeImageFromMemory(forKey: CODImageCache.default.getCacheKey(url: url))
//            SDWebImageManager.defaultImageCache?.store(image, imageData: nil, forKey: CODImageCache.default.getCacheKey(url: url), cacheType: .all, completion: nil)
        }
        
        if let url = URL(string: headImageUrl) {
            SDImageCache.shared.store(image, forKey: CODImageCache.default.getCacheKey(url: url), toDisk: true, completion: nil)
            SDImageCache.shared.removeImageFromMemory(forKey: CODImageCache.default.getCacheKey(url: url))
        }
        
        
//        let url = URL(string: headImageUrl.getHeaderImageFullPath(imageType: 2))
//        if let _ = SDWebImageManager.shared.cacheKey(for: url) {
//            SDImageCache.shared.removeImage(forKey: url?.absoluteString, fromDisk: true) {
//            }
//        }
//        if let _ = SDWebImageManager.shared.cacheKey(for: URL.init(string: headImageUrl) ) {
//
//            SDImageCache.shared.removeImage(forKey: headImageUrl, fromDisk: true) {
//            }
//        }
//        self.headerView.sd_setImage(with: url, placeholderImage: image)
////        CODDownLoadManager.sharedInstance.updateAvatar(userPicID: headImageUrl, complete: nil)
//        CODDownLoadManager.sharedInstance.updateAvatar(userPicID: headImageUrl) { (image) in
//
//        }
    }
    
    
}
