//
//  CustomUtil+ImageLoadTools.swift
//  COD
//
//  Created by Sim Tsai on 2020/6/17.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

extension CustomUtil{
    
    class func loadSmallImage(from videoInfo: VideoModelInfo?, isCloudDisk: Bool = false, closuer: ((UIImage?) -> ())? = nil) {
        
        guard let videoInfo = videoInfo else {
            closuer?(nil)
            return
        }
        
        
        if let image = CODImageCache.default.smallImageCache?.imageFromCache(forKey: videoInfo.videoId) {
            closuer?(image)
        } else {
            

            SDImageLoadersManager.shared.loadImage(with: URL(string: videoInfo.firstpicId.getImageFullPath(imageType: 1, isCloudDisk: isCloudDisk)), options: [], context: nil, progress: nil) { (image, _, _, _) in
                closuer?(image)
            }

        }

    }
    
}
