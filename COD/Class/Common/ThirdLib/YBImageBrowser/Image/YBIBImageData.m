//
//  YBIBImageData.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/6/5.
//  Copyright © 2019 波儿菜. All rights reserved.
//

#import "YBImage.h"
#import "YBIBImageData.h"
#import "YBIBImageCell.h"
#import "YBIBPhotoAlbumManager.h"
#import "YBIBImageData+Internal.h"
#import "YBIBUtilities.h"
#import "YBIBImageCache+Internal.h"
#import "YBIBSentinel.h"
#import "YBIBCopywriter.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "COD-Swift.h"

extern CGImageRef YYCGImageCreateDecodedCopy(CGImageRef imageRef, BOOL decodeForDisplay);

static dispatch_queue_t YBIBImageProcessingQueue(void) {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.yangbo.imagebrowser.imageprocessing", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

@implementation YBIBImageData {
    __weak id _downloadToken;
    SDWebImageDownloadToken *_fullDownloadToken;

    YBIBSentinel *_cuttingSentinel;
    /// Stop processing tasks when in freeze.
    BOOL _freezing;
}

#pragma mark - life cycle

- (void)dealloc {
    if (_downloadToken) {
        [YBIBWebImageManager cancelTaskWithDownloadToken:_downloadToken];
    }
    if (_fullDownloadToken) {
        [YBIBWebImageManager cancelTaskWithDownloadToken:_fullDownloadToken];
    }
    [self.imageCache removeForKey:self.cacheKey];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initValue];
    }
    return self;
}

- (void)initValue {
    _defaultLayout = _layout = [YBIBImageLayout new];
    _loadingStatus = YBIBImageLoadingStatusNone;
    _compressingSize = 4096 * 4096;
    _shouldPreDecodeAsync = YES;
    _freezing = NO;
    _cuttingSentinel = [YBIBSentinel new];
    _interactionProfile = [YBIBInteractionProfile new];
}

#pragma mark - load data

- (void)loadData {
    
    if (self.imageURL != nil) {
        
        NSString *cachePath = [CustomUtil movePicPathToConversationWithPicUrl:self.imageURL filePath:@""];
        if (cachePath != nil && cachePath.length > 0) {
            self.imagePath = cachePath;
        }
        
    }


    if (self.msgID == nil || self.msgID.length == 0){
        NSString *hideString = @"1";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kBottomViewHidden" object:nil userInfo:@{@"isHidden":hideString}];
    }
    _freezing = NO;
    
    // Avoid handling asynchronous tasks repeatedly.
    if (self.loadingStatus != YBIBImageLoadingStatusNone) {
        [self loadThumbImage];
        self.loadingStatus = self.loadingStatus;
        return;
    }
    
    if (self.originImage) {
        [self loadOriginImage];
    } else if (self.imageName || self.imagePath || self.imageData) {
        [self loadYBImage];
    } else if (self.image) {
        [self loadImageBlock];
    } else if (self.imageURL) {
        [self loadThumbImage];
        [self loadURL];
    } else if (self.imagePHAsset) {
        [self loadThumbImage];
        [self loadPHAsset];
    } else {
        [self.delegate yb_imageIsInvalidForData:self];
    }
}

- (void)loadOriginImage {
    if (_freezing) return;
    if (!self.originImage) return;
    
    if ([self shouldCompress]) {
        if (self.compressedImage) {
            [self.delegate yb_imageData:self readyForCompressedImage:self.compressedImage];
        } else {
            [self loadThumbImage];
            [self loadOriginImage_compress];
        }
    } else {
        [self.delegate yb_imageData:self readyForImage:self.originImage];
    }
}
- (void)loadOriginImage_compress {
    if (_freezing) return;
    if (!self.originImage) return;
    
    self.loadingStatus = YBIBImageLoadingStatusCompressing;
    __weak typeof(self) wSelf = self;
    CGSize size = [self bestSizeOfCompressing];

    YBIB_DISPATCH_ASYNC(YBIBImageProcessingQueue(), ^{
        if (self->_freezing) {
            self.loadingStatus = YBIBImageLoadingStatusNone;
            return;
        }
        // Ensure the best display effect.
        UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
        [self.originImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        if (self->_freezing) {
            UIGraphicsEndImageContext();
            self.loadingStatus = YBIBImageLoadingStatusNone;
            return;
        }
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        YBIB_DISPATCH_ASYNC_MAIN(^{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            
            self.loadingStatus = YBIBImageLoadingStatusNone;
            
            [self modifyImageWithModifier:self.compressedImageModifier image:resultImage completion:^(UIImage *processedImage) {
                __strong typeof(wSelf) self = wSelf;
                if (!self) return;
                self.compressedImage = processedImage ?: self.originImage;
                [self.delegate yb_imageData:self readyForCompressedImage:self.compressedImage];
            }];
        })
    })
}

- (void)loadYBImage {
    if (_freezing) return;
    NSString *name = self.imageName.copy;
    NSString *path = self.imagePath.copy;
    NSData *data = self.imageData ? self.imageData().copy : nil;
    if (name.length == 0 && path.length == 0 && data.length == 0) return;
    
    YBImageDecodeDecision decision = [self defaultDecodeDecision];
    
    __block YBImage *image;
    __weak typeof(self) wSelf = self;
    void(^dealBlock)(void) = ^{
        if (name.length > 0) {
            image = [YBImage imageNamed:name decodeDecision:decision];
        } else if (path.length > 0) {
//            URL.init(fileURLWithPath: fileName)
            image = [YBImage imageWithContentsOfFile:[NSURL URLWithString:path].absoluteString decodeDecision:decision];
            if (image == nil) {
                image = [YBImage imageWithData:data scale:UIScreen.mainScreen.scale decodeDecision:decision];
            }
        } else if (data.length > 0) {
           
            image = [YBImage imageWithData:data scale:UIScreen.mainScreen.scale decodeDecision:decision];
        }
        YBIB_DISPATCH_ASYNC_MAIN(^{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            self.loadingStatus = YBIBImageLoadingStatusNone;
            if (image) {
                [self setOriginImageAndLoadWithImage:image];
            } else {
                [self.delegate yb_imageIsInvalidForData:self];
            }
        })
    };
    
    if (self.shouldPreDecodeAsync) {
        [self loadThumbImage];
        self.loadingStatus = YBIBImageLoadingStatusDecoding;
        YBIB_DISPATCH_ASYNC(YBIBImageProcessingQueue(), dealBlock)
    } else {
        self.loadingStatus = YBIBImageLoadingStatusDecoding;
        dealBlock();
    }
}

- (void)loadImageBlock {
    if (_freezing) return;
    __block UIImage *image = self.image ? self.image() : nil;
    if (!image) return;
    
    BOOL shouldPreDecode = self.preDecodeDecision ? self.preDecodeDecision(self, image.size, image.scale) : ![self shouldCompressWithImage:image];
    
    __weak typeof(self) wSelf = self;
    void(^dealBlock)(void) = ^{
        // Do not need to decode If 'image' conformed 'YYAnimatedImage'. (Not entirely accurate.)
        if (![image conformsToProtocol:@protocol(YYAnimatedImage)]) {
            CGImageRef cgImage = YYCGImageCreateDecodedCopy(image.CGImage, shouldPreDecode);
            image = [UIImage imageWithCGImage:cgImage];
            if (cgImage) CGImageRelease(cgImage);
        }
        YBIB_DISPATCH_ASYNC_MAIN(^{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            self.loadingStatus = YBIBImageLoadingStatusNone;
            [self setOriginImageAndLoadWithImage:image];
        })
    };
    
    if (self.shouldPreDecodeAsync) {
        [self loadThumbImage];
        self.loadingStatus = YBIBImageLoadingStatusDecoding;
        YBIB_DISPATCH_ASYNC(YBIBImageProcessingQueue(), dealBlock)
    } else {
        self.loadingStatus = YBIBImageLoadingStatusDecoding;
        dealBlock();
    }
}

- (void)loadURL {
    if (!self.imageURL || self.imageURL.absoluteString.length == 0) return;
    [self loadURL_queryCache];
}
- (void)loadURL_queryCache {
    if (_freezing) return;
    if (self.imageURL != nil) {
        [CustomUtil movePicPathToConversationWithPicUrl:self.imageURL filePath:@""];
    }
    
    if (!self.imageURL || self.imageURL.absoluteString.length == 0) return;
    
    YBImageDecodeDecision decision = [self defaultDecodeDecision];
    
    self.loadingStatus = YBIBImageLoadingStatusQuerying;
    [YBIBWebImageManager queryCacheOperationForKey:self.imageURL completed:^(UIImage * _Nullable image, NSData * _Nullable imageData) {
        if (!imageData || imageData.length == 0) {
            YBIB_DISPATCH_ASYNC_MAIN(^{
                self.loadingStatus = YBIBImageLoadingStatusNone;
                [self loadURL_download];
            })
            return;
        }
        
        YBIB_DISPATCH_ASYNC(YBIBImageProcessingQueue(), ^{
            if (self->_freezing) {
                self.loadingStatus = YBIBImageLoadingStatusNone;
                return;
            }
            YBImage *image = [YBImage imageWithData:imageData scale:UIScreen.mainScreen.scale decodeDecision:decision];
            __weak typeof(self) wSelf = self;
            YBIB_DISPATCH_ASYNC_MAIN(^{
                __strong typeof(wSelf) self = wSelf;
                if (!self) return;
                self.loadingStatus = YBIBImageLoadingStatusNone;
                if (image) {    // Maybe the image data is invalid.
                    [self setOriginImageAndLoadWithImage:image];
                } else {
                    [self loadURL_download];
                }
            })
        })
    }];
}
- (void)loadURL_download {
    if (_freezing) return;
    if (!self.imageURL || self.imageURL.absoluteString.length == 0) return;
    
    YBImageDecodeDecision decision = [self defaultDecodeDecision];
    
    self.loadingStatus = YBIBImageLoadingStatusDownloading;
    __weak typeof(self) wSelf = self;
    [self.delegate yb_imageData:self downloadProgress:0];
    _downloadToken = [YBIBWebImageManager downloadImageWithURL:self.imageURL requestModifier:^NSURLRequest * _Nullable(NSURLRequest * _Nonnull request) {
        return self.requestModifier ? self.requestModifier(self, request) : request;
    } progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL ) {
        CGFloat progress = receivedSize * 1.0 / expectedSize ?: 0;
        YBIB_DISPATCH_ASYNC_MAIN(^{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            [self.delegate yb_imageData:self downloadProgress:progress];
        })
    } success:^(NSData * _Nullable imageData, BOOL finished) {
        if (!finished) return;

        YBIB_DISPATCH_ASYNC(YBIBImageProcessingQueue(), ^{
            [CustomUtil movePicPathToConversationWithPicUrl:self.imageURL filePath:@"" msgId:self.msgID];
            if (self->_freezing) {
                self.loadingStatus = YBIBImageLoadingStatusNone;
                return;
            }
            YBImage *image = [YBImage imageWithData:imageData scale:UIScreen.mainScreen.scale decodeDecision:decision];
            YBIB_DISPATCH_ASYNC_MAIN(^{
                __strong typeof(wSelf) self = wSelf;
                if (!self) return;
                [YBIBWebImageManager storeToDiskWithImageData:imageData forKey:self.imageURL];
                
                YBIB_DISPATCH_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    
                    NSString *cacheKey = [SDWebImageManager.sharedManager cacheKeyForURL:self.imageURL];
                    
                    [CustomUtil movePicPathToConversationWithPicUrl:self.imageURL filePath:[[SDImageCache sharedImageCache] cachePathForKey:cacheKey] msgId:self.msgID];
                    
                })
                
                self.loadingStatus = YBIBImageLoadingStatusNone;
                if (image) {
                    [self setOriginImageAndLoadWithImage:image];
                } else {
                    [self.delegate yb_imageIsInvalidForData:self];
                }
            })
        })
    } failed:^(NSError * _Nullable error, BOOL finished) {
        if (!finished) return;
        __strong typeof(wSelf) self = wSelf;
        if (!self) return;
        self.loadingStatus = YBIBImageLoadingStatusNone;
        [self.delegate yb_imageDownloadFailedForData:self];
    }];
}

- (void)loadFullURL_download{
    if (_freezing) return;
    if (!self.fullImageURL || self.fullImageURL.absoluteString.length == 0) return;
    
    YBImageDecodeDecision decision = [self defaultDecodeDecision];
    
    __weak typeof(self) wSelf = self;
    _fullDownloadToken = [YBIBWebImageManager downloadImageWithURL:self.fullImageURL requestModifier:^NSURLRequest * _Nullable(NSURLRequest * _Nonnull request) {
        return self.requestModifier ? self.requestModifier(self, request) : request;
    } progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        CGFloat progressF = receivedSize * 1.0 / expectedSize ?: 0;
        YBIB_DISPATCH_ASYNC_MAIN(^{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
//            progress(progressF);
            [self.delegate yb_imageData:self downloadProgress:progressF isFinish:false isFail:false targetURL:targetURL];

        })
    } success:^(NSData * _Nullable imageData, BOOL finished) {
        if (!finished) return;
        YBIB_DISPATCH_ASYNC(YBIBImageProcessingQueue(), ^{
            [CustomUtil movePicPathToConversationWithPicUrl:self.fullImageURL filePath:@"" msgId:self.msgID];
            if (self->_freezing) {
//                self.loadingStatus = YBIBImageLoadingStatusNone;
                return;
            }
            YBImage *image = [YBImage imageWithData:imageData scale:UIScreen.mainScreen.scale decodeDecision:decision];
            YBIB_DISPATCH_ASYNC_MAIN(^{
                __strong typeof(wSelf) self = wSelf;
                if (!self) return;
                self.imageURL = self.fullImageURL;
                [YBIBWebImageManager storeToDiskWithImageData:imageData forKey:self.fullImageURL];
                
                YBIB_DISPATCH_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    
                    NSString *cacheKey = [SDWebImageManager.sharedManager cacheKeyForURL:self.fullImageURL];
                    
                    [CustomUtil movePicPathToConversationWithPicUrl:self.fullImageURL filePath:[[SDImageCache sharedImageCache] cachePathForKey:cacheKey] msgId:self.msgID];
                    
                })
//                self.loadingStatus = YBIBImageLoadingStatusNone;
                [self.delegate yb_imageData:self downloadProgress:0 isFinish:true isFail:false targetURL:[[NSURL alloc] initWithString:@""] ];

                if (image) {
                    [self setOriginImageAndLoadWithImage:image];
                } else {
                    [self.delegate yb_imageIsInvalidForData:self];
                }
            })
        })
    } failed:^(NSError * _Nullable error, BOOL finished) {
        if (!finished) return;
        __strong typeof(wSelf) self = wSelf;
        if (!self) return;
        [self.delegate yb_imageData:self downloadProgress:0 isFinish:true isFail:true targetURL:[[NSURL alloc] initWithString:@""]];

    }];
}

- (void)cancelFullURL_download{
    [self.delegate yb_imageData:self downloadProgress:0 isFinish:true isFail:true targetURL:[[NSURL alloc] initWithString:@""]];
    [YBIBWebImageManager cancelTaskWithDownloadToken:_fullDownloadToken];
}

- (void)loadPHAsset {
    if (_freezing) return;
    if (!self.imagePHAsset) return;
    
    YBImageDecodeDecision decision = [self defaultDecodeDecision];
    
    self.loadingStatus = YBIBImageLoadingStatusReadingPHAsset;
    YBIB_DISPATCH_ASYNC(YBIBImageProcessingQueue(), ^{
        [YBIBPhotoAlbumManager getImageDataWithPHAsset:self.imagePHAsset completion:^(NSData * _Nullable data) {
            if (self->_freezing) {
                self.loadingStatus = YBIBImageLoadingStatusNone;
                return;
            }
            YBImage *image = [YBImage imageWithData:data scale:UIScreen.mainScreen.scale decodeDecision:decision];
            __weak typeof(self) wSelf = self;
            YBIB_DISPATCH_ASYNC_MAIN(^{
                __strong typeof(wSelf) self = wSelf;
                if (!self) return;
                
                self.loadingStatus = YBIBImageLoadingStatusNone;
                if (image) {
                    [self setOriginImageAndLoadWithImage:image];
                } else {
                    [self.delegate yb_imageIsInvalidForData:self];
                }
            })
        }];
    })
}

- (void)loadThumbImage {
    if (_freezing) return;
    if (self.thumbImage) {
        [self.delegate yb_imageData:self readyForThumbImage:self.thumbImage];
    } else if (self.thumbURL) {
        __weak typeof(self) wSelf = self;
        [CustomUtil imageVeiwDownLoadWithPicUrl:self.thumbURL imageView:[UIImageView new] placeholderImage:[UIImage new] filePath:@""  autoPlay:NO completedBlock:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            
            UIImage *thumbImage;
            if (image) {
                thumbImage = image;
            }
            // If the target image is ready, ignore the thumb image.
//            BOOL shouldIgnore = [self shouldCompress] ? (self.compressedImage != nil) : (thumbImage != nil);
//            if (!shouldIgnore) {
                [self.delegate yb_imageData:self readyForThumbImage:thumbImage];
//            }
        }];
    } else if (self.projectiveView && [self.projectiveView isKindOfClass:UIImageView.self] && ((UIImageView *)self.projectiveView).image) {
        UIImage *thumbImage = ((UIImageView *)self.projectiveView).image;
        [self.delegate yb_imageData:self readyForThumbImage:thumbImage];
    }
}

#pragma mark - internal

- (void)cuttingImageToRect:(CGRect)rect complete:(void (^)(UIImage * _Nullable))complete {
    if (_freezing) return;
    if (!self.originImage) return;
    
    int32_t value = [_cuttingSentinel increase];
    BOOL (^isCancelled)(void) = ^BOOL(void) {
        if (self->_freezing) return YES;
        return value != self->_cuttingSentinel.value;
    };
    
    YBIB_DISPATCH_ASYNC(YBIBImageProcessingQueue(), ^{
        if (isCancelled()) {
            complete(nil);
            return;
        }
        // Physical pixel.
        CGFloat scale = self.originImage.scale;
        CGRect rectOfPhysical = rect;
        rectOfPhysical.size.width *= scale;
        rectOfPhysical.size.height *= scale;
        CGImageRef cgImage = CGImageCreateWithImageInRect(self.originImage.CGImage, rectOfPhysical);
        if (isCancelled()) {
            complete(nil);
            if (cgImage) CGImageRelease(cgImage);
            return;
        }
        CGSize size = [self bestSizeOfCuttingWithOriginSize:CGSizeMake(CGImageGetWidth(cgImage), CGImageGetHeight(cgImage))];
        UIImage *tmpImage = [UIImage imageWithCGImage:cgImage];
        if (isCancelled()) {
            complete(nil);
            if (cgImage) CGImageRelease(cgImage);
            return;
        }
        // Ensure the best display effect.
        UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
        [tmpImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        if (isCancelled()) {
            complete(nil);
            UIGraphicsEndImageContext();
            if (cgImage) CGImageRelease(cgImage);
            return;
        }
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (cgImage) CGImageRelease(cgImage);
        
        __weak typeof(self) wSelf = self;
        YBIB_DISPATCH_ASYNC_MAIN(^{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            
            [self modifyImageWithModifier:self.cuttedImageModifier image:resultImage completion:^(UIImage *image) {
                __strong typeof(wSelf) self = wSelf;
                if (!self) return;
                complete(image);
            }];
        })
    })
}

- (BOOL)shouldCompress {
    return [self shouldCompressWithImage:self.originImage];
}

#pragma mark - public

- (BOOL)shouldCompressWithImage:(UIImage *)image {
    if (!image) return NO;
    return [self shouldCompressWithImageSize:image.size scale:image.scale];
}

- (void)stopLoading {
    _freezing = YES;
    self.loadingStatus = YBIBImageLoadingStatusNone;
}

- (void)clearCache {
    [self.imageCache removeForKey:self.cacheKey];
}

#pragma mark - private

/// 'size': logic pixel.
- (BOOL)shouldCompressWithImageSize:(CGSize)size scale:(CGFloat)scale {
    return size.width * scale * size.height * scale > self.compressingSize;
}

/// Logic pixel.
- (CGSize)bestSizeOfCompressing {
    if (!self.originImage) return CGSizeZero;
    UIDeviceOrientation orientation = self.yb_currentOrientation();
    CGRect imageViewFrame = [self.layout yb_imageViewFrameWithContainerSize:self.yb_containerSize(orientation) imageSize:self.originImage.size orientation:orientation];
    return imageViewFrame.size;
}

/// Logic pixel.
- (CGSize)bestSizeOfCuttingWithOriginSize:(CGSize)originSize {
    CGSize containerSize = self.yb_containerSize(self.yb_currentOrientation());
    CGFloat maxWidth = containerSize.width, maxHeight = containerSize.height;
    CGFloat oWidth = originSize.width, oHeight = originSize.height;
    if (maxWidth <= 0 || maxHeight <= 0 || oWidth <= 0 || oHeight <= 0) return CGSizeZero;
    
    if (oWidth <= maxWidth && oHeight <= maxHeight) {
        return originSize;
    }
    CGFloat rWidth = 0, rHeight = 0;
    if (oWidth / maxWidth < oHeight / maxHeight) {
        rHeight = maxHeight;
        rWidth = oWidth / oHeight * rHeight;
    } else {
        rWidth = maxWidth;
        rHeight = oHeight / oWidth * rWidth;
    }
    return CGSizeMake(rWidth, rHeight);
}

- (YBImageDecodeDecision)defaultDecodeDecision {
    __weak typeof(self) wSelf = self;
    return ^BOOL(CGSize imageSize, CGFloat scale) {
        __strong typeof(wSelf) self = wSelf;
        if (!self) return NO;
        CGSize logicSize = CGSizeMake(imageSize.width / scale, imageSize.height / scale);
        if (self.preDecodeDecision) return self.preDecodeDecision(self, logicSize, scale);
        if ([self shouldCompressWithImageSize:logicSize scale:scale]) return NO;
        return YES;
    };
}

- (void)modifyImageWithModifier:(YBIBImageModifierBlock)modifier image:(UIImage *)image completion:(void(^)(UIImage *processedImage))completion {
    if (modifier) {
        self.loadingStatus = YBIBImageLoadingStatusProcessing;
        __weak typeof(self) wSelf = self;
        modifier(self, image, ^(UIImage *processedImage){
            YBIB_DISPATCH_ASYNC_MAIN(^{
                // This step is necessary, maybe 'self' is already 'dealloc' if processing code takes too much time.
                __strong typeof(wSelf) self = wSelf;
                if (!self) return;
                self.loadingStatus = YBIBImageLoadingStatusNone;
                completion(processedImage);
            });
        });
    } else {
        completion(image);
    }
}

- (void)setOriginImageAndLoadWithImage:(UIImage *)image {
    __weak typeof(self) wSelf = self;
    [self modifyImageWithModifier:self.originImageModifier image:image completion:^(UIImage *processedImage) {
        __strong typeof(wSelf) self = wSelf;
        if (!self) return;
        self.originImage = processedImage;
        [self loadOriginImage];
    }];
}

- (void)saveToPhotoAlbumCompleteWithError:(nullable NSError *)error {
    if (error) {
        [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].saveToPhotoAlbumFailed];
    } else {
        [self.yb_auxiliaryViewHandler() yb_showCorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].saveToPhotoAlbumSuccess];
    }
}

- (void)UIImageWriteToSavedPhotosAlbum_completedWithImage:(UIImage *)image error:(NSError *)error context:(void *)context {
    [self saveToPhotoAlbumCompleteWithError:error];
}

- (YBIBImageCache *)imageCache {
    return self.yb_backView.ybib_imageCache;
}

#pragma mark - <YBIBDataProtocol>

@synthesize yb_isTransitioning = _yb_isTransitioning;
@synthesize yb_currentOrientation = _yb_currentOrientation;
@synthesize yb_containerSize = _yb_containerSize;
@synthesize yb_containerView = _yb_containerView;
@synthesize yb_auxiliaryViewHandler = _yb_auxiliaryViewHandler;
@synthesize yb_backView = _yb_backView;

- (nonnull Class)yb_classOfCell {
    return YBIBImageCell.self;
}

- (UIView *)yb_projectiveView {
    return self.projectiveView;
}

- (CGRect)yb_imageViewFrameWithContainerSize:(CGSize)containerSize imageSize:(CGSize)imageSize orientation:(UIDeviceOrientation)orientation {
    return [self.layout yb_imageViewFrameWithContainerSize:containerSize imageSize:imageSize orientation:orientation];
}

- (void)yb_preload {
    if (!self.delegate) {
        [self loadData];
    }
}

- (void)yb_saveToPhotoAlbum {
    void(^saveData)(NSData *) = ^(NSData * _Nonnull data){
        [[ALAssetsLibrary new] writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            [self saveToPhotoAlbumCompleteWithError:error];
        }];
    };
    void(^saveImage)(UIImage *) = ^(UIImage * _Nonnull image){
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(UIImageWriteToSavedPhotosAlbum_completedWithImage:error:context:), NULL);
    };
    void(^unableToSave)(void) = ^(){
        [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].unableToSave];
    };
    
    [YBIBPhotoAlbumManager getPhotoAlbumAuthorizationSuccess:^{
        if ([self.originImage conformsToProtocol:@protocol(YYAnimatedImage)] && [self.originImage respondsToSelector:@selector(animatedImageData)] && [self.originImage performSelector:@selector(animatedImageData)]) {
            NSData *data = [self.originImage performSelector:@selector(animatedImageData)];
            data ? saveData(data) : unableToSave();
        } else if (self.originImage) {
            saveImage(self.originImage);
        } else if (self.imageURL) {
            [YBIBWebImageManager queryCacheOperationForKey:self.imageURL completed:^(UIImage * _Nullable image, NSData * _Nullable data) {
                if (data) {
                    saveData(data);
                } else if (image) {
                    saveImage(image);
                } else {
                    unableToSave();
                }
            }];
        } else {
            unableToSave();
        }
    } failed:^{
        [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].getPhotoAlbumAuthorizationFailed];
    }];
}

/**
 *  分享
 *  多图分享，items里面直接放图片
 *  分享链接
 *  NSString *textToShare = @"mq分享";
 *  UIImage *imageToShare = [UIImage imageNamed:@"imageName"];
 *  NSURL *urlToShare = [NSURL URLWithString:@"https:www.baidu.com"];
 *  NSArray *items = @[urlToShare,textToShare,imageToShare];
 */
- (void)codShare{
    NSArray *items = [[NSArray alloc] init];
    if ([self.originImage conformsToProtocol:@protocol(YYAnimatedImage)] && [self.originImage respondsToSelector:@selector(animatedImageData)] && [self.originImage performSelector:@selector(animatedImageData)]) {
        NSData *data = [self.originImage performSelector:@selector(animatedImageData)];
        if (data != nil ) {
            UIImage *imageToShare = [[UIImage alloc] initWithData:data];
            items = @[imageToShare];
            [self imageShare:items];
        }
    } else if (self.originImage) {
        items = @[self.originImage];
        [self imageShare:items];
    } else if (self.imageURL) {
        [YBIBWebImageManager queryCacheOperationForKey:self.imageURL completed:^(UIImage * _Nullable image, NSData * _Nullable data) {
            if (data) {
                [self imageShare:@[data]];
            } else if (image) {
                [self imageShare:@[image]];
            } else {
                [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:@"不能分享此图片哦"];
            }
        }];
    } else {
        [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:@"不能分享此图片哦"];
    }
 }

- (void)imageShare:(NSArray *)items {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];

    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if (completed) {
            [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:@"操作成功"];
        }else{
            [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:@"操作失败"];
        }
    };
    //这儿一定要做iPhone与iPad的判断，因为这儿只有iPhone可以present，iPad需pop，所以这儿actVC.popoverPresentationController.sourceView = self.view;在iPad下必须有，不然iPad会crash，self.view你可以换成任何view，你可以理解为弹出的窗需要找个依托。
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        activityVC.popoverPresentationController.sourceView = self.yb_containerView;
        [vc presentViewController:activityVC animated:YES completion:nil];
    }else{
        activityVC.popoverPresentationController.sourceView = self.yb_containerView;
        [vc presentViewController:activityVC animated:YES completion:nil];
    }
}
#pragma mark - getters & setters

@synthesize delegate = _delegate;
- (void)setDelegate:(id<YBIBImageDataDelegate>)delegate {
    _delegate = delegate;
    if (delegate) {
        [self loadData];
    } else {
        _freezing = YES;
        // Remove the resident cache if '_delegate' is nil.
        [self.imageCache removeResidentForKey:self.cacheKey];
    }
}
- (id<YBIBImageDataDelegate>)delegate {
    // Stop sending data to the '_delegate' if it is transiting.
    return self.yb_isTransitioning() ? nil : _delegate;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = [imageURL isKindOfClass:NSString.class] ? [NSURL URLWithString:(NSString *)imageURL] : imageURL;
}

- (NSString *)cacheKey {
    return [NSString stringWithFormat:@"%p", self];
}

- (void)setOriginImage:(__kindof UIImage *)originImage {
    // 'image' should be resident if '_delegate' exists.
    [self.imageCache setImage:originImage type:YBIBImageCacheTypeOrigin forKey:self.cacheKey resident:self->_delegate != nil];
}
- (UIImage *)originImage {
    return [self.imageCache imageForKey:self.cacheKey type:YBIBImageCacheTypeOrigin];
}

- (void)setCompressedImage:(UIImage *)compressedImage {
    // 'image' should be resident if '_delegate' exists.
    [self.imageCache setImage:compressedImage type:YBIBImageCacheTypeCompressed forKey:self.cacheKey resident:_delegate != nil];
}
- (UIImage *)compressedImage {
    return [self.imageCache imageForKey:self.cacheKey type:YBIBImageCacheTypeCompressed];
}

- (void)setLoadingStatus:(YBIBImageLoadingStatus)loadingStatus {
    // Ensure thread safety.
    YBIB_DISPATCH_ASYNC_MAIN(^{
        self->_loadingStatus = loadingStatus;
        [self.delegate yb_imageData:self startLoadingWithStatus:loadingStatus];
    });
}

- (CGFloat)cuttingZoomScale {
    if (_cuttingZoomScale >= 1) return _cuttingZoomScale;
    _cuttingZoomScale = 1.1;
    if (!self.originImage) return _cuttingZoomScale;
    CGFloat imagePixel = self.originImage.size.width * self.originImage.size.height * self.originImage.scale * self.originImage.scale;
    // The larger the image size, the larger the '_cuttingZoomScale', in order to reduce the burden of CPU and memory.
    CGFloat scale = YBIBLowMemory() ? 0.28 : 0.19;
    _cuttingZoomScale += (imagePixel / self.compressingSize * scale);
    return _cuttingZoomScale;
}

@end
