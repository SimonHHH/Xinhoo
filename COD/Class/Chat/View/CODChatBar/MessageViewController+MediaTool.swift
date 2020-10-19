//
//  MessageViewController+MediaTool.swift
//  COD
//
//  Created by 1 on 2019/3/28.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

extension MessageViewController{

    //压缩图片
    func compressImage(pictureImage: UIImage,isGIF: Bool = false) -> Data {
    
        if isGIF {
            
        }
        
        return pictureImage.pngData() ?? Data()
    }


}
