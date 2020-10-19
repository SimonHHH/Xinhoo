//
//  CODFloatBaseWindow.h
//  COD
//
//  Created by Xinhoo on 2019/8/27.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GloableDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface CODFloatBaseWindow : UIWindow {
    UITapGestureRecognizer *tapGestureRecognizer;
}

@property (nonatomic, copy, nullable) void(^floatViewTapBlock)(void);

- (void)initSetup;

- (void)refreshPosition;

@end

NS_ASSUME_NONNULL_END
