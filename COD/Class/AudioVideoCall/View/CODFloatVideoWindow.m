//
//  CODFloatVideoWindow.m
//  COD
//
//  Created by Xinhoo on 2019/8/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#import "CODFloatVideoWindow.h"

@implementation CODFloatVideoWindow


- (void)initSetup {
    [super initSetup];
    
    self.viewCover = [[UIView alloc] initWithFrame:CGRectZero];
    self.viewCover.backgroundColor = [UIColor clearColor];
    [self addSubview:self.viewCover];
    [self.viewCover addGestureRecognizer:tapGestureRecognizer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.viewCover.frame = self.bounds;
}


@end
