//
//  YBIBVideoView.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/11.
//  Copyright © 2019 杨波. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "YBIBVideoView.h"
#import "YBIBVideoActionBar.h"
//#import "YBIBVideoTopBar.h"
#import "YBIBUtilities.h"
#import "YBIBIconManager.h"
#import "COD-Swift.h"

@interface YBIBVideoView () <YBIBVideoActionBarDelegate>
//@property (nonatomic, strong) YBIBVideoTopBar *topBar;
@property (nonatomic, strong) YBIBVideoActionBar *actionBar;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, assign, getter=isPlaying) BOOL playing;
@property (nonatomic, assign, getter=isPlayFailed) BOOL playFailed;
@property (nonatomic, assign, getter=isDowning) BOOL downing;

@property (nonatomic ,strong)  id timeObser;
@end

@implementation YBIBVideoView {
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_playerLayer;
    BOOL _active;
}

#pragma mark - life cycle

- (void)dealloc {
    [self removeObserverForSystem];
    [self reset];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initValue];
        self.backgroundColor = UIColor.clearColor;
        [self addSubview:self.thumbImageView];
//        [self addSubview:self.topBar];
        [self addSubview:self.actionBar];
        [self addSubview:self.playButton];
        [self addObserverForSystem];
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapGesture:)];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isPlayVideo:) name:@"kYBIBVideoPlay" object:nil];

        [self addGestureRecognizer:_tapGesture];
    }
    return self;
}

- (void)initValue {
    _playing = NO;
    _active = YES;
    _needAutoPlay = NO;
    _autoPlayCount = 0;
    _playFailed = NO;
    _downing = NO;
}

#pragma mark - public
- (void)updateLayoutWithExpectOrientation:(UIDeviceOrientation)orientation containerSize:(CGSize)containerSize {
    UIEdgeInsets padding = YBIBPaddingByBrowserOrientation(orientation);
    CGFloat width = containerSize.width - padding.left - padding.right, height = containerSize.height;
//    self.topBar.frame = CGRectMake(padding.left, height - [YBIBVideoActionBar defaultHeight] - padding.bottom - 10, width, [YBIBVideoActionBar defaultHeight]+padding.bottom+10);
//    self.actionBar.frame = CGRectMake(padding.left, height - [YBIBVideoActionBar defaultHeight] - padding.bottom - 10, width, [YBIBVideoActionBar defaultHeight]);
    CGFloat heightV = self.actionBar.shareButton.hidden ? 79 + padding.bottom : [YBIBVideoActionBar defaultHeight] + padding.bottom + 10;
    self.actionBar.frame = CGRectMake(padding.left, height - heightV, width,heightV );
    self.playButton.center = CGPointMake(containerSize.width / 2.0, containerSize.height / 2.0);
    _playerLayer.frame = (CGRect){CGPointZero, containerSize};
}

- (void)reset {
    [self removeObserverForPlayer];
    // If set '_playerLayer.player = nil' or '_player = nil', can not cancel observeing of 'addPeriodicTimeObserverForInterval'.
    [_player pause];
    _playerItem = nil;
    [_playerLayer removeFromSuperlayer];
    _playerLayer = nil;

    [self finishPlay];
}


- (void)isPlayVideo:(NSNotification *)notification{
    NSDictionary *dic  = notification.userInfo;
    NSString *playString = dic[@"isPlay"];

    if (playString != nil) {
        if ([playString intValue]) {
            CODDiscoverMessageModel *model = [CustomUtil getCircleMessageWithMsgID:self.videoData.msgID];
            if (model != nil ) {
                if (model.isDelete == false) {
                    if (self.downing) {
                        return;
                    }
                    [self preparPlay];
                }else{
                    [self playerPause];
                }
            }else{
                [self playerPause];
            }
        }else{
            [self playerPause];
        }
      
    }
}
- (void)hideToolBar:(BOOL)hide {

    if (hide) {
        self.actionBar.hidden = YES;
    } else if (self.isPlaying) {
        if (self.videoData.isHiddenPlayTool) {
            self.actionBar.hidden = self.videoData.isHiddenPlayTool;
        }else{
            self.actionBar.hidden = NO;
        }
    }
}

- (void)hidePlayButton {
    [self playButtonIsHidden:YES];
}

- (void)playButtonIsHidden:(BOOL)hide{
    self.playButton.hidden = hide;
    NSString *hideString = hide ? @"1": @"0" ;
    if (!hide) {
        [self.actionBar pause];
        [self.actionBar setCurrentValue:0];
        [self playerPause];
    }
    [self.actionBar isHiddenPlayButton:!hide];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"kBottomViewHidden" object:nil userInfo:@{@"isHidden":hideString}];
}

#pragma mark - private
- (void)videoJumpWithScale:(float)scale {
    CMTime startTime = CMTimeMakeWithSeconds(scale, _player.currentTime.timescale);
    AVPlayer *tmpPlayer = _player;
    [_player seekToTime:startTime toleranceBefore:CMTimeMake(1, 1000) toleranceAfter:CMTimeMake(1, 1000) completionHandler:^(BOOL finished) {
        if (finished && tmpPlayer == self->_player) {
            [self startPlay];
        }
    }];
}

- (void)preparPlay {
    _playFailed = NO;
    [self playButtonIsHidden:YES];
    [self.delegate yb_preparePlayForVideoView:self];
    
    if (!_playerLayer) {
        self.downing = YES;
        
        //先下载
//        __weak typeof(self) weakSelf = self;
        [self.delegate yb_startPlayForVideoView:self];
        __weak typeof(self) wSelf = self;
        
        
        [CustomUtil loadMP4DataWithUrl:self.videoData.videoURL.absoluteString progressBlock:^(CGFloat progress) {
            if (progress < 0) progress = 0;
            if (progress > 1) progress = 1;
            YBIB_DISPATCH_ASYNC_MAIN(^{
                __strong typeof(wSelf) self = wSelf;
                if (!self) return;
                if (!wSelf.playButton.hidden) {
                    wSelf.playButton.hidden = true;
                }

//            if ([CustomUtil getCurrentMd5UrlStringWithUrl:self.videoData.videoURL.absoluteString])
            [wSelf.delegate yb_hideLoadingWithContainer:self];
            [wSelf.delegate yb_videoDataWithContainer:self downloadProgress:progress];
            })
        } successBlock:^(NSURL *playFileURL) {
            __strong typeof(wSelf) self = wSelf;
            self.downing = NO;
//            if ([playFileURL.absoluteString containsString:[CustomUtil getCurrentMd5UrlStringWithUrl:self.videoData.videoURL.absoluteString]]) {
            
                        
            [self hidePlayButton];
            [self playMP4:playFileURL];
            
            [CustomUtil movePicPathToConversationWithPicUrl:playFileURL filePath:playFileURL.path msgId:self.videoData.msgID];
//            }
            [self.delegate yb_hideLoadingWithContainer:self];
        } faliedBlock:^(NSString *errorMessage) {
            __weak typeof(self) weakSelf = self;
            weakSelf.playFailed = YES;
            weakSelf.downing = NO;

            [weakSelf.delegate yb_hideLoadingWithContainer:self];
            if ([errorMessage containsString:@"网络连接已中断"] || [errorMessage containsString:@"未能完成该操作。软件导致连接中止"] || [errorMessage containsString:@"播放文件出错"]) {
                [weakSelf reset];
                [weakSelf preparPlay];
            }else{
                [weakSelf.delegate yb_playNoNetFailedForVideoView:self];
            }

            
        }];
    } else {
//        weakSelf.downing = NO;
        [self videoJumpWithScale:0];
    }
    
}
- (void)playMP4:(NSURL *)playFileURL{
    
//    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCOD_loginName"];
//    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCOD_password"];
//    NSString *authStr = [NSString stringWithFormat:@"%@:%@", userName, password];
//    NSData *utf8Data = [authStr dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [utf8Data base64EncodedStringWithOptions:(0)]];
    NSDictionary *header = [UserManager getVideoDownLoaderHeader];
    self.asset = [AVURLAsset URLAssetWithURL:playFileURL options:@{@"AVURLAssetHTTPHeaderFieldsKey":header}];
    _playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = (CGRect){CGPointZero, [self.delegate yb_containerSizeForVideoView:self]};
    [self.layer insertSublayer:_playerLayer above:self.thumbImageView.layer];
    
    [self addObserverForPlayer];
}

- (void)startPlay {

    NSLog(@"xianannngneige");
    if (_player) {
        self.playing = YES;
        [_player play];
        [self.actionBar play];
        if (self.videoData.isHiddenPlayTool) {
            self.actionBar.hidden = self.videoData.isHiddenPlayTool;
        }else{
            self.actionBar.hidden = NO;
        }
        [self playButtonIsHidden:YES];
    
        [self.delegate yb_startPlayForVideoView:self];
    }else{
    }
}

- (void)finishPlay {
    [self playButtonIsHidden:NO];
    [self.actionBar setCurrentValue:0];
    if (self.videoData.isHiddenPlayTool) {
        self.actionBar.hidden = self.videoData.isHiddenPlayTool;
    }else{
        self.actionBar.hidden = NO;
    }
    self.playing = NO;
    self.downing = NO;

    [self.delegate yb_finishPlayForVideoView:self];
}

- (void)playerPause {
    NSLog(@"xianannngneige");
    if (_player) {
        [_player pause];
        [self.actionBar pause];
    }
}

- (BOOL)autoPlay {
    if (self.autoPlayCount == NSUIntegerMax) {
        [self preparPlay];
    } else if (self.autoPlayCount > 0) {
        --self.autoPlayCount;
        [self.delegate yb_autoPlayCountChanged:self.autoPlayCount];
        [self preparPlay];
    } else {
        return NO;
    }
    return YES;
}

#pragma mark - <YBIBVideoActionBarDelegate>

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar clickPlayButton:(UIButton *)playButton {
    if (self.downing) {
        return;
    }
    
    if (_playerLayer != nil){
        [self startPlay];
    }else{
        [self preparPlay];
    }

}

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar clickPauseButton:(UIButton *)pauseButton {
    [self playerPause];
}

- (void)yb_videoActionBar:(YBIBVideoActionBar *)actionBar changeValue:(float)value {
    [self videoJumpWithScale:value];
}

#pragma mark - observe

- (void)addObserverForPlayer {
 
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    __weak typeof(self) wSelf = self;
    _timeObser  = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(wSelf) self = wSelf;
        if (!self) return;
        if (self.playButton.isHidden) {
            
            float currentTime = floor(time.value) / floor(time.timescale);
            [self.actionBar setCurrentValue:currentTime];
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

- (void)removeObserverForPlayer {
    if (_player != nil && _timeObser != nil){
        [_player removeTimeObserver:_timeObser];
        _timeObser = nil;
    }
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (![self.delegate yb_isFreezingForVideoView:self]) {
        if (object == _playerItem) {
            if ([keyPath isEqualToString:@"status"]) {
                [self playerItemStatusChanged];
            }
        }
    }
}

- (void)didPlayToEndTime:(NSNotification *)noti {
    if (noti.object == _playerItem) {
        [self finishPlay];
        [self.delegate yb_didPlayToEndTimeForVideoView:self];
    }
}

- (void)playerItemStatusChanged {
    if (!_active) return;
    
    switch (_playerItem.status) {
        case AVPlayerItemStatusReadyToPlay: {
            [self startPlay];
            
            double max = CMTimeGetSeconds(_playerItem.duration);
            [self.actionBar setMaxValue:isnan(max) || isinf(max) ? 0 : max];
        }
            break;
        case AVPlayerItemStatusUnknown: {
            _playFailed = YES;
            [self.delegate yb_playFailedForVideoView:self];
            [self reset];
        }
            break;
        case AVPlayerItemStatusFailed: {
            _playFailed = YES;
            [self.delegate yb_playFailedForVideoView:self];
            [self reset];
        }
            break;
    }
}

- (void)removeObserverForSystem {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)addObserverForSystem {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarFrame) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
//    [[AVAudioSession sharedInstance] setActive:YES error:nil];
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)   name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseMP4) name:@"kAudioCallBegin" object:nil];

}

- (void)pauseMP4 {
    [self playerPause];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    _active = NO;
    [self playerPause];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    _active = YES;
}

- (void)didChangeStatusBarFrame {
    if ([UIApplication sharedApplication].statusBarFrame.size.height > YBIBStatusbarHeight()) {
        [self playerPause];
    }
}

- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            [self playerPause];
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            break;
    }
}

#pragma mark - event

- (void)respondsToTapGesture:(UITapGestureRecognizer *)tap {
    if (self.isPlaying) {
        if (self.videoData.isHiddenPlayTool) {
            self.actionBar.hidden = self.videoData.isHiddenPlayTool;
        }else{
            self.actionBar.hidden = !self.actionBar.isHidden;
        }

        [self.delegate yb_respondsToTapGestureForVideoView:self];

    } else {
        [self.delegate yb_respondsToTapGestureForVideoView:self];
    }
}

- (void)clickCancelButton:(UIButton *)button {
    [self.delegate yb_cancelledForVideoView:self];
}

- (void)clickPlayButton:(UIButton *)button {
    [self preparPlay];
}

#pragma mark - getters & setters

- (void)setNeedAutoPlay:(BOOL)needAutoPlay {
    if (needAutoPlay && _asset && !self.isPlaying) {
        [self autoPlay];
    } else {
        _needAutoPlay = needAutoPlay;
    }
}

@synthesize asset = _asset;
- (void)setAsset:(AVAsset *)asset {
    _asset = asset;
    if (!asset) return;
    if (self.needAutoPlay) {
        if (![self autoPlay]) {
            [self playButtonIsHidden:NO];
        }
        self.needAutoPlay = NO;
    } else {
        [self playButtonIsHidden:NO];
    }
}
- (AVAsset *)asset {
    if ([_asset isKindOfClass:AVURLAsset.class]) {
        NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCOD_loginName"];
        NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCOD_password"];
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", userName, password];
        NSData *utf8Data = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [utf8Data base64EncodedStringWithOptions:(0)]];
        NSDictionary *header = @{@"Accept":@"*/*",@"Authorization":authValue};
        _asset= [AVURLAsset URLAssetWithURL:((AVURLAsset *)_asset).URL options:@{@"AVURLAssetHTTPHeaderFieldsKey":header}];
//        _asset = [AVURLAsset assetWithURL:((AVURLAsset *)_asset).URL];
    }
    return _asset;
}

- (YBIBVideoActionBar *)actionBar {
    if (!_actionBar) {
        _actionBar = [YBIBVideoActionBar new];
        _actionBar.delegate = self;
        [_actionBar.cancelButton addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];\
        _actionBar.backgroundColor =  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
        _actionBar.hidden = false;
    }
    return _actionBar;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.bounds = CGRectMake(0, 0, 100, 100);
        [_playButton setImage:YBIBIconManager.sharedManager.videoBigPlayImage() forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        _playButton.hidden = YES;
        _playButton.layer.shadowColor = UIColor.darkGrayColor.CGColor;
        _playButton.layer.shadowOffset = CGSizeMake(0, 1);
        _playButton.layer.shadowOpacity = 1;
        _playButton.layer.shadowRadius = 4;
    }
    return _playButton;
}

- (UIImageView *)thumbImageView {
    if (!_thumbImageView) {
        _thumbImageView = [UIImageView new];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
        _thumbImageView.layer.masksToBounds = YES;
    }
    return _thumbImageView;
}

@end
