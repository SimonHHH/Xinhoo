//
//  CODWebRTCManager+Message.m
//  IOSWebRTC
//
//  Created by Xinhoo on 2019/8/6.
//  Copyright © 2019 XRuby. All rights reserved.
//

#import "CODWebRTCManager+Message.h"

@implementation CODWebRTCManager (Message)

- (void)handleMessage:(NSDictionary *)dic {
    NSString *type = dic[@"body"];
    
    //发送加入房间后的反馈
    if ([type isEqualToString:@"accept"]) {
        strICEsdp = @"";
        
        NSDictionary *settingDic = dic[@"setting"];
        NSArray *socketIds = settingDic[@"jids"];
        mySocketId = settingDic[@"you"];
        roomId = settingDic[@"room"];
        msgType = [dic[@"msgType"] intValue] == 5 ? @"voice" : @"video";
        chatType = dic[@"chatType"];
        
        [self initPeerConnectionsWithSockIds:socketIds];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.getMemberListBlock) {
                self.getMemberListBlock(socketIds);
            }
        });
    //接收到新加入的人发了ICE候选，（即经过ICEServer而获取到的地址）
    } else if ([type isEqualToString:@"candidate"]) {
        NSDictionary *settingDic = dic[@"setting"];
        NSString *socketId = settingDic[@"socketId"];
        NSString *sdpMid = settingDic[@"id"];
        int sdpMLineIndex = [settingDic[@"label"] intValue];
        NSString *sdp = settingDic[@"candidate"];

        RTCIceCandidate *candidate = [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:sdpMLineIndex sdpMid:sdpMid];

        RTCPeerConnection *peerConnection = [connectedPeerDic objectForKey:socketId];
        [peerConnection addIceCandidate:candidate];
    //其他新人加入房间的信息
    } else if ([type isEqualToString:@"oneaccept"]) {
        NSDictionary *settingDic = dic[@"setting"];
        NSString *socketId = settingDic[@"jid"];
        
        [self initPeerConnectionsWithSockIds:@[socketId]];
        
//        RTCPeerConnection* peerConnection = [self getPeerConnectionFromConnectedPeerDic:socketId];
//        if (peerConnection) return;
//
//        peerConnection = [self createPeerConnection:socketId];
//        [peerConnection addTrack:localAudioTrack streamIds:@[kMediaStreamId]];
//        if ([msgType isEqualToString:@"video"]) {
//            [peerConnection addTrack:localVideoTrack streamIds:@[kMediaStreamId]];
//        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.addMemberBlock) {
                self.addMemberBlock(socketId);
            }
        });
    //有人离开房间的事件
    } else if ([type isEqualToString:@"close"]) {
        NSDictionary *settingDic = dic[@"setting"];
        NSString *socketId = settingDic[@"jid"];
        
        [self closePeerConnection:socketId];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.closeUserConnectedBlock) {
                self.closeUserConnectedBlock(socketId);
            }
            
            if (self.removeMemberBlock) {
                self.removeMemberBlock(socketId);
            }
        });
    //新加入的人发了个offer
    } else if ([type isEqualToString:@"offer"]) {
        NSDictionary *settingDic = dic[@"setting"];
        NSDictionary *sdpDic = settingDic[@"sdp"];
        NSString *sdp = sdpDic[@"sdp"];
        NSString *socketId = settingDic[@"socketId"];
        
        RTCPeerConnection *peerConnection = [connectedPeerDic objectForKey:socketId];
        RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeOffer sdp:sdp];
        codweakify(peerConnection);
        [peerConnection setRemoteDescription:remoteSdp completionHandler:^(NSError * _Nullable error) {
//            [self setSDPWithPeerConnection:weak_peerConnection];
        }];
    //回应offer
    } else if ([type isEqualToString:@"answer"]) {
        NSDictionary *settingDic = dic[@"setting"];
        NSDictionary *sdpDic = settingDic[@"sdp"];
        NSString *sdp = sdpDic[@"sdp"];
        NSString *socketId = settingDic[@"socketId"];
        
        RTCPeerConnection *peerConnection = [connectedPeerDic objectForKey:socketId];
        RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeAnswer sdp:sdp];
        codweakify(peerConnection);
        [peerConnection setRemoteDescription:remoteSdp completionHandler:^(NSError * _Nullable error) {
//            [self setSDPWithPeerConnection:weak_peerConnection];
        }];
    }
}

@end
