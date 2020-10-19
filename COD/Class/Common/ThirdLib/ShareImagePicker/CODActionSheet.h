//
//  CODActionSheet.h
//  COD
//
//  Created by 1 on 2019/8/15.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>
@class CODActionSheet;

/**
 * block回调
 *
 * @param actionSheet CODActionSheet对象自身
 * @param index       被点击按钮标识,取消: 0, 删除: -1, 其他: 1.2.3...
 */
typedef void(^CODActionSheetBlock)(CODActionSheet *actionSheet, NSInteger index);

@interface CODActionSheet : UIView

/**
 * 创建CODActionSheet对象
 *
 * @param title                  提示文本
 * @param cancelButtonTitle      取消按钮文本
 * @param destructiveButtonTitle 删除按钮文本
 * @param otherButtonTitles      其他按钮文本
 * @param block                  block回调
 *
 * @return CODActionSheet对象
 */
- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
            cancelButtonColor:(UIColor *)cancelButtonColor
       destructiveButtonColor:(UIColor *)destructiveButtonColor
            otherButtonColors:(NSArray *)otherButtonColors
                      handler:(CODActionSheetBlock)actionSheetBlock NS_DESIGNATED_INITIALIZER;

/**
 * 创建CODActionSheet对象(便利构造器)
 *
 * @param title                  提示文本
 * @param cancelButtonTitle      取消按钮文本
 * @param destructiveButtonTitle 删除按钮文本
 * @param otherButtonTitles      其他按钮文本
 * @param block                  block回调
 *
 * @return CODActionSheet对象
 */
+ (instancetype)actionSheetWithTitle:(NSString *)title
                   cancelButtonTitle:(NSString *)cancelButtonTitle
              destructiveButtonTitle:(NSString *)destructiveButtonTitle
                   otherButtonTitles:(NSArray *)otherButtonTitles
                             handler:(CODActionSheetBlock)actionSheetBlock;

/**
 * 弹出CODActionSheet视图
 *
 * @param title                  提示文本
 * @param cancelButtonTitle      取消按钮文本
 * @param destructiveButtonTitle 删除按钮文本
 * @param otherButtonTitles      其他按钮文本
 * @param block                  block回调
 *
 * @return CODActionSheet对象
 */
+ (void)showActionSheetWithTitle:(NSString *)title
               cancelButtonTitle:(NSString *)cancelButtonTitle
          destructiveButtonTitle:(NSString *)destructiveButtonTitle
               otherButtonTitles:(NSArray *)otherButtonTitles
                         handler:(CODActionSheetBlock)actionSheetBlock;

/**
 * 弹出CODActionSheet视图
 *
 * @param title                  提示文本
 * @param cancelButtonTitle      取消按钮文本
 * @param destructiveButtonTitle 删除按钮文本
 * @param otherButtonTitles      其他按钮文本
 * @param block                  block回调
 * @param superView              自定义的父视图

 * @return CODActionSheet对象
 */
+ (void)showActionSheetWithTitle:(NSString *)title
               cancelButtonTitle:(NSString *)cancelButtonTitle
          destructiveButtonTitle:(NSString *)destructiveButtonTitle
               otherButtonTitles:(NSArray *)otherButtonTitles
                       superView:(UIView *)superView
                         handler:(CODActionSheetBlock)actionSheetBlock;

+ (void)showActionSheetWithTitle:(NSString *)title
               cancelButtonTitle:(NSString *)cancelButtonTitle
          destructiveButtonTitle:(NSString *)destructiveButtonTitle
               otherButtonTitles:(NSArray *)otherButtonTitles
               cancelButtonColor:(UIColor *)cancelButtonColor
          destructiveButtonColor:(UIColor *)destructiveButtonColor
               otherButtonColors:(NSArray *)otherButtonColors
                         handler:(CODActionSheetBlock)actionSheetBlock;

+ (void)showActionSheetWithTitle:(NSString *)title
               cancelButtonTitle:(NSString *)cancelButtonTitle
          destructiveButtonTitle:(NSString *)destructiveButtonTitle
               otherButtonTitles:(NSArray *)otherButtonTitles
               cancelButtonColor:(UIColor *)cancelButtonColor
          destructiveButtonColor:(UIColor *)destructiveButtonColor
               otherButtonColors:(NSArray *)otherButtonColors
                       superView:(UIView *)superView
                         handler:(CODActionSheetBlock)actionSheetBlock;
/**
 * 弹出视图
 */
- (void)show;

/**
 * 移除视图
 */
- (void)dismiss;

@end
