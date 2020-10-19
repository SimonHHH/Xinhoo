//
//  MessageToolBar.swift
//  COD
//
//  Created by XinHoo on 2019/2/28.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

final class MessageToolBar: UIToolbar ,UITextViewDelegate{
    
    var lastToolbarFrame: CGRect?
    
    var messageTextViewHeightConstraint: NSLayoutConstraint!
    
    let messageTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
    
    // MARK: UI
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.autoresizingMask = AutoresizingMask.flexibleHeight
        
        makeUI()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var messageTextViewMinHeight: CGFloat {
        let textContainerInset = messageTextView.textContainerInset
        return ceil(messageTextView.font!.lineHeight + textContainerInset.top + textContainerInset.bottom)
    }
    
    func makeUI() {
        
        self.addSubview(messageTextView)
//        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(micButton)
//        micButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(voiceRecordButton)
//        voiceRecordButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(moreButton)
//        moreButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        let _: [String: AnyObject] = [
            "moreButton": moreButton,
            "messageTextView": messageTextView,
            "micButton": micButton,
            "voiceRecordButton": voiceRecordButton,
            ]
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var stateTransitionAction: ((_ messageToolbar: MessageToolBar, _ previousState: MessageToolbarState, _ currentState: MessageToolbarState) -> Void)?
    
    var previousState: MessageToolbarState = .Default
    var state: MessageToolbarState = .Default {
        willSet {
            
            previousState = state
            
            updateHeightOfMessageTextView()
            
            if let action = stateTransitionAction{ action(self, previousState, newValue)
                
            }
            
            switch newValue {
            case .Default:
                moreButton.isHidden = false
                
                messageTextView.isHidden = false
                voiceRecordButton.isHidden = true
                
                micButton.setImage(UIImage(named: "voice_icon"), for: UIButton.State.normal)
                moreButton.setImage(UIImage(named: "add_icon"), for: UIButton.State.normal)
                
//                hideVoiceButtonAnimation()
                
            case .BeginTextInput:
                moreButton.isHidden = false
                moreButton.setImage(UIImage(named: "add_icon"), for: UIButton.State.normal)
                
            case .TextInputing:
//                moreButton.isHidden = true
                moreButton.isHidden = false
                moreButton.setImage(UIImage(named: "add_icon"), for: UIButton.State.normal)
                messageTextView.isHidden = false
                voiceRecordButton.isHidden = true
                
//                notifyTyping()
                
            case .VoiceRecord:
                moreButton.isHidden = false
                
                messageTextView.isHidden = true
                voiceRecordButton.isHidden = false
                
                messageTextView.text = ""
                
                micButton.setImage(UIImage(named: "keyboard_icon"), for: UIButton.State.normal)
                moreButton.setImage(UIImage(named: "more_icon"), for: UIButton.State.normal)
                
//                showVoiceButtonAnimation()
            }
        }
    
        
    }
    
    
    lazy var micButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "voice_icon"), for: UIButton.State.normal)
        button.tintColor = UIColor(red:0.557, green:0.557, blue:0.576, alpha:1)
        button.tintAdjustmentMode = UIButton.TintAdjustmentMode.normal
//        button.addTarget(self, action: #selector(ChatToolbar.toggleRecordVoice), forControlEvents: UIControlEvents.TouchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let normalCornerRadius: CGFloat = 6
    
    lazy var messageTextView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(hexString: "BBBBBB")?.cgColor
        textView.layer.cornerRadius = self.normalCornerRadius
        textView.delegate = self
        textView.isScrollEnabled = false // 重要：若没有它，换行时可能有 top inset 不正确
        return textView
    }()
    
    lazy var voiceRecordButton: VoiceRecordButton = {
        let button = VoiceRecordButton()
        
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = self.normalCornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hexString: "BBBBBB")?.cgColor
        button.tintColor = UIColor(red: 50, green: 167, blue: 255)
        
        button.touchesBegin = { [weak self] in
//            self?.tryVoiceRecordBegin()
        }
        
        button.touchesEnded = { [weak self] needAbort in
            if needAbort {
//                self?.tryVoiceRecordCancel()
            } else {
//                self?.tryVoiceRecordEnd()
            }
        }
        
        button.touchesCancelled = { [weak self] in
//            self?.tryVoiceRecordCancel()
        }
        
        button.checkAbort = { [weak self] topOffset in
//            self?.voiceRecordingUpdateUIAction?(topOffset: topOffset)
            
            return topOffset > 40
        }
        
        return button
    }()
    
    lazy var moreButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "add_icon"), for: UIButton.State.normal)
        button.tintColor = UIColor(red:0.557, green:0.557, blue:0.576, alpha:1)
        button.tintAdjustmentMode = UIButton.TintAdjustmentMode.normal
//        button.addTarget(self, action: #selector(ChatToolbar.moreMessageTypes), forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }()
    
    
    func updateHeightOfMessageTextView() {
        
        let size = messageTextView.sizeThatFits(CGSize(width: messageTextView.width, height: CGFloat(CGFloat.greatestFiniteMagnitude)))
        
        let newHeight = size.height
        let limitedNewHeight : CGFloat = 0.0
//            min(Ruler.iPhoneVertical(60, 80, 100, 100).value, newHeight)
        
        //println("oldHeight: \(messageTextViewHeightConstraint.constant), newHeight: \(newHeight)")
        
        if newHeight != messageTextViewHeightConstraint.constant {
            
            UIView.animate(withDuration:0.1, delay: 0.0, options: AnimationOptions.curveEaseInOut, animations: { [weak self] in
                self?.messageTextViewHeightConstraint.constant = limitedNewHeight
                self?.layoutIfNeeded()
                
                }, completion: { [weak self] finished in
                    // hack for scrollEnabled when input lots of text
                    if finished, let strongSelf = self {
                        let enabled = newHeight > strongSelf.messageTextView.bounds.height
                        strongSelf.messageTextView.isScrollEnabled = enabled
                    }
            })
        }
    }
}
