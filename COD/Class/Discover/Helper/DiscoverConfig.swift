//
//  DiscoverConfig.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/23.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation


struct DiscoverConfig {
    
    static var maxImageWidth: CGFloat = 180
    static var minImageWidth: CGFloat = 58
    
    static func getThumbImageSize(_ originalSize: CGSize) -> CGSize {
        
        return DiscoverConfig.resetImgSize(originalSize: originalSize, maxImageLenght: maxImageWidth)
    }
    
    static func resetImgSize(originalSize: CGSize, maxImageLenght: CGFloat)  -> CGSize {
        
        let maxImageSize = maxImageLenght
        
        //先调整分辨率
        var newSize = CGSize(width: originalSize.width, height: originalSize.height)
        
        let tempHeight = newSize.height / maxImageSize;
        
        let tempWidth = newSize.width / maxImageSize;
        
        if (tempWidth > 1.0 && tempWidth > tempHeight) {
            
            newSize = CGSize.init(width: originalSize.width / tempWidth, height: originalSize.height / tempWidth)
            
        } else {
            
            newSize = CGSize.init(width: originalSize.width / tempHeight, height: originalSize.height / tempHeight)
            
        }
        
        if newSize.width < minImageWidth {
            newSize.width = minImageWidth
        }
        
        return newSize
        
        
    }
    
    
    
    
}
