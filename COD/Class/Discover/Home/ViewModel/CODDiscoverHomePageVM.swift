//
//  CODDiscoverHomePageVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/12.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CodableAlamofire
import SwiftyJSON
import RealmSwift

extension Reactive where Base: CODDiscoverHomePageVM {
    
    var spreadMessageCountBinder: Binder<Int> {
        return Binder(base) { (vm, value) in
            
            if value > 0 {
                vm.addNewMessageNotification()
            } else {
                vm.removeNewMessageNotification()
            }
            
        }
    }
    
}

class CODDiscoverHomePageVM: NSObject {
    
    let newMessageNotificationScetionIdentifier = "CODDiscoverHomePageVM.NewMessageNotification"
    let dataScetionIdentifier = "CODDiscoverHomePageVM.data"
    let sendFailIdentifier = "CODDiscoverHomePageVM.SendFailIdentifier"
    
    var nickName = BehaviorRelay<String>(value: UserManager.sharedInstance.nickname ?? "")
    
    var headerUrl = BehaviorRelay<URL?>(value: URL(string: UserManager.sharedInstance.avatar?.getHeaderImageFullPath(imageType: 1) ?? ""))
    
    
    var commentPR = PublishRelay<(momentsId: String, replayUser: String, replyUserName: String?)>()
    
    var scrollOffsetPR = PublishRelay<(CGFloat)>()
    
    var deleteCommentPR = PublishRelay<IndexPath>()
    
    var lastDataNoAnymorePR = PublishRelay<Void>()
    var fetchDataErrorPR = PublishRelay<Void>()
    var footLoadPR = PublishRelay<Void>()
    var hearLoadPR = PublishRelay<Void>()
    var installEmptyPR = PublishRelay<Void>()
    var installFooterPR = PublishRelay<Void>()
    var reloadCellPR = PublishRelay<IndexPath?>()
    
    let dataSource: BehaviorRelay<[CODDiscoverHomePageSectionVM]>
    
    var likePR = PublishRelay<IndexPath>()
    
    var showErrorPR = PublishRelay<String>()
    
    override init() {
        
        /// 服务器目前最大条数为10条
        let cellVMs = CODDiscoverMessageModel.loadLastMessages(count: 10).map { CODDiscoverHomeCellVM(model: $0) }
        
        dataSource = BehaviorRelay<[CODDiscoverHomePageSectionVM]>(value: [
            CODDiscoverHomePageSectionVM(model: dataScetionIdentifier, items: cellVMs)
        ])
        
        super.init()
        
        UserManager.sharedInstance.rx.spreadMessageCount
            .bind(to: self.rx.spreadMessageCountBinder)
            .disposed(by: self.rx.disposeBag)
        
        
        checkSendFailMessage()
        
        let failureModel = CODDiscoverFailureAndSendingListModel.getFailureModel()
        Observable.arrayWithChangeset(from: failureModel.modelList).bind { [weak self] (result) in
            
            guard let `self` = self else { return }
            if result.1?.deleted.count ?? 0 > 0 {
                self.checkSendFailMessage()
            }
            
            if let inserted = result.1?.inserted, inserted.count > 0 {
                
                for index in inserted {
                    let model = result.0[index]
                    self.insertNewMessage(messageModel: model)
                }
                
            }
            
            if let updated = result.1?.updated, updated.count > 0 {
                self.checkSendFailMessage()
            }
            
        }
        .disposed(by: self.rx.disposeBag)
        
        Observable.arrayWithChangeset(from: failureModel.messageDeletedCommentFailList)
            .bind { [weak self] (result) in
                
                guard let `self` = self else { return }
                if result.1?.deleted.count ?? 0 > 0 {
                    self.checkSendFailMessage()
                }
                
                if result.1?.inserted.count ?? 0 > 0 {
                    self.checkSendFailMessage()
                }
                
        }
        .disposed(by: self.rx.disposeBag)
        
        Observable.arrayWithChangeset(from: failureModel.messageDeletedLikeFailList)
            .bind { [weak self] (result) in
                
                guard let `self` = self else { return }
                if result.1?.deleted.count ?? 0 > 0 {
                    self.checkSendFailMessage()
                }
                
                if result.1?.inserted.count ?? 0 > 0 {
                    self.checkSendFailMessage()
                }
                
        }
        .disposed(by: self.rx.disposeBag)
        
        if let messageModels = try? Realm().objects(CODDiscoverMessageModel.self) {
            
            Observable.changeset(from: messageModels)
                .bind(to: self.rx.deleteMessageBinder)
                .disposed(by: self.rx.disposeBag)
            
        }
        
    }
    
    func findCellVM(model: CODDiscoverMessageModel) -> IndexPath? {
        
        let dataSources = self.dataSource.value
        
        let sectionOpt = dataSources.lastIndex { (value) -> Bool in
            return value.model == dataScetionIdentifier
        }
        
        guard let section = sectionOpt else {
            return nil
        }
        
        guard let items = dataSources[section].items as? [CODDiscoverHomeCellVM] else { return nil }
        
        let rowOpt = items.firstIndex { (cellVM) -> Bool in
            return cellVM.model == model
        }
        
        guard let row = rowOpt else {
            return nil
        }
        
        return IndexPath(row: row, section: section)
        
        
    }
    
    func checkSendFailMessage() {
        
        var failVMs = CODDiscoverFailureAndSendingListModel.getFailureList().map { CODDiscoverNotificationCellVM(style: .fail(failType: .moment, id: $0.msgId)) }
        
        let likeFailVMs = CODDiscoverFailureAndSendingListModel.getMessageDeletedLikeFailList().map {  CODDiscoverNotificationCellVM(style: .fail(failType: .like, id: $0.msgId)) }
        
        let commentFailVMs = CODDiscoverFailureAndSendingListModel.getMessageDeletedCommentFailList().map {  CODDiscoverNotificationCellVM(style: .fail(failType: .comment, id: $0.msgId)) }
        
        failVMs.append(contentsOf: likeFailVMs)
        failVMs.append(contentsOf: commentFailVMs)
        
        if failVMs.count > 0 {
            addNotification(identifier: sendFailIdentifier, vms: failVMs)
        } else {
            removeSendFail()
        }
        
        
    }
    
    func reloadCell(indexPath: IndexPath?) {
        self.reloadCellPR.accept(indexPath)
    }
    
    func removeSendFail() {
        removeNotification(identifier: sendFailIdentifier)
    }
    
    func insertNewMessage(messageModel: CODDiscoverMessageModel) {
        
        var dataSource = self.dataSource.value
        let cellVM = CODDiscoverHomeCellVM(model: messageModel)
        
        if dataScetionIdentifier == dataSource.last?.model {
            dataSource.last?.items.insert(cellVM, at: 0)
        } else {
            dataSource.append(CODDiscoverHomePageSectionVM(model: dataScetionIdentifier, items: [cellVM]))
        }
        
        self.dataSource.accept(dataSource)
        
    }
    
    
    func fetchData(isHeaderLoad: Bool = true, pageNum: Int = 1, size: Int = 10) {
        
        
        var params = CustomUtil.createPageReqParams(.page(pageNum, size, .sort("createTime", .desc)))
        
        params["userName"] = UserManager.sharedInstance.jid
        
        HttpManager.share.post(url: HttpConfig.COD_moments_see_moments, param: params)?.responseJSON(completionHandler: { [weak self] (response) in
            
            guard let `self` = self else { return }
            
            let json = JSON(response.value)
            
            guard let code = json["code"].int else {
                self.fetchDataErrorPR.accept(Void())
                return
            }
            
            if code != 0 {
                self.fetchDataErrorPR.accept(Void())
                return
            }
            
            let pageJson = json["data"]["page"]
            
            if let hasNext = pageJson["hasNext"].bool, hasNext == false {
                self.lastDataNoAnymorePR.accept(Void())
            }
            
            
        }).responseDecodableObject(keyPath: "data.list", completionHandler: { [weak self] (response: AFDataResponse<[CODDiscoverJsonModel]>) in
            
            guard let `self` = self else { return }
            
            DispatchQueue.realmWriteQueue.async {
                
                var cellVMs: [CODDiscoverHomeCellVM] = []
                
                if let value = response.value {
                    
                    let messageModels = value.map { CODDiscoverMessageModel.createMessageModel(jsonModel: $0) }
                    
                    if let lastModel = messageModels.last {
                        
                        messageModels.addToDB()
                        
                        var dbmessageModels: [CODDiscoverMessageModel] = []
                        
                        if isHeaderLoad {
                            dbmessageModels = CODDiscoverMessageModel.loadMessageList(afterTime: lastModel.createTime)
                        } else {
                            
                            if let appeaceLastModel = (self.dataSource.value.last?.items.last as? CODDiscoverHomeCellVM)?.model {
                                dbmessageModels = CODDiscoverMessageModel.loadMessageList(beginTime: lastModel.createTime, endTime: appeaceLastModel.createTime)
                            }
                        }
                        
                        
                        dbmessageModels = CODDiscoverMessageModel.syncDeletedMessage(dbmessageModels: dbmessageModels, messageModels: messageModels)
                        
                        cellVMs = dbmessageModels.map { CODDiscoverHomeCellVM(model: $0) }
                        
                        
                    }
                    
                    
                    
                } else {
                    
                    
                    cellVMs = self.featchDataFromDB(isHeaderLoad: isHeaderLoad, size: size).map { CODDiscoverHomeCellVM(model: $0) }
                    
                    
                    if cellVMs.count == 0 {
                        self.lastDataNoAnymorePR.accept(Void())
                        return
                    }
                    
                }
                
                DispatchQueue.main.async {
                    
                    if isHeaderLoad {
                        
                        self.setCellVM(cellVM: cellVMs)
                        self.hearLoadPR.accept(Void())
                        self.installEmptyPR.accept(Void())
                        self.installFooterPR.accept(Void())
                        
                    } else {
                        
                        self.addCellVM(cellVM: cellVMs)
                        self.footLoadPR.accept(Void())
                        
                    }
                    
                }
                
            }
            
        })
        
    }
    
    func featchDataFromDB(isHeaderLoad: Bool, size: Int) -> [CODDiscoverMessageModel] {
        
        var models: [CODDiscoverMessageModel] = []
        
        if isHeaderLoad {
            models = CODDiscoverMessageModel.loadLastMessages(count: size)
        } else {
            
            if let cellVM = self.dataSource.value.last?.items.last as? CODDiscoverHomeCellVM, let model = cellVM.model {
                models = CODDiscoverMessageModel.loadMessageList(beforeTime: model.createTime, count: size)
            }
            
        }
        
        return models
        
    }
    
    
    func getInfo() {
        
        DiscoverHttpTools.getAndUpdateNewMoments()
        
    }
    
    func setCellVM(cellVM: [CODDiscoverHomeCellVM]) {
        
        var dataSource = self.dataSource.value
        
        if dataScetionIdentifier == dataSource.last?.model {
            dataSource.last?.items = cellVM
        } else {
            dataSource.append(CODDiscoverHomePageSectionVM(model: dataScetionIdentifier, items: cellVM))
        }
        
        self.dataSource.accept(dataSource)
        
    }
    
    func addNewMessageNotification() {
        
        if self.dataSource.value.first?.model == newMessageNotificationScetionIdentifier {
            return
        }
        
        addNotification(identifier: newMessageNotificationScetionIdentifier,  vms: [
            CODDiscoverNotificationCellVM(style: .normal)
        ])
    }
    
    func removeNotification(identifier: String) {
        
        var dataSources = self.dataSource.value
        
        for (index, section) in dataSources.enumerated() {
            if section.model == identifier {
                dataSources.remove(at: index)
                self.dataSource.accept(dataSources)
                return
            }
        }
        
    }
    
    func addNotification(identifier: String, vms: [CODDiscoverNotificationCellVM]) {
        
        
        var dataSources = self.dataSource.value
        
        
        /// 如果有这个section直接覆盖
        for section in dataSources {
            if section.model == identifier {
                section.items = vms
                self.dataSource.accept(dataSources)
                return
            }
        }
        
        
        dataSources.insert(CODDiscoverHomePageSectionVM(model: identifier, items: vms), at: 0)
        
        self.dataSource.accept(dataSources)
        
    }
    
    func removeNewMessageNotification() {
        
        var dataSources = self.dataSource.value
        
        for (index, model) in dataSources.enumerated() {
            
            if model.model == newMessageNotificationScetionIdentifier {
                dataSources.remove(at: index)
                self.dataSource.accept(dataSources)
            }
            
        }
        
    }
    
    
    func addCellVM(cellVM: [CODDiscoverHomeCellVM]) {
        
        if cellVM.count <= 0 {
            return
        }
        
        let dataSource = self.dataSource.value
        
        guard let sectionVM = dataSource.last else {
            return
        }
        
        if sectionVM.model != dataScetionIdentifier {
            return
        }
        
        sectionVM.items.append(contentsOf: cellVM)
        
        
        self.dataSource.accept(dataSource)
        
    }
    
    func getModel(indexPath: IndexPath) -> CODDiscoverMessageModel? {
        
        guard let item = self.dataSource.value[indexPath.section].items[indexPath.row] as? CODDiscoverHomeCellVM  else {
            return nil
        }
        
        return item.model
    }
    
    func deleteComment(indexPath: IndexPath, messageId: String) {
        
        guard let model = getModel(indexPath: indexPath) else {
            return
        }
        
        let params = [
            "messageId": messageId,
            "momentsId": model.serverMsgId,
            "userName": UserManager.sharedInstance.jid
        ]
        
        HttpManager.share.post(url: HttpConfig.COD_moments_del_comment, param: params)?.responseJSON(completionHandler: { [weak self] (response) in
            
            guard let `self` = self else { return }
            
            let json = JSON(response.data)
            
            if json["data"]["flag"].boolValue {
                
                if let model = CODDiscoverMessageModel.getModel(serverMsgId: model.serverMsgId) {
                    model.deleteComment(serverId: messageId)
                }
                
            } else {
                self.showErrorPR.accept(NSLocalizedString("暂无网络", comment: ""))
            }
            
        })
        
        
    }
    
    func comment(indexPath: IndexPath, replayUser: String, replyUserName: String? = nil) {
        
        guard let model = getModel(indexPath: indexPath) else {
            return
        }
        
        self.commentPR.accept((momentsId: model.serverMsgId, replayUser: replayUser, replyUserName: replyUserName))
        
    }
    
    
    func srcollOffset(offset: CGFloat) {
        
        self.scrollOffsetPR.accept(offset)
    }
    
    func like(indexPath: IndexPath) {
        
        guard let model = getModel(indexPath: indexPath) else {
            return
        }
        
        DiscoverHttpTools.like(momentsId: model.serverMsgId) { [weak self] (respones) in
            
            guard let `self` = self else { return }
            
            switch respones.result {
            case .success(let data):
                if let _ = JSON(data)["data"]["messageId"].int {
                    self.likePR.accept(indexPath)
                }
            case .failure(.createURLRequestFailed(error: let error as DiscoverHttpTools.DiscoverHttpError)):
                if error == .momentIsDelete {
                    self.likePR.accept(indexPath)
                }
                
            case .failure(_):
                self.showErrorPR.accept(NSLocalizedString("暂无网络", comment: ""))
                break
            }
            
            
        }
        
    }
    
    func dislike(indexPath: IndexPath) {
        
        guard let model = getModel(indexPath: indexPath) else {
            return
        }
        
        DiscoverHttpTools.dislike(momentsId: model.serverMsgId, messageId: model.likerId) { [weak self] (respones) in
            
            guard let `self` = self else { return }
            
            switch respones.result {
            case .success(let data):
                
                if JSON(data)["data"]["flag"].boolValue {
                    self.likePR.accept(indexPath)
                }
                
                
            case .failure(_):
                self.showErrorPR.accept(NSLocalizedString("暂无网络", comment: ""))
                break
            }
            
            
        }
        
        
    }
    
    func goToPersonInfo(jid: String) {
        CustomUtil.pushPersonInfoVC(jid: jid)
    }
    
    
    func deleteMessage(indexPath: IndexPath) {
        
        guard let model = self.getModel(indexPath: indexPath) else {
            return
        }
        
        if model.statusEnum == .Sending {
            CODAlertView_show("", message: NSLocalizedString("正在发送中, 删除失败", comment: ""))
            return
        }
        
        CODAlertVcPresent(confirmBtn: "删除", message: "删除这条朋友圈?", title: "", cancelBtn: "取消", handler: { (action) in
            
            if action.style == .default {
                
                if model.statusEnum == .Failure {
                    model.delete()
                    self.removeItem(indexPath: indexPath)
                    return
                }
                
                CODProgressHUD.showWithStatus(NSLocalizedString("正在删除...", comment: ""))
                
                DiscoverHttpTools.delete(momentsId: model.serverMsgId) { [weak self] (respones) in
                    CODProgressHUD.dismiss()
                    
                    guard let `self` = self else { return }
                    
                    if JSON(respones.value)["data"]["flag"].boolValue {
                        self.removeItem(indexPath: indexPath)
                        
                    } else {
                        self.showErrorPR.accept(NSLocalizedString("暂无网络", comment: ""))
                    }
                    
                }
                
            }
            
        }, viewController: UIViewController.current()!)
        
        
        
    }
    
    func removeItem(indexPath: IndexPath) {
        
        var items = self.dataSource.value[indexPath.section].items
        
        items.remove(at: indexPath.row)
        
        if let items = items as? [CODDiscoverHomeCellVM] {
            self.setCellVM(cellVM: items)
        }
        
    }
    
}
