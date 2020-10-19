//
//  KKMasaicTool.m
//  CLImageEditorDemo
//
//  Created by 邬维 on 2017/1/4.
//  Copyright © 2017年 kook. All rights reserved.
//

#import "WBMosaicTool.h"
#import "WBMosaicView.h"
#import "WBGTextToolView.h"
#define WEAK_SELF __weak __typeof(&*self)weakSelf = self

@interface WBMosaicTool()

@property (nonatomic, strong)WBMosaicView *mosaicView;

@end

@implementation WBMosaicTool{

    UIView *_menuView; //底部菜单
    __weak UIImageView        *_drawingView;
    CGSize                     _originalImageSize;
}

+ (NSString*)defaultTitle
{
    return @"Mosaic";
}

+ (UIImage*)defaultIconImage 
{
    return [UIImage imageNamed:@"ToolMasaic"];
}

#pragma mark- implementation

- (void)setup{
    
    //初始化一些东西
    _originalImageSize   = self.editor.imageView.image.size;
    _drawingView         = self.editor.drawingView;
    
    UIImage *image_edit = self.editor.imageView.image;
    CIImage *ciImage = [[CIImage alloc] initWithImage:image_edit];
    //生成马赛克
    CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
    [filter setValue:ciImage  forKey:kCIInputImageKey];
    //马赛克像素大小
    [filter setValue:@(50) forKey:kCIInputScaleKey];
    CIImage *outImage = [filter valueForKey:kCIOutputImageKey];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outImage fromRect:[outImage extent]];
    UIImage *showImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    self.mosaicView = [[WBMosaicView alloc]initWithFrame:CGRectMake(0, self.editor.imageView.frame.origin.y, self.editor.imageView.bounds.size.width, self.editor.imageView.bounds.size.height)];
    self.mosaicView.surfaceImage = image_edit;
    self.mosaicView.image = showImage;
    [self.editor.drawingView insertSubview:self.mosaicView atIndex:0];

    WEAK_SELF;
    self.mosaicView.drawingDidTap = ^{
        if (weakSelf.drawingDidTap) {
            weakSelf.drawingDidTap();
        }
    };
    self.mosaicView.drawingCallback = ^(BOOL isDrawing){
        if (weakSelf.drawingCallback) {
            weakSelf.drawingCallback(isDrawing);
        }
    };
    
    self.editor.imageView.userInteractionEnabled = YES;
    self.editor.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    self.editor.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    self.editor.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
}

///这个是重置马赛克视图
- (void)resertView{
    [self.mosaicView removeFromSuperview];
    [self setup];
}

- (void)cleanup
{
    ///保存当前的图片到self.editor.imageView（注意涂鸦要清理）
    WEAK_SELF;
    [self executeWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *dic) {
        
        weakSelf.editor.imageView.userInteractionEnabled = NO;
        weakSelf.editor.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
        ///这里还要注意的一点是
        [weakSelf.mosaicView removeFromSuperview];
        weakSelf.mosaicView = nil;
        if (weakSelf.getMosaicImage) {
            weakSelf.getMosaicImage(image);
        }
    }];
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self buildImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(image, nil, nil);
        });
    });
}


- (UIImage*)buildImage
{
    UIGraphicsBeginImageContextWithOptions(self.mosaicView.bounds.size, NO, 0);
    [self.mosaicView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)getDrawImage{
    UIGraphicsBeginImageContextWithOptions(_originalImageSize, NO, self.editor.imageView.image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    ///这个要直接
    [_drawingView.image drawInRect:CGRectMake(0, self.editor.imageView.frame.origin.y, _originalImageSize.width, _originalImageSize.height)];
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tmp;

}
@end
