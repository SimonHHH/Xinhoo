//
//  YBIBVideoTopBar.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/11.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBVideoTopBar.h"
#import "YBIBIconManager.h"

@interface YBIBVideoTopBar ()
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation YBIBVideoTopBar

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.shareButton];
        [self addSubview:self.playButton];
        [self addSubview:self.deleteButton];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat buttonWidth = 37;
    self.shareButton.frame = CGRectMake(0, 17, buttonWidth, buttonWidth);
    self.playButton.frame = CGRectMake((self.bounds.size.width - buttonWidth)/2, 17, buttonWidth, buttonWidth);
    self.deleteButton.frame = CGRectMake(self.bounds.size.width - buttonWidth, 17, buttonWidth, buttonWidth);
}

#pragma mark - public

+ (CGFloat)defaultHeight {
    return 50;
}

#pragma mark - hit test

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.playButton.frame, point)) {
        return self.playButton;
    }
    if (CGRectContainsPoint(self.shareButton.frame, point)) {
        return self.shareButton;
    }
    if (CGRectContainsPoint(self.deleteButton.frame, point)) {
        return self.deleteButton;
    }
    return nil;
}

- (void)clickPlayButton:(UIButton *)button {
    button.userInteractionEnabled = NO;
    if (button.selected) {
        [self.delegate yb_videoActionBar:self clickPauseButton:button];
    } else {
        [self.delegate yb_videoActionBar:self clickPlayButton:button];
    }
    button.userInteractionEnabled = YES;
}

- (void)clickDeleteButton:(UIButton *)button {
    button.userInteractionEnabled = NO;
    [self.delegate yb_videoActionBar:self clickDeleteButton:button];
    button.userInteractionEnabled = YES;
}
- (void)clickShareButton:(UIButton *)button {
    button.userInteractionEnabled = NO;
    [self.delegate yb_videoActionBar:self clickShareButton:button];
    button.userInteractionEnabled = YES;
}
#pragma mark - getter

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:YBIBIconManager.sharedManager.videoPauseImage() forState:UIControlStateSelected];
        [_playButton setImage:YBIBIconManager.sharedManager.videoPlayImage() forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (void)pause {
    self.playButton.selected = NO;
}

- (void)play {
    self.playButton.selected = YES;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton setImage:[UIImage imageNamed:@"share_pic"] forState:UIControlStateNormal];
    }
    return _shareButton;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"delete_pic"] forState:UIControlStateNormal];
    }
    return _deleteButton;
}
@end
