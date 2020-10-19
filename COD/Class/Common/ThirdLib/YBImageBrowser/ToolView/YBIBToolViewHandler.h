//
//  YBIBToolViewHandler.h
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/7.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBSheetView.h"
#import "YBIBTopView.h"
#import "YBIBDataProtocol.h"
#import "YBIBOrientationReceiveProtocol.h"
#import "YBIBOperateBrowserProtocol.h"
#import "YBIBImageData.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum _ImageBrowserFromType {
    FromChat = 0,
    FromCircle_Publish,
    FromCircle_Friends,
    FromCircle_Person
} ImageBrowserFromType;

@protocol YBToolViewClickHandlerDelegate<NSObject>
//点击分享
-(void)shareYBImageData:(YBIBImageData *)data;
///删除图片
-(void)deleteYBImageData:(YBIBImageData *)data superView:(UIView *)superView currentPage:(NSInteger)currentPage;
@end

@protocol YBIBToolViewHandler <YBIBGetBaseInfoProtocol, YBIBOperateBrowserProtocol, YBIBOrientationReceiveProtocol>

@required

/**
 容器视图准备好了，可进行子视图的添加和布局
 */
- (void)yb_containerViewIsReadied;

/**
 隐藏视图
 
 @param hide 是否隐藏
 */
- (void)yb_hide:(BOOL)hide;

@optional

/// 当前数据
@property (nonatomic, copy) id<YBIBDataProtocol>(^yb_currentData)(void);

/**
 页码变化了
 */
- (void)yb_pageChanged;

/**
 偏移量变化了

 @param offsetX 当前偏移量
 */
- (void)yb_offsetXChanged:(CGFloat)offsetX;

/**
 响应长按手势
 */
- (void)yb_respondsToLongPress;

@end

@interface YBIBToolViewHandler : NSObject <YBIBToolViewHandler>

/// 弹出表单视图
@property (nonatomic, strong, readonly) YBIBSheetView *sheetView;

/// 顶部显示页码视图
@property (nonatomic, strong, readonly) YBIBTopView *topView;

///
@property (nonatomic, assign) ImageBrowserFromType fromType;

//按钮点击的按钮
@property(nonatomic,assign)id<YBToolViewClickHandlerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
