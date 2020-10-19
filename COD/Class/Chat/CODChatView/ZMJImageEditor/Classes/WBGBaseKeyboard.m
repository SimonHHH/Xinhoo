//
//  WBGBaseKeyboard.m
//  WBGKeyboards
//
//  Created by Jason on 2016/10/21.
//  Copyright © 2016年 Jason. All rights reserved.
//

#import "WBGBaseKeyboard.h"
//@import YYCategories.UIView_YYAdd;

@implementation WBGBaseKeyboard

#pragma mark - Public Methods
- (void)showWithAnimation:(BOOL)animation {
    [self showInView:[UIApplication sharedApplication].keyWindow withAnimation:animation];
}

- (void)showInView:(UIView *)view withAnimation:(BOOL)animation {
    if (_isShow) {
        return;
    }
    
    if (self.keyboardDelegate && [self.keyboardDelegate respondsToSelector:@selector(chatKeyboardWillShow:animated:)]) {
        [self.keyboardDelegate chatKeyboardWillShow:self animated:animation];
    }
    
    [view addSubview:self];
    CGFloat keyboardHeight = [self keyboardHeight];
    
    self.frame = CGRectMake(0,view.frame.size.height - (2 * keyboardHeight) , view.frame.size.width, keyboardHeight);
    
    [view layoutIfNeeded];
    
    if (animation) {
        [UIView animateWithDuration:.25f animations:^{
            self.frame = CGRectMake(0,view.frame.size.height - keyboardHeight , view.frame.size.width, keyboardHeight);
            [view layoutIfNeeded];
            _isShow = YES;
            
            if (self.keyboardDelegate && [self.keyboardDelegate respondsToSelector:@selector(chatKeyboard:didChangeHeight:)]) {
                [self.keyboardDelegate chatKeyboard:self didChangeHeight:view.frame.size.height - self.frame.origin.y];
            }
        } completion:^(BOOL finished) {
            if (self.keyboardDelegate && [self.keyboardDelegate respondsToSelector:@selector(chatKeyboardDidShow:animated:)]) {
                [self.keyboardDelegate chatKeyboardDidShow:self animated:animation];
            }
        }];
    }
    else {
        self.frame = CGRectMake(0,view.frame.size.height - keyboardHeight , view.frame.size.width, keyboardHeight);
        [view layoutIfNeeded];
        if (self.keyboardDelegate && [self.keyboardDelegate respondsToSelector:@selector(chatKeyboardDidShow:animated:)]) {
            [self.keyboardDelegate chatKeyboardDidShow:self animated:animation];
        }
         _isShow = YES;
    }
    
}

- (void)dismissWithAnimation:(BOOL)animation {
    if (!_isShow) {
        if (!animation) {
            [self removeFromSuperview];
        }
        return;
    }
    
    if (self.keyboardDelegate && [self.keyboardDelegate respondsToSelector:@selector(chatKeyboardWillDismiss:animated:)]) {
        [self.keyboardDelegate chatKeyboardWillDismiss:self animated:animation];
    }
    
    if (animation) {
        CGFloat keyboardHeight = [self keyboardHeight];
        [UIView animateWithDuration:.25f animations:^{
            self.frame = CGRectMake(0,self.superview.frame.size.height - 2 * keyboardHeight , self.superview.frame.size.width, keyboardHeight);
            [self.superview layoutIfNeeded];
            
            _isShow = NO;
            
            if (self.keyboardDelegate && [self.keyboardDelegate respondsToSelector:@selector(chatKeyboard:didChangeHeight:)]) {
                [self.keyboardDelegate chatKeyboard:self didChangeHeight:self.superview.frame.size.height - self.frame.origin.y];
            }
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            if (self.keyboardDelegate && [self.keyboardDelegate respondsToSelector:@selector(chatKeyboardDidDismiss:animated:)]) {
                [self.keyboardDelegate chatKeyboardDidDismiss:self animated:animation];
            }
            
        }];
    }
    else {
        [self removeFromSuperview];
        
        if (self.keyboardDelegate && [self.keyboardDelegate respondsToSelector:@selector(chatKeyboardDidDismiss:animated:)]) {
        
            [self.keyboardDelegate chatKeyboardDidDismiss:self animated:animation];
        }
        
        _isShow = NO;
    }
}

- (void)reset {
    
}

#pragma mark - WBGKeybardProtocol
- (CGFloat)keyboardHeight {
    return HEIGHT_CHAT_KEYBOARD;
}

@end
