//
//  CODWebRTCManager.m
//  IOSWebRTC
//
//  Created by Xinhoo on 2019/8/6.
//  Copyright © 2019 XRuby. All rights reserved.
//

#import "CODWebRTCManager.h"
#import "CODWebRTCManager+Message.h"
#import "ARDSettingsModel.h"
#import "CODWebRTCManager+RTCPeerConnectionDelegate.h"
#import "COD-Swift.h"

//turn:39.97.229.253:3478
//turn:47.75.5.26:3478
//turn:112.74.201.221:3478

static NSString *const RTCSTUNServerURL3 = @"stun:stun.fwdnet.net";
static NSString *const RTCSTUNServerURL2 = @"stun:stun.ideasip.com";

static NSString *const RTCSTUNServerURL_HK = @"stun:turn-hk01.xinhoo.com:3478";
static NSString *const RTCTURNServerURL_HK = @"turn:turn-hk01.xinhoo.com:3478";

static NSString *const RTCSTUNServerURL_SZ = @"stun:turn-sz01.xinhoo.com:3478";
static NSString *const RTCTURNServerURL_SZ = @"turn:turn-sz01.xinhoo.com:3478";

static NSString *const RTCTURNServerURL_1 = @"turn:turn01.imangoim.com:3478";
static NSString *const RTCSTUNServerURL_1 = @"stun:turn01.imangoim.com:3478";
static NSString *const RTCTURNServerURL_2 = @"turn:turn02.imangoim.com:3478";
static NSString *const RTCSTUNServerURL_2 = @"stun:turn02.imangoim.com:3478";
static NSString *const RTCTURNServerURL_3 = @"turn:turn03.imangoim.com:3478";
static NSString *const RTCSTUNServerURL_3 = @"stun:turn03.imangoim.com:3478";

static NSString *const RTC_STUNServerURL_Flaygram_1 = @"stun:34.92.191.241:3478";
static NSString *const RTC_STUNServerURL_Flaygram_2 = @"stun:120.78.185.89:3478";
static NSString *const RTC_STUNServerURL_Flaygram_3 = @"stun:35.240.164.63:3478";

static NSString *const RTC_TURNServerURL_Flaygram_1 = @"turn:34.92.191.241:3478";
static NSString *const RTC_TURNServerURL_Flaygram_2 = @"turn:120.78.185.89:3478";
static NSString *const RTC_TURNServerURL_Flaygram_3 = @"turn:35.240.164.63:3478";


static NSString *const RTC_TURNServerURL_Flaygram_first = @"turn:turn-global.r7lz6.com:3478";
static NSString *const RTC_TURNServerURL_Mango_first = @"turn:turn-global.rezffb.com:3478";

static NSString *const RTC_STUNServerURL_XinhooIM_1 = @"stun:turn01.xinhoo.com:3478";
static NSString *const RTC_STUNServerURL_XinhooIM_2 = @"stun:turn02.xinhoo.com:3478";

static NSString *const RTC_TURNServerURL_XinhooIM_1 = @"turn:turn01.xinhoo.com:3478";
static NSString *const RTC_TURNServerURL_XinhooIM_2 = @"turn:turn02.xinhoo.com:3478";



const Float64 kFramerateLimit = 30.0;

@interface CODWebRTCManager() <RTCPeerConnectionDelegate, RTCDataChannelDelegate, RTCVideoCapturerDelegate> {
    RTCPeerConnectionFactory *peerConnectionfactory;
    NSMutableDictionary<NSString *, RTCDataChannel *>* localDataChannelDic;
    
    NSMutableArray *ICEServers;
    BOOL usingFrontCamera;
    
    ARDSettingsModel* settings;
    
    BOOL isSpeaker;
}

@end

@implementation CODWebRTCManager 

- (RTCIceServer *)defaultSTUNServer {
    
#if MANGO
    return [[RTCIceServer alloc] initWithURLStrings:@[RTCSTUNServerURL_1,RTCSTUNServerURL_2,RTCSTUNServerURL_3]];
#elif PRO
    return [[RTCIceServer alloc] initWithURLStrings:@[RTC_STUNServerURL_Flaygram_1,RTC_STUNServerURL_Flaygram_2,RTC_STUNServerURL_Flaygram_3]];
#else
    return [[RTCIceServer alloc] initWithURLStrings:@[RTC_STUNServerURL_XinhooIM_1,RTC_STUNServerURL_XinhooIM_2]];
#endif
}

- (RTCIceServer *)defaultTURNServer {

#if MANGO
    return [[RTCIceServer alloc] initWithURLStrings:@[RTCTURNServerURL_1,RTCTURNServerURL_2,RTCTURNServerURL_3] username:@"mangoturn" credential:@"cvKuUdaQ"];
#elif PRO
    return [[RTCIceServer alloc] initWithURLStrings:@[RTC_TURNServerURL_Flaygram_1,RTC_TURNServerURL_Flaygram_2,RTC_TURNServerURL_Flaygram_3] username:@"flygramturn" credential:@"1eNBLlc9"];
#else
    return [[RTCIceServer alloc] initWithURLStrings:@[RTC_TURNServerURL_XinhooIM_1,RTC_TURNServerURL_XinhooIM_2] username:@"xinhooimturn" credential:@"G3oCXiRV"];
#endif
}

- (RTCIceServer *)firstTURNServer {

#if MANGO
    return [[RTCIceServer alloc] initWithURLStrings:@[RTC_TURNServerURL_Mango_first] username:@"mangoturn" credential:@"cvKuUdaQ"];
#elif PRO
    return [[RTCIceServer alloc] initWithURLStrings:@[RTC_TURNServerURL_Flaygram_first] username:@"flygramturn" credential:@"DvKuUda5"];
#else
    return [[RTCIceServer alloc] initWithURLStrings:@[RTC_TURNServerURL_XinhooIM_1] username:@"xinhooimturn" credential:@"G3oCXiRV"];
#endif
}



+ (instancetype)sharedManager {
    static CODWebRTCManager *sharedMessageManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMessageManager = [[CODWebRTCManager alloc] init];
    });
    return sharedMessageManager;
}

- (instancetype)init {
    if (self = [super init]) {
        NSDictionary *fieldTrials = @{};
        RTCInitFieldTrialDictionary(fieldTrials);
        RTCInitializeSSL();
        RTCSetupInternalTracer();
        
        [self initSetup];
        
//        NSString* docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES).firstObject;
//        self.logPath = [docPath stringByAppendingPathComponent:@"log.txt"];
//        if (![[NSFileManager defaultManager] fileExistsAtPath:self.logPath]) {
//            BOOL isSuccess = [[NSFileManager defaultManager] createFileAtPath:self.logPath contents:nil attributes:nil];
//            if (!isSuccess) {
//                NSLog(@"// create log file faile //");
//            }
//        }
    }
    return self;
}

- (void)initSetup {
    usingFrontCamera = YES;
    
    signalStrength = 0;
    
    [RTCPeerConnectionFactory initialize];
    peerConnectionfactory = [[RTCPeerConnectionFactory alloc] init];
    
    ICEServers = [NSMutableArray array];
    [ICEServers addObject:[self firstTURNServer]];
    [ICEServers addObject:[self defaultSTUNServer]];
    [ICEServers addObject:[self defaultTURNServer]];
    
    connectedPeerDic = [NSMutableDictionary dictionary];
    localDataChannelDic = [NSMutableDictionary dictionary];
    remoteDataChannelDic = [NSMutableDictionary dictionary];
    
    settings = [[ARDSettingsModel alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    
//    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *webRTCLogPath = [documentsDirectory stringByAppendingPathComponent:@"WebRTCLog"];
//    RTCFileLogger* rtcLogger = [[RTCFileLogger alloc] initWithDirPath:webRTCLogPath maxFileSize:9999999999999];
//    [rtcLogger start];
    
//    RTCSetMinDebugLogLevel(RTCLoggingSeverityInfo);
}

- (void)exitRoom {
    iceConnectionState = RTCIceConnectionStateNew;
    
    [connectedPeerDic enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, RTCPeerConnection*  _Nonnull obj, BOOL * _Nonnull stop) {
        [self closePeerConnection:key];
    }];
    
    [self stopCapture];
    localAudioTrack = nil;
    localVideoTrack = nil;
    remoteStream = nil;
    [connectedPeerDic removeAllObjects];
    [localDataChannelDic removeAllObjects];
    [remoteDataChannelDic removeAllObjects];
    
    NSError* error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:&error];
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
}

- (void)closeOrOpenLocalAudio:(BOOL)isClose {
    localAudioTrack.isEnabled = !isClose;

    [localDataChannelDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, RTCDataChannel * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString* message = [NSString stringWithFormat:@"%d", isClose ? (int)DataChannelMessageTypeCloseAudio : (int)DataChannelMessageTypeOpenAudio];
        [self sendMessageByDataChannel:obj message:message];
    }];
}

- (void)closeOrOpenLocalVideo:(BOOL)isClose {
    if (isClose) {
        [self stopCapture];
    } else {
        [self startCapture];
    }
    localVideoTrack.isEnabled = !isClose;

    [localDataChannelDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, RTCDataChannel * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString* message = [NSString stringWithFormat:@"%d", isClose ? (int)DataChannelMessageTypeCloseVideo : (int)DataChannelMessageTypeOpenVideo];
        [self sendMessageByDataChannel:obj message:message];
    }];
}

- (void)switchToVoice {
    [self stopCapture];
    localVideoTrack.isEnabled = false;
    localVideoTrack = nil;
    [self switchAudioCategory:NO force:YES];
    
    [localDataChannelDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, RTCDataChannel * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString* message = [NSString stringWithFormat:@"%d", (int)DataChannelMessageTypeSwitchVoice];
        [self sendMessageByDataChannel:obj message:message];
    }];
}

- (void)initPeerConnectionsWithSockIds:(NSArray *)socketIds {
    [socketIds enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (![obj isEqualToString:mySocketId]) {
            
            [self createPeerConnection:obj];
//        }
    }];
    
//    [self addStreams];
//    [self createOffers:false];
}

- (RTCPeerConnection *)createPeerConnection:(NSString *)socketId {
    
    RTCPeerConnection* peerConnection = [self getPeerConnectionFromConnectedPeerDic:socketId];
    
    if (peerConnection) {
        return peerConnection;
    }else{
        RTCConfiguration *configuration = [[RTCConfiguration alloc] init];
        configuration.iceServers = ICEServers;
        RTCPeerConnection *peerConnection = [peerConnectionfactory peerConnectionWithConfiguration:configuration constraints:[self creatPeerConnectionConstraint] delegate:self];
        [connectedPeerDic setObject:peerConnection forKey:socketId];
        
        RTCDataChannelConfiguration *dataChannelConfiguration = [[RTCDataChannelConfiguration alloc] init];
        dataChannelConfiguration.isOrdered = YES;
        RTCDataChannel* localDataChannel = [peerConnection dataChannelForLabel:socketId configuration:dataChannelConfiguration];
        localDataChannel.delegate = self;
        [localDataChannelDic setObject:localDataChannel forKey:socketId];
        
        
        if ([socketId isEqualToString:mySocketId] || [chatType isEqualToNumber:@1]) {
            
            [peerConnection addTrack:self->localAudioTrack streamIds:@[kMediaStreamId]];
            if ([msgType isEqualToString:@"video"]) {
                [peerConnection addTrack:self->localVideoTrack streamIds:@[kMediaStreamId]];
            }
        }
        
        [self createOffer:peerConnection isResetIce:false];
        
        return peerConnection;
    }
    
    
}

#pragma mark - private
- (RTCMediaConstraints *)creatPeerConnectionConstraint {
    NSDictionary* dic = @{kRTCMediaConstraintsOfferToReceiveAudio:kRTCMediaConstraintsValueTrue,
                          kRTCMediaConstraintsOfferToReceiveVideo: [msgType isEqualToString:@"video"] ? kRTCMediaConstraintsValueTrue : kRTCMediaConstraintsValueFalse};
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:dic optionalConstraints:nil];
    return constraints;
}

- (void)addStreams {
    [connectedPeerDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, RTCPeerConnection *obj, BOOL * _Nonnull stop) {
        
        if ([key isEqualToString:mySocketId] || [chatType isEqualToNumber:@1]) {
            
            [obj addTrack:self->localAudioTrack streamIds:@[kMediaStreamId]];
            if ([msgType isEqualToString:@"video"]) {
                [obj addTrack:self->localVideoTrack streamIds:@[kMediaStreamId]];
            }
        }
        
    }];
}

- (void)switchCamera {
    usingFrontCamera = !usingFrontCamera;
    [self startCapture];
}

- (void)startCapture {
    AVCaptureDevicePosition position = usingFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    AVCaptureDevice *device = [self findDeviceForPosition:position];
    AVCaptureDeviceFormat *format = [self selectFormatForDevice:device];
    
    if (format == nil) {
        RTCLogError(@"No valid formats for device %@", device);
        NSAssert(NO, @"");
        
        return;
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        NSLog(@"相机访问受限");
    } else {
        if (!device) {
            NSLog(@"该设备不能打开摄像头");
        }
    }
    
    NSInteger fps = [self selectFpsForFormat:format];
    [capturer startCaptureWithDevice:device format:format fps:fps completionHandler:^(NSError * error) {
        if (error) {
            NSLog(@"///// start capture error:%@ /////", error.description);
            return;
        }
    }];
}

- (void)stopCapture {
    [capturer stopCapture];
}

- (void)createLocalStream {
    localAudioTrack = [peerConnectionfactory audioTrackWithTrackId:kAudioTrackId];
    
    if ([msgType isEqualToString:@"video"]) {
        RTCVideoSource *videoSource = [peerConnectionfactory videoSource];
        localVideoTrack = [peerConnectionfactory videoTrackWithSource:videoSource trackId:kVideoTrackId];
        
        capturer = [[RTCCameraVideoCapturer alloc] initWithDelegate:videoSource];
        [capturer.captureSession beginConfiguration];
        if ([capturer.captureSession canSetSessionPreset:AVCaptureSessionPresetMedium]) {
            capturer.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        }
        [capturer.captureSession commitConfiguration];
        
        if (self.capturerSessionBlock) {
            self.capturerSessionBlock(capturer.captureSession, localVideoTrack);
        }
        [self startCapture];
    }
}

- (void)createOffer:(RTCPeerConnection *)peerConnection isResetIce:(BOOL)isResetIce {
    if (peerConnection == nil) return;
    [peerConnection offerForConstraints:[self offerOrAnswerConstraint:isResetIce] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        if (error == nil) {
            codweakify(peerConnection);
            [peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"////// set sdp error: %@ ///////", error.description);
                    return;
                }
                codstrongify(peerConnection);
                [self setSDPWithPeerConnection:peerConnection];
            }];
        }
    }];
}

- (void)createOffers:(BOOL)isRestIce {
    [connectedPeerDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, RTCPeerConnection *obj, BOOL * _Nonnull stop) {
        [self createOffer:obj isResetIce:isRestIce];
    }];
}

- (RTCMediaConstraints *)offerOrAnswerConstraint:(BOOL)isResetIce {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:@{kRTCMediaConstraintsOfferToReceiveAudio:kRTCMediaConstraintsValueTrue,
                                                                                 kRTCMediaConstraintsOfferToReceiveVideo: [msgType isEqualToString:@"video"] ? kRTCMediaConstraintsValueTrue : kRTCMediaConstraintsValueFalse,
                                                                                 kRTCMediaConstraintsIceRestart: isResetIce ? kRTCMediaConstraintsValueTrue : kRTCMediaConstraintsValueFalse
                                                                                 }];
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:dic optionalConstraints:nil];
    return constraints;
}

- (void)sendIQ:(NSDictionary *)dic {
    XMPPIQ *iq = [CustomUtil objcXmppIQWithSetRTCWithXmlns:@"com:xinhoo:video_v2" actionDic:dic];
    [[XMPPManager shareXMPPManager].xmppStream sendElement:iq];
}

- (void)setSDPWithPeerConnection:(RTCPeerConnection *)peerConnection {
    NSString *socketId = [self getSocketIdFromConnectedPeerDic:peerConnection];
    
    if (peerConnection.signalingState == RTCSignalingStateHaveRemoteOffer) {
        [peerConnection answerForConstraints:[self offerOrAnswerConstraint:false] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
            __weak RTCPeerConnection *obj = peerConnection;
            [peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
                [self setSDPWithPeerConnection:obj];
            }];
        }];
    } else if (peerConnection.signalingState == RTCSignalingStateHaveLocalOffer) {       //判断连接状态为本地发送offer
        if (peerConnection.localDescription.type == RTCSdpTypeAnswer) {
            [self sendOfferOrAnswer:RTCSdpTypeAnswer socketId:socketId peerConnection:peerConnection];
        } else if(peerConnection.localDescription.type == RTCSdpTypeOffer) {             //发送者,发送自己的offer
            [self sendOfferOrAnswer:RTCSdpTypeOffer socketId:socketId peerConnection:peerConnection];
        }
    } else if (peerConnection.signalingState == RTCSignalingStateStable) {
        if (peerConnection.localDescription.type == RTCSdpTypeAnswer) {
            [self sendOfferOrAnswer:RTCSdpTypeAnswer socketId:socketId peerConnection:peerConnection];
        }
    }
}

- (void)sendOfferOrAnswer:(RTCSdpType)type socketId:(NSString *)socketId peerConnection:(RTCPeerConnection *)peerConnection{
    NSString* strType = type == RTCSdpTypeAnswer ? @"answer" : @"offer";
    NSDictionary *dic = @{@"name": strType,
                          @"requester": mySocketId,
                          @"receiver": socketId,
                          @"room": roomId,
                          @"chatType": chatType,
                          @"msgType": msgType,
                          @"setting": @{@"sdp": @{@"type": strType,
                                                  @"sdp": peerConnection.localDescription.sdp},
                                        @"socketId": socketId,
                                        @"room":roomId}
                          };
    [self sendIQ:dic];
}

- (NSString *)getSocketIdFromConnectedPeerDic:(RTCPeerConnection *)peerConnection {
    __block NSString *socketId;
    [connectedPeerDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, RTCPeerConnection *obj, BOOL * _Nonnull stop) {
        if ([obj isEqual:peerConnection]) {
            socketId = key;
            *stop = YES;
        }
    }];
    return socketId;
}

- (RTCPeerConnection *)getPeerConnectionFromConnectedPeerDic:(NSString *)socketId {
    __block RTCPeerConnection* peerConnection;
    [connectedPeerDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, RTCPeerConnection *obj, BOOL * _Nonnull stop) {
        if ([key isEqual:socketId]) {
            peerConnection = obj;
            *stop = YES;
        }
    }];
    return peerConnection;
}

- (void)closePeerConnection:(NSString *)socketId {
    RTCDataChannel *localDataChannel = [localDataChannelDic objectForKey:socketId];
    if (localDataChannel) [localDataChannel close];

    RTCDataChannel *remoteDataChannel = [remoteDataChannelDic objectForKey:socketId];
    if (remoteDataChannel) [remoteDataChannel close];
    
    RTCPeerConnection *peerConnection = [connectedPeerDic objectForKey:socketId];
    if (peerConnection) [peerConnection close];
    
    [localDataChannelDic removeObjectForKey:socketId];
    [remoteDataChannelDic removeObjectForKey:socketId];
    [connectedPeerDic removeObjectForKey:socketId];
}

- (NSDictionary *)getConnectedPeerDic {
    return connectedPeerDic;
}

#pragma mark - RTCDataChannel send message
- (void)sendMessageByDataChannel:(RTCDataChannel *)dataChannel message:(NSString *)message {
    NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    RTCDataBuffer *buffer = [[RTCDataBuffer alloc] initWithData:data isBinary:NO];
    BOOL result = [dataChannel sendData:buffer];
    if (result) {
        NSLog(@"success");
    } else {
        NSLog(@"error");
    }
}

#pragma mark - RTCDataChannelDelegate
- (void)dataChannelDidChangeState:(RTCDataChannel *)dataChannel {
    NSLog(@"%s",__func__);
    NSLog(@"channel.state %ld",(long)dataChannel.readyState);
}

- (void)dataChannel:(RTCDataChannel *)dataChannel didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer {
    NSLog(@"%s",__func__);
    NSString *message = [[NSString alloc] initWithData:buffer.data encoding:NSUTF8StringEncoding];
    NSLog(@"message:%@",message);
    dispatch_async(dispatch_get_main_queue(), ^{
        __block NSString* socketId;
        [self->remoteDataChannelDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, RTCDataChannel * _Nonnull obj, BOOL * _Nonnull stop) {
            if (dataChannel == obj) {
                socketId = key;
                *stop = YES;
            }
        }];
        
        if (socketId && message.length > 0 && self.didReciveMessageByDataChannelBlock) {
            self.didReciveMessageByDataChannelBlock(socketId, message.integerValue);
        }
    });
}

#pragma mark - RTCVideoCapturerDelegate
- (void)capturer:(nonnull RTCVideoCapturer *)capturer didCaptureVideoFrame:(nonnull RTCVideoFrame *)frame {
    NSLog(@"////////// videoFrame width:%d, height:%d //////////", frame.width, frame.height);
}

#pragma mark - Private
- (AVCaptureDevice *)findDeviceForPosition:(AVCaptureDevicePosition)position {
    NSArray<AVCaptureDevice *> *captureDevices = [RTCCameraVideoCapturer captureDevices];
    
    if (captureDevices.count <= 0) {
        return nil;
    }
    
    for (AVCaptureDevice *device in captureDevices) {
        if (device.position == position) {
            return device;
        }
    }
    return captureDevices[0];
}

- (AVCaptureDeviceFormat *)selectFormatForDevice:(AVCaptureDevice *)device {
    NSArray<AVCaptureDeviceFormat *> *formats = [RTCCameraVideoCapturer supportedFormatsForDevice:device];
    int targetWidth = [settings currentVideoResolutionWidthFromStore];
    int targetHeight = [settings currentVideoResolutionHeightFromStore];
    AVCaptureDeviceFormat *selectedFormat = nil;
    int currentDiff = INT_MAX;

    for (AVCaptureDeviceFormat *format in formats) {
        CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        FourCharCode pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription);
        int diff = abs(targetWidth - dimension.width) + abs(targetHeight - dimension.height);
        if (diff < currentDiff) {
            selectedFormat = format;
            currentDiff = diff;
        } else if (diff == currentDiff && pixelFormat == [capturer preferredOutputPixelFormat]) {
            selectedFormat = format;
        }
    }

    return selectedFormat;
}

- (NSInteger)selectFpsForFormat:(AVCaptureDeviceFormat *)format {
    Float64 maxSupportedFramerate = 0;
    for (AVFrameRateRange *fpsRange in format.videoSupportedFrameRateRanges) {
        maxSupportedFramerate = fmax(maxSupportedFramerate, fpsRange.maxFrameRate);
    }
    return fmin(maxSupportedFramerate, kFramerateLimit);
}


#pragma mark - 扬声器与听筒切换
- (void)roteChange:(NSNotification *)noti {
    //NSLog(@"///////////////roteChange:%@///////////////", noti);
    
    if (iceConnectionState == RTCIceConnectionStateNew) return;
    
    AVAudioSessionRouteChangeReason reason = [[noti.userInfo objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    NSLog(@"/////// reason:%d ///////", (int)reason);
    
    if (reason == AVAudioSessionRouteChangeReasonNewDeviceAvailable || reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        if (![self isHeadPhoneOrBleHeadPhoneEnable]) {
            if (isSpeaker) {
                [self switchAudioCategoryWithSpeaker:YES];
            } else {
                [self switchAudioCategoryWithSpeaker:NO];
            }
        } else {
            [self switchAudioCategoryWithSpeaker:NO];
        }
    }
}

- (BOOL)isHeadPhoneOrBleHeadPhoneEnable {
    BOOL isHeadPhoneEnable = NO;
    NSArray* array = @[AVAudioSessionPortHeadphones, AVAudioSessionPortBluetoothA2DP, AVAudioSessionPortBluetoothHFP, AVAudioSessionPortBluetoothLE];
    
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription *desc in [route outputs]) {
        if ([array containsObject:[desc portType]]) {
            isHeadPhoneEnable = YES;
            break;
        }
    }
    NSLog(@"/////// isHeadPhoneEnable:%@ ///////", isHeadPhoneEnable ? @"YES" : @"NO");
    return isHeadPhoneEnable;
}

- (void)switchAudioCategory:(BOOL)isSpeakers force:(BOOL)force {
    isSpeaker = isSpeakers;
    
    if (force) {
        [self switchAudioCategoryWithSpeaker:isSpeakers];
    } else {
        if (isSpeakers && [self isHeadPhoneOrBleHeadPhoneEnable]) {
            [self switchAudioCategoryWithSpeaker:NO];
        } else {
            [self switchAudioCategoryWithSpeaker:isSpeakers];
        }
    }
}

- (void)switchAudioCategoryWithSpeaker:(BOOL)isSpeakers {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError* error = nil;
        
        AVAudioSessionCategoryOptions categoryOptions = isSpeakers ? AVAudioSessionCategoryOptionDefaultToSpeaker : AVAudioSessionCategoryOptionAllowBluetooth;
        
        RTCAudioSessionConfiguration* configuration = [RTCAudioSessionConfiguration webRTCConfiguration];
        configuration.categoryOptions = categoryOptions;
        RTCAudioSession* session = [RTCAudioSession sharedInstance];
        [session lockForConfiguration];
        BOOL hasSucceeded = [session setConfiguration:configuration active:YES error:&error];
        if (!hasSucceeded) NSLog(@"switch error:%@", error.description);
        [session unlockForConfiguration];

        //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:categoryOptions error:&error];
        
        //AVAudioSessionPortOverride portOverride = isSpeakers ? AVAudioSessionPortOverrideSpeaker : AVAudioSessionPortOverrideNone;
        //[[AVAudioSession sharedInstance] overrideOutputAudioPort:portOverride  error:&error];
    });
}

@end
