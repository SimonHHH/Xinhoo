//
//  KKMasaicTool.h
//  CLImageEditorDemo
//
//  Created by 邬维 on 2017/1/4.
//  Copyright © 2017年 kook. All rights reserved.
//

#import "WBGImageToolBase.h"

@interface WBMosaicTool : WBGImageToolBase

@property (nonatomic, copy) void (^drawToolStatus)(BOOL canPrev);
@property (nonatomic, copy) void (^drawingCallback)(BOOL isDrawing);
@property (nonatomic, copy) void (^drawingDidTap)(void);

@property (nonatomic, copy) void (^getMosaicImage)(UIImage *image);

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock;

- (void)resertView;
@end
