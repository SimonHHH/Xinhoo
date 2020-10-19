//
//  CODGlobalDataSource.swift
//  COD
//
//  Created by XinHoo on 2020/4/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODGlobalDataSource: NSObject {
    class func getContactGroupChannelModelData(isHeadCloudDisk: Bool, ignoreIDs: [Int]?) -> [AnyObject] {
        
        var contactIntSort :Array = [Int]()
        var contactListDic :Dictionary = [Int: AnyObject]()
        var contactListArr :Array = [AnyObject]()
        
        if isHeadCloudDisk {
            if let cloudDiskListModel = CODChatListRealmTool.getChatList(id: CloudDiskRosterID) {
                contactListDic[CloudDiskRosterID] = cloudDiskListModel
            }
            else if let cloudDiskModel = CODContactRealmTool.getContactById(by: CloudDiskRosterID) {
                contactListDic[CloudDiskRosterID] = cloudDiskModel
            }
            contactIntSort.append(CloudDiskRosterID)
        }
        
        let listModels = CODChatListRealmTool.getChatList()
        if listModels.count > 0 {
            for listModel in listModels {
                if let group = listModel.groupChat {
                    if group.isValid {
                        guard group.isCanSpeak() else {
                            continue
                        }
                        contactListDic[listModel.id] = listModel
                        contactIntSort.append(listModel.id)
                    }
                }
                if let contact = listModel.contact {
                    if contact.isValid {
                        
                        contactListDic[listModel.id] = listModel
                        contactIntSort.append(listModel.id)
                    }
                }
                if let channel = listModel.channelChat {
                    if channel.isValid {
                        guard channel.isAdmin(by: UserManager.sharedInstance.jid) else {
                            continue
                        }
                        contactListDic[listModel.id] = listModel
                        contactIntSort.append(listModel.id)
                    }
                }
            }
        }
        
        if let contactList = CODContactRealmTool.getContactsNotBlackListContainTempFriends() {
            if contactList.count > 0 {
                for contact in contactList {
                    contactListDic[contact.rosterID] = contact
                    contactIntSort.append(contact.rosterID)
                }
            }
        }
        
        let groupList = CODGroupChatRealmTool.getAllValidGroupChatList()
        if groupList.count > 0 {
            for group in groupList {
                guard group.isCanSpeak() else {
                    continue
                }
                contactListDic[group.roomID] = group
                contactIntSort.append(group.roomID)
            }
        }
        
        let channelList = CODChannelModel.getAllValidGroupChatList()
        if channelList.count > 0 {
            for channel in channelList {
                guard channel.isAdmin(by: UserManager.sharedInstance.jid) else {
                    continue
                }
                contactListDic[channel.roomID] = channel
                contactIntSort.append(channel.roomID)
            }
        }
        
        if let ignoreIds = ignoreIDs {
            contactIntSort = contactIntSort.removeAll(ignoreIds)
            contactIntSort = contactIntSort.removeAll(0)
        }
        
        for id in contactIntSort {
            guard let contact = contactListDic[id] else {
                continue
            }
            contactListArr.append(contact)
            contactListDic.removeValue(forKey: id)
        }
        
        return contactListArr
    }
}
