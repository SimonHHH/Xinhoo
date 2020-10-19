//
//  CODImageCache.swift
//  COD
//
//  Created by Sim Tsai on 2020/3/13.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import SDWebImage
import Foundation

class CODImageCache {
    
    static let `default` = CODImageCache()
    
    var smallImageCache: SDImageCache? = nil
    var originalImageCache: SDImageCache? = nil
    var downloadImageCache: SDImageCache? = nil
    
    #if MANGO
    let customHost = "mango"
    #elseif PRO
    let customHost = "flygram"
    #else
    let customHost = "xinhoo"
    #endif
    
    func getCacheKey(url: URL) -> String {
        if var host = url.host {
        
            if let port = url.port {
                host = "\(host):\(port)"
            }
            
            var urlString = url.absoluteString
            urlString = urlString.replacingOccurrences(of: host, with: self.customHost)
            return urlString
        }
        return url.absoluteString
    }
    
    func setup() {
        
        let maxDiskAge: TimeInterval = 60 * 60 * 24 * 365
        
        SDWebImageManager.shared.cacheKeyFilter = SDWebImageCacheKeyFilter.init(block: { (url) -> String in

            return self.getCacheKey(url: url)
        })
        
        smallImageCache = SDImageCache(namespace: "small", diskCacheDirectory: CODFileManager.shareInstanceManger().pathUserPath())
        smallImageCache?.config.maxDiskAge = maxDiskAge
        
        originalImageCache = SDImageCache(namespace: "original", diskCacheDirectory: CODFileManager.shareInstanceManger().pathUserPath())
        originalImageCache?.config.maxDiskAge = maxDiskAge
        
        downloadImageCache = SDImageCache(namespace: "download", diskCacheDirectory: CODFileManager.shareInstanceManger().pathUserPath())
        downloadImageCache?.config.maxDiskAge = maxDiskAge
        
        SDWebImageManager.defaultImageCache = downloadImageCache
        
        SDImageCache.shared.config.maxDiskAge = maxDiskAge


    }
    
    
    
}
