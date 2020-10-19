//
//  YBIBImageView.h
//  COD
//
//  Created by 1 on 2019/8/14.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YBIBImageView : UIView

@property (nonatomic, strong, readonly) UIButton *shareButton;
@property (nonatomic, strong, readonly) UIButton *deleteButton;
@property (nonatomic, strong, readonly) UILabel *nameLabel;
@property (nonatomic, strong, readonly) UILabel *timeLabel;
- (void)hideToolBar:(BOOL)hide;

@end

NS_ASSUME_NONNULL_END
