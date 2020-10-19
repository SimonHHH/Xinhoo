//
//  ConvertAudioFile.m
//  TestApp
//
//  Created by syslinc_dabo on 11/14/18.
//  Copyright © 2018 syslinc_dabo. All rights reserved.
//

#import "ConvertAudioFile.h"
#import <lame/lame.h>

@interface ConvertAudioFile ()
@property (nonatomic, assign) BOOL stopRecord;
@property (nonatomic, strong) CODThread * thread; //控制线程中录音转MP3 暂停和继续

@end

@implementation ConvertAudioFile
-(CODThread *)thread{
    if (!_thread) {
        _thread = [CODThread currentThread];
    }
    return _thread;
}
/**
 get instance obj
 
 @return ConvertAudioFile instance
 */
+ (instancetype)sharedInstance {
    static ConvertAudioFile *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ConvertAudioFile alloc] init];
    });
    return instance;
}
///注意swift是以安全作为重要原则的 对于像是安全或者性能至关重要的部分，我们可能除了继续使用 C API 以外别无选择 所以转码的部分使用C API
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
                           callback:(void(^)(BOOL result))callback
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        weakself.stopRecord = NO;
        @try {
            FILE *pcmFile = fopen([cafFilePath cStringUsingEncoding:NSASCIIStringEncoding], "rb");
            FILE *mp3File = fopen([mp3FilePath cStringUsingEncoding:NSASCIIStringEncoding], "wb+");
            
            if (pcmFile == nil || mp3File == nil) {
                callback(NO);
                return;
            }
            
            lame_t lameClient = lame_init();
            lame_set_in_samplerate(lameClient,sampleRate);
            lame_set_out_samplerate(lameClient, sampleRate);
            lame_set_num_channels(lameClient, 2);
            lame_set_brate(lameClient, 128);
            lame_init_params(lameClient);
            lame_set_quality(lameClient,2);
            //跳过 PCM header 否者会有一些噪音在MP3开始播放处
            fseek(pcmFile, 4*1024,  SEEK_CUR);
            
            //双声道获取比特率的数据
            int bufferSize = 256 * 1024;
            short *buffer = new short[bufferSize/2];
            short *leftBuffer = new short[bufferSize/4];
            short *rightBuffer = new short[bufferSize/4];
            unsigned char* mp3_buffer = new unsigned char[bufferSize];
            size_t readBufferSize = 0;
            
            while ((readBufferSize = fread(buffer, 2, bufferSize/2, pcmFile))>0) {
                for(int i = 0;i < readBufferSize;i++){
                    if(i % 2 == 0){
                        leftBuffer[i/2] = buffer[i];
                    }
                    else{
                        rightBuffer[i/2] = buffer[i];
                    }
                }
                size_t wroteSize = lame_encode_buffer(lameClient, (short int *)leftBuffer, (short int *)rightBuffer, (int)(readBufferSize / 2), mp3_buffer, bufferSize);
                fwrite(mp3_buffer, 1, wroteSize, mp3File);
            }
            
            //写入Mp3 VBR Tag，不是必须的步骤
            lame_mp3_tags_fid(lameClient, mp3File);
            readBufferSize = 0;
            
            //双声道获取比特率的数据
            bool isSkipPcmHeader = false;
            long curPos;
            //循环读取数据编码
            do {
                curPos = ftell(pcmFile);
                long startPos = ftell(pcmFile);
                fseek(pcmFile, 0, SEEK_END);
                long endPos = ftell(pcmFile);
                long totalDataLength = endPos - startPos;
                fseek(pcmFile, curPos, SEEK_SET);
                if (totalDataLength > bufferSize) {
                    if (!isSkipPcmHeader) {
                        //跳过 PCM header 否者会有一些噪音在MP3开始播放处
                        fseek(pcmFile, 4*1024,  SEEK_CUR);
                        isSkipPcmHeader = true;
                    }
                    readBufferSize = fread(buffer, 2, bufferSize/2, pcmFile);
                    //双声道的处理
                    for(int i = 0;i < readBufferSize;i++){
                        if(i % 2 == 0){
                            leftBuffer[i/2] = buffer[i];
                        }
                        else{
                            rightBuffer[i/2] = buffer[i];
                        }
                    }
                    size_t wroteSize = lame_encode_buffer(lameClient, (short int *)leftBuffer, (short int *)rightBuffer, (int)(readBufferSize / 2), mp3_buffer, bufferSize);
                    fwrite(mp3_buffer, 1, wroteSize, mp3File);
                }
                //sleep 0.05s
                sleep(0.05);
                
            } while (!weakself.stopRecord);
            //这里需要注意的是，一旦录音结束encodeEnd就会导致上面的函数结束，有可能出现解码慢，导致录音结束，仍然没有解码完所有数据的可能
            //循环读取剩余数据进行编码
            while ((readBufferSize = fread(buffer, 2, bufferSize/2, pcmFile))>0) {
                for(int i = 0;i < readBufferSize;i++){
                    if(i % 2 == 0){
                        leftBuffer[i/2] = buffer[i];
                    }
                    else{
                        rightBuffer[i/2] = buffer[i];
                    }
                }
                size_t wroteSize = lame_encode_buffer(lameClient, (short int *)leftBuffer, (short int *)rightBuffer, (int)(readBufferSize / 2), mp3_buffer, bufferSize);
                fwrite(mp3_buffer, 1, wroteSize, mp3File);
            }
            
            //写入Mp3 VBR Tag，不是必须的步骤
            lame_mp3_tags_fid(lameClient, mp3File);
            delete []buffer;
            delete []leftBuffer;
            delete []rightBuffer;
            delete []mp3_buffer;
        }
        @catch (NSException *exception) {
            if (callback) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(NO);
                });
            }
            return;
        }
        if (callback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(YES);
            });
        }
        
    });
}

/**
 send end record signal
 */
- (void)sendEndRecord {
    self.stopRecord = YES;
}



#pragma mark - ----------------------------------

// 这是录完再转码的方法, 如果录音时间比较长的话,会要等待几秒...
// Use this FUNC convent to mp3 after record

- (void)synchToMp3WithCafFilePath:(NSString *)cafFilePath
                      mp3FilePath:(NSString *)mp3FilePath
                       sampleRate:(int)sampleRate
                         callback:(void(^)(BOOL result))callback
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            int read, write;
            
            FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
            fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
            FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb+");  //output 输出生成的Mp3文件位置
            
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE*2];
            unsigned char mp3_buffer[MP3_SIZE];
            
            lame_t lame = lame_init();
            lame_set_num_channels(lame,1);//设置1为单通道，默认为2双通道
            lame_set_in_samplerate(lame, sampleRate);
            lame_set_VBR(lame, vbr_default);
            lame_init_params(lame);
            
            do {
                
                read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                if (read == 0) {
                    write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                    
                } else {
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                }
                
                fwrite(mp3_buffer, write, 1, mp3);
                
            } while (read != 0);
            
            lame_mp3_tags_fid(lame, mp3);
            
            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(YES);
                }
            });
        }
        @finally {
            NSLog(@"-----\n  MP3生成成功: %@   -----  \n", mp3FilePath);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(YES);
                }
            });
        }
    });
}

@end
@interface CODThread()
@property(nonatomic, assign) BOOL waitSignal;
@property(nonatomic, strong) NSCondition *condition;
@end

@implementation CODThread
+ (CODThread *) currentThread{
    return [[CODThread alloc]init];
}
- (id) init{
    self = [super init];
    if (self){
        self.waitSignal = NO;
        self.condition = [[NSCondition alloc] init];
    }
    return self;
}

-(BOOL)sendWaitSignal{
    [self.condition lock];
    self.waitSignal = YES;
    [self.condition unlock];
    return self.waitSignal;
}

-(BOOL)waitSignal{
    return _waitSignal;
}

-(void)sleep:(NSInteger)seconds{
    if (seconds == 0) {
        [self wait];
    }else{
        [self.condition lock];
        [self.condition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:seconds]];
        [self.condition unlock];
    }
}

-(void)wait{
    [self.condition lock];
    [self.condition wait];
    [self.condition unlock];
}

-(void)signal{
    [self.condition lock];
    self.waitSignal = NO;
    [self.condition signal];
    [self.condition unlock];
}

-(void)broadcast{
    [self.condition lock];
    self.waitSignal = NO;
    [self.condition broadcast];
    [self.condition unlock];
}
@end
