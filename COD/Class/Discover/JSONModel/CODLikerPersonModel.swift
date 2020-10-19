//
//  CODLikerPersonModel.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

enum CODDiscoverCommentMessageType: Int, Codable {
    case like = 1
    case comment = 2
    case at = 3
}

struct CODLikerPersonModel : Codable {
    
    
    let messageType : CODDiscoverCommentMessageType
    let replayUser : String?
    let replayUserNickName : String?
    let userName : String
    let userNickName : String?
    let userPic : String?
    let messageId : Int


    enum CodingKeys: String, CodingKey {
        case messageType = "messageType"
        case replayUser = "replayUser"
        case replayUserNickName = "replayUserNickName"
        case userName = "userName"
        case userNickName = "userNickName"
        case userPic = "userPic"
        case messageId = "messageId"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        messageId = try values.decode(Int.self, forKey: .messageId)
        messageType = try values.decode(CODDiscoverCommentMessageType.self, forKey: .messageType)
        userName = try values.decode(String.self, forKey: .userName)
        replayUser = try values.decodeIfPresent(String.self, forKey: .replayUser)
        replayUserNickName = try values.decodeIfPresent(String.self, forKey: .replayUserNickName)
        userNickName = try values.decodeIfPresent(String.self, forKey: .userNickName)
        userPic = try values.decodeIfPresent(String.self, forKey: .userPic)
        
    }


}
