//
//  CODChatMessageDisplayView+CellAction.swift
//  COD
//
//  Created by 1 on 2019/5/31.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

extension CODChatMessageDisplayView{
    
    func pushToVideocallVC(message: CODMessageModel, fromMe: Bool) {
//        self.dismissMenu()
        if self.delegate != nil {
            self.delegate?.videoCall(message: message, fromMe: fromMe)
        }
    }
    func pushToPictrueVC(message: CODMessageModel,imageView: UIImageView) {
//        self.dismissMenu()
        if self.delegate != nil {
            
            self.stopAudioPlayer()
            self.delegate?.photoClick(message: message, imageView: imageView)
        }
    }
    
    func pushToVoideVC(message:CODMessageModel,imageView: UIImageView) {

        if self.delegate != nil {
            
            self.stopAudioPlayer()
            self.delegate?.voideClick(message: message, imageView: imageView)
        }
    }
    
    func stopAudioPlayer() {
        if CODAudioPlayerManager.sharedInstance.isPlaying() {
//            if let cell = CODAudioPlayerManager.sharedInstance.playCell as? CODZZS_AudioLeftTableViewCell {
//                cell.playAudio()
//            }else if let cell = CODAudioPlayerManager.sharedInstance.playCell as? CODZZS_AudioRightTableViewCell {
//                cell.playAudio()
//            }else if CODAudioPlayerManager.sharedInstance.playModel != nil{
            
                CODAudioPlayerManager.sharedInstance.stop()
                try! Realm.init().write {
                     CODAudioPlayerManager.sharedInstance.playModel!.isPlay = false
                     CODAudioPlayerManager.sharedInstance.playModel = nil
                }
            
            if let indexs = self.tableView.indexPathsForVisibleRows {
            
                self.tableView.reloadRows(at: indexs, with: .none)
            }
//            }
        }
    }
    
    func playAudio(message:CODMessageModel?,showCell: CODAudioChatCell ) {
        showCell.unPlayVeiw.isHidden = true
        if self.delegate != nil {
            self.delegate?.audioClick(message: message ?? CODMessageModel(), showCell: showCell)
        }

    }
    
    func pushToMessageVC(contactModel :CODContactModel)  {
        let msgCtl = MessageViewController()
        msgCtl.toJID = contactModel.jid
        msgCtl.chatId = contactModel.rosterID
        msgCtl.title = contactModel.getContactNick()
        msgCtl.isMute = contactModel.mute
        let vc = self.viewForController(view:self)
//        vc?.navigationController?.setViewControllers([(vc?.navigationController?.viewControllers.first)!,msgCtl], animated: true)
        vc?.navigationController?.popViewController(animated: true)
        vc?.navigationController?.pushViewController(msgCtl, animated: true)
        
    }
    
    func pushToBussnissPersonDetailVC(model: CODMessageModel)  {
        let vc = self.viewForController(view:self)
        
        if let jidString = model.businessCardModel?.jid {
            if jidString == UserManager.sharedInstance.jid || jidString == UserManager.sharedInstance.loginName {
                let msgCtl = MessageViewController()
                msgCtl.chatType = .privateChat
                msgCtl.toJID = kCloudJid + XMPPSuffix
                msgCtl.chatId = CloudDiskRosterID
                msgCtl.title = NSLocalizedString("我的云盘", comment: "")
                vc?.navigationController?.pushViewController(msgCtl, animated: true)
                return
            }
            
            if let contactModel = CODContactRealmTool.getContactByJID(by: jidString), contactModel.isValid == true  {
                CustomUtil.pushToPersonVC(contactModel: contactModel)
            }else{
                CustomUtil.pushToStrangerVC(type: .cardType, businessCardModel: model.businessCardModel)
            }
        }
    }
    
    func cloudPushPersonDetailVC(model: CODMessageModel,isFromMe: Bool) {
        
        if isFromMe {
            return
        }
        //点击进入\(kApp_Name)小助手
        let vc = self.viewForController(view:self)
        let jid = model.fw
        if jid.contains("cod_60000000")  {
            vc?.navigationController?.pushViewController(CODLittleAssistantDetailVC())
        }else if let contactModel = CODContactRealmTool.getContactByJID(by: jid), contactModel.isValid {
        
            if contactModel.isValid == true {
                CustomUtil.pushToPersonVC(contactModel: contactModel, messageModel: model)
            }else{
            
                if CODChatListRealmTool.getChatList(id: model.roomId)?.groupChat?.isICanCheckUserInfo() ?? true == false  {
                    CODProgressHUD.showWarningWithStatus(NSLocalizedString("根据群组设置，您无法查看他的个人信息", comment: ""))
                    return
                }else{
                    CustomUtil.pushToStrangerVC(type: .cardType, contactModel: contactModel)
                }
            }
        }else{
        
            if CODChatListRealmTool.getChatList(id: model.roomId)?.groupChat?.isICanCheckUserInfo() ?? true == false  {
                CODProgressHUD.showWarningWithStatus(NSLocalizedString("根据群组设置，您无法查看他的个人信息", comment: ""))
                return
            }else{
                
                CustomUtil.searchUserBID(jid: jid, pushToVCWithSourceType: .groupType)
                
//                self.isPushDetail = true
//                var dict:NSDictionary? = [:]
//                dict = ["name":COD_searchUserBID,
//                        "requester":UserManager.sharedInstance.jid,
//                        "search":[["content":jid]]]
//
//                let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.get, xmlns: COD_com_xinhoo_contacts, actionDic: dict!)
//                XMPPManager.shareXMPPManager.xmppStream.send(iq)
            }
        }
    
                    
    }
    
    func pushPersonDetailVC(model: CODMessageModel,isFromMe: Bool) {
        
        if isFromMe {
            return
        }
        //点击进入\(kApp_Name)小助手
        let vc = self.viewForController(view:self)
        
        if vc?.title?.contains("\(kApp_Name)小助手") ?? false{
            
            vc?.navigationController?.pushViewController(CODLittleAssistantDetailVC())
        }else{
            
            var jid = ""
            
            if model.fromWho.contains(XMPPSuffix) {
                jid = model.fromWho
            }else{
                jid = model.fromWho+XMPPSuffix
            }
            
            if jid == UserManager.sharedInstance.jid || jid == UserManager.sharedInstance.loginName {
                let msgCtl = MessageViewController()
                msgCtl.chatType = .privateChat
                msgCtl.toJID = kCloudJid + XMPPSuffix
                msgCtl.chatId = CloudDiskRosterID
                msgCtl.title = NSLocalizedString("我的云盘", comment: "")
                vc?.navigationController?.pushViewController(msgCtl, animated: true)
                return
            }
            
            if let contactModel = CODContactRealmTool.getContactByJID(by: jid), contactModel.isValid {
                
                if contactModel.isValid == true {
                    CustomUtil.pushToPersonVC(contactModel: contactModel, messageModel: model)
                }else{
                    
                    if CODChatListRealmTool.getChatList(id: model.roomId)?.groupChat?.isICanCheckUserInfo() ?? true == false  {
                        CODProgressHUD.showWarningWithStatus(NSLocalizedString("根据群组设置，您无法查看他的个人信息", comment: ""))
                        return
                    }
                    
                    let memberId = CODGroupMemberModel.getMemberId(roomId: model.roomId, userName:model.fromWho)
                    if let member = CODGroupMemberRealmTool.getMemberById(memberId){
                        CustomUtil.pushToStrangerVC(type: .groupType, memberModel: member)
                    }else{
                        CustomUtil.pushToStrangerVC(type: .cardType, contactModel: contactModel)
                    }
                }
            }else{
                
                if CODChatListRealmTool.getChatList(id: self.chatId)?.groupChat?.isICanCheckUserInfo() ?? true == false {
                    CODProgressHUD.showWarningWithStatus(NSLocalizedString("根据群组设置，您无法查看他的个人信息", comment: ""))
                    return
                }
                
                let memberID = CODGroupMemberModel.getMemberId(roomId: model.roomId, userName: model.fromWho)
                if let member = CODGroupMemberRealmTool.getMemberById(memberID) {
                    
                    CustomUtil.pushToStrangerVC(type: .groupType, memberModel: member)
                }else{
                    CustomUtil.searchUserBID(jid: jid, pushToVCWithSourceType: .groupType)
                }
            }
        }
    }
    
    func pushLocationDetail(message:CODMessageModel?) {
        
        let vc = self.viewForController(view:self)
        let locationVC = CODLocationDetailVC()
        locationVC.locationModel = message?.location ?? LocationInfo()
        vc?.navigationController?.pushViewController(locationVC)
        
    }
    
    func addFriend(model: CODMessageModel) {
        let vc = self.viewForController(view:self)
        
        let chatModel = CODChatPersonModel()
        let modelType: EMMessageBodyType  = EMMessageBodyType(rawValue: model.msgType) ?? .text
        let verificationVC = CODVerificationApplicationVC()
        
        let stringArray:Array<String> = model.toJID.components(separatedBy: "@")

        if modelType == .businessCard {
            if let stringArray:Array<String> = model.businessCardModel?.jid.components(separatedBy: "@"),stringArray.count > 0 {
                chatModel.username = stringArray[0]
            }
            verificationVC.type = .cardType
        }else if stringArray.count > 0 {
            chatModel.username = stringArray[0]
            verificationVC.type = .searchType

        }
      
        verificationVC.model =  chatModel
        vc?.navigationController?.pushViewController(verificationVC)
        
    }
}

extension CODChatMessageDisplayView{
    
    func viewForController(view:UIView)->UIViewController?{
        var next:UIView? = view
        repeat{
            if let nextResponder = next?.next, nextResponder is UIViewController {
                return (nextResponder as! UIViewController)
            }
            next = next?.superview
        }while next != nil
        return nil
    }
    
}
