//
//  UIView+CustomCornerRadius.h
//  COD
//
//  Created by Xinhoo on 2019/12/9.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#import <UIKit/UIKit.h>

struct CornerRadius{
    CGFloat topLeft;
    CGFloat topRight;
    CGFloat bottomLeft;
    CGFloat bottomRight;
};
typedef struct CornerRadius CornerRadius;

NS_ASSUME_NONNULL_BEGIN

@interface UIView(CustomCornerRadius)

CornerRadius CornerRadiusMake(CGFloat topLeft,CGFloat topRight,CGFloat bottomLeft,CGFloat bottomRight);

- (void)setCustomCornerRaidus:(CornerRadius)cornerRadius size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
