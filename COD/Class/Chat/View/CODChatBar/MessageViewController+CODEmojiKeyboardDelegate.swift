//
//  MessageViewController+CODEmojiKeyboardDelegate.swift
//  COD
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

extension MessageViewController:CODEmojiKeyboardDelegate{
    /// 上滑或者下滑
    ///
    /// - Parameters:
    ///   - emojiKB: 表情键盘
    ///   - isScrollUp: 是否上滑
    func emojiKeyboardScrollStatus(emojiKB:CODEmojiKeyboard,isScrollUp:Bool){
        if(self.curStatus != .CODChatBarStatusEmoji){
            return;
        }
        if isScrollUp == true{
            print("wokan - up")
            UIView.animate(withDuration: 0.3) {
                self.chatBar.snp.updateConstraints { (make) in
                    make.bottom.equalToSuperview().offset(-(HEIGHT_CHAT_KEYBOARD+kSafeArea_Bottom)  - 60)
                }
                self.emojiKeyboard.snp.updateConstraints({ (make) in
                    make.height.equalTo(HEIGHT_CHAT_KEYBOARD+CGFloat(kSafeArea_Bottom) + 60)
                })
                self.view.needsUpdateConstraints()
                self.view.updateConstraintsIfNeeded()
                self.view.layoutIfNeeded()
            }
        }else{
            print("wokan - down")
            UIView.animate(withDuration: 0.05) {
                self.chatBar.snp.updateConstraints { (make) in
                    make.bottom.equalToSuperview().offset(-(HEIGHT_CHAT_KEYBOARD+kSafeArea_Bottom))
                }
                self.emojiKeyboard.snp.updateConstraints({ (make) in
                    make.height.equalTo(HEIGHT_CHAT_KEYBOARD+CGFloat(kSafeArea_Bottom))
                })
                self.view.needsUpdateConstraints()
                self.view.updateConstraintsIfNeeded()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - CODChatMessageController+CODEmojiKeyboardDelegate
    /// 长按表情
    ///
    /// - Parameters:
    ///   - emojiKB: 表情键盘
    ///   - emoji: 表情模型
    ///   - atRect: 位置
    func emojiKeyboardDidTouchEmojiItem(emojiKB:CODEmojiKeyboard,emoji:CODExpressionModel,atRect:CGRect){
        
    }
    /// 结束表情
    ///
    /// - Parameter emojiKB: 表情键盘
    func emojiKeyboardCancelTouchEmojiItem(emojiKB:CODEmojiKeyboard){
        
    }
    /// 选中这个表情
    ///
    /// - Parameters:
    ///   - emojiKB: 表情
    ///   - emoji: 表情模型
    func emojiKeyboardDidSelectedEmojiItem(emojiKB:CODEmojiKeyboard,emoji:CODExpressionModel){
        if emoji.type == .CODEmojiTypeEmoji || emoji.type == .CODEmojiTypeFace {
            ///1. 添加到CODChatBar
            self.chatBar.addEmojiString(emojiString: emoji.name)
        }else{
            ///直接发送图片表情
            self.sendEmojiMessage(text: emoji.name, toJID: self.toJID)
        }
    }
    /// 发送按钮 (发送表情)
    func emojiKeyboardSendButtonDown(){
        
        self.chatBar.sendCurrentText()
        //        self.emojiKeyboard.emjioGroupControl.sendButton.isEnabled = false
        //        self.emojiKeyboard.emjioGroupControl.sendButton.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1)
    }
    /// 删除表情
    func emojiKeyboardDeleteButtonDown(){
        self.chatBar.deleteCharacter()
        if self.chatBar.textView.text.count == 0 {
            //            self.emojiKeyboard.emjioGroupControl.sendButton.isEnabled = false
            //            self.emojiKeyboard.emjioGroupControl.sendButton.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1)
        }else{
            //            self.emojiKeyboard.emjioGroupControl.sendButton.isEnabled = true
            //            self.emojiKeyboard.emjioGroupControl.sendButton.backgroundColor = UIColor.init(hexString: kSubmitBtnBgColorS)
        }
    }
    /// 切换表情类型
    ///
    /// - Parameters:
    ///   - emojiKB: 表情键盘
    ///   - type: 类型
    func emojiKeyboardSelectedEmojiGroupType(emojiKB:CODEmojiKeyboard,type:CODEmojiType){
        
    }
}
