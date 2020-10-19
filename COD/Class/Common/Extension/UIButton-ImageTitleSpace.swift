//
//  UIButton-ImageTitleSpace.swift
//  Gooker
//
//  Created by Wilson on 2018/7/31.
//  Copyright © 2018 Libiao. All rights reserved.
//

import UIKit

///Button iamge title style
public enum CODButtonStyle: Int {
    case top    = 1
    case left   = 5
    case right  = 10
    case bottom = 15
}

/**
 *  titleEdgeInsets是title相对于其上下左右的inset
 *  如果只有title/image，那它上下左右都是相对于button
 *  如果同时有image和label，那这时候image的 上左下 是相对于button，右边是相对于label的；label的上右下是相对于button，左边是相对于image
 */
extension UIButton {
    public func CODButtonImageTitle(style: CODButtonStyle = .top, titleImgSpace: CGFloat) {
        // 1. 得到imageView和titleLabel的宽、高
        let imageWith:   CGFloat = self.imageView!.frame.size.width
        let imageHeight: CGFloat = self.imageView!.frame.size.height
        var labelWidth:  CGFloat = 0.0
        var labelHeight: CGFloat = 0.0
        
        // 由于iOS8中titleLabel的size为0，用下面的这种设置
        labelWidth = (self.titleLabel?.intrinsicContentSize.width)!
        labelHeight = (self.titleLabel?.intrinsicContentSize.height)!
        
        // 2. 声明全局的imageEdgeInsets和labelEdgeInsets
        var imageEdgeInsets = UIEdgeInsets.zero
        var labelEdgeInsets = UIEdgeInsets.zero
        
        // 3. 根据style和space得到imageEdgeInsets和labelEdgeInsets的值
        switch (style) {
        case .top:
            imageEdgeInsets = UIEdgeInsets(top: -labelHeight-titleImgSpace/2.0, left: 0, bottom: 0, right: -labelWidth);
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWith, bottom: -imageHeight-titleImgSpace/2.0, right: 0);
            break
        case .left:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -titleImgSpace/2.0, bottom: 0, right: titleImgSpace/2.0);
            labelEdgeInsets = UIEdgeInsets(top: 0, left: titleImgSpace/2.0, bottom: 0, right: -titleImgSpace/2.0);
            break
        case .bottom:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -labelHeight-titleImgSpace/2.0, right: -labelWidth);
            labelEdgeInsets = UIEdgeInsets(top: -imageHeight-titleImgSpace/2.0, left: -imageWith, bottom: 0, right: 0);
            break
        case .right:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth+titleImgSpace/2.0, bottom: 0, right: -labelWidth-titleImgSpace/2.0);
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWith-titleImgSpace/2.0, bottom: 0, right: imageWith+titleImgSpace/2.0);
            break
        }
        
        // 4. 赋值
        self.titleEdgeInsets = labelEdgeInsets;
        self.imageEdgeInsets = imageEdgeInsets;
    }
}
