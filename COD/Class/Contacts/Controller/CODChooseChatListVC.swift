//
//  CODChooseChatListVC.swift
//  COD
//
//  Created by XinHoo on 2019/7/16.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Lottie

class CODChooseChatListVC: BaseViewController {
    
    typealias ChoosePersonCompeleteBlock = (_ model:CODContactModel) -> Void ///选择联系人
    typealias ChooseGroupCompeleteBlock = (_ model:CODGroupChatModel) -> Void ///选择群
    typealias ChooseChannelCompeleteBlock = (_ model:CODChannelModel) -> Void ///选择频道
    typealias ChooseChatListCompeleteBlock = (_ model:CODChatListModel) -> Void ///选择聊天列表
    
    var fromJID = ""  //删除当前页面传过来的jid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackButton()
        self.navigationItem.title = NSLocalizedString("选择一项聊天", comment: "")
        self.definesPresentationContext = true
        
        self.setUpUI()
        self.getData()
    }
    let searchCtl = UISearchController(searchResultsController: nil)
    
    public var choosePersonBlock:ChoosePersonCompeleteBlock?
    public var chooseGroupBlock:ChooseGroupCompeleteBlock?
    public var chooseChatListBlock:ChooseChatListCompeleteBlock?
    public var chooseChannelBlock:ChooseChannelCompeleteBlock?
    
    var contactIntSort :Array = [Int]()
    
    var contactListDic :Dictionary = [Int: AnyObject]()
    
    var contactListArr :Array = [AnyObject]()
    
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
}

extension CODChooseChatListVC{
    
    func getData() {
      
        let listModels = CODChatListRealmTool.getChatList()
        if listModels.count > 0 {
            for listModel in listModels {
                if let group = listModel.groupChat {
                    if group.isValid {
                        guard group.isCanSpeak() else {
                            continue
                        }
                        self.contactListDic[listModel.id] = listModel
                        contactIntSort.append(listModel.id)
                    }
                }
                if let contact = listModel.contact {
                    if contact.isValid {
                        if contact.rosterID == NewFriendRosterID {
                            continue
                        }
                        self.contactListDic[listModel.id] = listModel
                        contactIntSort.append(listModel.id)
                    }
                }
                if let channel = listModel.channelChat {
                    if channel.isValid {
                        guard channel.isAdmin(by: UserManager.sharedInstance.jid) else {
                            continue
                        }
                        self.contactListDic[listModel.id] = listModel
                        contactIntSort.append(listModel.id)
                        
                    }
                }
            }
        }
        
        if let contactList = CODContactRealmTool.getContacts() {
            guard contactList.count > 0 else {
                return
            }
            
            for contact in contactList {
                if contact.rosterID == NewFriendRosterID {
                    continue
                }
                if contact.jid.contains(XMPPManager.shareXMPPManager.currentChatFriend) {
                    continue
                }
                if contact.jid.contains(fromJID) {
                    continue
                }
                
                self.contactListDic[contact.rosterID] = contact
                contactIntSort.append(contact.rosterID)
            }

            
        }
        
        let groupList = CODGroupChatRealmTool.getAllValidGroupChatList()
        
        if groupList.count > 0 {
            for group in groupList {
                guard group.roomID != 0, group.isCanSpeak() else {
                    continue
                }
                
                self.contactListDic[group.roomID] = group
                contactIntSort.append(group.roomID)
            }
        }
        
        let channelList = CODChannelModel.getAllValidGroupChatList()
        if channelList.count > 0 {
            for channel in channelList {
                guard channel.roomID != 0, channel.isAdmin(by: UserManager.sharedInstance.jid) else {
                    continue
                }
                
                self.contactListDic[channel.roomID] = channel
                contactIntSort.append(channel.roomID)
            }
        }
        
        // 我的云盘前置
        contactIntSort.removeAll(CloudDiskRosterID)
        contactIntSort.insert(CloudDiskRosterID, at: 0)
        
        for id in contactIntSort {
            guard let contact = self.contactListDic[id] else {
                continue
            }
            self.contactListArr.append(contact)
            self.contactListDic.removeValue(forKey: id)
        }
        
        
        
    }
    
    func setUpUI() {
        
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 56))
        bgView.addSubview(searchCtl.searchBar)
        searchCtl.searchBar.placeholder = "搜索好友"
//        self.tableView.tableHeaderView = bgView
        //取掉上下两条黑线
        searchCtl.searchBar.backgroundImage = UIImage()
        
        let searchBarTF = searchCtl.searchBar.customTextField
        searchBarTF?.font = UIFont.systemFont(ofSize: 17)
        searchBarTF?.backgroundColor = UIColor(hexString: kSearchBarTextFieldBackGdColorS)
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-kSafeArea_Bottom)
        }
    }
}

extension CODChooseChatListVC: UITableViewDelegate,UITableViewDataSource, EmptyDataSetSource{
    
    func registerCellClassForTableView(tableView:UITableView) {
        tableView.register(CODChoosePersonCell.self, forCellReuseIdentifier: "CODChoosePersonCellID")
    }
    
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.contactListArr.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell: CODChoosePersonCell = tableView.dequeueReusableCell(withIdentifier: "CODChoosePersonCellID", for: indexPath) as! CODChoosePersonCell
        
        cell.iconImage = UIImage.init(named: "default_header_110")
        cell.placeholer = ""
        cell.cellIndexPath = indexPath
        if let model :CODContactModel = self.contactListArr[indexPath.row] as? CODContactModel {
            cell.title = model.getContactNick()
            if model.rosterID > 0 {
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.userpic) { (image) in
                    cell.imgView.image = image
                }
            }else{
                cell.imgView.image = UIImage(named: model.userpic)
            }
            
        }
        
        if let model :CODGroupChatModel = self.contactListArr[indexPath.row] as? CODGroupChatModel {
            let imgText = NSTextAttachment()
            let img = UIImage(named: "group_chat_logo_img")!
            imgText.image = img
            imgText.bounds = CGRect(x: 0.0, y: -2.0, width: img.size.width, height: img.size.height)
            let imgAttri = NSAttributedString(attachment: imgText)
            cell.attributedTitle =  imgAttri + " " + NSAttributedString(string: model.getGroupName())
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.grouppic) { (image) in
                cell.imgView.image = image
            }
        }
        
        if let model :CODChannelModel = self.contactListArr[indexPath.row] as? CODChannelModel {
            let imgText = NSTextAttachment()
            let img = UIImage(named: "chat_list_channel")!
            imgText.image = img
            imgText.bounds = CGRect(x: 0.0, y: -2.0, width: img.size.width, height: img.size.height)
            let imgAttri = NSAttributedString(attachment: imgText)
            cell.attributedTitle =  imgAttri + " " + NSAttributedString(string: model.getGroupName())
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.grouppic) { (image) in
                cell.imgView.image = image
            }
        }
        
        if let model :CODChatListModel = self.contactListArr[indexPath.row] as? CODChatListModel {
            cell.title = model.title
            cell.cellIndexPath = indexPath
            if model.id > 0 {
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.icon) { (image) in
                    cell.imgView.image = image
                }
            }else{
                switch model.chatTypeEnum {
                case .privateChat:
                    cell.imgView.image = UIImage(named: model.contact?.userpic ?? "")
                    if model.id == NewFriendRosterID {
                        cell.title = "新的朋友"
                    }
                case .groupChat:
                    cell.imgView.image = UIImage(named: model.groupChat?.grouppic ?? "")
                default:
                    cell.imgView.image = UIImage(named: model.channelChat?.grouppic ?? "")
                }
            }
        }
        
        if indexPath.row == self.contactListArr.count - 1 {
            cell.isLast = true
        }else{
            cell.isLast = false
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let model :CODContactModel = self.contactListArr[indexPath.row] as? CODContactModel {
            if self.choosePersonBlock != nil {
                self.choosePersonBlock!(model)
                self.navigationController?.popViewController()
            }
        }
        if let model :CODGroupChatModel = self.contactListArr[indexPath.row] as? CODGroupChatModel {
            if self.chooseGroupBlock != nil {
                self.chooseGroupBlock!(model)
                self.navigationController?.popViewController()
            }
        }
        if let model :CODChannelModel = self.contactListArr[indexPath.row] as? CODChannelModel {
            if self.chooseChannelBlock != nil {
                self.chooseChannelBlock!(model)
                self.navigationController?.popViewController()
            }
        }
        if let model :CODChatListModel = self.contactListArr[indexPath.row] as? CODChatListModel {
            if self.chooseChatListBlock != nil {
                self.chooseChatListBlock!(model)
                self.navigationController?.popViewController()
            }
        }
    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 150, height: 100))
        
        let lottieView = AnimationView.init()
        let animation = Animation.filepath(Bundle.main.path(forResource: "404", ofType: "json")!, animationCache: nil)
        lottieView.animation = animation
        lottieView.loopMode = .loop
        lottieView.play()
        view.addSubview(lottieView)
        lottieView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 55, height: 65))
            make.centerX.equalToSuperview()
        }
        
        let lab = UILabel.init(frame: .zero)
        lab.text = CustomUtil.formatterStringWithAppName(str:"您暂时还没有加入%@的朋友\n推荐朋友下载一起畅聊吧")
        lab.numberOfLines = 0
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textAlignment = .center
        lab.textColor = UIColor.init(hexString: kWeakTitleColorS)
        view.addSubview(lab)
        lab.snp.makeConstraints { (make) in
            make.top.equalTo(lottieView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        return view
    }
    
}

