//
//  ChatViewController+SearchBarDelegate.swift
//  COD
//
//  Created by 1 on 2019/4/17.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

extension ChatViewController :UISearchControllerDelegate,UISearchResultsUpdating{
    
    //数据需要更新
    func updateSearchResults(for searchController: UISearchController) {
//        guard let resultVC = searchController.searchResultsController as? CODChatResultVC else {
//            return
//        }
//        let searchStr = searchController.searchBar.text ?? ""
//        var searchStrNoAt: String? = nil
//        if searchStr.starts(with: "@") {
//            searchStrNoAt = searchStr.removingPrefix("@")
//        }
//
//        resultVC.resultContactAndGroupList.removeAll()
//        resultVC.searchChannelListArr.removeAll()
//        resultVC.resultMessageList.removeAll()
//        resultVC.tableView.reloadData()
//
//        //联系人模糊查询
//        var contactAndGroupArr = Array<AnyObject>()
//
//        if let searchResults = CODContactRealmTool.getContactByKeyword(word: ((searchStrNoAt != nil) ? searchStrNoAt : searchStr)!, isContrainsTempFriends: true){
//            if searchResults.count > 0 {
//                for contact in searchResults {
//                    contactAndGroupArr.append(contact)
//                }
//            }
//        }
//
//        //群组模糊查询
//        if let searchGroupResults = CODGroupChatRealmTool.getGroupChatByKeyword(word: ((searchStrNoAt != nil) ? searchStrNoAt : searchStr)!) {
//            for group in searchGroupResults {
//                contactAndGroupArr.append(group)
//            }
//        }
//
//        //频道模糊查询
//        let searchChannelResutls = try! Realm.init().objects(CODChannelModel.self).filter({ (channelModel) -> Bool in
//            return channelModel.getGroupName().contains(((searchStrNoAt != nil) ? searchStrNoAt : searchStr)!, caseSensitive: false) && channelModel.isValid
//        }).sorted(by: { (channelModel1, channelModel2) -> Bool in
//            return channelModel1.lastChatTime > channelModel2.lastChatTime
//        })
//        contactAndGroupArr.append(contentsOf: searchChannelResutls)
//        resultVC.resultContactAndGroupList = contactAndGroupArr
//
//        //消息模糊查询
//        if self.type != .selectPerson {
//            let beginDate = Date()
//            if let messageResults = CODMessageRealmTool.searchMsgs(with: searchStr) {
//                print(messageResults.count)
//                let diff = beginDate.timeIntervalSinceNow
//                print("数据库查询耗时：\(diff)")
//                for message in messageResults {
//                    let model = CODSearchResultMessageModel()
//                    if let history = message.master.first {
//                        model.id = history.id
//
//                        if let chatList = CODChatListRealmTool.getChatList(id: history.id) {
//                            model.chatType = chatList.chatTypeEnum
//                            model.jid = chatList.jid
//                            model.title = chatList.title
//                            model.subTitle = chatList.subTitle
//                            model.icon = chatList.icon
//                            model.lastDateTime = message.datetime
//                            model.contact = chatList.contact
//                            model.groupChat = chatList.groupChat
//                            model.channelChat = chatList.channelChat
//                            model.message = message
//                        }
//                        resultVC.resultMessageList.append(model)
//                    }
//                }
//
//            }
//
//            let diff = beginDate.timeIntervalSinceNow
//
//            print("数据组装耗时：\(diff)")
//        }
//
//        resultVC.tableView.reloadData()
//
//        // 全局搜索
//        if searchStr.starts(with: "@") {
//
//            if searchStr.count > 5 {
//                self.requestGlobalSearch(searchStr: searchStrNoAt, resultVC: resultVC)
//
//            }
//        }
//
//        if resultVC.resultMessageList.count <= 0 &&
//            resultVC.resultContactAndGroupList.count <= 0 &&
//            resultVC.searchChannelListArr.count <= 0 {
//
//            resultVC.isNoSearchResult = false
//        } else {
//            resultVC.isNoSearchResult = true
//        }
        
    }
    
    
    func requestGlobalSearch(picCode: String? = nil, searchStr: String?, resultVC: CODChatResultVC) {
        XMPPManager.shareXMPPManager.globalSearch(search: searchStr!, picCode: picCode, success: { [weak self] (model, nameStr) in
            
            if nameStr == COD_globalSearch {
                
                guard model.success == true else {
                    switch model.code {
                    case 0:
                        self?.codeAlertView.vDismiss()
                    case 10091:
                        self?.codeAlertView.errorStr = "*验证码已失效，请重试"
                    case 10090:
                        self?.codeAlertView.errorStr = "*输入错误，请重试"
                    case 10093:
                        self?.codeAlertView.vShow()
                    case 40001:
                        CODProgressHUD.showWarningWithStatus("搜索已达上限")
                    default:
                        break
                    }
                    if resultVC.resultMessageList.count <= 0 &&
                        resultVC.resultContactAndGroupList.count <= 0 &&
                        resultVC.searchChannelListArr.count <= 0 {
                        
                        resultVC.isNoSearchResult = false
                    } else {
                        resultVC.isNoSearchResult = true
                    }
                    return
                }
                
                self?.codeAlertView.vDismiss()
                
                let objectArr = JSON(model.data as Any).arrayObject
                if objectArr?.count ?? 0 <= 0 {
                    return
                }
                
                var objArrTemp: Array<CODSearchResultContact> = []
                for dic in objectArr! {
                    guard let dicTemp = JSON(dic).dictionaryObject else {
                        continue
                    }
                    if let contactModel = CODSearchResultContact.deserialize(from: dicTemp) {
                        CODDownLoadManager.sharedInstance.updateAvatar(userPicID: contactModel.pic, complete: nil)
                        if contactModel.username == UserManager.sharedInstance.loginName {
                            continue
                        }
                        if contactModel.type == "G" {
                            continue
                        }
                        objArrTemp.append(contactModel)
                    }else{
                        print("解析出错")
                    }
                }
                
                
                if resultVC.resultMessageList.count <= 0 &&
                    resultVC.resultContactAndGroupList.count <= 0 &&
                    resultVC.searchChannelListArr.count <= 0 {
                    
                    resultVC.isNoSearchResult = false
                } else {
                    resultVC.isNoSearchResult = true
                }
                
                resultVC.searchChannelListArr = objArrTemp
                resultVC.tableView.reloadData()
            }
            
        }) { (error) in

            CODProgressHUD.showErrorWithStatus("搜索失败")
        }
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
//        UIApplication.shared.statusBarStyle = .lightContent
//        self.setTabBarHidden(true, animated: false)
//        if let subView = searchCtl.searchBar.subviews.first{
//            for view in subView.subviews {
//                if let imgView = view as? UIImageView{
//                    imgView.alpha = 0.0
//                }else if let textF = view as? UITextField {
//                    textF.backgroundColor = UIColor.init(hexString: "F1F1F1")
//                }else{
//                    view.backgroundColor = UIColor(hexString: kVCBgColorS)
//                }
//            }
//
//        }
        
        self.tabBarController?.tabBar.isHidden = true
        
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.setCancelButton()
        
        searchController.view.subviews.first?.backgroundColor = UIColor.white
        
        let viewCover = UIView.init()
        viewCover.tag = 101;
        viewCover.backgroundColor = UIColor.clear
        self.view.insertSubview(viewCover, aboveSubview: self.tableView)
        viewCover.snp.makeConstraints {(make) in
            make.edges.equalTo(self.tableView)
        }
        
        UIView.animate(withDuration: 0.3) {
            viewCover.backgroundColor = UIColor.white
        }
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        
        if self.type == .selectPerson {
            self.tabBarController?.tabBar.isHidden = true
        }else{
            self.tabBarController?.tabBar.isHidden = false
        }
        searchController.searchBar.showsCancelButton = false

        let viewCover:UIView = self.view.viewWithTag(101) ?? UIView.init()
        if (viewCover.superview != nil) {
            viewCover.removeFromSuperview()
        }
        
//        UIApplication.shared.statusBarStyle = .lightContent
//        self.setTabBarHidden(false, animated: false)
        searchController.searchBar.setPositionAdjustment(UIOffset.init(horizontal: (KScreenWidth - self.getSearchBarPlaceholderWidth())/2, vertical: 0), for: UISearchBar.Icon.search)
//        if let subView = searchCtl.searchBar.subviews.first{
//            for view in subView.subviews {
//                if let imgView = view as? UIImageView{
//                    imgView.alpha = 1
//                    view.backgroundColor = UIColor(hexString: kVCBgColorS)
//                }else if let textF = view as? UITextField {
//                    textF.backgroundColor = UIColor.init(hexString: "F1F1F1")
//                }else{
//                    view.backgroundColor = UIColor(hexString: kVCBgColorS)
//                }
//            }
//
//        }
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        self.searchActionDelegate?.endSearchAction()
        if self.resultContactList.count == 0 && self.resultGroupList.count == 0 {
            return
        }        
        if self.resultIndexPath.row < resultContactList.count {
            let model = resultContactList[self.resultIndexPath.row]
            if self.choosePersonBlock != nil {
                self.choosePersonBlock!(model)
            }
        }else{
            let model = resultGroupList[self.resultIndexPath.row-resultContactList.count]
            if self.chooseGroupBlock != nil {
                self.chooseGroupBlock!(model)
            }
        }
    }
    
}
extension ChatViewController :UISearchBarDelegate{
    ///开始编辑
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchActionDelegate?.startSearchAction()
        searchBar.setPositionAdjustment(UIOffset.zero, for: UISearchBar.Icon.search)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        searchBar.text = ""
//        searchBar.setPositionAdjustment(UIOffset.init(horizontal: (KScreenWidth - self.getSearchBarPlaceholderWidth())/2, vertical: 0), for: UISearchBar.Icon.search)
    }
    
    func getSearchBarPlaceholderWidth() -> CGFloat {
        let placeholderString = self.searchCtl.searchBar.placeholder ?? ""
        
        let textWidth = placeholderString.getStringWidth(font: searchCtl.searchBar.customTextField?.font ?? UIFont.systemFont(ofSize: 17), lineSpacing: 0, fixedWidth: KScreenWidth)
        return 50 + textWidth
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let resultVC = self.chatResultVC
        let searchStr = searchBar.text ?? ""
        var searchStrNoAt: String? = nil
        if searchStr.starts(with: "@") {
            searchStrNoAt = searchStr.removingPrefix("@")
        }
        
        resultVC.resultContactAndGroupList.removeAll()
        resultVC.searchChannelListArr.removeAll()
        resultVC.resultMessageList.removeAll()
        resultVC.tableView.reloadData()
        
        //联系人模糊查询
        var contactAndGroupArr = Array<AnyObject>()
        
        if let searchResults = CODContactRealmTool.getContactByKeyword(word: ((searchStrNoAt != nil) ? searchStrNoAt : searchStr)!, isContrainsTempFriends: true){
            if searchResults.count > 0 {
                for contact in searchResults {
                    contactAndGroupArr.append(contact)
                }
            }
        }
        
        //群组模糊查询
        if let searchGroupResults = CODGroupChatRealmTool.getGroupChatByKeyword(word: ((searchStrNoAt != nil) ? searchStrNoAt : searchStr)!) {
            for group in searchGroupResults {
                contactAndGroupArr.append(group)
            }
        }
        
        //频道模糊查询
        let searchChannelResutls = try! Realm.init().objects(CODChannelModel.self).filter({ (channelModel) -> Bool in
            return channelModel.getGroupName().contains(((searchStrNoAt != nil) ? searchStrNoAt : searchStr)!, caseSensitive: false) && channelModel.isValid
        }).sorted(by: { (channelModel1, channelModel2) -> Bool in
            return channelModel1.lastChatTime > channelModel2.lastChatTime
        })
        contactAndGroupArr.append(contentsOf: searchChannelResutls)
        resultVC.resultContactAndGroupList = contactAndGroupArr
        
        //消息模糊查询
        if self.type != .selectPerson {
            let beginDate = Date()
            if let messageResults = CODMessageRealmTool.searchMsgs(with: searchStr) {
                print(messageResults.count)
                let diff = beginDate.timeIntervalSinceNow
                print("数据库查询耗时：\(diff)")
                for message in messageResults {
                    let model = CODSearchResultMessageModel()
                    if let history = message.master.first {
                        model.id = history.id
                        
                        if let chatList = CODChatListRealmTool.getChatList(id: history.id) {
                            model.chatType = chatList.chatTypeEnum
                            model.jid = chatList.jid
                            model.title = chatList.title
                            model.subTitle = chatList.subTitle
                            model.icon = chatList.icon
                            model.lastDateTime = message.datetime
                            model.contact = chatList.contact
                            model.groupChat = chatList.groupChat
                            model.channelChat = chatList.channelChat
                            model.message = message
                        }
                        resultVC.resultMessageList.append(model)
                    }
                }
                
            }
            
            let diff = beginDate.timeIntervalSinceNow
            
            print("数据组装耗时：\(diff)")
        }
        
        resultVC.tableView.reloadData()
        
        // 全局搜索
        if searchStr.starts(with: "@") {
            
            if searchStr.count > 5 {
                self.requestGlobalSearch(searchStr: searchStrNoAt, resultVC: resultVC)
                
            }
        }
        
        if resultVC.resultMessageList.count <= 0 &&
            resultVC.resultContactAndGroupList.count <= 0 &&
            resultVC.searchChannelListArr.count <= 0 {
            
            resultVC.isNoSearchResult = false
        } else {
            resultVC.isNoSearchResult = true
        }
    }
}

extension ChatViewController: ContactSearchResultDelegate {
    func searchResultDidScroll(scrollView: UIScrollView) {
        self.searchCtl?.view.endEditing(true)
    }
    
    func contactSearchView(searchCtl: CODChatResultVC, CellSelected indexPath: IndexPath) {
        

        if self.type == .selectPerson {
            
            self.resultContactList = searchCtl.searchContactListArr
            self.resultGroupList = searchCtl.searchGroupListArr
            self.resultIndexPath = indexPath
            
            self.searchCtl.searchBar.text = ""
            self.searchCtl.isActive = false
            
           
        }else if (self.type == .normal) {
            
            if searchCtl.resultArr[indexPath.section].count > 0 {
                switch indexPath.section {
                case 3:
                    self.chatListResultSetting(searchCtl: searchCtl, indexPath: indexPath)
                case 4:
                    self.pushCtlWithSearchChannel(searchCtl: searchCtl, indexPath: indexPath)
                case 5:
                    self.messageResultSetting(searchCtl: searchCtl, indexPath: indexPath)
                default:
                    break
                }
            }

        }
    }
    
    func chatListResultSetting(searchCtl: CODChatResultVC, indexPath: IndexPath) {
        if let model: CODContactModel = searchCtl.resultContactAndGroupList[indexPath.row] as? CODContactModel {
            
            if model.rosterID == NewFriendRosterID {
                if let listModel = CODChatListRealmTool.getChatList(id: NewFriendRosterID) {
                    let ctl = Xinhoo_RosterRequestListViewController(nibName: "Xinhoo_RosterRequestListViewController", bundle: Bundle.main)
                    ctl.unRead = listModel.count
                    ctl.chatListModel = listModel
                    self.navigationController?.pushViewController(ctl, animated: true)
                    return
                }
            }else{
                self.pushCtlWith(contact: model)
            }
            
            
        }else if let groupModel: CODGroupChatModel = searchCtl.resultContactAndGroupList[indexPath.row] as? CODGroupChatModel {
            self.pushCtlWith(group: groupModel)
        }else if let channelModel: CODChannelModel = searchCtl.resultContactAndGroupList[indexPath.row] as? CODChannelModel {
            self.pushCtlWith(channelModel: channelModel)
        }
    }
    
    func messageResultSetting(searchCtl: CODChatResultVC, indexPath: IndexPath) {
        let model = searchCtl.resultMessageList[indexPath.row]
        if let contact = model.contact {
            self.pushCtlWith(model: model, contact: contact)
        }else if let group = model.groupChat {
            self.pushCtlWith(model: model, group: group)
        }else if let channelModel = model.channelChat {
            self.pushCtlWith(model: model, channelModel: channelModel)
        }
    }
    
    func pushCtlWith(model: CODSearchResultMessageModel? = nil, contact: CODContactModel) {
        let msgCtl = MessageViewController()
        if let listModel = CODChatListRealmTool.getChatList(id: contact.rosterID) {
            msgCtl.newMessageCount = listModel.count
        }
        msgCtl.chatType = .privateChat
        msgCtl.toJID = contact.jid
        msgCtl.chatId = contact.rosterID
        msgCtl.title = contact.getContactNick()
        msgCtl.isMute = contact.mute
        
        if let model = model {
            msgCtl.searchResultMessage = model.message
        }
        self.navigationController?.pushViewController(msgCtl, animated: true)
    }
    
    func pushCtlWith(model: CODSearchResultMessageModel? = nil, group: CODGroupChatModel) {
        let msgCtl = MessageViewController()
        if let listModel = CODChatListRealmTool.getChatList(id: group.roomID) {
            msgCtl.newMessageCount = listModel.count
            
            if (listModel.groupChat?.descriptions) != nil {
                let groupName = listModel.groupChat?.descriptions
                if let groupName = groupName, groupName.count > 0 {
                    msgCtl.title = groupName.subStringToIndexAppendEllipsis(10)
                }else{
                    msgCtl.title = NSLocalizedString("群组", comment: "")
                }
            }else{
                msgCtl.title = NSLocalizedString("群组", comment: "")
            }
            
            if let groupChatTemp = listModel.groupChat {
                msgCtl.toJID = String(groupChatTemp.jid)
            }
            msgCtl.chatId = listModel.id
            
        }else{
            if let group = CODGroupChatRealmTool.getGroupChat(id: group.roomID) {
                msgCtl.title = group.getGroupName().subStringToIndexAppendEllipsis(10)
            }else{
                msgCtl.title = NSLocalizedString("群组", comment: "")
            }
            msgCtl.toJID =  group.jid
            msgCtl.chatId = group.roomID
        }
        msgCtl.chatType = .groupChat
        msgCtl.roomId = String(format: "%d", group.roomID)
        msgCtl.isMute = group.mute
        if let model = model {
            msgCtl.searchResultMessage = model.message
        }
        self.navigationController?.pushViewController(msgCtl, animated: true)
    }
    
    func pushCtlWith(model: CODSearchResultMessageModel? = nil, channelModel: CODChannelModel) {
        let msgCtl = MessageViewController()
        if let listModel = CODChatListRealmTool.getChatList(id: channelModel.roomID) {
            msgCtl.newMessageCount = listModel.count
            
            if (listModel.channelChat?.descriptions) != nil {
                let groupName = listModel.channelChat?.descriptions
                if let groupName = groupName, groupName.count > 0 {
                    msgCtl.title = groupName.subStringToIndexAppendEllipsis(10)
                }else{
                    msgCtl.title = NSLocalizedString("频道", comment: "")
                }
            }else{
                msgCtl.title = NSLocalizedString("频道", comment: "")
            }
        }else{
            if channelModel.descriptions.count > 0 {
                msgCtl.title = channelModel.descriptions.subStringToIndexAppendEllipsis(10)
            }else{
                msgCtl.title = NSLocalizedString("频道", comment: "")
            }
        }
        msgCtl.toJID =  channelModel.jid
        msgCtl.chatId = channelModel.roomID
        msgCtl.chatType = .channel
        msgCtl.channelModel = channelModel
        msgCtl.roomId = String(format: "%d", channelModel.roomID)
        msgCtl.isMute = channelModel.mute
        if let model = model {
            msgCtl.searchResultMessage = model.message
        }
        self.navigationController?.pushViewController(msgCtl, animated: true)
    }
    
    func pushCtlWithSearchChannel(searchCtl: CODChatResultVC, indexPath: IndexPath) {
        
        let objectModel: CODSearchResultContact = searchCtl.searchChannelListArr[indexPath.row]
        XMPPManager.shareXMPPManager.getSearchResultInfo(userid: objectModel.userid, type: objectModel.type, success: { (model, nameStr) in
            if nameStr == COD_viewsearchdata {
                guard model.success else{
                    CODProgressHUD.showErrorWithStatus(model.msg)
                    return
                }
                guard let dicTemp = JSON(model.data as Any).dictionaryObject else {
                    return
                }
                if objectModel.type == "C" {
                    if let jsonModel = CODChannelHJsonModel.deserialize(from: dicTemp) {
                        let msgCtl = MessageViewController()
                        let channelModel = CODChannelModel.init(jsonModel: jsonModel)
                        if let listModel = CODChatListRealmTool.getChatList(id: channelModel.roomID) {
                            msgCtl.newMessageCount = listModel.count
                            
                            if (listModel.channelChat?.descriptions) != nil {
                                let groupName = listModel.channelChat?.descriptions
                                if let groupName = groupName, groupName.count > 0 {
                                    msgCtl.title = groupName.subStringToIndexAppendEllipsis(10)
                                }else{
                                    msgCtl.title = NSLocalizedString("频道", comment: "")
                                }
                            }else{
                                msgCtl.title = NSLocalizedString("频道", comment: "")
                            }
                            if let groupChatTemp = listModel.channelChat {
                                msgCtl.toJID = String(groupChatTemp.jid)
                            }
                            msgCtl.chatId = listModel.id
                            msgCtl.channelModel = listModel.channelChat ?? nil
                        }else{
                            CODDownLoadManager.sharedInstance.updateAvatar(userPicID: channelModel.grouppic, complete: nil)
                            if let memberArr = dicTemp["channelMemberVoList"] as? [Dictionary<String, Any>]? {
                                guard let memberArr = memberArr else {
                                    return
                                }
                                for member in memberArr {
                                    let memberTemp = CODGroupMemberModel()
                                    memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
                                    memberTemp.memberId = String(format: "%d%@", channelModel.roomID, memberTemp.username)
                                    channelModel.member.append(memberTemp)
                                }
                            }
                            if let noticeContent = dicTemp["noticecontent"] as? Dictionary<String, Any> {
                                if let notice = noticeContent["notice"] as? String {
                                    channelModel.notice = notice
                                }
                            }
                            channelModel.customName = CODGroupChatModel.getCustomGroupName(memberList: channelModel.member)
                            channelModel.createDate =  String(format: "%.0f", Date.milliseconds)
                            try! Realm.init().write {
                                try! Realm.init().add(channelModel, update: .all)
                            }
                            
                            if channelModel.descriptions.count > 0 {
                                msgCtl.title = channelModel.descriptions.subStringToIndexAppendEllipsis(10)
                            }else{
                                msgCtl.title = NSLocalizedString("频道", comment: "")
                            }

                            msgCtl.toJID =  channelModel.jid
                            msgCtl.chatId = channelModel.roomID
                            msgCtl.channelModel = channelModel
                        }
                        msgCtl.chatType = .channel
                        msgCtl.roomId = String(format: "%d", channelModel.roomID)
                        msgCtl.isMute = channelModel.mute
                        self.navigationController?.pushViewController(msgCtl, animated: true)
                    }else{
                        print("解析出错")
                    }
                }else if objectModel.type == "U" || objectModel.type == "B" {
                    let contactModel = CODContactModel()
                    contactModel.jsonModel = CODContactHJsonModel.deserialize(from: dicTemp)
                    let  dict:NSDictionary = ["name":COD_temporaryfriend,
                                              "requester":UserManager.sharedInstance.jid,
                                              "receiver":contactModel.jid]
                    let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_roster, actionDic: dict)
                    XMPPManager.shareXMPPManager.xmppStream.send(iq)
                    
                }else if objectModel.type == "G" {
                    
                }
            }
                
        }) { (error) in
            CODProgressHUD.showErrorWithStatus(error.msg)
            print("失败：\(error.msg ?? "空")")
        }
    }
}

protocol ChatViewSearchActionDelegate: NSObject {
    func startSearchAction()
    func endSearchAction()
}
