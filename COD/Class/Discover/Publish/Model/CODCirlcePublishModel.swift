//
//  CODCirlcePublishModel.swift
//  COD
//
//  Created by xinhooo on 2020/5/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODCirlcePublishModel: Codable {
    
    enum CircleType: Int,Codable {
        case text = 1
        case image = 2
        case video = 3
    }
    
    /// 位置
    struct Location: Codable {
        /// 经度
        var longitude:Double?
        /// 纬度
        var latitude:Double?
        /// 地名
        var name = ""
        /// 详细地址
        var address = ""
        /// poi uid
        var uid = ""
    }
    var position: Location?
    
    /// 谁可以看见
    struct CanLook: Codable {
        
        enum Permissions: Int,Codable {
            case publicity          = 1 //公开
            case onlySelf           = 2 //私密
            case somePeople_canSee  = 3 //部分人可见
            case somePeople_notSee  = 4 //部分人不可见
        }
        
        var permissions: Permissions = .publicity
        /// “部分人”集合 string is jid
        var somePeopleList: Array<String> = []
        
        var groupList: Array<String>?
        var contactList: Array<String>?
    }
    var canLook: CanLook = CanLook()
    
    /// 文本内容
    var content = ""
    
    struct CircleImage: Codable {
        var image: UIImage = UIImage()
        
        enum CodingKeys: String, CodingKey {
            case image = "image"
            
        }
        
        init(image: UIImage) {
            self.image = image
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let imageData = try container.decode(Data.self, forKey: .image)
            image = NSKeyedUnarchiver.unarchiveObject(with: imageData) as? UIImage ?? UIImage()
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            let imageData = NSKeyedArchiver.archivedData(withRootObject: image)
            try container.encode(imageData, forKey: .image)
        }
    }
    
    /// 图片，视频内容
    var itemList: [CircleImage] = []
    
    struct VideoInfo: Codable {
    
        /// 视频首帧图片
        var firstImage: UIImage = UIImage()
        
        /// 视频数据
        var videoData: Data = Data()
        
        /// 视频时长
        var duration: Double = 0.0
        
        /// 视频本地缓存地址
        var localURL: String = ""
        
        enum CodingKeys: String, CodingKey {
            case firstImage = "firstImage"
            case videoData = "videoData"
            case duration = "duration"
            case localURL = "localURL"
            
        }
        
        init(firstImage: UIImage, videoData: Data, duration: Double, localURL: String) {
            self.firstImage = firstImage
            self.videoData = videoData
            self.duration = duration
            self.localURL = localURL
        }
        
        init(from decoder: Decoder) throws {
            // 注意这里的 keyedBy
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // 直接解码
            videoData = try container.decode(Data.self, forKey: .videoData)
            duration = try container.decode(Double.self, forKey: .duration)
            localURL = try container.decode(String.self, forKey: .localURL)
            
            let firstImageData = try container.decode(Data.self, forKey: .firstImage)
            firstImage = NSKeyedUnarchiver.unarchiveObject(with: firstImageData) as? UIImage ?? UIImage()
        }
        
        func encode(to encoder: Encoder) throws {
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(localURL, forKey: .localURL)
            try container.encode(videoData, forKey: .videoData)
            try container.encode(duration, forKey: .duration)
            
            
            let firstImageData = NSKeyedArchiver.archivedData(withRootObject: firstImage)
            
            try container.encode(firstImageData, forKey: .firstImage)
        }
        
    }
    
    var video: VideoInfo? = nil
    
    /// 被@的人集合 string is jid
    var atList: Array<String> = []
    
    /// 是否允许评论点赞 1\禁止 2\允许
    var isCanCommentAndLike = 2
    
    /// 是否公开评论点赞 1\公开 2\不公开
    var isPublicCommentAndLike = 2
    
    var circleType: CircleType = .text
    
    enum CodingKeys: String, CodingKey {
        
        case position = "position"
        case canLook = "canLook"
        case content = "content"
        case itemList = "itemList"
        case video = "video"
        case atList = "atList"
        case isCanCommentAndLike = "isCanCommentAndLike"
        case isPublicCommentAndLike = "isPublicCommentAndLike"
        case circleType = "circleType"
        
    }
    
    init() {
        
    }
    
    required init(from decoder: Decoder) throws {
        // 注意这里的 keyedBy
        let container = try decoder.container(keyedBy: CodingKeys.self)
        position = try container.decodeIfPresent(Location.self, forKey: .position)
        canLook = try container.decode(CanLook.self, forKey: .canLook)
        content = try container.decode(String.self, forKey: .content)
        itemList = try container.decode(Array.self, forKey: .itemList)
        video = try container.decodeIfPresent(VideoInfo.self, forKey: .video)
        atList = try container.decode(Array.self, forKey: .atList)
        isCanCommentAndLike = try container.decode(Int.self, forKey: .isCanCommentAndLike)
        isPublicCommentAndLike = try container.decode(Int.self, forKey: .isPublicCommentAndLike)
        circleType = try container.decode(CircleType.self, forKey: .circleType)

    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(position, forKey: .position)
        try container.encode(canLook, forKey: .canLook)
        try container.encode(content, forKey: .content)
        try container.encode(itemList, forKey: .itemList)
        try container.encodeIfPresent(video, forKey: .video)
        try container.encode(atList, forKey: .atList)
        try container.encode(isCanCommentAndLike, forKey: .isCanCommentAndLike)
        try container.encode(isPublicCommentAndLike, forKey: .isPublicCommentAndLike)
        try container.encode(circleType, forKey: .circleType)
    }
    
}

class CircleImage: UIImage,Codable {
    
}
