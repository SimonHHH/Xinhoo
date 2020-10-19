//
//  CustomLabel.m
//  test
//
//  Created by Clement on 15/3/26.
//  Copyright (c) 2015年 Clement. All rights reserved.
//

#import "CustomLabel.h"

@implementation CustomLabel

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}


-(CGFloat)heightOfLabel:(id)sender
{
    if ([sender isKindOfClass:[UILabel class]]) {
        UILabel *lab = (UILabel *)sender;
        return [self heightWithWidth:lab.frame.size.width font:lab.font text:lab.text];
    }
    
    return 30;
}

-(CGFloat)heightWithWidth:(CGFloat)width font:(UIFont *)font text:(NSString *)text
{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        CGSize sizeToFit = [text sizeWithFont:font
                            constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                lineBreakMode:NSLineBreakByWordWrapping];
        return sizeToFit.height;
    }
    else
    {
        NSMutableDictionary *attribute = [[NSMutableDictionary alloc]init];
        if (self.lineHeight != 0) {
            NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc]init];
            paraStyle.lineSpacing = self.lineHeight;
            
            [attribute setObject:paraStyle forKey:NSParagraphStyleAttributeName];
        }
        [attribute setObject:font forKey:NSFontAttributeName];
        
        
        self.attributedText = [[NSAttributedString alloc]initWithString:text attributes:attribute];
        
        CGSize retSize = [text boundingRectWithSize:CGSizeMake(width - self.insets.left - self.insets.right, CGFLOAT_MAX)
                                            options:
                          NSStringDrawingTruncatesLastVisibleLine |
                          NSStringDrawingUsesLineFragmentOrigin |
                          NSStringDrawingUsesFontLeading
                                         attributes:attribute
                                            context:nil].size;
        
        return retSize.height + self.insets.top + self.insets.bottom;
    }
}





-(void)setLabelStyleWithLineHeight:(CGFloat)lineHeight inset:(UIEdgeInsets)insets
{
    if (lineHeight != 0) {
        self.lineHeight = lineHeight;
    }
    if ( !(insets.top == 0 && insets.left == 0  \
           && insets.bottom == 0 && insets.right == 0) ) {
        self.insets = insets;
    }
    self.numberOfLines = 0;
    
    CGRect labelFrame = self.frame;

    labelFrame.size.height = [self heightOfLabel:self];
    
    self.frame = labelFrame;
    
}

-(void)setLabelStyleWithLineHeight:(CGFloat)lineHeight inset:(UIEdgeInsets)insets font:(UIFont *)font
{
    if (font != nil) {
        self.font = font;
    }
    [self setLabelStyleWithLineHeight:lineHeight inset:insets];
}

-(void)setLabelStyleWithLineHeight:(CGFloat)lineHeight inset:(UIEdgeInsets)insets font:(UIFont *)font text:(NSString *)text
{
    if (text != nil) {
        self.text = text;
    }
    [self setLabelStyleWithLineHeight:lineHeight inset:insets font:font];
}

-(void)setLabelStyleWithLineHeight:(CGFloat)lineHeight inset:(UIEdgeInsets)insets font:(UIFont *)font text:(NSString *)text width:(CGFloat)width
{
    if (width != 0) {
        CGRect frame = self.frame;
        frame.size.width = width;
        self.frame = frame;
    }
    [self setLabelStyleWithLineHeight:lineHeight inset:insets font:font text:text];
}



@end
