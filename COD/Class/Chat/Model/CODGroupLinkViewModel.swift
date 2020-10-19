//
//  CODGroupLinkViewModel.swift
//  COD
//
//  Created by XinHoo on 2020/4/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct GroupCopyLink: CellSelectType {
    func didSelected(view: UIView, pageVM: Any?, cellVM: TableViewCellVM, indexPath: IndexPath) {
        guard let viewModel = pageVM as? CODGroupLinkViewModel else {
            return
        }
        
        if let vc = UIViewController.current() {
            UIPasteboard.general.string = viewModel.groupLinkUrl
            CODAlertVcPresent(confirmBtn: NSLocalizedString("好", comment: ""), message: nil, title: NSLocalizedString("邀请链接已复制到剪贴板。", comment: ""), cancelBtn: "", handler: { (action) in
            }, viewController: vc)
        }
    }
}

struct GroupShareLink: CellSelectType {
    
    func didSelected(view: UIView, pageVM: Any?, cellVM: TableViewCellVM, indexPath: IndexPath) {
        guard let viewModel = pageVM as? CODGroupLinkViewModel else {
            return
        }
        
        let linkUrl = viewModel.groupLinkUrl
        let shareView = CODShareImagePicker(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
        shareView.contactListArr = CODGlobalDataSource.getContactGroupChannelModelData(isHeadCloudDisk: true, ignoreIDs: [NewFriendRosterID])
        shareView.shareText = linkUrl
        shareView.fromType = .Chat
        shareView.show()
    }
}

struct GroupUpdateLink: CellSelectType {
    func didSelected(view: UIView, pageVM: Any?, cellVM: TableViewCellVM, indexPath: IndexPath) {
        print("update")
        guard let viewModel = pageVM as? CODGroupLinkViewModel else {
            return
        }
        
        if let vc = UIViewController.current() {
            
            CODAlertVcPresent(confirmBtn: NSLocalizedString("确定", comment: ""), message: nil, title: NSLocalizedString("我们将生成一个新的邀请链接，设置完成后原有链接将失效", comment: ""), cancelBtn: NSLocalizedString("取消", comment: ""), handler: { (action) in
                
                if action.style == .default{
                    let params: [String: Any] = [
                        "name": COD_getuniqueshareid,
                        "roomName": viewModel.groupModel.jid,
                    ]
                    
                    XMPPManager.shareXMPPManager.getRequest(param: params, xmlns: COD_com_xinhoo_groupchatsetting) { [weak viewModel] (result) in
                        guard let viewModel = viewModel else { return }
                        switch result {
                        case .success(let data):
                            if let userid = data.dataJson?.string {
                                viewModel.groupLinkId = userid
                                viewModel.saveGroupLink(userId: userid)
                            }else{
                                CODProgressHUD.showErrorWithStatus("数据解析有误")
                            }
                            
                            break
                        case .failure(let error):
                            CODProgressHUD.showErrorWithStatus(error.localizedDescription)
                            break
                            
                        }
                    }
                }
            }, viewController: vc)
        }
        
    }
}



class CODGroupLinkViewModel {
    
    var dataSource :BehaviorRelay<[CODGroupLinkSectionModel]> = BehaviorRelay(value: [])
    
    var groupLinkId: String {
        get {
            return groupLinkUrl
        }
        set {
            groupLinkUrl = "\(CODAppInfo.channelSharePrivateLink)\(newValue)"
        }
    }
    
    var groupModel = CODGroupChatModel()
    
    var groupLinkUrl = "" {
        didSet {
            self.updateLinkUrlForDataSource(url: self.groupLinkUrl)
        }
    }
        
    let showUpdateAlertView = PublishRelay<Void>()
    
    var linkCellVM: GroupLinkCellVM?
    
    let disposeBag = DisposeBag()
    
    func getDataSource() -> BehaviorRelay<[CODGroupLinkSectionModel]> {
        var dataSource: [CODGroupLinkSectionModel] = []
        linkCellVM = GroupLinkCellVM(title: groupLinkUrl, identity: CODGroupLinkTextCell.description())
        let sectionModel1 = CODGroupLinkSectionModel(model: "", items: [linkCellVM!], title: "用户可通过以上链接加入您的群组，您可以随时撤换此链接。", sectionFootViewType: "CODGroupLinkFooterView", footViewHeight: 47, headViewHeight: 20)
        dataSource.append(sectionModel1)
        
        let cellStr = CODGroupLinkOtherCell.description()
        let cellVM2 = GroupLinkCellVM(title: "拷贝链接", identity: cellStr, selectAction: GroupCopyLink())
        let cellVM3 = GroupLinkCellVM(title: "刷新链接", identity: cellStr, selectAction: GroupUpdateLink())
        let cellVM4 = GroupLinkCellVM(title: "分享链接", identity: cellStr, selectAction: GroupShareLink())
        let sectionModel2 = CODGroupLinkSectionModel(model: "", items: [cellVM2,cellVM3,cellVM4], headViewHeight: 20)
        dataSource.append(sectionModel2)
        
        return BehaviorRelay(value: dataSource)
    }
    
    func updateLinkUrlForDataSource(url: String) {
        linkCellVM?.title = url
    }
    
    convenience init(linkId: String, groupModel: CODGroupChatModel) {
        self.init()
        self.groupLinkId = linkId
        self.groupModel = groupModel
        dataSource = self.getDataSource()
    }
    
    func saveGroupLink(userId: String) {
        let param: [String : Any] = ["name":"setgroupchatsetting",
                     "requester":UserManager.sharedInstance.jid,
                     "itemID":self.groupModel.roomID,
                     "setting":["type":CODGroupType.MPRI.rawValue,
                                "userid":userId]]
        XMPPManager.shareXMPPManager.getRequest(param: param, xmlns: COD_com_xinhoo_groupchatsetting) { (result) in
            
            switch result {
            case .success(let data):
                if let userid = data.actionJson?["setting"]["userid"].string {
                    try! Realm.init().safeWrite { [weak self] in
                        guard let `self` = self else { return }
                        self.groupModel.userid = userid
                    }
                }else{
                    CODProgressHUD.showErrorWithStatus("数据解析有误")
                }
                
                break
            case .failure(let error):
                CODProgressHUD.showErrorWithStatus(error.localizedDescription)
                break
                
            }
        }
    }
}

extension Reactive where Base: GroupLinkCellVM {
    var title: Observable<String> {
        return self.base.titleBR.asObservable()
    }
}

class GroupLinkCellVM: TableViewCellVM {
    var title: String {
        set {
            self.titleBR.accept(newValue)
        }
        get {
            return titleBR.value
        }
    }
    var titleBR = BehaviorRelay<String>(value: "")
    convenience init(title: String, identity: String, selectAction: CellSelectType? = nil) {
        self.init(name: identity)
        self.selectAction = selectAction
        self.title = title
    }
}

class CODGroupLinkSectionModel: TableViewSectionVM<String, TableViewCellVM>  {
        
}



