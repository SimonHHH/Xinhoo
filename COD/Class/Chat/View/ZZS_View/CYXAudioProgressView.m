//
//  CYXAudioProgressView.m
//  CYXAudioProgressViewDemo
//
//  Created by 超级腕电商 on 2018/5/9.
//  Copyright © 2018年 超级腕电商. All rights reserved.
//

#import "CYXAudioProgressView.h"
#import "POP.h"
/*条条间隙*/
#define kDrawMargin 1
#define kDrawLineWidth 2
/*差值*/
#define differenceValue 9
@interface CYXAudioProgressView ()<CAAnimationDelegate>

/*条条 灰色路径*/
@property (nonatomic,strong) CAShapeLayer *shapeLayer;
/*背景黄色*/
@property (nonatomic,strong) CAShapeLayer *backColorLayer;
@property (nonatomic,strong) CAShapeLayer *maskLayer;


@end
@implementation CYXAudioProgressView



-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self.layer addSublayer:self.shapeLayer];
        [self.layer addSublayer:self.backColorLayer];
        self.persentage = 1;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = UIColor.clearColor;
        [self.layer addSublayer:self.shapeLayer];
        [self.layer addSublayer:self.backColorLayer];
        self.persentage = 1;
    }
    return self;
}

- (void)configShapeColor:(UIColor *)shapeColor backColor:(UIColor *)backColor{
    self.shapeLayer.strokeColor = shapeColor.CGColor;
    self.backColorLayer.strokeColor = backColor.CGColor;
}

#pragma mark ---Layers
/**
 初始化layer 在完成frame赋值后调用一下
 */
-(void)initLayers:(CGFloat)maxWidth{
    
    
    [self initStrokeLayer:maxWidth];
    [self setBackColorLayerWithwidth:maxWidth];
    
}
/*灰色路径*/
-(void)initStrokeLayer:(CGFloat)maxWidth{
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat drawHeight = self.frame.size.height;
    CGFloat x = 0.0;
    while (x+kDrawLineWidth<=maxWidth) {
        CGFloat random = arc4random()%differenceValue + 1;//差值在1-10 之间取
        [path moveToPoint:CGPointMake(x-kDrawLineWidth/2, random)];
        [path addLineToPoint:CGPointMake(x-kDrawLineWidth/2, drawHeight)];
        x+=kDrawLineWidth;
        x+=kDrawMargin;
    }
    self.shapeLayer.path = path.CGPath;
    self.backColorLayer.path = path.CGPath;
}
/*设置背景layer*/
-(void)setBackColorLayerWithwidth:(CGFloat)maxWidth{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.frame.size.height/2)];
    [path addLineToPoint:CGPointMake(maxWidth, self.frame.size.height/2)];
    self.maskLayer.frame = self.bounds;
    self.maskLayer.lineWidth = self.frame.size.width;
    self.maskLayer.path= path.CGPath;
    self.backColorLayer.mask = self.maskLayer;
}

-(void)setAnimationPersentage:(CGFloat)persentage duration:(CFTimeInterval)duration{
    CGFloat startPersentage = self.persentage;
    [self setPersentage:persentage];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = duration;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.fromValue = [NSNumber numberWithFloat:startPersentage];
    pathAnimation.toValue = [NSNumber numberWithFloat:persentage];
    pathAnimation.autoreverses = NO;
    pathAnimation.delegate = self;
    [self.maskLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    

}

- (void)stopAnimationPersentage{
    [self.maskLayer removeAnimationForKey:@"strokeEndAnimation"];
}

/**
 *  在修改百分比的时候，修改彩色遮罩的大小
 *
 *  @param persentage 百分比
 */
- (void)setPersentage:(CGFloat)persentage {
    
    _persentage = persentage;
    self.maskLayer.strokeEnd = persentage;
}
#pragma mark ---G
-(CAShapeLayer*)shapeLayer{
    if(!_shapeLayer){
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.lineWidth = kDrawLineWidth;
        _shapeLayer.fillColor = [UIColor clearColor].CGColor; // 填充色为透明（不设置为黑色）
        _shapeLayer.lineCap = kCALineCapSquare;
        _shapeLayer.strokeColor = [UIColor colorWithRed:162/255.0 green:215/255.0 blue:143.0/255 alpha:1].CGColor; // 路径颜色颜色
    }
    return _shapeLayer;
}
-(CAShapeLayer*)backColorLayer{
    if(!_backColorLayer){
        _backColorLayer = [[CAShapeLayer alloc] init];
        _backColorLayer.lineWidth = kDrawLineWidth;
        _backColorLayer.fillColor = [UIColor clearColor].CGColor; // 填充色为透明（不设置为黑色）
        _backColorLayer.lineCap = kCALineCapSquare;
        _backColorLayer.strokeColor = [UIColor colorWithRed:104/255.0 green:192/255.0 blue:80.0/255 alpha:1].CGColor; // 路径颜色颜色
    }
    return _backColorLayer;
}
-(CAShapeLayer*)maskLayer{
    if(!_maskLayer){
        _maskLayer = [[CAShapeLayer alloc] init];
        _maskLayer.strokeColor = [UIColor colorWithRed:104/255.0 green:192/255.0 blue:80.0/255 alpha:1].CGColor; // 路径颜色颜色
    }
    return _maskLayer;
}

@end
