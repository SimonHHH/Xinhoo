//
//  CODDownLoadManager.swift
//  COD
//
//  Created by xinhooo on 2019/5/21.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Alamofire

class CODDownLoadManager: NSObject {
    
    enum ImageType {
        case fullImage(messageModel: CODMessageModel, isCloudDisk: Bool)
        case smallImage(messageModel: CODMessageModel, isCloudDisk: Bool)
        
        var key: String? {
            
            switch self {
            case .fullImage(messageModel: let messageModel, isCloudDisk: _), .smallImage(messageModel: let messageModel, isCloudDisk: _):
                return messageModel.photoModel?.photoLocalURL ?? messageModel.videoModel?.videoId ?? messageModel.location?.locationImageId
            }
            
        }
        
        var firstImageURLString: String? {
            switch self {
            case .fullImage(messageModel: let messageModel, isCloudDisk: _), .smallImage(messageModel: let messageModel, isCloudDisk: _):
                return messageModel.getFirstImageURL()
            }
        }
        
        var firstImageURL: URL? {
            
            switch self {
            case .fullImage(messageModel: _, isCloudDisk: let isCloudDisk):
                return URL(string: self.firstImageURLString?.getImageFullPath(imageType: 2, isCloudDisk: isCloudDisk) ?? "")
            case .smallImage(messageModel: _, isCloudDisk: let isCloudDisk):
                return URL(string: self.firstImageURLString?.getImageFullPath(imageType: 1, isCloudDisk: isCloudDisk) ?? "")
            }
            
        }
        
        var cacheImage: UIImage? {
            switch self {
            case .fullImage(messageModel: _, isCloudDisk: _):
                return CODImageCache.default.originalImageCache?.imageFromCache(forKey: self.key)
            case .smallImage(messageModel: _, isCloudDisk: _):
                return CODImageCache.default.smallImageCache?.imageFromCache(forKey: self.key)
            }
        }
    }

    class var sharedInstance : CODDownLoadManager {
        struct Static {
            static let instance : CODDownLoadManager = CODDownLoadManager()
        }
        return Static.instance
    }
    
//    var avatarDownLoadArr = Array<String>()
    var index = 0
    var request:DownloadRequest?
    var currentFileID = ""
    
    var downloadTasks: [String: DownloadRequest] = [:]

    
//    var queue = DispatchQueue(label: "com.avatar.thread")
    fileprivate override init() {
        super.init()
        
    }
    
    func downloadImage(type: ImageType, completed: ((UIImage?) -> ())? = nil) {
        
        if let image = type.cacheImage {
            completed?(image)
            return
        }
        
        SDImageLoadersManager.shared.loadImage(with: type.firstImageURL, context: nil, progress: nil) { (image, _, _, _) in
            completed?(image)
        }

    }
    
    func downloadFile(saveFilePath:String,fileID:String, localFileID: String? = nil,isCloudDisk: Bool = false,downProgress:((_ downProgress:Progress) -> ())?,success: (() -> ())?,failure: (() -> ())?) {
        
        let downloadLocalFileID = localFileID ?? fileID
        
        var fileType = "MESSAGE"
        if isCloudDisk {
            fileType = "CLOUDDISK"
        }
        if self.currentFileID == fileID,fileID == "" {
            return
        }
        if FileManager.default.fileExists(atPath: saveFilePath) {
            if success != nil {
                success!()
            }
        }else{
            if  let requestUrl: URL = URL(string: "\(HttpConfig.downLoadUrl)/\(fileID)?imgtype=1&storeType=\(fileType)") {
                let urlString = URLRequest(url: requestUrl)
                
                let destination = DownloadRequest.suggestedDownloadDestination(
                    for: .cachesDirectory,
                    in: .userDomainMask
                )

                self.currentFileID = fileID
                let request = HttpManager.share.manager.download(urlString, interceptor: afHttpAdapter, to: destination).authenticate(with: ClientTrust.sendClientCer())
                self.request = request
                downloadTasks[downloadLocalFileID] = request
                request.downloadProgress(queue: DispatchQueue.main) { [weak self] (progress) in
                    if downProgress != nil && self?.downloadTasks[downloadLocalFileID] == request {
                        downProgress!(progress)
                    }
                }.response { (response) in
                    self.currentFileID = ""

                    
                    switch response.result {
                    case .failure(let error):
                        
                        switch error {
                        case .explicitlyCancelled:
                            break
                        default:
                            CODProgressHUD.showSuccessWithStatus("文件下载失败")
                        }
                        
                        
                        DDLogInfo("【文件下载失败】\(error)")
                        print("error = \(error)")
                        if response.fileURL != nil {
                            self.removeFile(fileURL: response.fileURL!)
                        }
                        
                        if failure != nil {
                            failure!()
                        }
                        
                        break
                    case .success(let data):
                        
                        let json = JSON(data)
                        
                        guard let downURL = response.fileURL else {
                            CODProgressHUD.showSuccessWithStatus("文件下载失败")
                            if failure != nil {
                                failure!()
                            }
                            return
                        }

                        if json["code"].int == 3001002 {
                            if response.fileURL != nil {
                                self.removeFile(fileURL: response.fileURL!)
                            }
                            CODProgressHUD.showSuccessWithStatus("文件过期或已被清理")
                            if failure != nil {
                                failure!()
                            }
                            return
                        }
                        
                        /// 正常情况下不会有code
                        if let _ = json["code"].int {
                            
                            if response.fileURL != nil {
                                self.removeFile(fileURL: response.fileURL!)
                            }
                            CODProgressHUD.showSuccessWithStatus("文件下载失败")
                            if failure != nil {
                                failure!()
                            }
                            return
                            
                        }
                        

                        
                        if FileManager.default.fileExists(atPath: downURL.path) {
                            do{
                                //                                CODProgressHUD.showSuccessWithStatus("文件下载成功")
                                try FileManager.default.moveItem(at: downURL, to: URL.init(fileURLWithPath: saveFilePath))
                                if success != nil {
                                    success!()
                                }
                            }catch{
                                if failure != nil {
                                    failure!()
                                }
                            }
                        }
                    
                        break
                    }
                    
                }
                
                

            }
            
            
        }
    }
    
    func cancelDownload(fileID: String) {
        
        if let request = downloadTasks[fileID] {
            request.cancel()
            downloadTasks.removeValue(forKey: fileID)
        }
        
    }


    func downloadAvatar(userPicID: String, complete: ((_ avatar: UIImage) -> ())?) {

        if userPicID == "" {
            print("头像ID为空&&&&&&&&&&&&&&&&")
            if complete != nil {
                complete!(#imageLiteral(resourceName: "default_header_125"))
            }
            return
        }

        var picID = userPicID

        if userPicID.contains("/") {
            picID = userPicID.components(separatedBy: "/").last!
        }

        if picID.contains("?") {
            picID = picID.components(separatedBy: "?").first!
        }

        if let picURL = URL(string: picID.getHeaderImageFullPath(imageType: 1)) {

//            if let image = SDImageCache.shared.imageFromCache(forKey: CODImageCache.default.getCacheKey(url: picURL)) {
//                complete?(image)
//            } else {
//                complete?(#imageLiteral(resourceName: "default_header_125"))
//                SDWebImageDownloader.shared.downloadImage(with: picURL, options: [.useNSURLCache,], context: nil, progress: nil) { (image, data, error, isOk) in
//                    if let image = image {
//                        SDImageCache.shared.store(image, forKey: CODImageCache.default.getCacheKey(url: picURL), toDisk: true, completion: nil)
//                        complete?(image)
//                    }
//                }
//            }
            
            if let image = SDImageCache.shared.imageFromCache(forKey: CODImageCache.default.getCacheKey(url: picURL)) {
    
                complete?(image)
                
            }else {
                
                let _ = self.cod_loadHeader(url: picURL) { (image, data, error, isOK) in
                    if let image = image {
                        complete?(image)
                    }
                }
            }
            
        }
    }
    
    
    func cod_loadHeader(url: URL?, completion: SDWebImageDownloaderCompletedBlock? = nil) -> SDWebImageDownloadToken? {
                
        
        let userpic = url?.getHeaderId() ?? ""
        
        return SDWebImageDownloader.shared.downloadImage(with: url, options: [.useNSURLCache, ], context: nil, progress: nil) { (image, data, error, isOk) in
            
            if let image = image {
                if let url = url {
                    SDImageCache.shared.store(image, forKey: CODImageCache.default.getCacheKey(url: url), toDisk: true, completion: nil)
                }
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRefreshHeaderNoti), object: nil, userInfo: [
                "userPic": userpic,
                "image": image as Any
            ])
            
            completion?(image, data, error, isOk)
        }
    }
    
    func updateAvatar(userPicID:String,complete:((_ avatar:UIImage) -> ())?) {
        
        if userPicID == "" {
            if complete != nil {
                complete!(#imageLiteral(resourceName: "default_header_125"))
            }
            return
        }
        
        var picID = userPicID
        
        if userPicID.contains("/") {
            picID = userPicID.components(separatedBy: "/").last!
        }
        
        if picID.contains("?") {
            picID = picID.components(separatedBy: "?").first!
        }
        
        if let picUrl = URL.init(string: picID.getHeaderImageFullPath(imageType: 1)) {
            
            let _ = self.cod_loadHeader(url: picUrl) { (image, data, error, isOK) in
                if let image = image {
                    complete?(image)
                }
            }
        }
        
    }
    
    //删除临时下载文件
    private func removeFile(fileURL:URL) {
        do{
            try FileManager.default.removeItem(at: fileURL)
        }catch{
        }
    }
    
    func pathUserPathWithAvatar() -> String{
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documnetPath = documentPaths[0]
        var userDocumnetPath = documnetPath + "/" + UserManager.sharedInstance.loginName! + "/avatar"
        //判断是否有文件存在
        if(!FileManager.default.fileExists(atPath: userDocumnetPath)){
            do{
                try FileManager.default.createDirectory(atPath: userDocumnetPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                CCLog("创建用户文件失败!")
                userDocumnetPath = ""
            }
        }
        return userDocumnetPath
    }
    
    func saveBgImg(bgImage:UIImage?) {
        if bgImage == nil {
            return
        }
        if FileManager.default.fileExists(atPath: self.pathUserPathWithBgImg()) {
            try! FileManager.default.removeItem(atPath: self.pathUserPathWithBgImg())
        }
        
        let bgFile = self.pathUserPathWithBgImg() + "/" + "bgImg.png"
        try! bgImage?.pngData()?.write(to: URL.init(fileURLWithPath: bgFile, isDirectory: false))
    }
    
    
    func pathUserPathWithBgImg() -> String{
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documnetPath = documentPaths[0]
        var userDocumnetPath = documnetPath + "/" + UserManager.sharedInstance.loginName! + "/bgImg"
        //判断是否有文件存在
        if(!FileManager.default.fileExists(atPath: userDocumnetPath)){
            do{
                try FileManager.default.createDirectory(atPath: userDocumnetPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                CCLog("创建用户文件失败!")
                userDocumnetPath = ""
            }
        }
        return userDocumnetPath
    }
    
    func removeBgImg() {
        if FileManager.default.fileExists(atPath: self.pathUserPathWithBgImg()) {
            try! FileManager.default.removeItem(atPath: self.pathUserPathWithBgImg())
        }
    }
    
    func isCustomBgImg() -> Bool {
        let bgFile = self.pathUserPathWithBgImg() + "/" + "bgImg.png"
        if FileManager.default.fileExists(atPath: bgFile) {
            return true
        }else{
            return false
        }
    }
    
    func getCustomBgImg() -> UIImage? {
        if self.isCustomBgImg() {
            let bgFile = self.pathUserPathWithBgImg() + "/" + "bgImg.png"
            return UIImage.init(contentsOfFile: bgFile)
        }else{
            return nil
        }
    }

    func downloadAudio(messageModel: CODMessageModel, progressHandler: Request.ProgressHandler? = nil) {

        var jid = ""
        
        switch messageModel.chatTypeEnum {
        case .groupChat, .channel:
            jid = messageModel.toJID
        case .privateChat:
            if messageModel.fromJID.contains(UserManager.sharedInstance.loginName!) {
                jid = messageModel.toJID
            } else {
                jid = messageModel.fromJID
            }
        }


        let filePath = CODAudioPlayerManager.sharedInstance.pathUserPathWithAudio(jid: jid).appendingPathComponent(messageModel.audioModel!.audioURL).appendingPathExtension("mp3")
        var urlString = URLRequest(url: URL(string: messageModel.audioModel!.audioURL.getImageFullPath(imageType: 0, isCloudDisk: jid.contains(kCloudJid)))!)
        let nameStr = String(format: "%@:%@", UserManager.sharedInstance.loginName ?? "", UserManager.sharedInstance.password ?? "")
        let utf8Data = nameStr.data(using: String.Encoding.utf8)
        let base64String = utf8Data?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        let authValue = String(format: "Basic %@", base64String ?? "")
        urlString.setValue("*/*", forHTTPHeaderField: "Accept")
        urlString.setValue(authValue, forHTTPHeaderField: "Authorization")

        let destination: DownloadRequest.Destination = { url, response in
            let fileURL = URL.init(fileURLWithPath: filePath!)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        let request = HttpManager.share.manager.download(urlString, interceptor: afHttpAdapter, to: destination).authenticate(with: ClientTrust.sendClientCer()).downloadProgress { (progress) in
            progressHandler?(progress)
        }.response { (response) in
            if let _ = response.error {
                print("\(String(describing: response.error))")
            } else {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
                }
            }
            self.downloadTasks.removeValue(forKey: urlString.url?.absoluteString ?? "")
        }
        
        if let key = urlString.url?.absoluteString {
            self.downloadTasks[key] = request
        }
        
    }
    
    func cancelAudioDownload(messageModel: CODMessageModel) {
        
        var jid = ""
        if messageModel.fromJID.contains(UserManager.sharedInstance.loginName!) {
            jid = messageModel.toJID
        } else {
            jid = messageModel.fromJID
        }
        
        let urlString = messageModel.audioModel!.audioURL.getImageFullPath(imageType: 0, isCloudDisk: jid.contains(kCloudJid))
        self.downloadTasks[urlString]?.cancel()
        downloadTasks.removeValue(forKey: urlString)
        
    }

    
}
