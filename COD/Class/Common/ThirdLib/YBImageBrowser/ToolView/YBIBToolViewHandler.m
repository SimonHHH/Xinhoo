//
//  YBIBToolViewHandler.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/7.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBToolViewHandler.h"
#import "YBIBCopywriter.h"
#import "YBIBUtilities.h"
#import "YBIBImageView.h"
#import "COD-Swift.h"
#import "YBIBWebImageManager.h"
#import "CODActionSheet.h"

@interface YBIBToolViewHandler ()
@property (nonatomic, strong) YBIBSheetView *sheetView;
@property (nonatomic, strong) YBIBSheetAction *saveAction;
@property (nonatomic, strong) YBIBTopView *topView;
@property (nonatomic, strong) YBIBImageView *bottomView;
@property (nonatomic, strong) CODImageTopVeiw *imageTopView;
@property (nonatomic, strong) CODImageBottomView *imageBottomView;

@end

@implementation YBIBToolViewHandler

#pragma mark - <YBIBToolViewHandler>

@synthesize yb_containerView = _yb_containerView;
@synthesize yb_containerSize = _yb_containerSize;
@synthesize yb_currentPage = _yb_currentPage;
@synthesize yb_totalPage = _yb_totalPage;
@synthesize yb_currentOrientation = _yb_currentOrientation;
@synthesize yb_currentData = _yb_currentData;

- (void)yb_containerViewIsReadied {
//    NotificationCenter.default.post(name: NSNotification.Name.init("kTransmessage"), object: nil)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toastTrans) name:@"kTransmessage"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toastCollection) name:@"kCollectionmessage"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toastSend) name:@"kSendmessage"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveData) name:@"kSavemessage"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareData) name:@"kIphoneShareMessage"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideBottomView:) name:@"kBottomViewHidden"  object:nil];
    
    if (self.fromType == FromCircle_Person) {
        [self.yb_containerView addSubview:self.imageTopView];
        [self.yb_containerView addSubview:self.imageBottomView];
//        [self.yb_containerView addSubview:self.likeAndCommentView];
    }else if (self.fromType == FromCircle_Friends) {
        [self.yb_containerView addSubview:self.imageTopView];
        [self.yb_containerView addSubview:self.bottomView];
    }else if (self.fromType == FromCircle_Publish) {
//        [self.yb_containerView addSubview:self.topView];
    }else{
        [self.yb_containerView addSubview:self.topView];
        [self.yb_containerView addSubview:self.bottomView];
    }
    
//    [self.yb_containerView addSubview:self.topView];
//    [self.yb_containerView addSubview:self.bottomView];
//    [self.yb_containerView addSubview:self.fullImageButton];
    [self layoutWithExpectOrientation:self.yb_currentOrientation()];
}

- (void)toastTrans{
    [[YBIBAuxiliaryViewHandler new] yb_showCorrectToastWithContainer:self.yb_containerView text:NSLocalizedString(@"已转发", @"")];
}

- (void)toastCollection{
    [[YBIBAuxiliaryViewHandler new] yb_showCorrectToastWithContainer:self.yb_containerView text:NSLocalizedString(@"已收藏至云盘", @"")];
}
- (void)toastSend{
    
    if (self.fromType == FromChat) {
        [[YBIBAuxiliaryViewHandler new] yb_showCorrectToastWithContainer:self.yb_containerView text:NSLocalizedString(@"已发送", @"")];
    }else{
        [[YBIBAuxiliaryViewHandler new] yb_showCorrectToastWithContainer:self.yb_containerView text:NSLocalizedString(@"已分享", @"")];
    }
}

- (void)saveData{
    
    id<YBIBDataProtocol> data = self.yb_currentData();
    if ([data respondsToSelector:@selector(yb_saveToPhotoAlbum)]) {
        [data yb_saveToPhotoAlbum];
    }
}
- (void)shareData{
    
    id<YBIBDataProtocol> data = self.yb_currentData();
    if ([data respondsToSelector:@selector(codShare)]) {
        [data codShare];
    }
}
- (void)hideBottomView:(NSNotification *)notification{
    NSDictionary *dic  = notification.userInfo;
    NSString *hideString = dic[@"isHidden"];
    if (hideString != nil) {
      
        self.bottomView.hidden = [hideString intValue];
    }
}
- (void)yb_pageChanged {
    if (self.fromType == FromCircle_Person) {
        id<YBIBDataProtocol> data = self.yb_currentData();
        NSString *messageID = @"";
        if ([data isKindOfClass:[YBIBImageData class]]){
            YBIBImageData *imageData = (YBIBImageData *)self.yb_currentData();
            messageID = imageData.msgID;
        }else{
            YBIBVideoData *videoData = (YBIBVideoData *)self.yb_currentData();
            messageID = videoData.msgID;
        }
        
        CODDiscoverMessageModel *messageModel = [CustomUtil getCircleMessageWithMsgID:messageID];
        if (messageModel != nil) {
            self.imageTopView.timeLabel.text = [CustomUtil getCircleMessageTimeWithMessageModel:messageModel];
           if ([data isKindOfClass:[YBIBImageData class]]){
               YBIBImageData *imageData = (YBIBImageData *)self.yb_currentData();
               self.imageTopView.pageLabel.text = [CustomUtil getCircleMessagePageWithMessageModel:messageModel photoId:imageData.photoId];
           }else{
               self.imageTopView.pageLabel.text = [CustomUtil getCircleMessagePageWithMessageModel:messageModel photoId:@""];
           }
            [self.imageTopView setMessageMessageModelWithMessageModel:messageModel];
            [self.imageBottomView setMessageModelWithMessageModel:messageModel];

        }
    }else if(self.fromType == FromCircle_Friends) {
        id<YBIBDataProtocol> data = self.yb_currentData();

        
        NSString *messageID = @"";
        if ([data isKindOfClass:[YBIBImageData class]]){
            YBIBImageData *imageData = (YBIBImageData *)self.yb_currentData();
            messageID = imageData.msgID;
        }else{
            YBIBVideoData *videoData = (YBIBVideoData *)self.yb_currentData();
            messageID = videoData.msgID;
        }
        
        CODDiscoverMessageModel *messageModel = [CustomUtil getCircleMessageWithMsgID:messageID];
        if (messageModel != nil) {
            self.imageTopView.timeLabel.text = [CustomUtil getCircleMessageTimeWithMessageModel:messageModel];
           if ([data isKindOfClass:[YBIBImageData class]]){
               YBIBImageData *imageData = (YBIBImageData *)self.yb_currentData();
               self.imageTopView.pageLabel.text = [CustomUtil getCircleMessagePageWithMessageModel:messageModel photoId:imageData.imageName];
           }else{
               self.imageTopView.pageLabel.text = [CustomUtil getCircleMessagePageWithMessageModel:messageModel photoId:@""];
           }
            [self.imageTopView setMessageMessageModelWithMessageModel:messageModel];
            [self.imageBottomView setMessageModelWithMessageModel:messageModel];

        }
        self.bottomView.hidden = true;
    }else{

        if(self.fromType == FromCircle_Publish) {
            self.topView.operationButton.hidden = false;
        }
        
        if (self.topView.operationType == YBIBTopViewOperationTypeSave) {
            self.topView.operationButton.hidden = ![self.yb_currentData() respondsToSelector:@selector(yb_saveToPhotoAlbum)];
        }

        [self.topView setPage:self.yb_currentPage() totalPage:self.yb_totalPage()];
        //重新赋值
        YBIBImageData *imageData = (YBIBImageData *)self.yb_currentData();
        if (imageData.msgID == nil || imageData.msgID.length == 0) {
            self.bottomView.hidden = YES;
        }
        
        self.bottomView.timeLabel.text = [CustomUtil getMessageTimeWithMsgID:imageData.msgID];
        self.bottomView.nameLabel.text = [CustomUtil getMessageNicknameWithMsgID:imageData.msgID];
        id<YBIBDataProtocol> data = self.yb_currentData();
        if ([data respondsToSelector:@selector(loadThumbImage)]) {
            [data loadThumbImage];
        }
        if ([data isKindOfClass:[YBIBVideoData class]]){
            self.bottomView.hidden = true;
            self.topView.hidden = false;
        }else{
            self.bottomView.hidden = false;
            self.topView.hidden = false;
        }
    }

}

- (void)yb_respondsToLongPress {
    [self showSheetView];
}

- (void)yb_hide:(BOOL)hide {
    
    if (self.fromType == FromCircle_Person) {
        
        self.imageTopView.hidden = hide;
        [self.imageBottomView isHiddenLikeViewWithIsHidden:hide];
    }else if(self.fromType == FromCircle_Friends) {
        
        self.imageTopView.hidden = hide;
    }else{
        
        self.topView.hidden = hide;
        self.bottomView.hidden = hide;

        YBIBImageData *data = self.yb_currentData();
        self.topView.hidden = hide;
        if (data.msgID == nil || data.msgID.length == 0 ){
            self.bottomView.hidden = YES;
        }else{
            self.bottomView.hidden = hide;
        }
        if ([data isKindOfClass:[YBIBVideoData class]]){

            self.bottomView.hidden = YES;
        }
        [self.sheetView hideWithAnimation:NO];
    }


}

- (void)yb_orientationWillChangeWithExpectOrientation:(UIDeviceOrientation)orientation {
    [self.sheetView hideWithAnimation:NO];
}

- (void)yb_orientationChangeAnimationWithExpectOrientation:(UIDeviceOrientation)orientation {
    [self layoutWithExpectOrientation:orientation];
}

#pragma mark - private

- (void)layoutWithExpectOrientation:(UIDeviceOrientation)orientation {
    CGSize containerSize = self.yb_containerSize(orientation);
    UIEdgeInsets padding = YBIBPaddingByBrowserOrientation(orientation);
    CGFloat width = containerSize.width - padding.left - padding.right, height = containerSize.height;

    if (self.fromType == FromCircle_Person) {
        
        self.imageTopView.frame = CGRectMake(padding.left, 0, containerSize.width - padding.left - padding.right, [YBIBTopView defaultHeight] + padding.top + 10);
        [self.imageTopView.backBtn addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.imageTopView.moreBtn addTarget:self action:@selector(clickMoreButton) forControlEvents:UIControlEventTouchUpInside];

        self.imageBottomView.frame= CGRectMake(padding.left, height - 160, width, 160);

    }else if(self.fromType == FromCircle_Friends) {
        self.imageTopView.frame = CGRectMake(padding.left, 0, containerSize.width - padding.left - padding.right, [YBIBTopView defaultHeight] + padding.top + 10);
        
        [self.imageTopView.backBtn addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.imageTopView.moreBtn addTarget:self action:@selector(clickMoreButton) forControlEvents:UIControlEventTouchUpInside];

    }else{
        
        self.topView.frame = CGRectMake(padding.left, 0, containerSize.width - padding.left - padding.right, [YBIBTopView defaultHeight] + padding.top);
        self.bottomView.frame= CGRectMake(padding.left, height - [YBIBTopView defaultHeight] - padding.bottom - 10, width, [YBIBTopView defaultHeight]+ padding.bottom + 10);
        [self.topView.cancelButton addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView.shareButton addTarget:self action:@selector(clickShareButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView.deleteButton addTarget:self action:@selector(clickDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    }

}

- (void)showSheetView {
//    if ([self.yb_currentData() respondsToSelector:@selector(yb_saveToPhotoAlbum)]) {
//        if (![self.sheetView.actions containsObject:self.saveAction]) {
//            [self.sheetView.actions addObject:self.saveAction];
//        }
//    } else {
//        [self.sheetView.actions removeObject:self.saveAction];
//    }
//    [self.sheetView showToView:self.yb_containerView orientation:self.yb_currentOrientation()];
    if (self.fromType == FromChat) {
        UIColor *blueColor = [UIColor colorWithRed:4/255.0 green:126/255.0 blue:245/255.0 alpha:1.0];
        __weak typeof(self) wSelf = self;
        id<YBIBDataProtocol> data = self.yb_currentData();
        NSString *saveTitleString = NSLocalizedString(@"保存图片", nil);
        if ([data isKindOfClass:[YBIBVideoData class]]) {
            saveTitleString = [YBIBCopywriter sharedCopywriter].saveVideo;
        }
        [CODActionSheet showActionSheetWithTitle:@"" cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[saveTitleString] cancelButtonColor:blueColor destructiveButtonColor:blueColor otherButtonColors:@[blueColor,blueColor,blueColor,blueColor,[UIColor redColor]] superView:self.yb_containerView handler:^(CODActionSheet *actionSheet, NSInteger index) {
            if (index > 0) {
                if ([wSelf.yb_currentData() respondsToSelector:@selector(yb_saveToPhotoAlbum)]) {
                    [data yb_saveToPhotoAlbum];
                }
            }

        }];
    }else{
        [self clickMoreButton];
    }
}
#pragma mark - click
- (void)clickMoreButton{
    NSLog(@"更多。。。。");

    UIColor *blueColor = [UIColor colorWithRed:4/255.0 green:126/255.0 blue:245/255.0 alpha:1.0];
    NSString *messageID = @"";
    id<YBIBDataProtocol> data = self.yb_currentData();
    if ([data isKindOfClass:[YBIBImageData class]]){
        YBIBImageData *imageData = (YBIBImageData *)self.yb_currentData();
        messageID = imageData.msgID;
    }else{
        YBIBVideoData *videoData = (YBIBVideoData *)self.yb_currentData();
        messageID = videoData.msgID;
    }
    CODDiscoverMessageModel *messageModel = [CustomUtil getCircleMessageWithMsgID:messageID];
    NSArray *otherButtonTitles = @[];
    NSArray *otherButtonColors = @[];
    
    NSString *openString =  (messageModel.msgType == 2) ? ((messageModel.msgPrivacyType == 2) ? @"设为公开照片" : @"设为私密照片") : ((messageModel.msgPrivacyType == 2) ? @"设为公开视频" : @"设为私密视频") ;
    NSString *sendFriendString = @"发送给朋友";
    NSString *colltionString = @"收藏";
    NSString *saveString = (messageModel.msgType == 2) ? @"保存图片" : @"保存视频";
    NSString *deleteString = @"删除";


    if ([messageModel.senderJid isEqualToString:[CustomUtil getUserJID]] ){

        otherButtonTitles = @[sendFriendString,colltionString,saveString,deleteString];
        otherButtonColors = @[blueColor,blueColor,blueColor,[UIColor redColor]];
    }else{
        
        otherButtonTitles = @[sendFriendString,colltionString,saveString];
        otherButtonColors = @[blueColor,blueColor,blueColor,];
    }
    
    NSInteger openInt = [otherButtonTitles indexOfObject:openString] + 1;
    NSInteger sendFriendInt = [otherButtonTitles indexOfObject:sendFriendString] + 1;
    NSInteger colltionInt = [otherButtonTitles indexOfObject:colltionString] + 1;
    NSInteger saveInt = [otherButtonTitles indexOfObject:saveString] + 1;
    NSInteger deleteInt = [otherButtonTitles indexOfObject:deleteString] + 1;
    __weak typeof(self) weakSelf = self;
    [CODActionSheet showActionSheetWithTitle:@"" cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:otherButtonTitles cancelButtonColor:blueColor destructiveButtonColor:blueColor otherButtonColors:otherButtonColors superView:self.yb_containerView handler:^(CODActionSheet *actionSheet, NSInteger index) {
        if (!self) return;
        if (index == saveInt){
            NSLog(@"baocun");
            if ([data respondsToSelector:@selector(yb_saveToPhotoAlbum)]) {
                [data yb_saveToPhotoAlbum];
            }
        }else if (index == deleteInt ){
            NSLog(@"shanchu");

            //删除朋友圈
            [weakSelf deleteCircleMessage:messageID];
        }else if (index == openInt){
            //是不是应该设置为公开的视频
          
        }else if (index == sendFriendInt){
            [CustomUtil shareCircleMessageWithMsgID:messageID data:(YBIBImageData *)self.yb_currentData()];

        }else if (index == colltionInt){
            NSLog(@"收藏");
            [CustomUtil collectionCircleMessageWithMsgID:messageID imageData:(YBIBImageData *)self.yb_currentData() ];
        }
    }];
}

- (void)deleteCircleMessage: (NSString *)messageID{
    [CustomUtil deleteCircleMessageWithMsgID:messageID currentPage:self.yb_currentPage() photoBrowser:self.yb_containerView.superview handler:^(NSString * _Nonnull tipString) {
        if (tipString.length == 4 || [tipString isEqualToString:@"Network Error"]) {
            [[YBIBAuxiliaryViewHandler new] yb_showIncorrectToastWithContainer:self.yb_containerView text:tipString];
        }else{
            [[YBIBAuxiliaryViewHandler new] yb_showCorrectToastWithContainer:self.yb_containerView text:tipString];
        }
    }];
}

- (void)clickCancelButton:(UIButton *)button{
    NSLog(@"返回。。。。");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kHideBrowser" object:nil];
}

- (void)clickShareButton:(UIButton *)button{
    NSLog(@"分享。。。。");
    YBIBImageData *imageData = (YBIBImageData *)self.yb_currentData();
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(shareYBImageData:)]){
        [self.delegate shareYBImageData:imageData];
    }
}

- (void)clickDeleteButton:(UIButton *)button{
    NSLog(@"删除。。。。");
    YBIBImageData *imageData = (YBIBImageData *)self.yb_currentData();
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(deleteYBImageData:superView:currentPage:)]){
        NSInteger ybCurrent = self.yb_currentPage();
        if (self.yb_totalPage() == 1 || self.yb_totalPage() == 0) {
            ybCurrent = 0;
        }else{
            ybCurrent = 1;
        }
        [self.delegate deleteYBImageData:imageData superView:self.yb_containerView currentPage:self.yb_currentPage()];
    }
}
#pragma mark - getters
- (YBIBSheetView *)sheetView {
    if (!_sheetView) {
        _sheetView = [YBIBSheetView new];
        __weak typeof(self) wSelf = self;
        [_sheetView setCurrentdata:^id<YBIBDataProtocol>{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return nil;
            return self.yb_currentData();
        }];
    }
    return _sheetView;
}

- (YBIBSheetAction *)saveAction {
    if (!_saveAction) {
        __weak typeof(self) wSelf = self;
        _saveAction = [YBIBSheetAction actionWithName:[YBIBCopywriter sharedCopywriter].saveToPhotoAlbum action:^(id<YBIBDataProtocol> data) {
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            if ([data respondsToSelector:@selector(yb_saveToPhotoAlbum)]) {
                [data yb_saveToPhotoAlbum];
            }
            [self.sheetView hideWithAnimation:YES];
        }];
    }
    return _saveAction;
}

- (YBIBTopView *)topView {
    if (!_topView) {
        _topView = [YBIBTopView new];
        _topView.operationType = YBIBTopViewOperationTypeMore;
        __weak typeof(self) wSelf = self;
        [_topView setClickOperation:^(YBIBTopViewOperationType type) {
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            switch (type) {
                case YBIBTopViewOperationTypeSave: {
                    id<YBIBDataProtocol> data = self.yb_currentData();
                    if ([data respondsToSelector:@selector(yb_saveToPhotoAlbum)]) {
                        [data yb_saveToPhotoAlbum];
                    }
                }
                    break;
                case YBIBTopViewOperationTypeMore: {
                    [self showSheetView];
                }
                    break;
                default:
                    break;
            }
        }];
        _topView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    }
    return _topView;
}

- (YBIBImageView *)bottomView {
    if (!_bottomView) {
        _bottomView = [YBIBImageView new];
    }
    return _bottomView;
}

- (CODImageTopVeiw *)imageTopView{
    if (!_imageTopView){
        _imageTopView = [CODImageTopVeiw new];
    }
    return _imageTopView;
}

- (CODImageBottomView *)imageBottomView{
    if (!_imageBottomView){
        _imageBottomView = [CODImageBottomView new];
    }
    return _imageBottomView;
}


@end
