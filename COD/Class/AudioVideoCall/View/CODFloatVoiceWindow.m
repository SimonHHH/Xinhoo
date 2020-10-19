//
//  CODFloatVoiceWindow.m
//  COD
//
//  Created by Xinhoo on 2019/8/27.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#import "CODFloatVoiceWindow.h"
#import "RippleAnimationView.h"

#define  circleDiameter       50.f

@interface CODFloatVoiceWindow()

@property (nonatomic, strong) RippleAnimationView* rippleView;

@end

@implementation CODFloatVoiceWindow

- (void)initSetup {
    [super initSetup];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.imgHead = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, circleDiameter, circleDiameter)];
    self.imgHead.layer.masksToBounds = YES;
    self.imgHead.layer.cornerRadius = circleDiameter/2;
    [self addSubview:self.imgHead];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGPoint center = [self convertPoint:self.center fromWindow:[[UIApplication sharedApplication] keyWindow]];
    self.imgHead.center = center;
    self.rippleView.center = center;
}

- (RippleAnimationView *)rippleView {
    if (!_rippleView) {
        _rippleView = [[RippleAnimationView alloc] initWithFrame:CGRectMake(0, 0, circleDiameter, circleDiameter) animationType:AnimationTypeWithBackground];
        _rippleView.multiple = self.bounds.size.width/circleDiameter;
    }
    
    return _rippleView;
}

- (void)show {
    [self refreshPosition];
    [self insertSubview:self.rippleView belowSubview:self.imgHead];
    self.hidden = NO;
}

- (void)hide {
    self.hidden = YES;
    self.floatViewTapBlock = nil;
    [self.rippleView removeFromSuperview];
    self.rippleView = nil;
}


@end
