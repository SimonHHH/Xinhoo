//
//  JXPhotoBrowserImageCell+PicDownload.swift
//  COD
//
//  Created by 1 on 2020/8/10.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import JXPhotoBrowser
extension JXPhotoBrowserImageCell{
//    private struct AssociatedKey {
//        static var downloader: SDWebImageDownloadToken = SDWebImageDownloadToken()
//        static var URLString: String = ""
//
//    }
//
//    public var downloader: SDWebImageDownloadToken {
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKey.downloader) as? SDWebImageDownloadToken ?? SDWebImageDownloadToken()
//        }
//
//        set {
//            objc_setAssociatedObject(self, &AssociatedKey.downloader, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
    
//    public var URLString: String {
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKey.URLString) as? String ?? ""
//        }
//
//        set {
//            objc_setAssociatedObject(self, &AssociatedKey.URLString, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
//        }
//    }
    
    func imageDownWithUrl(url: URL , msgID: String ,isNeedLoading: Bool ) {
        
        
        if let imagePath = CustomUtil.movePicPathToConversation(picUrl: url, filePath: ""),imagePath.count > 0 {
            
            if let imageData = NSData.init(contentsOf: URL.init(string: imagePath)!) as Data? {
                self.imageView.image = UIImage.init(data: imageData)
                self.setNeedsLayout()

            }
        }else{
            
            YBIBWebImageManager.queryCacheOperation(forKey: url) {[weak self]  (image, imageData) in
                guard let `self` = self else {
                    return
                }
                if image != nil {
                    self.imageView.image = image
                    self.setNeedsLayout()

                }else if imageData != nil {
                    self.imageView.image = UIImage.init(data: imageData!)
                    self.setNeedsLayout()

                }else{
                    if isNeedLoading {
                        self.downLoadWebImage(url: url, msgID: msgID)
                    }else {
                        self.downLoadWebImageWithNoLoading(url: url, msgID: msgID)
                    }
                }
            }
        }

    }
    
    func downLoadWebImageWithNoLoading(url: URL , msgID: String) {
          CustomUtil.imageVeiwDownLoad(picUrl: url, imageView: imageView, placeholderImage: nil, filePath: "") {[weak self] (image, error, cacheType, url) in
            guard let `self` = self else {
                return
            }
              dispatch_async_safely_to_main_queue {
                  if image != nil {
                    self.imageView.image = image
                    YBIBWebImageManager.storeToDisk(withImageData: image?.pngData(), forKey: url ?? URL(fileURLWithPath: ""))
                    self.setNeedsLayout()

                  }
              }
          }
    }
    
    func downLoadWebImage(url: URL , msgID: String ) {
        
        CODImageCache.default.originalImageCache?.diskImageDataExists(withKey: url.absoluteString)

        _ = SDWebImageDownloader.shared.downloadImage(with: url, options: [.progressiveLoad,.avoidDecodeImage,.lowPriority], progress: { [weak self] (receivedSize, expectedSize, targetURL) in
            guard let `self` = self else {
                return
            }
             if receivedSize > 0,expectedSize > 0{
                dispatch_async_safely_to_main_queue {
                    self.ybib_showLoading(withProgress: CGFloat(receivedSize) * 1.0 / CGFloat(expectedSize))
                }
             }
         }) { [weak self] (image, imageData, error, finished) in
            guard let `self` = self else {
                return
            }
             dispatch_async_safely_to_main_queue {
                self.ybib_hideLoading()
                 self.imageView.image = UIImage.init(data:  imageData  ?? Data())
                  _ = CustomUtil.movePicPathToConversation(picUrl: url, filePath: "")
                 YBIBWebImageManager.storeToDisk(withImageData: imageData, forKey: url)
                self.setNeedsLayout()

             }
            } ?? SDWebImageDownloadToken()
    }
    
//    @objc func `deinit`() {
//
//        self.downloader.cancel()
//    }
    
    
}

