//
//  CODNewTextView.m
//  COD
//
//  Created by 1 on 2019/7/2.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#import "CODNewTextView.h"
#import "EmojiTextAttachment.h"
#import "COD-Swift.h"

@implementation CODNewTextView

static NSString *emojiTextPttern = @"\\[[0-9a-zA-Z\\u4e00-\\u9fa5]+\\]";

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuChange) name:UIMenuControllerMenuFrameDidChangeNotification object:nil];
    }
    return self;
}

- (void)menuChange{
    
}

//_emojiDic = @{@"[大笑]":@"smile",@"[爱心]":@"love"};
/*
-(NSMutableAttributedString*)getEmojiText:(NSString*)content{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:content attributes:self.typingAttributes];
    static NSRegularExpression *regExpress = nil;
    if(regExpress == nil){
        regExpress = [[NSRegularExpression alloc]initWithPattern:emojiTextPttern options:0 error:nil];
    }
    //通过正则表达式识别出emojiText
    NSArray *matches = [regExpress matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    if(matches.count > 0){
        for(NSTextCheckingResult *result in [matches reverseObjectEnumerator]){
            NSString *emojiText = [content substringWithRange:result.range];
            //构造NSTextAttachment对象
            NSTextAttachment *attachment = [self createEmojiAttachment:emojiText];
            if(attachment){
                NSAttributedString *rep = [NSAttributedString attributedStringWithAttachment:attachment];
                //在对应的位置替换
                [attributedString replaceCharactersInRange:result.range withAttributedString:rep];
            }
        }
    }
    return attributedString;
}

-(NSTextAttachment*)createEmojiAttachment:(NSString*)emojiText{
    if(emojiText.length==0){
        return nil;
    }
    NSString *imageName = emojiText;
    if(imageName.length == 0){
        return nil;
    }
    UIImage *image = [UIImage imageNamed:imageName];
    if(image == nil){
        return nil;
    }
    //把图片缩放到符合当前textview行高的大小
    CGFloat emojiWHScale = image.size.width/1.0/image.size.height;
    CGSize emojiSize = CGSizeMake(self.font.lineHeight*emojiWHScale, self.font.lineHeight);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, emojiSize.width, emojiSize.height)];
    imageView.image = image;
    //防止模糊
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, [UIScreen mainScreen].scale);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *emojiImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CODEmojiAttachment *attachment = [[CODEmojiAttachment alloc]init];
    attachment.image = emojiImage;
    attachment.imageName = emojiText;
    attachment.bounds = CGRectMake(0, -3, emojiImage.size.width, emojiImage.size.height);
    return attachment;
}

-(void)paste:(id)sender{

    UIPasteboard *defaultPasteboard = [UIPasteboard generalPasteboard];
    if(defaultPasteboard.string.length>0){
        NSRange range = self.selectedRange;
        if(range.location == NSNotFound){
            range.location = self.text.length;
        }
        if([self.delegate textView:self shouldChangeTextInRange:range replacementText:defaultPasteboard.string]){
            NSAttributedString *newAttriString = [self getEmojiText:defaultPasteboard.string];
            [self insertAttriStringToTextview:newAttriString];
            [self changeTextHeight];
            [self changeButtonImage];
        }
        return;
    }

    [super paste:sender];
}

- (void)changeTextHeight{
    
    if ([self.superview isKindOfClass:[CODChatBar class]]) {
        CODChatBar *chatBar = (CODChatBar *)self.superview;
        [chatBar changeTextViewWithAnimationWithAnimation:false];
    }
    
}

- (void)changeButtonImage{
    if ([self.superview isKindOfClass:[CODChatBar class]]) {
        CODChatBar *chatBar = (CODChatBar *)self.superview;
        [chatBar changeVoiceImage];
    }
}

-(void)insertAttriStringToTextview:(NSAttributedString*)attriString{
    
    NSMutableAttributedString *mulAttriString = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
    NSRange range = self.selectedRange;
    if(range.location == NSNotFound){
        range.location = self.text.length;
    }
    [mulAttriString insertAttributedString:attriString atIndex:range.location];
    self.attributedText = [mulAttriString copy];
    self.selectedRange = NSMakeRange(range.location+attriString.length, 0);
}
-(void)copy:(id)sender{
    NSRange range = self.selectedRange;
    NSString *content = [self getStrContentInRange:range];
    if(content.length>0){
        UIPasteboard *defaultPasteboard = [UIPasteboard generalPasteboard];
        [defaultPasteboard setString:content];
        return;
    }
    [super copy:sender];
}
-(void)cut:(id)sender{
    NSRange range = self.selectedRange;
    NSString *content = [self getStrContentInRange:range];
    if(content.length>0){
        [super cut:sender];
        UIPasteboard *defaultPasteboard = [UIPasteboard generalPasteboard];
        [defaultPasteboard setString:content];
        return;
    }
    [super cut:sender];
}

/**
 把textview的attributedText转化为NSString，其中把自定义表情转化为emojiText
 
 @param range 转化的范围
 @return 返回转化后的字符串
 */
-(NSString*)getStrContentInRange:(NSRange)range{
    NSMutableString *result = [[NSMutableString alloc]initWithCapacity:10];
    NSRange effectiveRange = NSMakeRange(range.location,0);
    NSUInteger length = NSMaxRange(range);
    while (NSMaxRange(effectiveRange)<length) {
        NSTextAttachment *attachment = [self.attributedText attribute:NSAttachmentAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
        if(attachment){
            if([attachment isKindOfClass:[CODEmojiAttachment class]]){
                CODEmojiAttachment *emojiAttachment = (CODEmojiAttachment*)attachment;
                [result appendString:emojiAttachment.imageName];
            }
        }
        else{
            NSString *subStr = [self.text substringWithRange:effectiveRange];
            [result appendString:subStr];
        }
    }
    return [result copy];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    [UIMenuController.sharedMenuController.menuItems enumerateObjectsUsingBlock:^(UIMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@",obj);
    }];
    
    return [super canPerformAction:action withSender:sender];
}


@end
