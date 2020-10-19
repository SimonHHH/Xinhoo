//
//  CODChatConfig.swift
//  COD
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

open class CODChatConfig {
    /**
     获取缩略图的尺寸
     
     - parameter originalSize: 原始图的尺寸 size
     
     - returns: 返回的缩略图尺寸
     */
    class func getThumbImageSize(_ originalSize: CGSize) -> CGSize {
        
        var imageRealHeight = (originalSize.height) == 0 ? kChatImageMinHeight : originalSize.height
        var imageRealWidth = (originalSize.width) == 0 ? kChatImageMinWidth : originalSize.width
        
        let scale = imageRealHeight / imageRealWidth
        
        if imageRealHeight > imageRealWidth {
            if imageRealHeight > kChatImageMaxHeight {
                
                imageRealHeight = kChatImageMaxHeight
                imageRealWidth = imageRealHeight / scale
                
            }
            
            if imageRealHeight < kChatImageMinHeight {
                
                imageRealHeight = kChatImageMinHeight
                imageRealWidth = imageRealHeight / scale
                
            }
            
            if imageRealWidth < kChatImageMinWidth {
                imageRealWidth = kChatImageMinWidth
            }
            
        }else{
            
            if (imageRealWidth > kChatImageMaxWidth){
                
                imageRealWidth = kChatImageMaxWidth
                imageRealHeight = imageRealWidth * scale
                
            }
            
            if imageRealWidth < kChatImageMinWidth {
                
                imageRealWidth = kChatImageMinWidth
                imageRealHeight = imageRealWidth * scale
            }
            
            if imageRealHeight < kChatImageMinHeight {
                imageRealHeight = kChatImageMinHeight
            }
            
        }
        
        return CGSize(width: imageRealWidth, height: imageRealHeight)
        
    }
}



