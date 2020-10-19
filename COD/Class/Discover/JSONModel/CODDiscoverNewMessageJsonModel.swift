//
//  CODDiscoverNewMessageJsonModel.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/25.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

struct CODDiscoverNewMessageJsonModel : Codable {
    
    enum MessageStatus: Int, Codable {
        case normal = 1
        case delete = 2
    }
    
    var comments : String? = nil
    var content : String? = nil
    var createTime : Int? = nil
    var fileProperties : String? = nil
    var messageId : Int = 0
    var messageType : CODDiscoverCommentMessageType = .like
    var momentsId : Int = 0
    var momentsType : MomentsType = .text
    var read : Int = 1
    var messageStatus : MessageStatus? = nil
    var momentsStatus : MomentsStatus? = nil
    var spreadUserName : String = ""
    var spreadUserNickName : String? = nil
    var spreadUserPic : String? = nil
    var userName : String? = nil
    var spreadReplayUserNickName : String? = nil
    
    
    enum CodingKeys: String, CodingKey {
        case comments = "comments"
        case content = "content"
        case createTime = "createTime"
        case fileProperties = "fileProperties"
        case messageId = "messageId"
        case messageType = "messageType"
        case momentsId = "momentsId"
        case momentsType = "momentsType"
        case read = "read"
        case messageStatus = "messageStatus"
        case spreadUserName = "spreadUserName"
        case spreadUserNickName = "spreadUserNickName"
        case spreadReplayUserNickName = "spreadReplayUserNickName"
        case spreadUserPic = "spreadUserPic"
        case userName = "userName"
        case momentsStatus = "momentsStatus"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        comments = try? values.decodeIfPresent(String.self, forKey: .comments)
        content = try? values.decodeIfPresent(String.self, forKey: .content)
        createTime = try? values.decodeIfPresent(Int.self, forKey: .createTime)
        fileProperties = try? values.decodeIfPresent(String.self, forKey: .fileProperties)
        messageStatus = try? values.decodeIfPresent(MessageStatus.self, forKey: .messageStatus)
        spreadUserNickName = try? values.decodeIfPresent(String.self, forKey: .spreadUserNickName)
        spreadUserPic = try? values.decodeIfPresent(String.self, forKey: .spreadUserPic)
        spreadReplayUserNickName = try? values.decodeIfPresent(String.self, forKey: .spreadReplayUserNickName)
        userName = try? values.decodeIfPresent(String.self, forKey: .userName)
        momentsStatus = try? values.decodeIfPresent(MomentsStatus.self, forKey: .momentsStatus)
        
        read = try values.decode(Int.self, forKey: .read)
        
        do {
            spreadUserName = try values.decode(String.self, forKey: .spreadUserName)
        } catch _ {
        }
        
        do {
            momentsType = try values.decode(MomentsType.self, forKey: .momentsType)
        } catch _ {
            
        }
        
        do {
            messageType = try values.decode(CODDiscoverCommentMessageType.self, forKey: .messageType)
        } catch _ {
        }
        
        do {
            messageId = try values.decode(Int.self, forKey: .messageId)
        } catch _ {
        }
        
        do {
            momentsId = try values.decode(Int.self, forKey: .momentsId)
        } catch _ {
        }

        
    }
    
    
}
