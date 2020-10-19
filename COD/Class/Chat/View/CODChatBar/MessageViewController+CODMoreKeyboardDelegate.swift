//
//  MessageViewController+CODMoreKeyboardDelegate.swift
//  COD
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
//import JitsiMeet
import MobileCoreServices
import AVFoundation
import Photos
import PhotosUI
import AssetsLibrary
import LPActionSheet
// MARK: - CODMoreKeyboardDelegate

// MARK: - CODMoreKeyboardDelegate
extension MessageViewController:CODMoreKeyboardDelegate{
    
    /// 选中itme
    ///
    /// - Parameters:
    ///   - keyboard: 更多键盘
    ///   - funcItem: 类型
    func moreKeyboardDidSelectedFunctionItem(keyboard: CODMoreKeyboard, funcItem: CODMoreKeyboardItem) {
        
        self.dismisskeyboard()
        if funcItem.type == .CODMoreKeyboardItemTypeImage {//图片视频
            self.pushTZImagePickerController()
        }else if funcItem.type == .CODMoreKeyboardItemTypeCards{//名片
            self.sendCards()
        }else if funcItem.type == .CODMoreKeyboardItemTypeCamera{//相机
            
            if UserDefaults.standard.bool(forKey: kIsVideoCall) {
                CODProgressHUD.showWarningWithStatus("通话中无法使用此功能")
                return
            }
            self.pushUIImagePickerController()
        }else if funcItem.type == .CODMoreKeyboardItemTypePosition{//位置
            self.sendLocationInfo()
        }else if funcItem.type == .CODMoreKeyboardItemTypeVoiceCall{//语音聊天
            self.vioceCall(callType: COD_call_type_voice)
        }else if funcItem.type == .CODMoreKeyboardItemTypeVideoCall{//视频聊天
            self.vioceCall(callType: COD_call_type_video)
        }else if funcItem.type == .CODMoreKeyboardItemTypeFavorite{//收藏
            self.pushFavoriteVC()
        }else if funcItem.type == .CODMoreKeyboardItemTypeFile{//文件
            self.showFileSource()
        }else if funcItem.type == .CODMoreKeyboardItemTypeCloudDisk{//我的云盘
            self.pushMyCloudDiskVC()
        }
    }
    //   进入拍照
    func moreKeyboardPushUIImagePickerController(keyboard: CODMoreKeyboard){
        self.dismisskeyboard()  
        self.pushUIImagePickerController()
    }
    
    /// 选中上面的图片
    ///
    /// - Parameters:
    ///   - keyboard: 更多键盘
    ///   - item: 图片
    func moreKeyboardDidSelectedPhotoAssetItem(keyboard: CODMoreKeyboard,item:CODPhotoAsset){
        ///先获取图片
        ///然后在做处理 发送图片
//        self.sendImageMessage(image: item.photoImage ?? UIImage.init() )
       
//        CODPhotoPickerManger.getAssetMaxImageData(assest: item.asset, block: { (_ image:UIImage)in
//            ///然后在做处理 发送图片

//        })
    }
    
    /// 选择图片
    func pushTZImagePickerController(isSendFile: Bool = false) {
        
        if self.captionView != nil {
            self.captionView?.dismissCaptionView()
        }
        
        let captionView: CODPictureCaptionView = CODPictureCaptionView.share
        if captionView.textView.text.count ?? 0 > 0{
            captionView.textView.text = ""
        }
        
        let tzImgPicker = CODTZImagePickerController.init(maxImagesCount: 9, delegate: self)

        tzImgPicker?.photoPreviewPageUIConfigBlock = { [weak self] (_ collectionView, _ naviBar, _ backButton, _ selectButton, _ indexLabel, _ toolBar, _ originalPhotoButton, _ originalPhotoLabel, _ doneButton, _ numberImageView, _ numberLabel) in
            guard let `self` = self, !isSendFile else { return }
            self.addStutasView(toolV: toolBar ?? UIView())
            
        }
        tzImgPicker?.photoPreviewPageDidRefreshStateBlock = { [weak self] (_ collectionView, _ naviBar, _ backButton, _ selectButton, _ indexLabel, _ toolBar, _ originalPhotoButton, _ originalPhotoLabel, _ doneButton, _ numberImageView, _ numberLabel) in
//            guard let `self` = self else { return }
            toolBar?.superview?.resignFirstResponder()

        }
        tzImgPicker?.videoPreviewPageUIConfigBlock = { [weak self] (playButton,toolBar,doneButton) in
            playButton?.setImage(UIImage.init(named: "tz_bigPlay"), for: .normal)
            playButton?.setImage(UIImage.init(named: "tz_bigPlay"), for: .highlighted)
            guard let `self` = self, !isSendFile else { return }
            self.addStutasView(toolV: toolBar ?? UIView())

        }
        tzImgPicker?.videoPreviewPageDidLayoutSubviewsBlock = { [weak self] (playButton,toolBar,doneButton) in
            playButton?.setImage(UIImage.init(named: "tz_bigPlay"), for: .normal)
            playButton?.setImage(UIImage.init(named: "tz_bigPlay"), for: .highlighted)
//            guard let `self` = self else { return }
//            self.captionView?.isHidden = toolBar?.isHidden ?? false
        }
        tzImgPicker?.isSendFile = isSendFile
        tzImgPicker?.allowTakeVideo  = false
        tzImgPicker?.allowTakePicture  = false
        tzImgPicker?.allowPickingOriginalPhoto = !isSendFile
        tzImgPicker?.minImagesCount = 1
        if self.editMessage.type == .image  {
            tzImgPicker?.allowPickingVideo = false
            tzImgPicker?.allowPickingGif = true
            tzImgPicker?.allowPickingImage = true
        }else if self.editMessage.type == .video {
            tzImgPicker?.allowPickingVideo = true
            tzImgPicker?.allowPickingGif = false
            tzImgPicker?.allowPickingImage = false
        }else{
            tzImgPicker?.allowPickingVideo = true
            tzImgPicker?.allowPickingGif = true
            tzImgPicker?.allowPickingImage = true
        }
        tzImgPicker?.showSelectedIndex = false
        tzImgPicker?.showPhotoCannotSelectLayer = true
        //        tzImgPicker?.statusBarStyle = false
        tzImgPicker?.naviBgColor = UIColor.black
        tzImgPicker?.naviTitleColor = UIColor.white
//        tzImgPicker?.iconThemeColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1)
        tzImgPicker?.iconThemeColor = UIColor.init(hexString: "007EE5")
        tzImgPicker?.oKButtonTitleColorNormal = UIColor.init(hexString: "007EE5")
        tzImgPicker?.oKButtonTitleColorDisabled = UIColor.init(hexString: "007EE5")?.withAlphaComponent(0.5)
        tzImgPicker?.photoSelImage = UIImage.init(named: "person_selected")
        tzImgPicker?.photoOriginSelImage = UIImage.init(named: "person_selected")
        tzImgPicker?.videoMaximumDuration = 10
        tzImgPicker?.modalPresentationStyle = .fullScreen
        tzImgPicker?.barItemTextFont = UIFont.systemFont(ofSize: 17)
        tzImgPicker?.preferredLanguage = CustomUtil.getCurrentLanguage()
        tzImgPicker?.photoPickerPageDidRefreshStateBlock = { (_, _, _, _, _, doneButton, _, _, _) in
            doneButton?.hitWidthScale = 3
        }
        tzImgPicker?.cancelBtnTitleStr = NSLocalizedString("取消  ", comment: "")

        self.present(tzImgPicker!, animated: true, completion: nil)
        
    }
    
    func addStutasView(toolV: UIView) {

        toolV.backgroundColor = UIColor.black
        let addView = CODPictureCaptionView.share
        addView.delegate = self
        addView.textDelegate = self
        addView.toolView = toolV
        addView.createView(toolView: toolV)
        addView.showCaptionView(showView: toolV.superview ?? UIView())
        let bottomH = IsiPhoneX ? 44 + (83 - 49) : 44

        addView.snp.makeConstraints { (make) in
            make.left.right.equalTo(toolV)
            make.bottom.equalToSuperview().offset(-bottomH)
//            make.bottom.equalTo(toolV.snp.top)
            make.height.greaterThanOrEqualTo(45)
        }

        self.captionView = addView
        
    }
    
    func pushEidtTZImagePickerController() {
        
        if self.editMessage.type != .image && self.editMessage.type != .video {
            return
        }
        let tzImgPicker = CustomUtil.getImagePickController(maxImagesCount: 1, delegate: self)
        tzImgPicker?.isSelectOriginalPhoto = true
        tzImgPicker?.allowTakeVideo  = false
        tzImgPicker?.allowTakePicture  = false
        if self.editMessage.type == .image  {
            tzImgPicker?.allowPickingVideo = false
            tzImgPicker?.allowPickingGif = true
            tzImgPicker?.allowPickingImage = true
        }else if self.editMessage.type == .video {
            tzImgPicker?.allowPickingVideo = true
            tzImgPicker?.allowPickingGif = false
            tzImgPicker?.allowPickingImage = false
        }
        tzImgPicker?.videoMaximumDuration = 10
        tzImgPicker?.photoPreviewPageDidLayoutSubviewsBlock = { (_, _, _, _, _, _, _, _, doneButton, _, _) in
            doneButton?.hitScale = 3
        }
        tzImgPicker?.cancelBtnTitleStr = NSLocalizedString("取消  ", comment: "")
        self.present(tzImgPicker!, animated: true, completion: nil)
    }
        
    
    func checkCameraPermission () {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {granted in
            if !granted {
                
                DispatchQueue.main.async {
                    CODAlertViewToSetting_show("无法访问您的相机", message: CustomUtil.formatterStringWithAppName(str: "请到设置 -> %@ -> 相机 -> 打开访问权限") )
                }
                
            }
        })
    }
    
    ///拍照
    func pushEidtUIImagePickerController() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .denied || authStatus == .restricted {
            CODAlertViewToSetting_show("无法访问您的相机", message: CustomUtil.formatterStringWithAppName(str: "请到设置 -> %@ -> 相机 -> 打开访问权限") )
        }else{
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let photoPicker = UIImagePickerController()
                photoPicker.delegate = self
                photoPicker.allowsEditing  = false
                if self.editMessage.type == .image  {
                  photoPicker.mediaTypes=[kUTTypeImage as String]//只有照片

                }else if self.editMessage.type == .video {
                  photoPicker.mediaTypes=[kUTTypeMovie as String]//只有视频
                }
                photoPicker.sourceType = .camera
                self.present(photoPicker, animated: true, completion: nil)
            }else{
                ///没有相机权限
               CODAlertViewToSetting_show("无法访问您的相机", message: CustomUtil.formatterStringWithAppName(str: "请到设置 -> %@ -> 相机 -> 打开访问权限") )
            }
        }
    }
    
    ///拍照
    func pushUIImagePickerController() {
        if self.captionView != nil {
            self.captionView?.dismissCaptionView()
        }
        let captionView: CODPictureCaptionView = CODPictureCaptionView.share
        if captionView.textView.text.count ?? 0 > 0{
            captionView.textView.text = ""
            
        }
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)

        if authStatus == .denied || authStatus == .restricted {

            CODAlertViewToSetting_show("无法访问您的相机", message: CustomUtil.formatterStringWithAppName(str: "请到设置 -> %@ -> 相机 -> 打开访问权限") )

        }else{
            if UIImagePickerController.isSourceTypeAvailable(.camera){

                let cameraController = TXCameraController.default()
                cameraController.type = TXCameraTypeChat
                cameraController.chatId = Int32(self.chatId)
                cameraController.isGroupChat = self.isGroupChat

                // 拍照完成后回调
                cameraController.takePhotosCompletionBlock = {[weak self](_ image: UIImage,error: Error,capView: CODPictureCaptionView) in
                    if image.bytesSize > 0 {
                        self?.captionView = capView
//                        let imageData = ImageCompress.resetImgSize(sourceImage: image, maxImageLenght: KScreenHeight*2, maxSizeKB: 1024)
                        let imageData = image.pngData()

                        let imageName =  "\(NSDate().timeIntervalSince1970 * 1000000)"

                        let fileName = CODFileManager.shareInstanceManger().imagePathWithName(fileName: imageName)
                        let isSave: Bool = NSData.init(data: imageData ?? Data()).write(to: URL.init(fileURLWithPath: fileName), atomically: true)
                        if isSave{
                            let sendImage = UIImage.init(contentsOfFile: fileName)
                            self?.sendImageMessage(image: sendImage ?? UIImage(), imageData: imageData, ishdimg: false)
                        }
                    }else{
                        CODProgressHUD.showErrorWithStatus(NSLocalizedString("照片保存失败", comment: ""))
                    }
                }
                
                cameraController.shootCompletionBlock = {[weak self](_ videoUrl:URL, videoTimeLength:CGFloat, thumbnailImage:UIImage?, error:Error?,capView: CODPictureCaptionView) in
                    if let thumbnailImage = thumbnailImage, videoTimeLength > 0 {
                        self?.captionView = capView

                        let videoName =  "\(Int(NSDate().timeIntervalSince1970 * 1000000))"
                        if let data = NSData.init(contentsOf: videoUrl) {
                            let beforeData = data.count / 1048576
                            if beforeData > CODAppInfo.getUploadfileAllowsMaxsize()?.int ?? 0 {
                                CustomUtil.showUploadfileAllowsMaxsizeTip()
                                return
                            }
                        }
              
                        let msgIDTemp = UserManager.sharedInstance.getMessageId()
                        
                        self?.prepareSendVideoMessage(msgID: msgIDTemp, duration: CGFloat(videoTimeLength), firstpic: thumbnailImage, toID: self?.toJID)
                        
                        cameraController.navigationController?.popViewController()
                        
                        self?.compressVideoWithVideoURL(videoURL: videoUrl, savedName: videoName as NSString, msgID: msgIDTemp,displayName: videoName, duration: CGFloat(videoTimeLength),firstpic: thumbnailImage,toID: self?.toJID) { (videoFile) in
                        }

                    }else{
                        CODProgressHUD.showErrorWithStatus(NSLocalizedString("视频保存失败", comment: ""))
                    }
                  
                }
                
                self.navigationController?.pushViewController(cameraController)
            }else{
                ///没有相机权限
                CODAlertVcPresent(confirmBtn: nil, message: "提示", title: "当前的设备不支持！", cancelBtn: "确定", handler: { (actin) in
                    
                }, viewController: self)
            }
        }
    }
    
    
    //    发送位置
    func sendLocationInfo() {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse || status == .notDetermined {
            let sendLocationVC =  CODSendMapViewController()
            sendLocationVC.sendLocationBlock = { [weak self] (locationImage,currenPOI) in
                
                guard let `self` = self else { return }
                
                let msgIDTemp = UserManager.sharedInstance.getMessageId()
                let model = CODMessageModelTool.default.createLocationModel(msgID: msgIDTemp, toJID: self.toJID, longitude: CGFloat(currenPOI.pt.longitude), latitude: CGFloat(currenPOI.pt.latitude), titleString: currenPOI.name, subtitleString: currenPOI.address, pictrueImage: locationImage, chatType: self.chatType, roomId: self.roomId, chatId: self.chatId ?? 0, burn: self.isBurn ?? 0)
                self.sendLocationWithModel(model: model)
            }
            let nav = BaseNavigationController(rootViewController: sendLocationVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
       }else{
           ///提示用户
           CODAlertViewToSetting_show("无法访问您的位置", message: CustomUtil.formatterStringWithAppName(str: "请到设置 -> %@ -> 位置 -> 打开访问权限"))
       }
        
    }
    
    func pushFavoriteVC() {
        self.navigationController?.pushViewController(FavoriteViewController())
    }
    
    func pushMyCloudDiskVC() {
        let vc = SharedMediaFileViewController.init(nibName: "SharedMediaFileViewController", bundle: nil)
        vc.title = NSLocalizedString("我的云盘", comment: "")
        vc.isCloudDisk = true
        vc.chatId = CloudDiskRosterID
        let listModel = CODChatListRealmTool.getChatList(id: CloudDiskRosterID)
        vc.list = listModel?.chatHistory?.messages
        vc.chooseListBlock = { [weak self] (selectList,vc) in
            for messageModel in selectList {
                let copyModel = CODMessageSendTool.default.getCopyModel(messageModel: messageModel)
                let msgIDTemp = UserManager.sharedInstance.getMessageId()
                copyModel.msgID = msgIDTemp
                copyModel.toJID = self?.toJID ?? ""
                copyModel.toWho = self?.toJID ?? ""
                copyModel.fromWho = UserManager.sharedInstance.jid
                copyModel.fromJID = UserManager.sharedInstance.jid
                copyModel.status =  CODMessageStatus.Pending.rawValue
//                self?.chatType == .channel {
    
                copyModel.chatTypeEnum = self?.chatType ?? .privateChat
//                }else{
//
//                    copyModel.chatTypeEnum = self?.isGroupChat == true ? .groupChat : .privateChat
//                }
                let timestr = String(format: "%ld", Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp)
                copyModel.datetime = timestr
                copyModel.roomId = self?.roomId?.int ?? 0
                copyModel.datetimeInt = Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp
                copyModel.burn = self?.isBurn ?? 0
                copyModel.isReaded = false
                copyModel.fw = ""
                copyModel.fwn = ""
                copyModel.fwf = ""
                copyModel.n = ""
                copyModel.rp = ""
                
                if messageModel.chatTypeEnum == .privateChat && messageModel.isMeSend == false {
                    copyModel.itemID = messageModel.fromJID
                } else {
                    copyModel.itemID = messageModel.toJID
                }
                                
                copyModel.smsgID = messageModel.msgID
                
                _ = copyModel.videoModel?.setValue(messageModel.videoModel?.firstpicId ?? "", forKey: \.firstpicId)

                if messageModel.msgType == 2 || messageModel.msgType == 4 || (messageModel.msgType == 7  && messageModel.fileModel?.thumb.removeAllSapce.count ?? 0 > 0) {
                }
                if messageModel.msgType == 2 {
                    self?.vaildTranfile(fileID: messageModel.photoModel?.serverImageId ?? "", model: messageModel, copyModel: copyModel)
                }
                if messageModel.msgType == 4 {
                    self?.vaildTranfile(fileID: messageModel.videoModel?.serverVideoId ?? "", model: messageModel, copyModel: copyModel)
                }
                if messageModel.msgType == 7 {
                    self?.vaildTranfile(fileID: messageModel.fileModel?.fileID ?? "", model: messageModel, copyModel: copyModel)
                }
                
                if messageModel.msgType == 1 {
                    self?.sendMessage(messageModel: copyModel)
                }
            }
//            self?.messageView.tableView.scrollBottomToLastRow()
            vc.navigationController?.popViewController(animated: false)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentICloudDriveController() {
        self.iCloudTool.setDidPickBlock { [weak self] (pickerVC, urls) in
            guard let `self` = self else { return }
            for url in urls {
                if url.startAccessingSecurityScopedResource() {
                    let fileCoordinator = NSFileCoordinator()
                    let error = NSErrorPointer(nilLiteral: ())
                    fileCoordinator.coordinate(readingItemAt: url, options: .forUploading, error: error) { [weak self] (newUrl) in
                        
                        self?.sendFile(fileURL: newUrl)
                    }
                    url.stopAccessingSecurityScopedResource()
                }else{
                    
                }
            }
        }
        self.iCloudTool.present()
    }
    
    func showFileSource() {
        
        CODActionSheet.show(withTitle: "", cancelButtonTitle: NSLocalizedString("取消", comment: ""), destructiveButtonTitle: "", otherButtonTitles: [NSLocalizedString("从相册中选择", comment: ""), "iCloud Drive"], cancelButtonColor: UIColor(hexString: "#047EF5")!, destructiveButtonColor: nil, otherButtonColors: [UIColor(hexString: "#047EF5")!, UIColor(hexString: "#047EF5")!]) { [weak self] (sheet, index) in
            guard let `self` = self else { return }
            print("\(index)")
            switch index {
            case 1:
                self.pushTZImagePickerController(isSendFile: true)
                break
            case 2:
                self.presentICloudDriveController()
                break
            default:
                break
            }



        }
    }
    
    //文件迁移
    func vaildTranfile(fileID: String,model: CODMessageModel,copyModel: CODMessageModel) {
        //        验证类型 ctd(聊天转发到云盘)，默认 dtc(云盘转发到聊天)
        var fileIDs = CustomUtil.getPictureID(fileIDs: [fileID])

        if model.msgType == 4 {
            fileIDs = CustomUtil.getPictureID(fileIDs: [fileID,model.videoModel?.firstpicId ?? ""])
        }
        if model.msgType == 7 && model.fileModel?.thumb.removeAllSapce.count ?? 0 > 0 {
            fileIDs = CustomUtil.getPictureID(fileIDs: [fileID,model.fileModel?.thumb ?? ""])
        }

        guard fileIDs.count > 0 else {
            return
        }
        
        if !self.isCloudDisk {
            
//            if model.isCloudDiskMessage {
//                HttpTools.vaildandTranfile(attIdList: fileIDs, type: .CloudDiskToChat)
//            } else {
                HttpTools.vaildandTranfile(attIdList: fileIDs, type: .CloudDiskToChat)
//            }
            
            
        }

        self.sendICouldMessage(messageModel: copyModel)
     
    }

    func sendICouldMessage(messageModel: CODMessageModel) {
        
        if messageModel.msgType == 4 {
            let copyModel = CODMessageSendTool.default.getCopyModel(messageModel: messageModel)
            self.addMessageToView(model: copyModel)
        }
        self.sendMessage(messageModel: messageModel)

    }
    func vioceCall(callType:String) {
        let strCallType = callType == COD_call_type_voice ? "语音" : "视频"
        
        if UserDefaults.standard.bool(forKey: kIsVideoCall) {
            CODProgressHUD.showWarningWithStatus("当前无法发起\(strCallType)通话")
            return
        }
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if delegate.callObserver.calls.first != nil {
            let alert = UIAlertController.init(title: "正在通话", message: String.init(format: NSLocalizedString("您不能在电话通话时同时使用 %@ 通话。", comment: ""), kApp_Name), preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "好", style: .default) { (action) in
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if delegate.manager?.status == .notReachable {
            
            let alert = UIAlertController.init(title: "无法呼叫", message: "请检查您的互联网连接并重试。", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "好", style: .default) { (action) in
                
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if self.chatType == .groupChat {
            if !CustomUtil.judgeInGroupRoomCanSpeak(roomId: self.chatId) {
                
                CODAlertView_show("群禁言已开启，无法发起语音通话")
                
                return
            }
            
            if self.chatListModel?.groupRtc == 1 {
                                
                let alertView = UIAlertController(title: NSLocalizedString("群里已有语音通话，是否加入？", comment: ""), message: nil, preferredStyle: .alert)
                alertView.addAction(title: NSLocalizedString("取消", comment: ""), style: .default, isEnabled: true) { (action) in
                    
                }
                alertView.addAction(title: NSLocalizedString("加入", comment: ""), style: .default, isEnabled: true) { (action) in
                    
                    let dict:NSDictionary = ["name":COD_accept,
                                             "requester":UserManager.sharedInstance.jid,
                                             "receiver":self.chatListModel?.jid ?? "",
                                             "room":self.chatListModel?.groupRtcRoomId ?? "",
                                             "chatType":"2",
                                             "roomID":self.chatListModel?.groupChat?.roomID ?? "",
                                             "msgType":"voice"]
                    
                    let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_voicerequest, actionDic: dict)
                    XMPPManager.shareXMPPManager.xmppStream.send(iq)
                    
                }
                self.present(alertView, animated: true, completion: nil)
                
                return
            }
            
            let ctl = CreGroupChatViewController()
            ctl.ctlType = .multipleVoice
            ctl.groupChatModel = self.chatListModel?.groupChat
            ctl.roomID = self.roomId
            ctl.maxSelectedCount = 9
            ctl.selctMemberList = [UserManager.sharedInstance.jid]
            self.navigationController?.pushViewController(ctl, animated: true)
            
        }else if self.chatType == .privateChat {
            let  dict:NSDictionary = ["name":COD_request,
                                      "requester":UserManager.sharedInstance.jid,
                                      "memberList":[self.toJID],
                                      "chatType":"1",
                                      "roomID":"0",
                                      "msgType":callType]
            
            let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_voicerequest, actionDic: dict)
            XMPPManager.shareXMPPManager.xmppStream.send(iq)
        }
        
    }
    
    func sendCards() {
        let msgIDTemp = UserManager.sharedInstance.getMessageId() 
        let chooseVC = CODChoosePersonVC()
//        chooseVC.fromJID = self.toJID
        chooseVC.choosePersonBlock = { [weak self] (contactModel) in
            
            guard let `self` = self else { return }
            
            let model = CODMessageModelTool.default.createBusinessCardModel(msgID: msgIDTemp, toJID: self.toJID, username: contactModel.jid, name: contactModel.name, userdesc: contactModel.userdesc, userpic: contactModel.userpic, jid: contactModel.jid, gender: contactModel.gender, chatType: self.chatType, roomId: self.roomId, chatId: self.chatId, burn: self.isBurn  )
            self.sendCardWithModel(model:model)
        }
        self.navigationController?.pushViewController(chooseVC)
        
    }
}


extension MessageViewController:TZImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        print("xwregotjireth")
    }
    
    //选择图片
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        self.dismisskeyboard()
        var isSendFile = false
        if let CODPicker = picker as? CODTZImagePickerController {
            isSendFile = CODPicker.isSendFile
        }
        if assets.count > 0 {
            guard let assets = assets as? [PHAsset] else { return }
            
            if !isSendFile {
                var imageInfo: [(image: UIImage, imageData: Data?)] = []
                
                DispatchQueue(label: "imagePicker").async {
                    
                    let semaphore = DispatchSemaphore(value: 0)
                    
                    for i in 0..<assets.count {
                        let asset = assets[i]
                        
                        TZImageManager.default()!.getOriginalPhotoData(with: asset, completion: { (imageData, info, isDegraded) in
                            guard let imageData = imageData else { return }
                            imageInfo.append((image: photos[i], imageData: imageData))
                            
                            semaphore.signal()
                            
                        })
                        
                        semaphore.wait()
                    }

                    DispatchQueue.main.async {
                        
                        if imageInfo.count > 1 {
                            self.sendMultipleImage(imageInfos: imageInfo, ishdimg: isSelectOriginalPhoto)
                        } else {
                            
                            if self.isEdit {
                                self.editImageMessage(image: imageInfo[0].image, imageData: imageInfo[0].imageData, ishdimg: isSelectOriginalPhoto)
                            } else {
                                self.sendImageMessage(image: imageInfo[0].image, imageData: imageInfo[0].imageData, ishdimg: isSelectOriginalPhoto)
                            }
                            
                        }
                        
                        
                    }
                    
                }
            }else{
                //发送文件的方式
                for asset in assets {
                    
                    TZImageManager.default()!.getOriginalPhotoData(with: asset, completion: { (imageData, info, isDegraded) in
                        guard let data = imageData, let filename = asset.value(forKey: "filename") as? String else { return }
                        
                        self.sendFile(fileData: data, fileName: filename)
                    })
                    
                    
                    
                }
                
            }
            
            
            
        }
    }
    
    //视频
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingVideo coverImage: UIImage!, sourceAssets asset: PHAsset!) {
        self.dismisskeyboard()
        
        var isSendFile = false
        if let CODPicker = picker as? CODTZImagePickerController {
            isSendFile = CODPicker.isSendFile
        }
        
        let time = asset.duration
        
        if self.isEdit {
            
             let manager = PHImageManager.default()
             let options = PHVideoRequestOptions()
             options.isNetworkAccessAllowed = true
             options.version = PHVideoRequestOptionsVersion.current
             options.deliveryMode = PHVideoRequestOptionsDeliveryMode.automatic
            
            let msgID = self.editMessage.msgID
            
             manager.requestAVAsset(forVideo: asset, options: options) { [weak self] (avAsset, avAudioMix, info) in
                
                guard let `self` = self else { return }
                
                 guard info != nil else {
                     return
                 }
                
                 guard let asset1 = avAsset as? AVURLAsset else {
                     return
                 }
                
                DispatchQueue.main.async {
                    self.prepareEditVideoMessage(msgID: msgID, duration: CGFloat(time), firstpic: coverImage, editVideoUrl: asset1.url)
                }

                
            }
            

        } else {
            
            if !isSendFile {
                
                let options = PHVideoRequestOptions()
                options.isNetworkAccessAllowed = true
                
                PHCachingImageManager.default().requestAVAsset(forVideo: asset, options:options, resultHandler: {[weak self] (avAsset, audioMix, info)in
                    guard let `self` = self else { return }
                    
                    guard info != nil else {
                        return
                    }
                    
                    guard let asset1 = avAsset as? AVURLAsset else {
                        return
                    }
                    var videoSize = 0
                    for track in asset1.tracks {
                        
                        if track.mediaType == .video{
                            videoSize = Int(track.totalSampleDataLength)
                        }
                    }
                    
                    let beforeData = videoSize / 1048576
                    guard beforeData > CODAppInfo.getUploadfileAllowsMaxsize()?.int ?? 0 else {
                        let msgIDTemp = UserManager.sharedInstance.getMessageId()
                        DispatchQueue.main.async {
                            self.prepareSendVideoMessage(msgID: msgIDTemp, duration: CGFloat(time), firstpic: coverImage, toID: self.toJID)
                            if let model = CODMessageRealmTool.getMessageByMsgId(msgIDTemp), let videoModel = model.videoModel {
                                
                                _ = videoModel.setValue(asset.localIdentifier, forKey: \.assetLocalIdentifier)
                                
                                self.compressVideoWithPHAsset(msgID: msgIDTemp, asset: asset, savedPath: videoModel.videoId, coverImage: coverImage) { (filePathStr) in
                                    CODProgressHUD.dismiss()
                                }
                                
                            }
                        }
                        return
                    }
                    CustomUtil.showUploadfileAllowsMaxsizeTip()

                })
                
                
            }else{
                //发送文件的方式
                let options = PHVideoRequestOptions()
                options.isNetworkAccessAllowed = true
                options.deliveryMode = .highQualityFormat
                PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { [weak self] (avAsset, audioMix, info) in
                    guard let `self` = self else { return }
                    
                    guard let avAsset = avAsset as? AVURLAsset else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.sendFile(fileURL: avAsset.url)
                    }
                }
            }
            
        }
        
    }
    
    
    //gif
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingGifImage animatedImage: UIImage!, sourceAssets asset: PHAsset!) {
        var isSendFile = false
        if let CODPicker = picker as? CODTZImagePickerController {
            isSendFile = CODPicker.isSendFile
        }
        let imageManager = PHCachingImageManager.init()
        let option = PHImageRequestOptions.init()
        option.resizeMode = PHImageRequestOptionsResizeMode.fast
        option.isSynchronous = true
        imageManager .requestImageData(for: asset, options: option) { (imageData, dataUTI, orientation, info) in
            if !isSendFile {
                self.sendImageMessage(image: animatedImage, isGif: true, imageData: imageData ?? Data(), ishdimg: true)
            }else{
                guard let data = imageData, let filename = asset.value(forKey: "filename") as? String else { return }
                self.sendFile(fileData: data, fileName: filename)
            }
            
        }
    
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType:AnyObject? = info[UIImagePickerController.InfoKey.mediaType] as AnyObject
        if let type:AnyObject = mediaType {
            if type is String {
                let stringType = type as! String
                if stringType == kUTTypeMovie as String {///视频
                    //0.关闭视频拍摄界面
                    picker.dismiss(animated: true, completion: nil)
                    let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as! URL
                    let data = NSData.init(contentsOf: videoURL)
                    //1.设置视频的名字
                    let videoName =  "\(NSDate().timeIntervalSince1970 * 1000000)"
                    //2.获取视频的时间
                    let videoAsset = AVURLAsset(url: videoURL , options: nil)
                    let time = videoAsset.duration
                    let videoTime = CMTimeGetSeconds(time)
                    

                    
                    //3.压缩视频
                    let msgIDTemp = UserManager.sharedInstance.getMessageId()
                    
                    self.prepareEditVideoMessage(msgID: msgIDTemp, duration: CGFloat(videoTime), firstpic: UIImage.getVideoSecondImage(videoURL: videoURL.absoluteString)!, editVideoUrl: videoURL)
                    
 

                }else{//照片
                    //获得照片
                    var image:UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
                    image = image.fixOrientation()
                    // 拍照
                    if picker.sourceType == .camera {
                        //保存相册
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
                    }
                    self.dismiss(animated: true, completion: nil)
                    self.editImageMessage(image: image, imageData: image.pngData(), ishdimg: true)

                }
            }
        }
        
    }
    
    ///压缩视频的方法
    func compressVideoWithVideoURL(videoURL:URL,savedName:NSString,msgID:String,displayName:String?, duration:CGFloat, firstpic: UIImage, toID:String?, completion:@escaping(_ savedPath:NSString?) ->Void){
            ///获取当前的视频目录
            
            guard let model = CODMessageRealmTool.getMessageByMsgId(msgID) else {
                return
            }
            
            let path = CODFileManager.shareInstanceManger().mp4PathWithName (fileName: model.videoModel?.videoId ?? "")
            let smallVideoURL = URL(fileURLWithPath: path as String)
    //        let path =  CODFileManager.shareInstanceManger().filePathWithName(fileName: savedName as String)
            
            try! FileManager.default.moveItem(at: videoURL, to: smallVideoURL)
            
            if let smallData:Data = try? Data.init(contentsOf: smallVideoURL) {
                let afterData = smallData.count / 1048576
                print("压缩后大小：\(afterData)")
                            
                dispatch_async_safely_to_queue(DispatchQueue.main, {
                   
                  if let model = CODMessageRealmTool.getMessageByMsgId(msgID) {
                       
                       _ = model.videoModel?.setValue(smallData.count, forKey: \.size)
                       CODMessageSendTool.default.sendMessage(messageModel: model)
                       
                   }
                     

                })

            }
            
    //        CODVideoCompressTool.compressVideoV2(videoURL, withOutputUrl: NSURL.init(fileURLWithPath: path as String) as URL, complete: {[weak self] (success) in
    //            if success {
    ////                let smallVideoURLString = String(format: "file:///%@", savedName )
    //
    //            print("完成")
    //            }
    //        })
            
            /*
            let videoAsset = AVURLAsset(url: videoURL, options: nil)
            let presets = AVAssetExportSession.exportPresets(compatibleWith: videoAsset)

            if presets.contains(AVAssetExportPreset640x480) {

                if (CODFileManager.shareInstanceManger().conversationVideosPath == nil || CODFileManager.shareInstanceManger().conversationVideosPath?.count == 0){
                    completion(nil);
                    return
                }
                ///获取当前的视频目录
                let path =  CODFileManager.shareInstanceManger().mp4PathWithName(fileName: savedName as String)
                let session = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPreset960x540)
                session?.shouldOptimizeForNetworkUse = true
                session?.outputURL = URL(fileURLWithPath: path)
                let supportedTypeArray = session!.supportedFileTypes as NSArray
                if (supportedTypeArray.contains(AVFileType.mp4)){
                    session?.outputFileType = AVFileType.mp4
                }else if(supportedTypeArray.count == 0){
                    completion(nil);
                    return
                }else{
                    session?.outputFileType = supportedTypeArray.firstObject as? AVFileType
                }
                session?.exportAsynchronously(completionHandler: {
                    if (session?.status == AVAssetExportSession.Status.completed){
                        DispatchQueue.main.async {
                            completion((session?.outputURL?.path as! NSString))
                        }
                    }else{
                        DispatchQueue.main.async {
                            completion(nil);
                        }
                    }
                })
            }
            */
            
        }
    
    
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        if error != nil {
            ///提示图片保存失败
        }
    }
    
    func compressVideoWithPHAsset(msgID:String, asset:PHAsset, savedPath:String,coverImage: UIImage, isEdit: Bool = false, completion: @escaping(_ savedPath:String?) ->Void) {

        let manager = PHImageManager.default()
        let savePath = CODFileManager.shareInstanceManger().mp4PathWithName(fileName: savedPath)
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.version = PHVideoRequestOptionsVersion.current
        options.deliveryMode = PHVideoRequestOptionsDeliveryMode.automatic
        manager.requestAVAsset(forVideo: asset, options: options) { (avAsset, avAudioMix, info) in
            guard info != nil else {
                return
            }
            guard let asset1 = avAsset as? AVURLAsset else {
                return
            }
            let url = asset1.url.absoluteString
//            CODMessager
            if url.count > 0 {
                CODVideoCompressTool.compressVideoV2(asset1.url, withOutputUrl: NSURL.init(fileURLWithPath: savePath) as URL, complete: {(success) in

                    if success {
                        
                        let smallVideoURLString = String(format: "file:///%@", savePath )
                        
                         if let smallVideoURL: URL = URL.init(string: smallVideoURLString) {
                            
                            let smallData:Data = try! Data.init(contentsOf: smallVideoURL)
                            
                             let afterData = smallData.count / 1048576
                             print("压缩后大小：\(afterData)")
                             
                             dispatch_async_safely_to_queue(DispatchQueue.main, {
                                
                                if let model = CODMessageRealmTool.getMessageByMsgId(msgID) {
                                    
                                    _ = model.videoModel?.setValue(smallData.count, forKey: \.size)
                                    
                                    if isEdit {
                                        completion(savePath)
                                    } else {
                                        CODMessageSendTool.default.sendMessage(messageModel: model)
                                    }
                                }

                             })

                         }
                    print("完成")
                    }
                })
            }else {
                print("获取AVAsset失败")
            }
        }
    }
}

