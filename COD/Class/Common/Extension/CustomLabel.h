//
//  CustomLabel.h
//  test
//
//  Created by Clement on 15/3/26.
//  Copyright (c) 2015年 Clement. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomLabel : UILabel

@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic) CGFloat lineHeight;

-(CGFloat)heightOfLabel:(id)sender;

/*
  下列方法，当需要用到设置内边距和行间距的时候使用。
  以下方法中，如果已经设置过了lineHeight,insets,font,text,width可将0或者nil作为实参传递
 */
-(void)setLabelStyleWithLineHeight:(CGFloat)lineHeight inset:(UIEdgeInsets )insets;
-(void)setLabelStyleWithLineHeight:(CGFloat)lineHeight inset:(UIEdgeInsets )insets font:(UIFont *)font;
-(void)setLabelStyleWithLineHeight:(CGFloat)lineHeight inset:(UIEdgeInsets )insets font:(UIFont *)font text:(NSString *)text;
-(void)setLabelStyleWithLineHeight:(CGFloat)lineHeight inset:(UIEdgeInsets )insets font:(UIFont *)font text:(NSString *)text width:(CGFloat)width;

@end
