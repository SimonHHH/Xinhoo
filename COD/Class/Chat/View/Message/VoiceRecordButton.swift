//
//  VoiceRecordButton.swift
//  COD
//
//  Created by XinHoo on 2019/2/28.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class VoiceRecordButton: UIView {

    var touchesBegin: (() -> Void)?
    
    var touchesEnded: ((_ needAbort: Bool) -> Void)?
    
    var touchesCancelled: (() -> Void)?
    
    var checkAbort: ((_ topOffset: CGFloat) -> Bool)?
    
    var abort = false
    
    var titleLabel: UILabel?
    var leftVoiceImageView: UIImageView?
    var rightVoiceImageView: UIImageView?
    
    enum State {
        case Default
        case Touched
    }
    
    var state: State = .Default {
        willSet {
            let color: UIColor
            switch newValue {
            case .Default:
                color = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            case .Touched:
                color = UIColor(red: 50/255.0, green: 167/255.0, blue: 255/255.0, alpha: 1.0)
            }
            layer.borderColor = color.cgColor
            leftVoiceImageView?.tintColor = color
            rightVoiceImageView?.tintColor = color
            
            switch newValue {
            case .Default:
                titleLabel?.textColor = tintColor
            case .Touched:
                titleLabel?.textColor = UIColor(red: 50/255.0, green: 167/255.0, blue: 255/255.0, alpha: 1.0)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        abort = false
        touchesBegin?()
        titleLabel?.text = NSLocalizedString("松开 发送", comment: "")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        touchesEnded?(abort)
        titleLabel?.text = NSLocalizedString("按住 说话", comment: "")
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        super.touchesCancelled(touches!, with:event)
        
        touchesCancelled?()
        
        titleLabel?.text = NSLocalizedString("按住 说话", comment: "")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if let touch = touches.first {
            let location = touch.location(in: touch.view)
            
            if location.y < 0 {
                abort = checkAbort?(abs(location.y)) ?? false
            }
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        makeUI()
    }
    
    private func makeUI() {
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 15.0)
        titleLabel.text = NSLocalizedString("按住 说话", comment: "")
        titleLabel.textAlignment = .center
        titleLabel.textColor = self.tintColor
        
        self.titleLabel = titleLabel
        
        self.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        
        let viewsDictionary: [String: AnyObject] = ["titleLabel": titleLabel]
        
        let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLabel()]-10-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary)
        
        NSLayoutConstraint.activate(constraintsH)
    }

}
