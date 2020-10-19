//
//  CODNewMessageListPageVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/18.
//  Copyright © 2020 XinHoo. All rights reserved.
//


import Foundation
import RxSwift
import RxCocoa

class CODDiscoverNewMessageListPageVM {
    
    let dataSource = BehaviorRelay<[DiscoverHomeSectionVM]>(value: [])
    
    let notUnreadPR = PublishRelay<Void>()
    let installFooter = PublishRelay<Void>()
    let endFooterLoadData = PublishRelay<Void>()
    let fetchDataErrorPR = PublishRelay<Void>()
    let loadAllMessageBR = BehaviorRelay<Bool>(value: false)
    var allItmes = [CODDiscoverNewMessageCellNodeVM]()
    
    let earlierMessageSectionIdentifiy = "EarlierMessage"
    
    let pageType: CODDiscoverNewMessageListVC.PageType
    
    init(pageType: CODDiscoverNewMessageListVC.PageType) {
        
        self.pageType = pageType
        
        dataSource.accept([
            DiscoverHomeSectionVM(model: "CODDiscoverNewMessageListPageVM", items: [
            ]),
        ])
        
    }
    
    func showEarlierMessage() {
        
        self.removeShowEarlierMessage()
        
        self.loadAllMessageBR.accept(true)
        self.installFooter.accept(Void())
        
    }
    
    func fetchData(isHeader: Bool = true, pageNum: Int = 1, pageSize: Int = 20) {
        
        var params = CustomUtil.createPageReqParams(.page(pageNum, pageSize, .sort("createTime", .desc)))
        params["userName"] = UserManager.sharedInstance.jid
        
        HttpManager.share.post(url: HttpConfig.COD_moments_find_pull_message, param: params)?
            .responseJSON(completionHandler: { [weak self] (response) in
                
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
                    self.endFooterLoadData.accept(Void())
                }
                
            }).responseDecodableObject(keyPath: "data.list", completionHandler: {  [weak self] (response: AFDataResponse<[CODDiscoverNewMessageJsonModel]>) in
                
                guard let `self` = self, let value = response.value else { return }
                
                DispatchQueue.realmWriteQueue.async {
                    
                    let newMessages = value.map{ CODDiscoverNewMessageModel.createModel(jsonModel: $0) }
                    newMessages.addToDB()
                    
                    
                    let haveRead = value.contains { (model) -> Bool in
                        return model.read == 1
                    }
                    
                    let cellVMs = newMessages.map { CODDiscoverNewMessageCellNodeVM(model: $0) }
                    
                    DispatchQueue.main.async {
                        
                        _ = try? Realm().refresh()
                        
                        if isHeader == true {
                            self.installFooter.accept(Void())
                        }
                        
                        if isHeader {
                            self.setCellVm(vms: cellVMs)
                        } else {
                            self.addCellVm(vms: cellVMs)
                        }
                        
                        if haveRead && self.pageType == .new {
                            self.notUnreadPR.accept(Void())
                            self.addShowEarlierMessage()
                        }
                        
                    }
                    
                }
                
            })
        
    }
    
    func clear() {
        
        HttpManager.share.post(url: HttpConfig.COD_moments_empty_message,
                               param: ["userName": UserManager.sharedInstance.jid],
                               successBlock: { (_, json) in
                                
                                if json["data"]["flag"].intValue == 1 {
                                    
                                    self.allItmes = []
                                    self.dataSource.accept([])
                                    
                                }
                                
        }) { (_) in
        }
        
        
    }
    
    var dataSourceSignle: Observable<[DiscoverHomeSectionVM]> {
        
        return Observable.combineLatest(self.dataSource, self.loadAllMessageBR).map { [weak self] (value) in
            
            guard let `self` = self else { return value.0 }
            
            
            let dataSource = value.0
            if value.1 == false && self.pageType == .new {
                dataSource.first?.items = self.allItmes.filter { $0.model?.read == 0 }
            } else {
                dataSource.first?.items = self.allItmes
            }
            
            return dataSource
        }
    }
    
    func setCellVm(vms: [CODDiscoverNewMessageCellNodeVM]) {
        
        guard let section = dataSource.value.first else {
            return
        }
        
        section.items = vms
        allItmes = vms
        dataSource.accept([section])
        
        
    }
    
    func addCellVm(vms: [CODDiscoverNewMessageCellNodeVM]) {
        
        guard let section = dataSource.value.first else {
            return
        }
        
        section.items.append(contentsOf: vms)
        allItmes.append(contentsOf: vms)
        dataSource.accept([section])
        endFooterLoadData.accept(Void())
        
    }
    
    func goToPersonInfo(jid: String) {
        CustomUtil.pushPersonInfoVC(jid: jid)
    }
    
    func addShowEarlierMessage() {
        
        var dataSource = self.dataSource.value
        
        if loadAllMessageBR.value == true {
            return
        }
        
        if dataSource.last?.model == earlierMessageSectionIdentifiy {
            return
        }
        
        dataSource.append(DiscoverHomeSectionVM(model: earlierMessageSectionIdentifiy, items: [
            ASTableViewCellVM(name: CODDiscoverShowEarlierMessageCellNode.self)
        ]))
        
        self.dataSource.accept(dataSource)
        
    }
    
    func removeShowEarlierMessage() {
        
        var dataSource = self.dataSource.value
        
        if dataSource.last?.model != earlierMessageSectionIdentifiy {
            return
        }
        
        _ = dataSource.popLast()
        
        self.dataSource.accept(dataSource)
        
    }
    
    
    
}

