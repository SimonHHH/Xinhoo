//
//  YBIBImageCell.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/6/5.
//  Copyright © 2019 波儿菜. All rights reserved.
//

#import "YBIBImageCell.h"
#import "YBIBImageData.h"
#import "YBIBIconManager.h"
#import "YBIBImageScrollView.h"
#import "YBIBImageData+Internal.h"
#import "YBIBCopywriter.h"
#import "YBIBUtilities.h"
#import "YBIBTopView.h"

@interface YBIBImageCell () <YBIBImageDataDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) YBIBImageScrollView *imageScrollView;
@property (nonatomic, strong) UIImageView *tailoringImageView;
@property (nonatomic, assign) BOOL isHideTool;
@property (nonatomic, assign) BOOL isDowning;
@property (nonatomic, strong) UIButton *fullImageButton;
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation YBIBImageCell {
    CGPoint _interactStartPoint;
    BOOL _interacting;
}

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initValue];
        [self.contentView addSubview:self.imageScrollView];
        [self.contentView addSubview:self.fullImageButton];
        [self.fullImageButton addSubview:self.cancelButton];

        [self addGesture];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageScrollView.frame = self.bounds;
}

- (void)initValue {
    _interactStartPoint = CGPointZero;
    _interacting = NO;
    _isHideTool = NO;
}

- (void)prepareForReuse {
    ((YBIBImageData *)self.yb_cellData).delegate = nil;
    [self.imageScrollView reset];
    [self hideTailoringImageView];
    [self hideAuxiliaryView];
    [super prepareForReuse];
}

#pragma mark - <YBIBCellProtocol>

@synthesize yb_currentOrientation = _yb_currentOrientation;
@synthesize yb_containerSize = _yb_containerSize;
@synthesize yb_backView = _yb_backView;
@synthesize yb_collectionView = _yb_collectionView;
@synthesize yb_isTransitioning = _yb_isTransitioning;
@synthesize yb_isRotating = _yb_isRotating;
@synthesize yb_auxiliaryViewHandler = _yb_auxiliaryViewHandler;
@synthesize yb_hideStatusBar = _yb_hideStatusBar;
@synthesize yb_hideBrowser = _yb_hideBrowser;
@synthesize yb_hideToolViews = _yb_hideToolViews;
@synthesize yb_cellData = _yb_cellData;
@synthesize yb_cellIsInCenter = _yb_cellIsInCenter;
@synthesize yb_selfPage = _yb_selfPage;
@synthesize yb_currentPage = _yb_currentPage;

- (void)setYb_cellData:(id<YBIBDataProtocol>)yb_cellData {
    _yb_cellData = yb_cellData;
    ((YBIBImageData *)yb_cellData).delegate = self;
    
}

- (UIView *)yb_foregroundView {
    return self.imageScrollView.imageView;
}

- (void)yb_orientationWillChangeWithExpectOrientation:(UIDeviceOrientation)orientation {
    [self hideTailoringImageView];
}

- (void)yb_orientationChangeAnimationWithExpectOrientation:(UIDeviceOrientation)orientation {
    [self updateImageLayoutWithOrientation:orientation previousImageSize:self.imageScrollView.imageView.image.size];
}

#pragma mark - private

- (CGSize)contentSizeWithContainerSize:(CGSize)containerSize imageViewFrame:(CGRect)imageViewFrame {
    return CGSizeMake(MAX(containerSize.width, imageViewFrame.size.width), MAX(containerSize.height, imageViewFrame.size.height));
}

- (void)updateImageLayoutWithOrientation:(UIDeviceOrientation)orientation previousImageSize:(CGSize)previousImageSize {
    if (_interacting) [self restoreInteractionWithDuration:0];
    
    YBIBImageData *data = self.yb_cellData;
    
    CGSize imageSize;
    
    UIImage *image = self.imageScrollView.imageView.image;
    YBIBScrollImageType imageType = self.imageScrollView.imageType;
    if (imageType == YBIBScrollImageTypeCompressed) {
        imageSize = data.originImage ? data.originImage.size : image.size;
    } else {
        imageSize = image.size;
    }
    
    CGSize containerSize = self.yb_containerSize(orientation);
    CGRect imageViewFrame = [data.layout yb_imageViewFrameWithContainerSize:containerSize imageSize:imageSize orientation:orientation];
    CGSize contentSize = [self contentSizeWithContainerSize:containerSize imageViewFrame:imageViewFrame];
    CGFloat maxZoomScale = imageType == YBIBScrollImageTypeThumb ? 1 : [data.layout yb_maximumZoomScaleWithContainerSize:containerSize imageSize:imageSize orientation:orientation];
    
    // 'zoomScale' must set before 'contentSize' and 'imageView.frame'.
    self.imageScrollView.zoomScale = 1;
    self.imageScrollView.contentSize = contentSize;
    self.imageScrollView.minimumZoomScale = 1;
    self.imageScrollView.maximumZoomScale = maxZoomScale;

    CGFloat scale;
    if (previousImageSize.width > 0 && previousImageSize.height > 0) {
        scale = imageSize.width / imageSize.height - previousImageSize.width / previousImageSize.height;
    } else {
        scale = 0;
    }
    // '0.001' is admissible error.
    if (ABS(scale) <= 0.001) {
        self.imageScrollView.imageView.frame = imageViewFrame;
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.imageScrollView.imageView.frame = imageViewFrame;
        }];
    }
}

- (void)cuttingImage {
    // This method has been delayed called, so 'browser' may be in transit now.
    if (self.yb_isTransitioning()) return;
    if (_interacting) return;
    
    YBIBImageData *data = self.yb_cellData;
    if (!data.originImage) return;
    
    if (self.imageScrollView.zoomScale < data.cuttingZoomScale) return;
    
    if ([data shouldCompress]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cuttingImage_) object:nil];
        [self performSelector:@selector(cuttingImage_) withObject:nil afterDelay:0.15];
    }
}
- (void)cuttingImage_ {
    YBIBImageData *data = self.yb_cellData;
    if (!data.originImage) return;
    
    CGFloat scale = data.originImage.size.width / self.imageScrollView.contentSize.width;
    CGFloat x = self.imageScrollView.contentOffset.x * scale,
    y = self.imageScrollView.contentOffset.y * scale,
    width = self.imageScrollView.bounds.size.width * scale,
    height = self.imageScrollView.bounds.size.height * scale;
    
    __weak typeof(self) wSelf = self;
    [data cuttingImageToRect:CGRectMake(x, y, width, height) complete:^(UIImage *image) {
        if (!image) return;
        YBIB_DISPATCH_ASYNC_MAIN(^{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            if (data == self.yb_cellData && !self.imageScrollView.isDragging && !self->_interacting && !self.yb_isTransitioning()) {
                [self showTailoringImageView:image];
            }
        })
    }];

}

- (void)showTailoringImageView:(UIImage *)image {
    CGSize containerSize = self.yb_containerSize(self.yb_currentOrientation());
    if (!self.tailoringImageView.superview) {
        [self.contentView addSubview:self.tailoringImageView];
    }
    self.tailoringImageView.frame = CGRectMake(0, 0, containerSize.width, containerSize.height);
    self.tailoringImageView.hidden = NO;
    self.tailoringImageView.image = image;
}

- (void)showFullImageButton{
    CGSize containerSize = self.yb_containerSize(self.yb_currentOrientation());
      UIEdgeInsets padding = YBIBPaddingByBrowserOrientation(self.yb_currentOrientation());
      CGFloat width = containerSize.width - padding.left - padding.right, height = containerSize.height;
    self.fullImageButton.frame = CGRectMake(16, height - [YBIBTopView defaultHeight] - padding.bottom - 58, 124, 32);
    self.cancelButton.frame = CGRectMake(124-44, 0, 44, 32);

    YBIBImageData *imageData = self.yb_cellData;
    self.cancelButton.hidden = true;
    if (imageData.fullImageSize.length > 0) {
        self.fullImageButton.hidden = false;
        if ([imageData.imageURL.absoluteString isEqualToString:imageData.fullImageURL.absoluteString]) {
            [self.fullImageButton setTitle:NSLocalizedString(@"已完成", nil) forState:UIControlStateNormal];
            self.fullImageButton.userInteractionEnabled = false;
            self.fullImageButton.hidden = true;
        }else{
            self.isDowning = false;
            [self.fullImageButton setTitle:[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"查看原图", nil), imageData.fullImageSize] forState:UIControlStateNormal];
            self.fullImageButton.userInteractionEnabled = true;
        }
    }else{
        self.fullImageButton.hidden = true;
    }

}

- (void)hideTailoringImageView {
    // Don't use 'getter' method, because it's according to the need to load.
    if (_tailoringImageView) {
        self.tailoringImageView.hidden = YES;
    }
}

- (void)hideAuxiliaryView {
    [self.yb_auxiliaryViewHandler() yb_hideLoadingWithContainer:self];
    [self.yb_auxiliaryViewHandler() yb_hideToastWithContainer:self];
}

- (void)hideBrowser {
    ((YBIBImageData *)self.yb_cellData).delegate = nil;
    [self hideTailoringImageView];
    [self hideAuxiliaryView];
    self.yb_hideBrowser();
    _interacting = NO;
}

#pragma mark - <YBIBImageDataDelegate>

- (void)yb_imageData:(YBIBImageData *)data startLoadingWithStatus:(YBIBImageLoadingStatus)status {
    switch (status) {
        case YBIBImageLoadingStatusDecoding: {
            if (!self.imageScrollView.imageView.image) {
                [self.yb_auxiliaryViewHandler() yb_showLoadingWithContainer:self];
            }
        }
            break;
        case YBIBImageLoadingStatusProcessing: {
            if (!self.imageScrollView.imageView.image) {
                [self.yb_auxiliaryViewHandler() yb_showLoadingWithContainer:self];
            }
        }
            break;
        case YBIBImageLoadingStatusCompressing: {
            if (!self.imageScrollView.imageView.image) {
                [self.yb_auxiliaryViewHandler() yb_showLoadingWithContainer:self];
            }
        }
            break;
        case YBIBImageLoadingStatusReadingPHAsset: {
            if (!self.imageScrollView.imageView.image) {
                [self.yb_auxiliaryViewHandler() yb_showLoadingWithContainer:self];
            }
        }
            break;
        case YBIBImageLoadingStatusNone: {
            [self hideAuxiliaryView];
        }
            break;
        default:
            break;
    }
}

- (void)yb_imageData:(YBIBImageData *)data readyForImage:(__kindof UIImage *)image {
    [self.yb_auxiliaryViewHandler() yb_hideLoadingWithContainer:self];
    if (self.imageScrollView.imageView.image == image) return;
    
    CGSize size = self.imageScrollView.imageView.image.size;
    [self.imageScrollView setImage:image type:YBIBScrollImageTypeOriginal];
    [self updateImageLayoutWithOrientation:self.yb_currentOrientation() previousImageSize:size];
}

- (void)yb_imageData:(YBIBImageData *)data readyForCompressedImage:(__kindof UIImage *)image {
    [self.yb_auxiliaryViewHandler() yb_hideLoadingWithContainer:self];
    if (self.imageScrollView.imageView.image == image) return;
    
    CGSize size = self.imageScrollView.imageView.image.size;
    [self.imageScrollView setImage:image type:YBIBScrollImageTypeCompressed];
    [self updateImageLayoutWithOrientation:self.yb_currentOrientation() previousImageSize:size];
}

- (void)yb_imageData:(YBIBImageData *)data readyForThumbImage:(__kindof UIImage *)image {
    if (self.imageScrollView.imageView.image) return;
    
    [self.imageScrollView setImage:image type:YBIBScrollImageTypeThumb];
    [self updateImageLayoutWithOrientation:self.yb_currentOrientation() previousImageSize:image.size];
}

- (void)yb_imageData:(YBIBImageData *)data downloadProgress:(CGFloat)progress isFinish:(BOOL)isFinish isFail:(BOOL)isFail targetURL:(NSURL *)targetURL{
    YBIBImageData *imageData = self.yb_cellData;

    if (![imageData.fullImageURL.absoluteString isEqualToString:targetURL.absoluteString] && !isFinish) {
        return;
    }

    self.fullImageButton.userInteractionEnabled = false;
    self.cancelButton.hidden = isFinish;
    if (!isFinish) {
        self.isDowning = YES;
        self.fullImageButton.userInteractionEnabled = true;
        [self.fullImageButton setTitle:[NSString stringWithFormat:@"%.0lf%@",  progress * 100, @"%"] forState:UIControlStateNormal];
    }else{
        self.isDowning = false;

        if (isFail) {
            if (data.fullImageSize.length > 0) {
                self.fullImageButton.userInteractionEnabled = true;
                self.fullImageButton.hidden = false;
                [self.fullImageButton setTitle:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"查看原图", nil), data.fullImageSize] forState:UIControlStateNormal];
            }else{
                self.fullImageButton.hidden = true;
            }
        }else{
            [self.fullImageButton setTitle:NSLocalizedString(@"已完成", @"") forState:UIControlStateNormal];
            self.fullImageButton.userInteractionEnabled = false;
            __weak typeof(self) wSelf = self;
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                wSelf.fullImageButton.hidden = true;
            });
        }
    }
    
}


- (void)yb_imageIsInvalidForData:(YBIBImageData *)data {
    [self.yb_auxiliaryViewHandler() yb_hideLoadingWithContainer:self];
    NSString *imageIsInvalid = [YBIBCopywriter sharedCopywriter].imageIsInvalid;
    if (self.imageScrollView.imageView.image) {
        [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self text:imageIsInvalid];
    } else {
        [self.yb_auxiliaryViewHandler() yb_showLoadingWithContainer:self text:imageIsInvalid];
    }
}

- (void)yb_imageData:(YBIBImageData *)data downloadProgress:(CGFloat)progress {
    [self.yb_auxiliaryViewHandler() yb_showLoadingWithContainer:self progress:progress];
}

- (void)yb_imageDownloadFailedForData:(YBIBImageData *)data {
    if (self.imageScrollView.imageView.image) {
        [self.yb_auxiliaryViewHandler() yb_hideLoadingWithContainer:self];
//        [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self text:[YBIBCopywriter sharedCopywriter].downloadFailed];
    } else {
        [self.yb_auxiliaryViewHandler() yb_showLoadingWithContainer:self text:[YBIBCopywriter sharedCopywriter].downloadFailed];
    }
}

#pragma mark - gesture

- (void)addGesture {
    UITapGestureRecognizer *tapSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapSingle:)];
    tapSingle.numberOfTapsRequired = 1;
    UITapGestureRecognizer *tapDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapDouble:)];
    tapDouble.numberOfTapsRequired = 2;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToPan:)];
    pan.maximumNumberOfTouches = 1;
    pan.delegate = self;
    
    [tapSingle requireGestureRecognizerToFail:tapDouble];
    [tapSingle requireGestureRecognizerToFail:pan];
    [tapDouble requireGestureRecognizerToFail:pan];
    
    [self addGestureRecognizer:tapSingle];
    [self addGestureRecognizer:tapDouble];
    [self addGestureRecognizer:pan];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideBrowser) name:@"kHideBrowser" object:nil];
}

- (void)respondsToTapSingle:(UITapGestureRecognizer *)tap {
    if (self.yb_isRotating()) return;
    self.isHideTool = !self.isHideTool;
    YBIBImageData *data = self.yb_cellData;
    if (data.singleTouchBlock) {
        data.singleTouchBlock(data);
        self.yb_hideBrowser();
    } else {
        [self hideTailoringImageView];
        [self hideAuxiliaryView];
        self.yb_hideToolViews(self.isHideTool);
//        self.yb_hideBrowser();
    }
}

- (void)respondsToTapDouble:(UITapGestureRecognizer *)tap {
    if (self.yb_isRotating()) return;
    
    [self hideTailoringImageView];
    
    UIScrollView *scrollView = self.imageScrollView;
    UIView *zoomView = [self viewForZoomingInScrollView:scrollView];
    CGPoint point = [tap locationInView:zoomView];
    if (!CGRectContainsPoint(zoomView.bounds, point)) return;
    if (scrollView.zoomScale == scrollView.maximumZoomScale) {
        [scrollView setZoomScale:1 animated:YES];
    } else {
        [scrollView zoomToRect:CGRectMake(point.x, point.y, 1, 1) animated:YES];
    }
}


- (void)respondsToPan:(UIPanGestureRecognizer *)pan {
    if (self.yb_isRotating()) return;
    
    YBIBInteractionProfile *profile = ((YBIBImageData *)self.yb_cellData).interactionProfile;
    if (profile.disable) return;
    if ((CGRectIsEmpty(self.imageScrollView.imageView.frame) || !self.imageScrollView.imageView.image)) return;
    
    CGPoint point = [pan locationInView:self];
    CGSize containerSize = self.yb_containerSize(self.yb_currentOrientation());
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        _interactStartPoint = point;
    } else if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateRecognized || pan.state == UIGestureRecognizerStateFailed) {
        
        // End.
        if (_interacting) {
            CGPoint velocity = [pan velocityInView:self.imageScrollView];
            
            BOOL velocityArrive = ABS(velocity.y) > profile.dismissVelocityY;
            BOOL distanceArrive = ABS(point.y - _interactStartPoint.y) > containerSize.height * profile.dismissScale;
            
            BOOL shouldDismiss = distanceArrive || velocityArrive;
            if (shouldDismiss) {
                [self hideBrowser];
            } else {
                [self restoreInteractionWithDuration:profile.restoreDuration];
            }
        }
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        if (_interacting) {

            // Change.
            self.imageScrollView.center = point;
            CGFloat scale = 1 - ABS(point.y - _interactStartPoint.y) / (containerSize.height * 1.2);
            if (scale > 1) scale = 1;
            if (scale < 0.35) scale = 0.35;
            self.imageScrollView.transform = CGAffineTransformMakeScale(scale, scale);

            CGFloat alpha = 1 - ABS(point.y - _interactStartPoint.y) / (containerSize.height * 0.7);
            if (alpha > 1) alpha = 1;
            if (alpha < 0) alpha = 0;
            self.yb_backView.backgroundColor = [self.yb_backView.backgroundColor colorWithAlphaComponent:alpha];

        } else {

            // Start.
            if (CGPointEqualToPoint(_interactStartPoint, CGPointZero) || self.yb_currentPage() != self.yb_selfPage() || !self.yb_cellIsInCenter() || self.imageScrollView.isZooming) return;

            CGPoint velocity = [pan velocityInView:self.imageScrollView];
            CGFloat triggerDistance = profile.triggerDistance;
            CGFloat offsetY = self.imageScrollView.contentOffset.y, height = self.imageScrollView.bounds.size.height;

            BOOL distanceArrive = ABS(point.x - _interactStartPoint.x) < triggerDistance && ABS(velocity.x) < 500;
            BOOL upArrive = point.y - _interactStartPoint.y > triggerDistance && offsetY <= 1;
            BOOL downArrive = point.y - _interactStartPoint.y < -triggerDistance && offsetY + height >= MAX(self.imageScrollView.contentSize.height, height) - 1;

            BOOL shouldStart = (upArrive || downArrive) && distanceArrive;
            if (!shouldStart) return;

            _interactStartPoint = point;

            CGRect startFrame = self.imageScrollView.frame;
            CGFloat anchorX = point.x / startFrame.size.width, anchorY = point.y / startFrame.size.height;
            self.imageScrollView.layer.anchorPoint = CGPointMake(anchorX, anchorY);
            self.imageScrollView.userInteractionEnabled = NO;
            self.imageScrollView.scrollEnabled = NO;
            self.imageScrollView.center = point;
            
            self.yb_hideToolViews(YES);
            self.yb_hideStatusBar(NO);
            self.yb_collectionView().scrollEnabled = NO;
            [self hideTailoringImageView];

            _interacting = YES;
        }
    }
}

- (void)restoreInteractionWithDuration:(NSTimeInterval)duration {
    CGSize containerSize = self.yb_containerSize(self.yb_currentOrientation());
    
    void (^animations)(void) = ^{
        self.yb_backView.backgroundColor = [self.yb_backView.backgroundColor colorWithAlphaComponent:1];
        
        CGPoint anchorPoint = self.imageScrollView.layer.anchorPoint;
        self.imageScrollView.center = CGPointMake(containerSize.width * anchorPoint.x, containerSize.height * anchorPoint.y);
        self.imageScrollView.transform = CGAffineTransformIdentity;
    };
    void (^completion)(BOOL finished) = ^(BOOL finished){
        self.imageScrollView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.imageScrollView.center = CGPointMake(containerSize.width * 0.5, containerSize.height * 0.5);
        self.imageScrollView.userInteractionEnabled = YES;
        self.imageScrollView.scrollEnabled = YES;
        
        self.yb_hideToolViews(NO);
        self.yb_hideStatusBar(YES);
        self.yb_collectionView().scrollEnabled = YES;
        [self cuttingImage];
        
        self->_interactStartPoint = CGPointZero;
        self->_interacting = NO;
    };
    
    if (duration <= 0) {
        animations();
        completion(NO);
    } else {
        [UIView animateWithDuration:duration animations:animations completion:completion];
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    YBIBImageData *data = self.yb_cellData;
    if (data.imageDidZoomBlock) {
        data.imageDidZoomBlock(data, scrollView);
    }

    CGRect imageViewFrame = self.imageScrollView.imageView.frame;
    CGFloat width = imageViewFrame.size.width,
    height = imageViewFrame.size.height,
    sHeight = scrollView.bounds.size.height,
    sWidth = scrollView.bounds.size.width;
    if (height > sHeight) {
        imageViewFrame.origin.y = 0;
    } else {
        imageViewFrame.origin.y = (sHeight - height) / 2.0;
    }
    if (width > sWidth) {
        imageViewFrame.origin.x = 0;
    } else {
        imageViewFrame.origin.x = (sWidth - width) / 2.0;
    }
    self.imageScrollView.imageView.frame = imageViewFrame;
//    CGFloat offsetX = (self.imageScrollView.frame.size.width > self.imageScrollView.contentSize.width) ? ((self.imageScrollView.frame.size.width - self.imageScrollView.contentSize.width) * 0.5) : 0.0;
//    CGFloat offsetY = (self.imageScrollView.frame.size.height > self.imageScrollView.contentSize.height) ? ((self.imageScrollView.tz_height - self.imageScrollView.contentSize.height) * 0.5) : 0.0;
//    self.imageContainerView.center = CGPointMake(self.imageScrollView.contentSize.width * 0.5 + offsetX, self.imageScrollView.contentSize.height * 0.5 + offsetY);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageScrollView.imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    YBIBImageData *data = self.yb_cellData;
    if (data.imageDidScrollBlock) {
        data.imageDidScrollBlock(data, scrollView);
    }
//    [self cuttingImage];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    [self hideTailoringImageView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hideTailoringImageView];
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - getters

- (YBIBImageScrollView *)imageScrollView {
    if (!_imageScrollView) {
        _imageScrollView = [YBIBImageScrollView new];
        _imageScrollView.delegate = self;
    }
    return _imageScrollView;
}

- (UIImageView *)tailoringImageView {
    if (!_tailoringImageView) {
        _tailoringImageView = [UIImageView new];
        _tailoringImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _tailoringImageView;
}

- (UIButton *)fullImageButton {
    if (!_fullImageButton) {
        _fullImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullImageButton setTitle:NSLocalizedString(@"查看原图", nil) forState:UIControlStateNormal];
        _fullImageButton.clipsToBounds = true;
        _fullImageButton.layer.cornerRadius = 16;
        _fullImageButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _fullImageButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [_fullImageButton addTarget:self action:@selector(clickFullImagelButton:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _fullImageButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setImage:[UIImage imageNamed:@"close_downImage"] forState:UIControlStateNormal];
        _cancelButton.backgroundColor = [UIColor clearColor];
        [_cancelButton addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _cancelButton;
}

- (void)clickFullImagelButton:(UIButton *)button{
    if (self.isDowning){return;}
    NSLog(@"点击原图下载。。。。");
    YBIBImageData *imageData = self.yb_cellData;
    if (imageData.fullImageURL.absoluteString.length == 0) return;
    self.fullImageButton.userInteractionEnabled = true;
    [imageData loadFullURL_download];
}

- (void)clickCancelButton:(UIButton *)button{
    YBIBImageData *imageData = self.yb_cellData;
    [imageData cancelFullURL_download];
}

@end
