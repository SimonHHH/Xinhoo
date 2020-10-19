//
//  ChatViewController+UITableViewDelegate.swift
//  COD
//
//  Created by 1 on 2019/4/17.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import LGAlertView
import SwipeCellKit

extension ChatViewController :UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.type == .normal {
            self.chatCellSelected(indexPath: indexPath)
        } else if (self.type == .selectPerson) {
            let model = self.chatListArr[indexPath.row]
            if self.chooseChatListBlock != nil {
                self.chooseChatListBlock!(model)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 1))
//        view.backgroundColor = UIColor(hexString: kVCBgColorS)
        return UIView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.checkTopLineIsHidden()
        self.view.endEditing(true)
    }
    
}

extension ChatViewController :UITableViewDataSource, SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return chatListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
        return self.getChatCell(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        let listModel = chatListArr[indexPath.row]
        
        return listModel.stickyTop
        
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        
        var destinationIndexPath = proposedDestinationIndexPath
        
        let stickyTopCount = chatListArr.filter { $0.stickyTop }.count
        
        if stickyTopCount > 0, stickyTopCount < proposedDestinationIndexPath.row {
            destinationIndexPath = IndexPath(row: stickyTopCount - 1, section: proposedDestinationIndexPath.section)
        }
        
        return destinationIndexPath
    
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let chatListModel = chatListArr[sourceIndexPath.row]
        
        let stickyTopCount = chatListArr.filter { $0.stickyTop }.count

        chatListArr = chatListArr.rearrange(fromIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row)
        
        var destinationJID = ""
        
        if destinationIndexPath.row < (stickyTopCount - 1) {
            destinationJID = chatListArr[destinationIndexPath.row + 1].jid
        }
        
        XMPPManager.shareXMPPManager.topranking(chatListModel, destinationJID)
        
        let jidList = chatListArr.filter { $0.stickyTop }.map { $0.jid }
        
        DispatchQueue.realmWriteQueue.async {
            CustomUtil.topRankListHander(chatJIDList: jidList, needReload: false)
        }
        
                
    }
    
    
    
    /// 左滑删除频道会话，弹出视图
    /// - Parameter listModel: 会话model
    func showDeleteViewWithChannel(listModel:CODChatListModel) {
        
        let owner = listModel.channelChat?.getMember(by: UserManager.sharedInstance.loginName ?? "")?.userpower == 10
        
        let title = owner ? "解散频道" : "退出频道"
        let desc = owner ? NSLocalizedString("创建者退出会解散频道，确定要退出 %@ 吗？", comment: "") : NSLocalizedString("您确定要退出 %@ 吗?", comment: "")
        let channelView = DeleteChatListModelView.initWitXib(imgID: listModel.icon, desc: nil, subDesc: String(format: desc, listModel.title))

        
        let alert = LGAlertView(viewAndTitle: nil, message: nil, style: .actionSheet, view: channelView, buttonTitles: nil, cancelButtonTitle: NSLocalizedString("取消", comment: ""), destructiveButtonTitle: title, actionHandler: nil, cancelHandler: nil) { (alertView) in
            
            if owner {
                XMPPManager.shareXMPPManager.destroyChannel(roomId: listModel.channelChat?.roomID ?? 0, success: { (_, name) in
                }) { (_) in
                }
            }else{
                XMPPManager.shareXMPPManager.quitChannel(roomId: listModel.channelChat?.roomID ?? 0, success: { (_, name) in
                }) { (_) in
                }
            }
            
        }
        alert.cancelButtonBackgroundColorHighlighted = .clear
        alert.destructiveButtonTitleColor = UIColor(hexString: "FF3B30")
        alert.show(animated: true, completionHandler: nil)
        
    }
    /// 左滑删除会话，弹出视图
    /// - Parameter listModel: 会话model
    func showDeleteView(listModel:CODChatListModel) {
        
        var message = ""
        var buttonTitles:[String]? = nil
        if listModel.id == NewFriendRosterID {
            message = "您确定要删除此会话？"
            buttonTitles = [NSLocalizedString("删除", comment: "")]
        }else{
            message = "删除会话会清空聊天记录，您确定要删除吗？"
            buttonTitles = [NSLocalizedString("清除聊天记录", comment: ""),NSLocalizedString("删除", comment: "")]
        }
        
        var imgID :Any? = nil
        imgID = listModel.icon
        if listModel.id == NewFriendRosterID {
            imgID = UIImage(named: "chat_new_friend_icon")
        }else if listModel.id == CloudDiskRosterID {
            imgID = UIImage(named: "cloud_disk_icon")
        }else if listModel.id == RobotRosterID {
            imgID = UIImage.helpIcon()
        }
        
        let channelView = DeleteChatListModelView.initWitXib(imgID: imgID, desc:nil, subDesc:  NSLocalizedString(message, comment: ""))

        let alert = LGAlertView(viewAndTitle: nil, message: nil, style: .actionSheet, view: channelView, buttonTitles: buttonTitles, cancelButtonTitle: NSLocalizedString("取消", comment: ""), destructiveButtonTitle: nil, actionHandler: {[weak self] (alert, index, buttonTitle) in
            
            switch index {
            
            case 0:
                
                if listModel.id == NewFriendRosterID {
                    self?.deleteSession(model: listModel)
                    self?.updateFooter()
                }else{
                
                    self?.clearSessionRecord(model: listModel)
                }
                break
            case 1:
                self?.deleteSession(model: listModel)
                self?.updateFooter()
                break
            default:
                break
            }
            
        }, cancelHandler: nil, destructiveHandler: nil)
        
        alert.cancelButtonBackgroundColorHighlighted = .clear
        alert.buttonsBackgroundColorHighlighted = .clear
        alert.buttonsTitleColor = UIColor(hexString: "FF3B30")
        alert.buttonsHeight = 56
        
        alert.show(animated: true, completionHandler: nil)
    }
    
    /*
    @available(iOS 11.0, *)
    /// 苹果iOS11，滑动删除新特性
    ///
    /// - Parameters:
    ///   - tableView: tableview
    ///   - indexPath: indexpath
    /// - Returns: 删除按钮配置
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let listModel = chatListArr[indexPath.row]
        
        let deleteAction:UIContextualAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            
            if listModel.chatTypeEnum == .channel {
                
                self.showDeleteViewWithChannel(listModel: listModel)
                
            }else{
                self.showDeleteView(listModel: listModel)
            }
            
            completionHandler(true)
        }
        //delete操作按钮可使用UIContextualActionStyleDestructive类型，当使用该类型时，如果是右滑操作，一直向右滑动某个cell，会直接执行删除操作，不用再点击删除按钮。
        deleteAction.backgroundColor = UIColor(hexString: "#FF3724")
        deleteAction.image = UIImage.init(named: "chat_delete\(currentLanguage)")
        
        let model = self.chatListArr[indexPath.row]
        var topImgName = ""
        
        if model.stickyTop {
            topImgName = "chat_top_off\(currentLanguage)"
        }else{
            topImgName = "chat_top_on\(currentLanguage)"
        }
        
        if model.id == NewFriendRosterID {
            if UserManager.sharedInstance.xhnfsticktop {
                topImgName = "chat_top_off\(currentLanguage)"
            }else{
                topImgName = "chat_top_on\(currentLanguage)"
            }
        }
        
//        var topImageNameArr: Array<UIImage> = []
//        for i in 0..<30 {
//            let imageStr = String(format: "mute_off_000%02d", i)
//            let image = UIImage.init(named: imageStr)!
//            topImageNameArr.append(image)
//        }
        
        
        var muteImgName = ""
        if let contact = model.contact {
            if contact.mute {
                muteImgName = "chat_mute_off\(currentLanguage)"
            }else{
                muteImgName = "chat_mute_on\(currentLanguage)"
            }
        }
        
        if let group = model.groupChat {
            if group.mute {
                muteImgName = "chat_mute_off\(currentLanguage)"
            }else{
                muteImgName = "chat_mute_on\(currentLanguage)"
            }
        }
        
        if let channel = model.channelChat {
            if channel.mute {
                muteImgName = "chat_mute_off\(currentLanguage)"
            }else{
                muteImgName = "chat_mute_on\(currentLanguage)"
            }
        }
        
        if model.id == NewFriendRosterID {
            if UserManager.sharedInstance.xhnfmute {
                muteImgName = "chat_mute_off\(currentLanguage)"
            }else{
                muteImgName = "chat_mute_on\(currentLanguage)"
            }
        }
        
        let topAction:UIContextualAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            self.actionSession(sessionStr: COD_Stickytop, indexPath: indexPath)
            completionHandler(true)
        }
        topAction.backgroundColor = UIColor.init(hexString: "#B6B6BB")
        topAction.image = UIImage.init(named: topImgName)
//        topAction.image = UIImage.animatedImage(with: topImageNameArr, duration: 0.3)
        
        let muteAction:UIContextualAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            self.actionSession(sessionStr: COD_Mute, indexPath: indexPath)
            completionHandler(true)
        }
        muteAction.backgroundColor = UIColor.init(hexString: "#FF9500")
        muteAction.image = UIImage.init(named: muteImgName)
        
        var actions :Array<UIContextualAction> = []
        if let model = model.contact, model.rosterID < 1 { //为云盘和小助手
            actions = [deleteAction]
            if model.rosterID == CloudDiskRosterID {
                //2.0遗留功能完善，【mango客户反馈】IOS2.0版本里，小助手删掉以后，上线又跑出来了
                //服务器没有提供删除会话的接口，经需求评审讨论，客户端自己本地逻辑删除，接收到会话列表的时候，判断小助手的badge是否为0，如果是0则不做任何操作
                //但是云盘会话badge是一直为0的，所以云盘不支持左滑删除功能
                actions.remove(at: 0)
                actions.append(topAction)
            }
        } else if let model = model.groupChat, model.isValid == false {
            actions = [deleteAction]
        } else{
            actions = [deleteAction,muteAction,topAction]
        }
        
        if model.id == NewFriendRosterID {
            actions = [deleteAction,muteAction,topAction]
        }
        
        let action:UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: actions)
        // 当一直向右滑是会执行第一个action
        action.performsFirstActionWithFullSwipe = true
        
        return action
    }*/
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let listModel = chatListArr[indexPath.row]
        let font = UIFont.systemFont(ofSize: 13.0)
        let deleteAction = SwipeAction(style: .destructive, title: NSLocalizedString("删除", comment: "")) { action, indexPath in
            
            if listModel.chatTypeEnum == .channel {
                self.showDeleteViewWithChannel(listModel: listModel)
                
            }else{
                self.showDeleteView(listModel: listModel)
            }
            
        }
        //delete操作按钮可使用UIContextualActionStyleDestructive类型，当使用该类型时，如果是右滑操作，一直向右滑动某个cell，会直接执行删除操作，不用再点击删除按钮。
        deleteAction.backgroundColor = UIColor(hexString: "#FF3724")
        deleteAction.image = UIImage.init(named: "swipe_del") //swipe_del //chat_delete\(currentLanguage)
        deleteAction.font = font
        
        let model = self.chatListArr[indexPath.row]
        
        var isTop = model.stickyTop
        if model.id == NewFriendRosterID {
            isTop = UserManager.sharedInstance.xhnfsticktop
        }
        
        var isMute = false
        if let contact = model.contact {
            isMute = contact.mute
        }
        
        if let group = model.groupChat {
            isMute = group.mute
        }
        
        if let channel = model.channelChat {
            isMute = channel.mute
        }
        
        if model.id == NewFriendRosterID {
            isMute = UserManager.sharedInstance.xhnfmute
        }

        let topAction = SwipeAction(style: .default, title: NSLocalizedString(isTop ? "取消置顶" : "置顶", comment: "")) { action, indexPath in
            self.actionSession(sessionStr: COD_Stickytop, indexPath: indexPath)
        }
        topAction.backgroundColor = UIColor.init(hexString: "#B6B6BB")
        topAction.image = UIImage.init(named: isTop ? "swipe_unpin" : "swipe_pin") //isTop ? "swipe_unpin" : "swipe_pin"
        topAction.font = font
        
        let muteAction = SwipeAction(style: .default, title: NSLocalizedString(isMute ? "开启通知" : "关闭通知", comment: "")) { action, indexPath in
            self.actionSession(sessionStr: COD_Mute, indexPath: indexPath)
        }
        muteAction.backgroundColor = UIColor.init(hexString: "#FF9500")
        muteAction.image = UIImage.init(named: isMute ? "swipe_unmute" : "swipe_mute") //isMute ? "swipe_mute" : "swipe_unmute"
        muteAction.font = font
        
        var actions :Array<SwipeAction> = []
        if let model = model.contact, model.rosterID < 1 { //为云盘和小助手
            actions = [deleteAction]
            if model.rosterID == CloudDiskRosterID {
                //2.0遗留功能完善，【mango客户反馈】IOS2.0版本里，小助手删掉以后，上线又跑出来了
                //服务器没有提供删除会话的接口，经需求评审讨论，客户端自己本地逻辑删除，接收到会话列表的时候，判断小助手的badge是否为0，如果是0则不做任何操作
                //但是云盘会话badge是一直为0的，所以云盘不支持左滑删除功能
                actions.remove(at: 0)
                actions.append(topAction)
            }
        } else if let model = model.groupChat, model.isValid == false {
            actions = [deleteAction]
        } else{
            actions = [deleteAction,muteAction,topAction]
        }
        
        if model.id == NewFriendRosterID {
//            actions = [deleteAction,muteAction,topAction]
            actions = [muteAction,topAction]
        }
        return actions

    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .border
        options.maximumButtonWidth = 74.0
        options.buttonSpacing = 3.0
        return options
    }

    
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        // 删除
//        let model = chatListArr[indexPath.row]
//        let deleteAction:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "         ") { (action, indexPath) in
//
//            LPActionSheet.show(withTitle:nil, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: ["清除聊天记录","删除"]) { (actionSheet, index) in
//
//                switch index{
//                case 0:
//                    break
//                case 1:
//                    self.clearSessionRecord(model: model)
//                    break
//                case 2:
//                    self.deleteSession(model: model)
//                    break
//                default:
//                    break
//                }
//            }
//        }
//        deleteAction.backgroundColor = UIColor(patternImage: UIImage(named: "chat_delete")!)
//
////        let model = self.chatListArr[indexPath.row]
//        var topImgName = ""
//
//        if model.stickyTop {
//            topImgName = "chat_top_off"
//        }else{
//            topImgName = "chat_top_on"
//        }
//
//        var muteImgName = ""
//        if let contact = model.contact {
//            if contact.mute {
//                muteImgName = "chat_mute_off"
//            }else{
//                muteImgName = "chat_mute_on"
//            }
//        }
//
//        if let group = model.groupChat {
//            if group.mute {
//                muteImgName = "chat_mute_off"
//            }else{
//                muteImgName = "chat_mute_on"
//            }
//        }
//
//        // 消息免打扰
//        let muteAction:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "         ") { (action, indexPath) in
//
//            self.actionSession(sessionStr: COD_Mute, indexPath: indexPath)
//        }
//        muteAction.backgroundColor = UIColor(patternImage: UIImage(named: muteImgName)!)
//
//        // 置顶
//        let topAction:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "         ") { (action, indexPath) in
//
//            self.actionSession(sessionStr: COD_Stickytop, indexPath: indexPath)
//        }
//        topAction.backgroundColor = UIColor(patternImage: UIImage(named: topImgName)!)
//
//        // 第一个显示在最右边
//        return [deleteAction, muteAction, topAction]
//    }
    
//    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
//        self.view.setNeedsLayout()
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        
//        let model = chatListArr[indexPath.row]
//        
//        reti
//        
//        
//        
//    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let model = chatListArr[indexPath.row]
        if editingStyle == .delete {
            LPActionSheet.show(withTitle:nil, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: ["清除聊天记录","删除"]) { (actionSheet, index) in

                switch index{
                case 0:
                    break
                case 1:
                    self.clearSessionRecord(model: model)
                    break
                case 2:
                    self.deleteSession(model: model)
                    break
                default:
                    break
                }
            }
        }

    }
    
    func clearSessionRecord(model: CODChatListModel) {

        
        CustomUtil.clearChatRecord(chatId: model.id) { [weak self] in
            guard let `self` = self else {
                return
            }
            CODFileManager.shareInstanceManger().deleteEMConversationFilePathWithFilesAndImagesAndVideos(sessionID: model.jid)
            CODChatListRealmTool.deleteChatListHistory(by: model.id)
            //删除会话的时候要去通知”呼叫“模块更新列表
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadCallVC), object: nil, userInfo:nil)
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadRedPoint), object: nil, userInfo:nil)
            self.tableView.reloadData()
        }
        
//        CustomUtil.clearChatRecord(chatId: model.id)
        
    }
    
    func deleteSession(model: CODChatListModel) {
        

        CustomUtil.deleteChat(model: model) {
            CODFileManager.shareInstanceManger().deleteEMConversationFilePathWithFilesAndImagesAndVideos(sessionID: model.jid)
            CODChatListRealmTool.removeChatList(id: model.id)
            self.chatListArr.removeAll(model)
            self.tableView.reloadData()
            
            //删除会话的时候要去通知”呼叫“模块更新列表
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadCallVC), object: nil, userInfo:nil)
            NotificationCenter.default.post(name: NSNotification.Name.init(kReloadRedPoint), object: nil, userInfo:nil)
        }
        
        
    }
    
    func actionSession(sessionStr:String, indexPath:IndexPath) {
        self.currentIndexPath = indexPath
        
        let model = self.chatListArr[indexPath.row]
        
        if model.id == CloudDiskRosterID {
            let dict = ["name":COD_changePerson,
                        "requester":UserManager.sharedInstance.jid,
                        "setting":["xhassstickytop":!UserManager.sharedInstance.xhassstickytop]] as [String : Any]
            let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting_V2, actionDic: dict as NSDictionary)
            XMPPManager.shareXMPPManager.xmppStream.send(iq)
        }else if model.id == NewFriendRosterID {
            if sessionStr.contains(COD_Mute){
                let dict = ["name":COD_changePerson,
                            "requester":UserManager.sharedInstance.jid,
                            "setting":["xhnfmute":!UserManager.sharedInstance.xhnfmute]] as [String : Any]
                let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting_V2, actionDic: dict as NSDictionary)
                XMPPManager.shareXMPPManager.xmppStream.send(iq)
            }else if sessionStr.contains(COD_Stickytop){
                let dict = ["name":COD_changePerson,
                            "requester":UserManager.sharedInstance.jid,
                            "setting":["xhnfsticktop":!UserManager.sharedInstance.xhnfsticktop]] as [String : Any]
                let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting_V2, actionDic: dict as NSDictionary)
                XMPPManager.shareXMPPManager.xmppStream.send(iq)
            }

        }else {
            var dict = ["requester":UserManager.sharedInstance.jid,
                        "itemID":model.id] as [String : Any]
            
            switch model.chatTypeEnum {
            case .groupChat:
                dict["name"] = COD_changeGroup
                if let groupChat = model.groupChat {
                    dict["setting"] = [sessionStr: !(groupChat.value(forKey: sessionStr) as! Bool)]
                }else{
                    dict["setting"] = [sessionStr: false]
                }
                
            case .privateChat:
                dict["name"] = COD_changeChat
                if let contact = model.contact {
                    dict["setting"] = [sessionStr: !(contact.value(forKey: sessionStr) as! Bool)]
                }else{
                    dict["setting"] = [sessionStr: false]
                }
                
            case .channel:
                //TODO: 频道对应处理
//                dict["name"] = COD_changeChat
//                if let contact = model.channelChat {
//                    dict["setting"] = [sessionStr: !(channel.value(forKey: sessionStr) as! Bool)]
//                }else{
//                    dict["setting"] = [sessionStr: false]
//                }
                if let channel = model.channelChat {
                    
                    if sessionStr == COD_Mute {
                        XMPPManager.shareXMPPManager.channelSetting(roomID: model.channelChat?.roomID ?? 0, mute: !(channel.value(forKey: sessionStr) as! Bool))
                    }else if sessionStr == COD_Stickytop {
                        XMPPManager.shareXMPPManager.channelSetting(roomID: model.channelChat?.roomID ?? 0, stickytop: !(channel.value(forKey: sessionStr) as! Bool))
                    }
                    
                    
                }
                return
            }

            let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting, actionDic: dict as NSDictionary)
            XMPPManager.shareXMPPManager.xmppStream.send(iq)
        }
    }
    
}

extension ChatViewController{
    
    //聊天的cell
    func getChatCell(indexPath: IndexPath) -> UITableViewCell {
        let cell : ChatListCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ChatListCell
        cell.delegate = self
        let model = chatListArr[indexPath.row]
        if indexPath.row == chatListArr.count - 1 || indexPath.row == self.stickyTopCount-1 {  // 置顶部分也需要设置最宽分隔线
            cell.isLast = true
        }else{
            cell.isLast = false
        }
        cell.model = model
        
        if model.id <= 0 {
            if model.id == CloudDiskRosterID  {
                cell.imgView.image = UIImage(named: "cloud_disk_icon")
                cell.isReadImageView.image = UIImage.init(named: "list_blue_Haveread")
            }else if model.id == RobotRosterID{
                cell.imgView.image = UIImage.helpIcon()
                cell.isReadImageView.image = UIImage.init(named: "list_blue_Haveread")
            }else if model.id == NewFriendRosterID {
                cell.imgView.image = UIImage(named: "chat_new_friend_icon")
                cell.isReadImageView.image = nil
            }
            
        }else{
            var imgUrl = model.icon
            
            if imgUrl == "" {
                imgUrl =  model.icon
            }
            
//            CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: imgUrl) { (image) in
//                cell.imgView.image = image
//            }
            cell.imgName = imgUrl /*imgUrl.getHeaderImageFullPath(imageType: 0)*/
        }
        if model.id == NewFriendRosterID {
            cell.title = NSLocalizedString("新的朋友", comment: "")
            cell.stickyTop = UserManager.sharedInstance.xhnfsticktop

        }else{
            cell.title = model.title
            cell.stickyTop = model.stickyTop

        }
        
        return cell
    }
}

//cell的点击事件
extension ChatViewController{
    
    func chatCellSelected(indexPath: IndexPath) {
        
        let listModel: CODChatListModel = chatListArr[indexPath.row]
        
        if listModel.id == NewFriendRosterID {
            let ctl = Xinhoo_RosterRequestListViewController(nibName: "Xinhoo_RosterRequestListViewController", bundle: Bundle.main)
            ctl.unRead = listModel.count
            ctl.chatListModel = listModel
            self.navigationController?.pushViewController(ctl, animated: true)
            return
        }
        
        let msgCtl = MessageViewController()
        msgCtl.newMessageCount = listModel.count
        
        switch listModel.chatTypeEnum {
        case .privateChat:
            msgCtl.chatType = .privateChat
            msgCtl.title = NSLocalizedString(listModel.title, comment: "")
            if let jid = listModel.contact?.jid {
                msgCtl.toJID = jid
            }
            msgCtl.chatId = listModel.id
            msgCtl.isMute = listModel.contact!.mute
            
        case .groupChat:
            
            msgCtl.chatType = .groupChat
            msgCtl.roomId = String(format: "%d", (listModel.groupChat?.roomID) ?? 0)
            
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
            msgCtl.isMute = listModel.groupChat!.mute
            
        case .channel:
            
            msgCtl.chatType = .channel
            msgCtl.roomId = String(format: "%d", (listModel.channelChat?.roomID) ?? 0)
            msgCtl.channelModel = listModel.channelChat
            
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
            
            if let channelChatTemp = listModel.channelChat {
                msgCtl.toJID = String(channelChatTemp.jid)
            }
            msgCtl.chatId = listModel.id
            msgCtl.isMute = listModel.channelChat?.mute ?? false
        }
        
        self.navigationController?.pushViewController(msgCtl, animated: true)
        
    }
    
    
    
}

extension ChatViewController{
    
    func imageWithUIView(view: UIView) -> UIImage? {
        let s = view.bounds.size
        UIGraphicsBeginImageContextWithOptions(s, false, UIScreen.main.scale)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }
        view.layer.render(in: ctx)
        let tImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tImage
    }
}
