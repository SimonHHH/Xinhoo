//
//  YoukuRefreshHeader.swift
//  PullToRefreshKit
//
//  Created by huangwenchen on 16/7/31.
//  Copyright © 2016年 Leo. All rights reserved.
//

import Foundation
import UIKit

class YoukuRefreshHeader:UIView,RefreshableHeader{
    let iconImageView = UIImageView()// 这个ImageView用来显示下拉箭头
    let rotatingImageView = UIImageView() //这个ImageView用来播放动图
    let backgroundImageView = UIImageView() //这个ImageView用来显示广告的

    override init(frame: CGRect) {
        super.init(frame: frame)
        iconImageView.contentMode = .scaleAspectFit
        rotatingImageView.contentMode = .scaleAspectFit
        let imageWH = 80
        iconImageView.frame = CGRect(x: 0, y: 0, width: imageWH, height: imageWH)
        iconImageView.center = CGPoint(x: self.bounds.width/2.0, y: self.bounds.height/2.0)
        iconImageView.image = UIImage(named: "fresh_ani")
        rotatingImageView.image = UIImage(named: "fresh_ani")
        rotatingImageView.frame = CGRect(x: 0, y: 0, width: imageWH, height: imageWH)
        backgroundImageView.backgroundColor =  UIColor.clear
//        backgroundImageView.image = UIImage(named: "youku_ad.jpeg")
//        addSubview(backgroundImageView)
        addSubview(iconImageView)
        addSubview(rotatingImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView.frame = self.bounds
        iconImageView.center = CGPoint(x: self.bounds.width/2, y: self.frame.size.height - 30.0)
        rotatingImageView.center = CGPoint(x: self.bounds.width/2, y: self.frame.size.height - 30.0)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - RefreshableHeader -
    func heightForHeader() -> CGFloat {
        return UIScreen.main.bounds.size.width * 328.0/571.0
    }
    
    func heightForFireRefreshing() -> CGFloat {
        return 60.0
    }
    
    func heightForRefreshingState() -> CGFloat {
        return 60.0
    }
    
    //监听状态变化
    func stateDidChanged(_ oldState: RefreshHeaderState, newState: RefreshHeaderState) {
        if newState == .pulling && oldState == .idle{
         }
        if newState == .idle{
            UIView.animate(withDuration: 0.4, animations: {
//                self.iconImageView.transform = CGAffineTransform.identity
            })
        }
    }

    //松手即将刷新的状态
    func didBeginRefreshingState(){
        self.iconImageView.isHidden = true
        self.rotatingImageView.isHidden = false
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnimation.toValue = NSNumber(value: M_PI * 2)
        rotateAnimation.duration = 1
        rotateAnimation.isCumulative = true
        rotateAnimation.repeatCount = 10000000
        rotateAnimation.fillMode = CAMediaTimingFillMode.forwards
//        let animation:CAKeyframeAnimation = CAKeyframeAnimation.init(keyPath: "transform.rotation.z")
//        animation.keyTimes = [0, 0.5, 0.85, 1]
//        animation.values = [0, CGFloat(Double.pi), CGFloat(Double.pi) * 1.7, CGFloat(Double.pi) * 2]
//        animation.isRemovedOnCompletion = false
//        animation.repeatCount = MAXFLOAT
//        animation.duration = 1.5
//        animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.rotatingImageView.layer.add(rotateAnimation, forKey: "rotate")
    }
    //刷新结束，将要隐藏header
    func didBeginHideAnimation(_ result:RefreshResult){
        self.rotatingImageView.isHidden = true
        self.iconImageView.isHidden = false
//        self.iconImageView.layer.removeAllAnimations()
//        self.iconImageView.layer.transform = CATransform3DIdentity
        self.iconImageView.image = UIImage(named: "fresh_ani")
        
//        self.iconImageView.isHidden = true
//        self.rotatingImageView.isHidden = false
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnimation.toValue = NSNumber(value: M_PI * 2)
        rotateAnimation.duration = 1
        rotateAnimation.isCumulative = true
        rotateAnimation.repeatCount = 10000000
        rotateAnimation.fillMode = CAMediaTimingFillMode.forwards
        self.rotatingImageView.layer.add(rotateAnimation, forKey: "rotate")
    }
    //刷新结束，完全隐藏header
    func didCompleteHideAnimation(_ result:RefreshResult){
        
    }
}
