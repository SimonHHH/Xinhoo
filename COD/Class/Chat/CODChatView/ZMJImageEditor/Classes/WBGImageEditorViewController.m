//
//  WBGImageEditorViewController.m
//  CLImageEditorDemo
//
//  Created by Jason on 2017/2/27.
//  Copyright © 2017年 CALACULU. All rights reserved.
//

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 \
alpha:(a)]
#define WEAK_SELF __weak __typeof(&*self)weakSelf = self

#import "WBGImageEditorViewController.h"
#import "WBGImageToolBase.h"
#import "ColorfullButton.h"
#import "WBGDrawTool.h"
#import "WBGTextTool.h"
#import "TOCropViewController.h"
#import "UIImage+CropRotate.h"
#import "WBGTextToolView.h"
#import "WBGImageEditor.h"
#import "WBGMoreKeyboard.h"
#import "WBMosaicTool.h"
#import "UIView+YYAdd.h"
#import "CALayer+YYAdd.h"
NSString * const kColorPanNotificaiton = @"kColorPanNotificaiton";
#pragma mark - WBGImageEditorViewController

@interface WBGImageEditorViewController () <UINavigationBarDelegate, UIScrollViewDelegate, TOCropViewControllerDelegate, WBGMoreKeyboardDelegate, WBGKeyboardDelegate> {
    
    __weak IBOutlet NSLayoutConstraint *topBarTop;
    __weak IBOutlet NSLayoutConstraint *bottomBarBottom;
    
}
@property (nonatomic, strong, nullable) WBGImageToolBase *currentTool;

@property (weak, nonatomic) IBOutlet UIView *topBar;

@property (nonatomic, strong) UIView *functionBottomView;///下面的功能视图
@property (strong, nonatomic) IBOutlet UIView *topBannerView;
@property (strong, nonatomic) IBOutlet UIView *bottomBannerView;
@property (strong, nonatomic) IBOutlet UIView *leftBannerView;
@property (strong, nonatomic) IBOutlet UIView *rightBannerView;

@property (weak,   nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *drawingView;
@property (weak,   nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet WBGColorPan *colorPan;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *panButton;
@property (weak, nonatomic) IBOutlet UIButton *textButton;
@property (weak, nonatomic) IBOutlet UIButton *clipButton;
@property (weak, nonatomic) IBOutlet UIButton *paperButton;
@property (weak, nonatomic) IBOutlet UIButton *mosaicButton;


@property (nonatomic, strong) WBGDrawTool *drawTool;
@property (nonatomic, strong) WBGTextTool *textTool;
@property (nonatomic, strong) WBMosaicTool *mosaicTool;
@property (nonatomic, copy  ) UIImage   *originImage;

@property (nonatomic, assign) CGFloat clipInitScale;
@property (nonatomic, assign) BOOL barsHiddenStatus;
@property (nonatomic, strong) WBGMoreKeyboard *keyboard;

@end

@implementation WBGImageEditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (id)init
{
    self = [self initWithNibName:@"WBGImageEditorViewController" bundle:[NSBundle bundleForClass:self.class]];
    if (self){
        
    }
    return self;
}

- (id)initWithImage:(UIImage *)image
{
    return [self initWithImage:image delegate:nil dataSource:nil];
}

- (id)initWithImage:(UIImage*)image delegate:(id<WBGImageEditorDelegate>)delegate dataSource:(id<WBGImageEditorDataSource>)dataSource;
{
    self = [self init];
    if (self){
        _originImage = image;
        self.delegate = delegate;
        self.dataSource = dataSource;
    }
    return self;
}

- (id)initWithDelegate:(id<WBGImageEditorDelegate>)delegate
{
    self = [self init];
    if (self){
        
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.undoButton.hidden = YES;
    
    [self.view addSubview:self.functionBottomView];
    
    [self initImageScrollView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.panButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    });
}


/**
 这个设置颜色管理界面

 @return NO
 */
- (UIView *)functionBottomView{
    if (_functionBottomView == nil) {
        _functionBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.bottomBar.frame.size.height * 2, [UIScreen mainScreen].bounds.size.width, self.bottomBar.frame.size.height)];
        _functionBottomView.backgroundColor =  RGBACOLOR(26, 26, 26, 0.8);
        
        ///颜色的图片
        self.colorPan.frame = CGRectMake(10,0, [UIScreen mainScreen].bounds.size.width - 90, self.colorPan.bounds.size.height);
        self.colorPan.backgroundColor = [UIColor clearColor];
        [_functionBottomView addSubview:self.colorPan];
        
        ///添加撤销按钮
        self.newundoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.newundoButton.frame = CGRectMake(_functionBottomView.frame.size.width - 80, 0, 80,_functionBottomView.frame.size.height);
        [self.newundoButton addTarget:self action:@selector(undoAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.newundoButton setImage:[UIImage imageNamed:@"撤销选中"] forState:UIControlStateNormal];
        [self.newundoButton setImage:[UIImage imageNamed:@"撤销不选中"] forState:UIControlStateSelected];
        [_functionBottomView addSubview:self.newundoButton];
        self.newundoButton.selected = YES;
        
        UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(_functionBottomView.frame.size.width - 80, 7.5, 0.5, 30)];
        line1.backgroundColor = RGBACOLOR(110, 110, 110, 1);
        [_functionBottomView addSubview:line1];
        
        UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(0, _functionBottomView.frame.size.height -  0.5, _functionBottomView.frame.size.width, 0.5)];
        line2.backgroundColor = RGBACOLOR(110, 110, 110, 1);
        [_functionBottomView addSubview:line2];
    }
    return _functionBottomView;
}


/**
 马赛克类型视图
 @return 马赛克类型视图
 */
- (UIView *)mosaicTypeView{
    if (_mosaicTypeView == nil) {
        _mosaicTypeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.functionBottomView.frame.size.width - 80, self.functionBottomView.frame.size.height)];
        
        ///添加马赛克类型按钮
        UIButton *button  = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 44, self.functionBottomView.frame.size.height);
        button.center = _mosaicTypeView.center;
        [button setImage:[UIImage imageNamed:@"Mosaic_Type_NoSelect"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"Mosaic_Type"] forState:UIControlStateSelected];
        button.selected = YES;
        [_mosaicTypeView addSubview:button];
        [_functionBottomView addSubview:_mosaicTypeView];
    }
    return _mosaicTypeView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //ShowBusyIndicatorForView(self.view);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      //  HideBusyIndicatorForView(self.view);
        [self refreshImageView];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (!self.drawingView) {
        self.drawingView = [[UIImageView alloc] initWithFrame:self.imageView.superview.frame];
        self.drawingView.contentMode = UIViewContentModeCenter;
        self.drawingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
        [self.imageView.superview addSubview:self.drawingView];
    } else {
        //self.drawingView.frame = self.imageView.superview.frame;
    }
    
    
    self.topBannerView.frame = CGRectMake(0, 0, self.imageView.frame.size.width, CGRectGetMinY(self.imageView.frame));
    self.bottomBannerView.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame), self.imageView.frame.size.width, self.drawingView.frame.size.height - CGRectGetMaxY(self.imageView.frame));
    self.leftBannerView.frame = CGRectMake(0, 0, CGRectGetMinX(self.imageView.frame), self.drawingView.frame.size.height);
    self.rightBannerView.frame= CGRectMake(CGRectGetMaxX(self.imageView.frame), 0, self.drawingView.frame.size.width - CGRectGetMaxX(self.imageView.frame), self.drawingView.frame.size.height);
}

- (UIView *)topBannerView {
    if (!_topBannerView) {
        _topBannerView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = self.scrollView.backgroundColor;
            [self.imageView.superview addSubview:view];
            view;
        });
    }
    
    return _topBannerView;
}

- (UIView *)bottomBannerView {
    if (!_bottomBannerView) {
        _bottomBannerView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = self.scrollView.backgroundColor;
            [self.imageView.superview addSubview:view];
            view;
        });
    }
    return _bottomBannerView;
}

- (UIView *)leftBannerView {
    if (!_leftBannerView) {
        _leftBannerView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = self.scrollView.backgroundColor;
            [self.imageView.superview addSubview:view];
            view;
        });
    }
    
    return _leftBannerView;
}

- (UIView *)rightBannerView {
    if (!_rightBannerView) {
        _rightBannerView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = self.scrollView.backgroundColor;
            [self.imageView.superview addSubview:view];
            view;
        });
    }
    
    return _rightBannerView;
}

#pragma mark - 初始化 &getter
- (WBGDrawTool *)drawTool {
    if (_drawTool == nil) {
        _drawTool = [[WBGDrawTool alloc] initWithImageEditor:self];
        
        __weak typeof(self)weakSelf = self;
        _drawTool.drawToolStatus = ^(BOOL canPrev) {
            if (canPrev) {
                weakSelf.newundoButton.selected = NO;
            } else {
                weakSelf.undoButton.hidden = YES;
                weakSelf.newundoButton.selected = YES;
            }
        };
        _drawTool.drawingCallback = ^(BOOL isDrawing) {
            [weakSelf hiddenTopAndBottomBar:isDrawing animation:YES];
        };
        _drawTool.drawingDidTap = ^(void) {
            [weakSelf hiddenTopAndBottomBar:!weakSelf.barsHiddenStatus animation:YES];
        };
    }
    
    return _drawTool;
}

- (WBGTextTool *)textTool {
    if (_textTool == nil) {
        _textTool = [[WBGTextTool alloc] initWithImageEditor:self];
        __weak typeof(self)weakSelf = self;
        _textTool.dissmissTextTool = ^(NSString *currentText) {
            [weakSelf hiddenColorPan:NO animation:YES];
            weakSelf.currentMode = EditorNonMode;
            weakSelf.currentTool = nil;
        };
    }
    
    return _textTool;
}

- (WBMosaicTool *)mosaicTool{
    if (_mosaicTool == nil) {
        WEAK_SELF;
        _mosaicTool  = [[WBMosaicTool alloc] initWithImageEditor:self];
        _mosaicTool.drawingCallback = ^(BOOL isDrawing) {
            weakSelf.newundoButton.selected = NO;
            [weakSelf hiddenTopAndBottomBar:isDrawing animation:YES];
        };
        _mosaicTool.drawingDidTap = ^(void) {
            [weakSelf hiddenTopAndBottomBar:!weakSelf.barsHiddenStatus animation:YES];
        };
        _mosaicTool.getMosaicImage = ^(UIImage *image){
            weakSelf.imageView.image = image;
        };
    }
    return _mosaicTool;
}

- (void)initImageScrollView {
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.backgroundColor = [UIColor blackColor];

}

- (void)refreshImageView {
    if (self.imageView.image == nil) {
        self.imageView.image = self.originImage;
    }
    
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimated:NO];
    [self viewDidLayoutSubviews];
}

- (void)resetImageViewFrame {
    CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
    if(size.width > 0 && size.height > 0 ) {
        CGFloat ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
        CGFloat W = ratio * size.width * _scrollView.zoomScale;
        CGFloat H = ratio * size.height * _scrollView.zoomScale;
        
        _imageView.frame = CGRectMake(MAX(0, (_scrollView.frame.size.width-W)/2), MAX(0, (_scrollView.frame.size.height-H)/2), W, H);
    }
}

- (void)resetZoomScaleWithAnimated:(BOOL)animated
{
    CGFloat Rw = _scrollView.frame.size.width / _imageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / _imageView.frame.size.height;
    
    //CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat scale = 1;
    Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.height));
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 3);
    
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
    [self scrollViewDidZoom:_scrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark- ScrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView.superview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{ }

#pragma mark - Property
- (void)setCurrentTool:(WBGImageToolBase *)currentTool {
    if(_currentTool != currentTool) {
        [_currentTool cleanup];
        _currentTool = currentTool;
        [_currentTool setup];
        
    }
    
    [self swapToolBarWithEditting];
}

#pragma mark- ImageTool setting
+ (NSString*)defaultIconImagePath {
    return nil;
}

+ (CGFloat)defaultDockedNumber {
    return 0;
}

+ (NSString *)defaultTitle {
    return @"";
}

+ (BOOL)isAvailable {
    return YES;
}

+ (NSArray *)subtools {
    return [NSArray new];
}

+ (NSDictionary*)optionalInfo {
    return nil;
}


#pragma mark - Actions
///发送
- (IBAction)sendAction:(UIButton *)sender {
    WEAK_SELF;
    if (self.currentMode == EditorMosaicMode) {
        if (self.currentTool) {
            if ([self.currentTool isKindOfClass:[WBMosaicTool class]]) {
                WBMosaicTool *tools = (WBMosaicTool *)self.currentTool;
                [tools executeWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *dic) {
                    weakSelf.imageView.image = image;
                    [weakSelf buildClipImageShowHud:YES clipedCallback:^(UIImage *clipedImage) {
                        if ([weakSelf.delegate respondsToSelector:@selector(imageEditor:didFinishEdittingWithImage:)]) {
                            ///关闭控制器
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                            [weakSelf.delegate imageEditor:weakSelf didFinishEdittingWithImage:clipedImage];
                        }
                    }];

                }];
            }
        }
    }else{
        
        [self buildClipImageShowHud:YES clipedCallback:^(UIImage *clipedImage) {
            if ([self.delegate respondsToSelector:@selector(imageEditor:didFinishEdittingWithImage:)]) {
                ///关闭控制器
                [self dismissViewControllerAnimated:YES completion:nil];
                [self.delegate imageEditor:self didFinishEdittingWithImage:clipedImage];
            }
        }];
    }
}

///涂鸦模式
- (IBAction)panAction:(UIButton *)sender {
    if (_currentMode == EditorDrawMode) {
        return;
    }
    //先设置状态，然后在干别的
    self.currentMode = EditorDrawMode;
    self.currentTool = self.drawTool;
}

///裁剪模式
- (IBAction)clipAction:(UIButton *)sender {
    
    [self buildClipImageShowHud:NO clipedCallback:^(UIImage *clipedImage) {
        TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:TOCropViewCroppingStyleDefault image:clipedImage];
        cropController.delegate = self;
        __weak typeof(self)weakSelf = self;
        CGRect viewFrame = [self.view convertRect:self.imageView.frame toView:self.navigationController.view];
        [cropController presentAnimatedFromParentViewController:self
                                                      fromImage:clipedImage
                                                       fromView:nil
                                                      fromFrame:viewFrame
                                                          angle:0
                                                   toImageFrame:CGRectZero
                                                          setup:^{
                                                              [weakSelf refreshImageView];
                                                              weakSelf.colorPan.hidden = YES;
                                                              weakSelf.currentMode = EditorClipMode;
                                                              [weakSelf setCurrentTool:nil];
                                                          }
                                                     completion:^{
                                                     }];
    }];
    
}

//文字模式
- (IBAction)textAction:(UIButton *)sender {
    if (_currentMode == EditorTextMode) {
        return;
    }
    //先设置状态，然后在干别的
    self.currentMode = EditorTextMode;
    self.currentTool = self.textTool;
    [self hiddenColorPan:YES animation:YES];
}

//贴图模式
- (IBAction)paperAction:(UIButton *)sender {
    if (_currentMode == EditorTextMode) {
        return;
    }
    self.currentMode = EditorPaperMode;
    
    NSArray<WBGMoreKeyboardItem *> *sources = nil;
    if (self.dataSource) {
        sources = [self.dataSource imageItemsEditor:self];
    }
    //贴图模块
    [self.keyboard setChatMoreKeyboardData:sources];
    [self.keyboard showInView:self.view withAnimation:YES];
}

//马赛克模式
- (IBAction)mosaicAction:(UIButton *)sender {
    WEAK_SELF;
    if (self.currentMode == EditorMosaicMode) {
        return;
    }
    [self buildClipImageclipedCallback:^(UIImage *clipedImage) {
        
        weakSelf.imageView.image = clipedImage;
        [weakSelf.drawTool.allLineMutableArray removeAllObjects];
        [weakSelf.drawTool drawLine];
        weakSelf.currentMode = EditorMosaicMode;
        weakSelf.currentTool = weakSelf.mosaicTool;
    }];
}

- (IBAction)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)undoAction:(UIButton *)sender {
        if (self.currentMode == EditorDrawMode) {
            WBGDrawTool *tool = (WBGDrawTool *)self.currentTool;
            [tool backToLastDraw];
        }else if (self.currentMode == EditorMosaicMode){
            if (sender.selected == NO) {
                WBMosaicTool *tool = (WBMosaicTool *)self.currentTool;
                [tool resertView];
                self.newundoButton.selected = YES;
            }
        }
 }



- (void)editTextAgain {
    //WBGTextTool 钩子调用
    
    if (_currentMode == EditorTextMode) {
        return;
    }
    //先设置状态，然后在干别的
    self.currentMode = EditorTextMode;
    
    if(_currentTool != self.textTool) {
        [_currentTool cleanup];
        _currentTool = self.textTool;
        [_currentTool setup];
    }
    [self hiddenColorPan:YES animation:YES];
}

- (void)resetCurrentTool {
    self.currentMode = EditorNonMode;
    self.currentTool = nil;
}

- (WBGMoreKeyboard *)keyboard {
    if (!_keyboard) {
        WBGMoreKeyboard *keyboard = [WBGMoreKeyboard keyboard];
        [keyboard setKeyboardDelegate:self];
        [keyboard setDelegate:self];
        _keyboard = keyboard;
    }
    return _keyboard;
}

#pragma mark - WBGMoreKeyboardDelegate
- (void) moreKeyboard:(id)keyboard didSelectedFunctionItem:(WBGMoreKeyboardItem *)funcItem {
    WBGMoreKeyboard *kb = (WBGMoreKeyboard *)keyboard;
    [kb dismissWithAnimation:YES];
    
    WBGTextToolView *view = [[WBGTextToolView alloc] initWithTool:self.textTool text:@"" font:nil orImage:funcItem.image];
    view.borderColor = [UIColor whiteColor];
    view.image = funcItem.image;
    view.center = [self.imageView.superview convertPoint:self.imageView.center toView:self.drawingView];
    view.userInteractionEnabled = YES;
    [self.drawingView addSubview:view];
    [WBGTextToolView setActiveTextView:view];
    
}

#pragma mark - WBGKeyboardDelegate

#pragma mark - Cropper Delegate
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    [self updateImageViewWithImage:image fromCropViewController:cropViewController];
}

- (void)updateImageViewWithImage:(UIImage *)image fromCropViewController:(TOCropViewController *)cropViewController
{
    self.imageView.image = image;
    __unused CGFloat drawingWidth = self.drawingView.bounds.size.width;
    CGRect bounds = cropViewController.cropView.foregroundImageView.bounds;
    bounds.size = CGSizeMake(bounds.size.width/self.clipInitScale, bounds.size.height/self.clipInitScale);
    
    [self refreshImageView];
    [self viewDidLayoutSubviews];


    self.navigationItem.rightBarButtonItem.enabled = YES;
    __weak typeof(self)weakSelf = self;
    if (cropViewController.croppingStyle != TOCropViewCroppingStyleCircular) {

        [cropViewController dismissAnimatedFromParentViewController:self
                                                   withCroppedImage:image
                                                             toView:self.imageView
                                                            toFrame:CGRectZero
                                                              setup:^{
                                                                  [weakSelf refreshImageView];
                                                                  [weakSelf viewDidLayoutSubviews];
                                                                  weakSelf.colorPan.hidden = NO;
                                                              }
                                                         completion:^{
                                                             weakSelf.colorPan.hidden = NO;
                                                         }];
    }
    else {
        
        [cropViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    //生成图片后，清空画布内容
    [self.drawTool.allLineMutableArray removeAllObjects];
    [self.drawTool drawLine];
    
    [_drawingView removeAllSubviews];
    self.undoButton.hidden = YES;
    self.newundoButton.selected = YES;

}


- (void)cropViewController:(TOCropViewController *)cropViewController didFinishCancelled:(BOOL)cancelled {
    
    __weak typeof(self)weakSelf = self;
    [cropViewController dismissAnimatedFromParentViewController:self
                                               withCroppedImage:self.imageView.image
                                                         toView:self.imageView
                                                        toFrame:CGRectZero
                                                          setup:^{
                                                              [weakSelf refreshImageView];
                                                              [weakSelf viewDidLayoutSubviews];
                                                              weakSelf.colorPan.hidden = NO;
                                                          }
                                                     completion:^{
                                                         [UIView animateWithDuration:.3f animations:^{
                                                             weakSelf.colorPan.hidden = NO;
                                                         }];
                                                         
                                                     }];
}

#pragma mark -
- (void)swapToolBarWithEditting {
    switch (_currentMode) {
        case EditorDrawMode:
        {
            self.panButton.selected = YES;
            self.mosaicButton.selected = NO;
            if (self.drawTool.allLineMutableArray.count > 0) {
                self.undoButton.hidden  = NO;
                self.newundoButton.selected = NO;
            }
            self.functionBottomView.hidden  = NO;
            [self functionisDisplayMosaic:NO];
        }
            break;
        case EditorTextMode:
            self.mosaicButton.selected = NO;
            self.functionBottomView.hidden  = YES;
            break;
        case EditorClipMode:
            self.mosaicButton.selected = NO;
            self.functionBottomView.hidden  = YES;

            break;
        case EditorNonMode:
        {
            self.panButton.selected = NO;
            self.mosaicButton.selected = NO;
            self.undoButton.hidden  = YES;
            self.newundoButton.selected = YES;
            self.functionBottomView.hidden  = YES;

        }
            break;
        case EditorMosaicMode:
            self.panButton.selected = NO;
            self.mosaicButton.selected = YES;
            self.functionBottomView.hidden  = NO;
            [self functionisDisplayMosaic:YES];
            break;
        default:
            break;
    }
}

- (void)functionisDisplayMosaic:(BOOL )isMosaic{
    if (isMosaic == YES) {
        self.newundoButton.selected = YES;
        self.colorPan.hidden = YES;
        self.mosaicTypeView.hidden = NO;
        
    }else{
        self.colorPan.hidden = NO;
        self.mosaicTypeView.hidden = YES;
    }
}

- (void)hiddenTopAndBottomBar:(BOOL)isHide animation:(BOOL)animation {
    if (self.keyboard.isShow) {
        [self.keyboard dismissWithAnimation:YES];
        return;
    }
    
    [UIView animateWithDuration:animation ? .25f : 0.f delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:isHide ? UIViewAnimationOptionCurveEaseOut : UIViewAnimationOptionCurveEaseIn animations:^{
        if (isHide) {
            bottomBarBottom.constant = -49.f * 2;
            topBarTop.constant = -64.f;
            self.functionBottomView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, self.bottomBar.size.height);
        } else {
            bottomBarBottom.constant = 0;
            topBarTop.constant = 0;
            self.functionBottomView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height -self.bottomBar.size.height * 2 , [UIScreen mainScreen].bounds.size.width, self.bottomBar.size.height);

        }
        _barsHiddenStatus = isHide;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hiddenColorPan:(BOOL)yesOrNot animation:(BOOL)animation {
    [UIView animateWithDuration:animation ? .25f : 0.f delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:yesOrNot ? UIViewAnimationOptionCurveEaseOut : UIViewAnimationOptionCurveEaseIn animations:^{
        self.colorPan.hidden = yesOrNot;
    } completion:^(BOOL finished) {
    
    }];
}

+ (UIImage *)createViewImage:(UIView *)shareView {
    UIGraphicsBeginImageContextWithOptions(shareView.bounds.size, NO, [UIScreen mainScreen].scale);
    [shareView.layer renderInContext:UIGraphicsGetCurrentContext()];
    shareView.layer.affineTransform = shareView.transform;
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)buildClipImageclipedCallback:(void(^)(UIImage *clipedImage))clipedCallback{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat WS = self.imageView.width/ self.drawingView.width;
        CGFloat HS = self.imageView.height/ self.drawingView.height;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.imageView.image.size.width, self.imageView.image.size.height),
                                               NO,
                                               self.imageView.image.scale);
        [self.imageView.image drawAtPoint:CGPointZero];
        CGFloat viewToimgW = self.imageView.width/self.imageView.image.size.width;
        CGFloat viewToimgH = self.imageView.height/self.imageView.image.size.height;
        __unused CGFloat drawX = self.imageView.left/viewToimgW;
        CGFloat drawY = self.imageView.top/viewToimgH;
        [_drawingView.image drawInRect:CGRectMake(0, -drawY, self.imageView.image.size.width/WS, self.imageView.image.size.height/HS)];
        
        UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //HideBusyIndicatorForView(self.view);
            UIImage *image = [UIImage imageWithCGImage:tmp.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            clipedCallback(image);
            
        });
    });
}

- (void)buildClipImageShowHud:(BOOL)showHud clipedCallback:(void(^)(UIImage *clipedImage))clipedCallback {
    if (showHud) {
        //ShowBusyTextIndicatorForView(self.view, @"生成图片中...", nil);
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat WS = self.imageView.width/ self.drawingView.width;
        CGFloat HS = self.imageView.height/ self.drawingView.height;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.imageView.image.size.width, self.imageView.image.size.height),
                                               NO,
                                               self.imageView.image.scale);
        [self.imageView.image drawAtPoint:CGPointZero];
        CGFloat viewToimgW = self.imageView.width/self.imageView.image.size.width;
        CGFloat viewToimgH = self.imageView.height/self.imageView.image.size.height;
        __unused CGFloat drawX = self.imageView.left/viewToimgW;
        CGFloat drawY = self.imageView.top/viewToimgH;
        [_drawingView.image drawInRect:CGRectMake(0, -drawY, self.imageView.image.size.width/WS, self.imageView.image.size.height/HS)];
        
        for (UIView *subV in _drawingView.subviews) {
            if ([subV isKindOfClass:[WBGTextToolView class]]) {
                WBGTextToolView *textLabel = (WBGTextToolView *)subV;
                //进入正常状态
                [WBGTextToolView setInactiveTextView:textLabel];
                
                //生成图片
                 __unused UIView *tes = textLabel.archerBGView;
                UIImage *textImg = [self.class screenshot:textLabel.archerBGView orientation:UIDeviceOrientationPortrait usePresentationLayer:YES];
                CGFloat rotation = textLabel.archerBGView.layer.transformRotationZ;
                textImg = [textImg imageRotatedByRadians:rotation];
                
                CGFloat selfRw = self.imageView.bounds.size.width / self.imageView.image.size.width;
                CGFloat selfRh = self.imageView.bounds.size.height / self.imageView.image.size.height;
                
                CGFloat sw = textImg.size.width / selfRw;
                CGFloat sh = textImg.size.height / selfRh;
                
                [textImg drawInRect:CGRectMake(textLabel.left/selfRw, (textLabel.top/selfRh) - drawY, sw, sh)];
            }
        }
        
        UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //HideBusyIndicatorForView(self.view);
            UIImage *image = [UIImage imageWithCGImage:tmp.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            clipedCallback(image);
            
        });
    });
}

+ (UIImage *)screenshot:(UIView *)view orientation:(UIDeviceOrientation)orientation usePresentationLayer:(BOOL)usePresentationLayer
{
    CGSize size = view.bounds.size;
    CGSize targetSize = CGSizeMake(size.width * view.layer.transformScaleX, size.height *  view.layer.transformScaleY);
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, [UIScreen mainScreen].scale);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    [view drawViewHierarchyInRect:CGRectMake(0, 0, targetSize.width, targetSize.height) afterScreenUpdates:NO];
    CGContextRestoreGState(ctx);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

#pragma mark - Class WBGWColorPan
@interface WBGColorPan ()
@property (nonatomic, strong) UIColor *currentColor;
@property (strong, nonatomic) IBOutletCollection(ColorfullButton) NSArray *colorButtons;

@property (weak, nonatomic) IBOutlet ColorfullButton *redButton;
@property (weak, nonatomic) IBOutlet ColorfullButton *orangeButton;
@property (weak, nonatomic) IBOutlet ColorfullButton *yellowButton;
@property (weak, nonatomic) IBOutlet ColorfullButton *greenButton;
@property (weak, nonatomic) IBOutlet ColorfullButton *blueButton;
@property (weak, nonatomic) IBOutlet ColorfullButton *pinkButton;
@property (weak, nonatomic) IBOutlet ColorfullButton *whiteButton;

@end

@implementation WBGColorPan
- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentColor = [UIColor redColor];
        //[self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panSelectColor:)]];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _currentColor = [UIColor redColor];
        //[self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panSelectColor:)]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)panSelectColor:(UIPanGestureRecognizer *)recognizer {
    
    NSLog(@"recon = %@", NSStringFromCGPoint([recognizer translationInView:self]));
}

- (IBAction)buttonAction:(UIButton *)sender {
    ColorfullButton *theBtns = (ColorfullButton *)sender;
    
    for (ColorfullButton *button in _colorButtons) {
        if (button == theBtns) {
            button.isUse = YES;
            self.currentColor = theBtns.color;
            [[NSNotificationCenter defaultCenter] postNotificationName:kColorPanNotificaiton object:self.currentColor];
        } else {
            button.isUse = NO;
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSLog(@"point: %@", NSStringFromCGPoint([touch locationInView:self]));
    NSLog(@"view=%@", touch.view);
    CGPoint touchPoint = [touch locationInView:self];
    for (ColorfullButton *button in _colorButtons) {
        CGRect rect = [button convertRect:button.bounds toView:self];
        if (CGRectContainsPoint(rect, touchPoint) && button.isUse == NO) {
            [self buttonAction:button];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    //NSLog(@"move->point: %@", NSStringFromCGPoint([touch locationInView:self]));
    CGPoint touchPoint = [touch locationInView:self];
    
    for (ColorfullButton *button in _colorButtons) {
        CGRect rect = [button convertRect:button.bounds toView:self];
        if (CGRectContainsPoint(rect, touchPoint) && button.isUse == NO) {
            [self buttonAction:button];
        }
    }
}

@end
