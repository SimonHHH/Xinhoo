//
//  CODChannelDetailViewController.swift
//  COD
//
//  Created by XinHoo on 2019/11/28.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxRealm

class CODChannelDetailViewController: BaseViewController {
    
    public var channeModel: CODChannelModel?  = nil
    
    var isAdmin = true
    var myPower: Int = 30
    
    var introductionRowAddition = 1
    var linkRowAddition = 1
    
    private var cropImage: UIImage?
    
    fileprivate var dataSource: Array = [[CODCellModel]]()
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackButton()
        if isAdmin {
            self.mySetRightTextButton()
        }
        
        
//        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        self.navigationItem.title = NSLocalizedString("频道信息", comment: "")
        self.getChannelInfo()
        self.createChannelDataSource()
        
        self.setUpUI()
        // Do any additional setup after loading the view.
    }
    
    func setUpUI() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(0)
        }
    }
    
    
    fileprivate lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.estimatedRowHeight = 48
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        ///注册单元格
        self.registerCellClassForTableView(tableView: tableView)
        tableView.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0.01))
        tableView.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0.01))
        return tableView
    }()
    
    func mySetRightTextButton() {
        self.setRightTextButton()
        self.rightTextButton.setTitle("编辑", for: UIControl.State.normal)
        self.rightTextButton.setTitleColor(UIColor.init(hexString: kBlueTitleColorS), for: UIControl.State.normal)
        self.rightTextButton.isEnabled = true
    }
    
    override func navRightTextClick() {
        let ctl = CODChannelDetailEditViewController()
        ctl.channelModel = self.channeModel
        self.navigationController?.pushViewController(ctl, animated: false)
    }
    
    @objc dynamic func quitChanneModel(owner: Bool) {
        
        if owner {
            XMPPManager.shareXMPPManager.destroyChannel(roomId: self.channeModel?.roomID ?? 0, success: { [weak self] (_, name) in
                
                guard let `self` = self else { return }
                
                if (name != COD_destroyRoom) {
                    return
                }
                
                self.navigationController?.popToRootViewController(animated: true)
                
                
            }) { (_) in
                
            }
        }else{
            XMPPManager.shareXMPPManager.quitChannel(roomId: self.channeModel?.roomID ?? 0, success: { [weak self] (_, name) in
                
                guard let `self` = self else { return }
                
                if (name != COD_quitGroupChat) {
                    return
                }
                
                self.navigationController?.popToRootViewController(animated: true)
                
                
            }) { (_) in
                
            }
        }

    }
    
    @objc func createChannelDataSource() {
        if dataSource.count > 0 {
            dataSource.removeAll()
        }
        
        guard let channelModel = channeModel else {
            return
        }
        
        var model1 = self.createModel(title: channelModel.getGroupName(), subTitle: "", placeholder: "", image: channelModel.grouppic, type: .headerType)
        
//        dataSource.append([model1])
        
        var model2 = self.createModel(title: "简介", subTitle: channelModel.notice, placeholder: "", image: "", isHiddenBottomLine: true, type: .longTextType)
        var model3 = self.createModel(title: "分享链接", subTitle: channelModel.shareLink, placeholder: "", image: "", type: .longTextType)
        model3.action.didSelected = { [weak self, weak channelModel] in
            guard let `self` = self, let channelModel = channelModel else { return }
            self.shareUrlString(urlString: channelModel.shareLink)
        }
        
        let admins = channelModel.member.filter { (member) -> Bool in
            return member.userpower == 20 || member.userpower == 10
        }
        
        var model4 = self.createModel(title: "管理员", subTitle: admins.count.string, placeholder: "", image: "", isHiddenArrow: false, type: .baseType)
        model4.action.didSelected = { [weak self, weak channelModel] in
        
            guard let `self` = self, let channelModel = channelModel else { return }
            
            let ctl = CODChannelManagerViewController()
            ctl.groupChatId = channelModel.chatId
            self.navigationController?.pushViewController(ctl, animated: true)
        }
        
        var model5 = self.createModel(title: "订阅者", subTitle: channelModel.member.count.string, placeholder: "", image: "", isHiddenArrow: false, type: .baseType)
        model5.action.didSelected = { [weak self, weak channelModel] in
        
            guard let `self` = self, let channelModel = channelModel else { return }
            
            let ctl = CODChannelSubscriberViewController()
            ctl.groupChatId = channelModel.chatId
            self.navigationController?.pushViewController(ctl, animated: true)
        }
        
//        var model6 = self.createSwitchModel(title: "保存到频道", subTitle: "", placeholder: "", image: "", type: .switchType, switchIsOn: self.channeModel?.savecontacts ?? false, isEnable: true)
//
//        model6.action.switchButtonAction = { [weak channelModel] isOn in
//            guard let channelModel = channelModel else { return }
//            XMPPManager.shareXMPPManager.channelSetting(roomID: channelModel.roomID, savecontacts: isOn)
//        }
        
        var model7 = self.createSwitchModel(title: "置顶频道", subTitle: "", placeholder: "", image: "", type: .switchType, switchIsOn: self.channeModel?.stickytop ?? false, isEnable: true)
        
        model7.action.switchButtonAction = { [weak channelModel] (isOn) -> Void in
            guard let channelModel = channelModel else { return }
            XMPPManager.shareXMPPManager.channelSetting(roomID: channelModel.chatId, stickytop: isOn)
        }
        
        var model8 = self.createSwitchModel(title: "消息通知", subTitle: "", placeholder: "", image: "", type: .switchType, switchIsOn: !(self.channeModel?.mute ?? false), isEnable: true)
        
        model8.action.switchButtonAction = { [weak channelModel] (isOn) -> Void in
            guard let channelModel = channelModel else { return }
            XMPPManager.shareXMPPManager.channelSetting(roomID: channelModel.chatId, mute: !isOn)
        }
        
        var model9 = self.createModel(title: "分享的媒体文件", subTitle: "", placeholder: "", image: "", isHiddenArrow: false, type: .baseType)
        model9.action.didSelected = { [weak self, weak channelModel] in
            
            guard let `self` = self, let channelModel = channelModel else { return }
            
            let vc = SharedMediaFileViewController.init(nibName: "SharedMediaFileViewController", bundle: nil)
            vc.title = NSLocalizedString("共享媒体", comment: "")
            let listModel = CODChatListRealmTool.getChatList(id: channelModel.chatId)
            vc.list = listModel?.chatHistory?.messages
            vc.chatId = channelModel.chatId
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        let owner = channelModel.isOwner(by: UserManager.sharedInstance.jid)
        
        let title = owner ? "解散频道" : "退出频道"
        let alertTitle = owner ? NSLocalizedString("您确定要解散此频道？解散后所有成员会被移除，所有消息会被清空", comment: "") : nil
        
        var model10 = self.createModel(title: title, subTitle: "", placeholder: "", image: "", type: .baseType)
        model10.titleColor = UIColor.red
        model10.action.didSelected = { [weak self] in
            
            guard let `self` = self else { return }
            
            let alertView = UIAlertController(title: alertTitle, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            
            let alertItem1 = UIAlertAction(title: title, style: UIAlertAction.Style.destructive) {[weak self] (action) in
                
                self?.quitChanneModel(owner: owner)
                
                
            }
            alertView.addAction(alertItem1)
            
            let alertItem2 = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel) {(action) in}
            alertView.addAction(alertItem2)
            
            self.present(alertView, animated: true, completion: nil)
            
        }
        
        XMPPManager.shareXMPPManager.getChannelSetting(roomID: channelModel.roomID, success: { [weak channelModel] (model, name) in
            
            guard let channelModel = channelModel else { return }
            
            if name == COD_Getchannelsetting {
                
                if let dic = JSON(model.data as Any)["setting"].dictionaryObject, let jsonModel = CODChannelHJsonModel.deserialize(from: dic) {
                    channelModel.updateChannel(jsonModel: jsonModel)
                }

            }
            
        }, fail: nil)
        
        if let channelModel = CODChannelModel.getChannel(by: channelModel.chatId) {
            
            let memberChange = Observable.arrayWithChangeset(from: channelModel.member).map { $0.0 }
            
            let adminCount = memberChange
                .map { (members) -> String in
                    return members.filter { (member) -> Bool in
                        return member.userpower == 20 || member.userpower == 10
                        }.count.string
            }
            
            let memberCount = memberChange.map { $0.count.string }
            
            adminCount.bind(to: model4.$subTitle.observed)
                .disposed(by: self.disposeBag)
            
            memberCount.bind(to: model5.$subTitle.observed)
            .disposed(by: self.disposeBag)
            
            let noticeChange = Observable.from(object: channelModel).map { $0.notice }.distinctUntilChanged().map { _ in }
            let channelTypeChange = Observable.from(object: channelModel).map { $0.channelTypeEnum }.distinctUntilChanged().map { _ in }
            let myPowerChange = memberChange.map { _ in
                return channelModel.isAdmin(by: UserManager.sharedInstance.jid)
            }.distinctUntilChanged().map { _ in }
            
            
            Observable.from(object: channelModel)
                .takeUntil(self.rx.sentMessage(#selector(quitChanneModel(owner:))))
                .subscribe(onNext: { (model) in
                    
                    model1.title = model.getGroupName()
                    model1.iconName = model.grouppic
                    model2.subTitle = model.notice
                    model3.subTitle = model.shareLink
//                    model6.isOn = model.savecontacts
                    model7.isOn = model.stickytop
                    model8.isOn = !model.mute

                })
                .disposed(by: self.disposeBag)
            
            
            Observable.merge([noticeChange, channelTypeChange, myPowerChange]).subscribe(onNext: { [weak self, weak channelModel] in
                guard let `self` = self, let channelModel = channelModel else { return }
                            
                let section1 = [model1]
                
                var section2: [CODCellModel] = []
                
                let isShowDescription = channelModel.notice.count > 0
                
                if isShowDescription {
                    section2.append(model2)
                }
                
                if channelModel.channelTypeEnum == .CPUB {
                    section2.append(model3)
                }
                
                self.rightTextButton.isHidden = true
                if channelModel.isOwner(by: UserManager.sharedInstance.jid) {
                    section2.append(contentsOf: [model4, model5])
                    self.rightTextButton.isHidden = false
                } else if channelModel.isAdmin(by: UserManager.sharedInstance.jid) {
                    section2.append(contentsOf: [model5])
                    self.rightTextButton.isHidden = false
                }
                
//                let section3 = [model6, model7, model8, model9, model10]
                let section3 = [model7, model8, model9, model10]
                
                if channelModel.isMember(by: UserManager.sharedInstance.jid) {
                    self.dataSource = [section1, section2, section3]
                } else {
                    self.dataSource = [section1, section2]
                }
                
                self.tableView.reloadData()
                
            }).disposed(by: self.disposeBag)
        } else {
            
            
            self.rightTextButton.isHidden = true
            
            let section1 = [model1]
            var section2: [CODCellModel] = []
            
            let isShowDescription = channelModel.notice.count > 0
            
            if isShowDescription {
                section2.append(model2)
            }
            
            if channelModel.channelTypeEnum == .CPUB {
                section2.append(model3)
            }
            
            self.dataSource = [section1, section2]
            
        }
        

    }

    
    func getChannelInfo() {
        
    }
    
    func createSwitchModel(title: String = "",
                           subTitle: String = "",
                           placeholder: String = "",
                           image: String = "",
                           type: CODCellType,
                           switchIsOn: Bool,
                           isEnable: Bool) -> (CODCellModel) {
        var model = self.createModel(title: title, subTitle: subTitle, placeholder: placeholder, image: image, type: type)
        model.isOn = switchIsOn
        model.isEnable = isEnable
        return model
    }
    
    func createModel(title: String = "",
                     subTitle: String = "",
                     placeholder: String = "",
                     image: String = "",
                     isHiddenBottomLine: Bool = false,
                     isHiddenArrow:Bool = true,
                     type: CODCellType) -> (CODCellModel) {
        var model = CODCellModel()
        model.title = title
        model.subTitle = subTitle
        model.placeholderString = placeholder
        model.type = type
        model.iconName = image
        model.ishiddenBottomLine = isHiddenBottomLine
        model.ishiddenArrow = isHiddenArrow
        return model
    }

}

extension CODChannelDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODMessageDetailCell.self, forCellReuseIdentifier: "CODMessageDetailCellID")
        tableView.register(CODMessageDetailImageCell.self, forCellReuseIdentifier: "CODMessageDetailImageCellID")
        tableView.register(CODMessageDetailSwitchCell.self, forCellReuseIdentifier: "CODMessageDetailSwitchCellID")
        tableView.register(CODLongLongTextCell.self, forCellReuseIdentifier: "CODLongLongTextCellID")
        tableView.register(UINib.init(nibName: "CODGroupMemberAdvTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CODGroupMemberAdvTableViewCell")
        tableView.register(UINib.init(nibName: "CODGroupNameAndAvatarCell", bundle: Bundle.main), forCellReuseIdentifier: "CODGroupNameAndAvatarCell")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.selectGroupChatRow(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource[section].count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let datas = dataSource[indexPath.section]
        let model = datas[indexPath.row]
        if case .switchType = model.type {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODMessageDetailSwitchCellID", for: indexPath) as? CODMessageDetailSwitchCell
            if cell == nil{
                cell = CODMessageDetailSwitchCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODMessageDetailSwitchCellID")
            }
            cell?.cellType = .channel
            if indexPath.row == 0 {
                cell?.isTop = true
            }else{
                cell?.isTop = false
            }
            
            if indexPath.row == datas.count - 1 {
                cell?.isLast = true
            }else{
                cell?.isLast = false
            }
            cell?.title = model.title
            cell?.placeholer = model.placeholderString
            cell?.enable = model.isEnable ?? false
            cell?.switchIsOn = model.isOn
            cell?.onBlock = { isOn -> () in
                model.action.switchButtonAction?(isOn)
            }
            
            if let cell = cell {
                
                model.$isOn
                    .filterNil()
                    .bind(to: cell.switchBtn.rx.isOn)
                    .disposed(by: cell.rx.prepareForReuseBag)
                
            }
            
            return cell!
        }else if case .longTextType = model.type {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODLongLongTextCellID", for: indexPath) as? CODLongLongTextCell
            if cell == nil{
                cell = CODLongLongTextCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODLongLongTextCellID")
            }
            var isTop = false
            if indexPath.row == 0 {
                isTop = true
            }else{
                isTop = false
            }
            
            if let cell = cell {
                
                model.$subTitle.bind { [weak cell]  (subTitle) in
                    cell?.setChannelLongText(title: model.title, subTitle: subTitle, bottomLineIsHidden: model.ishiddenBottomLine, isTop: isTop)
                }
                .disposed(by: cell.rx.prepareForReuseBag)
                
            }
            
            cell?.setChannelLongText(title: model.title, subTitle: model.subTitle, bottomLineIsHidden: model.ishiddenBottomLine, isTop: isTop)
            return cell!
        }else if case .headerType = model.type {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODGroupNameAndAvatarCell", for: indexPath) as? CODGroupNameAndAvatarCell
            if cell == nil{
                cell = CODGroupNameAndAvatarCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODGroupNameAndAvatarCell")
            }
            if indexPath.row == datas.count - 1 {
                cell?.isLast = true
            }else{
                cell?.isLast = false
            }
            cell?.isEdit = false
                        
            
            cell?.selectAvatarCloser = { [weak cell] in

                let url =  URL.init(string: (model.iconName!.getHeaderImageFullPath(imageType: 2)))
                CustomUtil.removeImageCahch(imageUrl: model.iconName!.getHeaderImageFullPath(imageType: 2))
                SDImageCache.shared.removeImageFromMemory(forKey: CODImageCache.default.getCacheKey(url: url!))
                SDImageCache.shared.removeImageFromDisk(forKey: CODImageCache.default.getCacheKey(url: url!))
                let photoIndex: Int = 0
                let imageData: YBIBImageData = YBIBImageData()
//                imageData.projectiveView = cell?.avatarImgBtn
                imageData.imageURL = url
                let browser:YBImageBrowser =  YBImageBrowser()
                browser.dataSourceArray = [imageData]
                browser.currentPage = photoIndex
                browser.show()
                
            }
            cell?.textFieldDidEditChangeCloser = { [weak self] (textField: UITextField) in
                guard let self = self else {
                    return
                }
                guard let text = textField.text else {
                    return
                }
                if text.removeHeadAndTailSpacePro.count > 0 {
                    self.rightTextButton.isEnabled = true
                }else{
                    self.rightTextButton.isEnabled = false
                }
            }
            cell?.selectionStyle = .none
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.iconName!) { [weak cell] (image) in
                cell?.avatarImgBtn.setImage(image, for: .normal)
            }
            cell?.groupNameField.text = model.title
            
            if let cell1 = cell {
                
                
                
                
                model.$title
                    .bind(to: cell1.groupNameField.rx.text)
                    .disposed(by: cell1.rx.prepareForReuseBag)
                
                model.rx.iconName.bind { [weak cell1] (imageId) in
                    CODDownLoadManager.sharedInstance.updateAvatar(userPicID: imageId) { [weak cell1] (image) in
                        cell1?.avatarImgBtn.setImage(image, for: .normal)
                    }
                }
                .disposed(by: cell1.rx.prepareForReuseBag)
                
            }
            
            
            

            return cell!
        }else{
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODMessageDetailCellID", for: indexPath) as? CODMessageDetailCell
            if cell == nil{
                cell = CODMessageDetailCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODMessageDetailCellID")
            }
            cell?.cellType = .channel
            if case .deleteType = model.type {
                cell?.isDelete = true
            }else{
                cell?.isDelete = false
            }
            if indexPath.row == 0 {
                cell?.isTop = true
            }else{
                cell?.isTop = false
            }
            if indexPath.row == datas.count - 1 {
                cell?.isLast = true
            }else{
                cell?.isLast = false
            }
            
            if let cell = cell {
                model.$subTitle
                    .bind(to: cell.subTitleLab.rx.text)
                    .disposed(by: cell.rx.prepareForReuseBag)
            }
            

            cell?.title = model.title
            cell?.titleColor = model.titleColor
            cell?.placeholer = model.placeholderString
            cell?.subTitle = model.subTitle
            cell?.subTitleFont = UIFont.systemFont(ofSize: 17.0)
            cell?.isHiddenArrow = model.ishiddenArrow
            return cell!
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section < 2 {
            return 0.0
        }else{
            return 23.0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

extension CODChannelDetailViewController {
    func selectGroupChatRow(indexPath: IndexPath){
        let model = self.dataSource[indexPath.section][indexPath.row]
        model.action.didSelected?()
        
    }
    
    func shareUrlString(urlString: String)  {
        let shareView = CODShareImagePicker(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
        shareView.contactListArr = CODGlobalDataSource.getContactGroupChannelModelData(isHeadCloudDisk: true, ignoreIDs: [NewFriendRosterID])
        shareView.shareText = urlString
        shareView.fromType = .Chat
        shareView.show()
    }

}
