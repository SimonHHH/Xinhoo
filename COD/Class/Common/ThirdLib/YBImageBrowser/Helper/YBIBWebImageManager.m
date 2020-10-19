//
//  YBIBWebImageManager.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2018/8/29.
//  Copyright © 2018年 波儿菜. All rights reserved.
//

#import "YBIBWebImageManager.h"
#import "YBIBUtilities.h"

#import "UIImageView+WebCache.h"
#import "COD-Swift.h"
@implementation YBIBWebImageManager

#pragma mark public

+ (SDWebImageDownloadToken *)downloadImageWithURL:(NSURL *)url requestModifier:(nullable YBIBWebImageRequestModifierBlock)requestModifier progress:(nonnull YBIBWebImageProgressBlock)progress success:(nonnull YBIBWebImageSuccessBlock)success failed:(nonnull YBIBWebImageFailedBlock)failed {
    if (!url) return nil;

    SDWebImageDownloaderOptions options = SDWebImageDownloaderLowPriority | SDWebImageDownloaderAvoidDecodeImage;

    SDWebImageDownloadToken *token = [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:options progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        if (progress) progress(receivedSize, expectedSize,targetURL);
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if (error) {
            if (failed) failed(error, finished);
        } else {
            [CustomUtil movePicPathToConversationWithPicUrl:url filePath:nil];
            if (success) success(data, finished);
        }
    }];
    
    return token;
}

+ (void)cancelTaskWithDownloadToken:(id)token {
    if (token && [token isKindOfClass:SDWebImageDownloadToken.class]) {
        [((SDWebImageDownloadToken *)token) cancel];
    }
}

+ (void)storeToDiskWithImageData:(NSData *)data forKey:(NSURL *)key {
    if (!key) return;
    NSString *cacheKey = [SDWebImageManager.sharedManager cacheKeyForURL:key];
    if (!cacheKey) return;
    
    YBIB_DISPATCH_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[SDImageCache sharedImageCache] storeImageDataToDisk:data forKey:cacheKey];
    })
}

+ (void)queryCacheOperationForKey:(NSURL *)key completed:(YBIBWebImageCacheQueryCompletedBlock)completed {
#define QUERY_CACHE_FAILED if (completed) {completed(nil, nil); return;}
    if (!key) QUERY_CACHE_FAILED
    NSString *cacheKey = [SDWebImageManager.sharedManager cacheKeyForURL:key];
    if (!cacheKey) QUERY_CACHE_FAILED
#undef QUERY_CACHE_FAILED
    
    // 'NSData' of image must be read to ensure decoding correctly.
    SDImageCacheOptions options = SDImageCacheQueryMemoryData | SDImageCacheAvoidDecodeImage;
    [[SDImageCache sharedImageCache] queryCacheOperationForKey:cacheKey options:options done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        if (completed) completed(image, data);
    }];
}

@end