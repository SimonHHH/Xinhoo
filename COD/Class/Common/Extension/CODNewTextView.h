//
//  CODNewTextView.h
//  COD
//
//  Created by 1 on 2019/7/2.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CODNewTextView : UITextView

-(NSMutableAttributedString*)getEmojiText:(NSString*)content;

@end

NS_ASSUME_NONNULL_END
