//
//  CODChannelManagerViewController.swift
//  COD
//
//  Created by XinHoo on 2019/12/5.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODChannelManagerViewController: BaseViewController {

    var groupChatId: Int!
    var groupManager: CODGroupMemberModel!
    
    var memberArr: Array<CODGroupMemberModel>!
    
    var isGroupOwner = false
        
    var operationDic: Dictionary<String,Int> = [:]   //记录被操作的成员<jid:Int>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("管理员", comment: "")
        self.setBackButton()
        self.createDataSource()
        self.setUpUI()
        
//        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
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
//        XMPPManager.shareXMPPManager.xmppStream.removeDelegate(self)
    }

}

private extension CODChannelManagerViewController {
    
    func createDataSource() {
        if dataSource.count > 0 {
            dataSource.removeAll()
        }
        guard let groupModel = CODChannelModel.getChannel(by: self.groupChatId) else {
            return
        }
        
        var memberCellArr: Array<CODCellModel> = Array<CODCellModel>()
        
        memberArr = groupModel.member.chennalMemberSorted()
        
        for member in memberArr {
            var placeholder = NSAttributedString(string: "")
            if member.userpower < 30 {
                placeholder = NSAttributedString(string: NSLocalizedString("管理员", comment: ""))
                placeholder = placeholder.colored(with: UIColor(hexString: kSubTitleColors8E8E92)!)
            }
            
            let model4 = self.createModel(title: member.getMemberNickName(), subTitle: "", placeholder: placeholder, image: member.userpic, type: .switchType, isOn: member.userpower < 30 ? true : false)
            memberCellArr.append(model4)
        }
        dataSource.append(memberCellArr)
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
    
    func setUpUI() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-kSafeArea_Bottom)
        }
    }
}



extension CODChannelManagerViewController:UITableViewDelegate,UITableViewDataSource{
    
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
            if model.title == UserManager.sharedInstance.nickname {
                cell?.enable = false
            }else{
                cell?.enable = true
            }
            
            cell?.onBlock = { [weak self] isOn -> () in
                self?.sendIQ(indexPath: indexPath , isOn: isOn)
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
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 47
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let textString = self.getHeaderString(section: section)
        let textFont = UIFont.systemFont(ofSize: 12)
        var sectionHeight: CGFloat = 0.01
        sectionHeight = self.getHeaderHeight(textString: textString, width: KScreenWidth - 30, textFont: textFont)
        let footerHeight = textString.getStringHeight(font: textFont, lineSpacing: 0, fixedWidth: KScreenWidth - 30)
        let textLabel = UILabel.init(frame: CGRect(x: 21, y: 21, width: KScreenWidth-30, height: footerHeight))
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionHeight = 20
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: CGFloat(sectionHeight)))
        bgView.backgroundColor = UIColor.clear
        
        return bgView
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 43
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    
    
}

extension CODChannelManagerViewController {
    
    func getHeaderString(section: Int) -> String {
        var sectionString = ""
        
        switch section {
        case 0:
            sectionString = "添加管理员"
        default:
            sectionString = ""
        }
        return sectionString
    }
    
    func getHeaderHeight(textString: String, width: CGFloat,textFont:UIFont) -> CGFloat {
       return 43
    }
    
    func sendIQ(indexPath:IndexPath,isOn:Bool) {

        if indexPath.section == 0 {
            let index = indexPath.row
            if index >= 0 {
                let model = memberArr[index]
                
                CODProgressHUD.showWithStatus(nil)
                self.operationDic[model.jid] = index
                XMPPManager.shareXMPPManager.setAdmins(roomId: self.groupChatId ?? 0, jid: model.jid, isOn: isOn, success: { (_, name) in
                    
                    CODProgressHUD.dismiss()
                    if COD_SetAdmins != name {
                        return
                    }
                    
//                    guard let index = self.operationDic[model.jid] else {
//                        return
//                    }
//
//                    self.updateSourceData(section: 0, row: index, result: isOn)
                    
                    
                }) { (_) in
                    
                    CODProgressHUD.dismiss()

                }
//                dict = self.dictionaryWithSetManager(jid: model.jid, isOn: isOn)
//                operationDic[model.jid] = index
//                let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: "\(nameSpace)\(CODMessageChatType.channel.stringValue)", actionDic: dict!)
//                XMPPManager.shareXMPPManager.xmppStream.send(iq)
            }
        }
        
        
    }
    
    func dictionaryWithSetManager(jid: String, isOn: Bool) -> NSDictionary? {
        let dict: NSMutableDictionary = ["name": COD_SetAdmins,
                                         "requester": UserManager.sharedInstance.jid,
                                         "roomID": self.groupChatId ?? 0,
                                         "adminTarget": jid,
                                         "isAdd": isOn] as NSMutableDictionary
        return dict as NSDictionary
    }
}

extension CODChannelManagerViewController: XMPPStreamDelegate {
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        
        CustomUtil.analyticxXML(iq: iq) {[weak self] (actionDic, infoDic) in
            guard let infoDic = infoDic else {
                return
            }
            guard let tempSelf = self else{
                print("******* self 为 空 *******")
                return
            }
            
            if (actionDic["name"] as? String == COD_SetAdmins){ //群管理员设置
                guard let adminTarget = actionDic["adminTarget"] as? String else {
                    return
                }
                guard let index = tempSelf.operationDic[adminTarget] else {
                    return
                }
                if !(infoDic["success"] as! Bool) {
                    tempSelf.updateSourceData(section: 0, row: index, result: false)
                    CODProgressHUD.showErrorWithStatus("设置失败")
                    return
                }
                
                if let result = actionDic["isAdd"] as? Bool{
                    tempSelf.updateSourceData(section: 0, row: index, result: result)
                }
            }
            
        }
        return true
    }
    
    func updateSourceData(section: Int, row: Int, result: Bool){
        guard let groupModel = CODChannelModel.getChannel(by: self.groupChatId) else {
            return
        }
        if section == 0 {
            let member = groupModel.member[row]
            try! Realm.init().write {
                if result {
                    member.userpower = 20
                } else {
                    member.userpower = 30
                }
            }
        }
        
        var cellModel = self.dataSource[section][row]
        cellModel.isOn = result
        self.dataSource[section][row] = cellModel
        self.tableView.reloadData()
    }
}
