//
//  CODDiscoverCommentJsonModel.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/22.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation



struct CODDiscoverCommentJsonModel : Codable {
    
    
    var comments : String? = nil
    var createTime : Int? = nil
    var messageId : Int = 0
    //    let messageStatus : Int?
    let messageType : CODDiscoverCommentMessageType
    var momentsId : Int = 0
    var momentsType: MomentsType
    var replayUser : String? = nil
    var replayUserNickName : String? = nil
    var userName : String = ""
    var userNickName : String
    var userPic : String = ""
    var read: Bool? = nil
    var fileProperties : String?
    
    
    /// 内容
    var content : String? = nil
    
    
    enum CodingKeys: String, CodingKey {
        case comments = "comments"
        case createTime = "createTime"
        case messageId = "messageId"
        //        case messageStatus = "messageStatus"
        case messageType = "messageType"
        case momentsId = "momentsId"
        case momentsType = "momentsType"
        case replayUser = "replayUser"
        case replayUserNickName = "replayUserNickName"
        case userName = "userName"
        case userNickName = "userNickName"
        case userPic = "userPic"
        case content = "content"
        case read = "read"
        case fileProperties = "fileProperties"
        //        case sms
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            messageId = try values.decode(Int.self, forKey: .messageId)
            momentsId = try values.decode(Int.self, forKey: .momentsId)
            userName = try values.decode(String.self, forKey: .userName)
            userPic = try values.decode(String.self, forKey: .userPic)
            comments = try values.decodeIfPresent(String.self, forKey: .comments)
            createTime = try values.decodeIfPresent(Int.self, forKey: .createTime)
            replayUser = try values.decodeIfPresent(String.self, forKey: .replayUser)
            replayUserNickName = try values.decodeIfPresent(String.self, forKey: .replayUserNickName)
            content = try values.decodeIfPresent(String.self, forKey: .content)
            fileProperties = try values.decodeIfPresent(String.self, forKey: .fileProperties)
            read = try values.decodeIfPresent(Bool.self, forKey: .read)
        } catch _ {

        }
        
        do {
            messageType = try values.decode(CODDiscoverCommentMessageType.self, forKey: .messageType)
        } catch _ {
            messageType = .like
        }
        
        do {
            momentsType = try values.decode(MomentsType.self, forKey: .momentsType)
            
        } catch _ {
            momentsType = .text
        }
        
        do {
            userNickName = try values.decode(String.self, forKey: .userNickName)
        } catch _ {
            userNickName = ""
        }
        
        
    }
    
    
}
