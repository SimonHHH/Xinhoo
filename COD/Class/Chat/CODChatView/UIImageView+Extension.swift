
//
//  UIImageView+Extension.swift
//  JXUploadImageView
//
//  Created by 杜进新 on 2017/8/7.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit
import SDWebImage
import RxSwift

struct UIImageViewAssociatedKeys {
    static var _updateHeaderDispose: UInt8 = 0
}

extension UIImageView {
    
    func jx_setImage(obj:Any?) {
        guard let obj = obj else {
            return
        }
        if obj is UIImage {
            self.image = obj as? UIImage
        }
        
        if obj is String {
            let objStr = obj as! String
            if objStr.isEmpty == true {
                return
            }
            if objStr.hasPrefix("http") {
                jx_setImage(with: objStr, placeholderImage: nil)
            }else{
                self.image = UIImage(named: objStr)
            }
        }
    }
    
    func jx_setImage(with urlStr:String, placeholderImage: UIImage?,radius:CGFloat = 0){
        
        guard let url = URL(string: urlStr) else {
            self.image = placeholderImage
            return
        }
        self.sd_setImage(with: url, placeholderImage: placeholderImage, options: [], progress: nil) { (image, error, _, url) in
            
        }
    }
    
    var updateHeaderDispose: Disposable? {
        
        get {
            return objc_getAssociatedObject(self, &UIImageViewAssociatedKeys._updateHeaderDispose) as? Disposable
        }
        
        set {
            objc_setAssociatedObject(self, &UIImageViewAssociatedKeys._updateHeaderDispose, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        
        
    }
    
    func cod_loadHeaderByCache(url: URL?, completion: SDWebImageDownloaderCompletedBlock? = nil) -> SDWebImageDownloadToken? {
        
         self.image = UIImage(named: "default_header_80")
        
        guard let url = url else {
            completion?(nil, nil, NSError(), false)
            return nil
        }
        
       
        
        let userpic = url.getHeaderId()
                
        updateHeaderDispose?.dispose()
        
        updateHeaderDispose = NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: kRefreshHeaderNoti))
            .filter {  not in
                let userPicId = not.userInfo?["userPic"] as? String
                return userpic == userPicId
        }
        .map { $0.userInfo?["image"] as? UIImage }
        .filterNil()
        .bind(onNext: { [weak self] (image) in

            guard let `self` = self else { return }
            self.image = image

        })
        
        updateHeaderDispose?.disposed(by: self.rx.disposeBag)
                
        if let image = SDImageCache.shared.imageFromCache(forKey: CODImageCache.default.getCacheKey(url: url)) {
            self.image = image
        } else {
            
            return SDWebImageDownloader.shared.downloadImage(with: url, options: [.useNSURLCache, ], context: nil, progress: nil) { [weak self] (image, data, error, isOk) in
                
                if let image = image {
                    SDImageCache.shared.store(image, forKey: CODImageCache.default.getCacheKey(url: url), toDisk: true, completion: nil)
                    SDImageCache.shared.removeImageFromMemory(forKey: CODImageCache.default.getCacheKey(url: url))
                    self?.image = image
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRefreshHeaderNoti), object: nil, userInfo: [
                    "userPic": userpic,
                    "image": image as Any
                ])
                
                completion?(image, data, error, isOk)
            }
            
        }
        
        return nil
        
        
        
    }
    
    func cod_loadHeader(url: URL?, completion: SDWebImageDownloaderCompletedBlock? = nil) -> SDWebImageDownloadToken? {
        
        self.image = UIImage(named: "default_header_80")
        guard let url = url else {
            completion?(nil, nil, NSError(), false)
            return nil
        }
        
        
        let userpic = url.getHeaderId()
        
        if SDImageCache.shared.diskImageDataExists(withKey: CODImageCache.default.getCacheKey(url: url)) {
            self.image = SDImageCache.shared.imageFromCache(forKey: CODImageCache.default.getCacheKey(url: url))
        }
        
        updateHeaderDispose?.dispose()
        
        updateHeaderDispose = NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: kRefreshHeaderNoti))
            .filter {  not in
                let userPicId = not.userInfo?["userPic"] as? String
                return userpic == userPicId
        }
        .map { $0.userInfo?["image"] as? UIImage }
        .filterNil()
        .bind(onNext: { [weak self] (image) in

            guard let `self` = self else { return }
            self.image = image

        })
        
        updateHeaderDispose?.disposed(by: self.rx.disposeBag)
        
        return SDWebImageDownloader.shared.downloadImage(with: url, options: [.useNSURLCache, ], context: nil, progress: nil) { [weak self] (image, data, error, isOk) in
            
            if let image = image {
                SDImageCache.shared.store(image, forKey: CODImageCache.default.getCacheKey(url: url), toDisk: true, completion: nil)
                SDImageCache.shared.removeImageFromMemory(forKey: CODImageCache.default.getCacheKey(url: url))
                self?.image = image
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRefreshHeaderNoti), object: nil, userInfo: [
                "userPic": userpic,
                "image": image as Any
            ])
            
            completion?(image, data, error, isOk)
        }
    }
    
}
