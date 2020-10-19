//
//  GloableDefine.h
//  IOSWebRTC
//
//  Created by Xinhoo on 2019/8/6.
//  Copyright © 2019 XRuby. All rights reserved.
//

#ifndef GloableDefine_h
#define GloableDefine_h

#define kScreenWidth          [UIScreen mainScreen].bounds.size.width
#define kScreenHeight         [UIScreen mainScreen].bounds.size.height

#define isIphoneX             ([UIApplication sharedApplication].statusBarFrame.size.height >= 44)
#define kSafeTopHeight        (isIphoneX ? 44 : 20)
#define kSafeBottomHeight     (isIphoneX ? 34 : 0)
#define kNavigationBarHeight  44
#define kTabBarHeight         50

#pragma mark - Block weakify self
#if __has_include(<ReactiveCocoa/ReactiveCocoa.h>) || \
__has_include(<libextobjc/EXTScope.h>)
#ifndef codweakify
#define codweakify(...) @weakify(__VA_ARGS__)
#endif  /*codweakify*/
#ifndef codstrongify
#define codstrongify(...) @strongify(__VA_ARGS__)
#endif  /*codstrongify*/
#else
#ifndef codweakify
#if DEBUG
#define codweakify(object) @autoreleasepool{} __weak __typeof__(object) weak##_##object = object
#else
#define codweakify(object) @try{} @finally{} {} __weak __typeof__(object) weak##_##object = object
#endif  /*DEBUG*/
#endif  /*codweakify*/
#ifndef codstrongify
#if DEBUG
#define codstrongify(object) @autoreleasepool{} __typeof__(object) object = weak##_##object
#else   /*DEBUG*/
#define codstrongify(object) @try{} @finally{} __typeof__(object) object = weak##_##object
#endif  /*codstrongify*/
#endif
#endif  /*__has_include(<ReactiveCocoa/ReactiveCocoa.h>)*/



#define NOTIFICE_SOCKET_CONNECT_OPEN           @"NOTIFICE_SOCKET_CONNECT_OPEN"
#define NOTIFICE_SOCKET_CONNECT_CLOSE          @"NOTIFICE_SOCKET_CONNECT_CLOSE"
#define NOTIFICE_SOCKET_RECIVE_MESSAGE         @"NOTIFICE_SOCKET_RECIVE_MESSAGE"

#define NOTIFICE_RECIVE_MESSAGE_BY_DATACHANEL  @"NOTIFICE_RECIVE_MESSAGE_BY_DATACHANEL"




#endif /* GloableDefine_h */
