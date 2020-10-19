//
//  CODVideoCancleView.swift
//  COD
//
//  Created by 1 on 2019/7/5.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODVideoCancleView: UIView {
    var isFirstHundredPercent: Bool = false
    
    fileprivate lazy var circleLayer:CAShapeLayer = { () -> CAShapeLayer in
        let circleLayer = CAShapeLayer()
        circleLayer.lineWidth = 2
        circleLayer.lineJoin = CAShapeLayerLineJoin.round
        circleLayer.lineCap = CAShapeLayerLineCap.round
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeStart = 0
        circleLayer.strokeEnd = 0
        
        let circlePath = UIBezierPath.init(arcCenter: YYTextCGRectGetCenter(self.bounds), radius: (self.bounds.size.width - 4)/2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        circleLayer.path = circlePath.cgPath
        
        self.progressView.layer.addSublayer(circleLayer)
        
        return circleLayer
    }()
    
    fileprivate lazy var progressView:UIView = { () -> UIView in
        let viewProgress = UIView()
        viewProgress.frame = self.bounds
        viewProgress.backgroundColor = UIColor.clear
        self.addSubview(viewProgress)
        
        return viewProgress
    }()
    
    fileprivate lazy var iconImgView:UIImageView = { () -> UIImageView in
        let imgView = UIImageView()
        imgView.frame = self.bounds
        imgView.contentMode = .scaleAspectFit
        self.addSubview(imgView)
        
        return imgView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showVideoLoadingView(progress: Float, imageNamed: String? = nil) {
        let strProgress = String(format:"%.2f", Float(progress))
        let progress = Float(strProgress) ?? 0.0
        
        //NSLog("////// progress:%f //////", progress)
        
        self.isHidden = false
        self.iconImgView.isHidden = false
        self.progressView.isHidden = false
        self.bringSubviewToFront(self.progressView)
        
        self.circleLayer.strokeEnd = CGFloat(progress)
        
        if let imageNamed = imageNamed {
            self.iconImgView.image = UIImage.init(named: imageNamed)
            self.iconImgView.sizeToFit()
            
        } else {
            self.iconImgView.image = UIImage.init(named: "msg_video_loading")
        }
        
        if self.progressView.layer.animation(forKey: "rotationAnimation") == nil {
            let animation:CABasicAnimation = CABasicAnimation(keyPath:"transform.rotation.z")
            animation.isRemovedOnCompletion = false
            animation.autoreverses = false
            animation.repeatCount = MAXFLOAT
            animation.duration = 1.5
            animation.fromValue = 0
            animation.toValue = Double.pi * 2
            animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear)
            animation.beginTime = 0
            self.progressView.layer.add(animation, forKey: "rotationAnimation")
        }
        
        if progress >= 1 && self.isFirstHundredPercent == false {
            self.isFirstHundredPercent = true
            
            self.progressView.layer.removeAnimation(forKey: "rotationAnimation")
        } else {
            self.isFirstHundredPercent = false
        }
    }
    
    func showPlayVideoIconView() {
        self.isHidden = false
        self.circleLayer.strokeEnd = 0
        self.progressView.isHidden = true
        self.iconImgView.isHidden = false
        self.iconImgView.image = UIImage.init(named: "msg_video")
    }
    
    func showUploadFinishedIconView() {
        self.isHidden = false
        self.circleLayer.strokeEnd = 0
        self.progressView.isHidden = true
        self.iconImgView.isHidden = false
        self.iconImgView.image = UIImage.init(named: "upload_success")
    }
    
    func showDownloadFinished() {
        self.isHidden = true
        self.circleLayer.strokeEnd = 0
        self.progressView.isHidden = true
        self.iconImgView.isHidden = true
    }
    
    func showHaveNotDownload(imageNamed: String? = nil) {
        self.isHidden = false
        self.circleLayer.strokeEnd = 0
        self.progressView.isHidden = false
        self.iconImgView.isHidden = false
        
        if let imageNamed = imageNamed {
            self.iconImgView.image = UIImage(named: imageNamed)
            self.iconImgView.sizeToFit()
        }
        
    }
    
    func hide() {
        self.isHidden = true
        self.circleLayer.strokeEnd = 0
        self.iconImgView.isHidden = true
        self.progressView.isHidden = true
    }
}


extension CODVideoCancleView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim == self.layer.animation(forKey: "scaleAnimation") && flag == true {
            self.isHidden = true
            self.circleLayer.strokeEnd = 0
            self.iconImgView.isHidden = true
            self.progressView.isHidden = true
            self.layer.removeAnimation(forKey: "scaleAnimation")
        }
    }
}
