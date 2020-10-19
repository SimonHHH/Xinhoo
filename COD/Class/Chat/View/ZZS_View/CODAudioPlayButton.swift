//
//  CODAudioPayButton.swift
//  COD
//
//  Created by Sim Tsai on 2019/12/5.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import pop

struct CODAudioPlayButtonStyle {
    
    static let leftPauseStateImage = UIImage(named: "other_audio_cell_play")
    static let leftPlayStateImage = UIImage(named: "other_audio_cell_pause")
    static let leftNoFileStateImage = UIImage(named: "other_audio_cell_download")
    static let leftDownloadingStateImage = UIImage(named: "other_audio_cell_close")
    
    static let rightPauseStateImage = UIImage(named: "audio_cell_play")
    static let rightPlayStateImage = UIImage(named: "audio_cell_pause")
    static let rightNoFileStateImage = UIImage(named: "audio_cell_download")
    static let rightDownloadingStateImage = UIImage(named: "audio_cell_close")

}

enum CODAudioPlayButtonState: String {
    case pause
    case play
    case noFile
    case downloading
}

enum CODAudioPlayButtonStyleType: String {
    case left
    case right
}

class CODAudioPlayButton: UIButton {
    
    @IBInspectable var payButtonStateIB: String {
        get {
            return self.payButtonState.rawValue
        }
        
        set {
            self.payButtonState = CODAudioPlayButtonState(rawValue: newValue) ?? .pause
        }
    }
    
    @IBInspectable var payButtonStyleIB: String {
        
        get {
            return self.payButtonStyle.rawValue
        }
        
        set {
            self.payButtonStyle = CODAudioPlayButtonStyleType(rawValue: newValue) ?? .left
        }
    }
    
    
    var payButtonState: CODAudioPlayButtonState = .pause {
        didSet {
            configButtonImage()
            initProgress()
        }
    }

    
    var payButtonStyle: CODAudioPlayButtonStyleType = .left {
        didSet {
            configButtonImage()
            initProgress()
        }
    }
    
    var circleProgress: CAShapeLayer?

    var progress: CGFloat = 0.0 {
        didSet {
            self.circleProgress?.strokeEnd = progress
            if progress == 1 {
                self.payButtonState = .pause
                self.circleProgress?.removeFromSuperlayer()
                
            }
        }
    }

    func configButtonImage() {

        switch (self.payButtonState, self.payButtonStyle) {
        case let (state, style) where state == .play && style == .left:
            self.setImage(CODAudioPlayButtonStyle.leftPlayStateImage, for: .normal)
        case let (state, style) where state == .pause && style == .left:
            self.setImage(CODAudioPlayButtonStyle.leftPauseStateImage, for: .normal)
        case let (state, style) where state == .noFile && style == .left:
            self.setImage(CODAudioPlayButtonStyle.leftNoFileStateImage, for: .normal)
        case let (state, style) where state == .downloading && style == .left:
            self.setImage(CODAudioPlayButtonStyle.leftDownloadingStateImage, for: .normal)

        case let (state, style) where state == .play && style == .right:
            self.setImage(CODAudioPlayButtonStyle.rightPlayStateImage, for: .normal)
        case let (state, style) where state == .pause && style == .right:
            self.setImage(CODAudioPlayButtonStyle.rightPauseStateImage, for: .normal)
        case let (state, style) where state == .noFile && style == .right:
            self.setImage(CODAudioPlayButtonStyle.rightNoFileStateImage, for: .normal)
        case let (state, style) where state == .downloading && style == .right:
            self.setImage(CODAudioPlayButtonStyle.rightDownloadingStateImage, for: .normal)
        default:
            return
        }
        

    }
    
    func initProgress() {
        
        if self.payButtonState != .downloading {
            self.circleProgress?.strokeEnd = 0
            self.circleProgress?.removeFromSuperlayer()
        }

        if self.payButtonState == .downloading {
            self.circleProgress = self.generateLayer(lineWidth: 2, cgrect: CGRect(x: 1, y: 1, width: self.bounds.width - 4, height: self.bounds.height - 4))
        }

    }
    

    func generateLayer(lineWidth: CGFloat, cgrect:CGRect) -> CAShapeLayer {
        
        let layer = CAShapeLayer()
        layer.frame = cgrect
        layer.lineCap = .round
        layer.lineWidth = lineWidth
        layer.fillColor = UIColor.clear.cgColor
        let path = UIBezierPath(ovalIn: cgrect)
        layer.path = path.cgPath
        self.layer.addSublayer(layer)
        
        layer.strokeColor = UIColor.white.cgColor
        layer.strokeEnd = self.progress
        return layer
        
    }
    

}


