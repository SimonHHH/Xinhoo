//
//  ChatFileDownloadButtonNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/31.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class ChatFileDownloadButtonNode: CODButtonNode {
    
    
    
    enum ButtonState {
        case ide
        case downloading
        case cancel
    }
    
    var progress: CGFloat = 0.0 {
        didSet {
            
            if buttonState == .downloading {
                self.circleProgress?.strokeEnd = progress
                if progress == 1 {
                    self.circleProgress?.removeFromSuperlayer()
                }
            }
            
        }
    }
    
    var buttonState: ButtonState = .ide {
        didSet {
            
            if buttonState == .downloading {
                startAnimation()
                progressNode.isHidden = false
            } else {
                stopAnimation()
                progressNode.isHidden = true
            }
            
        }
    }
    
    var circleProgress: CAShapeLayer?
    
    var progressNode = ASDisplayNode()
    
    override init() {
        super.init()
        self.addSubnode(progressNode)
    }

    
    func generateLayer(lineWidth: CGFloat, cgrect:CGRect) -> CAShapeLayer {
        
        let layer = CAShapeLayer()
        layer.frame = cgrect
        layer.lineCap = .round
        layer.lineWidth = lineWidth
        layer.fillColor = UIColor.clear.cgColor
        let path = UIBezierPath(ovalIn: cgrect)
        layer.path = path.cgPath
        self.progressNode.view.layer.addSublayer(layer)
        
        layer.strokeColor = UIColor.white.cgColor
        layer.strokeEnd = self.progress
        return layer
        
    }
    
    func startAnimation() {
        
        if self.progressNode.view.layer.animation(forKey: "rotationAnimation") == nil {
            let animation:CABasicAnimation = CABasicAnimation(keyPath:"transform.rotation.z")
            animation.isRemovedOnCompletion = false
            animation.autoreverses = false
            animation.repeatCount = MAXFLOAT
            animation.duration = 1.5
            animation.fromValue = 0
            animation.toValue = Double.pi * 2
            animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear)
            animation.beginTime = 0
            self.progressNode.view.layer.add(animation, forKey: "rotationAnimation")
        }
        
    }
    
    func stopAnimation() {
        
        self.progressNode.view.layer.removeAnimation(forKey: "rotationAnimation")
        
    }
    
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
                
        progressNode.frame = self.bounds
        
        
        
        self.circleProgress = self.generateLayer(lineWidth: 2, cgrect: CGRect(x: 1, y: 1, width: self.view.bounds.width - 4, height: self.view.bounds.height - 4))
        
    }


}
