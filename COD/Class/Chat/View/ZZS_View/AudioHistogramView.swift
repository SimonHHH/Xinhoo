//
//  AudioHistogramView.swift
//  COD
//
//  Created by xinhooo on 2019/11/11.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit


class AudioHistogramView: UIView {

    let kDrawLineWidth = 2
    let differenceValue = 9
    let kDrawMargin = 1
//    let shapeLayer:CAShapeLayer? = nil
//    let backColorLayer:CAShapeLayer? = nil
//    let maskLayer:CAShapeLayer? = nil
    var persentage:CGFloat = 0.0 {
        didSet {
            self.maskLayer.strokeEnd = self.persentage
        }
    }
    
    lazy var shapeLayer:CAShapeLayer = {
       
        var layer = CAShapeLayer.init()
        layer.lineWidth = CGFloat(kDrawLineWidth)
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .square
        layer.strokeColor = UIColor.init(red: 162/255.0, green: 215/255.0, blue: 143/255.0, alpha: 1).cgColor
        return layer
    }()
    
    lazy var backColorLayer:CAShapeLayer = {
       
        var layer = CAShapeLayer.init()
        layer.lineWidth = CGFloat(kDrawLineWidth)
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .square
        layer.strokeColor = UIColor.init(red: 104/255.0, green: 192/255.0, blue: 80/255.0, alpha: 1).cgColor
        return layer
    }()
    
    lazy var maskLayer:CAShapeLayer = {
       
        var layer = CAShapeLayer.init()

        layer.strokeColor = UIColor.init(red: 104/255.0, green: 192/255.0, blue: 80/255.0, alpha: 1).cgColor
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.layer.addSublayer(self.shapeLayer)
        self.layer.addSublayer(self.backColorLayer)
        self.persentage = 1
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
        self.layer.addSublayer(self.shapeLayer)
        self.layer.addSublayer(self.backColorLayer)
        self.persentage = 1
    }
    
    func configShape(shapeColor:UIColor,backColor:UIColor) -> () {
        self.shapeLayer.strokeColor = shapeColor.cgColor
        self.backColorLayer.strokeColor = backColor.cgColor
    }
    
    func initLayers(maxWidth:CGFloat,message:CODMessageModel? = nil) {
        self.initStrokeLayer(maxWidht: maxWidth ,message: message)
        self.setBackColorLayerWith(maxWidth: maxWidth)
    }
    
    func initStrokeLayer(maxWidht:CGFloat,message:CODMessageModel? = nil) {
        let path = UIBezierPath.init()
        let drawHeight = self.frame.size.height
        var x:Int = 0
        
        guard let message = message else {
            
            while CGFloat(x+kDrawLineWidth) <= maxWidht {
                
                let random = Int(arc4random())%differenceValue + 1
                path.move(to: CGPoint.init(x: x-kDrawLineWidth/2, y: random))
                path.addLine(to: CGPoint.init(x: CGFloat(x-kDrawLineWidth/2), y: drawHeight))
                x += kDrawLineWidth
                x += kDrawMargin
                
                self.shapeLayer.path = path.cgPath
                self.backColorLayer.path = path.cgPath
            }
            
            return
        }
        
        if message.audioList.count > 0 {
            
            for randomStr in message.audioList {
                let random = randomStr.int ?? 0
                path.move(to: CGPoint.init(x: x-kDrawLineWidth/2, y: random))
                path.addLine(to: CGPoint.init(x: CGFloat(x-kDrawLineWidth/2), y: drawHeight))
                x += kDrawLineWidth
                x += kDrawMargin
            }
            
        }else{
            while CGFloat(x+kDrawLineWidth) <= maxWidht {
                let random = Int(arc4random())%differenceValue + 1
                try! Realm.init().write {
                    message.audioList.append("\(random)")
                }
                path.move(to: CGPoint.init(x: x-kDrawLineWidth/2, y: random))
                path.addLine(to: CGPoint.init(x: CGFloat(x-kDrawLineWidth/2), y: drawHeight))
                x += kDrawLineWidth
                x += kDrawMargin
            }
        }
        
        self.shapeLayer.path = path.cgPath
        self.backColorLayer.path = path.cgPath
    }
    
    func setBackColorLayerWith(maxWidth:CGFloat) {
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: 0, y: self.frame.size.height/2))
        path.addLine(to: CGPoint.init(x: maxWidth, y: self.frame.size.height/2))
        self.maskLayer.frame = self.bounds
        self.maskLayer.lineWidth = self.frame.size.width
        self.maskLayer.path = path.cgPath
        self.backColorLayer.mask = self.maskLayer
    }
    
    func setAnimationPersentage(persentage:CGFloat,duration:CFTimeInterval) {
        let startPersentage = self.persentage
        self.persentage = persentage
        let pathAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        pathAnimation.duration = duration
        pathAnimation.timingFunction = CAMediaTimingFunction.init(name: .linear)
        pathAnimation.fromValue = startPersentage
        pathAnimation.toValue = persentage
        pathAnimation.autoreverses = false
        self.maskLayer.add(pathAnimation, forKey: "strokeEndAnimation")
    }
    
    func stopAnimationPersentage() {
        self.maskLayer.removeAnimation(forKey: "strokeEndAnimation")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
