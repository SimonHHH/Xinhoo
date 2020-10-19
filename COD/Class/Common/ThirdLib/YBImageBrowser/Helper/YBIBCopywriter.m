//
//  YBIBCopywriter.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2018/9/13.
//  Copyright © 2018年 波儿菜. All rights reserved.
//

#import "YBIBCopywriter.h"
#import "COD-Swift.h"
@implementation YBIBCopywriter

#pragma mark - life cycle

+ (instancetype)sharedCopywriter {
    static YBIBCopywriter *copywriter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        copywriter = [YBIBCopywriter new];
    });
    return copywriter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _type = YBIBCopywriterTypeSimplifiedChinese;
        NSArray *appleLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        if (appleLanguages && appleLanguages.count > 0) {
            NSString *languages = appleLanguages[0];
            if (![languages hasPrefix:@"zh-Hans"]) {
                _type = YBIBCopywriterTypeEnglish;
            }
        }
        
        [self initCopy];
    }
    return self;
}

#pragma mark - private

- (void)initCopy {
    BOOL en = self.type == YBIBCopywriterTypeEnglish;
    
    self.videoIsInvalid = en ? @"Video is invalid" : [CustomUtil formatterStringWithAppNameWithStr:@"视频无效"];
    self.videoError = en ? @"Video error" : [CustomUtil formatterStringWithAppNameWithStr:@"视频错误"];
    self.unableToSave = en ? @"Unable to save" : [CustomUtil formatterStringWithAppNameWithStr:@"无法保存"];
    self.imageIsInvalid = en ? @"Image is invalid" : [CustomUtil formatterStringWithAppNameWithStr:@"图片无效"];
    self.downloadFailed = en ? @"Image acquisition failed" : [CustomUtil formatterStringWithAppNameWithStr:@"图片获取失败"];
    self.getPhotoAlbumAuthorizationFailed = en ? @"Failed to get album authorization" : [CustomUtil formatterStringWithAppNameWithStr:@"请到设置 -> %@ -> 相册 -> 打开访问权限"];
    self.saveToPhotoAlbumSuccess = en ? @"Save successful" : [CustomUtil formatterStringWithAppNameWithStr:@"已保存到系统相册"];
    self.saveToPhotoAlbumFailed = en ? @"Save failed" : [CustomUtil formatterStringWithAppNameWithStr:@"保存失败"];
    self.saveToPhotoAlbum = en ? @"Save" : [CustomUtil formatterStringWithAppNameWithStr:@"保存到相册"];
    self.cancel = en ? @"Cancel" : [CustomUtil formatterStringWithAppNameWithStr:@"取消"];
    self.savePhoto = en ? @"Save picture" : [CustomUtil formatterStringWithAppNameWithStr:@"保存图片"];
    self.saveVideo = en ? @"Save video" : [CustomUtil formatterStringWithAppNameWithStr:@"保存视频"];

}

#pragma mark - public

- (void)setType:(YBIBCopywriterType)type {
    _type = type;
    [self initCopy];
}

@end
