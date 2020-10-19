//
//  CODMessageModel.swift
//  COD
//
//  Created by 1 on 2019/3/6.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import RealmSwift
import HandyJSON
import RxSwift
import RxCocoa
import XMPPFramework
import SwiftyJSON


@objc


enum EMMessageBodyType : Int, HandyJSONEnum {
    
    case unknown = -999 // 未知消息
    case newMessage = -998 //新的消息的cell
    case text = 1
    case image = 2
    case audio = 3
    case video = 4
    case voiceCall = 5
    case location = 6
    case file = 7
    case notification = 8
    case haveRead = 10
    case businessCard = 11
    case videoCall = 13
    case gifMessage = 14 // 表情
    case multipleImage = 15 // 多图

}

enum CODMessageStatus :Int {
    
    case Cancal = -999
    case Pending  = 0    /*! \~chinese 发送未开始 \~english Pending */
    case Delivering = 5     /*! \~chinese 正在发送 \~english Delivering */
    case Succeed = 10   /*! \~chinese 发送成功 \~english Succeed */
    case Failed  = 15         /*! \~chinese 发送失败 \~english Failed */
}

enum CODMessageShowStatus :Int {
    
    case Initial  = 0    /*! \~chinese 初始的状态需要判断更新 \~english Pending */
    case Part = 5     /*! \~chinese 显示一个角 \~english Delivering */
    case HeadAndPart = 10   /*! \~chinese 显示一个角和头像都需要显示 \~english Succeed */
    case Nono  = 15         /*! \~chinese 什么都不显示 \~english Failed */
}

enum CODMessageFileUploadState :Int {
    
    case UploadForWait  = 0
    case Uploading      = 5
    case UploadSucceed  = 10
    case UploadFailed   = 15
}


///时间
let dateLocalTime:Int64 = 0
///最大的图片高度
let MAX_MESSAGE_IMAGE_WIDTH:CGFloat = KScreenWidth * 0.40

extension CODMessageModel: RealmWriteKeyPathable {}


final class CODMessageModel: Object,HandyJSON  {
    
    @objc dynamic var msgID = "0"
    
    //消息来自谁
    @objc dynamic var fromWho = ""
    @objc dynamic var fromJID = ""
    //消息发送给谁
    @objc dynamic var toWho = ""   
    @objc dynamic var toJID = ""
    
    /// 用户头像
    @objc dynamic var userPic = ""
    
    //如果是转发来自频道的话需要进行跳转到频道的区分，如果是人需要跳转到详情 个人'U' 群聊 "G" 频道 "C"
    @objc dynamic var fwf = ""
    
    @objc dynamic var n = ""
    
    /// 是否需要
    @objc dynamic var needUpdateMsg = false
    
    var nick = ""
    var color = ""
    //阅后即焚是否已读
    @objc dynamic var isReadedDestroy :Bool = false
    //阅后即焚（单位秒）
    @objc dynamic var burn:Int  = 0
    //消息的发送状态
    @objc dynamic var status: Int = CODMessageStatus.Succeed.rawValue
    var statusType: CODMessageStatus {
        get {
            return CODMessageStatus(rawValue: status) ?? .Succeed
        }
        set {
            self.status = newValue.rawValue
        }
    }
    
    var isRpOrFw: Bool {
        return (self.rp.count > 0 && self.rp != "0") || (self.fw.count > 0 && self.fw != "0")
    }
    
    //消息的附件上传状态，用于图片、视频、文件上传
    @objc dynamic var uploadState: Int = CODMessageFileUploadState.UploadForWait.rawValue
    //消息的附件上传进度，用于图片、视频、文件上传
    @objc dynamic var uploadProgress: Float = 0
    
    //是否已读
    @objc dynamic var isReaded :Bool = false
    
    //语音消息是否在播放中
    @objc dynamic var isPlay :Bool = false
    //语音消息是否已经播放过
    @objc dynamic var isPlayRead :Bool = false
    
    //文本消息发送时间是否要换行显示
    @objc dynamic var isNewline :Bool = false
    
    //用于图片的高度计算的高度储存使用，默认0
    @objc dynamic var imageHeight: Float = 0
    @objc dynamic var imageWidth: Float = 0
    @objc dynamic var cellHeight: String = ""
    @objc dynamic var isDelete: Bool = false
    
    //MARK: 回复 msgID
    @objc dynamic var rp: String = ""
    
    //MARK: 编辑 model
    @objc dynamic var editMessage: CODMessageModel?
    
    var isRp: Bool {
        return (self.rp.count > 0 && self.rp != "0")
    }
    
    //MARK: 转发 jid
    @objc dynamic var fw: String = ""
    
    var isFw: Bool {
        return (self.fw.count > 0 && self.fw != "0") && !CustomUtil.getIsCloudMessage(messageModel: self)
    }
    
    var isCloudDiskMessage: Bool {
        
        if self.toWho.contains(kCloudJid) || self.toJID.contains(kCloudJid) {
            return true
        }
        
        return false
    }
    
    //MARK: 转发的姓名 
    @objc dynamic var fwn: String = ""
    //MARK: 是否包含超链接
    @objc dynamic var l: Int = 0
    
    var entities:List = List<CODAttributeTextModel>()
    
    /// 是否群组
    //    @objc dynamic var isGroupChat :Bool = false
    
    @objc dynamic var chatType: String  = "1"
    
    var chatTypeEnum: CODMessageChatType {
        set {
            self.chatType = newValue.rawValue
        }
        get {
            return CODMessageChatType(rawValue: self.chatType) ?? .privateChat
        }
    }
    
    var isGroupChat: Bool {
        get {
            switch self.chatTypeEnum {
            case .groupChat, .channel:
                return true
                
            case .privateChat:
                return false
            }
        }
    }
    
    /// 如果是群组的话，RoomId需要赋值
    @objc dynamic var roomId = 0
    
    dynamic var referTo = List<String>()
    
    dynamic var audioList = List<String>()
    
    dynamic var invitjoinList = List<String>()
    
    dynamic var imageList = List<PhotoModelInfo> ()
    
    

    ///消息类型用于判断
    var type: EMMessageBodyType {
        set(newType) {
            msgType = newType.rawValue
        }
        get {
            return EMMessageBodyType(rawValue: msgType) ?? .unknown
        }
    }
    
    @objc dynamic var msgType = 0  //消息类型用于保存数据库
    //UI样式的显示
    @objc dynamic var showType = 0  //UI样式的显示
    
    ///是否显示日期
    @objc dynamic var isShowDate:Bool = false
    ///日期时间
    @objc dynamic var datetime = ""
    
    ///日期时间 int
    @objc dynamic var datetimeInt = 0 
    
    ///重发时间 int
    @objc dynamic var resendDatetimeInt = 0
    ///编辑
    @objc dynamic var edited = 0
    ///消息  0 未编辑过 1已编辑
    
    @objc dynamic var reply = 0
    
    //    var eMessage:EMMessage? = nil
    ///上一次消息发送时间
    @objc dynamic var lastDateString = ""
    ///消息下标
    @objc dynamic var msgIndex:Int = 0
    
    /// 消息转发自（会话ID）
    @objc dynamic var itemID: String?
    
    /// 消息转发自（原消息ID）
    @objc dynamic var smsgID: String?
    
    ///文本消息的转码
    var attrText:NSAttributedString  {
        
        var text = ""
        switch type {
        case .image:
            text = self.photoModel?.descriptionImage ?? ""
        case .video:
            text = self.videoModel?.descriptionVideo ?? ""
        case .audio:
            text = self.audioModel?.descriptionAudio ?? ""
        case .file:
            text = self.fileModel?.descriptionFile ?? ""
        default:
            text = self.text
        }
        
        return self.entities.toAttributeText(text: text)
        
    }
    
    ///文本消息的转码
    @objc dynamic var text = ""
    
    //消息内容
    @objc dynamic var messageBody = ""
    
    //位置
    @objc dynamic var location:LocationInfo?
    
    //名片
    @objc dynamic var businessCardModel:BusinessCardModelInfo?
    //图片
    @objc dynamic var photoModel:PhotoModelInfo?
    //录音
    @objc dynamic var audioModel:AudioModelInfo?
    //短视频
    @objc dynamic var videoModel:VideoModelInfo?
    //语音通话
    @objc dynamic var videoCallModel:VideoCallModelInfo?
    //语音通话
    @objc dynamic var fileModel:FileModelInfo?
    
    @objc dynamic var setting: Data?
    

    var isMeSend: Bool {
        return fromWho == UserManager.sharedInstance.jid
    }
    
    let master = LinkingObjects(fromType: CODChatHistoryModel.self, property: "messages")
    
    override static func primaryKey() -> String?{
        return "msgID"
    }    
    override class func indexedProperties() -> [String] {
        return ["datetimeInt"]
    }
    
    override static func ignoredProperties() -> [String] {
        return ["type","attrText","imageSize","videoImage","isPlay", "uploadProgress", "uploadState", "color","isSelect"]
    }
    
}

extension LocationInfo {
    
    func setValue<E>(_ value: E, forKey key: KeyPath<LocationInfo, E>) -> Self {
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            
            guard let keyPathString = key._kvcKeyPathString else {
                fatalError("Key path cannot be observed. You may need to prefix it with @objc.")
            }
            
            setValue(value, forKeyPath: keyPathString)
            
        }
        
        return self
        
        
    }
    
}

//位置信息
class LocationInfo: Object,HandyJSON {
    ///经纬度
    @objc dynamic var latitude:Double = 0.0
    @objc dynamic var longitude:Double = 0.0
    
    @objc dynamic var name = "" ///名字
    @objc dynamic var address = "" ///地址
    @objc dynamic var locationImageString: String  = "" ///图片
    @objc dynamic var loactionImageData: Data?
    @objc dynamic var locationImageId: String = "" // 本地缓存数据
    
    @objc dynamic var version = 1
    
    //描述内容
    @objc dynamic var descriptionLoaction = ""
    
    override static func ignoredProperties() -> [String] {
        return ["type","attrText","imageSize","videoImage"]
    }
}

enum DownloadStateType {
    case None
    case Downloading
    case Finished
    case Cancel

    init(value: Int) {
        
        switch value {
        case 1:
            self = DownloadStateType.Downloading
        case 2:
            self = DownloadStateType.Finished
        case 3:
            self = DownloadStateType.Cancel
        default:
            self = DownloadStateType.None
        }
        
    }
    
    var intValue: Int {
        
        switch self {
        case .None:
            return 0
        case .Downloading:
            return 1
        case .Finished:
            return 2
        case .Cancel:
            return 3
        }
        
    }
}


enum UploadStateType {
    case None
    case Finished
    case Uploading
    case Fail
    case Handling
    case Cancel

    init(value: Int) {
        
        switch value {
        case 1:
            self = UploadStateType.Finished
        case 2:
            self = UploadStateType.Uploading
        case 3:
            self = UploadStateType.Fail
        case 4:
            self = UploadStateType.Handling
        case 5:
            self = UploadStateType.Cancel
        default:
            self = UploadStateType.None
        }
        
    }
    
    var intValue: Int {
        
        switch self {
        case .None:
            return 0
        case .Finished:
            return 1
        case .Uploading:
            return 2
        case .Fail:
            return 3
        case .Handling:
            return 4
        case .Cancel:
            return 5
        }
        
    }
}

extension PhotoModelInfo: RealmWriteKeyPathable {}

final class PhotoModelInfo: Object ,HandyJSON{
    
    @objc dynamic var photoId: String = UUID().uuidString
    @objc dynamic var photoImageData: Data? = nil
    @objc dynamic var photoLocalURL: String = ""
    @objc dynamic var serverImageId: String = ""
    @objc dynamic var isGIF: Bool = false
    @objc dynamic var filename: String = ""
    //是不是原图
    @objc dynamic var ishdimg: Bool = false
    //描述内容
    @objc dynamic var descriptionImage = ""
    //宽
    @objc dynamic var w: Float = 0
    //高
    @objc dynamic var h: Float = 0
    // 文件大小
    @objc dynamic var size: Int = 0
    
    @objc dynamic var uploadState: Int = 0
    
    var uploadStateType: UploadStateType {
        set {
            uploadState = newValue.intValue
        }
        get {
            return UploadStateType(value: uploadState)
        }
    }
    
    override class func primaryKey() -> String? {
        return "photoId"
    }
    

    // 数据版本号
    @objc dynamic var version = 1
    
    func didFinishMapping() {
        self.isGIF = (self.filename.hasSuffix(".gif") || self.filename.hasSuffix(".GIF")) ? true : false
    }
    
    
    
    
}

extension Sequence where Element: PhotoModelInfo {
    func toImageInfo() -> [UploadTool.ImageInfo] {
        return self.map { $0.toImageInfo() }
    }
    
    func toYBIBImageData() -> [YBIBImageData] {
        
        return self.map { (value)in
            return value.toYBIBImageData()
        }
        
    }
    
    func getImageSmallURL() -> [URL?] {
        
        return self.map { $0.getImageSmallURL() }
        
    }

}

extension PhotoModelInfo {
    
    func toYBIBImageData() -> YBIBImageData {
        
        let data = YBIBImageData()
        data.imageURL = URL(string: ServerUrlTools.getMomentsServerUrl(fileType: .Image(self.serverImageId, .medium)))
        data.thumbURL = URL(string: ServerUrlTools.getMomentsServerUrl(fileType: .Image(self.serverImageId, .small)))
        data.photoId = self.photoId
        
        if CODImageCache.default.originalImageCache?.diskImageDataExists(withKey: self.photoId) ?? false {
            data.imagePath = CODImageCache.default.originalImageCache?.cachePath(forKey: self.photoId)
        }
//        data.singleTouchBlock = { (data) in
//
//        }
        return data
        
    }

    func getImageSmallURL() -> URL? {
        
        if CODImageCache.default.smallImageCache?.diskImageDataExists(withKey: self.photoId) ?? false {
            return URL(fileURLWithPath: CODImageCache.default.smallImageCache?.cachePath(forKey: self.photoId) ?? "")
        } else {
            return URL(string: ServerUrlTools.getMomentsServerUrl(fileType: .Image(self.serverImageId, .small)))
        }
        
    }
    
    func toJSON() -> [String : Any]? {
        var json: [String: Any] = [:]
        

        json["filepic"] = serverImageId
        json["photoid"] = serverImageId
        
        
        json["ishdimg"] = self.ishdimg
        json["description"] = self.descriptionImage
        json["w"] = self.w
        json["h"] = self.h
        json["size"] = self.size
        
        return json
        
    }
    
    class func getModel(serverId: String) -> PhotoModelInfo? {
        
        if serverId == "" {
            return nil
        }
        
        return try? Realm().objects(PhotoModelInfo.self).filter("serverImageId = '\(serverId)'").first
        
    }
    
    convenience init(json: JSON) {
        self.init()
        
        self.setModel(json: json)

    }
    
    func setModel(json: JSON) {
        
        
        self.descriptionImage = json["description"].stringValue
        self.w = json["w"].floatValue
        self.h = json["h"].floatValue
        self.ishdimg = json["ishdimg"].boolValue
        self.size = json["size"].intValue
        
        if let serverImageId = json["photoid"].string {
            self.serverImageId = serverImageId
        } else if let serverImageId = json["filepic"].string {
            self.serverImageId = serverImageId
        }
        
        
    }
    
    class func createModel(json: JSON) -> PhotoModelInfo {
        
        var newPhotoInfo = PhotoModelInfo(json: json)
        
        if let photoInfo = PhotoModelInfo.getModel(serverId: json["photoid"].stringValue) {
            newPhotoInfo = photoInfo
        } else if let photoInfo = PhotoModelInfo.getModel(serverId: json["filepic"].stringValue) {
            newPhotoInfo = photoInfo
        }
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            newPhotoInfo.setModel(json: json)
        }
        
        return newPhotoInfo
        
        
        
    }
    
    class func createModel(imageInfo: UploadTool.ImageInfo) -> PhotoModelInfo {
        
        let realm = try? Realm()
        
        var newPhotoInfo = PhotoModelInfo()
        
        if let photoInfo = PhotoModelInfo.getPhotoInfo(photoId: imageInfo.photoid) {
            newPhotoInfo = photoInfo
        } else {
            newPhotoInfo.photoId = imageInfo.photoid
        }
        
        try? realm?.safeWrite {
            
            newPhotoInfo.photoLocalURL = imageInfo.photoid
            newPhotoInfo.ishdimg = imageInfo.ishdimg
            newPhotoInfo.w = imageInfo.w
            newPhotoInfo.h = imageInfo.h
            newPhotoInfo.size = imageInfo.size

            if let description = imageInfo.description {
                newPhotoInfo.descriptionImage = description
            }
            
        }
                
        return newPhotoInfo
        
    }
    
    convenience init(imageData: Data, ishdimg: Bool) {
        
        self.init()
        

        //非原图片限制长宽1280
        var imageData = imageData
        
        if ishdimg != true {
            imageData = ImageCompress.compressImageData(imageData, limitLongWidth: 1280) ?? Data()
        }
        
        if ishdimg == true || imageData.imageFormat != .jpg {
            imageData = ImageCompress.compressImageDataToJPEG(imageData) ?? Data()
        }
        
        self.h = imageData.imageSize.height.float
        self.w = imageData.imageSize.width.float
        self.ishdimg = ishdimg
        self.size = imageData.count
        self.photoLocalURL = self.photoId

        if let smallImageData = ImageCompress.compressImageData(imageData, limitLongWidth: kChatImageMaxWidth * UIScreen.main.scale) {
            CODImageCache.default.smallImageCache?.store(UIImage(data: smallImageData), forKey: photoLocalURL, completion: nil)
        }
        
        CODImageCache.default.originalImageCache?.storeImageData(toDisk: imageData, forKey: photoLocalURL)
        

    }
    
    func toImageInfo() -> UploadTool.ImageInfo {
        
        var imageInfo = UploadTool.ImageInfo()
        
        imageInfo.photoid = self.photoId
        imageInfo.ishdimg = self.ishdimg
        imageInfo.w = self.w
        imageInfo.h = self.h
        imageInfo.size = self.size
        
        return imageInfo
        
    }
    
    func updateInfo(size: Int? = nil, descriptionImage: String? = nil, uploadState: UploadStateType? = nil, serverImageId: String? = nil){
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            
            if let size = size {
                self.size = size
            }

            if let descriptionImage = descriptionImage {
                self.descriptionImage = descriptionImage
            }
            
            if let uploadState = uploadState {
                self.uploadStateType = uploadState
            }
            
            if let serverImageId = serverImageId {
                self.serverImageId = serverImageId
            }
            
            
        }
        
    }
    
    class func getPhotoInfo(photoId: String) -> PhotoModelInfo? {
        return try? Realm().object(ofType: PhotoModelInfo.self, forPrimaryKey: photoId)
    }
    
    class func updateInfo(photoId: String, uploadState: UploadStateType? = nil,  serverImageId: String? = nil) {
        
        if let photo = self.getPhotoInfo(photoId: photoId) {
            photo.updateInfo(uploadState: uploadState, serverImageId: serverImageId)
        }
        
    }
    
    class func updateUploadState(photoList: List<PhotoModelInfo>, uploadState: UploadStateType) {
        
        try? Realm().safeWrite {
            
            photoList.setValue(\.uploadState, value: uploadState.intValue)
            
        }
        
    }
    
}

extension AudioModelInfo: RealmWriteKeyPathable {}

//录音
final class AudioModelInfo: Object,HandyJSON {
    
    ///视频的时间
    @objc dynamic var audioDuration: Float = 0.0
    ///视频的本地地址
    @objc dynamic var audioLocalURL = ""
    //视频网络地址
    @objc dynamic var audioURL = ""
    // 文件大小
    @objc dynamic var size: Int = 0
    //这个语音是不是播放过
    @objc dynamic var isPlayed = false
    
    
    @objc dynamic var descriptionAudio = "" ///名片
    
}

extension VideoModelInfo {
    
    func getMomentFirstpic() -> URL? {
        
        if CODImageCache.default.smallImageCache?.diskImageDataExists(withKey: self.videoId) ?? false {
            return URL(fileURLWithPath: CODImageCache.default.smallImageCache?.cachePath(forKey: self.videoId) ?? "")
        } else {
            return URL(string: ServerUrlTools.getMomentsServerUrl(fileType: .Image(self.firstpicId, .small)))
        }
        
    }
    
    class func getVideoModelInfo(by id: String) -> VideoModelInfo? {
        
        return try? Realm().object(ofType: VideoModelInfo.self, forPrimaryKey: id)
        
    }
    
    class func updateInfo<E>(videoId: String, value: E, keypath: KeyPath<VideoModelInfo, E>) -> VideoModelInfo? {
        
        if let videoModel = getVideoModelInfo(by: videoId) {
            return videoModel.setValue(value, forKey: keypath)
        }
        
        return nil
    }
    
    func setValue<E>(_ value: E, forKey key: KeyPath<VideoModelInfo, E>) -> Self {
        
        let realm = try? Realm()
        
        try? realm?.safeWrite {
            
            guard let keyPathString = key._kvcKeyPathString else {
                fatalError("Key path cannot be observed. You may need to prefix it with @objc.")
            }
            
            setValue(value, forKeyPath: keyPathString)
            
        }
        
        return self
        
        
    }
    
    func updateInfo(descriptionVideo: String? = nil, serverVideoId: String? = nil, firstpicId: String? = nil) {
        
        try! realm?.safeWrite {
            
            if let descriptionVideo = descriptionVideo {
                self.descriptionVideo = descriptionVideo
            }
            
            if let serverVideoId = serverVideoId {
                self.serverVideoId = serverVideoId
            }
            
            if let firstpicId = firstpicId {
                self.firstpicId = firstpicId
            }

        }
        
    }
    
    func toJSON() -> [String : Any]? {
        var json: [String: Any] = [:]
        
        json["filepic"] = serverVideoId
        json["w"] = self.w
        json["h"] = self.h
        json["size"] = self.size
        json["duration"] = self.videoDuration
        json["firstpic"] = self.firstpicId
        return json
        
    }
    
    convenience init(videoId: String, videoData: Data, firstpic: UIImage, duration: Float, localURL: String) {
        
        self.init()
        
        
        self.videoId = videoId
        self.videoDuration = duration
        self.size = videoData.count
        self.h = firstpic.size.height.float
        self.w = firstpic.size.width.float

        if let smallImageData = ImageCompress.resetImgSize(sourceImage: firstpic, maxImageLenght: 280, maxSizeKB: 600) {
            CODImageCache.default.smallImageCache?.store(UIImage(data: smallImageData), forKey: videoId, completion: nil)
        }
        
        CODImageCache.default.originalImageCache?.store(firstpic, forKey: videoId, completion: nil)
        
    }
    
    class func getModel(serverId: String) -> VideoModelInfo? {
        
        return try? Realm().objects(VideoModelInfo.self).filter("serverVideoId == '\(serverId)'").first
        
    }
    
    class func createModel(json: JSON) -> VideoModelInfo {
        
        var model = VideoModelInfo()
        let realm = try? Realm()
        
        if let localModel = VideoModelInfo.getModel(serverId: json["filepic"].stringValue) {
            model = localModel
        }
        
        
        try? realm?.safeWrite {
            
            model.serverVideoId = json["filepic"].stringValue
            model.videoDuration = json["duration"].floatValue
            model.firstpicId = json["firstpic"].stringValue
            model.w = json["w"].floatValue
            model.h = json["h"].floatValue
            model.size = json["size"].intValue

        }
        
        return model

    }
    
    
    
    func toVideoInfo() -> UploadTool.VideoInfo {
        
        var videoInfo = UploadTool.VideoInfo()
        
        videoInfo.uploadId = self.videoId
        videoInfo.videoId = self.videoId
        return videoInfo
        
    }
    
    func toYBIBVideoData() -> YBIBVideoData {
        
        let videoData = YBIBVideoData()
        videoData.autoPlayCount = UInt(NSIntegerMax)
        
        let videoLocalPath = CODFileManager.shareInstanceManger().mp4PathWithName(fileName: self.videoId)
        
        if FileManager.default.fileExists(atPath: videoLocalPath) {

            videoData.videoURL = URL(fileURLWithPath: videoLocalPath)
            
        } else {
            videoData.videoURL = URL(string: ServerUrlTools.getMomentsServerUrl(fileType: .Video(self.serverVideoId)))
            videoData.thumbURL = URL(string: ServerUrlTools.getMomentsServerUrl(fileType: .Image(self.firstpicId, .small)))
        }

        videoData.videoID = self.videoId
        videoData.isHiddenPlayBtn = true
        videoData.isHiddenPlayBtn = true
        videoData.isHiddenPlayTool = true
        videoData.repeatPlayCount = UInt(NSIntegerMax)

        return videoData
    }
    
}

//微视频
class VideoModelInfo: Object ,HandyJSON{
    
    @objc dynamic var videoId: String = UUID().uuidString
    
    @objc dynamic var serverVideoId = ""
    
    ///视频的时间
    @objc dynamic var videoDuration: Float = 0.0

    // 文件大小
    @objc dynamic var size: Int = 0
    
    //视频第一帧的图片
    @objc dynamic var firstpicId: String = ""
    
    @objc dynamic var uploadState: Int = 0
    
    // 本地资源ID
    @objc dynamic var assetLocalIdentifier: String?
    
    var uploadStateType: UploadStateType {
        set {
            uploadState = newValue.intValue
        }
        get {
            return UploadStateType(value: uploadState)
        }
    }
    
    //描述内容
    @objc dynamic var descriptionVideo = ""
    //宽
    @objc dynamic var w: Float = 0
    //高
    @objc dynamic var h: Float = 0
    
    // 数据版本号
    @objc dynamic var version = 1
    
    override class func primaryKey() -> String? {
        return "videoId"
    }
    
}

//名片
class BusinessCardModelInfo: Object ,HandyJSON{
    
    @objc dynamic var username = "" //名片发送人的JID
    @objc dynamic var name = "" ///昵称
    @objc dynamic var userdesc = "" ///用户名
    @objc dynamic var userpic = "" ///图片地址
    @objc dynamic var jid = "" ///jid
    @objc dynamic var gender = "" ///性别
    @objc dynamic var descriptionBusiness = "" ///名片
}


extension FileModelInfo: RealmWriteKeyPathable {
    
    var saveFilePath: String {
        let suffix = filename.pathExtension
        let saveFilePath = CODFileManager.fileManger.filePathWithName(fileName: "\(self.fileID).\(suffix)")
        
        return saveFilePath
    }
    
    func downloadFile(isCloudDisk: Bool = false) {
        if self.fileID.removeAllSapce.count == 0 {
            CODProgressHUD.showErrorWithStatus("文件为空")
            if FileModelInfo.getFileInfoModel(localFileID: localFileID)?.downloadStateType == DownloadStateType.Downloading {
                FileModelInfo.getFileInfoModel(localFileID: localFileID)?.setValue(\.downloadState, value: DownloadStateType.None.intValue)
            }
            return
        }
        
        let suffix = self.filename.pathExtension
        
        let saveFilePath = CODFileManager.fileManger.filePathWithName(fileName: "\(self.fileID).\(suffix)")
        
        let localFileID = self.localFileID
        
        self.setValue(\.downloadState, value: DownloadStateType.Downloading.intValue)
        
        if let downloadProgress = Xinhoo_FileViewModel.downloadProgressDic[localFileID] {
            downloadProgress.accept(0)
        }
        
        CODDownLoadManager.sharedInstance.downloadFile(saveFilePath: saveFilePath, fileID: self.fileID, localFileID: self.localFileID, isCloudDisk: isCloudDisk, downProgress: {  progress  in
            
            if FileModelInfo.getFileInfoModel(localFileID: localFileID)?.downloadStateType != DownloadStateType.Downloading {
                return
            }
            
            if let downloadProgress = Xinhoo_FileViewModel.downloadProgressDic[localFileID] {
                downloadProgress.accept(progress.fractionCompleted.float)
            }
        }, success: {
            
            if FileModelInfo.getFileInfoModel(localFileID: localFileID)?.downloadStateType != DownloadStateType.Downloading {
                return
            }
            
            FileModelInfo.getFileInfoModel(localFileID: localFileID)?.setValue(\.downloadState, value: DownloadStateType.Finished.intValue)


        }) {
            
            if FileModelInfo.getFileInfoModel(localFileID: localFileID)?.downloadStateType != DownloadStateType.Downloading {
                return
            }
            
            FileModelInfo.getFileInfoModel(localFileID: localFileID)?.setValue(\.downloadState, value: DownloadStateType.None.intValue)
        }
        
    }
    
    func cancelDownloadFile() {
        
        if let downloadProgress = Xinhoo_FileViewModel.downloadProgressDic[localFileID] {
            downloadProgress.accept(0)
        }
        
        CODDownLoadManager.sharedInstance.cancelDownload(fileID: self.localFileID)
        self.setValue(\.downloadState, value: DownloadStateType.Cancel.intValue)
        
        
        let suffix = self.filename.pathExtension
        let saveFilePath = CODFileManager.fileManger.filePathWithName(fileName: "\(self.fileID).\(suffix)")
        
        try? FileManager.default.removeItem(atPath: saveFilePath)
        
    }
    
    class func dowloadingTypeSetToNone() {
        
        let realm = try? Realm()
        
        realm?.objects(FileModelInfo.self).filter("downloadState == \(DownloadStateType.Downloading.intValue)").setValue(\.downloadState, value: DownloadStateType.None.intValue)
        
    }
    
    class func getFileInfoModel(localFileID: String) -> FileModelInfo? {
        let realm = try? Realm()
        
        return realm?.object(ofType: FileModelInfo.self, forPrimaryKey: localFileID)
    }
    
}


//文件
final class FileModelInfo: Object ,HandyJSON{
    
    @objc dynamic var localFileID = UUID().uuidString
    @objc dynamic var filename = "" //文件名称
    @objc dynamic var fileID = "" //文件id
    @objc dynamic var fileImageName = "" //文件图片显示的名字
    @objc dynamic var fileLocalString: String = ""///本地路径
    @objc dynamic var fileSizeString: String = ""///文件大小
    @objc dynamic var size: Int =  0///文件大小
    @objc dynamic var thumb = "" // 缩略图
    @objc dynamic var descriptionFile = "" // 描述
    
    @objc dynamic var downloadState: Int = 0
    
    var downloadStateType: DownloadStateType {
        set {
            downloadState = newValue.intValue
        }
        get {
            return DownloadStateType(value: downloadState)
        }
    }
    
    var downloadProgress: Float = 0
    
    var isImageOrVideo: Bool {
        get {
            return self.fileType == .ImageType || self.fileType == .VideoType
        }
    }
    
    var fileType: CODFileType {
        return CODFileHelper.getFileType(fileName: filename)
    }
    
    var fileExists: Bool {
        
        get {
            
            //文件后缀名
            let suffix = self.filename.pathExtension
            let saveFilePath = CODFileManager.fileManger.filePathWithName(fileName: "\(self.fileID).\(suffix)")
            return FileManager.default.fileExists(atPath: saveFilePath)
            
        }
        
    }
    
    override class func primaryKey() -> String? {
        return "localFileID"
    }
    
    override class func ignoredProperties() -> [String] {
        return ["downloadProgress"]
    }
    
    
}

extension FileModelInfo {
    
    func toJSON() -> [String : Any]? {
        
        var json = [
            "size": self.size.string,
            "filename": self.filename,
            "description": self.descriptionFile
        ]
        
        if self.isImageOrVideo {
            json["thumb"] = self.thumb
        }
        
        return json
        
    }
    
}


//语音聊天
enum VideoCallType : Int {
    
    case request        = 1         //申请语音聊天
    case accept         = 2         //接受语音聊天
    case close          = 3         //结束语音聊天 - 显示：通话时长：mm:ss
    case reject         = 4         //拒绝语音聊天 - 显示：已拒绝、对方已拒绝
    case cancle         = 6         //取消语音聊天 - 显示：已取消、对方已取消
    case timeout        = 8         //语音聊天超时 - 显示：未接听、对方无应答
    case busy           = 10        //语音聊天繁忙 - 显示：忙线未接听、对方忙
    case connectfailed  = 11        //连接失败 - 显示：连接失败、连接失败
    case oneaccept      = 12
    case offer          = 13
    case answer         = 14
    case candidate      = 15
    case requestmore      = 16
    
    init(string: String) {
        switch string {
        case "request":
            self = .request
        case "requestmore":
            self = .requestmore
        case "accept":
            self = .accept
        case "close":
            self = .close
        case "reject":
            self = .reject
        case "cancel":
            self = .cancle
        case "calltimeout":
            self = .timeout
        case "busy":
            self = .busy
        case "connectfailed":
            self = .connectfailed
        case "oneaccept":
            self = .oneaccept
        case "offer":
            self = .offer
        case "answer":
            self = .answer
        case "candidate":
            self = .candidate
        default:
            self = .accept
        }
    }
    
}

class VideoCallModelInfo: Object ,HandyJSON{
    ///消息类型用于判断
    var videoCalltype:VideoCallType {
        return VideoCallType(string: self.videoString)
    }
    
    ///请求类型
    @objc dynamic var videoString = ""
    
    /// 房间
    @objc dynamic var room = ""
    @objc dynamic var durationString = ""
    @objc dynamic var duration: Int = 0
    @objc dynamic var requester = ""
    @objc dynamic var resource = ""
    @objc dynamic var killer = ""
    
    func isKillerWithServer() -> Bool? {
        return (killer == "server")
    }
}


// 操作数据库
class CODMessageRealmTool: CODRealmTools {
    
    /// 根据消息ID查询消息
    /// - Parameters:
    ///   - msgId: 消息ID
    ///   - response: 回调闭包
    class func getRemoteMessageByMsgId(msgId: String, addToRealm: Bool = true, response:(@escaping (_ model:CODMessageModel?) -> Void)){
        
        let paramDic = [
                        "requester": UserManager.sharedInstance.jid,
                        "msgid":msgId,
                        "name": COD_getMsgByMsgId] as [String: Any]
        
        XMPPManager.shareXMPPManager.getRequest(param: paramDic, xmlns: COD_com_xinhoo_groupChat) { (result) in
            
            switch result {
                
            case .success(let model):
                
                if let msgString = model.data as? String {
                    
                    do{
                        let message = try XMPPMessage(xmlString: msgString)
                        if let messageModel = XMPPManager.shareXMPPManager.xmppMessageToRealmMessage(message: message) {
                            var id = 0
                            if messageModel.chatTypeEnum == .privateChat {
                                
                                if messageModel.fromJID.contains(UserManager.sharedInstance.loginName ?? "") {
                                    
                                    id = CODContactRealmTool.getContactByJID(by: messageModel.toJID)?.rosterID ?? 0
                                    
                                }else{
                                    id = CODContactRealmTool.getContactByJID(by: messageModel.fromJID)?.rosterID ?? 0
                                }
                                
                                
                            }else{
                                id = messageModel.roomId
                            }
                            if addToRealm {
                                
                                CODChatListRealmTool.addChatListMessage(id: id, message: messageModel)
                            }
                            
                            response(messageModel)
                        }else{
                            response(nil)
                        }
                        
                        
                        
                    }catch{
                        response(nil)
                    }
                    
                }
                
                break
            case .failure(_):
                response(nil)
                break
            }
        }
        
    }
    
    public class func generateNewMessage(by msgId: String) -> CODMessageModel? {
        
        if let messageModel = getMessageByMsgId(msgId) {
            
            let newMessageModel = CODMessageModel(value: messageModel)
            
            newMessageModel.msgID = UserManager.sharedInstance.getMessageId()
            
            return newMessageModel
            
        }
        
        return nil
        
    }
    
    /// 根据主键查询
    public class func getMessageByMsgId(_ msgId: String) -> CODMessageModel? {
        let defaultRealm = self.getDB()
        let message = defaultRealm.object(ofType: CODMessageModel.self, forPrimaryKey: msgId) ?? nil
        return message
    }
    
    /// 清除脏数据
    class func deleteDirtyMsg() {
        
         let realm = try! Realm()
        
        if let messageModel = self.getMessageByMsgId("0") {
            try! realm.safeWrite {
                realm.delete(messageModel)
            }
        }
        
        if let groupModel = CODGroupChatRealmTool.getGroupChat(id: 0) {
            try! realm.safeWrite {
                realm.delete(groupModel)
            }
        }
        
        if let channelModel = CODChannelModel.getChannel(by: 0) {
            try! realm.safeWrite {
                realm.delete(channelModel)
            }
        }
        
        let videos = realm.objects(VideoModelInfo.self).filter("w = 0").toArray()
        try? realm.safeWrite {
            realm.delete(videos)
        }
        
        let models = CODDiscoverFailureAndSendingListModel.getFailureModel().modelList.filter("version = 0").toArray()
        try? realm.safeWrite {
            realm.delete(models)
        }
        
        let models2 = realm.objects(CODDiscoverMessageModel.self).filter("serverMsgId == '' && version < 2").toArray()
        try? realm.safeWrite {
            realm.delete(models2)
        }
        
        let models3 = realm.objects(CODChatListModel.self).filter("chatType == '2'")
        for model in models3 {
            if let groupChat = model.groupChat {
                model.chatHistory?.messages.setValue(\.roomId, value: groupChat.roomID)
            }
        }
        

    }
    
    public class func getExistMessage(_ msgId: String) -> CODMessageModel?  {
        let defaultRealm = self.getDB()
        
        return defaultRealm.objects(CODMessageModel.self).filter("msgID = '\(msgId)' AND isDelete != true").first
    }
    

    public class func updateMessageEditMessageByMsgId(_ msgId: String ,editMessage: CODMessageModel) {
        if let message = self.getMessageByMsgId(msgId) {
            let defaultRealm = CODRealmTools.getDB()
            try! defaultRealm.write {
                message.editMessage = editMessage
            }
        }
    }

    public class func updateMessageEditMessageVideoByMsgId(_ msgId: String ,videoModel: VideoModelInfo) {
        if let message = self.getMessageByMsgId(msgId) {
            let defaultRealm = CODRealmTools.getDB()
            try! defaultRealm.write {
                message.editMessage?.videoModel = videoModel
                message.statusType = .Pending
            }
        }
    }

    public class func updateMessageIsPlayByMsgId(_ msgId: String ,isPlay: Bool) {
        if let message = self.getMessageByMsgId(msgId) {
            let defaultRealm = CODRealmTools.getDB()
            try! defaultRealm.write {
                message.audioModel?.isPlayed = isPlay
            }
        }
    }
    public class func updateMessageEditedByMsgId(_ msgId: String ,edited: Int) {
        if let message = self.getMessageByMsgId(msgId) {
            let defaultRealm = CODRealmTools.getDB()
            try! defaultRealm.write {
                message.edited = edited
                message.editMessage = nil
            }
        }
    }
    public class func updateMessageShowTypeByMsgId(_ msgId: String ,showType: Int) {
        if let message = self.getMessageByMsgId(msgId) {
            let defaultRealm = CODRealmTools.getDB()
            try! defaultRealm.write {
                message.showType = showType
            }
        }
    }

    
    public class func burnMessage(messages: [CODMessageModel]) -> [CODMessageModel] {
        
        var messages = messages
        
        let burnMessages = messages.filter { (messageModel) -> Bool in
            let leftTime = messageModel.burn * 1000 + messageModel.datetimeInt - CustomUtil.getCurrentTime()
            
            if messageModel.isReadedDestroy == false {
                return false
            }
            
            if messageModel.statusType != .Succeed {
                return false
            }
            
            if messageModel.type == .notification {
                return false
            }
            
            if (messageModel.burn > 0 && leftTime <= 0 || messageModel.burn == 1) {
                return true
            }
            
            return false
        }
        
        if burnMessages.count > 0 {
            CODMessageRealmTool.deleteMessages(by: burnMessages)
            messages.removeAll(burnMessages)
        }

        return messages
        
    }
    
    public class func burnMessage(chatID: Int)  {
        
        DispatchQueue.realmWriteQueue.async {
            
            guard let chatList = CODChatListRealmTool.getChatList(id: chatID) else {
                return
            }

            if let messages = chatList.chatHistory?.messages.filter("isReadedDestroy == \(true) AND status == \(CODMessageStatus.Succeed.rawValue) AND msgType != \(EMMessageBodyType.notification.rawValue) AND isDelete != \(true) AND burn > 0") {

                let burnMessages = messages.toArray().filter({ (messageModel) -> Bool in
                    
                    let leftTime = messageModel.burn * 1000 + messageModel.datetimeInt - CustomUtil.getCurrentTime()
                    
                    if (messageModel.burn > 0 && leftTime <= 0 || messageModel.burn == 1) {
                        return true
                    }
                    
                    return false
                    
                })
                
                if burnMessages.count > 0 {
                    CODMessageRealmTool.deleteMessages(by: burnMessages)
                }

            }
            
            
        }
        
        
        
    }
    
    /// 更新消息的已收到状态和时间
    ///
    /// - Parameters:
    ///   - msgId: 消息ID
    ///   - status: 消息已收到状态
    ///   - sendTime: 收到时间
    public class func updateMessageStyleByMsgId(_ msgId: String ,status: Int, sendTime: Int? = nil) {
        if let message = self.getMessageByMsgId(msgId) {
            let defaultRealm = CODRealmTools.getDB()
            
            let writeBlock = {
                
                message.status = status
                
                if let sendTime = sendTime {
                    message.datetime = "\(sendTime)"
                    message.datetimeInt = sendTime
                }
                
//                if message.statusType == .Succeed {
////                    message.imageList.setValue(\.uploadState, value: 0)
//                }
                
            }
            
            if defaultRealm.isInWriteTransaction {
                
                writeBlock()
                
            } else {
                
                try! defaultRealm.write(writeBlock)
                
            }
            
            
        }
    }
    
    public class func updateMessageHaveReadedByMsgId(_ msgId: String ,isReaded: Bool) {
        if let message = self.getMessageByMsgId(msgId) {
            let defaultRealm = CODRealmTools.getDB()
            try! defaultRealm.write {
                message.isReaded = isReaded
            }
        }
    }
    
    
    
    public class func updateMessageNickname(_ msgId: String ,nickname: String) {
        if let message = self.getMessageByMsgId(msgId) {
            let defaultRealm = CODRealmTools.getDB()
            try! defaultRealm.write {
                message.nick = nickname
            }
        }
    }
    
    public class func updateMessagePhotoLocalURLByMsgId(_ msgId: String ,photoLocalURL: String) {
        if let message = self.getMessageByMsgId(msgId) {
            let defaultRealm = CODRealmTools.getDB()
            try! defaultRealm.write {
                if message.editMessage != nil {
                    message.editMessage?.photoModel?.photoLocalURL = photoLocalURL
                }else{
                    message.photoModel?.photoLocalURL = photoLocalURL
                }
            }
        }
    }

    
    public class func updateMessageVideoUrl(_ msgId: String, picID: String = "", audioURL: String,fileID: String,locationString: String,sendTime: Int) {
        
        if let message = self.getMessageByMsgId(msgId) {
            let defaultRealm = CODRealmTools.getDB()
            try! defaultRealm.write {
                message.audioModel?.audioURL = audioURL
                message.datetime = "\(sendTime)"
                message.datetimeInt = sendTime
//                message.photoModel?.photoImageURL = picUrl
                message.photoModel?.serverImageId = picID
                if fileID.count > 0{
                    message.fileModel?.fileID = fileID
                }
                message.location?.locationImageString = locationString
                
            }
        }
    }
    public class func updateMessageImageSize(_ msgId: String ,imageHeight: CGFloat,imageWidth: CGFloat) {
        
        
        if let message = self.getMessageByMsgId(msgId) {
            let defaultRealm = CODRealmTools.getDB()
            try! defaultRealm.write {
                message.imageWidth = imageWidth.float
                message.imageHeight = imageHeight.float
            }
        }
    }
    public class func updateMessageCellHeight(_ msgId: String ,cellHeight: String) {
        
        DispatchQueue.realmWriteQueue.async {
            
            if let message = self.getMessageByMsgId(msgId) {
                let defaultRealm = CODRealmTools.getDB()
                try! defaultRealm.write {
                    message.cellHeight = cellHeight
                }
            }
            
        }
        
        
        
    }
    
    public class func deleteMessages(by messages: [CODMessageModel]) -> Void {
        let defaultRealm = try! Realm()
        try! defaultRealm.safeWrite {
            let messageList = List<CODMessageModel>()
            messageList.append(objectsIn: messages)
            messageList.setValue(true, forKey: "isDelete")
        }
    }
    
    public class func setReadedDestroy(by messages: [CODMessageModel]) -> Void {
        let defaultRealm = self.getDB()
        try! defaultRealm.safeWrite {
            let messageList = List<CODMessageModel>()
            messageList.append(objectsIn: messages)
            messageList.setValue(true, forKey: "isReadedDestroy")
        }
    }
    
    public class func setReadedDestroy(message: CODMessageModel) -> Void {
        let defaultRealm = self.getDB()
        
        guard let message = getMessageByMsgId(message.msgID) else {
            return
        }
        
        try! defaultRealm.safeWrite {
            message.isReadedDestroy = true
        }
    }
    
    public class func deleteMessages(by msgIds : [String]) -> Void {
        
        for msgId in msgIds {
            self.deleteMessage(by: msgId)
        }
        
    }
    
    public class func deleteMessage(by msgId : String) -> Void {
        let defaultRealm = self.getDB()
        guard let messsageModel = self.getMessageByMsgId(msgId) else {
            return
        }
        
        try! defaultRealm.safeWrite {
            messsageModel.isDelete = true
        }
        
    }
    
    public class func updateVideoMessage(by msgId : String, videoModel: VideoModelInfo) -> Void {
        let defaultRealm = self.getDB()
        guard let messsageModel = self.getMessageByMsgId(msgId) else {
            return
        }
        try! defaultRealm.write {
            messsageModel.videoModel = videoModel
        }
    }
    
    
    public class func searchMsgs(with textStr: String) -> Array<CODMessageModel>? {
        
        func searchTextMsgArr(messageSource: Results<CODMessageModel>, searchText: String) -> Array<CODMessageModel> {
            let messageTextArr = messageSource.filter("msgType = 1 && isDelete = false && text contains[c] %@", textStr).toArray()
//            var array = Array<CODMessageModel>()
//            for contact in messageTextArr {
//                array.append(contact)
//            }
            return messageTextArr
        }
        
        func searchFileMsgArr(messageSource: Results<CODMessageModel>, searchText: String) -> Array<CODMessageModel> {
//            let messageTextArr = messageSource.map { (messageModel) -> CODMessageModel? in
//                if messageModel.msgType == 7 && messageModel.isDelete == false && messageModel.fileModel?.filename.contains(searchText, caseSensitive: false) ?? false {
//                    return messageModel
//                }else{
//                    return nil
//                }
//            }.compactMap{$0}

            let messageTextArr = messageSource.filter("(msgType = 7 && isDelete = false && fileModel.filename contains[c] %@) || (msgType = 1 && isDelete = false && text contains[c] %@)",textStr, textStr).toArray()
            return messageTextArr
        }
        
        let defaultRealm = self.getDB()
        let messageArrTemp = defaultRealm.objects(CODMessageModel.self)
        
        /*searchTextMsgArr(messageSource: messageArrTemp, searchText: textStr) +*/
        var list = searchFileMsgArr(messageSource: messageArrTemp, searchText: textStr)
        
        guard list.count > 0 else {
            print("————————————查询不到匹配的消息————-——————")
            return nil
        }
        var array = Array<CODMessageModel>()
        for contact in list.sort(by: \.datetime, ascending: false) {
            array.append(contact)
        }
        return array
    }
    
}
