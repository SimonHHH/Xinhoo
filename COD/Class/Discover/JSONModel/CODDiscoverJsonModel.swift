//
//  CODDiscoverJsonModel.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

/// 朋友圈类型 1：文字 2：图片3：视频
enum MomentsType: Int, Codable {
    case text = 1
    case image = 2
    case video = 3
}

enum MomentsStatus: Int, Codable {
    case normal = 1
    case delete = 2
}

enum MomentsForbidType: Int, Codable {
    case forbidCommnet = 1
    case allowComment = 2
}

enum MomentsCommentType: Int, Codable {
    case publicComment = 1
    case privateComment = 2
}

struct CODDiscoverJsonModel : Codable {


    /// 内容
    let content : String?
    
    /// 创建时间
    let createTime : Int
    
    /// 文件属性json格式
    let fileProperties : String?

    /// 维度
    let lat : String?
    
    /// 经度
    let lng : String?
    
    /// 位置
    let position : String?
    
    /// 主键Id
    let momentsId : Int
    

    /// 朋友圈状态 1：正常 2：删除
    let momentsStatus : MomentsStatus
    
    /// 开放点赞评论 1：公开2：不公开
    let openCommentPraise : MomentsCommentType
    
    let praiseList : [CODLikerPersonModel]?
    
    /// 分享范围1：所有可见2：自己可见3：指定朋友可见4：指定不可见列表
//    let sharingScope : Int?

    /// 用户名
    let userName : String
    
    let userNickName : String?
    
    /// 可见不可见用户列表
    let visibleUserIds : String?
    
    /// 头像
    let userPic : String?
    
    /// 朋友圈类型 1：文字 2：图片3：视频
    let momentsType: MomentsType
    
    /// 评论
    let commentList : [CODDiscoverCommentJsonModel]?
    
    let referToList: [String]?
    
    /// 分享范围 1：所有可见 2：自己可见 3：指定朋友可见 4：指定不可见列表
    let sharingScope: MessagePrivacyType
    
    /// 禁止评论点赞 1：禁止 2：不禁止
    let forbidCommentPraise: MomentsForbidType


    enum CodingKeys: String, CodingKey {
        case commentList = "commentList"
        case content = "content"
        case createTime = "createTime"
        case forbidCommentPraise = "forbidCommentPraise"
        case openCommentPraise = "openCommentPraise"
        case lat = "lat"
        case lng = "lng"
        case position = "position"
        case momentsId = "momentsId"
        case momentsStatus = "momentsStatus"
        case praiseList = "praiseList"
        case sharingScope = "sharingScope"
        case userName = "userName"
        case userNickName = "userNickName"
        case fileProperties = "fileProperties"
        case userPic = "userPic"
        case momentsType = "momentsType"
        case referToList = "referToList"
        case visibleUserIds = "visibleUserIds"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        userName = try values.decode(String.self, forKey: .userName)
        createTime = try values.decode(Int.self, forKey: .createTime)
        momentsId = try values.decode(Int.self, forKey: .momentsId)
        momentsStatus = try values.decode(MomentsStatus.self, forKey: .momentsStatus)
        sharingScope = try values.decode(MessagePrivacyType.self, forKey: .sharingScope)
        forbidCommentPraise = try values.decode(MomentsForbidType.self, forKey: .forbidCommentPraise)
        openCommentPraise = try values.decode(MomentsCommentType.self, forKey: .openCommentPraise)
        
        content = try values.decodeIfPresent(String.self, forKey: .content)
        commentList = try values.decodeIfPresent([CODDiscoverCommentJsonModel].self, forKey: .commentList)
        referToList = try values.decodeIfPresent([String].self, forKey: .referToList)
        visibleUserIds = try values.decodeIfPresent(String.self, forKey: .visibleUserIds)
        
        lat = try values.decodeIfPresent(String.self, forKey: .lat)
        lng = try values.decodeIfPresent(String.self, forKey: .lng)
        position = try values.decodeIfPresent(String.self, forKey: .position)
        
        fileProperties = try values.decodeIfPresent(String.self, forKey: .fileProperties)
        
        praiseList = try values.decodeIfPresent([CODLikerPersonModel].self, forKey: .praiseList)
        userPic = try values.decodeIfPresent(String.self, forKey: .userPic)
        userNickName = try values.decodeIfPresent(String.self, forKey: .userNickName)
        
        do {
            momentsType = try values.decode(MomentsType.self, forKey: .momentsType)
        } catch _ {
            momentsType = MomentsType.text
        }
        
        
        
        
    }


}


