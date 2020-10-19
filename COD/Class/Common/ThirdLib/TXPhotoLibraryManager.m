//
//  TXPhotoLibraryManager.m
//  MGJRouter
//
//  Created by xtz_pioneer on 2019/3/22.
//

#import "TXPhotoLibraryManager.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

/**
 *  DEBUG 打印日志
 */
#if DEBUG
#define TXPLILog(s, ... ) NSLog( @"<FileName:%@ InThe:%d Line> Log:%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define TXPLILog(s, ... )
#endif

@implementation TXPhotoLibraryManager

/**
 *  请求照片权限，注意，强烈要求用户获得照片权限，否则视频写入照片会有崩溃
 */
+ (void)requestALAssetsLibraryAuthorizationWithCompletion:(RequestAssetsLibraryAuthCompletion)requestAssetsLibraryAuthCompletion{
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus != PHAuthorizationStatusAuthorized) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status != PHAuthorizationStatusAuthorized){
                TXPLILog(@"用户拒绝访问相册！");
                if (requestAssetsLibraryAuthCompletion){
                    requestAssetsLibraryAuthCompletion(NO);
                }
            }
            else{
                TXPLILog(@"用户允许访问相册！");
                if (requestAssetsLibraryAuthCompletion){
                    requestAssetsLibraryAuthCompletion(YES);
                }
            }
        }];
    }
    else{
        // nothing
    }
}

/**
 *  保存照片
 *
 *  @param image                UImage
 *  @param assetCollectionName  相册名字，不填默认为app名字+相册
 */
+ (void)savePhotoWithImage:(UIImage *)image andAssetCollectionName:(NSString *)assetCollectionName withCompletion:(SavePhotoCompletionBlock)savePhotoCompletionBlock{
    if (assetCollectionName == nil){
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        assetCollectionName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        if (assetCollectionName == nil){
            assetCollectionName = @"视频相册";
        }
    }
    
    __block NSString *blockAssetCollectionName = assetCollectionName;
    __block UIImage *blockImage = image;
    __block NSString *assetId = nil;
    
    PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];
    
    // 1. 存储图片到"相机胶卷"
    [library performChanges:^{ // 这个block里保存一些"修改"性质的代码
        // 新建一个PHAssetCreationRequest对象, 保存图片到"相机胶卷"
        // 返回PHAsset(图片)的字符串标识
        assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:blockImage].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            TXPLILog(@"error1%@", error);
            return;
        }
        
        TXPLILog(@"成功保存图片到相机胶卷中");
        
        // 2. 获得相册对象
        // 获取曾经创建过的自定义视频相册名字
        PHAssetCollection *createdAssetCollection = nil;
        PHFetchResult <PHAssetCollection*> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *assetCollection in assetCollections){
            if ([assetCollection.localizedTitle isEqualToString:blockAssetCollectionName])
            {
                createdAssetCollection = assetCollection;
                break;
            }
        }
        
        //如果这个自定义框架没有创建过
        if (createdAssetCollection == nil){
            //创建新的[自定义的 Album](相簿\相册)
            [library performChangesAndWait:^{
                
                assetId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:blockAssetCollectionName].placeholderForCreatedAssetCollection.localIdentifier;
                
            } error:&error];
            
            TXPLILog(@"error2: %@", error);
            
            //抓取刚创建完的视频相册对象
            createdAssetCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
            
        }
        
        // 3. 将“相机胶卷”中的图片添加到新的相册
        //        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdAssetCollection];
        //
        //            // 根据唯一标示获得相片对象
        //            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
        //            // 添加图片到相册中
        //            [request addAssets:@[asset]];
        //        } completionHandler:^(BOOL success, NSError * _Nullable error) {
        //            if (error)
        //            {
        //                TXPLILog(@"添加图片到相册中失败");
        //                return;
        //            }
        //
        //            TXPLILog(@"成功添加图片到相册中");
        //        }];
        
        // 将【Camera Roll】(相机胶卷)的视频 添加到【自定义Album】(相簿\相册)中
        [library performChangesAndWait:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdAssetCollection];
            
            [request addAssets:[PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil]];
            
        } error:&error];
        TXPLILog(@"error3: %@", error);
        // 提示信息
        if (savePhotoCompletionBlock)
        {
            if (error){
                TXPLILog(@"保存照片失败!");
                
                savePhotoCompletionBlock(nil, error);
            }
            else{
                TXPLILog(@"保存照片成功!");
                
                savePhotoCompletionBlock(blockImage, nil);
            }
        }
        
    }];
}

/**
 *  保存视频
 *
 *  @param videoUrl             视频地址
 *  @param assetCollectionName  相册名字，不填默认为app名字+视频
 */
+ (void)saveVideoWithVideoUrl:(NSURL *)videoUrl andAssetCollectionName:(NSString *)assetCollectionName withCompletion:(SaveVideoCompletionBlock)saveVideoCompletionBlock{
    if (assetCollectionName == nil){
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        assetCollectionName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        
        if (assetCollectionName == nil){
            assetCollectionName = @"视频相册";
        }
    }
    
    __block NSString *blockAssetCollectionName = assetCollectionName;
    __block NSURL *blockVideoUrl = videoUrl;
    PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;
        __block NSString *assetId = nil;
        __block NSString *assetCollectionId = nil;
        
        // 保存视频到【Camera Roll】(相机胶卷)
        [library performChangesAndWait:^{
            assetId = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:blockVideoUrl].placeholderForCreatedAsset.localIdentifier;
            
        } error:&error];
        
        TXPLILog(@"error1: %@", error);
        
        // 获取曾经创建过的自定义视频相册名字
        PHAssetCollection *createdAssetCollection = nil;
        PHFetchResult <PHAssetCollection*> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *assetCollection in assetCollections){
            if ([assetCollection.localizedTitle isEqualToString:blockAssetCollectionName]){
                createdAssetCollection = assetCollection;
                break;
            }
        }
        
        //如果这个自定义框架没有创建过
        if (createdAssetCollection == nil){
            //创建新的[自定义的 Album](相簿\相册)
            [library performChangesAndWait:^{
                
                assetCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:blockAssetCollectionName].placeholderForCreatedAssetCollection.localIdentifier;
                
            } error:&error];
            
            TXPLILog(@"error2: %@", error);
            
            //抓取刚创建完的视频相册对象
            createdAssetCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[assetCollectionId] options:nil].firstObject;
            
        }
        
        // 将【Camera Roll】(相机胶卷)的视频 添加到【自定义Album】(相簿\相册)中
        [library performChangesAndWait:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdAssetCollection];
            
            [request addAssets:[PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil]];
            
        } error:&error];
        TXPLILog(@"error3: %@", error);
        
        // 提示信息
        if (saveVideoCompletionBlock){
            if (error){
                TXPLILog(@"保存视频失败!");
                
                saveVideoCompletionBlock(nil, error);
            }
            else{
                TXPLILog(@"保存视频成功!");
                saveVideoCompletionBlock(blockVideoUrl, nil);
            }
        }
        
    });
}

@end
