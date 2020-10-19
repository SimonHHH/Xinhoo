//
//  CODChannelSubscriberViewController.swift
//  COD
//
//  Created by XinHoo on 2019/12/5.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxRealm

class CODChannelSubscriberViewController: BaseViewController {
    
    var groupChatId: Int!
        
    public var groupChatModel: CODChannelModel?  = nil
    
    public var groupMembers = Array<CODGroupMemberModel>()
    
    private var dataSource: Array = [[CODCellModel]]()
    
    private var memberCellArr: [CODCellModel] = []
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setBackButton()
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        self.navigationItem.title = NSLocalizedString("订阅者", comment: "")
        self.getGroupInfo()
        self.createGroupDataSource()
        
        self.setUpUI()
                
    }
    
    func getGroupInfo() {
        guard let groupChatModel = CODChannelModel.getChannel(by: groupChatId) else {
            return
        }
        
        self.groupChatModel = groupChatModel
        
        let dict: NSDictionary = ["name":COD_GroupMembersOnlineTime,
                                  "requester":UserManager.sharedInstance.jid,
                                  "roomID":groupChatModel.roomID] as NSDictionary
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_groupChat, actionDic: dict)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if delegate.isNetwork {
            CODDownLoadManager.sharedInstance.updateAvatar(userPicID: groupChatModel.grouppic, complete: nil)
        }
        
        
//        if let members = self.groupChatModel?.member {
//            let membersTemp = members.sorted(byKeyPath: "userpower", ascending: true)
//            var membersArr = Array<CODGroupMemberModel>()
//            
//            for member in membersTemp {
//                membersArr.append(member)
//            }
//            self.groupMembers = membersArr
//        }
    }
    
    func setUpUI() {
        
//        tableView.tableFooterView = self.footerView
//        tableView.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0.01))

        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(0)
        }
    }
    
    @objc func createGroupDataSource() {
        if dataSource.count > 0 {
            dataSource.removeAll()
        }
        
        var model = self.createModel(title: "添加成员", subTitle: "", placeholder: "", image: "", type: .baseType)
        model.titleColor = UIColor.init(hexString: kBlueTitleColorS)
        
        var model1 = self.createModel(title: "删除成员", subTitle: "", placeholder: "", image: "", type: .baseType)
        model1.titleColor = UIColor.init(hexString: kBlueTitleColorS)
        dataSource.append([model, model1])
        
        guard let channel = self.groupChatModel else {
            return
        }
        

        dataSource.append(self.memberCellArr)
        Observable.arrayWithChangeset(from: channel.member)
        .map { $0.0 }
        .map { [weak self] (members) -> [CODCellModel] in
            
            guard let `self` = self else { return [] }
            
            self.groupMembers = members.chennalMemberSorted()
            
            return self.groupMembers.map { (member) -> CODCellModel in
                
                var model = self.createModel(title: member.getMemberNickName(), subTitle: nil, placeholder: nil, image: member.userpic, type: .memberType)
                model.userType = member.userTypeEnum
//                if member.loginStatus.count > 0 {
//                    let result = CustomUtil.getOnlineTimeStringAndStrColor(with: member)
//                    model.attributeSubTitle = NSAttributedString(string: result.timeStr).colored(with: result.strColor)
//                }
                
                return model
            }
        }
        .subscribe(onNext: { [weak self] (cellModels) in
            
            guard let `self` = self else { return }
            
            self.dataSource.removeLast()
            self.memberCellArr.removeAll()
            self.memberCellArr.append(contentsOf: cellModels)
            self.dataSource.append(self.memberCellArr)

            self.tableView.reloadData()
            
        })
        .disposed(by: self.disposeBag)
                
        
        
        
        
//        var memberCellArr: Array<CODCellModel> = Array<CODCellModel>()
//        groupMembers.sort { (model1, model2) -> Bool in
//            model1.lastlogintime > model2.lastlogintime
//        }
//        for member in groupMembers {
//            var placeHolder = ""
////            switch member.userpower {
////            case 10:
////                placeHolder = NSLocalizedString("群主", comment: "")
////            case 20:
////                placeHolder = NSLocalizedString("管理员", comment: "")
////            default:
////                placeHolder = ""
////            }
//            var model15 = self.createModel(title: member.getMemberNickName(), subTitle: "", placeholder: placeHolder, image: member.userpic, type: .memberType)
//            if member.loginStatus.count > 0 {
//                let result = CustomUtil.getOnlineTimeStringAndStrColor(with: member)
//                model15.attributeSubTitle = NSAttributedString(string: result.timeStr).colored(with: result.strColor)
//            }
//            memberCellArr.append(model15)
//        }
        
        
        tableView.reloadData()
    }
    
    
    fileprivate lazy var tableView:UITableView = {
        let tabelView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        tabelView.estimatedRowHeight = 48
        tabelView.rowHeight = UITableView.automaticDimension
        tabelView.separatorStyle = .none
        tabelView.backgroundColor = UIColor.clear
        tabelView.delegate = self
        tabelView.dataSource = self
        ///注册单元格
        self.registerCellClassForTableView(tableView: tabelView)
        return tabelView
    }()
    
//    lazy var footerView: UIView = {
//        let footerV = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 51))
//        return footerV
//    }()
    
    func createModel(title: String = "",
                             subTitle: String?,
                             placeholder: String?,
                             image: String = "",
                             type: CODCellType) -> (CODCellModel) {
        var model = CODCellModel()
        model.title = title
        if let subTitle = subTitle {
            model.subTitle = subTitle
        }
        if let placeholder = placeholder {
            model.placeholderString = placeholder
        }
        model.type = type
        model.iconName = image
        return model
    }
    
    @objc func updateGroupMember() {
        dispatch_async_safely_to_main_queue {
            self.getGroupInfo()
            self.createGroupDataSource()
        }
    }
    
}
extension CODChannelSubscriberViewController: UITableViewDelegate,UITableViewDataSource{
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODMessageDetailCell.self, forCellReuseIdentifier: "CODMessageDetailCellID")
        tableView.register(CODMessageDetailImageCell.self, forCellReuseIdentifier: "CODMessageDetailImageCellID")
        tableView.register(CODMessageDetailSwitchCell.self, forCellReuseIdentifier: "CODMessageDetailSwitchCellID")
        tableView.register(CODLongLongTextCell.self, forCellReuseIdentifier: "CODLongLongTextCellID")
        tableView.register(UINib.init(nibName: "CODGroupMemberAdvTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CODGroupMemberAdvTableViewCell")
        tableView.register(UINib.init(nibName: "CODGroupNameAndAvatarCell", bundle: Bundle.main), forCellReuseIdentifier: "CODGroupNameAndAvatarCell")
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
            cell?.placeholer = model.placeholderString
            cell?.enable = model.isEnable ?? false
            cell?.switchIsOn = model.isOn
            cell?.imageStr = model.iconName
            cell?.onBlock = { [weak self] isOn -> () in
//                self?.sendIQ(indexPath: indexPath , isOn: isOn)
            }
            return cell!
        } else if case .imageType = model.type {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODMessageDetailImageCellID", for: indexPath) as? CODMessageDetailImageCell
            if cell == nil{
                cell = CODMessageDetailImageCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODMessageDetailImageCellID")
            }
            if indexPath.row == datas.count - 1 {
                cell?.isLast = true
            }else{
                cell?.isLast = false
            }
            cell?.cellType = .arrow
            cell?.title = model.title
            cell?.placeholer = model.placeholderString
            cell?.imageV = UIImage.init(named: model.iconName ?? "")
            return cell!
        }else if case .longTextType = model.type {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODLongLongTextCellID", for: indexPath) as? CODLongLongTextCell
            if cell == nil{
                cell = CODLongLongTextCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODLongLongTextCellID")
            }
            if indexPath.row == datas.count - 1 {
                cell?.isLast = true
            }else{
                cell?.isLast = false
            }
            cell?.title = model.title
            cell?.subTitle = model.subTitle
            cell?.imageStr = model.iconName
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
            
            return cell!
        }else if case .memberType = model.type {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CODGroupMemberAdvTableViewCell", for: indexPath) as? CODGroupMemberAdvTableViewCell
            if cell == nil{
                cell = CODGroupMemberAdvTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CODGroupMemberAdvTableViewCell")
            }
            if indexPath.row == datas.count - 1 {
                cell?.isLast = true
            }else{
                cell?.isLast = false
            }
            if indexPath.row == 0 {
                cell?.isTop = true
            }else{
                cell?.isTop = false
            }
            cell?.titleStr = model.title
            if model.attributeSubTitle != nil {
                cell?.attributeSubTitleStr = model.attributeSubTitle!
            }else{
                cell?.attributeSubTitleStr = nil
            }
            if model.placeholderString?.count ?? 0 > 0 {
                cell?.placeholderStr = model.placeholderString
            }else{
                cell?.placeholderStr = nil
            }
            
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.iconName!) { (image) in
                cell?.imgView.image = image
            }
            
            cell?.userType = model.userType
            
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
            cell?.titleColor = model.titleColor
            cell?.placeholer = model.placeholderString
            cell?.subTitle = model.subTitle
            cell?.imageStr = model.iconName
            cell?.isHiddenArrow = true
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let bg = UIView(frame: CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: 33.0))
            let lab = UILabel(frame: CGRect(x: 15.0, y: 6.0, width: KScreenWidth-30, height: 16))
            lab.text = "此列表仅频道管理员可见。"
            lab.font = UIFont.systemFont(ofSize: 11.0)
            lab.textColor = UIColor(hexString: kSectionFooterTextColorS)
            bg.addSubview(lab)
            return bg
        }else{
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 33.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell: CODGroupNameAndAvatarCell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? CODGroupNameAndAvatarCell {
            if cell.groupNameField.isEditing {
                self.view.endEditing(true)
                return
            }
        }
        
        self.selectGroupChatRow(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

private extension CODChannelSubscriberViewController {
    
    func selectGroupChatRow(indexPath: IndexPath){
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                addMemberAction()
                return
            }else if indexPath.row == 1{
                subtractMemberAction()
                return
            }
        case 1:
            let model = groupMembers[indexPath.row]
            
            if model.username.contains("cod_60000000") {
                self.navigationController?.pushViewController(CODLittleAssistantDetailVC())
                return
            }
            
            if model.jid == UserManager.sharedInstance.jid {
                return
            }
            
            if let contactModel = CODContactRealmTool.getContactByJID(by: model.jid), contactModel.isValid == true  {
                
                
                CustomUtil.pushToPersonVC(contactModel: contactModel, memberModel: model, updateMemberInfoBlock: { [weak self] in
                    self?.updateGroupMember()
                })
                
            }else{
                CustomUtil.pushToStrangerVC(type: .groupType, memberModel: model)
            }
        default:
            break
        }

    }
    
    func addMemberAction() {
        
        
        
        guard let groupModel = CODChannelModel.getChannel(by: self.groupChatId) else {
            return
        }
        
        let ctl = CreGroupChatViewController()
        ctl.ctlType = .addMember
        ctl.groupChatModel = groupModel
        ctl.channelModel = groupModel
        self.navigationController?.pushViewController(ctl, animated: true)
    }
    
    func subtractMemberAction() {
        var memberTempArr = Array<CODGroupMemberModel>()
        
        for member in groupMembers {
            if member.jid == UserManager.sharedInstance.jid {
                continue
            }
            memberTempArr.append(member)
        }
        
        if groupMembers.count <= 1 || memberTempArr.count <= 0 {
            CODProgressHUD.showErrorWithStatus("没有可移除的群成员")
        }else{
            
            guard let groupModel = CODChannelModel.getChannel(by: self.groupChatId) else {
                return
            }
            
            let ctl = CreGroupChatViewController()
            ctl.ctlType = .subtractMember
            ctl.groupChatModel = groupModel
            ctl.channelModel = groupModel
            self.navigationController?.pushViewController(ctl, animated: true)
        }
    }
}
