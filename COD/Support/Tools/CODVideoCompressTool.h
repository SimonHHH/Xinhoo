//
//  CODVideoCompressTool.h
//  COD
//
//  Created by XinHoo on 2019/7/11.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CODVideoCompressTool : NSObject

+ (NSDictionary *)videoCompressSettings:(CGSize)videoSize;

+ (NSDictionary *)audioCompressSettings;

+ (void)compressVideoV2:(NSURL *)videoUrl withOutputUrl:(NSURL *)outputUrl complete:(typeof(void(^)(bool)))ocblock;

@end

NS_ASSUME_NONNULL_END
