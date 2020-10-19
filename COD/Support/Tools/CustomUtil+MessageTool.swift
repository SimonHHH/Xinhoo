//
//  CustomUtil+MessageTool.swift
//  COD
//
//  Created by 1 on 2020/4/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

extension CustomUtil{
    
    class func getRefertoString(message:CODMessageModel) -> String?{
        
        return ["msgId":message.msgID,"sendTime":message.datetime].jsonString()
    }
    
    class func getImageNameWithSuffix(str:String?) -> String {
        
        if str == nil {
            return "icon_file_unfile"
        }
        
        let suffix = str!.pathExtension.lowercased()
        var imageName = ""
        switch suffix {
        case "ppt","key":
            imageName = "icon_file_ppt"
            break
        case "txt","rtf":
            imageName = "icon_file_txt"
            break
        case "excel","xlsx","xls","numbers":
            imageName = "icon_file_excel"
            break
        case "zip":
            imageName = "icon_file_zip"
            break
        case "json":
            imageName = "icon_file_json"
            break
        case "pdf":
            imageName = "icon_file_pdf"
            break
        case "word","pages","docx","doc":
            imageName = "icon_file_word"
            break
        default:
            imageName = "icon_file_unfile"
            break
        }
        
        return imageName
    }
    
    class func showUploadfileAllowsMaxsizeTip() {
        let allowsMaxsize = CODAppInfo.getUploadfileAllowsMaxsize()?.int ?? 0
        var sizeString = ""
        if allowsMaxsize >= 1024 {
            
            sizeString = String.init(format:"%.1fG",Double(allowsMaxsize)/1024.0)
        }else {
            sizeString = String.init(format:"%ldM",allowsMaxsize)
        }
        CODProgressHUD.showWarningWithStatus(String.init(format: NSLocalizedString("选取的视频不能超过%@哦", comment: ""), sizeString))
    }

    
    class  func getVideoChatType(videoString: String) -> VideoCallType {
        var videoCalltype: VideoCallType = .request
        
        switch videoString {
        case "request":
            videoCalltype = .request
        case "accept":
            videoCalltype = .accept
        case "close":
            videoCalltype = .close
        case "reject":
            videoCalltype = .reject
        case "cancel":
            videoCalltype = .cancle
        case "calltimeout":
            videoCalltype = .timeout
        case "busy":
            videoCalltype = .busy
        case "connectfailed":
            videoCalltype = .connectfailed
        default:
            videoCalltype = .request
            break
        }
        return videoCalltype
    }
    
    class func getVideoChatContentString(messageModel: CODMessageModel) -> String {
        let type = self.getVideoChatType(videoString: messageModel.text)
        
        let isSelfCall = UserManager.sharedInstance.jid == messageModel.fromJID
        
        var  contentText = ""
        switch type {
        case .close:
            contentText = NSLocalizedString("通话时长 ", comment: "") + CustomUtil.transToHourMinSec(time:Float(messageModel.videoCallModel?.duration ?? 0))
            break
        case .reject:
            contentText = isSelfCall ? "对方已拒绝" : "已拒绝"
            break
        case .cancle:
            contentText = isSelfCall ? "已取消" : "对方已取消"
            break
        case .timeout:
            contentText = isSelfCall ? "对方无应答" : "未接来电"
            break
        case .busy:
            contentText = isSelfCall ? "对方忙" : "忙线未接听"
            break
        case .connectfailed:
            contentText = "连接失败"
            break
        default:
            contentText = ""
        }
        return contentText
    }
    
    class func isVideoByFileName(fileName:String) -> Bool {
        
        let phonoNames = ["gif", "jpeg", "jpg", "bmp", "png","jfif","tif","pcx","tga","exif","fpx","svg","cdr","pcd","dxf","ufo","eps","ai","raw","WMF","webp"]
        let fileArry: [String] = fileName.components(separatedBy: ".")
        if let fileNameString:String = fileArry.last {
            
            if phonoNames.contains(fileNameString){
                return false
            }else{
                return true
            }
        }
        
        return false
    }
    
    class func validate(model:CODMessageModel,otherModel:CODMessageModel) -> Bool {
        
        let isSelfcall = model.fromJID == UserManager.sharedInstance.jid ? true :false
        let isSelfCallOther = otherModel.fromJID == UserManager.sharedInstance.jid ? true :false
        
        let arr = ["cancel","busy","calltimeout","connectfailed"] //未接来电
        let otherArr = ["close","reject","cancel","busy","calltimeout","connectfailed"] //所有语音通话类型
        
        if arr.contains(model.text) && arr.contains(otherModel.text) && isSelfcall == isSelfCallOther && model.msgType == otherModel.msgType {
            return true
        }else if otherArr.contains(model.text) && otherArr.contains(otherModel.text) && isSelfcall == isSelfCallOther && model.msgType == otherModel.msgType && (model.fromJID == UserManager.sharedInstance.jid || (model.toJID == UserManager.sharedInstance.jid && !arr.contains(model.text) && !arr.contains(otherModel.text))) {
            return true
        }else{
            return false
        }
    }
    
    class func validateMissedCall(model:CODMessageModel) -> Bool {
        let arr = ["cancel","busy","calltimeout","connectfailed"] //未接来电
        if arr.contains(model.text) {
            return true
        }else{
            return false
        }
    }
    
    @objc class func getMessageNickname(msgID: String) -> String{
        var nickname: String?
        if let  messageModel = CODMessageRealmTool.getMessageByMsgId(msgID) {
            //先判断是不是群组消息
            
            switch messageModel.chatTypeEnum {
            case .groupChat:
                //是群消息就去获取消息对应的群成员
                let memberId = CODGroupMemberModel.getMemberId(roomId: messageModel.roomId, userName:messageModel.fromWho)
                if let member = CODGroupMemberRealmTool.getMemberById(memberId) {
                    //如果成员存在，则去判断当前消息是不是来自于自己，是自己就去自己的昵称，不是自己就取群成员的昵称
                    nickname = messageModel.fromWho.contains(UserManager.sharedInstance.loginName!) ? UserManager.sharedInstance.nickname : member.getMemberNickName()
                }else{
                    //如果成员不存在，则直接取自己的昵称
                    nickname = UserManager.sharedInstance.nickname
                }
                
            case .privateChat:
                //不是群消息就判断当前消息是不是来自于自己
                if  messageModel.fromWho.contains(UserManager.sharedInstance.loginName!) {
                    nickname = UserManager.sharedInstance.nickname
                }else{
                    //消息不是来自自己，就去获取联系人，取联系人的昵称
                    if let contact = CODContactRealmTool.getContactByJID(by: messageModel.fromJID) {
                        nickname = contact.getContactNick()
                    }
                }
                
            case .channel:
                //TODO: 频道对应处理
                break
                
            }
            
            
        }
        return nickname ?? ""
    }
    
    @objc class func getMessageTime(msgID: String) -> String{
        
        var timeString: String?
        if let  messageModel = CODMessageRealmTool.getMessageByMsgId(msgID) {
            timeString = Date.init(timeIntervalSince1970:(Double(messageModel.datetime))!/1000).shortTimeTextOfDate()
        }
        return timeString ?? ""
    }
    
    @objc class func getCircleMessage(msgID: String) -> CODDiscoverMessageModel?{
        
        if let messageModel = CODDiscoverMessageModel.getModel(id: msgID) {
            return messageModel
        }
        return nil
    }
    
    @objc class func getCircleMessageTime(messageModel: CODDiscoverMessageModel) -> String{
        
        return DiscoverTools.toImageBrowserString(time: messageModel.createTime)
        //        return TimeTool.getTimeStringAutoShort2(Date.init(timeIntervalSince1970:TimeInterval((messageModel.createTime)/1000)), mustIncludeTime: true, theOffSetMS: UserManager.sharedInstance.timeStamp)
    }
    
    @objc class func deleteCircleMessage(msgID: String, currentPage: Int,photoBrowser: YBImageBrowser, handler:@escaping(String) ->Void) {
        
        if let messageModel = CODDiscoverMessageModel.getModel(id: msgID) {
            
            var confirmBtnString = "删除"
            var messageString = "要删除这张照片吗？"
            
            if messageModel.msgTypeEnum == .image && messageModel.imageList.count > 1 {
                
                confirmBtnString = "全部删除"
                messageString = "与这张照片同时发布的一组照片都会被删除"
            }else if messageModel.msgTypeEnum == .video{
                
                messageString = "要删除这个视频吗？"
            }
            
            
            CODAlertVcPresent(confirmBtn: confirmBtnString, message: messageString, title: nil, cancelBtn: "取消", handler: {(action) in
                if action.style == .default {
                    
                    CODProgressHUD.showWithStatus(NSLocalizedString("正在删除...", comment: ""))
                    DiscoverHttpTools.delete(momentsId: messageModel.serverMsgId) {(respones) in
                        
                        CODProgressHUD.dismiss()
                        
                        if JSON(respones.value)["data"]["flag"].boolValue {
                            CustomUtil.isPlayVideo(isPlay: false,isDelete: true)
                            //                            CODProgressHUD.showSuccessWithStatus()
                            handler(NSLocalizedString("已删除", comment: ""))
                            if currentPage == 0 || (photoBrowser.dataSourceArray.count) - messageModel.imageList.count <= 0 {
                                
                                if (photoBrowser.dataSourceArray.count) - messageModel.imageList.count <= 0 || (photoBrowser.dataSourceArray.count) == 1 {
                                    
                                    NotificationCenter.default.post(name: NSNotification.Name.init("kHideBrowser"), object: nil, userInfo: nil)
                                }else{
                                    
                                }
                            }else{
                                
                            }
                            
                        } else {
                            handler(NSLocalizedString("暂无网络", comment: ""))
                            //                            CODProgressHUD.showErrorWithStatus(NSLocalizedString("暂无网络", comment: ""))
                        }
                        
                    }
                }
            }, viewController: UIViewController.current() ?? UIViewController())
            
        }
        
    }
    
    //朋友圈图片浏览分享
    @objc class func shareCircleMessage(msgID: String, data: YBIBImageData) {
        
        self.shareHomeCircleMessage(msgID: msgID, data: data, fromType: .Moments)
    }
    
    //朋友圈图片浏览分享
    class func shareHomeCircleMessage(msgID: String, data: YBIBImageData, fromType: CODShareImagePickerFromType = .HomeMoments) {
        
        if let circleModel = CODDiscoverMessageModel.getModel(id: msgID) {
            let shareView = CODShareImagePicker(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
            shareView.contactListArr = CODGlobalDataSource.getContactGroupChannelModelData(isHeadCloudDisk: true, ignoreIDs: [NewFriendRosterID])
            shareView.msgID = msgID
            shareView.fromType = fromType
            shareView.messageModel = self.transCircleMessageToMessageModel(msgID: msgID)
            if circleModel.msgTypeEnum == .video {
               shareView.msgUrl = data.thumbURL?.absoluteString ?? ""
            }else{
                shareView.msgUrl = data.imageURL?.absoluteString ?? ""
            }
            shareView.show()
        }
        
    }
    
    //朋友圈图片浏览收藏
    @objc class func collectionCircleMessage(msgID: String, imageData: YBIBImageData) {
        
        if let messageModel = self.transCircleMessageToICouldMessageModel(msgID: msgID, imageData: imageData) {

            let fileIds = CustomUtil.getMessageFileIDS(messages: [messageModel])
            
            HttpTools.vaildandTranfile(attIdList: fileIds, type: .MomentToCloudDisk)
            CustomUtil.copyMediaFile(messageModel: messageModel, fromPathJid: DiscoverHomeCache, toPathJid: messageModel.toJID)

            CODChatListRealmTool.addChatListMessage(id: CloudDiskRosterID, message: messageModel)
            CODMessageSendTool.default.sendMessage(messageModel: messageModel, sender: messageModel.fromWho)
//            NotificationCenter.default.post(name: NSNotification.Name.init("kCollectionmessage"), object: nil)
            
//            if messageModel.type == .image {
                CODProgressHUD.showSuccessWithStatus(NSLocalizedString("已收藏至云盘", comment: ""))
//            }
            
        }
    }
    
    @objc class func transCircleMessageToMessageModel(msgID: String)-> CODMessageModel? {
    
        if let circleModel = CODDiscoverMessageModel.getModel(id: msgID) {
            
            let msgIDTemp = UserManager.sharedInstance.getMessageId()
            let messageModel = CODMessageModelTool.default.createBaseModel(msgID: msgIDTemp, toJID: "", chatType: .privateChat, roomId: nil, chatId: 0, burn: 0)
            if circleModel.msgTypeEnum == .image {
                
                messageModel.type = .image
                if circleModel.imageList.count == 1 {
                    messageModel.photoModel = circleModel.imageList[0]
                }else{
                    messageModel.imageList = circleModel.imageList
                    messageModel.type = .multipleImage
                }

            }else{
                
                messageModel.type = .video
                messageModel.videoModel = circleModel.video
            }
            
            return CODMessageSendTool.default.getCopyModel(messageModel: messageModel)
        }

        return nil
        
    }
    
    @objc class func transCircleMessageToICouldMessageModel(msgID: String,imageData: YBIBImageData) -> CODMessageModel?  {
        
        if let messageModel = self.transCircleMessageToMessageModel(msgID: msgID) {
            
            if messageModel.type == .multipleImage {
                
                messageModel.photoModel = self.imageListTransPhotoModel(messageModel: messageModel, messageUrl: imageData.imageURL?.absoluteString ?? "")
                
                messageModel.type = .image

            }
            
            
            messageModel.imageList = List<PhotoModelInfo> ()
            messageModel.msgID = UserManager.sharedInstance.getCloudDiskMessageId()
            if let contactModel = CODContactRealmTool.getContactByJID(by: kCloudJid) {
                messageModel.toJID = contactModel.jid
                messageModel.toWho = contactModel.jid
                messageModel.burn = contactModel.burn
                messageModel.chatTypeEnum = .privateChat
                let timestr = String(format: "%ld", Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp)
                messageModel.datetime = timestr
                messageModel.datetimeInt = Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp
                messageModel.status =  CODMessageStatus.Pending.rawValue
                messageModel.fromJID = UserManager.sharedInstance.jid
                messageModel.fromWho = UserManager.sharedInstance.jid
                messageModel.chatTypeEnum = .privateChat
                messageModel.isReaded = false
                messageModel.isDelete = false
                messageModel.isReadedDestroy = false
                messageModel.edited = 0
                messageModel.rp = ""
                return messageModel
            }
        }
        
        return nil

    }
    class func imageListTransPhotoModel(messageModel: CODMessageModel,messageUrl: String) -> PhotoModelInfo?{
        var imageModel: PhotoModelInfo?
        
        for photoModel in messageModel.imageList {
            if photoModel.serverImageId.getImageFullPath(imageType: 1) == messageUrl.getImageFullPath(imageType: 1) || messageUrl.contains(photoModel.serverImageId)  {
                let copyPhotoModel = PhotoModelInfo.deserialize(from: photoModel.toJSONString())
                imageModel = copyPhotoModel
                imageModel?.photoId = UUID().uuidString
                imageModel?.photoImageData = photoModel.photoImageData
                imageModel?.serverImageId = photoModel.serverImageId
                imageModel?.photoLocalURL = photoModel.photoLocalURL
                imageModel?.descriptionImage = photoModel.descriptionImage
                imageModel?.serverImageId = photoModel.serverImageId
            }
        }
        return imageModel
    }
    class func isPlayVideo(isPlay: Bool,isDelete: Bool = false) {
        if isPlay {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kYBIBVideoPlay"), object: nil, userInfo: ["isPlay" : "1"])
        }else{
            
            if isDelete {
                HttpManager.share.requestManager?.cancel()
                HttpManager.share.requestManager = nil
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kYBIBVideoPlay"), object: nil, userInfo: ["isPlay" : "0"])
        }
    }
    
    
    @objc class func getCircleMessagePage(messageModel: CODDiscoverMessageModel, photoId: String) -> String{
        
        if messageModel.msgTypeEnum == .image{
            
            if messageModel.imageList.count > 1 {
                let imageIndex = messageModel.imageList.firstIndex(where: {$0.photoId == photoId}) ?? 0
                
                return "\(imageIndex + 1)/\(messageModel.imageList.count)"
            }
        }
        
        return ""
    }
    
    @objc class func showCircleActionSheet(msgID: String,superView: UIView,imageData: YBIBImageData,handler:@escaping(String) ->Void) {
        
        let blueColor = RGBA(r: 4, g: 126, b: 245, a: 1)
//        let messageModel = self.getCircleMessage(msgID: msgID) ?? CODDiscoverMessageModel()
        var otherButtonTitles: NSArray = []
        var otherButtonColors: NSArray = []
//        let openString = (messageModel.msgTypeEnum == .image) ? ((messageModel.msgPrivacyTypeEnum == .Private) ? "设为公开照片" : "设为私密照片") : ((messageModel.msgPrivacyTypeEnum == .Private) ? "设为公开视频" : "设为私密视频")
//        let saveString = (messageModel.msgTypeEnum == .image) ? "保存图片" : "保存视频";

        let sendFriendString = "发送给朋友";
        let colltionString = "收藏";
        let saveString  = "保存图片"

        otherButtonTitles = [sendFriendString,colltionString,saveString];
        otherButtonColors = [blueColor,blueColor,blueColor,];
        
        let sendFriendInt = otherButtonTitles.index(of: sendFriendString) + 1
        let colltionInt = otherButtonTitles.index(of: colltionString) + 1
        let saveInt = otherButtonTitles.index(of: saveString) + 1
        
        CODActionSheet.show(withTitle: "", cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: otherButtonTitles as? [Any], cancelButtonColor: blueColor, destructiveButtonColor: blueColor, otherButtonColors: otherButtonColors as? [Any], superView:superView) { (actionSheet, index) in
 
            if index == saveInt{
                NotificationCenter.default.post(name: NSNotification.Name.init("kSavemessage"), object: nil)
                handler("")
//            }
//            }else if index == deleteInt {
                //删除朋友圈
//                self.deleteCircleMessage(msgID: <#T##String#>, currentPage: <#T##Int#>, photoBrowser: <#T##YBImageBrowser#>, handler: <#T##(String) -> Void#>)
//            }else if index == openInt {

            }else if index == sendFriendInt {
                CustomUtil.shareHomeCircleMessage(msgID: msgID, data: imageData)

            }else if index == colltionInt {

                CustomUtil.collectionCircleMessage(msgID: msgID, imageData: imageData)
            }
            
        }

    }
    
    @objc class func getUserJID() -> String{
        
        return UserManager.sharedInstance.jid
    }
    
    class func getMessageFileIDS(messages: Array<CODMessageModel>) -> Array<String> {
        var fileIDs: Array<String> = []
        for messageModel in messages {
            //判断服务器是不是存在这个文件
            let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: (messageModel.msgType)) ?? .text
            
            if modelType == .image {
                if messageModel.photoModel?.serverImageId.count ?? 0 > 0 {
                    fileIDs.append(messageModel.photoModel?.serverImageId ?? "")
                }
            }else if modelType == .video{
                
                if messageModel.videoModel?.serverVideoId.count ?? 0 > 0  && messageModel.videoModel?.firstpicId.count ?? 0 > 0{
                    
                    fileIDs.append(messageModel.videoModel?.serverVideoId ?? "")
                    fileIDs.append(messageModel.videoModel?.firstpicId ?? "")
                }
            }else if modelType == .file {
                if messageModel.fileModel?.fileID.count ?? 0 > 0 {
                    fileIDs.append(messageModel.fileModel?.fileID ?? "")
                }
                if messageModel.fileModel?.thumb.count ?? 0 > 0 {
                    fileIDs.append(messageModel.fileModel?.thumb ?? "")
                }
            }else if modelType == .location {
                if messageModel.location?.locationImageString.count ?? 0 > 0 {
                    fileIDs.append(messageModel.location?.locationImageString ?? "")
                }
            }else if modelType == .audio {
                if messageModel.audioModel?.audioURL.count ??  0 > 0 {
                    fileIDs.append(messageModel.audioModel?.audioURL ?? "")
                }
            }else if modelType == .multipleImage {
                
                for photo in messageModel.imageList {
                    
                    fileIDs.append(photo.serverImageId)
                    
                }
                
            }
        }
        return fileIDs
    }
    
    
    @objc class func getMessageImageCount(msgID: String) -> Int{
        
        if let  messageModel = CODMessageRealmTool.getMessageByMsgId(msgID) {
            
            return messageModel.imageList.count
        }
        return 0
    }
    
    class func messageToImageDataArray(model: CODMessageModel, isCloudDisk: Bool = false) -> [YBIBDataProtocol]? {
        
        var imageDataArray: [YBIBDataProtocol] = []
        
        if model.type == .multipleImage {
            
            
            for photo in model.imageList {
                
                let imageData = YBIBImageData()
                imageData.msgID = model.msgID
                imageData.photoId = photo.photoId
                
                if photo.photoLocalURL.isEmpty == false, let imagePath = CODImageCache.default.originalImageCache?.cachePath(forKey: photo.photoLocalURL) {
                    imageData.imagePath = imagePath
                    imageData.imageURL = URL(string: photo.serverImageId.getImageFullPath(imageType: 3, isCloudDisk: isCloudDisk))
                    imageData.thumbURL = URL(string: photo.serverImageId.getImageFullPath(imageType: 1, isCloudDisk: isCloudDisk))
                } else {
                    imageData.imageURL = URL(string: photo.serverImageId.getImageFullPath(imageType: 3, isCloudDisk: isCloudDisk))
                    imageData.thumbURL = URL(string: photo.serverImageId.getImageFullPath(imageType: 1, isCloudDisk: isCloudDisk))
                    
                }
                
                imageDataArray.append(imageData)
                
            }
            
            return imageDataArray
            
        } else if model.type == .image || model.type == .video  {
            
            if let data = self.messageToImageData(model: model, isCloudDisk: isCloudDisk) {
                return [data]
            }
            
        }
        
        return nil
        
    }
    
    class func messageToImageData(model: CODMessageModel, isCloudDisk: Bool = false) -> YBIBDataProtocol? {
        
        if model.type == .image {
            
            let imageData = YBIBImageData()
            imageData.msgID = model.msgID
            imageData.photoId = model.photoModel?.photoId
            
            if model.photoModel?.version == 1 {
                if let localUrl = model.photoModel?.photoLocalURL, localUrl.count > 0, let imagePath = CODImageCache.default.originalImageCache?.cachePath(forKey: model.photoModel?.photoLocalURL) {
                    imageData.imagePath = imagePath
                    imageData.thumbURL = URL(string: model.photoModel?.serverImageId.getImageFullPath(imageType: 1, isCloudDisk: isCloudDisk) ?? "")
                } else {
                    imageData.imageURL = URL(string: model.photoModel?.serverImageId.getImageFullPath(imageType: 3, isCloudDisk: isCloudDisk) ?? "")
                    imageData.thumbURL = URL(string: model.photoModel?.serverImageId.getImageFullPath(imageType: 1, isCloudDisk: isCloudDisk) ?? "")
                }
            } else {
                
                if let localUrl = model.photoModel?.photoLocalURL, localUrl.count > 0 {
                    imageData.imagePath = CustomUtil.getImageURL(message: model)
                } else {
                    imageData.imageURL = URL(string: model.photoModel?.serverImageId.getImageFullPath(imageType: 3, isCloudDisk: isCloudDisk) ?? "")
                    imageData.thumbURL = URL(string: model.photoModel?.serverImageId.getImageFullPath(imageType: 1, isCloudDisk: isCloudDisk) ?? "")
                }
                
            }
            
            if model.photoModel?.ishdimg ?? false,let originalUrl = URL.init(string: model.photoModel?.serverImageId.getImageFullPath(imageType: 2,isCloudDisk: isCloudDisk) ?? ""){
                imageData.fullImageURL = originalUrl
                imageData.fullImageSize = "  (" + CODFileHelper.getFileSize(fileSize: CGFloat(model.photoModel?.size ?? 0)) + ")"
                if let imagePath = CustomUtil.movePicPathToConversation(picUrl: originalUrl, filePath: ""),imagePath.count > 0 {
                    //原图已经下载过了
                    imageData.imageURL = originalUrl
                }
            }
            
            return imageData
            
        } else if model.type == .video  {
            
            let videoData = YBIBVideoData()
            videoData.msgID = model.msgID
            videoData.autoPlayCount = 1
            if model.videoModel?.version == 1 {
                if let image = CODImageCache.default.originalImageCache?.imageFromCache(forKey: model.videoModel?.videoId) {
                    videoData.thumbImage = image
                } else {
                    videoData.thumbURL = URL(string: model.videoModel?.firstpicId.getImageFullPath(imageType: 2, isCloudDisk: isCloudDisk) ?? "")
                }
            } else {
                videoData.thumbURL = URL(string: model.videoModel?.firstpicId.getImageFullPath(imageType: 2, isCloudDisk: isCloudDisk) ?? "")
            }
            
            
            videoData.videoURL = CustomUtil.getVideoURL(message: model, isCloudDisk: isCloudDisk)
            
            return videoData
            
        } else if model.type == .file {
            
            let fileType = CODFileHelper.getFileType(fileName: model.fileModel?.filename ?? "")
            
            let fileID = model.fileModel?.fileID ?? ""
            
            if fileType == .ImageType {
                
                let imageData = YBIBImageData()
                imageData.msgID = model.msgID
                imageData.photoId = model.fileModel?.fileID
                
                
                if model.fileModel?.fileExists == true {
                    imageData.imagePath = model.fileModel?.saveFilePath
                } else {
                    
                    if model.isCloudDiskMessage {
                        imageData.imageURL = ServerUrlTools.getServerUrl(store: .CloudDisk(fileType: .File(fileID)))
                    } else {
                        imageData.imageURL = ServerUrlTools.getServerUrl(store: .Message(fileType: .File(fileID)))
                    }
                    
                }
                
                return imageData
                
            } else if fileType == .VideoType {
                
                let videoData = YBIBVideoData()
                
                videoData.msgID = model.msgID
                let thumb = model.fileModel?.thumb ?? ""
                
                if model.fileModel?.fileExists == true {
                    videoData.videoURL = URL(fileURLWithPath: model.fileModel?.saveFilePath ?? "")
                } else {
                    
                    if model.isCloudDiskMessage {
                        videoData.videoURL = ServerUrlTools.getServerUrl(store: .CloudDisk(fileType: .File(fileID)))
                        videoData.thumbURL = ServerUrlTools.getServerUrl(store: .CloudDisk(fileType: .Image(thumb, .medium)))
                    } else {
                        videoData.videoURL = ServerUrlTools.getServerUrl(store: .Message(fileType: .File(fileID)))
                        videoData.thumbURL = ServerUrlTools.getServerUrl(store: .Message(fileType: .Image(thumb, .medium)))
                    }
                    
                }
                
                
                
                return videoData
                
            }
            
            
        }
        
        return nil
    }
    
    class func getIsCloudMessage(messageModel: CODMessageModel?) -> Bool{
        
        if let model = messageModel {
            
            return (model.toJID.contains(kCloudJid) && model.fw.removeAllSapce.count > 0)
        }else{
            
            return false
        }
        
        
    }
    class func getCloudMessageIsHelp(messageModel: CODMessageModel) -> String? {
        if messageModel.fw.contains("cod_60000000") {
            return UIImage.getHelpIconName()
        }
        return nil
    }
    class func getIsCloudMessageHeaderImage(messageModel: CODMessageModel) -> String{
        
        if messageModel.fw.removeAllSapce.count > 0 {
            
            if let contactModel = CODContactRealmTool.getContactByJID(by: messageModel.fw) {
                return contactModel.userpic
            }else if UserManager.sharedInstance.jid.contains(messageModel.fw) {
                return UserManager.sharedInstance.avatar ?? ""
            }else if let memberPic = CODContactRealmTool.searchContactPic(messageModel.fw){
                return memberPic
            }else if let personModel = CODPersonInfoModel.getPersonInfoModel(jid: messageModel.fw) {
                return personModel.userpic
            }else if let channelModel = CODChannelModel.getChannel(jid: messageModel.fw){
                return channelModel.grouppic
            }
        }
        return messageModel.userPic
    }
    
    class func getIsShowFwView(messageModel: CODMessageModel) -> Bool{
        
        if self.getIsCloudMessage(messageModel: messageModel) {
            return false
        }else{
            return messageModel.fw.count > 0 && messageModel.fw != "0"
        }
        
    }
    
    class func getMessageModelNickName(messageModel: CODMessageModel) -> String{
        
        var nickName = ""
        var jid = ""
        if messageModel.fromWho.contains(XMPPSuffix) {
            jid = messageModel.fromWho
        }else{
            jid = messageModel.fromWho + XMPPSuffix
        }
        if messageModel.chatTypeEnum == .channel {
            
            if let channel = CODChannelModel.getChannel(by: messageModel.roomId) {
                nickName = channel.descriptions
            }else{
                nickName = NSLocalizedString("频道", comment: "")
            }
            
        }else if self.getIsCloudMessage(messageModel: messageModel){
            if messageModel.fw.contains(UserManager.sharedInstance.jid) {
                nickName = "我"
            }else{
                nickName = messageModel.fwn
            }
        }else{
            if let member = CODGroupMemberRealmTool.getMemberById(CODGroupMemberModel.getMemberId(roomId: messageModel.roomId, userName: jid)) {
                nickName = member.getMemberNickName()
            }else{
                if let member = CODGroupMemberRealmTool.getMembersByJid(jid)?.first {
                    nickName = member.getMemberNickName()
                }else if let contact = CODContactRealmTool.getContactByJID(by: jid) {
                    nickName = contact.getContactNick()
                }else if let personInfo = CODPersonInfoModel.getPersonInfoModel(jid: jid){
                    nickName = personInfo.name
                }else{
                    nickName = " "
                }
            }
        }
        
        return nickName
    }
    
    class func getMessageModelTextColor(messageModel: CODMessageModel) -> UIColor? {
        var color = ""
        var fromJID = messageModel.fromJID
        
        if self.getIsCloudMessage(messageModel: messageModel) {
            fromJID = messageModel.fw
        }
        
        if let _ = CODChannelModel.getChannel(by: messageModel.roomId) {
            color = kChannelNameColorS
        }else{
            if let memberModelList = CODGroupMemberRealmTool.getMembersByJid(fromJID) {
                color = memberModelList.first!.color
            }else if let contact = CODContactRealmTool.getContactByJID(by: fromJID) {
                color = contact.color
            }else{
                color = kEmptyTitleColorS
            }
        }
        if self.getIsCloudMessage(messageModel: messageModel)  && messageModel.fwf == "C" {
            color = kChannelNameColorS
        }
        
        return UIColor(hexString: color)
    }
    
    class func getUserPic(messageBodyModel: CODMessageHJsonModel) -> String {
        
        var userPic = ""
        
        if messageBodyModel.isCloudDiskMessage {

            if let personInfo = CODPersonInfoModel.getPersonInfoModel(jid: messageBodyModel.fw) {
                userPic = personInfo.userpic
            } else if let channel = CODChannelModel.getChannel(jid: messageBodyModel.fw) {
                userPic = channel.grouppic
            }
            
        } else if let personInfo = CODPersonInfoModel.getPersonInfoModel(jid: messageBodyModel.sender) {
            userPic = personInfo.userpic
        } else if messageBodyModel.chatType == .groupChat || messageBodyModel.chatType == .channel {
            let memberId = CODGroupMemberModel.getMemberId(roomId: messageBodyModel.roomID, userName: messageBodyModel.sender.subStringTo(string: "@"))
            if let memberPic = CODGroupMemberRealmTool.searchMemberPic(memberId) {
                userPic = memberPic
            } else if let memberPic = CODContactRealmTool.searchContactPic(messageBodyModel.sender) {
                userPic = memberPic
            }
            
        } else {
            if let memberPic = CODContactRealmTool.searchContactPic(messageBodyModel.sender) {
                userPic = memberPic
            } else if let userpic = messageBodyModel.setting?.userpic {
                userPic = userpic
            }
        }
        
        return userPic
        
    }
    
    
}
