//
//  CustomUtil+PictrueTool.swift
//  COD
//
//  Created by 1 on 2020/4/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
//图片
extension CustomUtil{
    
    class func getImagePickController(maxImagesCount: Int, delegate: TZImagePickerControllerDelegate!) -> TZImagePickerController? {
        let tzImgPicker = TZImagePickerController.init(maxImagesCount: maxImagesCount, delegate: delegate)
        tzImgPicker?.showSelectedIndex = false
        tzImgPicker?.showPhotoCannotSelectLayer = true
        tzImgPicker?.naviBgColor = UIColor.black
        tzImgPicker?.naviTitleColor = UIColor.white
        tzImgPicker?.iconThemeColor = UIColor.init(hexString: "007EE5")
        tzImgPicker?.oKButtonTitleColorNormal = UIColor.init(hexString: "007EE5")
        tzImgPicker?.oKButtonTitleColorDisabled = UIColor.init(hexString: "007EE5")?.withAlphaComponent(0.5)
        tzImgPicker?.photoSelImage = UIImage.init(named: "person_selected")
        tzImgPicker?.photoOriginSelImage = UIImage.init(named: "person_selected")
        tzImgPicker?.modalPresentationStyle = .fullScreen
        tzImgPicker?.preferredLanguage = CustomUtil.getCurrentLanguage()
        tzImgPicker?.barItemTextFont = UIFont.systemFont(ofSize: 17)
        tzImgPicker?.cancelBtnTitleStr = NSLocalizedString("取消  ", comment: "")
        return tzImgPicker
    }
    class func getImageURL(message: CODMessageModel) -> String {
        if message.photoModel?.photoLocalURL.count ?? 0 > 0 {
            
            let fileImageStr: String = CODFileManager.shareInstanceManger().eMConversationFilePath ?? ""
            let fileArray: [String] = fileImageStr.components(separatedBy: "/message/")
            if fileArray.count > 0, let fileString: String = fileArray.first,message.photoModel?.photoLocalURL.contains("/message/") ?? false {
                
                if  let stringArray = message.photoModel?.photoLocalURL.components(separatedBy: "/message/") , stringArray.count > 0 , let imageString: String = stringArray.last {
                    let imageStr = fileString + "/message/" + imageString
                    if imageStr.hasSuffix(".png") {
                        return imageStr
                    }else{
                        return imageStr + ".png"
                    }
                }
            }
            
            if  let stringArray = message.photoModel?.photoLocalURL.components(separatedBy: "/Images/") , stringArray.count > 0 , let imageString: String = stringArray.last {
                
                let imageArray = imageString.components(separatedBy: ".")
                if  imageArray.count > 0 , let imageName = imageArray.first {
                    let filePath = CODFileManager.shareInstanceManger().imagePathWithName(fileName: imageName)
                    return filePath
                }
            }
            
        }
        return ""
    }
    
    class func getVideoURL(message: CODMessageModel, isCloudDisk: Bool = false) -> URL? {
        var urlString = ""
        
        guard let video = message.videoModel else {
            return nil
        }
        
        let mp4Path = CODFileManager.shareInstanceManger().mp4PathWithName(fileName: video.videoId)
        
        if FileManager.default.fileExists(atPath: mp4Path) {
            return URL(fileURLWithPath: mp4Path)
        } else {
            return URL(string: video.serverVideoId.getImageFullPath(imageType: 1,isCloudDisk: isCloudDisk))
        }
        
    }
    
    
    class func getPictureID(fileIDs: Array<String>)-> Array<String>{
        var returnFiles: Array<String> = []
        
        for fileID in fileIDs {
            if fileID.hasPrefix("https") {
                
                let lastPath = fileID.lastPathComponent
                if let result = lastPath.range(of: ".*?(?=\\?)", options: .regularExpression, range: lastPath.startIndex..<lastPath.endIndex, locale: nil)  {
                    returnFiles.append(lastPath.substring(with: result))
                }
            }else{
                returnFiles.append(fileID)
            }
        }
        return returnFiles
    }
    
    class func getPictureID(picUrl: URL?)-> String? {
        return picUrl?.lastPathComponent
    }
    
    static let placeholderImage = UIImage(named: "Normal_Placeholder")!
    static let pictureLoadFailImage = UIImage.init(named: "Failed_load_Placeholder")!
    
    class func getPlaceholderImage(imageSize: CGSize = .zero) -> UIImage{
        
        return placeholderImage
    }
    
    class func getPictureLoadFailImage(imageSize: CGSize = .zero) -> UIImage{
        
        return pictureLoadFailImage
    }
    
    //这里是移除传完整的路径地址
    class func removeImageCahch(imageUrl: String){
        if HttpManager.share.isHaveNet() {
            let url = URL(string: imageUrl)
            if let _ = SDWebImageManager.shared.cacheKey(for: url) {
                SDImageCache.shared.removeImage(forKey: url?.absoluteString, fromDisk: true) {
                }
            }
            let mD5Url = imageUrl.md5()
            let filePath = CODFileManager.shareInstanceManger().imagePathWithName(fileName: mD5Url)
            ///已经下载 文件存在
            if (FileManager.default.fileExists(atPath: filePath)){
                try! FileManager.default.removeItem(atPath: filePath)
            }
        }
    }
    
    //这里是清除头像地址
    class func removeHeaderImageCahch(picID: String){
        
        //在有网络的情况下再去执行
        if HttpManager.share.isHaveNet() {
            let headTypes = [0,1,2,3]
            for imageType in headTypes {
                let url = URL(string: picID.getHeaderImageFullPath(imageType: imageType))
                if let _ = SDWebImageManager.shared.cacheKey(for: url) {
                    SDImageCache.shared.removeImage(forKey: url?.absoluteString, fromDisk: true) {
                    }
                }
            }
        }
        
    }
    
    class func compressVideoWithPHAsset(messageModel: CODMessageModel, completion: ((_ savedPath:String?) -> Void)? = nil) {
        
        guard let videoModel = messageModel.videoModel, let assetLocalIdentifier = videoModel.assetLocalIdentifier else {
            return
        }
        
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetLocalIdentifier], options: nil).firstObject else {
            return
        }
        

        let manager = PHImageManager.default()
        let savePath = CODFileManager.shareInstanceManger().mp4PathWithName(fileName: videoModel.videoId)
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.version = PHVideoRequestOptionsVersion.current
        options.deliveryMode = PHVideoRequestOptionsDeliveryMode.automatic
        let msgID = messageModel.msgID
        manager.requestAVAsset(forVideo: asset, options: options) { (avAsset, avAudioMix, info) in
            guard info != nil else {
                return
            }
            guard let asset1 = avAsset as? AVURLAsset else {
                return
            }
            let url = asset1.url.absoluteString
            //            CODMessager
            if url.count > 0 {
                CODVideoCompressTool.compressVideoV2(asset1.url, withOutputUrl: NSURL.init(fileURLWithPath: savePath) as URL, complete: { (success) in
                    
                    
                    if success {
                        let smallVideoURLString = String(format: "file:///%@", savePath )
                        if let smallVideoURL: URL = URL(string: smallVideoURLString),let smallData:Data = try? Data(contentsOf: smallVideoURL){
                            let afterData = smallData.count / 1048576
                            print("压缩后大小：\(afterData)")
                            
                            dispatch_async_safely_to_queue(DispatchQueue.main, {
                                
                                if let model = CODMessageRealmTool.getMessageByMsgId(msgID) {
                                    
                                    _ = model.videoModel?.setValue(smallData.count, forKey: \.size)
                                    
                                    completion?(savePath)
                                    
                                    
                                    
                                }
                                
                            })
                            
                        }
                        print("完成")
                    }
                })
            }else {
                print("获取AVAsset失败")
            }
        }
    }
}

//文件下载
extension CustomUtil{
    
    typealias VideoNetSuccessBlock = (URL) -> Void
    typealias VideoNetFaliedBlock  = (String) -> Void
    typealias VideoProgressBlock  = (CGFloat) -> Void

    @objc class func loadMP4Data(url: String,progressBlock:@escaping VideoProgressBlock,successBlock:@escaping VideoNetSuccessBlock,faliedBlock:@escaping VideoNetFaliedBlock) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kSendVoiceStopPlay), object: nil)
        
        guard let videoUrl = URL(string: url)else {
            faliedBlock("url isVaile")
            return
        }
        
        if url.hasPrefix("file://") {
            successBlock(videoUrl)
            return;
        }
        let mD5Url = url.md5()
        let filePath = CODFileManager.shareInstanceManger().mp4PathWithName(fileName: mD5Url)
        ///已经下载 文件存在
        if (FileManager.default.fileExists(atPath: filePath)){
            //            self.playLocalMP4(url: URL(fileURLWithPath:filePath))
            successBlock(URL(fileURLWithPath:filePath))
            return;
        }
        var urlString = URLRequest(url: videoUrl)
        let nameStr = String(format: "%@:%@",UserManager.sharedInstance.loginName ?? "",UserManager.sharedInstance.password ?? "")
        let utf8Data = nameStr.data(using: String.Encoding.utf8)
        let base64String = utf8Data?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        let authValue = String(format: "Basic %@", base64String ?? "")
        //var headers = ["Accept":"*/*","Authorization":authValue]
        urlString.setValue("*/*", forHTTPHeaderField: "Accept")
        urlString.setValue(authValue, forHTTPHeaderField: "Authorization")
        urlString.setValue(UserManager.sharedInstance.session ?? "", forHTTPHeaderField:"xh-user-token")
        urlString.setValue(UserManager.sharedInstance.loginName ?? "", forHTTPHeaderField:"xh-user-name")
        urlString.setValue(UserManager.sharedInstance.resource ?? "", forHTTPHeaderField:"xh-user-resource")
        
        let destination = DownloadRequest.suggestedDownloadDestination(
            for: .documentDirectory,
            in: .userDomainMask
        )

        HttpManager.share.requestManager = HttpManager.share.manager.download(urlString, interceptor: afHttpAdapter, to: destination).authenticate(with: ClientTrust.sendClientCer()).downloadProgress { (progress) in
            
            progressBlock(CGFloat(progress.fractionCompleted))
            
        }.response {(response) in
            if let error = response.error {
                ///下载失败清空下载文件
                if((response.fileURL) != nil){
                    self.removeFile(fileURL: response.fileURL!)
                }
                
                //                    CODProgressHUD.showErrorWithStatus("下载文件失败")
                faliedBlock(error.localizedDescription)
            } else {
                ///下载好的文件移动文件到新的文件夹
                
                guard let downURL = response.fileURL else {
                    faliedBlock("播放文件出错")
                    return
                }
                
                if FileManager.default.fileExists(atPath:downURL.path) {
                    do {
                        try FileManager.default.moveItem(at: downURL, to: URL(fileURLWithPath: filePath))
                        ///播放
                        //                            self?.playLocalMP4(url: URL(fileURLWithPath:filePath))
                        successBlock(URL(fileURLWithPath:filePath))
                    }catch{
                        //                            CODProgressHUD.showErrorWithStatus("播放文件出错")
                        faliedBlock("播放文件出错")
                        ///删除临时下载文件
                        self.removeFile(fileURL: downURL)
                        return;
                    }
                }else{
                    //                        CODProgressHUD.showErrorWithStatus("播放文件出错")
                    faliedBlock("播放文件出错")
                }
            }
        }
    }
    
    @objc class func getCurrentMd5UrlString(url: String) -> String {
        if url.hasPrefix("file://") {
            
            return url
        }else{
            
            let mD5Url = url.md5()
//            let filePath = CODFileManager.shareInstanceManger().mp4PathWithName(fileName: mD5Url)
            return mD5Url
        }

        
    }
    
    //删除临时下载文件
    class func removeFile(fileURL:URL) {
        do{
            try FileManager.default.removeItem(at: fileURL)
        }catch{
        }
    }
    //删除整个tmp临时文件夹
    class func removeTmpFile() {
        let fileManger = FileManager.default
        let tmpFileManger = NSTemporaryDirectory()
        let files:[AnyObject]? = fileManger.subpaths(atPath: tmpFileManger)! as [AnyObject]
        for file in files!
        {
            do{
                //删除指定位置的内容
                try fileManger.removeItem(atPath: tmpFileManger + "/\(file)")
                print("Success to remove folder")
            }catch{
                print("Failder!")
            }
        }
    }
    
    class func downLoadImageThumbNailPic(_ fromJID: String,_ photoModel: CODMessageModel){
        
        var jid = ""
        if fromJID.contains(UserManager.sharedInstance.loginName!) {
            jid = photoModel.toJID
        }else{
            jid = fromJID
        }
        
        let photoUrl = photoModel.photoModel?.serverImageId.getImageFullPath(imageType: 0, isCloudDisk: jid.contains(kCloudJid))
        //        let mD5Url = (photoUrl?.md5() ?? "") + ".png"
        //        let filePath = self.pathUserPathWithPhoto(jid: jid, pathStirng: "Images")
        //        let imageString = filePath.appendingPathComponent(mD5Url)
        self.sdThumbImageView(picUrl:  URL.init(string: photoUrl ?? "")!, imageView: UIImageView.init(), placeholderImage: nil) { (image, error, cacheType, url) in
            //            if !FileManager.default.fileExists(atPath: filePath) {
            //                   do{
            //                       try FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            //                   }catch{
            //                       CCLog("创建用户文件失败!")
            //                   }
            //            }
            //            self.moveThumbPathToConversation(picUrl: URL.init(string: photoUrl ?? "")!, filePath: imageString)
        }
    }
    @objc class func sdThumbImageView(picUrl: URL,imageView: UIImageView,placeholderImage: UIImage?,completedBlock: SDExternalCompletionBlock?){
        
        imageView.sd_setImage(with: picUrl, placeholderImage: placeholderImage, options: []) { (image, error, cacheType, url) in
            if completedBlock != nil {
                completedBlock!(image, error, cacheType, url)
            }
        }
    }
    
    class func pathUserPathWithPhoto(jid:String, pathStirng: String) -> String{
        
        
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documnetPath = documentPaths[0]
        var userDocumnetPath = documnetPath.appendingPathComponent(UserManager.sharedInstance.loginName!).appendingPathComponent("message").appendingPathComponent(jid).appendingPathComponent(pathStirng)
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
    
    @objc class func imageVeiwDownLoad(picUrl: URL,imageView: UIImageView, placeholderImage: UIImage?,filePath: String?, autoPlay:Bool = false, completedBlock: SDExternalCompletionBlock?){
        
        CODImageCache.default.originalImageCache?.diskImageDataExists(withKey: picUrl.absoluteString)
        
        if let imagePath = self.movePicPathToConversation(picUrl: picUrl, filePath: filePath),imagePath.count > 0 {
            if let imageData = NSData.init(contentsOf: URL.init(string: imagePath)!) as Data? {
                
                if autoPlay {
                    if let flImageView = imageView as? FLAnimatedImageView {
                        flImageView.animatedImage = FLAnimatedImage(gifData: imageData)
                    }
                }else{
                    imageView.image = UIImage.init(data: imageData)
                }
                
                
                //                (UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL)
                if completedBlock != nil {
                    completedBlock!(imageView.image, nil,.memory, picUrl)
                }
            }else{
                self.sdImageView(picUrl: picUrl, imageView: imageView, placeholderImage: placeholderImage,completedBlock: completedBlock)
            }
        }else{
            self.sdImageView(picUrl: picUrl, imageView: imageView, placeholderImage: placeholderImage,completedBlock: completedBlock)
        }
    }
    
    @objc class func sdImageView(picUrl: URL,imageView: UIImageView,placeholderImage: UIImage?,completedBlock: SDExternalCompletionBlock?){
        
        imageView.sd_setImage(with: picUrl, placeholderImage: placeholderImage, options: [.progressiveLoad]) { (image, error, cacheType, url) in
            if completedBlock != nil {
                completedBlock!(image, error, cacheType, url)
            }
        }
    }
    
    @objc class func getPicPathToConversation(picUrl: String) -> String {
        let url = picUrl
        if url.hasPrefix("file://") {
            return url
        }
        let mD5Url = url.md5()
        let filePath = CODFileManager.shareInstanceManger().imagePathWithName(fileName: mD5Url)
        if (FileManager.default.fileExists(atPath: filePath)){
            
            return filePath
        }
        return ""
    }
    
    class func moveThumbPathToConversation(picUrl: URL,filePath: String) {
        let url = picUrl.absoluteString
        let mD5Url = url.md5()
        
        if (FileManager.default.fileExists(atPath: filePath)){
            
        }else{
            
            if SDWebImageManager.shared.cacheKey(for: picUrl) != nil {
                
                let paths:Array = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                
                if paths.count > 0 {
                    
                    let imagePath = paths[0]
                    //                    var imagePath = userCacheDirectory
                    var newImageUrl = imagePath.appendingPathComponent("com.hackemist.SDImageCache")
                    newImageUrl = newImageUrl.appendingPathComponent("default")
                    newImageUrl = newImageUrl.appendingPathComponent(mD5Url)
                    var oldImageUrl = imagePath.appendingPathComponent("default")
                    oldImageUrl = oldImageUrl.appendingPathComponent("com.hackemist.SDWebImageCache.default")
                    oldImageUrl = oldImageUrl.appendingPathComponent(mD5Url)
                    if (FileManager.default.fileExists(atPath: newImageUrl)){
                        do {
                            try FileManager.default.copyItem(atPath: newImageUrl, toPath: filePath)
                            print("图片路径拷贝成功")
                            //                                return newImageUrl
                        } catch {
                            print("图片路径拷贝失败")
                        }
                    }else {
                        if (FileManager.default.fileExists(atPath: oldImageUrl)) {
                            do {
                                try FileManager.default.copyItem(atPath: oldImageUrl, toPath: filePath)
                                print("图片路径拷贝成功")
                                //                                    return oldImageUrl
                            } catch {
                                print("图片路径拷贝失败")
                            }
                        }
                    }
                }
            }
        }
        //            return ""
    }
    
    class func photoFileExists(picUrl: URL?) -> Bool {
        
        guard let url = picUrl?.absoluteString  else {
            return false
        }
        
        if url.hasPrefix("file://") {
            return true
        }
        let mD5Url = url.md5()
        
        if SDImageCache.shared.diskImageDataExists(withKey: picUrl?.absoluteString) {
            return true
        }
        
        return FileManager.default.fileExists(atPath: CODFileManager.shareInstanceManger().imagePathWithName(fileName: mD5Url))
    }
    
    @objc class func movePicPathToConversation(picUrl: URL,filePath: String?, msgId: String) -> String? {
        
        guard let message =  CODMessageRealmTool.getMessageByMsgId(msgId), let filePath = filePath, let fileModel = message.fileModel else {
            return nil
        }
        
        message.fileModel?.setValue(\.downloadState, value: DownloadStateType.Finished.intValue)

        try? FileManager.default.moveItem(at: URL(fileURLWithPath: filePath), to: URL(fileURLWithPath: fileModel.saveFilePath))
        
        if CODFileHelper.getFileType(fileName: fileModel.filename) == .ImageType {
            return self.movePicPathToConversation(picUrl: picUrl,filePath: filePath)
        } else {
            return nil
        }
        
    }
        
    @objc class func movePicPathToConversation(picUrl: URL,filePath: String?) -> String? {
        
        let url = picUrl.absoluteString
        if url.hasPrefix("file://") {
            return url
        }
        let mD5Url = url.md5()
        var fileString = ""
        if filePath?.removeAllSapce.count ?? 0 == 0{
            fileString = CODFileManager.shareInstanceManger().imagePathWithName(fileName: mD5Url)
        }else{
            fileString = filePath ?? ""
        }
        if !fileString.contains("/Images") {
            return ""
        }
        //        let filePath: String = CODFileManager.shareInstanceManger().imagePathWithName(fileName: mD5Url)
        if (FileManager.default.fileExists(atPath: fileString)){
            
            return fileString
        }else{
            
            if SDWebImageManager.shared.cacheKey(for: picUrl) != nil {
                
                let paths:Array = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                if paths.count > 0 {
                    
                    let imagePath = paths[0]
                    //                    var imagePath = userCacheDirectory
                    var newImageUrl = imagePath.appendingPathComponent("com.hackemist.SDImageCache")
                    newImageUrl = newImageUrl.appendingPathComponent("default")
                    newImageUrl = newImageUrl.appendingPathComponent(mD5Url)
                    var oldImageUrl = imagePath.appendingPathComponent("default")
                    oldImageUrl = oldImageUrl.appendingPathComponent("com.hackemist.SDWebImageCache.default")
                    oldImageUrl = oldImageUrl.appendingPathComponent(mD5Url)
                    if (FileManager.default.fileExists(atPath: newImageUrl)){
                        do {
                            try FileManager.default.copyItem(atPath: newImageUrl, toPath: fileString)
                            return newImageUrl
                        } catch {
                        }
                    }else {
                        if (FileManager.default.fileExists(atPath: oldImageUrl)) {
                            do {
                                try FileManager.default.copyItem(atPath: oldImageUrl, toPath: fileString)
                                return oldImageUrl
                            } catch {
                            }
                        }
                    }
                }
            }
        }
        return ""
    }
    
    @objc class func conversionImageWithView(view:UIView) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage ?? nil
    }
    
    @objc class func copyMediaFile(messageModel: CODMessageModel,fromPathJid: String = "",toPathJid: String = "") {
        switch messageModel.type {
        case .video:

            self.copyVideoFile(messageModel: messageModel, fromPathJid: fromPathJid, toPathJid: toPathJid)
            break
        case .image:

            self.copyImageFile(messageModel: messageModel, fromPathJid: fromPathJid, toPathJid: toPathJid)
            break
        case .file:
            
            self.copyFileVideoOrImageFile(messageModel: messageModel, fromPathJid: fromPathJid, toPathJid: toPathJid)
            break

        case .audio:
            
            self.copyVoiceFile(messageModel: messageModel, fromPathJid: fromPathJid, toPathJid: toPathJid)
            break
            
        default: break
            
            
        }

    }
    
    @objc class func copyVideoFile(messageModel: CODMessageModel,fromPathJid: String = "",toPathJid: String = "") {
        
        if let _ = messageModel.videoModel?.serverVideoId.getImageFullPath(imageType: 1) {
            
            var filePathMD5 = (messageModel.videoModel?.serverVideoId.getImageFullPath(imageType: 1, isCloudDisk: fromPathJid.contains(kCloudJid)) ?? "").md5()
            let toPathMD5 = (messageModel.videoModel?.serverVideoId.getImageFullPath(imageType: 1, isCloudDisk: toPathJid.contains(kCloudJid)) ?? "").md5()
            if fromPathJid == DiscoverHomeCache {
                filePathMD5 = ServerUrlTools.getMomentsServerUrl(fileType: .Video(messageModel.videoModel?.serverVideoId ?? ""))
            }
            let filePath = CODFileManager.shareInstanceManger().mp4PathWithName(sessionID: fromPathJid, fileName: filePathMD5)
            let toPath = CODFileManager.shareInstanceManger().mp4PathWithName(sessionID: toPathJid, fileName: toPathMD5)
            
            if (FileManager.default.fileExists(atPath: filePath)){
                
                do{
                    try   FileManager.default.copyItem(atPath: filePath, toPath: toPath)
                }catch{
                    print("保存失败_video")
                }
            }
        }
    }
    
    @objc class func copyImageFile(messageModel: CODMessageModel,fromPathJid: String = "",toPathJid: String = "") {
        
        let imageTypes = [0,1,2,3]
        
        for imageType in imageTypes {
            
            if let _ = messageModel.photoModel?.serverImageId.getImageFullPath(imageType: imageType) {
                var filePathMD5 = (messageModel.photoModel?.serverImageId.getImageFullPath(imageType: imageType, isCloudDisk: fromPathJid.contains(kCloudJid)) ?? "").md5()
                let toPathMD5 = (messageModel.photoModel?.serverImageId.getImageFullPath(imageType: imageType, isCloudDisk: toPathJid.contains(kCloudJid)) ?? "").md5()
                if fromPathJid == DiscoverHomeCache {
                    filePathMD5 = ServerUrlTools.getMomentsServerUrl(fileType: .Image(messageModel.photoModel?.serverImageId ?? "", .medium)).md5()
                }

                let filePath = CODFileManager.shareInstanceManger().imagePathWithName(sessionID: fromPathJid, fileName: filePathMD5)
                let toPath = CODFileManager.shareInstanceManger().imagePathWithName(sessionID: toPathJid, fileName: toPathMD5)
                if (FileManager.default.fileExists(atPath: filePath)){
                    
                    do{
                        try   FileManager.default.copyItem(atPath: filePath, toPath: toPath)
                    }catch{
                        print("保存失败_image")
                    }
                }
            }
            
        }
            
    }
    
    @objc class func copyVoiceFile(messageModel: CODMessageModel,fromPathJid: String = "",toPathJid: String = "") {
        
        var audioID = ""
        
        audioID = (messageModel.audioModel!.audioURL)
        if let localURL = messageModel.audioModel?.audioLocalURL, localURL.count > 0 {
            audioID = localURL
        }
        
        if audioID.count > 0 {
             
            var audioID = ""
            audioID = (messageModel.audioModel!.audioURL)
            if (messageModel.audioModel?.audioLocalURL.count)! > 0{
                audioID = messageModel.audioModel?.audioLocalURL.lastPathComponent ?? ""
            }
            let filePath = CODFileManager.shareInstanceManger().mp3PathWithName(sessionID: fromPathJid, fileName: audioID)
            let toPath = CODFileManager.shareInstanceManger().mp3PathWithName(sessionID: toPathJid, fileName: audioID)
            if (FileManager.default.fileExists(atPath: filePath)){
                
                do{
                    try   FileManager.default.copyItem(atPath: filePath, toPath: toPath)
                }catch{
                    print("保存失败_video")
                }
            }
        }
    }
    
    @objc class func copyFileVideoOrImageFile(messageModel: CODMessageModel,fromPathJid: String = "",toPathJid: String = "") {
        
        let suffix: String = messageModel.fileModel?.filename.pathExtension ?? ""
        
        let fileID = messageModel.fileModel?.fileID ?? ""

        let filePath = CODFileManager.fileManger.filePathWithName(sessionID: fromPathJid,fileName: "\(fileID).\(suffix)")
        let toPath = CODFileManager.fileManger.filePathWithName(sessionID: toPathJid,fileName: "\(fileID).\(suffix)")

        if (FileManager.default.fileExists(atPath: filePath)){

            do{
                try   FileManager.default.copyItem(atPath: filePath, toPath: toPath)
            }catch{
                print("保存失败_image")
            }
        }
        
    }
    
}
