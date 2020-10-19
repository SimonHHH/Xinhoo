//
//  CODVideoCompressTool.m
//  COD
//
//  Created by XinHoo on 2019/7/11.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#import "CODVideoCompressTool.h"


@implementation CODVideoCompressTool
+ (void)compressVideoV2:(NSURL *)videoUrl withOutputUrl:(NSURL *)outputUrl complete:(typeof(void(^)(bool)))successBlock{
    AVAsset *asset = [AVAsset assetWithURL:videoUrl];
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:nil];
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:outputUrl fileType:AVFileTypeMPEG4 error:nil];
    
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize videoSize = [videoTrack naturalSize];
    CGAffineTransform t = videoTrack.preferredTransform;  //视频方向的获取
    
    
    AVAssetReaderTrackOutput *videoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:[CODVideoCompressTool configVideoOutput]];
    AVAssetWriterInput *videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:[CODVideoCompressTool videoCompressSettings:videoSize]];
    videoInput.transform = t;
    if ([reader canAddOutput:videoOutput]) {
        [reader addOutput:videoOutput];
    }
    if ([writer canAddInput:videoInput]) {
        [writer addInput:videoInput];
    }
    
    NSArray *tempArr = [asset tracksWithMediaType:AVMediaTypeAudio];
    BOOL ifGetAudio = YES;
    AVAssetReaderTrackOutput *audioOutput;
    AVAssetWriterInput *audioInput;
    if (tempArr.count > 0) {
        AVAssetTrack *audioTrack = [tempArr firstObject];
        audioOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:[self configAudioOutput]];
        audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:[self audioCompressSettings]];
        if ([reader canAddOutput:audioOutput]) {
            [reader addOutput:audioOutput];
        }
        if ([writer canAddInput:audioInput]) {
            [writer addInput:audioInput];
        }
        
    }else{
        ifGetAudio = NO;
    }
    

    [reader startReading];
    [writer startWriting];
    [writer startSessionAtSourceTime:kCMTimeZero];

    dispatch_queue_t videoQueue = dispatch_queue_create("Video Queue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t audioQueue;
    if (ifGetAudio) {
        audioQueue = dispatch_queue_create("Audio Queue", DISPATCH_QUEUE_SERIAL);
    }
    
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    __block BOOL videoRequestMediaFinished = NO;
    
    [videoInput requestMediaDataWhenReadyOnQueue:videoQueue usingBlock:^{
        while ([videoInput isReadyForMoreMediaData]) {
            CMSampleBufferRef sampleBuffer = NULL;

            if (writer.error == NULL && [reader status] == AVAssetReaderStatusReading && (sampleBuffer = [videoOutput copyNextSampleBuffer])) {
                BOOL result = [videoInput appendSampleBuffer:sampleBuffer];
                CFRelease(sampleBuffer);
                if (!result) {
                    [reader cancelReading];
                    break;
                }
            }else {
                
                [videoInput markAsFinished];
                if (videoRequestMediaFinished == NO) {
                    dispatch_group_leave(group);
                }
                
                videoRequestMediaFinished = YES;
                break;
            }
        }
        
        
    }];
    
    if (ifGetAudio) {
        dispatch_group_enter(group);
        __block BOOL audioRequestMediaFinished = NO;
        [audioInput requestMediaDataWhenReadyOnQueue:audioQueue usingBlock:^{
            while ([audioInput isReadyForMoreMediaData]) {
                CMSampleBufferRef sampleBuffer = NULL;
                if (writer.error == NULL && [reader status] == AVAssetReaderStatusReading && (sampleBuffer = [audioOutput copyNextSampleBuffer])) {
                    BOOL result = [audioInput appendSampleBuffer:sampleBuffer];
                    CFRelease(sampleBuffer);
                    if (!result) {
                        [reader cancelReading];
                        break;
                    }
                }else{
                    [audioInput markAsFinished];
                    if (audioRequestMediaFinished == NO) {
                        dispatch_group_leave(group);
                    }
                    audioRequestMediaFinished = YES;
                    break;
                }
            }
            
        }];
    }
    
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([reader status] == AVAssetReaderStatusReading) {
            [reader cancelReading];
        }
        switch (writer.status) {
            case AVAssetWriterStatusWriting: {
                [writer finishWritingWithCompletionHandler:^{
                    successBlock(YES);
                }];
                break;
                
            }
            default:
                successBlock(NO);
                break;
        }
    });
    
}



/** 视频解码 */
+ (NSDictionary *)configVideoOutput
{
    NSDictionary *videoOutputSetting = @{
                                         (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_422YpCbCr8],
                                         (id)kCVPixelBufferIOSurfacePropertiesKey :@{}
                                         };
    
    return videoOutputSetting;
}

/** 音频解码 */
+ (NSDictionary *)configAudioOutput
{
    NSDictionary *audioOutputSetting = @{
                                         AVFormatIDKey: @(kAudioFormatLinearPCM)
                                         };
    return audioOutputSetting;
}

+ (NSDictionary *)videoCompressSettings:(CGSize)videoSize{
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    CGFloat scale = videoSize.width/videoSize.height;
    if (scale > 1) { //横屏
        if (videoSize.width < 1280.0) {
            width = videoSize.width;
            height = videoSize.height;
        }else{
            width = 1280.0;
            height = 1280.0/scale;
        }
        
    }else{  //竖屏
        if (videoSize.height < 1280) {
            width = videoSize.width;
            height = videoSize.height;
        }else{
            width = 1280.0 * scale;
            height = 1280.0;
        }
    }
    
    NSDictionary *compressionPreperties = @{ AVVideoAverageBitRateKey : @(width*height*3),  //比特率
                                             AVVideoExpectedSourceFrameRateKey:@60,      //帧数：帧数就是在1秒钟时间里传输的图片的量
                                             AVVideoMaxKeyFrameIntervalKey:@60,          //关键帧最大间隔，1为每个都是关键帧，数值越大压缩率越高
                                             AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel};
    if (@available(iOS 11.0, *)) {
        NSDictionary *videoCompressSettings = @{ AVVideoCodecKey : AVVideoCodecTypeH264,
                                                 AVVideoWidthKey : @(width),
                                                 AVVideoHeightKey : @(height),
                                                 AVVideoCompressionPropertiesKey : compressionPreperties,
                                                 //                                             AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill
                                                 };
        return videoCompressSettings;
    } else {
        // Fallback on earlier versions
        NSDictionary *videoCompressSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
                                                 AVVideoWidthKey : @(videoSize.width),
                                                 AVVideoHeightKey : @(videoSize.height),
                                                 AVVideoCompressionPropertiesKey : compressionPreperties,
                                                 //                                             AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill
                                                 };
        return videoCompressSettings;
    }
}

+ (NSDictionary *)audioCompressSettings{
    AudioChannelLayout stereoChannelLayout = { .mChannelLayoutTag = kAudioChannelLayoutTag_Stereo,
        .mChannelBitmap = 0,
        .mNumberChannelDescriptions = 0
    };
    NSData *channelLayoutAsData = [NSData dataWithBytes:&stereoChannelLayout length:offsetof(AudioChannelLayout, mChannelDescriptions)];
    NSDictionary *audioCompressSettings = @{ AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                             AVEncoderBitRateKey : @96000,
                                             AVSampleRateKey : @44100,
                                             AVChannelLayoutKey : channelLayoutAsData,
                                             AVNumberOfChannelsKey : @2
                                             };
    return audioCompressSettings;
}




@end
