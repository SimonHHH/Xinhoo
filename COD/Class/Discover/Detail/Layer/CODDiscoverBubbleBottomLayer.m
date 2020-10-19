//
//  CODDiscoverBubbleLayer.m
//  COD
//
//  Created by Sim Tsai on 2020/6/23.
//  Copyright © 2020 XinHoo. All rights reserved.
//

#import "CODDiscoverBubbleBottomLayer.h"

@implementation CODDiscoverBubbleBottomLayer

// 绘制气泡形状,获取path
- (CGPathRef )bubblePath {
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 获取绘图所需要的关键点
    NSMutableArray *points = [self keyPoints];
    
    // 第一步是要画箭头的“第一个支点”所在的那个角，所以要把“笔”放在这个支点顺时针顺序的上一个点
    // 所以把“笔”放在最后才画的矩形框的角的位置, 准备开始画箭头
    CGPoint currentPoint = [[points objectAtIndex:6] CGPointValue];
    CGContextMoveToPoint(ctx, currentPoint.x, currentPoint.y);
    
    CGPoint pointA, pointB;  //用于 CGContextAddArcToPoint函数
    CGFloat radius;
    int i = 0;
    
    while(1) {
        
        // 整个过程需要画七个角，所以分为七个步骤
        if (i > 6)
            break;
        
        // 箭头处的三个圆角和矩形框的四个圆角不一样
        radius = i < 3 ?  self.arrowRadius : self.cornerRadius;
        
        if (i == 4 || i == 5)
            radius = 0;

        pointA = [[points objectAtIndex:i] CGPointValue];
        
        
        // 画矩形框最后一个角的时候，pointB就是points[0]
        pointB = [[points objectAtIndex:(i+1)%7] CGPointValue];

        CGContextAddArcToPoint(ctx, pointA.x, pointA.y, pointB.x, pointB.y, radius);
        i = i + 1;
    }

    // 获取path
    CGContextClosePath(ctx);
    CGPathRef path = CGContextCopyPath(ctx);
    UIGraphicsEndImageContext();
    return path;
}

@end
