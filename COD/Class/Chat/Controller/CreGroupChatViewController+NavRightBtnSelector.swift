//
//  CreGroupChatViewController+NavRightBtnSelector.swift
//  COD
//
//  Created by XinHoo on 2019/4/3.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

extension CreGroupChatViewController {
    
    func createGroupChat() {
        if let selectedArray = selectedArray {
            let count = selectedArray.count + self.globalSearchSelectedArr.count
            guard count > 0 else {
                CODProgressHUD.showErrorWithStatus("创建群组请至少选择1人")
                return
            }
            
            let ctl = CODSetGroupNameAndAvatarVC()
            ctl.dataSource = self.selectedArray!
            ctl.searchUsers = self.globalSearchSelectedArr
            ctl.allDataSource = self.groupMemberSelectView.collectionSource
            ctl.createGroupSuccess = { [weak self] (_ groupChatModel : CODGroupChatModel) in
                guard let self = self else {
                    return
                }
                if self.createGroupSuccess != nil{
                    self.createGroupSuccess(groupChatModel)
                }
            }
            self.navigationController?.pushViewController(ctl, animated: true)
        }
    }
    
    
    func addGroupMember() {
        
        let count = selectedArray?.count ?? 0 + self.globalSearchSelectedArr.count
        if count <= 0 {
            CODProgressHUD.showErrorWithStatus("至少选择一人")
            return
        }
//            CODProgressHUD.showWithStatus(nil)
        

        XMPPManager.shareXMPPManager.addGroupMember(members: selectedArray as? Array<CODContactModel> ?? [],
                                                    searchUsers: self.globalSearchSelectedArr,
                                                    roomId: self.groupChatModel?.chatId ?? 0,
                                                    chatType: self.groupChatModel?.chatTypeEnum ?? .groupChat,
                                                    success: { (model, nameStr) in
            if nameStr == "inviteMember" {
                
                guard let data = model.data else {
                    CODProgressHUD.showErrorWithStatus(NSLocalizedString("添加成员失败，请重新添加", comment: ""))
                    return
                }
                self.addMember(data)
                
                
            }
            
        }) { (error) in
            switch error.code {
            case 30044:
                CODProgressHUD.showErrorWithStatus("已启动“禁止邀请入群”群成员禁止邀请朋友入群，仅管理员可进行邀请。")
            case 30041:
                CODProgressHUD.showErrorWithStatus("该用户已加入群聊")
            case 30004:
                CODProgressHUD.showErrorWithStatus("群用户数量已超出限制")
            case 30035, 30032:
                CODProgressHUD.showErrorWithStatus("你已不是管理员，操作失败")
            default:
                break
            }
            print("失败：\(error.msg ?? "空")")
        }
    }
    
    func subtractMember()  {
        if let selectedArray = selectedArray {
            if selectedArray.count <= 0 {
                CODProgressHUD.showErrorWithStatus("至少选择一人")
                return
            }
//            CODProgressHUD.showWithStatus(nil)
            
            XMPPManager.shareXMPPManager.subtractGroupMember(members: selectedArray as! Array<CODGroupMemberModel>,
                                                             roomId: self.groupChatModel?.chatId ?? 0,
                                                             chatType: self.groupChatModel?.chatTypeEnum ?? .groupChat,
                                                             success: { (model, nameStr) in
                
                if nameStr == "kickOutMember" {
                    
                    print("success：\(model.data ?? "空")")
                    
                    NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
                    self.navigationController?.popViewController(animated: true)
                    if self.subtractMemberSuccess != nil{
                        self.subtractMemberSuccess()
                    }
                }
                
                
            }) { (error) in
                switch error.code {
                case 30042:
                    CODProgressHUD.showErrorWithStatus("该用户已被移除群聊")
                default:
                    CODProgressHUD.showSuccessWithStatus("删除成员失败")
                }
                
                print("失败：\(error.msg ?? "空")")
            }
        }
    }
    
    fileprivate func addMember(_ data: Any) {
        
        if let channelModel = self.channelModel {
            let members = JSON(data)["data"]["channelMemberVoList"].arrayValue.map { (member) -> CODGroupMemberModel? in
                let memberTemp = CODGroupMemberModel()
                memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member.dictionaryObject)
                if memberTemp.jid == UserManager.sharedInstance.jid {
                    return nil
                }
                memberTemp.memberId = String(format: "%d%@", channelModel.roomID, memberTemp.username)
                return memberTemp
            }.compactMap{$0}
            if members.count <= 0 {
                self.navigationController?.popViewController(animated: true, {
                    CODProgressHUD.showErrorWithStatus(NSLocalizedString("根据对方的隐私设置，您无法邀请对方加入频道", comment: ""))
                })
                return
            }else{
                channelModel.addMembers(members)
            }
            
        }else{
            if JSON(data)["data"].arrayValue.count <= 0 {
                self.navigationController?.popViewController(animated: true, {
                    CODProgressHUD.showErrorWithStatus(NSLocalizedString("根据对方的隐私设置，您无法邀请对方加入群聊", comment: ""))
                })
                return
            }
        }
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func createChannelNextStep() {
        
        if (selectedArray == nil || selectedArray?.count == 0) {
            
            self.navigationController?.popToRootViewController(animated: true)
            if let channelModel = self.channelModel {
                self.createChannelSuccess?(channelModel)
            }
            
            return
            
        }
        
        CODProgressHUD.showWithStatus(nil)
        
        guard let channelModel = self.channelModel else {
            CODProgressHUD.showSuccessWithStatus(NSLocalizedString("频道创建失败，请重新创建", comment: ""))
            return
        }
        
        XMPPManager.shareXMPPManager.addGroupMember(members: selectedArray as? Array<CODContactModel> ?? [],
                                                    searchUsers: self.globalSearchSelectedArr,
                                                    roomId: channelModel.roomID,
                                                    chatType: channelModel.chatTypeEnum,
                                                    success: { (model, nameStr) in
            
            if nameStr != "inviteMember" {
                return
            }
            
            CODProgressHUD.dismiss()
            guard let data = model.data else {
                CODProgressHUD.showSuccessWithStatus(NSLocalizedString("频道创建失败，请重新创建", comment: ""))
                return
            }
            
            self.addMember(data)
            
            self.navigationController?.popToRootViewController(animated: true)
            if self.createChannelSuccess != nil{
                self.createChannelSuccess(channelModel)
            }
            
        }) { (model) in
            CODProgressHUD.showErrorWithStatus(model.msg)
        }
        
    }
    
    func addAdmins() {
        
    }
    
    func selectedRemindsList() {
        if self.selectedRemindsSuccess != nil {
            self.selectedRemindsSuccess(self.selectedArray as? [CODContactModel] ?? [])
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func sendMultipleCall() {
        
        let msgType = (self.ctlType == .multipleVoice) ? COD_call_type_voice : COD_call_type_video
        
        if let array = self.selectedArray as? [CODGroupMemberModel] {
            
            let memberList = array.map{ $0.jid}
            
            let  dict:NSDictionary = ["name":COD_request,
                                      "requester":UserManager.sharedInstance.jid,
                                      "memberList":memberList,
                                      "chatType":"2",
                                      "roomID":self.roomID as Any,
                                      "msgType":msgType]
            
            let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_voicerequest, actionDic: dict)
            XMPPManager.shareXMPPManager.xmppStream.send(iq)
            
        }
        
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    func sendRequestMoreMultipleCall() {
        
        let msgType = (self.ctlType == .requestmore_multipleVoice) ? COD_call_type_voice : COD_call_type_video
        
        if let array = self.selectedArray as? [CODGroupMemberModel] {
            
            let memberList = array.map{ $0.jid}
            
            let  dict:NSDictionary = ["name":COD_requestmore,
                                      "requester":UserManager.sharedInstance.jid,
                                      "memberList":memberList,
                                      "room":self.room,
                                      "msgType":msgType]
            
            let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_voicerequest, actionDic: dict)
            XMPPManager.shareXMPPManager.xmppStream.send(iq)
            
        }
        
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
}
