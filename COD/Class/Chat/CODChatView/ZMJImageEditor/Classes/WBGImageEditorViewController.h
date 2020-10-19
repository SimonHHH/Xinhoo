//
//  WBGImageEditorViewController.h
//  CLImageEditorDemo
//
//  Created by Jason on 2017/2/27.
//  Copyright © 2017年 CALACULU. All rights reserved.
//

#import "WBGImageEditor.h"

typedef NS_ENUM(NSUInteger, EditorMode) {
    EditorNonMode,
    EditorDrawMode,
    EditorTextMode,
    EditorClipMode,
    EditorPaperMode,
    EditorMosaicMode,
};

extern NSString * const kColorPanNotificaiton;

@interface WBGColorPan : UIView
@property (nonatomic, strong, readonly) UIColor *currentColor;
@end

@interface WBGImageEditorViewController : WBGImageEditor
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (strong, nonatomic) UIButton *newundoButton;///这个是新的撤销按钮
@property (nonatomic, strong)UIView *mosaicTypeView;///马赛克类型

@property (weak,   nonatomic, readonly) IBOutlet UIImageView *imageView;
@property (strong, nonatomic, readonly) IBOutlet UIImageView *drawingView;
@property (weak,   nonatomic, readonly) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic, readonly) IBOutlet WBGColorPan *colorPan;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (nonatomic, assign) EditorMode currentMode;

- (void)resetCurrentTool;

- (void)editTextAgain;
- (void)hiddenTopAndBottomBar:(BOOL)isHide animation:(BOOL)animation;
@end
