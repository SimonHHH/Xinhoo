//
//  UIScrollView+Extensions.swift
//  COD
//
//  Created by 1 on 2019/3/11.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

extension UIScrollView{
    
    func offsetX() -> CGFloat{
        return self.contentOffset.x
    }
    func setOffsetX(offsetX:CGFloat,animation:Bool) {
        var point = self.contentOffset
        point.x = offsetX
        self.setContentOffset(point, animated: animation)
    }
    
    func offsetY() -> CGFloat{
        return self.contentOffset.y
    }
    func setOffsetY(offsetY:CGFloat,animation:Bool) {
        var point = self.contentOffset
        point.y = offsetY
        self.setContentOffset(point, animated: animation)
    }
    ///宽度
    func contentWidth() -> CGFloat {
        return self.contentSize.width;
    }
    func setCcontentWidth(contentWidth:CGFloat) {
        var size = self.contentSize
        size.width = contentWidth;
        self.contentSize = size
    }
    ///高度
    func contentHeight() -> CGFloat {
        return self.contentSize.height;
    }
    func setCcontentWidth(contentHeight:CGFloat) {
        var size = self.contentSize
        size.height = contentHeight;
        self.contentSize = size
    }
    /// 滚动到最顶端
    ///
    /// - Parameter animation: 动画
    func scrollToTopWithAnimation(animation:Bool) {
        self.setOffsetY(offsetY: 0, animation: animation)
    }
    
    ///  滚动到最底端
    ///
    /// - Parameter animation: 动画
    func scrollToBottomWithAnimation(animation:Bool)  {
        let viewHeight = self.frame.size.height
        if self.contentHeight() > viewHeight {
            let offsetY = self.contentHeight() - viewHeight
            self.setOffsetY(offsetY: offsetY, animation: animation)
        }
    }
    /// 滚动到最左端
    ///
    /// - Parameter animation: 动画
    func scrollToLeftWithAnimation(animation:Bool) {
        self.setOffsetX(offsetX: 0, animation: animation)
    }
    /// 滚动到最左端
    ///
    /// - Parameter animation: 动画
    func scrollToRightWithAnimation(animation:Bool) {
        let viewWidth = self.frame.size.width
        if self.contentWidth() > viewWidth {
            let offsetX = self.contentWidth() - viewWidth
            self.setOffsetX(offsetX: offsetX, animation: animation)
        }
    }
    
}
