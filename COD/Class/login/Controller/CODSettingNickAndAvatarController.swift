//
//  CODSettingNickAndAvatarController.swift
//  COD
//
//  Created by XinHoo on 2019/4/9.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODSettingNickAndAvatarController: BaseViewController {
    
    var avatarImgID: String?
    
    var nickName: String?
    
    private var cropImage: UIImage?
    private var isnNeedCrop: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = NSLocalizedString("完善资料", comment: "")
        self.view.backgroundColor = UIColor.white
        UserManager.sharedInstance.isLogin = false
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        self.addSubView()
        self.addSubViewContrains()
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(applicationBecomeUnavailable),
        name: NSNotification.Name.init("kApplicationBecomeUnavailable"),
        object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let target = self.navigationController?.interactivePopGestureRecognizer?.delegate
        let pan = UIPanGestureRecognizer(target: target, action: nil)
        self.view.addGestureRecognizer(pan)
    }

    
    @objc func settingAvatar(_ sender: UIButton) {
        //打开相册或者摄像头
        
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
    
    @objc func applicationBecomeUnavailable() {
        UserManager.sharedInstance.userLogout()
    }
    
    @objc func submit(_ sender: UIButton) {
        //发送iq设置头像和nick     ******头像还没上传
        CODProgressHUD.showWithStatus(nil)
        
        guard CODWebRTCManager.whetherConnectedNetwork() else {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            return
        }
        
        guard let nick = nickField.text else{
            CODProgressHUD.showErrorWithStatus("昵称为必填项(*)")
            return
        }
        self.nickName = nick
        self.nickName = self.nickName?.removeHeadAndTailSpacePro
        if self.nickName?.count ?? 0 <= 0 {
            CODProgressHUD.showErrorWithStatus("昵称为必填项(*)")
            return
        }
        
        if self.nickName!.count > 20  {
            CODProgressHUD.showErrorWithStatus("昵称设置请控制在20个字以内哦")
            return
        }
//        paramDic["name"] = self.nickName
//        XMPPManager.shareXMPPManager.SettingUserInfo(desc: paramDic, success: { (successModel, nameStr) in
//            print("设置nick成功")
//            UserManager.sharedInstance.isLogin = true
//            NotificationCenter.default.post(name: NSNotification.Name.init(kChangeRootCtlNoti), object: nil, userInfo: nil)
//        }) { (errorModel) in
//            print("设置nick失败")
//        }
        
        let paramDic = ["name":COD_changePerson,"requester":"\(UserManager.sharedInstance.jid)","setting":["name": nick]] as [String : Any]
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting_V2, actionDic: paramDic as NSDictionary)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
        
    }
    
    @objc func setNick(_ field: UITextField){
        guard var text = field.text else {
            return
        }
        if text.count > 20 {
            self.nickField.text = text.slice(from: 0, to: 20)
        }
    }
    
    func addSubView() {
        self.view.addSubview(avatarView)
        self.view.addSubview(uploadBtn)
        self.view.addSubview(nickField)
        self.view.addSubview(line)
        self.view.addSubview(submitBtn)
    }
    
    func addSubViewContrains() {
        avatarView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(52)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        avatarView.layer.cornerRadius = 40
        avatarView.clipsToBounds = true
        
        uploadBtn.snp.makeConstraints { (make) in
            make.top.equalTo(avatarView.snp.bottom).offset(20)
            make.left.right.equalTo(avatarView)
            make.height.equalTo(20)
        }
        
        nickField.snp.makeConstraints { (make) in
            make.top.equalTo(uploadBtn.snp.bottom).offset(38)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(20)
        }
        
        line.snp.makeConstraints { (make) in
            make.top.equalTo(nickField.snp.bottom).offset(5)
            make.left.right.equalTo(nickField)
            make.height.equalTo(0.5)
        }
        
        submitBtn.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(39)
            make.left.right.equalTo(line)
            make.height.equalTo(44)
        }
        
    }
    
    lazy var avatarView: UIButton = {
        let imgView = UIButton()
        let image = UIImage(named: "default_header_110")
        imgView.setImage(image, for: UIControl.State.normal)
        imgView.addTarget(self, action: #selector(settingAvatar(_:)), for: UIControl.Event.touchUpInside)
        return imgView
    }()
    
    lazy var uploadBtn: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.text = "上传头像"
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.titleLabel?.textColor = UIColor(hexString: kMainTitleColorS)
        btn.addTarget(self, action: #selector(settingAvatar(_:)), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    lazy var nickField: UITextField = {
        let field = UITextField()
        field.placeholder = "请输入昵称(字数请控制在20个字以内哦)"
        field.clearButtonMode = UITextField.ViewMode.always
        field.font = UIFont.systemFont(ofSize: 15)
        field.addTarget(self, action: #selector(setNick(_:)), for: UIControl.Event.editingChanged)
        return field
    }()
    
    lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: kDividingLineColorS)
        return view
    }()
    
    lazy var submitBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setTitle("完成注册", for: UIControl.State.normal)
        btn.backgroundColor = UIColor(hexString: kSubmitBtnBgColorS)
        btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        btn.layer.cornerRadius = kCornerRadius
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(self.submit(_:)), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension CODSettingNickAndAvatarController{
    
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
extension CODSettingNickAndAvatarController:UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate,CODCropViewControllerDelegate{
    func CODClipImageDidCancel() {
        
    }
    
    func CODClipImageClipping(image: UIImage) {
        self.avatarView.setImage(image, for: .normal)
        self.uploadHeaderImage(image: image)
    }
    
    //选择图片
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
        if photos.count > 0 {
            for image in photos {
                
                isnNeedCrop = true
                self.cropImage = image
                self.cropImage(image: self.cropImage ?? UIImage() )
                
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
extension CODSettingNickAndAvatarController{
    
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
        
        let url = URL(string: headImageUrl.getHeaderImageFullPath(imageType: 2))
        if let _ = SDWebImageManager.shared.cacheKey(for: url) {
            SDImageCache.shared.removeImage(forKey: url?.absoluteString, fromDisk: true) {
            }
        }
        if let _ = SDWebImageManager.shared.cacheKey(for: URL.init(string: headImageUrl) ) {
            SDImageCache.shared.removeImage(forKey: headImageUrl, fromDisk: true) {
                
            }
        }
        self.avatarView.sd_setImage(with: url, for: .normal, placeholderImage: image)
        //        self.avatarView.sd_setImage(with: url, placeholderImage: image, options: []) { (downImage, error, cacheType, url) in
        //
        //            self.avatarView.setImage(image, for: .normal)
        //        }
    }
    
    
}

extension CODSettingNickAndAvatarController: XMPPStreamDelegate {
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        CustomUtil.analyticxXML(iq: iq) { (actionDict, infoDict) in
            guard let infoDict = infoDict else {
                return
            }
            if (actionDict["name"] as? String == COD_changePerson){
                if let success = infoDict["success"] as? Bool {
                    if success {
                        
                        if let userinfo = actionDict["setting"] as? Dictionary<String,Any> {
                            UserManager.sharedInstance.userInfoSetting = CODUserInfoAndSetting.deserialize(from: userinfo)!
                        }
                        
                        UserManager.sharedInstance.isLogin = true
                        CODUserDefaults.set(true, forKey: AccountAndSecurity_Red_Point)
                        NotificationCenter.default.post(name: NSNotification.Name.init(kChangeRootCtlNoti), object: nil, userInfo: nil)
                        
                    }else{
                        if let code = infoDict["code"] as? Int {
                            switch code {
                                
                            default: break
                            }
                        }
                    }
                }
            }
        }
        
        return true
    }
}

