//
//  UploadTool.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/24.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON


struct UploadTool {
    
    struct ImageInfo {
        var photoid: String = UUID().uuidString
        var serverPhotoId: String?
        var ishdimg: Bool = false
        var description: String?
        var w: Float = 0
        var h: Float = 0
        var size: Int = 0
        var result: Result = .none
    }
    
    struct VideoInfo {
        var uploadId: String = ""
        var videoId: String = ""
        var serverFirstImageId = ""
        var serverVideoId: String = ""
    }
    
    indirect enum FileType {
        case image(imageInfo: ImageInfo)
        case imageObjest(image: UIImage)
        
        // 多图
        case multipleImage(imageInfos: [ImageInfo])
        
        // 视频
        case video(videoInfo: VideoInfo)
        
        // 用户头像
        case header(image: UIImage)
        
        // 群头像
        case groupHeader(roomID: String, image: UIImage)
        
        // 文件
        case file(msgID: String)
        
        var stringValue: String {
            switch self {
            case .image(imageInfo: _), .imageObjest(image: _):
                return "Image"
                
                
//            case .multipleImage(imageInfos: _), .header(image: _), .groupHeader(roomID: _, image: _):
//                return ""
                
            case .video(videoInfo: _):
                return "MVideo"
                
            case .file(msgID: _):
                return "Document"
                
            default:
                return ""
            }
            
            
        }
    }
    
    indirect enum Result {
        case none
        case progress(progress: Double)
        case success(file: FileType)
        case fail
        case cancal
        
        var isSuccess: Bool {
            
            switch self {
            case .progress(progress: _), .fail, .none, .cancal:
                return false
            case .success(file: _):
                return true
                
            }
            
        }
        
        var isCancal: Bool {
            
            switch self {
            case .progress(progress: _), .success(file: _), .fail, .none:
                return false
            case .cancal:
                return true
            }
            
        }
        
        var isProgress: Bool {
            
            switch self {
            case .success(file: _), .fail, .none, .cancal:
                return false
            case .progress(progress: _):
                return true
            }
            
        }
    }
    
    static var uploadTasksPublishRelay: [String: BehaviorRelay<Result>] = [:]
    static var uploadTasksObserver: [String: AnyObserver<Result>] = [:]
    static var uploadFileInfos: [String: FileType] = [:]
    static var observer: PublishRelay<Result>? = nil
    
    
    static var headers: HTTPHeaders  {
        get {
            return HTTPHeaders(["content-type":"multipart/form-data",
                                "xh-user-name":UserManager.sharedInstance.loginName ?? "",
                                "xh-user-token":UserManager.sharedInstance.session ?? "",
                                "xh-user-resource":UserManager.sharedInstance.resource ?? ""])
        }
    }
    
    
    
    
    
    static func uploadRequest(request: UploadRequest,
                              progressHandle: Request.ProgressHandler? = nil,
                              completionHandler: ((AFDataResponse<Any>) -> Void)? = nil) {
        
        _ = request.authenticate(with: ClientTrust.sendClientCer()).responseJSON(completionHandler: { (response) in
            
            switch response.result {
                
            case .success(let data):
                
                let json = JSON(data)
                
                if json["code"].intValue != 0 {
                    
                    completionHandler?(AFDataResponse(request: response.request, response: response.response, data: response.data, metrics: response.metrics, serializationDuration: response.serializationDuration, result: .failure(.explicitlyCancelled)))
                    
                    return
                    
                }
                
                
                break
                
            case .failure(_):
                break
            }
            
            completionHandler?(response)
            
            
        }).uploadProgress { (progress) in
            progressHandle?(progress)
        }
        
        
        
    }
    
    static func uploadImageRequest(image: UIImage,
                                   progressHandle: Request.ProgressHandler? = nil,
                                   completionHandler: ((AFDataResponse<Any>) -> Void)? = nil) {
        
        
        let uploadRequest = HttpManager.share.manager.upload(multipartFormData: { (multipartFormData) in
            
            guard let pictureImageData = image.sd_imageData(as: .JPEG) else { return }
            multipartFormData.append(pictureImageData, withName: "files", fileName: UUID().uuidString, mimeType: "image/png");
            multipartFormData.append(true.string.data(using: .utf8) ?? Data(), withName: "isHDImg")
            
        }, to: HttpConfig.COD_moments_uploadImg, headers: self.headers, interceptor: afHttpAdapter)
        
        self.uploadRequest(request: uploadRequest, progressHandle: progressHandle, completionHandler: completionHandler)
        
    }
    
    static func uploadImageRequest(imageInfos: [UploadTool.ImageInfo],
                                   progressHandle: Request.ProgressHandler? = nil,
                                   completionHandler: ((AFDataResponse<Any>) -> Void)? = nil) {
        
        
        let uploadRequest = HttpManager.share.manager.upload(multipartFormData: { (multipartFormData) in
            
            for imageInfo in imageInfos {
                guard let pictureImageData = CODImageCache.default.originalImageCache?.diskImageData(forKey: imageInfo.photoid) else { continue }
                multipartFormData.append(pictureImageData, withName: "files", fileName: imageInfo.photoid, mimeType: "image/png");
            }
            
            if let isHDImg = imageInfos.first?.ishdimg.string {
                multipartFormData.append(isHDImg.data(using: .utf8) ?? Data(), withName: "isHDImg")
            }
            
            
        }, to: HttpConfig.COD_moments_uploadImg, headers: self.headers, interceptor: afHttpAdapter)
        
        self.uploadRequest(request: uploadRequest, progressHandle: progressHandle) { (result) in
            
            switch result.result {
                
            case .success(let data):
                
                let json = JSON(data)
                for jsonData in json["data"].arrayValue {
                    
                    if let photo = PhotoModelInfo.getPhotoInfo(photoId: jsonData["name"].stringValue) {
                        
                        let serverImageId = jsonData["attId"].stringValue
                        photo.updateInfo( uploadState: .Finished, serverImageId: serverImageId)
                        
                    }
                    
                }
            case .failure(let error):
                print(error)
                break
                
            default:
                break
                
            }
            
            completionHandler?(result)
            
        }
        
        
    }
    
    static func uploadVideoRequest(videoInfo: UploadTool.VideoInfo,
                                   progressHandle: Request.ProgressHandler? = nil,
                                   completionHandler: ((AFDataResponse<Any>) -> Void)? = nil) {
        
        let videoLocalPath = CODFileManager.shareInstanceManger().mp4PathWithName(fileName: videoInfo.videoId)
        
        let uploadRequest = HttpManager.share.manager.upload(multipartFormData: { (multipartFormData) in
            
            if let videoData: Data = FileManager.default.contents(atPath: videoLocalPath) {
                multipartFormData.append(videoData, withName: "files", fileName: videoInfo.videoId, mimeType: "video/mp4");
            }
            
        }, to: HttpConfig.COD_moments_uploadVideo, headers: self.headers, interceptor: afHttpAdapter)
        
        self.uploadRequest(request: uploadRequest, progressHandle: progressHandle) { (result) in
            
            switch result.result {
                
            case .success(let data):
                
                let json = JSON(data)
                for jsonData in json["data"].arrayValue {
                    
                    
                    if let video = VideoModelInfo.getVideoModelInfo(by: jsonData["name"].stringValue) {
                        
                        let serverVideoId = jsonData["attId"].stringValue
                        
                        _ = video.setValue(serverVideoId, forKey: \.serverVideoId)
                        
                        
                    }
                    
                }
                
            default:
                break
                
            }
            
            completionHandler?(result)
            
        }
        
        
    }
    
    static func upload(fileType: FileType,
                       progressHandle: Request.ProgressHandler? = nil,
                       completionHandler: ((AFDataResponse<Any>) -> Void)? = nil) {
        
        
        switch fileType {
        case .image(imageInfo: let imageInfo):
            uploadImageRequest(imageInfos: [imageInfo], progressHandle: progressHandle, completionHandler: completionHandler)
            
        case .imageObjest(image: let image):
            uploadImageRequest(image: image, progressHandle: progressHandle, completionHandler: completionHandler)
            
        case .multipleImage(imageInfos: let imageInfos):
            uploadImageRequest(imageInfos: imageInfos, progressHandle: progressHandle, completionHandler: completionHandler)
            
        case .header(image: let image):
            uploadHeader(image: image, progressHandle: progressHandle, completionHandler: completionHandler)
            
        case .groupHeader(roomID: let roomID, image: let image):
            uploadGroupHeader(roomID: roomID, image: image, progressHandle: progressHandle, completionHandler: completionHandler)
            
        case .video(videoInfo: let videoInfo):
            
            var imageInfo = ImageInfo()
            imageInfo.photoid = videoInfo.videoId
            imageInfo.ishdimg = true
            
            uploadImageRequest(imageInfos: [imageInfo]) { (response) in
                
                switch response.result {
                case .success(let data):
                    
                    let json = JSON(data)
                    for jsonData in json["data"].arrayValue {
                        
                        let serverImageId = jsonData["attId"].stringValue
                        
                        
                        if let video = VideoModelInfo.getVideoModelInfo(by: videoInfo.videoId) {
                            
                            let serverVideoId = jsonData["attId"].stringValue
                            
                            _ = video.setValue(serverImageId, forKey: \.firstpicId)
                                .setValue(serverVideoId, forKey: \.serverVideoId)
                            
                        }
                        
                    }
                    
                    uploadVideoRequest(videoInfo: videoInfo, progressHandle: progressHandle, completionHandler: completionHandler)
                    
                case .failure(_):
                    completionHandler?(.init(request: nil, response: nil, data: nil, metrics: nil, serializationDuration: 0, result: .failure(.explicitlyCancelled)))
                    
                }
                
            }
            
            
        default: break
            
        }
        
    }
    
    static func uploadGroupHeader(roomID: String,
                                  image: UIImage,
                                  progressHandle: Request.ProgressHandler? = nil,
                                  completionHandler: ((AFDataResponse<Any>) -> Void)? = nil) {
        
        //
        //        var url = URL(string: HttpConfig.COD_GroupHeaderPic_UploadUrl)
        //
        //        if let roomId = roomID.int {
        //            url = url?.appendingQueryParameters([
        //                "roomid": roomId
        //            ])
        //        }
        
        
        
        let uploadRequest = HttpManager.share.manager.upload(multipartFormData: { (multipartFormData) in
            
            guard let pictureImageData = image.sd_imageData(as: .JPEG) else { return }
            multipartFormData.append(pictureImageData, withName: "file", fileName: UUID().uuidString, mimeType: "image/png");
            multipartFormData.append(roomID.data(using: .utf8) ?? Data(), withName: "roomid")
            
            
        }, to: HttpConfig.COD_GroupHeaderPic_UploadUrl, headers: self.headers, interceptor: afHttpAdapter).authenticate(with: ClientTrust.sendClientCer())
        
        self.uploadRequest(request: uploadRequest, progressHandle: progressHandle, completionHandler: completionHandler)
        
    }
    
    static func uploadHeader(image: UIImage,
                             progressHandle: Request.ProgressHandler? = nil,
                             completionHandler: ((AFDataResponse<Any>) -> Void)? = nil) {
        
        
        let uploadRequest = HttpManager.share.manager.upload(multipartFormData: { (multipartFormData) in
            
            guard let pictureImageData = image.sd_imageData(as: .JPEG) else { return }
            multipartFormData.append(pictureImageData, withName: "file", fileName: UUID().uuidString, mimeType: "image/png")
            
        }, to: HttpConfig.COD_HeaderPic_UploadUrl, headers: self.headers, interceptor: afHttpAdapter)
        
        self.uploadRequest(request: uploadRequest, progressHandle: progressHandle) { (response) in
            
            if let attId = JSON(response.value)["data"]["attId"].string {
                
                DispatchQueue.main.async {
                    UserManager.sharedInstance.avatar = attId
                    NotificationCenter.default.post(name: NSNotification.Name.init(kUpdateGKMeHeaderViewNoti), object: nil, userInfo: nil)
                }
                
            }
            
            
            completionHandler?(response)
            
        }
        
        
    }
    
    
    static func chatServerUploadImage(paramDic: [String: Any], photoid: String,receiver: String,
                                      progressBlock: ((Double) -> Void)? = nil,
                                      successBlock: ((_ imageId: String) -> Void)? = nil,
                                      faliedBlock: (() -> Void)? = nil) {
        
        if let pictureImageData = CODImageCache.default.originalImageCache?.diskImageData(forKey: photoid) {
            
            
            func uploadImage() {
                
                _ = HttpManager.share.postImage(imageData: pictureImageData, url: HttpConfig.uploadUrl, params: paramDic, progressBlock: { (progress) in
                    progressBlock?(progress)
                }, successBlock: { (successDic, json) in
                    
                    if let message = json["data"]["attId"].string  {
                        successBlock?(message)
                    } else {
                        faliedBlock?()
                    }
                    
                    
                }) { (_) in
                    faliedBlock?()
                }
                
            }
            
            
            var storeType = "MESSAGE"
            if receiver.contains(kCloudJid) {
                storeType = "CLOUDDISK"
            }
            
            let params = ["storeType":storeType,
                          "validSha512List":[
                            ["size":pictureImageData.count,
                             "type":"Image",
                             "sha512":pictureImageData.sha512()]
                ]
                ] as [String : Any]
            
            HttpManager.share.postWithUserInfo(url: HttpConfig.COD_Valida_File, param: params, successBlock: { (dic, json) in
                
                if let attid = json["data"].arrayValue.first?["attId"].string  {
                    successBlock?(attid)
                } else {
                    uploadImage()
                }
                
            }) { (error) in
                
                uploadImage()
                
            }
            
        }
        
    }
    
    static func chatServerUploadFile(paramDic: [String: Any], msgID: String,receiver: String,
                                      progressBlock: ((Double) -> Void)? = nil,
                                      successBlock: ((_ imageId: String) -> Void)? = nil,
                                      faliedBlock: (() -> Void)? = nil) {
        
        
        
        
        
        if let messageModel = CODMessageRealmTool.getMessageByMsgId(msgID), let fileinfo = messageModel.fileModel {
            
            let filePath = CODFileManager.shareInstanceManger().filePathWithName(sessionID: messageModel.toJID, fileName: "\(fileinfo.localFileID).\(fileinfo.filename.pathExtension)")
            
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath), options: .mappedRead) else {
                return
            }
            

            func uploadFile() {
                
                _ = HttpManager.share.postFile(video: data, url: HttpConfig.uploadUrl, fileName:fileinfo.filename, params: paramDic, progressBlock: { (progress) in
                    progressBlock?(progress)
                }, successBlock: { (successDic, json) in
                    
                    if let message = json["data"]["attId"].string  {
                        successBlock?(message)
                    } else {
                        faliedBlock?()
                    }
                    
                    
                }) { (_) in
                    faliedBlock?()
                }
                

            }
            
            
            var storeType = "MESSAGE"
            if receiver.contains(kCloudJid) {
                storeType = "CLOUDDISK"
            }
            
            let params = ["storeType":storeType,
                          "validSha512List":[
                            ["size":data.count,
                             "type":"Image",
                             "sha512":data.sha512()]
                ]
                ] as [String : Any]
            
            HttpManager.share.postWithUserInfo(url: HttpConfig.COD_Valida_File, param: params, successBlock: { (dic, json) in
                
                if let attid = json["data"].arrayValue.first?["attId"].string  {
                    successBlock?(attid)
                } else {
                    uploadFile()
                }
                
            }) { (error) in
                
                uploadFile()
                
            }
            
        }
        
    }
    
    static func chatServerUploadVideo(paramDic: [String: Any], videoId: String,
                                      progressBlock: ((Double) -> Void)? = nil,
                                      successBlock: ((_ videoId: String) -> Void)? = nil,
                                      faliedBlock: (() -> Void)? = nil) {
        
        
        print("================开始上传视频")
        
        let videoLocalURL = CODFileManager.shareInstanceManger().mp4PathWithName(fileName: videoId)
        let smallVideoURL: URL = URL.init(fileURLWithPath: videoLocalURL)
        
        if let videoData:Data = try? Data.init(contentsOf: smallVideoURL) {
            
            HttpManager.share.postVideo(video: videoData, url: HttpConfig.uploadUrl, params: paramDic, progressBlock: { (progress) in
                
                progressBlock?(progress)
                
            }, successBlock: { (success, jsonString) in
                
                print("=================视频上传成功")
                
                if let message = jsonString["data"]["attId"].string {
                    
                    DispatchQueue.main.async {
                        successBlock?(message)
                    }
                }
            }) { (_) in
                
                faliedBlock?()
                
            }
            
            
            
        }
        
    }
    
    static func precreateUploadPublishRelay(uploadId: String, file: FileType) {
        
        if uploadId.count == 0 {
            return
        }
        
        let publishRelay = BehaviorRelay<Result>(value: Result.progress(progress: 0))
        uploadTasksPublishRelay[uploadId] = publishRelay
        uploadFileInfos[uploadId] = file
        
    }
    
    
    static func upload(chatType: CODMessageChatType, receiver: String, fileType: FileType) -> Observable<Result> {
        
        var receivername = receiver
        
        if receivername.contains(kCloudJid) {
            receivername = "clouddisk"
        }
        
        
        var paramDic: [String: Any] = ["receivername": receivername,
                                       "type":chatType.uploadType,
                                       "ishdimg": "0",
                                       "filetype":fileType.stringValue]
        
        var behaviorRelay = BehaviorRelay<Result>(value: .progress(progress: 0))
        
        switch fileType {
        case .image(imageInfo: var imageInfo):
            
            paramDic["ishdimg"] = imageInfo.ishdimg.int.string
            
            if let preBehaviorRelay = uploadTasksPublishRelay[imageInfo.photoid] {
                behaviorRelay = preBehaviorRelay
            }
            
            uploadFileInfos[imageInfo.photoid] = fileType
            uploadTasksPublishRelay[imageInfo.photoid] = behaviorRelay
            
            let observable = Observable<Result>.create { (observer) -> Disposable in
                
                UploadTool.uploadTasksObserver[imageInfo.photoid] = observer
                
                PhotoModelInfo.updateInfo(photoId: imageInfo.photoid, uploadState: .Uploading)
                UploadTool.updateResult(imageInfo.photoid, result: .progress(progress: 0))
                
                chatServerUploadImage(paramDic: paramDic, photoid: imageInfo.photoid,receiver: receiver, progressBlock: { (progress) in
                    UploadTool.updateResult(imageInfo.photoid, result: .progress(progress: progress))
                }, successBlock: { (imageId) in
                    
                    imageInfo.serverPhotoId = imageId
                    
                    PhotoModelInfo.updateInfo(photoId: imageInfo.photoid, uploadState: .Finished, serverImageId: imageInfo.serverPhotoId)
                    UploadTool.updateResult(imageInfo.photoid, result: .success(file: .image(imageInfo: imageInfo)))
                    
                    UploadTool.uploadTasksPublishRelay.removeValue(forKey: imageInfo.photoid)
                    UploadTool.uploadTasksObserver.removeValue(forKey: imageInfo.photoid)
                    
                }) {
                    
                    PhotoModelInfo.updateInfo(photoId: imageInfo.photoid, uploadState: .Fail)
                    UploadTool.updateResult(imageInfo.photoid, result: .fail)
                    
                    UploadTool.uploadTasksPublishRelay.removeValue(forKey: imageInfo.photoid)
                    UploadTool.uploadTasksObserver.removeValue(forKey: imageInfo.photoid)
                    
                }
                
                return Disposables.create {
                }
                
            }
            
            return observable
            
        case .video(videoInfo: var videoInfo):
            
            guard let video = VideoModelInfo.getVideoModelInfo(by: videoInfo.videoId) else {
                return Observable.empty()
            }
            
            if video.uploadStateType == .Cancel {
                return Observable.empty()
            }
            
            paramDic["ishdimg"] = "0"
            paramDic["filetype"] = "Image"
            
            if let prePublishRelay = uploadTasksPublishRelay[videoInfo.videoId] {
                behaviorRelay = prePublishRelay
            }
            
            uploadFileInfos[videoInfo.videoId] = fileType
            
            let observable = Observable<Result>.create { (observer) -> Disposable in
                
                if video.uploadStateType == .Cancel {
                    observer.onCompleted()
                    return Disposables.create {
                    }
                }
                
                UploadTool.uploadTasksObserver[videoInfo.videoId] = observer
                
                
                PhotoModelInfo.updateInfo(photoId: videoInfo.videoId, uploadState: .Uploading)
                
                /// 上传首帧图片
                chatServerUploadImage(paramDic: paramDic, photoid: videoInfo.videoId, receiver: receiver, successBlock: { (imageId) in
                    
                    
                    if video.uploadStateType == .Cancel {
                        observer.onCompleted()
                        return
                    }
                    
                    _ = video.setValue(imageId, forKey: \.firstpicId)
                        .setValue(UploadStateType.Uploading.intValue, forKey: \.uploadState)
                    
                    let paramDic = ["file":".png",
                                    "receivername":receiver,
                                    "type": chatType.uploadType,
                                    "ishdimg": "0",
                                    "filetype":"MVideo"]
                    
                    videoInfo.serverFirstImageId = imageId
                    
                    /// 上传视频
                    chatServerUploadVideo(paramDic: paramDic, videoId: videoInfo.videoId, progressBlock: { (progress) in
                        
                        UploadTool.updateResult(videoInfo.videoId, result: .progress(progress: progress))
                        
                    }, successBlock: { (videoId) in
                        
                        videoInfo.serverVideoId = videoId
                        
                        _ = video.setValue(videoId, forKey: \.serverVideoId)
                            .setValue(UploadStateType.Finished.intValue, forKey: \.uploadState)
                        
                        UploadTool.updateResult(videoInfo.videoId, result: .success(file: .video(videoInfo: videoInfo)))
                        
                        UploadTool.uploadTasksPublishRelay.removeValue(forKey: videoInfo.videoId)
                        UploadTool.uploadTasksObserver.removeValue(forKey: videoInfo.videoId)
                        
                    }) {
                        
                        _ = video.setValue(UploadStateType.Fail.intValue, forKey: \.uploadState)
                        
                        UploadTool.updateResult(videoInfo.videoId, result: .fail)
                        
                        UploadTool.uploadTasksPublishRelay.removeValue(forKey: videoInfo.videoId)
                        UploadTool.uploadTasksObserver.removeValue(forKey: videoInfo.videoId)
                        
                    }
                    
                    
                }) {
                                        
                    _ = VideoModelInfo.updateInfo(videoId: videoInfo.videoId, value: UploadStateType.Fail.intValue, keypath: \.uploadState)
                    
                    UploadTool.uploadTasksPublishRelay.removeValue(forKey: videoInfo.videoId)
                    UploadTool.uploadTasksObserver.removeValue(forKey: videoInfo.videoId)
                    
                }
                
                return Disposables.create {
                }
                
            }
            
            
            return observable
            
        case .file(msgID: let msgID):
            
            guard let fileInfo = CODMessageRealmTool.getMessageByMsgId(msgID)?.fileModel else {
                return Observable.empty()
            }
            
            let localFileID = fileInfo.localFileID
            
            if let preBehaviorRelay = uploadTasksPublishRelay[fileInfo.localFileID] {
                behaviorRelay = preBehaviorRelay
            }
            
            let observable = Observable<Result>.create { (observer) -> Disposable in
                
                UploadTool.uploadTasksObserver[localFileID] = observer
                
                func _uploadFile() {
                    
                    chatServerUploadFile(paramDic: paramDic, msgID: msgID, receiver: receiver, progressBlock: { (progress) in
                        UploadTool.updateResult(localFileID, result: .progress(progress: progress))
                    }, successBlock: { (fileID) in
                        
                        guard let messageModel = CODMessageRealmTool.getMessageByMsgId(msgID) else {
                            observer.onCompleted()
                            return
                        }
                        
                        let filePath = CODFileManager.shareInstanceManger().filePathWithName(sessionID: messageModel.toJID, fileName: "\(fileInfo.localFileID).\(fileInfo.filename.pathExtension)")
                        
                        let newFilePath = CODFileManager.shareInstanceManger().filePathWithName(sessionID: messageModel.toJID, fileName: "\(fileID).\(fileInfo.filename.pathExtension)")
                        
                        do {
                            
                            try FileManager.default.moveItem(at: URL(fileURLWithPath: filePath), to: URL(fileURLWithPath: newFilePath))
                            fileInfo.setValue(\.fileID, value: fileID)
                            UploadTool.updateResult(localFileID, result: .success(file: .file(msgID: msgID)))
                            
                        } catch {
                            UploadTool.updateResult(localFileID, result: .fail)
                        }

                        
                        UploadTool.uploadTasksPublishRelay.removeValue(forKey: localFileID)
                        UploadTool.uploadTasksObserver.removeValue(forKey: localFileID)
                        observer.onCompleted()
                        
                    }) {
                        
                        UploadTool.updateResult(localFileID, result: .fail)
                        
                        UploadTool.uploadTasksPublishRelay.removeValue(forKey: localFileID)
                        UploadTool.uploadTasksObserver.removeValue(forKey: localFileID)
                        observer.onCompleted()
                        
                    }
                    
                }
                
                if fileInfo.isImageOrVideo {
                    
                    var imageParamDic = paramDic
                    
                    imageParamDic["filetype"] = "Image"
                    
                    chatServerUploadImage(paramDic: imageParamDic, photoid: localFileID, receiver: receiver, progressBlock: nil, successBlock: { (imageId) in
                        
                        fileInfo.setValue(\.thumb, value: imageId)
                        _uploadFile()
                        
                    }) {
                        
                        UploadTool.updateResult(localFileID, result: .fail)
                        
                        UploadTool.uploadTasksPublishRelay.removeValue(forKey: localFileID)
                        UploadTool.uploadTasksObserver.removeValue(forKey: localFileID)
                        observer.onCompleted()
                        
                    }
                    

                } else {
                    _uploadFile()
                }
                
                
                
                
                return Disposables.create {
                }
                
            }
            
            
            return observable
            

            
        default:
            break
        }
        
        
        return behaviorRelay.asObservable()
        
        
    }
    
//    static func uploadFile
    
    static func cancel(uploadId: String) {
        
        self.accept(uploadId, .cancal)
        UploadTool.uploadTasksPublishRelay.removeValue(forKey: uploadId)
        
        if let fileInfo =  UploadTool.uploadFileInfos[uploadId] {
            
            switch fileInfo {
            case .video(videoInfo: let videInfo):
                
                _ = VideoModelInfo.getVideoModelInfo(by: videInfo.videoId)?.setValue(UploadStateType.Cancel.intValue, forKey: \.uploadState)
                
            case .image(imageInfo: let videInfo):
                _ = PhotoModelInfo.getPhotoInfo(photoId: videInfo.photoid)?.setValue(\.uploadState, value: UploadStateType.Cancel.intValue)
                
            default:
                break
                
            }
            
            
        }
        
        uploadFileInfos.removeValue(forKey: uploadId)
        
        
        
    }
    
    static func accept(_ uploadId: String, _ result: Result) {
        
        if let publishRelay = self.uploadTasksPublishRelay[uploadId] {
            publishRelay.accept(result)
        }
        
        guard let observer = self.uploadTasksObserver[uploadId] else {
            return
        }
        
        observer.onNext(result)
        
        switch result {
        case .fail, .cancal, .success(file: _):
            observer.onCompleted()
            uploadTasksObserver.removeValue(forKey: uploadId)
        default:
            break
        }
        
    }
    
    static func updateResult(_ uploadId: String, result: Result) {
        
        self.accept(uploadId, result)
        
        if let uploadInfo = self.uploadFileInfos[uploadId] {
            
            switch uploadInfo {
            case .image(imageInfo: var imageInfo):
                imageInfo.result = result
                self.uploadFileInfos[uploadId] = .image(imageInfo: imageInfo)
            case .multipleImage(imageInfos: let imageInfos):
                self.uploadFileInfos[uploadId] = .multipleImage(imageInfos: imageInfos)
                
            default:
                break
            }
            
        }
        
    }
    
    
    
    
}
