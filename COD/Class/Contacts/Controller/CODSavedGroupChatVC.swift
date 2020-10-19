//
//  CODSavedGroupChatVC.swift
//  COD
//
//  Created by 1 on 2019/3/15.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

enum CtlType {
    case saveGroupType
    case togetherGroup
    case saveChannelType
}

class CODSavedGroupChatVC: BaseViewController {
    
    var dataSource: Array<CODGroupChatModel> = []
    var dataSource2: Array<CODChannelModel> = []
    
    var type: CtlType = .saveGroupType
    
    var jid: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch type {
        case .saveGroupType:
            self.navigationItem.title = NSLocalizedString("已加入的群组", comment: "")
        case .togetherGroup:
            self.navigationItem.title = NSLocalizedString("共同加入的群组", comment: "")
        default:
            self.navigationItem.title = NSLocalizedString("已加入的频道", comment: "")
        }
        
        self.setBackButton()
        self.view.backgroundColor = UIColor.white
        
        self.setUpUI()
        self.getData()
        
    }
    
    func getData() {
        
        switch type {
        case .saveGroupType:
            let groupArr = CODGroupChatRealmTool.getAllValidGroupChatList().sorted { (groupModel1, groupModel2) -> Bool in
                let chatlist1 = CODChatListRealmTool.getChatList(id: groupModel1.roomID)
                let chatlist2 = CODChatListRealmTool.getChatList(id: groupModel2.roomID)
                
                return chatlist1?.lastDateTime.int ?? 0 > chatlist2?.lastDateTime.int ?? 0
            }
            guard groupArr.count > 0 else {
                return
            }
            for groupModel in groupArr {
                dataSource.append(groupModel)
            }
        case .togetherGroup:
            if let memberArr = CODGroupMemberRealmTool.getMembersByJid(jid){
                guard memberArr.count > 0 else {
                    return
                }
                var withLastDateArr = [CODChatListModel]()
                var withoutLastDateArr = [CODGroupChatModel]()
                for member in memberArr {
                    let roomId = member.memberId.subStringTo(string: "c")
                    if let groupModel = CODGroupChatRealmTool.getGroupChat(id: roomId.int!) {
                        if groupModel.isValid == true {
                            let chatlistArr = groupModel.master
                            if chatlistArr.count > 0 {
                                withLastDateArr.append(chatlistArr.first!)
                            }else {
                                withoutLastDateArr.append(groupModel)
                            }
                            
                        }
                    }
                }
                withLastDateArr = withLastDateArr.sorted(by: { (chatListModel1, chatListModel2) -> Bool in
                    
                    let datetime1 = chatListModel1.chatHistory?.messages.last?.datetimeInt ?? 0
                    let datetime2 = chatListModel2.chatHistory?.messages.last?.datetimeInt ?? 0
                    return datetime1 > datetime2
                    
                })
                for listModel in withLastDateArr {
                    dataSource.append(listModel.groupChat!)
                }
                dataSource.append(contentsOf: withoutLastDateArr)
            }
        default:
            let realm = try! Realm.init()
            let channelArr = realm.objects(CODChannelModel.self).filter("isValid == \(true)").sorted { (groupModel1, groupModel2) -> Bool in
                let chatlist1 = CODChatListRealmTool.getChatList(id: groupModel1.roomID)
                let chatlist2 = CODChatListRealmTool.getChatList(id: groupModel2.roomID)
                
                return chatlist1?.lastDateTime.int ?? 0 > chatlist2?.lastDateTime.int ?? 0
            }
//            let channelArr = realm.objects(CODChannelModel.self).filter("savecontacts == \(true) &&  isValid == \(true)")
            
            guard channelArr.count > 0 else {
                return
            }
            for channelModel in channelArr {
                dataSource2.append(channelModel)
            }
        }
                
        tableView.reloadData()
    }
    
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
        tabelV.emptyDataSetSource = self
        ///注册单元格
        self.registerCellClassForTableView(tableView: tabelV)
        return tabelV
    }()
    
    
}

extension CODSavedGroupChatVC{
    
    func setUpUI() {
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-kSafeArea_Bottom)
        }
    }
    
    func createFooterView() -> UIView? {
        
//        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 82))
//        bgView.backgroundColor = UIColor.clear
//
        
        var textString = String.init()
        if type == .saveChannelType {
            if self.dataSource2.count <= 0 {
                return nil
            }
            textString = String.init(format: NSLocalizedString("%ld个频道", comment: ""), dataSource2.count)
        }else{
            if self.dataSource.count <= 0 {
                return nil
            }
            textString = String.init(format: NSLocalizedString("%ld个群组", comment: ""), dataSource.count)
        }
        let textFont = UIFont.systemFont(ofSize: 12)
        let textLabel = UILabel.init(frame: CGRect(x: 47, y: 24, width: KScreenWidth/2, height: 12))
        textLabel.textAlignment = NSTextAlignment.center
        textLabel.font = textFont
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor(red: 0.53, green: 0.53, blue: 0.53,alpha:1)
        textLabel.text = textString
        
        let linev = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.5))
        linev.backgroundColor = UIColor(hexString: kDividingLineColorS)
        textLabel.addSubview(linev)
        return textLabel
    }
}

extension CODSavedGroupChatVC:UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chatCellSelected(indexPath)
    }
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODSavedGroupChatCell.self, forCellReuseIdentifier: "CODSavedGroupChatCellID")
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return type == .saveChannelType ? dataSource2.count : dataSource.count
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell: CODSavedGroupChatCell = tableView.dequeueReusableCell(withIdentifier: "CODSavedGroupChatCellID", for: indexPath) as! CODSavedGroupChatCell
        if type == .saveChannelType {
            if indexPath.row == self.dataSource2.count - 1 {
                cell.isLast = true
            }else{
                cell.isLast = false
            }
            let model = self.dataSource2[indexPath.row]
            cell.title = model.getGroupName()
            cell.headerImgId = model.grouppic
        }else{
            if indexPath.row == self.dataSource.count - 1 {
                cell.isLast = true
            }else{
                cell.isLast = false
            }
            let model = self.dataSource[indexPath.row]
            cell.title = model.getGroupName()
            cell.headerImgId = model.grouppic
        }
        return cell
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return self.createFooterView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 41
    }
    
}

extension CODSavedGroupChatVC {
    func chatCellSelected(_ indexPath: IndexPath) {
        let msgCtl = MessageViewController()
        
        if type == .saveChannelType {
            let channelModel: CODChannelModel = dataSource2[indexPath.row]
            msgCtl.chatType = .channel
            msgCtl.roomId = String(format: "%d", (channelModel.roomID) )
            
            if channelModel.member.count > 0{
                if channelModel.descriptions.count > 0 {
                    let groupName = channelModel.descriptions
                    if groupName.count > 0 {
                        msgCtl.title = groupName.subStringToIndexAppendEllipsis(10)
                    }else{
                        msgCtl.title = NSLocalizedString("频道", comment: "")
                    }
                }else{
                    msgCtl.title = NSLocalizedString("频道", comment: "")
                }
                msgCtl.toJID = String(channelModel.jid)
                msgCtl.chatId = channelModel.roomID
            }else{
                msgCtl.title = channelModel.getGroupName()
                msgCtl.toJID = ""
                msgCtl.chatId = channelModel.roomID
            }
            msgCtl.isMute = channelModel.mute
            
        }else{
            let groupChat: CODGroupChatModel = dataSource[indexPath.row]
            msgCtl.chatType = .groupChat
            msgCtl.roomId = String(format: "%d", (groupChat.roomID) )
            
            if groupChat.member.count > 0{
                if groupChat.descriptions.count > 0 {
                    let groupName = groupChat.descriptions
                    if groupName.count > 0 {
                        msgCtl.title = groupName.subStringToIndexAppendEllipsis(10)
                    }else{
                        msgCtl.title = NSLocalizedString("群组", comment: "")
                    }
                }else{
                    msgCtl.title = NSLocalizedString("群组", comment: "")
                }
                msgCtl.toJID = String(groupChat.jid)
                msgCtl.chatId = groupChat.roomID
            }else{
                msgCtl.title = groupChat.getGroupName()
                msgCtl.toJID = ""
                msgCtl.chatId = groupChat.roomID
            }
            msgCtl.isMute = groupChat.mute
            
        }
        
        
        self.navigationController?.setViewControllers([(self.navigationController?.viewControllers.first)!, msgCtl], animated: true)
    }
    
}

extension CODSavedGroupChatVC: EmptyDataSetSource {
    
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        
        var titleStr = ""
        if self.type == .saveGroupType {
            titleStr = "您还没有创建或加入过群聊"
        }else if self.type == .saveChannelType{
            titleStr = "您还没有创建或加入过频道"
        }else{
            return nil
        }
        
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 160))
        let image = UIImage(named: "group_list_none")
        let imageView = UIImageView.init(image: image)
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(5.0)
            make.width.equalTo(image?.size.width ?? 0.0)
            make.height.equalTo(image?.size.height ?? 0.0)
            make.centerX.equalToSuperview()
        }
        
        let lab = UILabel(text: NSLocalizedString(titleStr, comment: ""))
        lab.textAlignment = .center
        lab.font = UIFont.systemFont(ofSize: 15.0)
        lab.textColor = UIColor(hexString: kSubTitleColors)
        view.addSubview(lab)
        
        lab.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(14.0)
            make.centerX.equalToSuperview()
        }
        
        return view
    }
}


