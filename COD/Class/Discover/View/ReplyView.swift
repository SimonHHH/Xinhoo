
//
//  ReplyView.swift
//  COD
//
//  Created by xinhooo on 2020/5/23.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import NextGrowingTextView
import SwiftyJSON

class ReplyView: UIView {

    enum KeyboardType {
        case text
        case emoji
    }
    /// 表情管理者
    lazy var emojiKBHelper:CODExpressionHelper = {
        let emojiKBHelper = CODExpressionHelper.sharedHelper()
        return emojiKBHelper
    }()

    ///表情键盘
    lazy var emojiKeyboard: CODEmojiKeyboard = {
        let emojiKeyboard = CODEmojiKeyboard(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 300))
        emojiKeyboard.emjioGroupControl.isNeedSendBtn = true
        return emojiKeyboard
    }()
    
    var textView: NextGrowingTextView = NextGrowingTextView()
   
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var changeKeyboardButton: UIButton!
    
    var keyType: KeyboardType = .text
    
    var momentsId = ""
    var replayUser = ""
    weak var responder: UIResponder!
    var keyboradView: UIView!
//    @IBOutlet weak var backViewHeight: NSLayoutConstraint!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.textView.placeholder = NSLocalizedString("评论...", comment: "")
        textView.textView.font = UIFont.systemFont(ofSize: 17)
        textView.textView.inputAccessoryView = self
        textView.textView.returnKeyType = .send
        textView.textView.enablesReturnKeyAutomatically = true
        backView.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        textView.maxNumberOfLines = 4
        textView.minNumberOfLines = 1
        
        // 监控文本输入框的高度，动态改变约束
        textView.delegates.didChangeHeight = { [weak self] (height) in
            
            guard let `self` = self else {
                return
            }
            var h = height
            if h < 34 {
                h = 34
            }
            
            self.frame = CGRect(x: self.x, y: self.y, width: self.width, height: h + 16)
            self.textView.textView.reloadInputViews()
             
        }
        textView.textView.delegate = self
        
        self.emojiKeyboard.delegate = self
        self.emojiKBHelper.emojiGroupData(userID:"",filterGif: true) {[weak self] (dataArray) in
            self?.emojiKeyboard.emojiGroupData = dataArray
        }
        
    }
    
    func config(momentsId:String, replyUser:String, responder: UIResponder, replyName: String?){
        
        if replyName != nil {
            self.textView.textView.placeholder = NSLocalizedString("回复@", comment: "") + replyName! + ":"
        }else{
            self.textView.textView.placeholder = NSLocalizedString("评论...", comment: "")
        }
        
        self.replayUser = replyUser
        self.momentsId = momentsId
        self.responder = responder
    }

    func dismiss() {
        
        self.isHidden = true
        
        if keyType == .emoji {
            self.changeKeyboardAction(changeKeyboardButton)
        }
        self.textView.textView.text = ""
        self.textViewDidChange(self.textView.textView)
        self.textView.textView.reloadInputViews()
        self.textView.textView.resignFirstResponder()
        self.responder?.resignFirstResponder()
    }
    
    func show() {
        
        self.isHidden = false
        
        self.responder?.becomeFirstResponder()
        self.textView.textView.becomeFirstResponder()
        
    }
    
    @IBAction func changeKeyboardAction(_ sender: UIButton) {
        
        
        if !self.textView.textView.isFirstResponder {
            self.textView.textView.becomeFirstResponder()
        }
        
        if keyType == .text {
        
            sender.setImage(UIImage(named: "text_input_icon"), for: .normal)
            keyType = .emoji
            
            textView.textView.inputView = self.emojiKeyboard
            
        }else{
            sender.setImage(UIImage(named: "emoji_input_icon"), for: .normal)
            keyType = .text
            textView.textView.inputView = nil
        }
        
        textView.textView.reloadInputViews()
    }
    
    func publishComment() {
        
        self.textView.textView.placeholder = NSLocalizedString("评论...", comment: "")
        
        let content = self.textView.textView.text ?? ""
        
        if content.removeAllSapce.count == 0 {
            return
        }
        
        self.keyboradView.removeFromSuperview()
        self.dismiss()
        
        if let replyModel = CODDiscoverMessageModel.addReply(momentsId: self.momentsId, serverId: "", replayUser: self.replayUser, comments: content) {
            
            CODDiscoverFailureAndSendingListModel.addReplyModel(replyModel: replyModel)
            CirclePublishTool.share.publishReplyWithModel(replyModel: replyModel) { (isSuccess) in

            }
        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.dismiss()
    }
    
}

extension ReplyView: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        let window = UIApplication.shared.keyWindow
        keyboradView = UIView()
        keyboradView.frame = window?.bounds ?? .zero
        keyboradView.backgroundColor = .clear
        keyboradView.addTap { [weak self,weak keyboradView] in
            guard let `self` = self else { return }
            keyboradView?.removeFromSuperview()
            self.dismiss()
        }
        
        
        let long = UILongPressGestureRecognizer(target: self, action: #selector(long(ges:)))
        long.minimumPressDuration = 0.1
        keyboradView.addGestureRecognizer(long)
        
        window?.addSubview(keyboradView)
        
        return true
    }
    
    @objc func long(ges:UILongPressGestureRecognizer) {
        if ges.state == .began {
            ges.view?.removeFromSuperview()
            self.dismiss()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            self.lineView.backgroundColor = UIColor(hexString: "007EE5")
        }else{
            self.lineView.backgroundColor = UIColor(hexString: "ACACAC")
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            self.publishComment()
            return false
        }
        
        if (textView.text.count >= 1000 && text != "") || text.count > 1000 || textView.text.count + text.count > 1000 {
            CODProgressHUD.showWarningWithStatus("输入内容过长")
            return false
        }
        
        return true
    }
    
}

extension ReplyView: CODEmojiKeyboardDelegate {
    func emojiKeyboardDidTouchEmojiItem(emojiKB: CODEmojiKeyboard, emoji: CODExpressionModel, atRect: CGRect) {
        print(#line,#function)
    }
    
    func emojiKeyboardCancelTouchEmojiItem(emojiKB: CODEmojiKeyboard) {
        print(#line,#function)
    }
    
    func emojiKeyboardDidSelectedEmojiItem(emojiKB: CODEmojiKeyboard, emoji: CODExpressionModel) {
        print(#line,#function)
        
        self.textView.textView.insertText(emoji.name ?? "")
        
    }
    
    func emojiKeyboardSendButtonDown() {
        print(#line,#function)
        if textView.textView.text.removeAllSapce.count != 0 {
            self.publishComment()
        }
        
    }
    
    func emojiKeyboardDeleteButtonDown() {
        print(#line,#function)
        self.textView.textView.deleteBackward()
    }
    
    func emojiKeyboardSelectedEmojiGroupType(emojiKB: CODEmojiKeyboard, type: CODEmojiType) {
        print(#line,#function)
    }
    
    func emojiKeyboardScrollStatus(emojiKB: CODEmojiKeyboard, isScrollUp: Bool) {
        print(#line,#function)
    }
    
    
}
