//
//  CODActionSheet.m
//  COD
//
//  Created by 1 on 2019/8/15.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#import "CODActionSheet.h"

static const CGFloat kRowHeight = 57.0f;
static const CGFloat kRowLineHeight = 0.5f;
static const CGFloat kSeparatorHeight = 6.0f;
static const CGFloat kTitleFontSize = 14.0f;
static const CGFloat kButtonTitleFontSize = 20.0f;
static const NSTimeInterval kAnimateDuration = 0.3f;

@interface CODActionSheet ()

/** block回调 */
@property (copy, nonatomic) CODActionSheetBlock actionSheetBlock;
/** 背景图片 */
@property (strong, nonatomic) UIView *backgroundView;
/** 背景图片 */
@property (strong, nonatomic) UIView *titleBackgroundView;
/** 弹出视图 */
@property (strong, nonatomic) UIView *actionSheetView;

/**
 * 收起视图
 */
- (void)dismiss;

/**
 * 通过颜色生成图片
 */
- (UIImage *)imageWithColor:(UIColor *)color;

@end

@implementation CODActionSheet

- (instancetype)initWithFrame:(CGRect)frame
{
//    return [self initWithTitle:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil handler:nil];
    return [self initWithTitle:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil cancelButtonColor:nil destructiveButtonColor:nil otherButtonColors:nil handler:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithTitle:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil cancelButtonColor:nil destructiveButtonColor:nil otherButtonColors:nil handler:nil];
}

- (instancetype)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles cancelButtonColor:(UIColor *)cancelButtonColor  destructiveButtonColor:(UIColor *)destructiveButtonColor otherButtonColors:(NSArray *)otherButtonColors handler:(CODActionSheetBlock)actionSheetBlock
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _actionSheetBlock = actionSheetBlock;
        
        CGFloat actionSheetHeight = 0;
        NSInteger gap = 9;
        CGFloat viewWidth = self.frame.size.width - gap*2;
        CGFloat cornerRadius = 15;
        
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
        _backgroundView.alpha = 0;
        [self addSubview:_backgroundView];
                
        _actionSheetView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 0)];
        _actionSheetView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        _actionSheetView.backgroundColor = [UIColor clearColor];
        _actionSheetView.layer.cornerRadius = cornerRadius;
        _actionSheetView.clipsToBounds = true;
        [self addSubview:_actionSheetView];
        
        _titleBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, viewWidth, 0)];
        _titleBackgroundView.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
//        _titleBackgroundView.alpha = 0;
        _titleBackgroundView.layer.cornerRadius = 15;
        _titleBackgroundView.clipsToBounds = true;
        _titleBackgroundView.backgroundColor = [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1.0];
//        _titleBackgroundView.backgroundColor = [UIColor redColor];
        [_actionSheetView addSubview:_titleBackgroundView];

        UIImage *normalImage = [self imageWithColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
        UIImage *highlightedImage = [self imageWithColor:[UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f]];
        
        if (title && title.length > 0)
        {
            actionSheetHeight += kRowLineHeight;
            
            CGFloat titleHeight = ceil([title boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kTitleFontSize]} context:nil].size.height) + 15*2;
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, actionSheetHeight, viewWidth, titleHeight)];
            titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            titleLabel.text = title;
            titleLabel.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
            titleLabel.textColor = [UIColor colorWithRed:135.0f/255.0f green:135.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = [UIFont systemFontOfSize:kTitleFontSize];
            titleLabel.numberOfLines = 0;
            [_titleBackgroundView addSubview:titleLabel];
            
            actionSheetHeight += titleHeight;
        }
        
        if (destructiveButtonTitle && destructiveButtonTitle.length > 0)
        {
            actionSheetHeight += kRowLineHeight;
            
            UIButton *destructiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
            destructiveButton.frame = CGRectMake(0, actionSheetHeight, viewWidth, kRowHeight);
            destructiveButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            destructiveButton.tag = -1;
            destructiveButton.titleLabel.font = [UIFont systemFontOfSize:kButtonTitleFontSize];
            [destructiveButton setTitle:destructiveButtonTitle forState:UIControlStateNormal];
            if (destructiveButtonColor != nil) {
                [destructiveButton setTitleColor:destructiveButtonColor forState:UIControlStateNormal];
            }else{
                [destructiveButton setTitleColor:[UIColor colorWithRed:230.0f/255.0f green:66.0f/255.0f blue:66.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            }
            [destructiveButton setBackgroundImage:normalImage forState:UIControlStateNormal];
            [destructiveButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
            [destructiveButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_titleBackgroundView addSubview:destructiveButton];
            
            actionSheetHeight += kRowHeight;
        }
        
        if (otherButtonTitles && [otherButtonTitles count] > 0)
        {
            for (int i = 0; i < otherButtonTitles.count; i++)
            {
                actionSheetHeight += kRowLineHeight;
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(0, actionSheetHeight, viewWidth, kRowHeight);
                button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                button.tag = i+1;
                button.titleLabel.font = [UIFont systemFontOfSize:kButtonTitleFontSize];
                [button setTitle:otherButtonTitles[i] forState:UIControlStateNormal];
                if (otherButtonColors.count > i){
                    UIColor *otherColor = otherButtonColors[i];
                    [button setTitleColor:otherColor forState:UIControlStateNormal];
                }else{
                    [button setTitleColor:[UIColor colorWithRed:64.0f/255.0f green:64.0f/255.0f blue:64.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
                }
                [button setBackgroundImage:normalImage forState:UIControlStateNormal];
                [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
                [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [_titleBackgroundView addSubview:button];
                
                actionSheetHeight += kRowHeight;
            }
        }
        _titleBackgroundView.frame = CGRectMake(gap, 0, viewWidth, actionSheetHeight);

        if (cancelButtonTitle && cancelButtonTitle.length > 0)
        {
            actionSheetHeight += kSeparatorHeight;
            
            UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            cancelButton.frame = CGRectMake(gap, actionSheetHeight, viewWidth, kRowHeight);
            cancelButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            cancelButton.tag = 0;
            cancelButton.layer.cornerRadius = 15;
            cancelButton.clipsToBounds = true;
            cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:kButtonTitleFontSize];
            [cancelButton setTitle:cancelButtonTitle ?: @"取消" forState:UIControlStateNormal];
            if (cancelButtonColor != nil) {
                [cancelButton setTitleColor:cancelButtonColor forState:UIControlStateNormal];
            }else{
                [cancelButton setTitleColor:[UIColor colorWithRed:64.0f/255.0f green:64.0f/255.0f blue:64.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            }
//            [cancelButton setTitleColor:[UIColor colorWithRed:64.0f/255.0f green:64.0f/255.0f blue:64.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:normalImage forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
            [cancelButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_actionSheetView addSubview:cancelButton];
            
            actionSheetHeight += kRowHeight;
        }
        
        _actionSheetView.frame = CGRectMake(gap, self.frame.size.height, viewWidth, actionSheetHeight);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"kAudioCallBegin" object:nil];
    return self;
}

+ (instancetype)actionSheetWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles handler:(CODActionSheetBlock)actionSheetBlock
{
//    return [[self alloc] initWithTitle:title cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles handler:actionSheetBlock];
    return [[self alloc] initWithTitle:title cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles cancelButtonColor:[UIColor blackColor] destructiveButtonColor:[UIColor blackColor] otherButtonColors:@[]  handler:actionSheetBlock];
    
}

+ (void)showActionSheetWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles handler:(CODActionSheetBlock)actionSheetBlock
{
    CODActionSheet *CODActionSheet = [self actionSheetWithTitle:title cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles handler:actionSheetBlock];
    [CODActionSheet show];
}

+ (void)showActionSheetWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles superView:(UIView *)superView handler:(CODActionSheetBlock)actionSheetBlock
{
    CODActionSheet *CODActionSheet = [self actionSheetWithTitle:title cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles handler:actionSheetBlock];
    [CODActionSheet showWithSuperVeiw:superView];
}

+ (void)showActionSheetWithTitle:(NSString *)title
               cancelButtonTitle:(NSString *)cancelButtonTitle
          destructiveButtonTitle:(NSString *)destructiveButtonTitle
               otherButtonTitles:(NSArray *)otherButtonTitles
               cancelButtonColor:(UIColor *)cancelButtonColor
          destructiveButtonColor:(UIColor *)destructiveButtonColor
               otherButtonColors:(NSArray *)otherButtonColors
                         handler:(CODActionSheetBlock)actionSheetBlock{
    CODActionSheet *CODActionSheet = [[self alloc] initWithTitle:title cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles cancelButtonColor:cancelButtonColor destructiveButtonColor:destructiveButtonColor  otherButtonColors:otherButtonColors handler:actionSheetBlock];
    [CODActionSheet show];
}

+ (void)showActionSheetWithTitle:(NSString *)title
               cancelButtonTitle:(NSString *)cancelButtonTitle
          destructiveButtonTitle:(NSString *)destructiveButtonTitle
               otherButtonTitles:(NSArray *)otherButtonTitles
               cancelButtonColor:(UIColor *)cancelButtonColor
          destructiveButtonColor:(UIColor *)destructiveButtonColor
               otherButtonColors:(NSArray *)otherButtonColors
                       superView:(UIView *)superView
                         handler:(CODActionSheetBlock)actionSheetBlock{
    CODActionSheet *CODActionSheet = [[self alloc] initWithTitle:title cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles cancelButtonColor:cancelButtonColor destructiveButtonColor:destructiveButtonColor  otherButtonColors:otherButtonColors handler:actionSheetBlock];
    if (superView != nil ){
        [CODActionSheet showWithSuperVeiw:superView];
    }else{
        [CODActionSheet show];
    }
}

- (void)show
{
    // 在主线程中处理,否则在viewDidLoad方法中直接调用,会先加本视图,后加控制器的视图到UIWindow上,导致本视图无法显示出来,这样处理后便会优先加控制器的视图到UIWindow上
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows)
        {
            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
            BOOL windowIsVisible = !window.hidden && window.alpha > 0;
            BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
            
            if(windowOnMainScreen && windowIsVisible && windowLevelNormal)
            {
                [window addSubview:self];
                break;
            }
        }
        
//        [UIView animateWithDuration:kAnimateDuration delay:0 usingSpringWithDamping:0.2f initialSpringVelocity:0.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.backgroundView.alpha = 1.0f;
//            self.titleBackgroundView.alpha = 1.0f;
//            self.titleBackgroundView.frame = CGRectMake(9, self.frame.size.height-self.actionSheetView.frame.size.height - 10, self.frame.size.width - 18, self.titleBackgroundView.frame.size.height);
            self.actionSheetView.frame = CGRectMake(0, self.frame.size.height-self.actionSheetView.frame.size.height - 10, self.frame.size.width, self.actionSheetView.frame.size.height);
//        } completion:nil];
    }];
}
- (void)showWithSuperVeiw:(UIView *)superView{
    // 在主线程中处理,否则在viewDidLoad方法中直接调用,会先加本视图,后加控制器的视图到UIWindow上,导致本视图无法显示出来,这样处理后便会优先加控制器的视图到UIWindow上
    //    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    
    //        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    //        for (UIWindow *window in frontToBackWindows)
    //        {
    //            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
    //            BOOL windowIsVisible = !window.hidden && window.alpha > 0;
    //            BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
    //
    //            if(windowOnMainScreen && windowIsVisible && windowLevelNormal)
    //            {
    //                [window addSubview:self];
    //                break;
    //            }
    //        }
    [superView addSubview:self];
    [UIView animateWithDuration:kAnimateDuration delay:0 usingSpringWithDamping:0.7f initialSpringVelocity:0.7f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundView.alpha = 1.0f;
        self.actionSheetView.frame = CGRectMake(0, self.frame.size.height-self.actionSheetView.frame.size.height, self.frame.size.width, self.actionSheetView.frame.size.height);
    } completion:nil];
    //    }];
}

- (void)dismiss
{
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIView animateWithDuration:kAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundView.alpha = 0.0f;
        self.actionSheetView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.actionSheetView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.backgroundView];
    if (!CGRectContainsPoint(self.actionSheetView.frame, point))
    {
        if (self.actionSheetBlock)
        {
            self.actionSheetBlock(self, 0);
        }
        
        [self dismiss];
    }
}

- (void)buttonClicked:(UIButton *)button
{
    if (self.actionSheetBlock)
    {
        self.actionSheetBlock(self, button.tag);
    }
    
    [self dismiss];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"CODActionSheet dealloc");
#endif
}

@end
