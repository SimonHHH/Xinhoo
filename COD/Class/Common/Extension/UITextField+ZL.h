//
//  UITextField+ZL.h
//  UITextFieldDeleteDemo
//
//  Created by 钟亮 on 2018/7/26.
//  Copyright © 2018年 zhongliang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WJTextFieldDelegate <UITextFieldDelegate>
@optional
- (void)textFieldDidDeleteBackward:(UITextField *)textField;
@end
@interface UITextField (WJ)
@property (weak, nonatomic) id<WJTextFieldDelegate> delegate;
@end
/**
 *  监听删除按钮
 *  object:UITextField
 */
extern NSString * const WJTextFieldDidDeleteBackwardNotification;
