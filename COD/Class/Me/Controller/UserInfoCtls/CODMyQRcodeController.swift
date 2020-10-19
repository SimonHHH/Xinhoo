//
//  CODMyQRcodeController.swift
//  COD
//
//  Created by XinHoo on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit



class CODMyQRcodeController: BaseViewController {
    
    enum QRCodeType: Int {
        case simpleType
        case groupType
    }
    
    var type: QRCodeType = .simpleType
    var roomID: Int?
    var groupModel: CODGroupChatModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if type == .simpleType {
            self.navigationItem.title = NSLocalizedString("我的二维码", comment: "")
            let sex = UserManager.sharedInstance.sex
            if sex.compareNoCaseForString("男") {
               sexImgView.image = UIImage(named: "man_icon")
           }else{
               sexImgView.image = UIImage(named: "woman_icon")
           }
        }else{
            self.navigationItem.title = NSLocalizedString("群二维码", comment: "")
            groupModel = CODGroupChatRealmTool.getGroupChat(id: roomID!)
        }
        
        self.setBackButton()
        self.setRightButton()
        self.rightButton.setImage(UIImage.init(named: "QRcode_More"), for: .normal)
        self.addSubView()
        self.addSubViewContrains()
        if UserManager.sharedInstance.addinqrcode || type != .simpleType {
            self.downloadImage()
        }else{
            self.prohibitAddFriendByQRCode()
        }
    }
    
    override func navRightClick() {
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
      let saveAction = UIAlertAction.init(title: NSLocalizedString("保存到相册", comment: ""), style: .default) { (action) in
        
        self.saveQRImage()
      }
            
      let cancelAction = UIAlertAction.init(title: NSLocalizedString("取消", comment: ""), style: .cancel) { (action) in
          
      }
      
      alert.addAction(saveAction)
      alert.addAction(cancelAction)
      
      UIViewController.current()?.present(alert, animated: true, completion: nil)
    }
    
    func prohibitAddFriendByQRCode() {
        
        let bgView = UIImageView.init()
        bgView.backgroundColor = UIColor.clear
        bgView.image = UIImage.init(named: "prohibit_QRCode")
        bgView.contentMode = .scaleAspectFit
        self.view.addSubview(bgView)
        
        let mainTitleLb = UILabel.init()
        mainTitleLb.text = NSLocalizedString("未开启二维码添加功能", comment: "")
        mainTitleLb.font = UIFont.systemFont(ofSize: 16)
        mainTitleLb.textColor = UIColor.black
        bgView.addSubview(mainTitleLb)
        
        bgView.snp .makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.size.equalTo((kScreenWidth-30-106))
        }
        mainTitleLb.snp.makeConstraints { (make) in
            make.top.equalTo(bgView).offset(40)
            make.centerX.equalTo(bgView)
        }
        
    }
        
    func addSubView() {
        self.view.addSubview(backGroundView)
        backGroundView.addSubview(headerView)
        backGroundView.addSubview(nameLab)
        backGroundView.addSubview(self.sexImgView)
        qrCode.addSubview(logoImg)
        backGroundView.addSubview(qrCode)
        backGroundView.addSubview(tipsLab)
    }
    
    func addSubViewContrains() {
        backGroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(55)
            make.centerX.equalToSuperview()
            make.width.equalTo(kScreenWidth-40)
            make.height.equalTo(KScreenHeight*0.682)
        }
        
        headerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(25)
            make.left.equalToSuperview().offset(25)
            make.size.equalTo(60)
        }
        
        nameLab.snp.makeConstraints { (make) in
            make.centerY.equalTo(headerView)
            make.left.equalTo(headerView.snp.right).offset(13)
            make.width.lessThanOrEqualTo(kScreenWidth-160-21)
//            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(40)
        }
        
        sexImgView.snp.makeConstraints { (make) in
            make.height.width.equalTo(14)
            make.centerY.equalTo(self.nameLab)
            make.left.equalTo(self.nameLab.snp.right).offset(0)
        }
        
        qrCode.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom).offset(14)
            make.left.equalTo(backGroundView).offset(29)
            make.right.equalTo(backGroundView).offset(-28)
            make.size.equalTo((KScreenWidth - 97))
        }
        
        logoImg.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(50)
        }
        
        tipsLab.snp.makeConstraints { (make) in
            make.top.equalTo(qrCode.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
    
    lazy var backGroundView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = UIColor.white
        bgView.layer.cornerRadius = 8
        bgView.clipsToBounds = true
        return bgView
    }()
    
    lazy var headerView: UIImageView = {
        let headV = UIImageView()
        var url = URL.init(string: "")
        if type == .simpleType {
            url = URL(string: UserManager.sharedInstance.avatar!)
        }else{
            url = URL(string: groupModel?.grouppic.getHeaderImageFullPath(imageType: 0) ?? "")
        }
        
        let placeholder_image = UIImage(named: "default_header_80")
//        headV.sd_setImage(with: url, placeholderImage: placeholder_image)
        headV.sd_setImage(with: url, placeholderImage: placeholder_image, options: [.fromLoaderOnly, ], completed: nil)
        headV.clipsToBounds = true
        headV.layer.cornerRadius = 30
        return headV
    }()
    
    lazy var nameLab: UILabel = {
        let lab = UILabel()
        if type == .simpleType {
            lab.text = UserManager.sharedInstance.nickname
        }else{
            lab.text = groupModel?.getGroupName()
        }
        
        lab.font = UIFont.boldSystemFont(ofSize: 16)
        return lab
    }()
    
    lazy var sexImgView: UIImageView = {
           let sixImg = UIImageView()
           sixImg.contentMode = .scaleAspectFit
           return sixImg
       }()
    
    lazy var qrCode: UIImageView = {
        let codeImg = UIImageView()
        codeImg.contentMode = .scaleAspectFit
        return codeImg
    }()
    
    lazy var logoImg: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleToFill
        img.layer.cornerRadius = 25
        img.layer.borderColor = UIColor.white.cgColor
        img.layer.borderWidth = 2.0
        img.layer.masksToBounds = true
        return img
    }()
    
    lazy var tipsLab: UILabel = {
        let lab = UILabel()
        if type == .simpleType {
            lab.text = CustomUtil.formatterStringWithAppName(str: "扫描二维码, 加我%@")
        }else{
            lab.text = CustomUtil.formatterStringWithAppName(str: "扫描二维码, 加入群组")
        }
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textColor = UIColor(hexString: kSubTitleColors)
        lab.textAlignment = NSTextAlignment.center
        lab.numberOfLines = 0
        return lab
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

extension CODMyQRcodeController{
    /**
     使用 Alamofire 下载并且存储文件
     */
    fileprivate func downloadImage() {
        
        let mD5Url = HttpConfig.COD_QRcode_DownLoadUrl.md5() + UserManager.sharedInstance.loginName!
        ///判断这个文件存不存在
        var fileName = ""
        if type == .simpleType {
            fileName = CODFileManager.shareInstanceManger().getPersonFilePath(userPath: "qrCode", fileName: mD5Url, formatString: ".png")
        }else{
            fileName = CODFileManager.shareInstanceManger().getGroupFilePath(userPath: "qrCode", fileName: mD5Url, formatString: ".png")
            do {
                try FileManager.default.removeItem(atPath: fileName)
            } catch {
                
            }
        }
        
//        var url = URL.init(string: "")
        var picId = ""
        if type == .simpleType {
            picId = UserManager.sharedInstance.avatar!
        }else{
            picId = groupModel!.grouppic
        }
        
        self.logoImg.image = UIImage(named: "default_header_80")
        
        
        if FileManager.default.fileExists(atPath:fileName), let fileImage = UIImage.init(contentsOfFile: fileName){
//            self.playSoundWithPath(fileName)
            self.qrCode.image = fileImage
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: picId) { (image) in
                self.logoImg.image = image
            }
        }else{
            ///文件不存在下载
            var paramDic = Dictionary<String, Any>()
            if type == .simpleType {
                paramDic["qrType"] = 1
            }else{
                paramDic["qrType"] = 2
                paramDic["roomID"] = roomID
            }
            HttpManager.share.postWithHeader(url: HttpConfig.COD_QRcode_DownLoadUrl, param: paramDic, imageView: self.qrCode, userPath: "qrCode", filePath: fileName, formatString: ".png",successBlock: { (success, json) in
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: picId) { (image) in
                    self.logoImg.image = image
                }
            }) { (error) in
                print(error)
            }
        }
    }
}
extension CODMyQRcodeController{
    
    
    func saveQRImage()  {
        
        if self.checkAuth() {
            
            if let cutImage = self.cutImageWithView(view: self.backGroundView) as? UIImage  {
                self.writeImageToAlbum(image: cutImage)
            }
        }
    }
    
    /// 获取权限
    ///
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
    
    /// 截屏
    ///
    /// - Parameters:
    ///   - view: 要截屏的view
    /// - Returns: 一个UIImage
    func cutImageWithView(view:UIView) -> UIImage
    {
        // 参数①：截屏区域  参数②：是否透明  参数③：清晰度
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return image;
    }
    
    func writeImageToAlbum(image:UIImage)
    {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer)
    {
        if let e = error as NSError?
        {
            print(e)
        }
        else
        {
            CODProgressHUD.showSuccessWithStatus(NSLocalizedString("保存成功", comment: ""))
        }
    }
}
