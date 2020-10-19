//
//  CODChatResultVC.swift
//  COD
//
//  Created by 1 on 2019/4/17.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODChatResultVC: BaseViewController {
    
    enum searchType {
        case contactAndGroupAndMessage
        case onlyContact
        case contactAndGroup
    }
    
    var searchType: searchType = .contactAndGroupAndMessage
    
    
    var searchContactListArr :Array<CODContactModel> = Array() {
        didSet {
            resultArr[0] = self.searchContactListArr
        }
    }
    
    var searchGroupListArr :Array<CODGroupChatModel> = Array() {
        didSet {
            resultArr[1] = self.searchGroupListArr
        }
    }
    var searchLocalChannelList: Array<CODChannelModel> = Array() {
        didSet {
            resultArr[2] = self.searchLocalChannelList
        }
    }
    
    var resultContactAndGroupList: Array<AnyObject> = Array() {
        didSet {
            resultArr[3] = self.resultContactAndGroupList
        }
    }
    
    var searchChannelListArr :Array<CODSearchResultContact> = Array() {
        didSet {
            resultArr[4] = self.searchChannelListArr
        }
    }
    
    var resultMessageList: Array<CODSearchResultMessageModel> = Array() {
        didSet {
            resultArr[5] = self.resultMessageList
        }
    }
    
    //搜索结果总集合
    var resultArr: Array<Array<Any>> = [Array(),Array(),Array(),Array(),Array(),Array()]
    
    var selectContactModel:CODContactModel?
    
    weak var delegate: ContactSearchResultDelegate? = nil
    
    var isNoSearchResult = true {
        didSet {
            self.noSearchResultView.isHidden = isNoSearchResult
        }
    }
    
    
    lazy var tableView:UITableView = {
        let tabelV = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        tabelV.estimatedRowHeight = 80
        tabelV.rowHeight = UITableView.automaticDimension
        tabelV.separatorStyle = .none
        tabelV.backgroundColor = UIColor.clear
        tabelV.tableHeaderView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.01))
        tabelV.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.01))
        tabelV.delegate = self
        tabelV.dataSource = self
        
        ///注册单元格
        tabelV.register(CODChoosePersonCell.self, forCellReuseIdentifier: "CODChoosePersonCellID")
        tabelV.register(UINib.init(nibName: "ChatListCell", bundle: nil), forCellReuseIdentifier: "ChatListCell")
        return tabelV
    }()
    
    lazy var noSearchResultView: UIView = {
        let view = UIView()
        view.isHidden = false
        view.backgroundColor = UIColor.init(hexString: kVCBgColorS)
        let label = UILabel()
        label.text = NSLocalizedString("无结果", comment: "")
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = UIColor.init(hexString: kSubTitleColors)
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-150)
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.noSearchResultView)
        self.noSearchResultView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
//        self.tableView.frame = self.view.bounds
        self.edgesForExtendedLayout = .bottom
//        self.definesPresentationContext = true
        // Do any additional setup after loading the view
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension CODChatResultVC :UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.resultArr[indexPath.section].count > 0 {
            switch indexPath.section {
            case 0:
                self.selectContactModel = self.searchContactListArr[indexPath.row]
            case 3:
                if let model = self.resultContactAndGroupList[indexPath.row] as? CODContactModel {
                    self.selectContactModel = model
                }
            default:
                break
            }
        }
        
        if self.delegate != nil {
            self.delegate?.contactSearchView(searchCtl: self, CellSelected: indexPath)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        return
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.resultArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.resultArr[section].count > 0 {
            return 28
        }else{
            return 0.001
        }
        
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var textString = ""
        
        if self.resultArr[section].count > 0 {
            switch section {
            case 0:
                textString = "联系人"
            case 1:
                textString = "群组"
            case 2:
                textString = "频道"
            case 3:
                textString = "对话与联系人"
            case 4:
                textString = "全局搜索"
            case 5:
                textString = "消息 "  //后面的空格是特意加的
            default:
                textString = ""
            }
        }
        
        let textFont = UIFont.boldSystemFont(ofSize: 13.0)
        let textLabel = UILabel.init(frame: CGRect(x: 15, y: 0, width: KScreenWidth-50, height: 28))
        textLabel.textAlignment = NSTextAlignment.left
        textLabel.font = textFont
        textLabel.textColor = UIColor(hexString: kSubTitleColors8E8E92)
        textLabel.text = textString
        let lineView = UIView(frame: CGRect(x: 5, y: 27, width: kScreenWidth, height: 1))
        lineView.backgroundColor = UIColor(hexString: kVCBgColorS)

        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 28))
        view.backgroundColor = UIColor(hexString: kVCBgColorS)
        view.addSubviews([textLabel,lineView])
        return textString.count > 0 ? view : UIView()
        
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

}

extension CODChatResultVC :UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.searchResultDidScroll(scrollView: scrollView)
    }
}

extension CODChatResultVC :UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                
        return self.resultArr[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return self.getContactCell(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.resultArr[indexPath.section].count > 0 {
            switch indexPath.section {
            case 5:
                return 75.0
            default:
                return 47.0
            }
        }
        return 0.0
        
    }
    
    
}

extension CODChatResultVC{
    

    //联系人的cell
    func getContactCell(indexPath: IndexPath) -> UITableViewCell {
        
        let arr = self.resultArr[indexPath.section]
        switch indexPath.section {
        case 0:
            let cell: CODChoosePersonCell = tableView.dequeueReusableCell(withIdentifier: "CODChoosePersonCellID") as! CODChoosePersonCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.gray
            cell.isLast = indexPath.row == arr.count-1
            guard let model = arr[indexPath.row] as? CODContactModel else {
                return cell
            }
            self.setContactCell(cell: cell, model: model)
            return cell
        case 1:
            let cell: CODChoosePersonCell = tableView.dequeueReusableCell(withIdentifier: "CODChoosePersonCellID") as! CODChoosePersonCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.gray
            cell.isLast = indexPath.row == arr.count-1
            guard let model = arr[indexPath.row] as? CODGroupChatModel else {
                return cell
            }
            
            self.setGroupCell(cell: cell, model: model)
            return cell
        case 2:
            let cell: CODChoosePersonCell = tableView.dequeueReusableCell(withIdentifier: "CODChoosePersonCellID") as! CODChoosePersonCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.gray
            cell.isLast = indexPath.row == arr.count-1
            guard let model = arr[indexPath.row] as? CODChannelModel else {
                return cell
            }
            
            self.setChannelCell(cell: cell, model: model)
            return cell
        case 3:
            let cell: CODChoosePersonCell = tableView.dequeueReusableCell(withIdentifier: "CODChoosePersonCellID") as! CODChoosePersonCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.gray
            cell.isLast = indexPath.row == arr.count-1
            let model = arr[indexPath.row]
            if let model = model as? CODContactModel {
                self.setContactCell(cell: cell, model: model)
            }
            if let model = model as? CODGroupChatModel {
                self.setGroupCell(cell: cell, model: model)
            }
            if let model = model as? CODChannelModel {
                self.setChannelCell(cell: cell, model: model)
                
            }
            return cell
        case 4:
            let cell: CODChoosePersonCell = tableView.dequeueReusableCell(withIdentifier: "CODChoosePersonCellID") as! CODChoosePersonCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.gray
            cell.isLast = indexPath.row == arr.count-1
            guard let model = arr[indexPath.row] as? CODSearchResultContact else {
                return cell
            }
            if let _ = URL.init(string: model.pic.getHeaderImageFullPath(imageType: 0)) {
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.pic) { (image) in
                    cell.imgView.image = image
                }
            }
            let username = "@\(model.userid)"
            if model.type == "C" {
                let attriStr = NSAttributedString.init(string: " \(model.name)")
                let textAttachment = NSTextAttachment.init()
                let img = UIImage(named: "chat_list_channel")
                textAttachment.image = img
                textAttachment.bounds = CGRect.init(x: 0, y: 0, width: img?.size.width ?? 0, height: img?.size.height ?? 0)
                let attributedIconString = NSAttributedString.init(attachment: textAttachment)
                let attributedTitle = NSMutableAttributedString.init()
                attributedTitle.append(attributedIconString)
                attributedTitle.append(attriStr)
                cell.attributedTitle = attributedTitle
                cell.placeholer = "\(username)，\(model.count) 位订阅者"
            } else if model.type == "B" {
                cell.attributedTitle = CustomUtil.getBotAttriString(botName: model.name)
                cell.placeholer = username
            } else {
                cell.title = model.name
                cell.placeholer = username
            }
            
            return cell
        case 5:
            let cell : ChatListCell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
            cell.isLast = indexPath.row == self.resultMessageList.count-1
            guard let model = arr[indexPath.row] as? CODSearchResultMessageModel else {
                return cell
            }
            cell.resultMessageModel = model
            if model.title == "\(kApp_Name)小助手" {
                cell.imgView.image = UIImage.helpIcon()
            }else if model.title == "我的云盘" {
                cell.imgView.image = UIImage(named: "cloud_disk_icon")
            }else{
                let imgUrl = model.icon
                cell.imgName = imgUrl /*imgUrl.getHeaderImageFullPath(imageType: 0)*/
            }
            cell.title = model.title
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: "CODChoosePersonCellID") as! CODChoosePersonCell
        }
        
        
        
        
        
        
        
        
        
        
        
//        if self.searchType == .contactAndGroupAndMessage {
//            if indexPath.section == 0 {
//                if self.resultContactAndGroupList.count > 0 {
//                    let cell: CODChoosePersonCell = tableView.dequeueReusableCell(withIdentifier: "CODChoosePersonCellID") as! CODChoosePersonCell
//                    cell.selectionStyle = UITableViewCell.SelectionStyle.gray
//                    cell.isLast = indexPath.row == self.resultContactAndGroupList.count-1
//                    let model = self.resultContactAndGroupList[indexPath.row]
//                    if let model = model as? CODContactModel {
//
//                        if model.rosterID <= 0 {
//                            if model.rosterID == CloudDiskRosterID  {
//                                cell.imgView.image = UIImage(named: "cloud_disk_icon")
//                            }else if model.rosterID == RobotRosterID{
//                                cell.imgView.image = UIImage.helpIcon()
//                            }else if model.rosterID == NewFriendRosterID {
//                                cell.imgView.image = UIImage(named: "chat_new_friend_icon")
//                            }
//
//                        }else{
//                            var imgUrl = model.icon
//
//                            if imgUrl == "" {
//                                imgUrl =  model.icon
//                            }
//
//                            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: imgUrl) { (image) in
//                                cell.imgView.image = image
//                            }
//                        }
//                        if model.rosterID == NewFriendRosterID {
//                            cell.title = "新的朋友"
//                        }else{
//                            cell.title = model.title
//                        }
//
//                        cell.placeholer = ""
//                    }
//                    if let model = model as? CODGroupChatModel {
//                        if let _ = URL.init(string: model.grouppic.getHeaderImageFullPath(imageType: 0)) {
//                            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.grouppic) { (image) in
//                                cell.imgView.image = image
//                            }
//                        }
//                        let imgText = NSTextAttachment()
//                        let img = UIImage(named: "group_chat_logo_img")!
//                        imgText.image = img
//                        imgText.bounds = CGRect(x: 0.0, y: -2.0, width: img.size.width, height: img.size.height)
//                        let imgAttri = NSAttributedString(attachment: imgText)
//                        cell.attributedTitle =  imgAttri + " " + NSAttributedString(string: model.getGroupName())
//                        cell.placeholer = String(format: NSLocalizedString("%d 位成员", comment: ""), model.member.count)
//                    }
//                    if let model = model as? CODChannelModel {
//                        if let _ = URL.init(string: model.grouppic.getHeaderImageFullPath(imageType: 0)) {
//                            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.grouppic) { (image) in
//                                cell.imgView.image = image
//                            }
//                        }
//                        let imgText = NSTextAttachment()
//                        let img = UIImage(named: "chat_list_channel")!
//                        imgText.image = img
//                        imgText.bounds = CGRect(x: 0.0, y: -2.0, width: img.size.width, height: img.size.height)
//                        let imgAttri = NSAttributedString(attachment: imgText)
//                        cell.attributedTitle =  imgAttri + " " + NSAttributedString(string: model.getGroupName())
//                        cell.placeholer = String(format: NSLocalizedString("%d 位订阅者", comment: ""), model.member.count)
//                    }
//                    return cell
//                }else if self.searchChannelListArr.count > 0{
//                    let cell: CODChoosePersonCell = tableView.dequeueReusableCell(withIdentifier: "CODChoosePersonCellID") as! CODChoosePersonCell
//                    cell.selectionStyle = UITableViewCell.SelectionStyle.gray
//                    cell.isLast = indexPath.row == self.searchChannelListArr.count-1
//                    let model = self.searchChannelListArr[indexPath.row]
//                    if let _ = URL.init(string: model.pic.getHeaderImageFullPath(imageType: 0)) {
//                        CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.pic) { (image) in
//                            cell.imgView.image = image
//                        }
//                    }
//                    let username = "@\(model.userid)"
//                    if model.type == "C" {
//                        let attriStr = NSAttributedString.init(string: " \(model.name)")
//                        let textAttachment = NSTextAttachment.init()
//                        let img = UIImage(named: "chat_list_channel")
//                        textAttachment.image = img
//                        textAttachment.bounds = CGRect.init(x: 0, y: 0, width: img?.size.width ?? 0, height: img?.size.height ?? 0)
//                        let attributedIconString = NSAttributedString.init(attachment: textAttachment)
//                        let attributedTitle = NSMutableAttributedString.init()
//                        attributedTitle.append(attributedIconString)
//                        attributedTitle.append(attriStr)
//                        cell.attributedTitle = attributedTitle
//                        cell.placeholer = "\(username)，\(model.count) 位订阅者"
//                    } else if model.type == "B" {
//                        cell.attributedTitle = CustomUtil.getBotAttriString(botName: model.name)
//                        cell.placeholer = username
//                    } else {
//                        cell.title = model.name
//                        cell.placeholer = username
//                    }
//
//                    return cell
//                }else{
//                    let model = self.resultMessageList[indexPath.row]
//                    let cell : ChatListCell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
//                    cell.isLast = indexPath.row == self.resultMessageList.count-1
//                    cell.resultMessageModel = model
//                    if model.title == "\(kApp_Name)小助手" {
//                        cell.imgView.image = UIImage.helpIcon()
//                    }else if model.title == "我的云盘" {
//                        cell.imgView.image = UIImage(named: "cloud_disk_icon")
//                    }else{
//                        let imgUrl = model.icon
//                        cell.imgName = imgUrl /*imgUrl.getHeaderImageFullPath(imageType: 0)*/
//                    }
//                    cell.title = model.title
//                    return cell
//                }
//
//            }else{
//                //
//                let model = self.resultMessageList[indexPath.row]
//                let cell : ChatListCell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
//                cell.isLast = indexPath.row == self.resultMessageList.count-1
//                cell.resultMessageModel = model
//                if model.title == "\(kApp_Name)小助手" {
//                    cell.imgView.image = UIImage.helpIcon()
//                }else if model.title == "我的云盘" {
//                    cell.imgView.image = UIImage(named: "cloud_disk_icon")
//                }else{
//                    let imgUrl = model.icon
//                    cell.imgName = imgUrl /*imgUrl.getHeaderImageFullPath(imageType: 0)*/
//                }
//                cell.title = model.title
//                return cell
//            }
//        }else if self.searchType == .contactAndGroup {
//            let cell: CODChoosePersonCell = tableView.dequeueReusableCell(withIdentifier: "CODChoosePersonCellID") as! CODChoosePersonCell
//            cell.selectionStyle = UITableViewCell.SelectionStyle.gray
//            if indexPath.section == 0 {
//                if self.searchContactListArr.count > 0 {
//                    let model = self.searchContactListArr[indexPath.row]
//                    cell.isLast = indexPath.row == self.searchContactListArr.count-1
//                    self.setContactCell(cell: cell, model: model)
//                    return cell
//                }else{
//                    if self.searchGroupListArr.count > 0 {
//                        let model = self.searchGroupListArr[indexPath.row]
//                        cell.isLast = indexPath.row == self.searchGroupListArr.count-1
//                        self.setGroupCell(cell: cell, model: model)
//                        return cell
//                    }else{
//                        let model = self.searchLocalChannelList[indexPath.row]
//                        cell.isLast = indexPath.row == self.searchLocalChannelList.count-1
//                        self.setChannelCell(cell: cell, model: model)
//                        return cell
//                    }
//                }
//            }else if indexPath.section == 1 {
//                if self.searchContactListArr.count > 0 {
//                    if searchGroupListArr.count > 0 {
//                        let model = self.searchGroupListArr[indexPath.row]
//                        cell.isLast = indexPath.row == self.searchGroupListArr.count-1
//                        self.setGroupCell(cell: cell, model: model)
//                        return cell
//                    }else{
//                        let model = self.searchLocalChannelList[indexPath.row]
//                        cell.isLast = indexPath.row == self.searchLocalChannelList.count-1
//                        self.setChannelCell(cell: cell, model: model)
//                        return cell
//                    }
//
//                }else if self.searchGroupListArr.count > 0 {
//                    let model = self.searchLocalChannelList[indexPath.row]
//                    cell.isLast = indexPath.row == self.searchLocalChannelList.count-1
//                    self.setChannelCell(cell: cell, model: model)
//                    return cell
//                }else {
//                    return cell
//                }
//            }else{
//                let model = self.searchLocalChannelList[indexPath.row]
//                cell.isLast = indexPath.row == self.searchLocalChannelList.count-1
//                self.setChannelCell(cell: cell, model: model)
//                return cell
//            }
//
//        }else{
//            let cell: CODChoosePersonCell = tableView.dequeueReusableCell(withIdentifier: "CODChoosePersonCellID") as! CODChoosePersonCell
//            cell.selectionStyle = UITableViewCell.SelectionStyle.gray
//            cell.isLast = indexPath.row == self.searchContactListArr.count-1
//            let model = self.searchContactListArr[indexPath.row]
//            if (model.name == "\(kApp_Name)小助手") {
//                //网络图片需要处理一下
//                cell.iconImage = UIImage.helpIcon()
//            }else if model.name == "我的云盘" {
//                cell.iconImage = UIImage(named: "cloud_disk_icon")
//            }else{
//                if let _ = URL.init(string: model.userpic.getHeaderImageFullPath(imageType: 0)) {
//                    CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.userpic) { (image) in
//                        cell.imgView.image = image
//                    }
//                }
//            }
//            cell.title = model.getContactNick()
//            cell.placeholer = ""
//            return cell
//        }
    }
    
}

extension CODChatResultVC{
    func setContactCell(cell: CODChoosePersonCell, model: CODContactModel) {
        if model.rosterID <= 0 {
            if model.rosterID == CloudDiskRosterID  {
                cell.imgView.image = UIImage(named: "cloud_disk_icon")
            }else if model.rosterID == RobotRosterID{
                cell.imgView.image = UIImage.helpIcon()
            }else if model.rosterID == NewFriendRosterID {
                cell.imgView.image = UIImage(named: "chat_new_friend_icon")
            }
            
        }else{
            var imgUrl = model.icon
            
            if imgUrl == "" {
                imgUrl =  model.icon
            }
            
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: imgUrl) { (image) in
                cell.imgView.image = image
            }
        }
        if model.rosterID == NewFriendRosterID {
            cell.title = "新的朋友"
        }else{
            cell.title = model.title
        }

        cell.placeholer = ""
    }
    
    func setGroupCell(cell: CODChoosePersonCell, model: CODGroupChatModel) {
        if let _ = URL.init(string: model.grouppic.getHeaderImageFullPath(imageType: 0)) {
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.grouppic) { (image) in
                cell.imgView.image = image
            }
        }
        let imgText = NSTextAttachment()
        let img = UIImage(named: "group_chat_logo_img")!
        imgText.image = img
        imgText.bounds = CGRect(x: 0.0, y: -2.0, width: img.size.width, height: img.size.height)
        let imgAttri = NSAttributedString(attachment: imgText)
        cell.attributedTitle =  imgAttri + " " + NSAttributedString(string: model.getGroupName())
        cell.placeholer = String(format: NSLocalizedString("%d 位成员", comment: ""), model.member.count)
    }
    
    func setChannelCell(cell: CODChoosePersonCell, model: CODChannelModel) {
//        if let _ = URL.init(string: model.grouppic.getHeaderImageFullPath(imageType: 0)) {
//            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.grouppic) { (image) in
//                cell.imgView.image = image
//            }
//        }
//        cell.title = model.getGroupName()
//        cell.placeholer = "\(model.member.count) 位订阅者"
        
        if let _ = URL.init(string: model.grouppic.getHeaderImageFullPath(imageType: 0)) {
            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: model.grouppic) { (image) in
                cell.imgView.image = image
            }
        }
        let imgText = NSTextAttachment()
        let img = UIImage(named: "chat_list_channel")!
        imgText.image = img
        imgText.bounds = CGRect(x: 0.0, y: -2.0, width: img.size.width, height: img.size.height)
        let imgAttri = NSAttributedString(attachment: imgText)
        cell.attributedTitle =  imgAttri + " " + NSAttributedString(string: model.getGroupName())
        cell.placeholer = String(format: NSLocalizedString("%d 位订阅者", comment: ""), model.member.count)
    }
    
}

protocol ContactSearchResultDelegate: NSObjectProtocol {
    func contactSearchView(searchCtl: CODChatResultVC, CellSelected indexPath: IndexPath)
    
    func searchResultDidScroll(scrollView: UIScrollView)
}


