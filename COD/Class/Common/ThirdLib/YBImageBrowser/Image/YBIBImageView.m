//
//  YBIBImageView.m
//  COD
//
//  Created by 1 on 2019/8/14.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#import "YBIBImageView.h"
#import "YBIBImageActionBar.h"

@interface YBIBImageView ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation YBIBImageView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
        [self addSubview:self.shareButton];
        [self addSubview:self.nameLabel];
        [self addSubview:self.timeLabel];
        [self addSubview:self.deleteButton];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat buttonWidth = 37;
    self.shareButton.frame = CGRectMake(0, 17, buttonWidth, buttonWidth);
    self.nameLabel.frame = CGRectMake((self.bounds.size.width - buttonWidth*5)/2, 17, buttonWidth*5, 18);
    self.timeLabel.frame = CGRectMake((self.bounds.size.width - buttonWidth*5)/2, 17 + 19, buttonWidth*5, 18);
    self.deleteButton.frame = CGRectMake(self.bounds.size.width - buttonWidth, 17, buttonWidth, buttonWidth);
}
#pragma mark - public

+ (CGFloat)defaultHeight {
    return 50;
}
#pragma mark - hit test

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  
    if (CGRectContainsPoint(self.shareButton.frame, point)) {
        return self.shareButton;
    }
    if (CGRectContainsPoint(self.deleteButton.frame, point)) {
        return self.deleteButton;
    }
    return nil;
}


- (void)clickDeleteButton:(UIButton *)button {
    button.userInteractionEnabled = NO;
//    [self.delegate yb_videoActionBar:self clickDeleteButton:button];
    button.userInteractionEnabled = YES;
}
- (void)clickShareButton:(UIButton *)button {
    button.userInteractionEnabled = NO;
//    [self.delegate yb_videoActionBar:self clickShareButton:button];
    button.userInteractionEnabled = YES;
}
#pragma mark - getters & setters
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:15];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment =  NSTextAlignmentCenter;
        _timeLabel.backgroundColor = [UIColor clearColor];
    }
    return _nameLabel;
}
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:15];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textAlignment =  NSTextAlignmentCenter;
    }
    return _timeLabel;
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




