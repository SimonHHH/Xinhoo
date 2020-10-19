//
//  ContactsViewController+SearchBarDelegate.swift
//  COD
//
//  Created by 1 on 2019/4/18.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

extension ContactsViewController :UISearchControllerDelegate,UISearchResultsUpdating{
    
    //数据需要更新
    func updateSearchResults(for searchController: UISearchController) {
        if let resultVC = searchController.searchResultsController as? CODChatResultVC {
            //联系人模糊查询
            if let searchResults = CODContactRealmTool.getContactByKeyword(word: searchController.searchBar.text ?? ""){
                print(searchResults as Any)
                resultVC.searchContactListArr.removeAll()
                if type == .newCall {
                    let searchItems = searchResults.filter { (contact) -> Bool in
                        return contact.rosterID > 0
                    }
                    resultVC.searchContactListArr = searchItems
                }else{
                    resultVC.searchContactListArr = searchResults
                }
                
            }else{
                
                resultVC.searchContactListArr.removeAll()
            }
            
            //群组模糊查询
            if let searchGroupResults = CODGroupChatRealmTool.getGroupChatByKeyword(word: searchController.searchBar.text ?? "") {
                resultVC.searchGroupListArr = searchGroupResults
            }else{
                resultVC.searchGroupListArr.removeAll()
            }
            
            //频道模糊查询
            let searchChannelResutls = try! Realm.init().objects(CODChannelModel.self).filter({ (channelModel) -> Bool in
                return channelModel.getGroupName().contains(searchController.searchBar.text ?? "", caseSensitive: false) && channelModel.isValid == true
            }).sorted(by: { (channelModel1, channelModel2) -> Bool in
                return channelModel1.lastChatTime > channelModel2.lastChatTime
            }).compactMap({ (channelModel) -> CODChannelModel in
                return channelModel
            })
            
            if searchChannelResutls.count > 0 {
                resultVC.searchLocalChannelList = searchChannelResutls
            }else{
                resultVC.searchLocalChannelList.removeAll()
            }
            
            
            if resultVC.searchContactListArr.count <= 0 && resultVC.searchGroupListArr.count <= 0 && resultVC.searchLocalChannelList.count <= 0{
                resultVC.isNoSearchResult = false
            }else{
                resultVC.isNoSearchResult = true
            }
            
            resultVC.tableView.reloadData()
            
        }
        
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        self.tabBarController?.tabBar.isHidden = true
        
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.setCancelButton()
        
        let viewCover = UIView.init()
        viewCover.tag = 101;
        viewCover.backgroundColor = UIColor.init(hexString: kVCBgColorS)
        self.view.insertSubview(viewCover, aboveSubview: self.tableView)
        viewCover.snp.makeConstraints {(make) in
            make.edges.equalTo(self.tableView)
        }
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(searchTextFieldResignFirstResponder))
        viewCover.addGestureRecognizer(tapGesture)
        
        UIView.animate(withDuration: 0.3) {
            viewCover.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        }
    }
    
    @objc func searchTextFieldResignFirstResponder() {
        self.searchCtl?.isActive = false
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        if self.type == .selectPerson {
            self.tabBarController?.tabBar.isHidden = true
        }else{
            self.tabBarController?.tabBar.isHidden = false
        }
        searchController.searchBar.setPositionAdjustment(UIOffset.init(horizontal: (KScreenWidth - self.getSearchBarPlaceholderWidth())/2, vertical: 0), for: UISearchBar.Icon.search)
        
        searchController.searchBar.showsCancelButton = false

        let viewCover:UIView = self.view.viewWithTag(101) ?? UIView.init()
        if (viewCover.superview != nil) {
            viewCover.removeFromSuperview()
        }
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        self.searchActionDelegate?.endSearchEvent()
        if self.type == .selectPerson {
            if self.resultContactList.count == 0 && self.resultGroupList.count == 0 {
                
                return
            }
            
            if self.resultIndexPath.section == 0,resultContactList.count > 0 {
                let model = resultContactList[self.resultIndexPath.row]
                if self.choosePersonBlock != nil {
                    
                    self.choosePersonBlock!(model)
                }
            }else{
                let model = resultGroupList[self.resultIndexPath.row]
                if self.chooseGroupBlock != nil {
                    self.chooseGroupBlock!(model)
                }
            }
        }else if self.type == .newCall {
            
            if self.selectContactModel == nil {
                return
            }
            
            let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(title: "语音通话", style: .default, isEnabled: true) { (action) in
                let model = self.selectContactModel
                
                if UserDefaults.standard.bool(forKey: kIsVideoCall) {
                    CODProgressHUD.showWarningWithStatus("当前无法发起语音通话")
                    return
                }
                
                let delegate = UIApplication.shared.delegate as! AppDelegate
                if delegate.callObserver.calls.first != nil {
                    let alert = UIAlertController.init(title: "正在通话", message: String.init(format: NSLocalizedString("您不能在电话通话时同时使用 %@ 通话。", comment: ""), kApp_Name), preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: "好", style: .default) { (action) in
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                if delegate.manager?.status == .notReachable {
                    
                    let alert = UIAlertController.init(title: "无法呼叫", message: "请检查您的互联网连接并重试。", preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: "好", style: .default) { (action) in
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                let  dict:NSDictionary = ["name":COD_request,
                                          "requester":UserManager.sharedInstance.jid,
                                          "memberList":[model!.jid],
                                          "chatType":"1",
                                          "roomID":"0",
                                          "msgType":COD_call_type_voice]

                let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_voicerequest, actionDic: dict)
                XMPPManager.shareXMPPManager.xmppStream.send(iq)
                self.selectContactModel = nil
            }
            alert.addAction(title: "取消", style: .cancel, isEnabled: true) { (action) in
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ContactsViewController :UISearchBarDelegate{
    ///开始编辑
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchActionDelegate?.startSearchEvent()
        searchBar.setPositionAdjustment(UIOffset.zero, for: UISearchBar.Icon.search)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        searchBar.text = ""
//        searchBar.setPositionAdjustment(UIOffset.init(horizontal: (KScreenWidth - self.getSearchBarPlaceholderWidth())/2, vertical: 0), for: UISearchBar.Icon.search)
    }
    
    func getSearchBarPlaceholderWidth() -> CGFloat {
        guard let searchCtl = searchCtl else {
            return 0.0
        }
        let placeholderString = searchCtl.searchBar.placeholder ?? ""
        
        let textWidth = placeholderString.getStringWidth(font: searchCtl.searchBar.customTextField?.font ?? UIFont.systemFont(ofSize: 17), lineSpacing: 0, fixedWidth: KScreenWidth)
        return 50 + textWidth
    }

}

extension ContactsViewController: ContactSearchResultDelegate {
    func searchResultDidScroll(scrollView: UIScrollView) {
        self.searchCtl?.view.endEditing(true)
    }
    
    func contactSearchView(searchCtl: CODChatResultVC, CellSelected indexPath: IndexPath) {
        
        if self.type == .selectPerson {
            
            self.resultContactList = searchCtl.searchContactListArr
            self.resultGroupList = searchCtl.searchGroupListArr
            self.resultIndexPath = indexPath
            
            self.searchCtl?.searchBar.text = ""
            self.searchCtl?.isActive = false
            
        }else if (self.type == .normal) {
            
            if indexPath.section == 0 {
                if searchCtl.searchContactListArr.count > 0 {
                    self.pushContactMessageVC(searchCtl: searchCtl, indexPath: indexPath)
                }else{
                    if searchCtl.searchGroupListArr.count > 0 {
                        self.pushGroupMessageVC(searchCtl: searchCtl, indexPath: indexPath)
                    }else {
                        self.pushChannelMessageVC(searchCtl: searchCtl, indexPath: indexPath)
                    }
                }
            }else if indexPath.section == 1 {
                if searchCtl.searchContactListArr.count > 0 {
                    self.pushGroupMessageVC(searchCtl: searchCtl, indexPath: indexPath)
                }else if searchCtl.searchGroupListArr.count > 0 {
                    self.pushChannelMessageVC(searchCtl: searchCtl, indexPath: indexPath)
                }
            }else{
                self.pushChannelMessageVC(searchCtl: searchCtl, indexPath: indexPath)
            }
            
//            self.searchCtl?.searchBar.text = ""
//            self.searchCtl?.isActive = false
            
        }else if(self.type == .newCall){
         
            if indexPath.section == 1{
                
                let alert = UIAlertController.init(title: "提示", message: "您不能在群组中发起语音通话。", preferredStyle: .alert)
                let confirmAction = UIAlertAction.init(title: "好", style: .default, handler: nil)
                alert.addAction(confirmAction)
                self.present(alert, animated: true, completion: nil)
                
            }else{
//                self.resultContactList = searchCtl.searchContactListArr
//                self.resultGroupList = searchCtl.searchGroupListArr
//                self.resultIndexPath = indexPath
                self.selectContactModel = searchCtl.selectContactModel
                self.searchCtl?.searchBar.text = ""
                self.searchCtl?.isActive = false
            }
        }
    }
}

extension ContactsViewController {
    func pushContactMessageVC(searchCtl: CODChatResultVC, indexPath: IndexPath) {
        let msgCtl = MessageViewController()
        let model: CODContactModel = searchCtl.searchContactListArr[indexPath.row]
        if let listModel = CODChatListRealmTool.getChatList(id: model.rosterID) {
            msgCtl.newMessageCount = listModel.count
        }
        msgCtl.chatType = .privateChat
        msgCtl.toJID = model.jid
        msgCtl.chatId = model.rosterID
        msgCtl.title = model.getContactNick()
        msgCtl.isMute = model.mute
        self.navigationController?.pushViewController(msgCtl, animated: true)
    }
    
    func pushGroupMessageVC(searchCtl: CODChatResultVC, indexPath: IndexPath) {
        let msgCtl = MessageViewController()
        let groupModel: CODGroupChatModel = searchCtl.searchGroupListArr[indexPath.row]
        if let listModel = CODChatListRealmTool.getChatList(id: groupModel.roomID) {
            msgCtl.newMessageCount = listModel.count
            if let groupName = listModel.groupChat?.descriptions, groupName.count > 0 {
                msgCtl.title = groupName.subStringToIndexAppendEllipsis(10)
            }else{
                msgCtl.title = NSLocalizedString("群组", comment: "")
            }
            
            if let groupChatTemp = listModel.groupChat {
                msgCtl.toJID = String(groupChatTemp.jid)
            }
            msgCtl.chatId = listModel.id
        }else{
            msgCtl.title = groupModel.getGroupName()
            msgCtl.toJID =  groupModel.jid
            msgCtl.chatId = groupModel.roomID
        }
        msgCtl.chatType = .groupChat
        msgCtl.roomId = String(format: "%d", groupModel.roomID)
        msgCtl.isMute = groupModel.mute
        self.navigationController?.pushViewController(msgCtl, animated: true)
    }
    
    func pushChannelMessageVC(searchCtl: CODChatResultVC, indexPath: IndexPath) {
        let msgCtl = MessageViewController()
        let channelModel: CODChannelModel = searchCtl.searchLocalChannelList[indexPath.row]
        if let listModel = CODChatListRealmTool.getChatList(id: channelModel.roomID) {
            msgCtl.newMessageCount = listModel.count
            if let channelName = listModel.channelChat?.descriptions, channelName.count > 0 {
                msgCtl.title = channelName.subStringToIndexAppendEllipsis(10)
            }else{
                msgCtl.title = NSLocalizedString("频道", comment: "")
            }
            
            if let groupChatTemp = listModel.channelChat {
                msgCtl.toJID = String(groupChatTemp.jid)
            }
            msgCtl.chatId = listModel.id
        }else{
            msgCtl.title = channelModel.getGroupName()
            msgCtl.toJID =  channelModel.jid
            msgCtl.chatId = channelModel.roomID
        }
        msgCtl.chatType = .channel
        msgCtl.roomId = String(format: "%d", channelModel.roomID)
        msgCtl.isMute = channelModel.mute
        self.navigationController?.pushViewController(msgCtl, animated: true)
    }
}

protocol contactsViewSearchActionDelegate: class {
    func startSearchEvent()
    func endSearchEvent()
}


