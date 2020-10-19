//
//  UIView+CustomCornerRadius.m
//  COD
//
//  Created by Xinhoo on 2019/12/9.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#import "UIView+CustomCornerRadius.h"

@implementation UIView(CustomCornerRadius)

CornerRadius CornerRadiusMake(CGFloat topLeft,CGFloat topRight,CGFloat bottomLeft,CGFloat bottomRight){
     return (CornerRadius){
          topLeft,
          topRight,
          bottomLeft,
          bottomRight,
     };
}

+ (CGPathRef)CGPathCreateWithRoundedRect:(CGRect)bounds cornerRadius:(CornerRadius)cornerRadius {
     const CGFloat minX = CGRectGetMinX(bounds);
     const CGFloat minY = CGRectGetMinY(bounds);
     const CGFloat maxX = CGRectGetMaxX(bounds);
     const CGFloat maxY = CGRectGetMaxY(bounds);
     
     const CGFloat topLeftCenterX = minX +  cornerRadius.topLeft;
     const CGFloat topLeftCenterY = minY + cornerRadius.topLeft;
     
     const CGFloat topRightCenterX = maxX - cornerRadius.topRight;
     const CGFloat topRightCenterY = minY + cornerRadius.topRight;
     
     const CGFloat bottomLeftCenterX = minX +  cornerRadius.bottomLeft;
     const CGFloat bottomLeftCenterY = maxY - cornerRadius.bottomLeft;
     
     const CGFloat bottomRightCenterX = maxX -  cornerRadius.bottomRight;
     const CGFloat bottomRightCenterY = maxY - cornerRadius.bottomRight;
     
     CGMutablePathRef path = CGPathCreateMutable();
     CGPathAddArc(path, NULL, topLeftCenterX, topLeftCenterY,cornerRadius.topLeft, M_PI, 3 * M_PI_2, NO);
     CGPathAddArc(path, NULL, topRightCenterX , topRightCenterY, cornerRadius.topRight, 3 * M_PI_2, 0, NO);
     CGPathAddArc(path, NULL, bottomRightCenterX, bottomRightCenterY, cornerRadius.bottomRight,0, M_PI_2, NO);
     CGPathAddArc(path, NULL, bottomLeftCenterX, bottomLeftCenterY, cornerRadius.bottomLeft, M_PI_2,M_PI, NO);
     CGPathCloseSubpath(path);
     return path;
}

- (void)setCustomCornerRaidus:(CornerRadius)cornerRadius size:(CGSize)size {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CGPathRef path = [UIView CGPathCreateWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:cornerRadius];
    shapeLayer.path = path;
    CGPathRelease(path);
    self.layer.mask = shapeLayer;
}

@end
