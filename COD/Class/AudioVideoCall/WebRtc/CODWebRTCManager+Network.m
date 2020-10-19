//
//  CODWebRTCManager+Network.m
//  COD
//
//  Created by Xinhoo on 2019/9/4.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#import "CODWebRTCManager+Network.h"
#import "COD-Swift.h"

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

@implementation CODWebRTCManager (Network)

- (int)getSignalStrength {
    //if ([UIDevice currentDevice].systemVersion.floatValue >= 13.0) return 4;
    
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    //NSLog(@"//// statusBar Height:%d ////", (int)statusBarHeight);
    if (statusBarHeight == 0) return signalStrength;
    
    if (@available(iOS 13.0, *)) {
        id statusBar;
        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager;
        if ([statusBarManager respondsToSelector:@selector(createLocalStatusBar)]) {
            UIView *localStatusBar = [statusBarManager performSelector:@selector(createLocalStatusBar)];
            if ([localStatusBar respondsToSelector:@selector(statusBar)]) {
                statusBar = [localStatusBar performSelector:@selector(statusBar)];
            }
        }
        
        if (statusBar) {
            id currentData = [[statusBar valueForKeyPath:@"_statusBar"] valueForKeyPath:@"currentData"];
            id wifiEntry = [currentData valueForKeyPath:@"wifiEntry"];
            id cellularEntry = [currentData valueForKeyPath:@"cellularEntry"];
            if (wifiEntry && [[wifiEntry valueForKeyPath:@"isEnabled"] boolValue]) {
                signalStrength = [[wifiEntry valueForKeyPath:@"displayValue"] intValue];
                signalStrength = signalStrength == 3 ? 4 : signalStrength;
            } else if (cellularEntry && [[cellularEntry valueForKeyPath:@"isEnabled"] boolValue]) {
                signalStrength = [[cellularEntry valueForKey:@"displayValue"] intValue];
            }
        }
        return signalStrength;
    } else {
        if (statusBarHeight >= 44) {
            id statusBar = [[UIApplication sharedApplication] valueForKeyPath:@"statusBar"];
            
            id statusBarView = [statusBar valueForKeyPath:@"statusBar"];
            UIView *foregroundView = [statusBarView valueForKeyPath:@"foregroundView"];
            
            NSArray *subviews = [[foregroundView subviews][2] subviews];
            
            BOOL isWifi = false;
            for (id subview in subviews) {
                if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                    isWifi = YES;
                    break;
                }
            }
            
            for (id subview in subviews) {
                if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                    signalStrength = [[subview valueForKey:@"numberOfActiveBars"] intValue];
                    signalStrength = signalStrength == 3 ? 4 : signalStrength;
                    break;
                } else if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarPersistentAnimationView")] && !isWifi) {
                    signalStrength = [[subview valueForKey:@"numberOfActiveBars"] intValue];
                    break;
                }
            }
            return signalStrength;
        } else {
            UIApplication *app = [UIApplication sharedApplication];
            NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
            NSString *dataNetworkItemView = nil;
            
            for (id subview in subviews) {
                if ([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]] && [[CODWebRTCManager getNetworkType] isEqualToString:@"WIFI"] && ![[CODWebRTCManager getNetworkType] isEqualToString:@"NONE"]) {
                    dataNetworkItemView = subview;
                    signalStrength = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
                    break;
                }
                if ([subview isKindOfClass:[NSClassFromString(@"UIStatusBarSignalStrengthItemView") class]] && ![[CODWebRTCManager getNetworkType] isEqualToString:@"WIFI"] && ![[CODWebRTCManager getNetworkType] isEqualToString:@"NONE"]) {
                    dataNetworkItemView = subview;
                    signalStrength = [[dataNetworkItemView valueForKey:@"_signalStrengthRaw"] intValue];
                    break;
                }
            }
            return signalStrength;
        }
    }
}

//检查当前是否连网
+ (BOOL)whetherConnectedNetwork {
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    struct sockaddr_storage zeroAddress;//IP地址
    
    bzero(&zeroAddress, sizeof(zeroAddress));//将地址转换为0.0.0.0
    zeroAddress.ss_len = sizeof(zeroAddress);//地址长度
    zeroAddress.ss_family = AF_INET;//地址类型为UDP, TCP, etc.
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    //获得连接的标志
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    //如果不能获取连接标志，则不能连接网络，直接返回
    if (!didRetrieveFlags) return NO;
    
    //根据获得的连接标志进行判断
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable&&!needsConnection) ? YES : NO;
}

//获取网络类型
+ (NSString *)getNetworkType {
    if (![self whetherConnectedNetwork]) return @"NONE";
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    NSString *type = @"NONE";
    for (id subview in subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            int networkType = [[subview valueForKeyPath:@"dataNetworkType"] intValue];
            switch (networkType) {
                case 0:
                    type = @"NONE";
                    break;
                case 1:
                    type = @"2G";
                    break;
                case 2:
                    type = @"3G";
                    break;
                case 3:
                    type = @"4G";
                    break;
                case 5:
                    type = @"WIFI";
                    break;
            }
        }
    }
    return type;
}

@end
