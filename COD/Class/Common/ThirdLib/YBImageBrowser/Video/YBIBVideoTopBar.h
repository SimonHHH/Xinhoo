//
//  YBIBVideoTopBar.h
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/11.
//  Copyright © 2019 杨波. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YBIBVideoActionBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface YBIBVideoTopBar : UIView

- (void)pause;

- (void)play;

@property (nonatomic, weak) id<YBIBVideoActionBarDelegate> delegate;

+ (CGFloat)defaultHeight;

@end

NS_ASSUME_NONNULL_END
