//
//  CODFloatBaseWindow.m
//  COD
//
//  Created by Xinhoo on 2019/8/27.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#import "CODFloatBaseWindow.h"
//#import "COD-Swift.h"
#define DIFFER   50
#define HORIZONTAL_DIFFER   20

@implementation CODFloatBaseWindow

- (instancetype)init {
    if (self = [super init]) {
        [self initSetup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initSetup];
    }
    return self;
}

- (void)initSetup {
    self.hidden = YES;
    
    self.windowLevel = UIWindowLevelAlert + 1;
    self.backgroundColor = [UIColor blackColor];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureRecognizer:)];
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    
     CGPoint currentPoint = [touch locationInView:[[UIApplication sharedApplication] keyWindow]];
    //CGPoint prevPoint = [touch previousLocationInView:[[UIApplication sharedApplication] keyWindow]];
    
    self.center = currentPoint;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self refreshPosition];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self refreshPosition];
}

- (void)tapGestureRecognizer:(UITapGestureRecognizer*)recognizer {
    if (self.floatViewTapBlock) {
        self.floatViewTapBlock();
    }
}

- (void)refreshPosition {
    CGRect rec = self.frame;
    
    if (rec.origin.x < HORIZONTAL_DIFFER) {
        rec = CGRectMake(HORIZONTAL_DIFFER, rec.origin.y, rec.size.width, rec.size.height);
    }
    
    if (rec.origin.y < (kNavigationBarHeight + kSafeTopHeight - 9)) {
        rec = CGRectMake(rec.origin.x, kNavigationBarHeight + kSafeTopHeight - 9, rec.size.width, rec.size.height);
    }
    
    if (rec.origin.x > kScreenWidth - HORIZONTAL_DIFFER - rec.size.width) {
        rec = CGRectMake(kScreenWidth - HORIZONTAL_DIFFER - rec.size.width, rec.origin.y, rec.size.width, rec.size.height);
    }
    
    if (rec.origin.y > kScreenHeight - rec.size.height - kSafeBottomHeight) {
        rec = CGRectMake(rec.origin.x, kScreenHeight - rec.size.height - kSafeBottomHeight, rec.size.width, rec.size.height);
    }
    
//    self.frame = rec;
    
//    if (rec.origin.y <= 5 + DIFFER && rec.origin.y >= 5) {
//        rec = CGRectMake(rec.origin.x, 5, rec.size.width, rec.size.height);
//    } else if (rec.origin.y <= kScreenHeight - rec.size.height - 5 && rec.origin.y >= kScreenHeight - rec.size.height - 5 - DIFFER) {
//        rec = CGRectMake(rec.origin.x, kScreenHeight - rec.size.height - 5, rec.size.width, rec.size.height);
//    } else {
        if ((rec.origin.x + rec.size.width/2) >= kScreenWidth/2.f) {
            rec = CGRectMake(kScreenWidth - rec.size.width - HORIZONTAL_DIFFER, rec.origin.y, rec.size.width, rec.size.height);
        } else {
            rec = CGRectMake(HORIZONTAL_DIFFER, rec.origin.y, rec.size.width, rec.size.height);
        }
//    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = rec;
    }];
}

@end
