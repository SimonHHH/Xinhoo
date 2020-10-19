//
//  CODWebRTCManager+RTCPeerConnectionDelegate.m
//  IOSWebRTC
//
//  Created by Xinhoo on 2019/8/6.
//  Copyright © 2019 XRuby. All rights reserved.
//

#import "CODWebRTCManager+RTCPeerConnectionDelegate.h"
#import <Bugly/Bugly.h>
@implementation CODWebRTCManager (RTCPeerConnectionDelegate)

#pragma mark RTCPeerConnectionDelegate

- (void)peerConnection:(RTCPeerConnection *)peerConnection didAddStream:(RTCMediaStream *)stream {
    NSLog(@"%s",__func__);
    NSString * socketId = [self getSocketIdFromConnectedPeerDic:peerConnection];
    dispatch_async(dispatch_get_main_queue(), ^{
        self->remoteStream = stream;
        NSLog(@"//////didAddStream socketId:%@, videoTrack:%@//////", socketId, stream.videoTracks);
        if (self.addRemoteStreamBlock) {
            self.addRemoteStreamBlock(socketId, stream);
        }
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didRemoveReceiver:(RTCRtpReceiver *)rtpReceiver {
    NSLog(@"%s",__func__);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState {
    NSLog(@"%s",__func__);
    NSLog(@"//////iceConnectionState:%d//////", (int)newState);
    NSString * socketId = [self getSocketIdFromConnectedPeerDic:peerConnection];
    iceConnectionState = newState;
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSString *content = [NSString stringWithContentsOfFile:self.logPath encoding:NSUTF8StringEncoding error:nil];
//        NSString *strLog = [NSString stringWithFormat:@"%@\r\n//////iceConnectionState:%d//////", content, (int)newState];
//        [strLog writeToFile:self.logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        if (self.iceConnectionStateBlock) {
            self.iceConnectionStateBlock(socketId, newState);
        }
    });
    
    if (newState == RTCIceConnectionStateFailed) {
//        NSString *exceptionName = [NSString stringWithFormat:@"webRTCLog_%@",mySocketId];
//        NSString *exceptionReason = strICEsdp;
//        NSDictionary *exceptionUserInfo = @{@"jid": mySocketId, @"iceSdp": strICEsdp};
//
//        NSException* exception = [[NSException alloc] initWithName:exceptionName reason:exceptionReason userInfo:exceptionUserInfo];
//        [Bugly reportException:exception];

        if (peerConnection.localDescription.type == RTCSdpTypeOffer) {
            [self createOffers:true];
        }
    }

//    if (newState == RTCIceConnectionStateDisconnected) {
//        
//        [self closePeerConnection:socketId];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (self.closeUserConnectedBlock) {
//                self.closeUserConnectedBlock(socketId);
//            }
//            
//            if (self.removeMemberBlock) {
//                self.removeMemberBlock(socketId);
//            }
//        });
//    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didAddReceiver:(RTCRtpReceiver *)rtpReceiver streams:(NSArray<RTCMediaStream *> *)mediaStreams{
    NSLog(@"%s",__func__);
    NSLog(@"%@",mediaStreams);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didGenerateIceCandidate:(RTCIceCandidate *)candidate{
    NSLog(@"%s",__func__);
    NSString *socketId = [self getSocketIdFromConnectedPeerDic:peerConnection];
    
    strICEsdp = [NSString stringWithFormat:@"%@/n  %@", candidate.sdp, strICEsdp];
    
    NSDictionary *dic = @{@"name": @"candidate",
                          @"requester": mySocketId,
                          @"receiver": socketId,
                          @"room": roomId,
                          @"chatType": chatType,
                          @"msgType": msgType,
                          @"setting": @{@"id": candidate.sdpMid,
                                        @"label": [NSNumber numberWithInteger:candidate.sdpMLineIndex],
                                        @"candidate": candidate.sdp,
                                        @"socketId": socketId,
                                        @"room": roomId}
                          };
    [self sendIQ:dic];
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didRemoveStream:(RTCMediaStream *)stream {
    NSLog(@"%s",__func__);
}

- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection {
    NSLog(@"%s",__func__);
    //NSLog(@"%s,line = %d object = %@",__FUNCTION__,__LINE__,peerConnection);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didRemoveIceCandidates:(NSArray<RTCIceCandidate *> *)candidates {
    NSLog(@"%s",__func__);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeSignalingState:(RTCSignalingState)stateChanged {
    NSLog(@"%s",__func__);
    NSLog(@"//////signalingState = %ld//////",(long)stateChanged);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeIceGatheringState:(RTCIceGatheringState)newState {
    NSLog(@"%s",__func__);
    NSLog(@"//////iceGatheringState = %d//////",(int)newState);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didOpenDataChannel:(RTCDataChannel *)dataChannel {
    NSLog(@"%s",__func__);
    NSLog(@"//////didOpenDataChannel = %@//////",dataChannel);
    RTCDataChannel* remoteDataChannel = dataChannel;
    remoteDataChannel.delegate = self;
    NSString * socketId = [self getSocketIdFromConnectedPeerDic:peerConnection];
    [remoteDataChannelDic setObject:remoteDataChannel forKey:socketId];
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeConnectionState:(RTCPeerConnectionState)newState {
    NSLog(@"%s",__func__);
    NSLog(@"//////peerConnectionState = %ld//////",(long)newState);
}

@end
