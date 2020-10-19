//
//  CODWebRTCManager.h
//  IOSWebRTC
//
//  Created by Xinhoo on 2019/8/6.
//  Copyright © 2019 XRuby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>
#import "GloableDefine.h"

static NSString * const kMediaStreamId = @"ARDAMS";
static NSString * const kAudioTrackId = @"ARDAMSa0";
static NSString * const kVideoTrackId = @"ARDAMSv0";
static NSString * const kVideoTrackKind = @"video";

typedef enum : NSUInteger {
    DataChannelMessageTypeOpenVideo,
    DataChannelMessageTypeCloseVideo,
    DataChannelMessageTypeOpenAudio,
    DataChannelMessageTypeCloseAudio,
    DataChannelMessageTypeSwitchVoice
} DataChannelMessageType;


NS_ASSUME_NONNULL_BEGIN

@interface CODWebRTCManager : NSObject {
    NSMutableDictionary *connectedPeerDic;
    NSString *mySocketId;
    
    int signalStrength;
    
    NSString *roomId;
    NSString *msgType;
    NSNumber *chatType;
    
    RTCCameraVideoCapturer * capturer;
    RTCVideoTrack* localVideoTrack;
    RTCAudioTrack* localAudioTrack;
    
    RTCMediaStream* remoteStream;
    
    NSMutableDictionary<NSString *, RTCDataChannel *>* remoteDataChannelDic;
    
    NSString* strICEsdp;
    
    RTCIceConnectionState iceConnectionState;
}

+ (instancetype)sharedManager;

@property (nonatomic, copy) void(^closeUserConnectedBlock)(NSString* socketId);
@property (nonatomic, copy) void(^capturerSessionBlock)(AVCaptureSession* captureSession, RTCVideoTrack* localVideoTrack);
@property (nonatomic, copy) void(^addRemoteStreamBlock)(NSString* socketId, RTCMediaStream *stream);

@property (nonatomic, copy) void(^iceConnectionStateBlock)(NSString* socketId, RTCIceConnectionState state);
@property (nonatomic, copy) void(^didReciveMessageByDataChannelBlock)(NSString* socketId, DataChannelMessageType type);

@property (nonatomic, copy) void(^getMemberListBlock)(NSArray* socketIds);
@property (nonatomic, copy) void(^addMemberBlock)(NSString* socketId);
@property (nonatomic, copy) void(^removeMemberBlock)(NSString* socketId);

@property (nonatomic, strong) NSString* logPath;

- (void)exitRoom;

- (void)switchCamera;
- (void)closeOrOpenLocalAudio:(BOOL)isClose;
- (void)closeOrOpenLocalVideo:(BOOL)isClose;
- (void)switchToVoice;
- (void)switchAudioCategory:(BOOL)isSpeakers force:(BOOL)force;

- (void)createLocalStream;

- (void)handleMessage:(NSDictionary *)dic;

- (void)sendIQ:(NSDictionary *)dic;

- (BOOL)isHeadPhoneOrBleHeadPhoneEnable;

- (void)createOffers:(BOOL)isRestIce;

/**
 由socketIds生成相应的PeerConnection，并添加音轨，声轨，发送offer （最开始进入房间收到回执调用）

 @param socketIds sockeId数组
 */
- (void)initPeerConnectionsWithSockIds:(NSArray *)socketIds;

- (void)setSDPWithPeerConnection:(RTCPeerConnection *)peerConnection;

- (RTCPeerConnection *)createPeerConnection:(NSString *)socketId;

- (RTCPeerConnection *)getPeerConnectionFromConnectedPeerDic:(NSString *)socketId;

- (NSString *)getSocketIdFromConnectedPeerDic:(RTCPeerConnection *)peerConnection;
- (void)closePeerConnection:(NSString *)socketId;


- (int)getSignalStrength;
+ (BOOL)whetherConnectedNetwork;

- (NSDictionary *)getConnectedPeerDic;

@end

NS_ASSUME_NONNULL_END
