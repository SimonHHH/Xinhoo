//
//  YBIBVideoActionBar.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/11.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBVideoActionBar.h"
#import "YBIBIconManager.h"


@interface YBVideoBrowseActionSlider : UISlider
@end
@implementation YBVideoBrowseActionSlider
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setThumbImage:YBIBIconManager.sharedManager.videoDragCircleImage() forState:UIControlStateNormal];
        self.minimumTrackTintColor = UIColor.whiteColor;
        self.maximumTrackTintColor = [UIColor.whiteColor colorWithAlphaComponent:0.5];
//        UIImage *img = [self scaleToSize:[self getImageWithColor:[UIColor whiteColor]] size:CGSizeMake(5, 5)];
//        [self setThumbImage:img forState:UIControlStateNormal];
        self.layer.shadowColor = UIColor.darkGrayColor.CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 4;
    }
    return self;
}
- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGRect frame = [super trackRectForBounds:bounds];
    return CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 2);
}
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect frame = [super thumbRectForBounds:bounds trackRect:rect value:value];
    return CGRectMake(frame.origin.x - 10, frame.origin.y - 10, frame.size.width + 20, frame.size.height + 20);
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size {
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (UIImage *)getImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 5.0f, 5.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end


@interface YBIBVideoActionBar ()
@property (nonatomic, strong) UILabel *preTimeLabel;
@property (nonatomic, strong) UILabel *sufTimeLabel;
@property (nonatomic, strong) YBVideoBrowseActionSlider *slider;

@property (nonatomic, strong) UIButton *playButton;
//@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *deleteButton;
@end

@implementation YBIBVideoActionBar {
    BOOL _dragging;
}

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _dragging = NO;
        [self addSubview:self.preTimeLabel];
        [self addSubview:self.sufTimeLabel];
        [self addSubview:self.slider];
        [self addSubview:self.shareButton];
        [self addSubview:self.playButton];
        [self addSubview:self.deleteButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat gap = 12;
    CGFloat width = self.bounds.size.width - gap*2, height = self.bounds.size.height, labelWidth = width / 2, labelHeigth = 16, buttonWidth = 70, labelOffset = 10;
    CGFloat imageWidth = YBIBIconManager.sharedManager.videoPlayImage().size.width;
//    CGFloat offset = (buttonWidth - imageWidth) * 0.5;

    self.slider.frame = CGRectMake(gap, 11, width , 19);

    self.preTimeLabel.frame = CGRectMake(gap, CGRectGetMaxY(self.slider.frame), labelWidth, labelHeigth);
    self.sufTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.preTimeLabel.frame), CGRectGetMaxY(self.slider.frame), labelWidth, labelHeigth);
    CGFloat actionBtnWidth = 37;
    self.shareButton.frame = CGRectMake(0, 59, actionBtnWidth, actionBtnWidth);
    if (self.shareButton.hidden){
        self.playButton.frame = CGRectMake((self.bounds.size.width - actionBtnWidth)/2, 25, actionBtnWidth, actionBtnWidth);
    }else{
        self.playButton.frame = CGRectMake((self.bounds.size.width - actionBtnWidth)/2, 59, actionBtnWidth, actionBtnWidth);
    }
    self.deleteButton.frame = CGRectMake(self.bounds.size.width - actionBtnWidth, 59, actionBtnWidth, actionBtnWidth);
}

#pragma mark - public

+ (CGFloat)defaultHeight {
    return 96;
}

- (void)setMaxValue:(float)value {
    self.slider.maximumValue = value;
    self.sufTimeLabel.attributedText = [self.class timeformatFromSeconds:value];
}

- (void)setCurrentValue:(float)value {
    if (!_dragging) {
        [self.slider setValue:value animated:NO];
    }
    self.preTimeLabel.attributedText = [self.class timeformatFromSeconds:value];
}

- (void)pause {
    self.playButton.selected = NO;
}

- (void)play {
    _dragging = NO;
    self.slider.userInteractionEnabled = YES;
    self.playButton.selected = YES;
}

- (void)isHiddenPlayButton: (BOOL)ishidden{
    self.playButton.hidden = ishidden;
}

- (void)isHiddenShareAndDeleteButton:(BOOL)ishidden{
    self.shareButton.hidden = ishidden;
    self.deleteButton.hidden = ishidden;
    CGFloat actionBtnWidth = 37;
    self.playButton.frame = CGRectMake((self.bounds.size.width - actionBtnWidth)/2, 25, actionBtnWidth, actionBtnWidth);
}

- (void)clickPlayButton:(UIButton *)button {
    button.userInteractionEnabled = NO;
    if (button.selected) {
        [self.delegate yb_videoActionBar:self clickPauseButton:button];
    } else {
        [self.delegate yb_videoActionBar:self clickPlayButton:button];
    }
    button.userInteractionEnabled = YES;
}

- (void)clickDeleteButton:(UIButton *)button {
    button.userInteractionEnabled = NO;
    [self.delegate yb_videoActionBar:self clickDeleteButton:button];
    button.userInteractionEnabled = YES;
}

- (void)clickShareButton:(UIButton *)button {
    button.userInteractionEnabled = NO;
    [self.delegate yb_videoActionBar:self clickShareButton:button];
    button.userInteractionEnabled = YES;
}
#pragma mark - private

+ (NSAttributedString *)timeformatFromSeconds:(NSInteger)seconds {
    NSInteger hour = seconds / 3600, min = (seconds % 3600) / 60, sec = seconds % 60;
    NSString *text = seconds > 3600 ? [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)min, (long)sec] : [NSString stringWithFormat:@"%02ld:%02ld", (long)min, (long)sec];
    
    NSShadow *shadow = [NSShadow new];
    shadow.shadowBlurRadius = 4;
    shadow.shadowOffset = CGSizeMake(0, 1);
    shadow.shadowColor = UIColor.darkGrayColor;
    NSAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSShadowAttributeName:shadow, NSFontAttributeName:[UIFont boldSystemFontOfSize:11]}];
    return attr;
}

#pragma mark - touch event
- (void)respondsToSliderTouchFinished:(UISlider *)slider {
    [self.delegate yb_videoActionBar:self changeValue:slider.value];
}

- (void)respondsToSliderTouchDown:(UISlider *)slider {
    _dragging = YES;
    slider.userInteractionEnabled = NO;
}

#pragma mark - getters
- (UILabel *)preTimeLabel {
    if (!_preTimeLabel) {
        _preTimeLabel = [UILabel new];
        _preTimeLabel.attributedText = [self.class timeformatFromSeconds:0];
        _preTimeLabel.adjustsFontSizeToFitWidth = YES;
        _preTimeLabel.textAlignment = NSTextAlignmentLeft;
        _preTimeLabel.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.9];
    }
    return _preTimeLabel;
}

- (UILabel *)sufTimeLabel {
    if (!_sufTimeLabel) {
        _sufTimeLabel = [UILabel new];
        _sufTimeLabel.attributedText = [self.class timeformatFromSeconds:0];
        _sufTimeLabel.adjustsFontSizeToFitWidth = YES;
        _sufTimeLabel.textAlignment = NSTextAlignmentRight;
        _sufTimeLabel.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.9];
    }
    return _sufTimeLabel;
}

- (YBVideoBrowseActionSlider *)slider {
    if (!_slider) {
        _slider = [YBVideoBrowseActionSlider new];
        [_slider addTarget:self action:@selector(respondsToSliderTouchFinished:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchCancel|UIControlEventTouchUpOutside];
        [_slider addTarget:self action:@selector(respondsToSliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    }
    return _slider;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:YBIBIconManager.sharedManager.videoPauseImage() forState:UIControlStateSelected];
        [_playButton setImage:YBIBIconManager.sharedManager.videoPlayImage() forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton setImage:[UIImage imageNamed:@"share_pic"] forState:UIControlStateNormal];
    }
    return _shareButton;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"delete_pic"] forState:UIControlStateNormal];
    }
    return _deleteButton;
}

@end
