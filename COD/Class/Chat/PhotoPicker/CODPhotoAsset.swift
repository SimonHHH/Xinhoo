//
//  CODPhotoAsset.swift
//  COD
//
//  Created by 1 on 2019/3/27.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Photos

class CODPhotoAsset: NSObject {
    /// 是否选中
    public  var isSelected = false
    /// 是否显示可选按钮
    public var isEnableSelected = false
    /// 是否可点击
    public  var isEnable = true
    /// 图片集合
    public var asset = PHAsset()
    /// 照片在指定相册中的索引（同一张照片在不同相册中索引不同）
    public  var index : Int = 0
    public init(asset:PHAsset) {
        self.asset = asset
    }
    public var photoImage: UIImage?

    public override init() {
        super.init()
    }
}
