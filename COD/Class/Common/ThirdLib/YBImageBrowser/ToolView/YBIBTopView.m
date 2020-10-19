//
//  YBIBTopView.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/6.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBTopView.h"
#import "YBIBIconManager.h"
#import "YBIBUtilities.h"

@interface YBIBTopView ()
@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, strong) UIButton *operationButton;
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation YBIBTopView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.pageLabel];
        [self addSubview:self.operationButton];
        [self addSubview:self.cancelButton];
        [self setOperationType:YBIBTopViewOperationTypeMore];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat height = self.bounds.size.height, width = self.bounds.size.width;
    self.pageLabel.frame = CGRectMake((width - width / 3)/2, 10, width / 3, height);
    CGFloat buttonWidth = 100;
    self.cancelButton.frame = CGRectMake(10, 10, buttonWidth, height);
    self.operationButton.frame = CGRectMake(width - buttonWidth/2, 12, buttonWidth/2, height);
}

#pragma mark - public

+ (CGFloat)defaultHeight {
    return 50;
}

- (void)setPage:(NSInteger)page totalPage:(NSInteger)totalPage {
    if (totalPage <= 1) {
        self.pageLabel.hidden = YES;
    } else {
        self.pageLabel.hidden  = NO;
        
        NSString *text = [NSString stringWithFormat:@"%ld/%ld", page + (NSInteger)1, totalPage];
        NSShadow *shadow = [NSShadow new];
        shadow.shadowBlurRadius = 4;
        shadow.shadowOffset = CGSizeMake(0, 1);
        shadow.shadowColor = UIColor.darkGrayColor;
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSShadowAttributeName:shadow}];
        self.pageLabel.attributedText = attr;
    }
}

#pragma mark - event

- (void)clickOperationButton:(UIButton *)button {
    if (self.clickOperation) self.clickOperation(self.operationType);
}

#pragma mark - hit test

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.operationButton.frame, point)) {
        return self.operationButton;
    }
    if (CGRectContainsPoint(self.cancelButton.frame, point)) {
        return self.cancelButton;
    }
    return nil;
}

#pragma mark - getters & setters

- (void)setOperationType:(YBIBTopViewOperationType)operationType {
    _operationType = operationType;
    
    UIImage *image = nil;
    switch (operationType) {
        case YBIBTopViewOperationTypeSave:
            image = [YBIBIconManager sharedManager].toolSaveImage();
            break;
        case YBIBTopViewOperationTypeMore:
            image = [YBIBIconManager sharedManager].toolMoreImage();
            break;
    }
    
    [self.operationButton setImage:image forState:UIControlStateNormal];
}

- (UILabel *)pageLabel {
    if (!_pageLabel) {
        _pageLabel = [UILabel new];
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.font = [UIFont boldSystemFontOfSize:16];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _pageLabel;
}

- (UIButton *)operationButton {
    if (!_operationButton) {
        _operationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _operationButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _operationButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_operationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_operationButton addTarget:self action:@selector(clickOperationButton:) forControlEvents:UIControlEventTouchUpInside];
        _operationButton.layer.shadowColor = UIColor.darkGrayColor.CGColor;
        _operationButton.layer.shadowOffset = CGSizeMake(0, 1);
        _operationButton.layer.shadowOpacity = 1;
        _operationButton.layer.shadowRadius = 4;
        [_operationButton setHidden:YES];
    }
    return _operationButton;
}
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton setTitle:@"返回" forState:UIControlStateNormal];
        [_cancelButton setImage:[UIImage imageNamed:@"back_pic"] forState:UIControlStateNormal];
        [_cancelButton setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
        [_cancelButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        //        [_cancelButton setContentEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
//        [_cancelButton addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return _cancelButton;
}


@end
