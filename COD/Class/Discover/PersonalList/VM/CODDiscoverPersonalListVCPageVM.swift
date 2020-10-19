//
//  CODDiscoverPersonalListVCPageVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/10.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx
import IGListKit
import RxRealm

extension CODDiscoverPersonalListVCPageVM: HasDisposeBag {
    
}






class CODDiscoverPersonalListVCPageVM {
    
    
    enum LoadState {
        case ide
        case loading
        case headerLoadingEnd
        case footerLoadingEnd
        case noAnyMore
        case loadingError
        case addMessage
        case reloadData
    }
    
    @CODBehaviorRelay var dataSources: [CODDiscoverPersonalListCellVM] = []
    
    var headerData: [CODDiscoverPersonalListCellVM] = [
        CODDiscoverPersonalListCellVM(cellType: .hander, model: nil)
    ]
    
    let jid: String
    
    var isMeSelf: Bool {
        return UserManager.sharedInstance.jid == jid
    }
    
    @CODPublishRelay var loadingState: LoadState = .ide
    
    var showImageBrowserPR: PublishRelay<String> = PublishRelay()
    
    init(jid: String = UserManager.sharedInstance.jid) {
        
        self.jid = jid
        
        if isMeSelf {
            headerData.append(CODDiscoverPersonalListCellVM(cellType: .date, model: nil))
            headerData.append(CODDiscoverPersonalListCellVM(cellType: .camera, model: nil))
        }

        dataSources.append(contentsOf: headerData)
        dataSources.append(contentsOf: self.featchCellVMFromDB(isHeaderLoad: true))
        
        let sendingList = CODDiscoverFailureAndSendingListModel.getFailureModel().modelList
        
        Observable.arrayWithChangeset(from: sendingList).skip(1).bind { [weak self ] (value) in
            
            guard let `self` = self else { return }
            
            if let inserted =  value.1?.inserted, inserted.count > 0 {
                
                for index in inserted {
                    
                    let model = value.0[index]
                    self.insertNewMessage(model: model)
                    
                    
                }
                
            }
            
        }
        .disposed(by: self.disposeBag)
        
        if let value = try? Realm().objects(CODDiscoverMessageModel.self) {
            Observable.changeset(from: value)
            .skip(1)
                .bind { [weak self] (value) in
                    guard let `self` = self else { return }
                    if let updated = value.1?.updated, updated.count > 0 {
                        
                        for index in updated {
                            
                            let model = value.0[index]
                            if model.isDelete == true {
                                self.deleteCellVM(messageModel: model)
                            }
                            
                        }
                    }
            }
            .disposed(by: self.disposeBag)
        }
        
        
        
    }
    
    func showImageBrowser(msgId: String) {
        
        showImageBrowserPR.accept(msgId)
        
    }
    
    func deleteCellVM(messageModel: CODDiscoverMessageModel) {

        var haveDelete = false
        
        var endTime: Int?
        var beginTime: Int?
        
        for cellVM in self.dataSources {
            
            if endTime == nil {
                endTime = cellVM.model?.createTime
            }
            
            if let model = cellVM.model, model.msgId == messageModel.msgId {
                haveDelete = true
            }
            
            if let createTime = cellVM.model?.createTime {
                beginTime = createTime
            }

        }

//        dataSources.append(contentsOf: headerData)
        
        if let beginTime = beginTime, let endTime = endTime, haveDelete {
            
            let dbModels = CODDiscoverMessageModel.loadMessageList(senderJid: self.jid, beginTime: beginTime, include: endTime)
            
            let cellVMs = self.createCellVM(models: dbModels)
            
            dataSources.removeAll()
            dataSources.append(contentsOf: headerData)
            dataSources.append(contentsOf: cellVMs)
            
            self.loadingState = .reloadData
            
        }
        

    }
    
    func insertNewMessage(model: CODDiscoverMessageModel) {
        
        if model.statusEnum != .Sending || model.senderJid != UserManager.sharedInstance.jid {
            return
        }
        
        let i = dataSources.firstIndex { $0.cellType == .date }
        
        guard var index = i else {
            return
        }
        
        if dataSources.count > index + 1 {
            
            if dataSources[index + 1].cellType == .camera {
                index += 1
            }
            
        }
        
        dataSources.insert(messageModelToCellVM(model: model), at: index + 1)
        
        self.loadingState = .addMessage
        
    }
    
    func fetchData(isHeaderLoad: Bool = true, pageNum: Int = 1, size: Int = 10, completion: (([CODDiscoverPersonalListCellVM]) -> ())? = nil) {
        
        
        var params = CustomUtil.createPageReqParams(.page(pageNum, size, .sort("createTime", .desc)))
        
        params["userName"] = UserManager.sharedInstance.jid
        params["targeter"] = self.jid
        
        func _loadCellVMs(dbModels: [CODDiscoverMessageModel]) {
                        
            if isHeaderLoad {
                
                self.dataSources.removeAll()
                self.dataSources.append(contentsOf: headerData)
                
            }
            
            let cellVMs = self.createCellVM(models: dbModels)
            
            self.addDataSources(cellVMs: cellVMs)
            
            DispatchQueue.main.async {
                
                _ = try? Realm().refresh()
                completion?(cellVMs)
                
                if isHeaderLoad {
                    self.loadingState = .headerLoadingEnd
                } else {
                    self.loadingState = .footerLoadingEnd
                }
                
            }

        }
        
        self.loadingState = .loading
        HttpManager.share.post(url: HttpConfig.COD_moments_see_moments, param: params)?.responseDecodableObject(keyPath: "data.list", completionHandler: { [weak self] (response: AFDataResponse<[CODDiscoverJsonModel]>) in
            
            guard let `self` = self else { return }
            
            if let models = response.value {
                
                DispatchQueue.realmWriteQueue.async {
                    
                    var dbModels = models.map { CODDiscoverMessageModel.createMessageModel(jsonModel: $0) }
                    _ = dbModels.addToDB()
                    _ = try? Realm().refresh()
                    
                    let beginTime = models.last?.createTime ?? 0
                    let endTime = models.first?.createTime ?? 0
                    
                    if isHeaderLoad {
                        
                        dbModels = CODDiscoverMessageModel.loadMessageList(senderJid: self.jid, afterTime: beginTime)
                        
                    } else {
                        dbModels = CODDiscoverMessageModel.loadMessageList(senderJid: self.jid, beginTime: beginTime, include: endTime)
                    }
                    
                    let messageModel = models.map { CODDiscoverMessageModel.createMessageModel(jsonModel: $0) }
                    
                    dbModels = CODDiscoverMessageModel.syncDeletedMessage(dbmessageModels: dbModels, messageModels: messageModel)
                    
                    _loadCellVMs(dbModels: dbModels)
                    
                }
                
                
            } else {
                
                let dbModels = self.featchDataFromDB(isHeaderLoad: isHeaderLoad, size: size)
                _loadCellVMs(dbModels: dbModels)
                
            }
            
            
            
        })
            .responseJSON(completionHandler: { [weak self] (response) in
                
                guard let `self` = self else { return }
                
                let json = JSON(response.value)
                
                guard let code = json["code"].int else {
                    self.loadingState = .loadingError
                    return
                }
                
                if code != 0 {
                    self.loadingState = .loadingError
                    return
                }
                
                let pageJson = json["data"]["page"]
                
                if let hasNext = pageJson["hasNext"].bool, hasNext == false {
                    self.loadingState = .noAnyMore
                }
                
            })
        
    }
    
    func featchCellVMFromDB(isHeaderLoad: Bool, size: Int = 10) -> [CODDiscoverPersonalListCellVM]  {
        
        let dbModels = self.featchDataFromDB(isHeaderLoad: isHeaderLoad, size: size)
        
        return self.createCellVM(models: dbModels)
        
    }
    
    func addDataSources(cellVMs: [CODDiscoverPersonalListCellVM]) {
        
        self.dataSources.append(contentsOf: cellVMs)
        
        
    }
    
    func createCellVM(models: [CODDiscoverMessageModel]) -> [CODDiscoverPersonalListCellVM] {
        
        var cellVMs: [CODDiscoverPersonalListCellVM] = []
        
        
        for (index, model) in models.enumerated() {
            
            var preModel: CODDiscoverMessageModel? = nil
            
            if index == 0 {
                preModel = self.dataSources.last?.model
                
            } else {
                
                let preIndex = index - 1
                preModel = models[preIndex]
                
            }
            
            if let cellVM = createYearModel(preModel: preModel, model: model) {
                cellVMs.append(cellVM)
            }
            
            if let cellVM = createDateModel(preModel: preModel, model: model) {
                cellVMs.append(cellVM)
            }
            
            cellVMs.append(messageModelToCellVM(model: model))
            
        }
        
        return cellVMs
        
    }
    
    func messageModelToCellVM(model: CODDiscoverMessageModel) -> CODDiscoverPersonalListCellVM {
        
        switch model.msgTypeEnum {
        case .video:
            return CODDiscoverPersonalListCellVM(cellType: .video, model: model)
        case .image:
            
            if model.imageList.count > 1 {
                return CODDiscoverPersonalListCellVM(cellType: .groupImage, model: model)
            } else {
                
                if model.text.count > 0 {
                    return CODDiscoverPersonalListCellVM(cellType: .imageText, model: model)
                } else {
                    return CODDiscoverPersonalListCellVM(cellType: .image, model: model)
                }
                
            }
        case .text:
            return CODDiscoverPersonalListCellVM(cellType: .text, model: model)
        }
        
    }
    
    func createDateModel(preModel: CODDiscoverMessageModel?, model: CODDiscoverMessageModel) -> CODDiscoverPersonalListCellVM? {
        
        if Date(milliseconds: model.createTime).isInToday && isMeSelf {
            return nil
        }
        
        guard let preModel = preModel else {
            return CODDiscoverPersonalListCellVM(cellType: .date, model: model)
        }
        
        if DiscoverTools.isSameDay(preModel.createTime, model.createTime) != true {
            return CODDiscoverPersonalListCellVM(cellType: .date, model: model)
        } else {
            return nil
        }
        
    }
    
    func createYearModel(preModel: CODDiscoverMessageModel?, model: CODDiscoverMessageModel) -> CODDiscoverPersonalListCellVM? {
        
        guard let preModel = preModel else {
            return nil
        }
        
        if DiscoverTools.isSameYear(preModel.createTime, model.createTime) {
            return nil
        }
        
        if DiscoverTools.isInYear(model.createTime) {
            return nil
        }
        
        return CODDiscoverPersonalListCellVM(cellType: .year, model: model)
        
    }
    
    func featchDataFromDB(isHeaderLoad: Bool, size: Int) -> [CODDiscoverMessageModel] {
        
        var models: [CODDiscoverMessageModel] = []
        
        if isHeaderLoad {
            models = CODDiscoverMessageModel.loadLastMessages(senderJid: jid, count: size)
        } else {
            
            if let cellVM = self.dataSources.last, let model = cellVM.model {
                models = CODDiscoverMessageModel.loadLastMessages(senderJid: jid, beforeTime: model.createTime, count: size)
            }
            
        }
        
        return models
        
    }
    
    func loadImageAndVideoData() -> [YBIBDataProtocol] {
        
        var beginTime: Int?
        var endTime: Int?
        
        for vm in dataSources {
            
            if let createTime = vm.model?.createTime{
                endTime = createTime
                break
            }
            
        }
        
        for vm in dataSources.reversed() {
            
            if let createTime = vm.model?.createTime{
                beginTime = createTime
                break
            }
            
        }
        
        if let beginTime = beginTime, let endTime = endTime {
            return CODDiscoverMessageModel
                .loadMessageList(senderJid: jid, msgTypes: [.image, .video], beginTime: beginTime, include: endTime)
                .toYBIBData()
        }
        
        return []
        
        
        
    }
    
}
