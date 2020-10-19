//
//  DiscoverHttpTools.swift
//  COD
//
//  Created by Sim Tsai on 2020/6/3.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation


struct DiscoverHttpTools {
    
    enum DiscoverHttpError: Int, Error {
        case momentIsDelete = 2000312
    }
    
    
    static func getMomentBackground(targeter: String = UserManager.sharedInstance.jid, completionHandler: ((AFDataResponse<Any>) -> Void)? = nil) {
        
        findComment(targeter: targeter) { (response) in
            let json = JSON(response.value)["data"]
            let backgroundUrl = json["backgroundUrl"].stringValue
            
            if backgroundUrl.count <= 0 {
                return
            }
            
            if let image = UIImage(named: backgroundUrl) {
                
                DiscoverTools.saveMomentBackground(jid: targeter, image)
                
                
            } else {
                
                let urlString = ServerUrlTools.getMomentsServerUrl(fileType: .Image(backgroundUrl, .origin))
                
                if let url = URL(string: urlString) {
                    UserManager.sharedInstance.chooseGoodWork = nil
                    DiscoverTools.downloadMomentBackground(jid: targeter, url: url)
                }
                
                
            }
        }
        
        
    }
    
    static func findComment(targeter: String = UserManager.sharedInstance.jid, completionHandler: ((AFDataResponse<Any>) -> Void)? = nil) {
        
        let params = [
            "requester": UserManager.sharedInstance.jid,
            "targeter": targeter
        ]
        
        HttpManager.share.post(url: HttpConfig.COD_moments_find_comment, param: params)?.responseJSON(completionHandler: { (response) in
            
            
            completionHandler?(response)
            
            
        })
        
    }
    
    static func getNewMoments(completionHandler: ((AFDataResponse<Any>) -> Void)? = nil) {
        
        findComment() { (response) in
            
            let params = [
                "userName": UserManager.sharedInstance.jid
            ]
            
            HttpManager.share.post(url: HttpConfig.COD_moments_get_new_moments, param: params)?.responseJSON(completionHandler: {  (response) in
                
                completionHandler?(response)
                
                
            })
            
        }
        
        
    }
    
    static func getAndUpdateNewMoments() {
        func getPicUrlStr(picId: String) -> String{
            return picId.count > 0 ? picId.getHeaderImageFullPath(imageType: 0) : ""
        }
        
        self.getNewMoments { (response) in
            
            if response.result.isFailure {
                return
            }
            
            let json = JSON(response.value)["data"]
            let spreadMessageCount = json["spreadMessageCount"].intValue
            let spreadMessagePic = json["spreadMessagePic"].stringValue
            let firstPicStr = json["firstPic"].stringValue
            UserManager.sharedInstance.spreadMessageCount = spreadMessageCount
            UserManager.sharedInstance.spreadMessagePic = getPicUrlStr(picId: spreadMessagePic)
            UserManager.sharedInstance.circleFirstPic = getPicUrlStr(picId: firstPicStr)
            
        }
    }
    
    static func dislike(momentsId: String, messageId: String, completionHandler: ((AFDataResponse<Any>) -> Void)? = nil) {
        
        
        HttpManager.share.post(url: HttpConfig.COD_moments_del_praise, param: [
            "momentsId": momentsId,
            "userName": UserManager.sharedInstance.jid,
            "messageId": messageId
        ])?.responseJSON(completionHandler: { (respones) in
            
            
            switch respones.result {
            case .success(let data):
                
                if JSON(data)["data"]["flag"].boolValue {
                    
                    if let model = CODDiscoverMessageModel.getModel(serverMsgId: momentsId) {
                        model.removeLiker(UserManager.sharedInstance.jid)
                    }
                    
                }
                
                
            case .failure(_):
                break
            }
            
            completionHandler?(respones)
            
            
        })
        
    }
    
    static func like(momentsId: String, completionHandler: ((AFDataResponse<Any>) -> Void)? = nil) {
        
        HttpManager.share.post(url: HttpConfig.COD_moments_add_praise, param: [
            "momentsId": momentsId,
            "userName": UserManager.sharedInstance.jid
        ])?.responseJSON(completionHandler: {  (respones) in
            
            switch respones.result {
            case .success(let data):
                
                guard let model = CODDiscoverMessageModel.getModel(serverMsgId: momentsId) else {
                    completionHandler?(respones)
                    return
                }
                
                let json = JSON(data)
                
                if let likeId = json["data"]["messageId"].int {
                    model.like(likerId: likeId.string)
                }
                
                if json["code"].intValue == DiscoverHttpTools.DiscoverHttpError.momentIsDelete.rawValue {
                    
                    CODDiscoverFailureAndSendingListModel.insertModelToDeletedLikeFailList(model)
                    model.like()
                    
                    completionHandler?(.init(request: respones.request, response: respones.response, data: respones.data, metrics: respones.metrics, serializationDuration: respones.serializationDuration, result: .failure(.createURLRequestFailed(error: DiscoverHttpTools.DiscoverHttpError.momentIsDelete))))
                    
                    
                    
                    return
                    
                }
                
                
            case .failure(_):
                break
            }
            
            completionHandler?(respones)
            
            
        })
        
    }
    
    static func delete(momentsId: String, completionHandler: ((AFDataResponse<Any>) -> Void)? = nil) {
        
        
        HttpManager.share.post(url: HttpConfig.COD_moments_del_moments, param: [
            "momentsId": momentsId,
            "userName": UserManager.sharedInstance.jid
        ])?.responseJSON(completionHandler: {  (respones) in
            
            if respones.result.isFailure != true {
                CODDiscoverMessageModel.getModel(serverMsgId: momentsId)?.delete()
            }
            
            completionHandler?(respones)
        })
        
    }
    
    static func getMoments(id: String, completionHandler: ((AFDataResponse<CODDiscoverJsonModel>) -> Void)? = nil) {
        
        let param = [
            
            "momentsId": id,
            "userName": UserManager.sharedInstance.jid
            
        ]
        
        HttpManager.share.post(url: HttpConfig.COD_moments_get_moments_by_id, param: param)?.responseDecodableObject(keyPath: "data", completionHandler: {  (response: AFDataResponse<CODDiscoverJsonModel>) in
            
            if let value = response.value {
                
                DispatchQueue.realmWriteQueue.async {
                    
                    let messageModel = CODDiscoverMessageModel.createMessageModel(jsonModel: value)
                    messageModel.addToDB()
                    
                    DispatchQueue.main.async {
                        
                        try? Realm().refresh()
                        completionHandler?(response)
                    }
                    
                    
                }
                
            } else {
                completionHandler?(response)
            }
            
        })
        
    }
    
    static func getUserMomentsPics(jid: String = UserManager.sharedInstance.jid, completionHandler: ((AFDataResponse<Any>) -> Void)? = nil) {
        
        let param = [
            "userName": UserManager.sharedInstance.jid,
            "tarName": jid
        ]
        
        HttpManager.share.post(url: HttpConfig.COD_moments_get_user_moments_pic, param: param)?.responseJSON(completionHandler: {  (respones) in
            
            completionHandler?(respones)
        })
        
        
        
    }
    
    static func setUserMomentsBackground(pic: String, completionHandler: ((AFDataResponse<Any>) -> Void)? = nil) {
        
        let param = [
            "userName": UserManager.sharedInstance.jid,
            "backgroundUrl": pic
        ]
        
        HttpManager.share.post(url: HttpConfig.COD_moments_set_moments_background, param: param)?.responseJSON(completionHandler: {  (respones) in
            
            completionHandler?(respones)
        })
        
        
    }
    
    
    
}

