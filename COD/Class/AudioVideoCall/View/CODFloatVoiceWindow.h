//
//  CODFloatVoiceWindow.h
//  COD
//
//  Created by Xinhoo on 2019/8/27.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CODFloatBaseWindow.h"

NS_ASSUME_NONNULL_BEGIN

@interface CODFloatVoiceWindow : CODFloatBaseWindow

@property (nonatomic, strong) UIImageView* imgHead;

- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
