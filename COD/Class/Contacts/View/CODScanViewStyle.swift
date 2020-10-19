//
//  CODScanViewStyle.swift
//  COD
//
//  Created by 1 on 2019/3/15.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

public struct CODScanViewStyle
{
    // MARK: - -中心位置矩形框
    
    /// 是否需要绘制扫码矩形框，默认YES
    public var isNeedShowRetangle:Bool = true
    
    /**
     *  默认扫码区域为正方形，如果扫码区域不是正方形，设置宽高比
     */
    public var whRatio:CGFloat = 1.0
    
    /**
     @brief  矩形框(视频显示透明区)域向上移动偏移量，0表示扫码透明区域在当前视图中心位置，如果负值表示扫码区域下移
     */
    public var centerUpOffset:CGFloat = 54
    
    /**
     *  矩形框(视频显示透明区)域离界面左边及右边距离，默认60
     */
    public var xScanRetangleOffset:CGFloat = (KScreenWidth - 248)/2
    
    /**
     @brief  矩形框线条颜色，默认白色
     */
    public var colorRetangleLine = UIColor.white
    
    //4个角的颜色
    public var colorAngle = UIColor(red: 0.0, green: 167.0/255.0, blue: 231.0/255.0, alpha: 1.0)
    
    //扫码区域4个角的宽度和高度
    public var photoframeAngleW:CGFloat = 15.0
    public var photoframeAngleH:CGFloat = 15.0
    /**
     @brief  扫码区域4个角的线条宽度,默认6，建议8到4之间
     */
    public var photoframeLineW:CGFloat = 1
    
    /**
     *  动画效果的图像，如线条或网格的图像
     */
    public var animationImage:UIImage?
    
    
    // MARK: -非识别区域颜色,默认 RGBA (0,0,0,0.5)，范围（0--1）
    public var color_NotRecoginitonArea:UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5);
    
    public init()
    {
        
    }
}


