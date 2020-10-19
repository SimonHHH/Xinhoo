//
//  ConvertAudioFile.h
//  Expert
//
//  Created by xuxiwen on 2017/3/21.
//  Copyright © 2017年 xuxiwen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CODThread;
@interface ConvertAudioFile : NSObject

/**
 get instance obj
 
 @return ConvertAudioFile instance
 */
+ (instancetype)sharedInstance;

/**
 ConvertMp3
 
 @param cafFilePath caf FilePath
 @param mp3FilePath mp3 FilePath
 @param sampleRate sampleRate (same record sampleRate set)
 @param callback callback result
 */
- (void)conventToMp3WithCafFilePath:(NSString *)cafFilePath
                        mp3FilePath:(NSString *)mp3FilePath
                         sampleRate:(int)sampleRate
                           callback:(void(^)(BOOL result))callback;

/**
 send end record signal
 */
- (void)sendEndRecord;



// Use this FUNC convent to mp3 after record
- (void)synchToMp3WithCafFilePath:(NSString *)cafFilePath
                      mp3FilePath:(NSString *)mp3FilePath
                       sampleRate:(int)sampleRate
                         callback:(void(^)(BOOL result))callback;

@end

@interface CODThread : NSObject

+ (CODThread *) currentThread;

/**
 发送等待信号
 
 @return 是否等待
 */
-(BOOL)sendWaitSignal;
/**
 等待信号
 
 @return 是否去等待
 */
-(BOOL)waitSignal;
/**
 休眠（seconds == 0 即 wait函数）
 
 @param seconds 秒
 */
-(void)sleep:(NSInteger)seconds;
/**
 线程等待
 */
-(void)wait;
/**
 线程继续
 */
-(void)signal;

/**
 控制的全部线程继续
 */
-(void)broadcast;
@end
