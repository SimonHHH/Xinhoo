//
//  YBIBVideoData.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/10.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBVideoData.h"
#import "YBIBVideoCell.h"
#import "YBIBVideoData+Internal.h"
#import "YBIBUtilities.h"
#import "YBIBPhotoAlbumManager.h"
#import "YBIBCopywriter.h"
#import "COD-Swift.h"
#import "TXPhotoLibraryManager.h"
#import "YBIBWebImageManager.h"

extern CGImageRef YYCGImageCreateDecodedCopy(CGImageRef imageRef, BOOL decodeForDisplay);

@interface YBIBVideoData () <NSURLSessionDelegate>
@end

@implementation YBIBVideoData {
    NSURLSessionDownloadTask *_downloadTask;
}

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initValue];
    }
    return self;
}

- (void)initValue {
    _loadingFirstFrame = NO;
    _loadingAVAssetFromPHAsset = NO;
    _downloading = NO;
    _interactionProfile = [YBIBInteractionProfile new];
    _repeatPlayCount = 0;
    _autoPlayCount = 0;
    _shouldHideForkButton = NO;
    _allowSaveToPhotoAlbum = YES;
}

#pragma mark - load data

- (void)loadData {
    // Always load 'thumbImage'.
    [self loadThumbImage];
    
    if (self.videoAVAsset) {
        [self.delegate yb_videoData:self readyForAVAsset:self.videoAVAsset];
    } else if (self.videoPHAsset) {
        [self loadAVAssetFromPHAsset];
    } else {
        [self.delegate yb_videoIsInvalidForData:self];
    }
}

- (void)loadAVAssetFromPHAsset {
    if (!self.videoPHAsset) return;
    if (self.isLoadingAVAssetFromPHAsset) {
        self.loadingAVAssetFromPHAsset = YES;
        return;
    }
    
    self.loadingAVAssetFromPHAsset = YES;
    [YBIBPhotoAlbumManager getAVAssetWithPHAsset:self.videoPHAsset completion:^(AVAsset * _Nullable asset) {
        YBIB_DISPATCH_ASYNC_MAIN(^{
            self.loadingAVAssetFromPHAsset = NO;
            self.videoAVAsset = asset;
            [self.delegate yb_videoData:self readyForAVAsset:self.videoAVAsset];
            [self loadThumbImage];
        })
    }];
}

- (void)loadThumbImage {
    if (self.thumbImage) {
        NSLog(@"self.thumbImage");
        [self.delegate yb_videoData:self readyForThumbImage:self.thumbImage];
    } else if (self.thumbURL) {
        NSLog(@"thumbURL");

        __weak typeof(self) wSelf = self;
        [YBIBWebImageManager queryCacheOperationForKey:self.thumbURL completed:^(UIImage * _Nullable image, NSData * _Nullable imageData) {
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            
            UIImage *thumbImage;
            if (image) {
                thumbImage = image;
                [wSelf.delegate yb_videoData:self readyForThumbImage:thumbImage];
            } else if (imageData) {
                thumbImage = [UIImage imageWithData:imageData];
                [wSelf.delegate yb_videoData:self readyForThumbImage:thumbImage];
                
            }else{
                [wSelf loadThumbImageUrl];
            }
            // If the target image is ready, ignore the thumb image.
        }];
    } else if (self.projectiveView && [self.projectiveView isKindOfClass:UIImageView.self] && ((UIImageView *)self.projectiveView).image) {
        NSLog(@"self.projectiveView && [self.projectiveView isKindOfClass:UIImageView.self] && ((UIImageView *)self.projectiveView).image");

        self.thumbImage = ((UIImageView *)self.projectiveView).image;
        [self.delegate yb_videoData:self readyForThumbImage:self.thumbImage];
    } else {
        NSLog(@"self.projectiveView && [self.projectiveView isKindOfClass:UIImageView.self] && ((UIImageView *)self.projectiveView).image");

        [self loadThumbImage_firstFrame];
        if (self.thumbURL != nil ){
            __weak typeof(self) wSelf = self;
            [YBIBWebImageManager queryCacheOperationForKey:self.thumbURL completed:^(UIImage * _Nullable image, NSData * _Nullable imageData) {
                __strong typeof(wSelf) self = wSelf;
                if (!self) return;
                
                UIImage *thumbImage;
                if (image) {
                    thumbImage = image;
                    [wSelf.delegate yb_videoData:self readyForThumbImage:thumbImage];
                } else if (imageData) {
                    thumbImage = [UIImage imageWithData:imageData];
                    [wSelf.delegate yb_videoData:self readyForThumbImage:thumbImage];

                }else{
                    [wSelf loadThumbImageUrl];
                }
                // If the target image is ready, ignore the thumb image.
            }];
          
        }
    }
}
-(void)loadThumbImageUrl{
    __weak typeof(self) wSelf = self;
    SDWebImageDownloaderOptions options = SDWebImageDownloaderLowPriority | SDWebImageDownloaderAvoidDecodeImage;
    SDWebImageDownloadToken *token = [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:self.thumbURL options:options progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//        if (progress) progress(receivedSize, expectedSize);
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        UIImage *thumbImage;
        if (image) {
            thumbImage = image;
        } else if (data) {
            thumbImage = [UIImage imageWithData:data];
        }
        [wSelf.delegate yb_videoData:self readyForThumbImage:thumbImage];
        if (error) {
        } else {
            [CustomUtil movePicPathToConversationWithPicUrl:wSelf.thumbURL filePath:nil];
        }
    }];
}
- (void)loadThumbImage_firstFrame {
    if (!self.videoAVAsset) return;
    if (self.isLoadingFirstFrame) {
        self.loadingFirstFrame = YES;
        return;
    }
    
    self.loadingFirstFrame = YES;
    CGSize containerSize = self.yb_containerSize(self.yb_currentOrientation());
    CGSize maximumSize = containerSize;
    
    __weak typeof(self) wSelf = self;
    YBIB_DISPATCH_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.videoAVAsset];
        generator.appliesPreferredTrackTransform = YES;
        generator.maximumSize = maximumSize;
        NSError *error = nil;
        CGImageRef cgImage = [generator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:NULL error:&error];
        CGImageRef decodedImage = YYCGImageCreateDecodedCopy(cgImage, YES);
        UIImage *resultImage = [UIImage imageWithCGImage:decodedImage];
        if (cgImage) CGImageRelease(cgImage);
        if (decodedImage) CGImageRelease(decodedImage);
        
        YBIB_DISPATCH_ASYNC_MAIN(^{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            self.loadingFirstFrame = NO;
            if (!error && resultImage) {
                self.thumbImage = resultImage;
                [self.delegate yb_videoData:self readyForThumbImage:self.thumbImage];
            }
        })
    })
}

#pragma mark - <YBIBDataProtocol>

@synthesize yb_currentOrientation = _yb_currentOrientation;
@synthesize yb_containerView = _yb_containerView;
@synthesize yb_containerSize = _yb_containerSize;
@synthesize yb_isTransitioning = _yb_isTransitioning;
@synthesize yb_auxiliaryViewHandler = _yb_auxiliaryViewHandler;

- (nonnull Class)yb_classOfCell {
    return YBIBVideoCell.self;
}

- (UIView *)yb_projectiveView {
    return self.projectiveView;
}

- (CGRect)yb_imageViewFrameWithContainerSize:(CGSize)containerSize imageSize:(CGSize)imageSize orientation:(UIDeviceOrientation)orientation {
    if (containerSize.width <= 0 || containerSize.height <= 0 || imageSize.width <= 0 || imageSize.height <= 0) return CGRectZero;
    CGFloat x = 0, y = 0, width = 0, height = 0;
    if (imageSize.width / imageSize.height >= containerSize.width / containerSize.height) {
        width = containerSize.width;
        height = containerSize.width * (imageSize.height / imageSize.width);
        x = 0;
        y = (containerSize.height - height) / 2.0;
    } else {
        height = containerSize.height;
        width = containerSize.height * (imageSize.width / imageSize.height);
        x = (containerSize.width - width) / 2.0;
        y = 0;
    }
    return CGRectMake(x, y, width, height);
}

- (void)yb_preload {
    if (!self.delegate) {
        [self loadData];
    }
}

- (BOOL)yb_allowSaveToPhotoAlbum {
    return self.allowSaveToPhotoAlbum;
}




//- (void)yb_saveToPhotoAlbum {
//    void(^unableToSave)(void) = ^(){
//        [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].unableToSave];
//    };
//    if (self.videoURL.absoluteString.length > 0) {
//        [YBIBPhotoAlbumManager getPhotoAlbumAuthorizationSuccess:^{
//            [CustomUtil loadMP4DataWithUrl:self.videoURL.absoluteString progressBlock:^(CGFloat progress) {
//
//            } successBlock:^(NSURL *playFileURL) {
//                if ([playFileURL.scheme isEqualToString:@"file"]) {
//                    NSString *path = playFileURL.path;
//                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
//                        UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(UISaveVideoAtPathToSavedPhotosAlbum_videoPath:didFinishSavingWithError:contextInfo:), nil);
//                    } else {
//                        unableToSave();
//                    }
//                }else{
//                    unableToSave();
//
//                }
//            } faliedBlock:^(NSString *errorString) {
//                unableToSave();
//
//            }];
//        } failed:^{
//                [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].getPhotoAlbumAuthorizationFailed];
//        }];
//    }else{
//        if (self.videoAVAsset && [self.videoAVAsset isKindOfClass:AVURLAsset.class]) {
//               AVURLAsset *asset = (AVURLAsset *)self.videoAVAsset;
//               NSURL *URL = asset.URL;
//               if ([URL.scheme isEqualToString:@"file"]) {
//                   NSString *path = URL.path;
//                   if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
//                       UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(UISaveVideoAtPathToSavedPhotosAlbum_videoPath:didFinishSavingWithError:contextInfo:), nil);
//                   } else {
//                       unableToSave();
//                   }
//               } else if ([URL.scheme containsString:@"http"]) {
//                   [self downloadWithURL:URL];
//               } else {
//                   unableToSave();
//               }
//           } else {
//               unableToSave();
//           }
//    }
//
//}

- (void)yb_saveToPhotoAlbum {
    void(^unableToSave)(void) = ^(){
        [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].unableToSave];
    };
    if (self.videoURL.absoluteString.length > 0) {
        [YBIBPhotoAlbumManager getPhotoAlbumAuthorizationSuccess:^{
            [CustomUtil loadMP4DataWithUrl:self.videoURL.absoluteString progressBlock:^(CGFloat progress) {
                
            } successBlock:^(NSURL *playFileURL) {
                if ([playFileURL.scheme isEqualToString:@"file"]) {
                    NSString *path = playFileURL.path;
                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
                        UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(UISaveVideoAtPathToSavedPhotosAlbum_videoPath:didFinishSavingWithError:contextInfo:), nil);
                    } else {
                        unableToSave();
                    }
                }else{
                    unableToSave();
                    
                }
            } faliedBlock:^(NSString *errorString) {
                unableToSave();
                
            }];
        } failed:^{
                [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].getPhotoAlbumAuthorizationFailed];
        }];
    }else{
        if (self.videoAVAsset && [self.videoAVAsset isKindOfClass:AVURLAsset.class]) {
               AVURLAsset *asset = (AVURLAsset *)self.videoAVAsset;
               NSURL *URL = asset.URL;
               if ([URL.scheme isEqualToString:@"file"]) {
                   NSString *path = URL.path;
                   if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
                       UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(UISaveVideoAtPathToSavedPhotosAlbum_videoPath:didFinishSavingWithError:contextInfo:), nil);
                   } else {
                       unableToSave();
                   }
               } else if ([URL.scheme containsString:@"http"]) {
                   [self downloadWithURL:URL];
               } else {
                   unableToSave();
               }
           } else {
               unableToSave();
           }
    }
   
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
    void(^unableToShare)(void) = ^(){
        [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].unableToSave];
    };
    [CustomUtil loadMP4DataWithUrl:self.videoURL.absoluteString progressBlock:^(CGFloat progress) {
        
    } successBlock:^(NSURL *playFileURL) {
        if ([playFileURL.scheme isEqualToString:@"file"]) {
            NSString *path = playFileURL.path;
//            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
////                UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(UISaveVideoAtPathToSavedPhotosAlbum_videoPath:didFinishSavingWithError:contextInfo:), nil);
//            } else {
//                unableToShare();
//            }
        }else{
            unableToShare();
            
        }
    } faliedBlock:^(NSString *errorString) {
        unableToShare();
    }];
    if (self.videoAVAsset && [self.videoAVAsset isKindOfClass:AVURLAsset.class]) {
        AVURLAsset *asset = (AVURLAsset *)self.videoAVAsset;
        NSURL *URL = asset.URL;
        if ([URL.scheme isEqualToString:@"file"]) {
            NSString *path = URL.path;
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
                UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(UISaveVideoAtPathToSavedPhotosAlbum_videoPath:didFinishSavingWithError:contextInfo:), nil);
            } else {
                unableToShare();
            }
        } else if ([URL.scheme containsString:@"http"]) {
            [self downloadWithURL:URL];
        } else {
            unableToShare();
        }
    } else {
        unableToShare();
    }
}

- (void)imageShare:(NSArray *)items {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    if (@available(iOS 11.0, *)) {
        //UIActivityTypeMarkupAsPDF是在iOS 11.0 之后才有的
        activityVC.excludedActivityTypes = @[UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypeOpenInIBooks, UIActivityTypeMarkupAsPDF];
    }else if (@available(iOS 9.0, *)){
        //UIActivityTypeOpenInIBooks是在iOS 9.0 之后才有的
        activityVC.excludedActivityTypes = @[UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypeOpenInIBooks];
    }else{
        activityVC.excludedActivityTypes = @[UIActivityTypeMessage, UIActivityTypeMail];
    }
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
    };
    //这儿一定要做iPhone与iPad的判断，因为这儿只有iPhone可以present，iPad需pop，所以这儿actVC.popoverPresentationController.sourceView = self.view;在iPad下必须有，不然iPad会crash，self.view你可以换成任何view，你可以理解为弹出的窗需要找个依托。
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        activityVC.popoverPresentationController.sourceView = vc.view;
        [vc presentViewController:activityVC animated:YES completion:nil];
    }else{
        [vc presentViewController:activityVC animated:YES completion:nil];
    }
}

#pragma mark - private

- (void)UISaveVideoAtPathToSavedPhotosAlbum_videoPath:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].saveToPhotoAlbumFailed];
    } else {
        [self.yb_auxiliaryViewHandler() yb_showCorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].saveToPhotoAlbumSuccess];
    }
}

- (void)downloadWithURL:(NSURL *)URL {
    if (self.isDownloading) {
        self.downloading = YES;
        return;
    }

    self.downloading = YES;
    __weak typeof(self) wSelf = self;
    [CustomUtil loadMP4DataWithUrl:self.videoURL.absoluteString progressBlock:^(CGFloat progress) {
        NSLog(@"kankanddsss");
        if (progress < 0) progress = 0;
        if (progress > 1) progress = 1;
        YBIB_DISPATCH_ASYNC_MAIN(^{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            [self.delegate yb_videoData:self downloadingWithProgress:progress];
        })
    } successBlock:^(NSURL *playFileURL) {
        __weak typeof(self) weakSelf = self;
        weakSelf.downloading = NO;
        [YBIBPhotoAlbumManager getPhotoAlbumAuthorizationSuccess:^{
            [TXPhotoLibraryManager saveVideoWithVideoUrl:playFileURL andAssetCollectionName:nil withCompletion:^(NSURL * _Nonnull vedioUrl, NSError * _Nonnull error) {

            }];
         } failed:^{
//             [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].getPhotoAlbumAuthorizationFailed];
         }];

    } faliedBlock:^(NSString *errorMessage) {
        __weak typeof(self) weakSelf = self;
        [weakSelf.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].downloadFailed];
        weakSelf.downloading = NO;
    }];
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCOD_loginName"];
//    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCOD_password"];
//    NSString *authStr = [NSString stringWithFormat:@"%@:%@", userName, password];
//    NSData *utf8Data = [authStr dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [utf8Data base64EncodedStringWithOptions:(0)]];
////    [[SDWebImageDownloader sharedDownloader] setValue:authValue forHTTPHeaderField:@"Authorization"];
////    [[SDWebImageDownloader sharedDownloader] setValue:@"*/*" forHTTPHeaderField:@"Accept"];
//    config.HTTPAdditionalHeaders = @{@"Authorization":@"authValue",@"Accept":@"*/*"};
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//    _downloadTask = [session downloadTaskWithURL:URL];
//    [_downloadTask resume];
}

//- (void)downloadWithURL:(NSURL *)URL {
//    if (self.isDownloading) {
//        self.downloading = YES;
//        return;
//    }
//    
//    self.downloading = YES;
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    config.HTTPAdditionalHeaders = [UserManager getVideoDownLoaderHeader];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//    _downloadTask = [session downloadTaskWithURL:URL];
//    [_downloadTask resume];
//}

#pragma mark - <NSURLSessionDelegate>

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    CGFloat progress = totalBytesWritten / (double)totalBytesExpectedToWrite;
    if (progress < 0) progress = 0;
    if (progress > 1) progress = 1;
    [self.delegate yb_videoData:self downloadingWithProgress:progress];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    if (error) {
        [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].downloadFailed];
    }
    self.downloading = NO;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *file = [cache stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:file] error:nil];
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(file)) {
        UISaveVideoAtPathToSavedPhotosAlbum(file, self, @selector(UISaveVideoAtPathToSavedPhotosAlbum_videoPath:didFinishSavingWithError:contextInfo:), nil);
    } else {
        [self.yb_auxiliaryViewHandler() yb_showIncorrectToastWithContainer:self.yb_containerView text:[YBIBCopywriter sharedCopywriter].saveToPhotoAlbumFailed];
    }
    self.downloading = NO;
}

#pragma mark - getters & setters

- (void)setVideoURL:(NSURL *)videoURL{
    _videoURL = [videoURL isKindOfClass:NSString.class] ? [NSURL URLWithString:(NSString *)videoURL] : videoURL;
    self.videoAVAsset = [AVURLAsset URLAssetWithURL:_videoURL options:nil];
}

- (void)setDownloading:(BOOL)downloading {
    _downloading = downloading;
    if (downloading) {
        [self.delegate yb_videoData:self downloadingWithProgress:0];
    } else {
        [self.delegate yb_finishDownloadingForData:self];
    }
}

- (void)setLoadingAVAssetFromPHAsset:(BOOL)loadingAVAssetFromPHAsset {
    _loadingAVAssetFromPHAsset = loadingAVAssetFromPHAsset;
    if (loadingAVAssetFromPHAsset) {
        [self.delegate yb_startLoadingAVAssetFromPHAssetForData:self];
    } else {
        [self.delegate yb_finishLoadingAVAssetFromPHAssetForData:self];
    }
}

- (void)setLoadingFirstFrame:(BOOL)loadingFirstFrame {
    _loadingFirstFrame = loadingFirstFrame;
    if (loadingFirstFrame) {
        [self.delegate yb_startLoadingFirstFrameForData:self];
    } else {
        [self.delegate yb_finishLoadingFirstFrameForData:self];
    }
}
 
@synthesize delegate = _delegate;
- (void)setDelegate:(id<YBIBVideoDataDelegate>)delegate {
    _delegate = delegate;
    if (delegate) {
        [self loadData];
    }
}
- (id<YBIBVideoDataDelegate>)delegate {
    // Stop sending data to the '_delegate' if it is transiting.
    return self.yb_isTransitioning() ? nil : _delegate;
}

@end
