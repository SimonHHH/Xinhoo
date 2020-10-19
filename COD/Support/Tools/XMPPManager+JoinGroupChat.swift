//
//  XMPPManager+JoinGroupChat.swift
//  COD
//
//  Created by XinHoo on 2019/4/3.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import XMPPFramework

extension XMPPManager {
    
    func joinGroupChatWith(groupJid: String) {
        
//        if let jid = XMPPJID(string: groupJid) {
//            autoreleasepool(invoking: { () -> () in
//                let storage = XMPPRoomCoreDataStorage.sharedInstance()
//                
//                let room = XMPPRoom.init(roomStorage: storage!, jid: jid)
//                // 激活
//                room.activate(XMPPManager.shareXMPPManager.xmppStream)
//                //            // 存放在字典中
//                //            roomDict[groupJid] = room
//                
//                // 加入房间
//                room.join(usingNickname: "\(UserManager.sharedInstance.jid)/" + self.xmppStream.myJID!.resource!, history: nil)
//                // 设置代理
//                //            room.addDelegate(self, delegateQueue: DispatchQueue.main)
//            })
//            
//            
//        }else{
//            CCLog("jid创建失败")
//        }
        
    }
    
    func leaveGroupChatWith(_ groupJid: String) {
//        if let room = self.roomDict[groupJid] {
//            room.leave()
//            room.deactivate()
//            room.removeDelegate(self, delegateQueue: DispatchQueue.main)
//        }
    }

}

extension XMPPManager: XMPPRoomDelegate{
    func xmppRoomDidJoin(_ sender: XMPPRoom) {
        print("加入房间 \(sender.roomJID)")
    }
    
    func xmppRoomDidLeave(_ sender: XMPPRoom) {
        print("离开房间")
    }
    
    func xmppRoomDidCreate(_ sender: XMPPRoom) {
        print("创建房间")
    }
    
    func xmppRoomDidDestroy(_ sender: XMPPRoom) {
        print("销毁房间")
    }
    
    func xmppRoom(_ sender: XMPPRoom, didReceive message: XMPPMessage, fromOccupant occupantJID: XMPPJID) {
//        print("收到消息！！！：\(message)")
    }
    
    func xmppRoom(_ sender: XMPPRoom, didConfigure iqResult: XMPPIQ) {
        print("设定群组")
    }
    
    func xmppRoom(_ sender: XMPPRoom, occupantDidUpdate occupantJID: XMPPJID, with presence: XMPPPresence) {
        print("成员变动")
    }
    
    func xmppMUC(_ sender: XMPPMUC!, roomJID: XMPPJID!, didReceiveInvitation message: XMPPMessage!) {
        print("收到加入聊天室邀请 :\(String(describing: roomJID)) send invitation")
    }
    

    func xmppMUC(_ sender: XMPPMUC!, didDiscoverRooms rooms: [Any]!, forServiceNamed serviceName: String!) {
        print("取得房间列表")
    }
    
    func xmppRoom(_ sender: XMPPRoom, occupantDidLeave occupantJID: XMPPJID, with presence: XMPPPresence) {
//        print("有人退出群组")
    }
}
