//
//  CODChannelModelTools.swift
//  COD
//
//  Created by Sim Tsai on 2020/1/1.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa

extension CODChannelModel {
    
    convenience init(jsonModel: CODChannelHJsonModel) {
        
        self.init()
        roomID = jsonModel.roomID
        self.updateChannel(jsonModel: jsonModel)
        
    }
    
    func addMembers(_ members: [CODGroupMemberModel]) {
        
        do {
            
            let defaultRealm = try Realm()
            
            let write = {
                

                
                defaultRealm.add(members, update: .all)
                
                self.member.removeAll()
                
                let results = defaultRealm.objects(CODGroupMemberModel.self).filter("memberId contains '\(self.roomID.string)'")
                self.member.append(objectsIn: results)
                
            }
            
            if defaultRealm.isInWriteTransaction {
                write()
            } else {
                try defaultRealm.write(write)
            }

        } catch {
        }
        
    }
    
    func updateMembersWithContactsList(_ members: [CODGroupMemberModel], roomId: Int) {
        
        do {
            
            let defaultRealm = try Realm()
            
            let result = defaultRealm.objects(CODGroupMemberModel.self).filter("memberId contains %@","\(roomId)")
            
            let write = {
                
                defaultRealm.delete(result)
                
                defaultRealm.add(members, update: .all)
                
                self.member.removeAll()
                
                self.member.append(objectsIn: members)
                
            }
            
            if defaultRealm.isInWriteTransaction {
                write()
            } else {
                try defaultRealm.write(write)
            }

        } catch {
        }
        
    }
    
    
    public func getMember(by userName: String) -> CODGroupMemberModel? {
//        return self.member.filter("memberId = '\(self.roomID)\(userName)'").first
        return self.member.filter { (model) -> Bool in
            return model.memberId == "\(self.roomID)\(userName)"
        }.first
    }
    
    ///群组模糊查询
    public class func getGroupChatByKeyword(word : String) -> [CODChannelModel]? {
        let list = self.getAllValidGroupChatList().filter("descriptions contains[c] %@", word)
        var array = Array<CODChannelModel>()
        guard list.count > 0 else {
            print("————————————查询不到群组————-——————")
            return nil
        }
        for group in list {
            array.append(group)
        }
        return array
    }
    
    /// 查询所有的有效的群组
    public class func getAllValidGroupChatList() -> Results<CODChannelModel> {
        return try! Realm().objects(CODChannelModel.self).filter("isValid == \(true)")
    }
    
    public class func getChannel(by id: Int) -> CODChannelModel? {
        return try? Realm().object(ofType: CODChannelModel.self, forPrimaryKey: id)
    }
    
    public class func getChannel(jid: String) -> CODChannelModel? {
        return try? Realm().objects(CODChannelModel.self).filter("jid = %@", jid).first
    }
    
    public func addChannelChat() -> Void {
        do {
            
            let defaultRealm = try Realm()
            
            try defaultRealm.write {
                defaultRealm.add(self, update: .all)
            }
        } catch {
        }

    }
    
    public func addToChatList() -> Void {
        CODChatListModel.insertOrUpdateChannelListModel(by: self, message: nil)
    }
    
    @objc dynamic func delete() {
        
        do {
            
            let defaultRealm = try Realm()
            
            try defaultRealm.write {
                
                CODGroupMemberRealmTool.deleteMember(roomId: self.roomID, jid: UserManager.sharedInstance.jid)
                
                if let chatList = defaultRealm.object(ofType: CODChatListModel.self, forPrimaryKey: self.chatId) {
                    chatList.isInValid = true
                    chatList.channelChat?.isValid = false
                    chatList.stickyTop = false
                }
                
            }
            
        } catch {
        }

    }
    
    func updateMembers(_ members: [CODGroupMemberModel]) {
        
//        let needRemoveMembers = members.filter { $0.isActive != true }
        let needAppendMembers = members.filter { $0.isActive == true }

        self.addMembers(members)

    }
    
    func removeMembers(_ members: [CODGroupMemberModel]) {
        
        do {
            
            let defaultRealm = try Realm()
            
            let write = {
                
                var newMembers: [CODGroupMemberModel] = []
                
                self.member.removeAll()
                for member in members {
                    
                    if let dbMember = defaultRealm.object(ofType: CODGroupMemberModel.self, forPrimaryKey: member.memberId) {
                        newMembers.append(dbMember)
                    }
                
                }
                
                defaultRealm.delete(newMembers)
                
                let results = defaultRealm.objects(CODGroupMemberModel.self).filter("memberId contains '\(self.roomID.string)'")
                self.member.append(objectsIn: results)

            }
            
            if defaultRealm.isInWriteTransaction {
                write()
            } else {
                try defaultRealm.write(write)
            }
            
        } catch {
        }
        
    }
    
    func isAdmin(by jid: String) -> Bool {
        return self.member.filter { (model) -> Bool in
            return model.userpower == 10 || model.userpower == 20
        }
        .contains { (model) -> Bool in
            return model.jid == jid
        }
    }
    
    func isOwner(by jid: String) -> Bool {
        return self.member.filter { (model) -> Bool in
            return model.userpower == 10
        }
        .contains { (model) -> Bool in
            return model.jid == jid
        }
    }
    
    func getMember(jid: String) -> CODGroupMemberModel? {
        return CODGroupMemberRealmTool.getMemberById(CODGroupMemberModel.getMemberId(roomId: roomID, userName: jid))
    }
    
    func isMember(by jid: String) -> Bool {
        
        if let _ = self.getMember(jid: jid) {
            return true
        }
        
        return false
        
    }
    
    func removeMembersByJid(_ members: [CODGroupMemberModel]) {
        
        do {
            
            let defaultRealm = try Realm()
            
            let write = {
                
                for member in members {
                    
                    if let index = self.member.index(of: member) {
                        self.member.remove(at: index)
                    }
                    
                    CODGroupMemberRealmTool.getMembersByJid(member.jid)

                }

                
            }
            
            if defaultRealm.isInWriteTransaction {
                write()
            } else {
                try defaultRealm.write(write)
            }
            
        } catch {
        }
        
    }
    
    public func updateChannel(jsonModel: CODChannelHJsonModel) {
        
        do {
            
            let defaultRealm = try Realm()

            try defaultRealm.write {
                
                name = jsonModel.name
                jid = jsonModel.jid
                
                savecontacts = jsonModel.savecontacts
                timingcleanup = jsonModel.timingcleanup
                descriptions = jsonModel.description
                notice = jsonModel.notice
                naturalname = jsonModel.naturalname
                burn = jsonModel.burn
                mute = jsonModel.mute
                showname = jsonModel.showname
                signmsg = jsonModel.signmsg
                screenshot = jsonModel.screenshot
                stickytop = jsonModel.stickytop
                grouppic = jsonModel.grouppic
                notinvite = jsonModel.notinvite
                userid = jsonModel.userid
                topmsg = jsonModel.topmsg
                channelType = jsonModel.type
            }
            
        } catch {
        }
        
    }
    
    
    public func updateChannel(name: String? = nil, channelType: CODChannelType? = nil, link: String? = nil, notice: String? = nil, stickytop: Bool? = nil, mute: Bool? = nil, savecontacts: Bool? = nil, grouppic: String? = nil, signmsg: Bool? = nil, isValid: Bool? = nil, topmsg: String? = nil) {
        
        do {
            
            let defaultRealm = try Realm()

            try defaultRealm.write {
                
                if let name = name {
                    
                    if let chatList = defaultRealm.object(ofType: CODChatListModel.self, forPrimaryKey: self.chatId) {
                        chatList.title = name
                    }
                    
                    self.descriptions = name
                    
                }
                
                if let channelType = channelType {
                    self.channelTypeEnum = channelType
                }
                
                if let link = link {
                    self.userid = link
                }
                
                if let stickytop = stickytop {
                    if let chatList = defaultRealm.object(ofType: CODChatListModel.self, forPrimaryKey: self.chatId) {
                        chatList.stickyTop = stickytop
                    }
                    self.stickytop = stickytop
                }

                if let notice = notice {
                    self.notice = notice
                }
                
                if let mute = mute {
                    self.mute = mute
                }
                
                if let savecontacts = savecontacts {
                    self.savecontacts = savecontacts
                }
                
                if let grouppic = grouppic {
                    
                    if let chatList = defaultRealm.object(ofType: CODChatListModel.self, forPrimaryKey: self.chatId) {
                        chatList.icon = grouppic
                    }
                    
                    self.grouppic = grouppic
                }
                
                if let signmsg = signmsg {
                    self.signmsg = signmsg
                }
                
                if let isValid = isValid {
                    self.isValid = isValid
                }
                
                if let topmsg = topmsg {
                    self.topmsg = topmsg
                }
                
            }
            
        } catch {
        }

    }
    
    public class func createChanel(roomID: Int, json: JSON) {
        
        let dic = json.dictionaryObject
        
        guard let jsonModel = CODChannelHJsonModel.deserialize(from: json.dictionaryObject) else {
            return
        }
        
        if jsonModel.roomID == 0 {
            return
        }
        
        let channelModel = CODChannelModel.init(jsonModel: CODChannelHJsonModel.deserialize(from: dic)!)
        channelModel.isValid = true
        
        if let memberArr = json["channelMemberVoList"].arrayObject as? [Dictionary<String,Any>] {
            
            let members = memberArr.map { member -> CODGroupMemberModel in
                let memberTemp = CODGroupMemberModel()
                memberTemp.jsonModel = CODGroupMemberHJsonModel.deserialize(from: member)
                memberTemp.memberId = String(format: "%d%@", channelModel.roomID, memberTemp.username)
                return memberTemp
            }
            channelModel.member.append(objectsIn: members)
        }
        channelModel.customName = CODGroupChatModel.getCustomGroupName(memberList: channelModel.member)
        
        channelModel.createDate = String(format: "%.0f", Date.milliseconds)
        
        CODChatListModel.insertOrUpdateChannelListModel(by: channelModel, message: nil)
        
        
    }
    
    
    
}

extension Reactive where Base: CODChannelModel {
    
    var willDelete: Observable<[Any]> {
        return self.methodInvoked(#selector(CODChannelModel.delete)).debug("CODChannelModel.delete", trimOutput: true)
    }
    
}
