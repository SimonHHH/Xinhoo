//
//  CODDiscoverNotificationJsonModel.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/29.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

struct CODDiscoverNotificationJsonModel : Codable {

    let comments : String?
    let createTime : Int?
    let messageId : Int
    let messageStatus : CODDiscoverNewMessageJsonModel.MessageStatus
    let messageType : CODDiscoverCommentMessageType
    let momentsId : Int
    let replayUserNickName : String?
    let replayUser: String
    let userNickName : String?
    let userPic : String?


    enum CodingKeys: String, CodingKey {
        case comments = "comments"
        case createTime = "createTime"
        case messageId = "messageId"
        case messageStatus = "messageStatus"
        case messageType = "messageType"
        case momentsId = "momentsId"
        case replayUserNickName = "replayUserNickName"
        case replayUser = "replayUser"
        case userNickName = "userNickName"
        case userPic = "userPic"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        comments = try values.decodeIfPresent(String.self, forKey: .comments)
        createTime = try values.decodeIfPresent(Int.self, forKey: .createTime)
        messageId = try values.decode(Int.self, forKey: .messageId)
        messageStatus = try values.decode(CODDiscoverNewMessageJsonModel.MessageStatus.self, forKey: .messageStatus)
        messageType = try values.decode(CODDiscoverCommentMessageType.self, forKey: .messageType)
        momentsId = try values.decode(Int.self, forKey: .momentsId)
        replayUserNickName = try values.decodeIfPresent(String.self, forKey: .replayUserNickName)
        replayUser = try values.decode(String.self, forKey: .replayUser)
        userNickName = try values.decodeIfPresent(String.self, forKey: .userNickName)
        userPic = try values.decodeIfPresent(String.self, forKey: .userPic)
    }


}
