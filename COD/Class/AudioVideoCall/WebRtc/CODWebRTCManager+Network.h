//
//  CODWebRTCManager+Network.h
//  COD
//
//  Created by Xinhoo on 2019/9/4.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CODWebRTCManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface CODWebRTCManager (Network)

- (int)getSignalStrength;
+ (BOOL)whetherConnectedNetwork;

@end

NS_ASSUME_NONNULL_END
