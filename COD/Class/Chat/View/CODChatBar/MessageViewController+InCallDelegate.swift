//
//  MessageViewController+InCallDelegate.swift
//  COD
//
//  Created by 1 on 2020/9/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

extension MessageViewController: CODGroupInviteInCallViewDelegate{
    func cancelCallClick() {
        self.inviteCallView.isHidden = true
    }
    
    func joinCallClick() {
        self.inviteCallView.isHidden = true
    }
    

}

extension MessageViewController: CODGroupInCallViewDelegate{
    func inCallClick() {
//        self.inviteCallView.isHidden = false
        
        if let currentRoomJid = CustomUtil.getRoomJid() {
            
            if currentRoomJid == self.toJID {
                
                let delegate = UIApplication.shared.delegate as! AppDelegate
                if let block = delegate.floatVoiceWindow?.floatViewTapBlock {
                
                    block()
                }else{
                    CustomUtil.removeRoomJid()
                }
                
                
            }else{
                CODAlertView_show(NSLocalizedString("当前正在语音通话，无法加入", comment: ""))
            }
            
            return
        }
        
        let alertView = UIAlertController(title: NSLocalizedString("是否加入语音通话？", comment: ""), message: nil, preferredStyle: .alert)
        alertView.addAction(title: NSLocalizedString("取消", comment: ""), style: .default, isEnabled: true) { (action) in
            
        }
        alertView.addAction(title: NSLocalizedString("加入", comment: ""), style: .default, isEnabled: true) { (action) in
            
            let dict:NSDictionary = ["name":COD_accept,
                                     "requester":UserManager.sharedInstance.jid,
                                     "receiver":self.chatListModel?.jid ?? "",
                                     "room":self.chatListModel?.groupRtcRoomId ?? "",
                                     "chatType":"2",
                                     "roomID":self.chatListModel?.groupChat?.roomID ?? "",
                                     "msgType":"voice"]
            
            let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_voicerequest, actionDic: dict)
            XMPPManager.shareXMPPManager.xmppStream.send(iq)
            
        }
        self.present(alertView, animated: true, completion: nil)
    }
    

}
