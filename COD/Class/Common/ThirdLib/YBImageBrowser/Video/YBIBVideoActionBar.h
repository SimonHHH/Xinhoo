//
//  YBIBVideoActionBar.h
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/11.
//  Copyright © 2019 杨波. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YBIBVideoActionBar;
@class YBIBVideoTopBar;

@protocol YBIBVideoActionBarDelegate <NSObject>
@required

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar clickPlayButton:(UIButton *)playButton;

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar clickPauseButton:(UIButton *)pauseButton;

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar clickDeleteButton:(UIButton *)deleteButton;

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar clickShareButton:(UIButton *)shareButton;

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar changeValue:(float)value;

@end

@interface YBIBVideoActionBar : UIView

@property (nonatomic, weak) id<YBIBVideoActionBarDelegate> delegate;

- (void)setMaxValue:(float)value;

- (void)setCurrentValue:(float)value;

- (void)pause;

- (void)play;

- (void)isHiddenPlayButton: (BOOL)ishidden;

- (void)isHiddenShareAndDeleteButton: (BOOL)ishidden;


+ (CGFloat)defaultHeight;

@property (nonatomic, strong, readonly) UIButton *cancelButton;

@property (nonatomic, strong) UIButton *shareButton;


@end

NS_ASSUME_NONNULL_END
