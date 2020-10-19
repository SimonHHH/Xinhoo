

//
//  CODUploadTool.swift
//  COD
//
//  Created by 1 on 2019/4/25.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODUploadTool: NSObject {
    static var `default`: CODUploadTool  = CODUploadTool()
    
    var uploadingModel:CODMessageModel? = nil
    var toBeUploadArray = [CODMessageModel]()
    
    func pictureUpload(model: CODMessageModel) {
        self.uploadPictureOrVideo(model: model)
    }
    
    func uploadPictureOrVideo(model: CODMessageModel) {

        if !CODWebRTCManager.whetherConnectedNetwork() {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            self.uploadFailMessage(model: model)
            return
        }
        
        let uploadMessage = model.editMessage ?? model
        let msgID = model.msgID
//        if model.editMessage != nil {
//            uploadMessage = model.editMessage ?? CODMessageModel()
//        }
        
        let key = uploadMessage.photoModel?.photoLocalURL ?? uploadMessage.videoModel?.videoId ??  uploadMessage.location?.locationImageId
        
        if let pictureImageData = CODImageCache.default.originalImageCache?.diskImageData(forKey: key) {
            
            var ishdimg = "1"
            if uploadMessage.type == .image {
                if uploadMessage.photoModel?.ishdimg ?? false {
                    ishdimg = "1"
                } else {
                    ishdimg = "0"
                }
            }
            var type = "Single"
            switch model.chatTypeEnum {
            case .groupChat:
                type = "Group"
            case .channel:
                type = "Channel"
            case .privateChat:
                type = "Single"
            }
            
            
            var receivername = model.toJID
            if model.toJID.contains(kCloudJid) {
                receivername = "clouddisk"
            }
            
            let paramDic = ["receivername":receivername,"type":type ,"ishdimg":ishdimg,"filetype":"Image"]
            
            NSLog("================开始上传图片")
            self.uploadingModel = self.toBeUploadArray.first
            
            HttpManager.share.postImage(imageData: pictureImageData, url:HttpConfig.uploadUrl, params: paramDic,isGIF: model.photoModel?.isGIF ?? false, progressBlock: { (progress) in
                dispatch_async_safely_to_main_queue({
                    if model.type == .image {
                        NotificationCenter.default.post(name: NSNotification.Name.init(kUploadCellUpdateNoti), object: nil,
                                                        userInfo: [
                                                            "progress": Float(progress),
                                                            "messageID": msgID
                        ])
                    }
                })
            }, successBlock: {[weak self] (success, jsonString) in
                if let message = jsonString["data"]["attId"].string {
                    
                    if model.editMessage != nil {
                        model.editMessage?.photoModel?.updateInfo(size: pictureImageData.count)
                    }else{
                        model.photoModel?.updateInfo(size: pictureImageData.count)
                    }
                    self?.pictureUploadSuccess(model: model, picID: message)

                    if model.type != .video { //视频发送分视频和帧图片，视频和帧图片上传成功才算成功
                        self?.uploadingModel?.uploadState = CODMessageFileUploadState.UploadSucceed.rawValue
                    }
                }
            }) { (error) in
                CODProgressHUD.showErrorWithStatus(error.message)
            }
        }
        
    }

    func fileUpload(model: CODMessageModel) {
        
        if model.fileModel?.fileLocalString.removeAllSapce.count == 0 {
            CODMessageRealmTool.updateMessageStyleByMsgId(model.msgID, status: CODMessageStatus.Failed.rawValue, sendTime: model.datetimeInt)
            return
        }
        
        let smallVideoURL: URL = URL.init(fileURLWithPath: model.fileModel?.fileLocalString ?? "")
        if let videoData:Data = try? Data.init(contentsOf: smallVideoURL){
            
            var toJID = model.toJID
            if toJID.contains(kCloudJid) {
                toJID = "clouddisk"
            }
            
            var type = "Single"
            switch model.chatTypeEnum {
            case .privateChat:
                type = "Single"
            case .groupChat:
                type = "Group"
            case .channel:
                type = "Channel"
            }
            
            let paramDic = ["receivername":model.toJID,"type":type,"filetype":"Document", "ishdimg": "0"]
            
            HttpManager.share.postFile(video: videoData, url: HttpConfig.uploadUrl, fileName: model.fileModel?.filename ?? "", params: paramDic, progressBlock: { (progress) in
                
            }, successBlock: {[weak self](success, jsonString) in
                
                if let message = jsonString["data"]["attId"].string {
                    
                    DispatchQueue.main.async {
                        self?.fileUploadSuccess(model: model, fileString: message)
                    }
                }
            }) {[weak self] (error) in
                
                CODMessageRealmTool.updateMessageStyleByMsgId(model.msgID, status: CODMessageStatus.Failed.rawValue, sendTime: model.datetimeInt)
                self?.postAUpdateMessageToView(messageID: model.msgID)
            }
        }
    }
    
    func voiceMessageUpload(model: CODMessageModel) {
        
        var receivername = model.toJID
        if receivername.contains(kCloudJid) {
            receivername = model.toJID
        }
        
        var type = "Single"
        switch model.chatTypeEnum {
        case .privateChat:
            type = "Single"
        case .groupChat:
            type = "Group"
        case .channel:
            type = "Channel"
        }
        
        
        let paramDic = ["file":".mp3","receivername":model.toJID,"type":type, "filetype":"MVoice", "ishdimg": "0"]
        
                    
        if let voiceData = try? Data(contentsOf: URL(fileURLWithPath: CODFileManager.shareInstanceManger().mp3PathWithName(sessionID: receivername, fileName: model.audioModel?.audioLocalURL ?? ""))) {
            
            HttpManager.share.postVideo(video: voiceData, url: HttpConfig.uploadUrl, params: paramDic, progressBlock: { (progress) in
                
            }, successBlock: { (success, jsonString) in
                
                if let message = jsonString["data"]["attId"].string {
                    
                    CODMessageRealmTool.getExistMessage(model.msgID)?.audioModel?.setValue(\.audioURL, value: message)
                     model.audioModel?.audioURL = message
                     CODMessageSendTool.default.sendMessage(messageModel: model)
                }
            }) {[weak self] (error) in
                
                CODMessageRealmTool.updateMessageStyleByMsgId(model.msgID, status: CODMessageStatus.Failed.rawValue, sendTime: model.datetimeInt)
                self?.postAUpdateMessageToView(messageID: model.msgID)
            }
        }
    }
}

extension CODUploadTool{
    
    func uploadFailMessage(model: CODMessageModel) {
        
        CODMessageRealmTool.updateMessageStyleByMsgId(model.msgID, status: CODMessageStatus.Failed.rawValue, sendTime: model.datetimeInt)
        self.postAUpdateMessageToView(messageID: model.msgID)
        self.uploadingModel = model
        self.uploadingModel?.uploadState = CODMessageFileUploadState.UploadFailed.rawValue
    }

    func pictureUploadSuccess(model: CODMessageModel,picID: String) {
        
        if model.statusType == .Succeed {
            return
        }
        
        if model.type == .image {
            if model.editMessage != nil {
                model.editMessage?.photoModel?.updateInfo(serverImageId: picID)
            }
            model.photoModel?.updateInfo(serverImageId: picID)
            CODMessageSendTool.default.sendMessage(messageModel: model)
        } else if model.type == .location {
            model.location?.locationImageString = picID
            CODMessageSendTool.default.sendMessage(messageModel: model)
        }
    }
    
    func fileUploadSuccess(model: CODMessageModel,fileString: String) {
        model.fileModel?.fileID = fileString
        CODMessageSendTool.default.sendMessage(messageModel: model)
    }
    
    func postAUpdateMessageToView(messageID: String) {
        NotificationCenter.default.post(name: NSNotification.Name.init(kUpdataMessageStatueView), object: nil, userInfo: ["id":messageID])
    }
    
}
