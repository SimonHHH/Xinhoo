//
//  CODGroupManageVC.swift
//  COD
//
//  Created by 1 on 2019/4/17.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import XMPPFramework
import RealmSwift

class CODGroupManageVC: BaseViewController{
    
    enum IQAction {
        case invite
        case speak
        case atAll
        case setAllAdmins
        case checkInfo
        case setAdmin(jid: String, indexPath: IndexPath)
        case showAllHistory
    }
    
    var groupChatId: Int!
    var groupManager: CODGroupMemberModel!
    
    var memberArr: List<CODGroupMemberModel>!
    var memberCellArr: Array<CODCellModel> = Array<CODCellModel>()
    
    var isGroupOwner = false
    
    var sectionAdditionCount = 0
    
    var groupLinkModel: CODCellModel?
    var speakModel: CODCellModel?
    var inviteModel: CODCellModel?
    var atAllModel: CODCellModel?
    var setAllAdminsModel: CODCellModel?
    var checkInfoModel: CODCellModel?
    
    var showAllHistoryModel: CODCellModel?
    
    var operationDic: Dictionary<String,Int> = [:]   //记录被操作的成员<jid:Int>
    
    var realmNotification: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("管理员", comment: "")
        self.setBackButton()
        self.createDataSource()
        self.addNotification()
        self.setUpUI()
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    private var dataSource: Array = [[CODCellModel]]()
    
    fileprivate lazy var tableView:UITableView = {
        let tabelV = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        tabelV.estimatedRowHeight = 80
        tabelV.rowHeight = UITableView.automaticDimension
        tabelV.separatorStyle = .none
        tabelV.backgroundColor = UIColor.clear
        tabelV.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tabelV.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tabelV.delegate = self
        tabelV.dataSource = self
        
        ///注册单元格
        self.registerCellClassForTableView(tableView: tabelV)
        return tabelV
    }()
    
    deinit {
        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self)
        self.realmNotification?.invalidate()
    }
}
private extension CODGroupManageVC {
    
    func createDataSource() {
        if dataSource.count > 0 {
            dataSource.removeAll()
        }
        guard let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.groupChatId) else {
            return
        }
        
        memberArr = groupModel.member
        
        let memberId = CODGroupMemberModel.getMemberId(roomId: self.groupChatId, userName: UserManager.sharedInstance.jid)
        let member = CODGroupMemberRealmTool.getMemberById(memberId)
        if member?.userpower == 10 {
            self.isGroupOwner = true
            sectionAdditionCount = 2
        }else{
            self.isGroupOwner = false
            sectionAdditionCount = 0
        }
        
        var firstArr = Array<CODCellModel>()
        if self.isGroupOwner {
            var model = self.createModel(title: "群管理权转让", subTitle: "", image: "", type: .baseType, isOn: false)
            model.action.didSelected = { [weak self] in
                guard let self = self else { return }
                let ctl = CreGroupChatViewController()
                ctl.ctlType = .transferAdmin
                ctl.groupChatModel = groupModel
                self.navigationController?.pushViewController(ctl, animated: true)
            }
            firstArr.append(model)
        }
        
        groupLinkModel = self.createModel(title: groupModel.userid.count > 0 ? "群链接" : "创建群链接", subTitle: "", image: "", type: .baseType, isOn: false)
        groupLinkModel?.action.didSelected = {  [weak self] in
            guard let self = self else { return }
            if groupModel.userid.count > 0 {
                self.setNotInvite(groupModel: groupModel) { [weak self] (userAction) in
                    guard let `self` = self else { return }
                    if userAction {
                        let ctl = CODGroupLinkViewController.init(linkId: groupModel.userid, groupModel: groupModel)
                        self.navigationController?.pushViewController(ctl, animated: true)
                    }
                }
                return
            }
            self.createGroupLink(groupModel: groupModel)
        }
        if let model = self.groupLinkModel {
            firstArr.append(model)
        }
        
        dataSource.append(firstArr)
        
        var dataSourceArr: Array<CODCellModel> = Array<CODCellModel>()
        

        speakModel = self.createModel(title: "允许群成员发言", subTitle: "", image: "", type: .switchType, isOn: groupModel.canspeak)
        speakModel!.action.switchButtonAction = { [weak self] isOn in
            
            guard let `self` = self else { return }
            self.sendIQ(action: .speak, isOn: !isOn)

//            if isOn == true {
//                let title =  "开启后，群成员可通过二维码邀请他人入群，通过群链接入群也将生效"
//                let alertCtl = UIAlertController.init(title: nil, message: title , preferredStyle: UIAlertController.Style.alert)
//                let action1 = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.default, handler: { (action) in
//                    self.speakModel?.isOn = false
//                })
//                alertCtl.addAction(action1)
//                let action2 = UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default, handler: { (action) in
//                    self.sendIQ(action: .speak, isOn: isOn)
//                })
//                alertCtl.addAction(action2)
//                self.present(alertCtl, animated: true, completion: nil)
//            } else {
//            }
            
        }
        dataSourceArr.append(speakModel!)
        inviteModel = self.createModel(title: "允许邀请入群", subTitle: "", image: "", type: .switchType, isOn: !groupModel.notinvite)
        inviteModel!.action.switchButtonAction = { [weak self] isOn in
            
            guard let `self` = self else { return }
            
            if isOn == true {
                let title =  "开启后，群成员可通过二维码邀请他人入群，通过群链接入群也将生效"
                let alertCtl = UIAlertController.init(title: nil, message: title , preferredStyle: UIAlertController.Style.alert)
                let action1 = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.default, handler: { (action) in
                    self.inviteModel?.isOn = false
                })
                alertCtl.addAction(action1)
                let action2 = UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default, handler: { (action) in
                    self.sendIQ(action: .invite, isOn: isOn)
                })
                alertCtl.addAction(action2)
                self.present(alertCtl, animated: true, completion: nil)
            } else {
                self.sendIQ(action: .invite, isOn: isOn)
            }
            
            
            
        }
        dataSourceArr.append(inviteModel!)
        
        checkInfoModel = self.createModel(title: "查看非好友信息", subTitle: "", image: "", type: .switchType, isOn: groupModel.userdetail)
        checkInfoModel?.action.switchButtonAction = { [weak self] isOn in
            guard let `self` = self else { return }

            if isOn == false {
//                let title =  NSLocalizedString("关闭后，群成员无法查看陌生人信息，且无法进行转发，收藏和@群成员操作，发消息后无法查看已读清单", comment: "")
                let title =  NSLocalizedString("关闭后，群成员无法查看陌生人信息，且无法进行转发，收藏和@群成员操作", comment: "")
                let alertCtl = UIAlertController.init(title: nil, message: title , preferredStyle: UIAlertController.Style.alert)
                let action1 = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.default, handler: { (action) in
                    self.checkInfoModel?.isOn = !isOn
                })
                alertCtl.addAction(action1)
                let action2 = UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default, handler: { (action) in
                    self.sendIQ(action: .checkInfo, isOn: isOn)
                })
                alertCtl.addAction(action2)
                self.present(alertCtl, animated: true, completion: nil)
            } else {
                self.sendIQ(action: .checkInfo, isOn: isOn)
            }
            
        }
        
        dataSourceArr.append(checkInfoModel!)
        
        atAllModel = self.createModel(title: "群成员@所有人", subTitle: "", image: "", type: .switchType, isOn: groupModel.xhreferall)
        atAllModel!.action.switchButtonAction = { [weak self] isOn in
            
            guard let `self` = self else { return }
            
            if isOn {
                
                let title =  "开启后，群成员发送消息时可以@所有成员。"
                
                let alertCtl = UIAlertController.init(title: nil, message: title , preferredStyle: UIAlertController.Style.alert)
                let action1 = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.default, handler: { (action) in
                    self.atAllModel?.isOn = false
                })
                alertCtl.addAction(action1)
                let action2 = UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default, handler: { (action) in
                    self.sendIQ(action: .atAll, isOn: isOn)
                })
                alertCtl.addAction(action2)
                self.present(alertCtl, animated: true, completion: nil)
                
            } else {
                self.sendIQ(action: .atAll, isOn: isOn)
            }
            
        }
        dataSourceArr.append(atAllModel!)
        
        showAllHistoryModel = self.createModel(title: "查看入群前消息", subTitle: "", image: "", type: .switchType, isOn: groupModel.xhshowallhistory)
        showAllHistoryModel!.action.switchButtonAction = { [weak self] isOn in
            
            guard let `self` = self else { return }
            
            if isOn {
                
                let title =  "开启后，所有人都可以查看自己入群前的历史消息。"
                
                let alertCtl = UIAlertController.init(title: nil, message: title , preferredStyle: UIAlertController.Style.alert)
                let action1 = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.default, handler: { (action) in
                    self.showAllHistoryModel?.isOn = false
                })
                alertCtl.addAction(action1)
                let action2 = UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default, handler: { (action) in
                    self.sendIQ(action: .showAllHistory, isOn: isOn)
                })
                alertCtl.addAction(action2)
                self.present(alertCtl, animated: true, completion: nil)
                
            } else {
                self.sendIQ(action: .showAllHistory, isOn: isOn)
            }
            
        }
        dataSourceArr.append(showAllHistoryModel!)
        
        
        if self.isGroupOwner {
           
            
            let memberTemp = self.memberArr.sorted(byKeyPath: "userpower", ascending: false).first
            setAllAdminsModel = self.createModel(title: "将当前所有成员设为管理员", subTitle: "", image: "", type: .switchType, isOn: memberTemp?.userpower == 20 ? true : false)
            setAllAdminsModel!.action.switchButtonAction = { [weak self] isOn in
                guard let `self` = self else { return }
                self.sendIQ(action: .setAllAdmins, isOn: isOn)
            }
            dataSourceArr.append(setAllAdminsModel!)
            
            for member in groupModel.member {
                var placeholder = NSAttributedString(string: "")
                if member.userpower < 30 {
                    placeholder = NSAttributedString(string: NSLocalizedString(member.userpower == 10 ? "群主" : "管理员", comment: ""))
                    placeholder = placeholder.colored(with: UIColor(hexString: kSubTitleColors8E8E92)!)
                }else{
                    let result = CustomUtil.getOnlineTimeStringAndStrColor(with: member)
                    placeholder = NSAttributedString(string: NSLocalizedString(result.timeStr, comment: ""))
                    placeholder = placeholder.colored(with: result.strColor)
                }
                
                var model4 = self.createModel(title: member.getMemberNickName(), subTitle: "", placeholder: placeholder, image: member.userpic, type: .switchType, isOn: member.userpower < 30 ? true : false)
                
                if member.name == UserManager.sharedInstance.nickname {
                    model4.isEnable = false
                }
                
                model4.action.switchButtonActionWithIndexPath = { [weak self] (isOn, indexPath) in
                    guard let `self` = self else { return }
                    self.sendIQ(action: .setAdmin(jid: member.jid, indexPath: indexPath), isOn: isOn)
                }
                
                memberCellArr.append(model4)
            }
            dataSource.append(dataSourceArr)
            dataSource.append(memberCellArr)
        } else {
            dataSource.append(dataSourceArr)
        }
    }
    
    func createModel(title: String = "",
                     subTitle: String = "",
                     placeholder: NSAttributedString = NSAttributedString(string: ""),
                     image: String = "",
                     type: CODCellType,
                     isOn: Bool) -> (CODCellModel) {
        var model = CODCellModel()
        model.title = title
        model.subTitle = subTitle
        model.attributeSubTitle = placeholder
        model.type = type
        model.isOn = isOn
        model.iconName = image
        return model
    }
    
    func addNotification() {
        guard let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.groupChatId) else {
            return
        }
        self.realmNotification = groupModel.observe({ [weak self] (objectChange) in
            switch objectChange {
                
            case .error(_):
                break
            case .change(let properties):
                    guard let self = self else { return }
                for property in properties.1 {
                        
                        if property.name == "canspeak"{
                            self.speakModel?.isOn = property.newValue as? Bool
                        }

                        if property.name == "notinvite"{
                            self.inviteModel?.isOn = !(property.newValue as! Bool)
                        }

                        if property.name == "xhreferall" {
                            self.atAllModel?.isOn = property.newValue as? Bool
                        }
                        
                        if property.name == "userdetail" {
                            self.checkInfoModel?.isOn = property.newValue as? Bool
                        }
                        
                        if property.name == COD_xhshowallhistory {
                            self.showAllHistoryModel?.isOn = property.newValue as? Bool
                        }
                        
                        if property.name == "userid" {
                            if let userid = property.newValue as? String {
                                self.groupLinkModel?.title = userid.count > 0 ? "群链接" : "创建群链接"
                            }
                        }
                    }
                break
            case .deleted:
                break
            @unknown default:
                break
            }
            
        })
    }
    
    func setUpUI() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-kSafeArea_Bottom)
        }
    }
}



extension CODGroupManageVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.section][indexPath.row]
        model.action.didSelected?()
        
    }
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODMessageDetailCell.self, forCellReuseIdentifier: "CODMessageDetailCellID")
        tableView.register(CODMessageDetailImageCell.self, forCellReuseIdentifier: "CODMessageDetailImageCellID")
        tableView.register(CODMessageDetailSwitchCell.self, forCellReuseIdentifier: "CODMessageDetailSwitchCellID")
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        let  datas = dataSource[section]
        return datas.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let datas = dataSource[indexPath.section]
        let model = datas[indexPath.row]
        if case .switchType = model.type {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODMessageDetailSwitchCellID", for: indexPath) as? CODMessageDetailSwitchCell
            if cell == nil{
                cell = CODMessageDetailSwitchCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODMessageDetailSwitchCellID")
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
            
            cell?.title = model.title
            cell?.placeholerAttrStr = model.attributeSubTitle
            cell?.switchIsOn = model.isOn
            cell?.imageStr = model.iconName
            if let picStr = model.iconName {
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: picStr) { (image) in
                    cell?.iconView.image = image
                }
            }
            
            cell?.enable = model.isEnable ?? true
            
            cell?.onBlock = { [weak self] isOn in
                model.action.switchButtonAction?(isOn)
                model.action.switchButtonActionWithIndexPath?(isOn, indexPath)
            }
            
            model.$isOn
                .filterNil()
                .bind(to: cell!.switchBtn.rx.isOn)
                .disposed(by: cell!.rx.prepareForReuseBag)
            
            return cell!
        }else if case .imageType = model.type {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODMessageDetailImageCellID", for: indexPath) as? CODMessageDetailImageCell
            if cell == nil{
                cell = CODMessageDetailImageCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODMessageDetailImageCellID")
            }
            if indexPath.row == datas.count - 1 {
                cell?.isLast = true
            }else{
                cell?.isLast = false
            }
            cell?.title = model.title
            cell?.placeholer = model.placeholderString
            cell?.imageV = UIImage.init(named: model.iconName ?? "")
            return cell!
        }else{
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODMessageDetailCellID", for: indexPath) as? CODMessageDetailCell
            if cell == nil{
                cell = CODMessageDetailCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODMessageDetailCellID")
            }
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
            
            cell?.title = model.title
            cell?.placeholer = model.placeholderString
            cell?.subTitle = model.subTitle
            cell?.imageStr = model.iconName
            
            model.$title
                .bind(to: cell!.titleLab.rx.text)
                .disposed(by: cell!.rx.prepareForReuseBag)
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == dataSource.count - 1 {
            return 47
        }else{
            return 43.5
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeight = 20
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: CGFloat(sectionHeight)))
        bgView.backgroundColor = UIColor.clear
        
        return bgView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let textString = self.getHeaderString(section: section)
        let textFont = UIFont.systemFont(ofSize: 12)
        var sectionHeight: CGFloat = 0.01
        sectionHeight = self.getHeaderHeight(textString: textString, width: KScreenWidth - 30, textFont: textFont)
        let footerHeight = textString.getStringHeight(font: textFont, lineSpacing: 0, fixedWidth: KScreenWidth - 30)
        let textLabel = UILabel.init(frame: CGRect(x: 15, y: 7, width: KScreenWidth-30, height: footerHeight))
        textLabel.textAlignment = NSTextAlignment.left
        textLabel.font = textFont
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor(hexString: kSubTitleColors8E8E92)
        textLabel.text = textString
        
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: sectionHeight))
        bgView.backgroundColor = UIColor.clear
        bgView.addSubview(textLabel)
        
        return bgView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 1 {
            return 0.01
        }
        return 20.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 1{
            let textString = self.getHeaderString(section: section)
            let textFont = UIFont.systemFont(ofSize: 12)
            return  self.getHeaderHeight(textString: textString, width: KScreenWidth, textFont: textFont)+5
        }
        if  section == 2 && isGroupOwner {
            let textString = self.getHeaderString(section: section)
            let textFont = UIFont.systemFont(ofSize: 12)
            return  self.getHeaderHeight(textString: textString, width: KScreenWidth, textFont: textFont)+5
        }
        
        return 0.01
    }
}

extension CODGroupManageVC {
    
    func getHeaderString(section: Int) -> String {
        var sectionString = ""
        
        switch section {
        case 1:
            sectionString = "只有群主/管理员可以移除成员，编辑群组名称、群公告和群头像。"
        default:
            sectionString = ""
        }
        return sectionString
    }
    
    func getHeaderHeight(textString: String, width: CGFloat,textFont:UIFont) -> CGFloat {
        return 60
    }
    

    fileprivate func setAdmin(jid: String, indexPath: IndexPath, isOn: Bool) {
        let dict = self.dictionaryWithSetManager(jid: jid, isOn: isOn)
        XMPPManager.shareXMPPManager.setRequest(param: dict, xmlns: COD_com_xinhoo_groupChat) { (result) in
            switch result {
            case .success(let model):
                if let isAdd = model.actionJson?["isAdd"].bool {
                    self.updateSourceData(action: .setAdmin(jid: jid, indexPath: indexPath), result: isAdd)
                } else {
                    self.updateSourceData(action: .setAdmin(jid: jid, indexPath: indexPath), result: !isOn)
                }
                break
            case .failure(_):
                CODProgressHUD.showErrorWithStatus("设置失败")
                self.updateSourceData(action: .setAdmin(jid: jid, indexPath: indexPath), result: !isOn)
            }
        }
    }
    
    func sendIQ(action: IQAction, isOn:Bool) {
        
        switch action {
        case .invite:
            let dict = self.dictionaryWithChangeMute(typeStr: "notinvite", isGroup: true, isOn: !isOn)
            XMPPManager.shareXMPPManager.setRequest(param: dict, xmlns: COD_com_xinhoo_setting) { [weak self] (result) in
                guard let `self` = self else { return }
                
                switch result {
                case .success(let model):
//                    if let notinvite = model.actionJson?["setting"]["notinvite"].bool {
//                        self.updateSourceData(action: .invite, result: !notinvite)
//                    } else {
//                        self.updateSourceData(action: .invite, result: !isOn)
//                    }
                    
                    break
                    
                case .failure(_):
                    self.updateSourceData(action: .invite, result: !isOn)
                    CODProgressHUD.showErrorWithStatus("设置失败")
                }
            }
        case .atAll:
            let dict: [String : Any] = ["name": COD_changeGroup,
                                     "requester": UserManager.sharedInstance.jid,
                                     "itemID": self.groupChatId ?? 0,
                                     "setting": ["xhreferall":isOn]]
            
            XMPPManager.shareXMPPManager.setRequest(param: dict, xmlns: COD_com_xinhoo_setting) { [weak self] (result) in
                guard let `self` = self else { return }
                
                switch result {
                case .success(let model):
//                    if let xhreferall = model.actionJson?["setting"]["xhreferall"].bool {
//                        self.updateSourceData(action: .atAll, result: xhreferall)
//                    } else {
//                        self.updateSourceData(action: .atAll, result: !isOn)
//                    }
                    
                    break
                    
                case .failure(_):
                    self.updateSourceData(action: .atAll, result: !isOn)
                    CODProgressHUD.showErrorWithStatus("设置失败")
                }
            }
   
            
        case .setAllAdmins:
            let dict: [String: Any] = ["name": COD_SetAllAdmins,
                                             "requester": UserManager.sharedInstance.jid,
                                             "roomID": self.groupChatId ?? 0,
                                             "isAdd": isOn]

            XMPPManager.shareXMPPManager.setRequest(param: dict, xmlns: COD_com_xinhoo_groupChat) { [weak self] (result) in
                guard let `self` = self else { return }
                
                switch result {
                case .success(let model):
                    if let isAdd = model.actionJson?["isAdd"].bool {
                        self.updateSourceData(action: .setAllAdmins, result: isAdd)
                    } else {
                        self.updateSourceData(action: .setAllAdmins, result: !isOn)
                    }
                    
                    break
                    
                case .failure(_):
                    self.updateSourceData(action: .setAllAdmins, result: !isOn)
                    CODProgressHUD.showErrorWithStatus("设置失败")
                }
            }
            
        case .setAdmin(jid: let jid, indexPath: let indexPath):
            setAdmin(jid: jid, indexPath: indexPath, isOn: isOn)
        case .checkInfo:
            let dict = self.dictionaryWithChangeMute(typeStr: "userdetail", isGroup: true, isOn: isOn)
            XMPPManager.shareXMPPManager.setRequest(param: dict, xmlns: COD_com_xinhoo_setting) { [weak self] (result) in
                guard let `self` = self else { return }
                
                switch result {
                case .success(let model):
//                    if let userdetail = model.actionJson?["setting"]["userdetail"].bool {
//                        self.updateSourceData(action: .checkInfo, result: userdetail)
//                    } else {
//                        self.updateSourceData(action: .checkInfo, result: !isOn)
//                    }
                    
                    break
                    
                case .failure(_):
                    self.updateSourceData(action: .checkInfo, result: !isOn)
                    CODProgressHUD.showErrorWithStatus("设置失败")
                }
            }
            break
        case .speak:
            let dict = self.dictionaryWithChangeMute(typeStr: COD_CanSpeak, isGroup: true, isOn: !isOn)
           XMPPManager.shareXMPPManager.setRequest(param: dict, xmlns: COD_com_xinhoo_setting) { [weak self] (result) in
               guard let `self` = self else { return }
               
               switch result {
               case .success(let model):
//                   if let speak = model.actionJson?["setting"]["canspeak"].bool {
//                       self.updateSourceData(action: .speak, result: speak)
//                   } else {
//                       self.updateSourceData(action: .speak, result: !isOn)
//                   }
                   break
               case .failure(_):
                   self.updateSourceData(action: .speak, result: !isOn)
                   CODProgressHUD.showErrorWithStatus("设置失败")
               }
           }
            
        case .showAllHistory:
            let dict = self.dictionaryWithChangeMute(typeStr: COD_xhshowallhistory, isGroup: true, isOn: isOn)
            XMPPManager.shareXMPPManager.setRequest(param: dict, xmlns: COD_com_xinhoo_setting) { [weak self] (result) in
                guard let `self` = self else { return }
                switch result {
                case .success(_):
                    break
                case .failure(_):
                    self.updateSourceData(action: .showAllHistory, result: !isOn)
                    CODProgressHUD.showErrorWithStatus("设置失败")
                }
            }
        }
     
    }
    
    func dictionaryWithChangeMute(typeStr: String, isGroup: Bool, isOn: Bool) -> Dictionary<String, Any> {
        return ["name": COD_changeGroup,
                "requester": UserManager.sharedInstance.jid,
                "itemID": self.groupChatId ?? 0,
                "setting": [typeStr:isOn]]
    }
    
    func dictionaryWithSetManager(jid: String, isOn: Bool) -> Dictionary<String, Any> {
        return ["name": COD_SetAdmins,
                "requester": UserManager.sharedInstance.jid,
                "roomID": self.groupChatId ?? 0,
                "adminTarget": jid,
                "isAdd": isOn]
    }
    
    func createGroupLink(groupModel: CODGroupChatModel) {
        CODAlertVcPresent(confirmBtn: NSLocalizedString("确定", comment: ""), message: nil, title: NSLocalizedString("您确定要为此群创建一个邀请链接吗？", comment: ""), cancelBtn: NSLocalizedString("取消", comment: ""), handler: { [weak self] (UIAlertAction) in
            
            let params: [String: Any] = [
                "name": COD_getuniqueshareid,
                "roomName": groupModel.jid,
            ]
            
            XMPPManager.shareXMPPManager.getRequest(param: params, xmlns: COD_com_xinhoo_groupchatsetting) { [weak self] (result) in
                
                guard let `self` = self else { return }
                
                switch result {
                case .success(let data):
                    if let userid = data.dataJson?.string {
                        self.setNotInvite(groupModel: groupModel) { [weak self] (userAction) in
                            guard let `self` = self else { return }
                            if userAction {
                                let ctl = CODGroupLinkViewController.init(linkId: userid, groupModel: groupModel)
                                self.navigationController?.pushViewController(ctl, animated: true)
                            }
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
        }, viewController: self)
    }
    
    
    func setNotInvite(groupModel: CODGroupChatModel, userAction: @escaping (_ isAction: Bool) -> Void) {
        if groupModel.notinvite {
            let alertCtl = UIAlertController.init(title: nil, message: NSLocalizedString("邀请入群已关闭，群链接将无法正常使用，是否开启“允许邀请入群”设定？", comment: "") , preferredStyle: UIAlertController.Style.alert)
            let action1 = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.default, handler: { (action) in
                userAction(true)
            })
            alertCtl.addAction(action1)
            let action2 = UIAlertAction.init(title: "开启", style: UIAlertAction.Style.default, handler: { (action) in
                userAction(true)
                let dict = self.dictionaryWithChangeMute(typeStr: "notinvite", isGroup: true, isOn: !groupModel.notinvite)
                XMPPManager.shareXMPPManager.setRequest(param: dict, xmlns: COD_com_xinhoo_setting) { [weak self] (result) in
                    guard let `self` = self else { return }
                    switch result {
                    case .success(_):
                        self.updateSourceData(action: .invite, result: !groupModel.notinvite)
                        break
                    case .failure(_):
                        CODProgressHUD.showErrorWithStatus("设置失败")
                    }
                }
            })
            alertCtl.addAction(action2)
            self.present(alertCtl, animated: true, completion: nil)
        }else{
            userAction(true)
        }
    }
    
}

extension CODGroupManageVC: XMPPStreamDelegate {
    
    func updateSourceData(action: IQAction, result: Bool){
        guard let groupModel = CODGroupChatRealmTool.getGroupChat(id: self.groupChatId) else {
            return
        }
        try! Realm.init().write {
            
            switch action {
            case .invite:
                groupModel.notinvite = result
                inviteModel?.isOn = result
                
            case .atAll:
                groupModel.xhreferall = result
                atAllModel?.isOn = result
                
            case .setAllAdmins:
                if result {
                    for member in memberArr {
                        if member.userpower == 30 {
                            member.userpower = 20
                        }
                    }
                    
                }else{
                    for member in memberArr {
                        if member.userpower == 20 {
                            member.userpower = 30
                        }
                    }
                }
                for var memberCell in memberCellArr {
                    if memberCell.isEnable ?? true == false {
                        continue
                    }
                    memberCell.isOn = result
                }
                setAllAdminsModel?.isOn = result
                
            case .setAdmin(jid: let jid, indexPath: let indexPath):
                let memberId = CODGroupMemberModel.getMemberId(roomId: groupModel.roomID, userName: jid)
                guard let groupMemberModel = CODGroupMemberRealmTool.getMemberById(memberId) else {
                    return
                }
                if result {
                    groupMemberModel.userpower = 20
                } else {
                    groupMemberModel.userpower = 30
                }
                
                memberCellArr[indexPath.row].isOn = result
                
            case .checkInfo:
                groupModel.userdetail = result
                checkInfoModel?.isOn = result
                break
            case .speak:
                groupModel.canspeak = result
                speakModel?.isOn = result
            case .showAllHistory:
                groupModel.xhshowallhistory = result
                showAllHistoryModel?.isOn = result
            }
   
            
        }
    }
    
}


