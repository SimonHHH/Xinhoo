//
//  MessageViewController+ChannelAtion.swift
//  COD
//
//  Created by 1 on 2019/11/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import LGAlertView
extension MessageViewController{

    @objc func bottomNoticeAction(button: UIButton){
        if CustomUtil.judgeJoinChannelRoom(roomId: self.chatId) {
            XMPPManager.shareXMPPManager.channelSetting(roomID: self.chatId, mute: !self.channelBottomView.isSelected)
        }else{
            self.requestJoinChannel(linkString: self.channelModel?.shareLink ?? "", inviter: UserManager.sharedInstance.jid, add: true)
        }
    }
    
    func requestJoinChannel(linkString: String, inviter: String, add: Bool) {

        if self.channelModel?.channelTypeEnum == CODChannelType.CPRI {

            let channelView = DeleteChatListModelView.initWitXib(imgID: self.channelModel?.grouppic, desc: self.channelModel?.descriptions, subDesc: String(format: NSLocalizedString("%d 位订阅者", comment: ""), self.channelModel?.member.count ?? 0))

            LGAlertView(viewAndTitle: nil, message: nil, style: .actionSheet, view: channelView,
                        buttonTitles: [NSLocalizedString("加入", comment: "")], cancelButtonTitle: NSLocalizedString("取消", comment: ""), destructiveButtonTitle: nil,
                        actionHandler: { (alertView, index, buttonTitle) in
                            
                            if index == 0 {
                                XMPPManager.shareXMPPManager.joinGroupAndChannel(linkString: linkString, inviter: inviter, add: add)
                            }
                            
                }, cancelHandler: nil, destructiveHandler: nil).showAnimated()
            
        }else{
            
            CODProgressHUD.showWithStatus(nil)
            XMPPManager.shareXMPPManager.joinGroupAndChannel(linkString: linkString, inviter: inviter, add: add) { _ in
                
                CODProgressHUD.dismiss()
                
            }
        }
        
    }
    

    
    func updateTopMessageView() {
        if self.isSearch {
            self.topMessageView.isHidden = true
        }else{
            self.updateTopMessage()
            if self.chatType == .channel{
                let channelResult = CustomUtil.judgeInChannelRoom(roomId: self.chatId)
                if channelResult.isManager {
                    self.topMessageView.deleteBtn.isHidden = false
                }else{
                    self.topMessageView.deleteBtn.isHidden = true
                }
            }else{
                if CustomUtil.getIsManager(roomId: self.chatId, userName: UserManager.sharedInstance.jid){
                    self.topMessageView.deleteBtn.isHidden = false
                }else{
                    self.topMessageView.deleteBtn.isHidden = true
                }
            }
        }
        self.updateMessageView()
        self.updateInCallView()
    }
    
    func updateInCallView() {
        if self.isSearch {
            self.inCallView.isHidden = true
        }else{
          if let listModel = CODChatListRealmTool.getChatList(id: self.chatId){
              if listModel.groupRtc == 0 {
                  
              }
              self.inCallView.isHidden = (listModel.groupRtc == 0) ? true : false
              
              if !self.topMessageView.isHidden  && !self.inCallView.isHidden{
                  self.topMessageView.snp.remakeConstraints { (make) in
                      make.top.equalTo(self.inCallView.snp.bottom)
                      make.left.right.equalToSuperview()
                      make.height.equalTo(51)
                  }
              }else{
                  self.topMessageView.snp.remakeConstraints { (make) in
                      make.top.left.right.equalToSuperview()
                      make.height.equalTo(51)
                  }
                  
              }
          }
        }
        
        self.updateMessageView()
    }
    
    func updateMessageView() {
        
        self.messageView.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview()
            if !self.topMessageView.isHidden  {
                make.top.equalTo(self.topMessageView.snp.bottom)
            }else if !self.inCallView.isHidden {
                make.top.equalTo(self.inCallView.snp.bottom)
            }else{
                make.top.equalToSuperview()
            }
            if !self.editView.isHidden {
                make.bottom.equalTo(self.editView.snp.top).offset(0)
            }else if !self.tipView.isHidden {
                make.bottom.equalTo(self.tipView.snp.top).offset(0)
            }else{
                make.bottom.equalTo(self.chatBar.snp.top).offset(0)
            }
        }
    }

}
