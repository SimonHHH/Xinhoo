//
//  CODGroupMemberOnlineManger.swift
//  COD
//
//  Created by Sim Tsai on 2020/9/17.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

class CODGroupMemberOnlineManger: XMPPStreamDelegate {
    
    static let `default` = CODGroupMemberOnlineManger()
    
    func setup() {
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: .messageQueue)
        
    }
    
    func getGroupMembersOnlineTime(roomID: String, response: XMPPManager.XMPPIQResponse? = nil) {
        
        let dict = ["name":COD_GroupMembersOnlineTime,
        "requester":UserManager.sharedInstance.jid,
        "roomID":roomID] as [String : Any]
        
        
        XMPPManager.shareXMPPManager.getRequest(param: dict, xmlns: COD_com_xinhoo_groupChat, response: response)
        
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        
        CustomUtil.analyticxXML(iq: iq) { (actionDic, infoDic) in
            guard let infoDic = infoDic else {
                return
            }
            
            if UserManager.sharedInstance.isLogin != true {
                return
            }
            
            if actionDic["name"] as? String == COD_GroupMembersOnlineTime {
                
                DispatchQueue.groupMembersOnlineTimeQueue.async {
                    
                    guard let data = infoDic["data"] as? NSArray else {
                        return
                    }
                    
                    var tempMemberArr: Array<CODGroupMemberModel> = []
                    
                    guard let roomID = actionDic["roomID"] as? String else {
                        return
                    }
                    
                    for object in data {
                        guard let jsonStr = object as? NSString else {
                            return
                        }
                                                
                        let item = CustomUtil.dictionaryWithString(jsonStr: jsonStr)
                        guard let obj = CODGroupMemberOnlineModel.deserialize(from: item) else {
                            return
                        }
                        let memberId = CODGroupMemberModel.getMemberId(roomId: roomID.int ?? 0, userName: obj.userName)
                        
                        if let member = CODGroupMemberRealmTool.getMemberById(memberId) {
                            var newMember = CODGroupMemberModel()
                            newMember = member.mutableCopy() as! CODGroupMemberModel
                            newMember.loginStatus = obj.active
                            newMember.lastLoginTimeVisible = obj.lastLoginTimeVisible
                            newMember.lastlogintime = obj.lastlogintime
                            if obj.active == "ONLINE" {
                                newMember.lastlogintime = Int(Date.milliseconds)
                            }
                            if !obj.lastLoginTimeVisible {
                                newMember.lastlogintime = 0
                            }
                            
                            tempMemberArr.append(newMember)
                        }
                        
                    }
                    
                    try! Realm().safeWrite {
                        try! Realm().add(tempMemberArr, update: .modified)
                    }
                    
                }
            }
            
            
        }
        return true
    }
    
}
