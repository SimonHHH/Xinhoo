//
//  CODDiscoverDetailVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SVProgressHUD

class CODDiscoverDetailPageVM {
    
    let dataSource = BehaviorRelay<[DiscoverHomeSectionVM]>(value: [])
    
    let pageType: CODDiscoverDetailVC.PageType
    
    var commentPR = PublishRelay<(momentsId: String, replayUser: String, replyUserName: String?)>()
    
    let hiddenKeyboardPR = PublishRelay<Bool>()
    
    var deleteMoments = PublishRelay<Void>()
    
    var momentsId: String = ""
    
    init(pageType: CODDiscoverDetailVC.PageType) {
        
        self.pageType = pageType
        
        momentsId = CODDiscoverMessageModel.getModel(id: self.pageType.momentsId)?.serverMsgId ?? ""
    }
    
    func hiddenKeyboard(hidden: Bool) {
        hiddenKeyboardPR.accept(hidden)
    }
    
    
    func comment(replayUser: String = "", replyUserName: String? = nil) {
        
        if pageType.isFail {
            return
        }
        
        commentPR.accept((momentsId: momentsId, replayUser: replayUser, replyUserName: replyUserName))
        
    }
    
    func like() {
        
        if pageType.isFail {
            return
        }
        
        
        DiscoverHttpTools.like(momentsId: momentsId) { [weak self] (_) in
            
            guard let `self` = self else { return }
            
            self.fetchDataFormServer(setDataSource: false)
            
        }
        
    }
    
    func deleteMessage() {
        
        CODAlertVcPresent(confirmBtn: "删除", message: "删除这条朋友圈?", title: "", cancelBtn: "取消", handler: { [weak self] (action) in
            
            guard let `self` = self else { return }
            
            if action.style == .default {
                
                
                
                if self.pageType.isFail {
                    
                    if let model = CODDiscoverMessageModel.getModel(id: self.pageType.momentsId) {
                        CODDiscoverFailureAndSendingListModel.deleteDiscoverModel(discoverModel: model)
                        model.delete()
                        self.deleteMoments.accept(Void())
                    }
                    
                    
                    
                } else {
                    
                    CODProgressHUD.showWithStatus(NSLocalizedString("正在删除...", comment: ""))
                    DiscoverHttpTools.delete(momentsId: self.momentsId) {  (respones) in
                        
                        
                        if JSON(respones.value)["data"]["flag"].boolValue {
                            CODProgressHUD.dismiss()
                            self.deleteMoments.accept(Void())
                        } else {
                            
                            
                            CODProgressHUD.showErrorWithStatus(NSLocalizedString("暂无网络", comment: ""))

                        }
                        
                    }
                }

            }
            
        }, viewController: UIViewController.current()!)
        
        

    }
    
    func dislike() {
        
        if pageType.isFail {
            return
        }
        
        if let model = CODDiscoverMessageModel.getModel(serverMsgId: self.momentsId) {
            DiscoverHttpTools.dislike(momentsId: model.serverMsgId, messageId: model.likerId) { [weak self] (_) in
                
                guard let `self` = self else { return }
                
                self.fetchDataFormServer(setDataSource: false)
                
            }
        }
        
    }
    
    func fetchDataFormDB() {
        
        if let messageModel = CODDiscoverMessageModel.getModel(id: pageType.momentsId) {
            
            let dataSource = self.discoverMessageModelToDataSoucre(messageModel: messageModel)
            
            self.dataSource.accept(dataSource)
            
        }
        
    }
    
    func fetchDataFormServer(setDataSource: Bool = true) {
        
        let param = [
            
            "momentsId": momentsId,
            "userName": UserManager.sharedInstance.jid
            
        ]
        
        HttpManager.share.post(url: HttpConfig.COD_moments_get_moments_by_id, param: param)?.responseDecodableObject(keyPath: "data", completionHandler: { [weak self] (response: AFDataResponse<CODDiscoverJsonModel>) in
            
            guard let `self` = self else { return }
            
            if let value = response.value {
                
                DispatchQueue.realmWriteQueue.async {
                    
                    let messageModel = CODDiscoverMessageModel.createMessageModel(jsonModel: value)
                    messageModel.addToDB()
                    
                    if setDataSource {
                        let dataSource = self.discoverMessageModelToDataSoucre(messageModel: messageModel)
                        self.dataSource.accept(dataSource)
                    }

                }
                
            }
            
            
        })
        
        
    }
    
    func discoverMessageModelToDataSoucre(messageModel: CODDiscoverMessageModel) -> [DiscoverHomeSectionVM] {
        
        let item = CODDiscoverDetailCellNodeVM(model: messageModel)
        
        var dataSource = [
            DiscoverHomeSectionVM(model: "detail", items: [item]),
        ]
        
        if messageModel.likerList.count > 0 {
            
            let likerItem = CODDiscoverDetailLikerCellNodeVM(likerList: messageModel.likerList.detached().toArray())
            dataSource.append(DiscoverHomeSectionVM(model: "liker", items: [likerItem]))
        }
        
        if messageModel.replyList.count > 0 {
            
            let replyList = messageModel.replyList.detached().toArray().map { CODDiscoverDetailCommentCellNodeVM(replyModel: $0) }
            
            dataSource.append(DiscoverHomeSectionVM(model: "reply", items: replyList))
            
        }
        
        return dataSource

    }
    
    
}
