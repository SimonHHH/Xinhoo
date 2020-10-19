//
//  CODBaseKeyboard.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

/// 这个是键盘的基础类 提供键盘的显示和隐藏等操作
class CODBaseKeyboard: UIView {
    
    weak var delagate:CODKeyboardDelegate?
    fileprivate var isShow:Bool = false
    ///显示视图
    public func showInApplicationView(animation:Bool) {
        self.showInView(view: UIApplication.shared.keyWindow!, animation:animation)
    }
    ///显示视图
    public func showInView(view:UIView,animation:Bool) {
        if self.isShow{
            return
        }
        self.isShow = true
        if self.delagate != nil {
            self.delagate?.chatKeyboardWillShow(keyboard: self, animated: animation)
        }
        view.addSubview(self)
        
        let keyboardHeight = self.keyboardHeight() + CGFloat(kSafeArea_Bottom)
        self.snp.remakeConstraints({ (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(keyboardHeight)
            make.bottom.equalToSuperview().offset(keyboardHeight)
        })
        self.superview?.layoutIfNeeded()
        if animation {
            UIView.animate(withDuration: 0.01, animations: {
                self.snp.updateConstraints({ (make) in
                    make.bottom.equalToSuperview()
                })
                self.superview?.layoutIfNeeded()
                if self.delagate != nil{
                    self.delagate?.chatKeyboardDidChangeHeight(height: view.height - self.y, keyboard: self)
                }
            }) { (finshed) in
                ///完成
                if self.delagate != nil {
                    self.delagate?.chatKeyboardDidShow(keyboard: self, animated: animation)
                }
            }
        }else{
            self.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview()
            })
            self.superview?.layoutIfNeeded()
            if self.delagate != nil {
                self.delagate?.chatKeyboardDidShow(keyboard: self, animated: animation)
            }
        }
    }
    
    /// 关闭视图
    ///
    /// - Parameter animation: 动画
    public func dismissWithAnimation(animation:Bool){
        if self.isShow {
            self.isShow = false
            if self.delagate != nil {
                self.delagate?.chatKeyboardWillDismiss(keyboard: self, animated: animation)
            }
            let keyboardHeight = self.keyboardHeight() + CGFloat(kSafeArea_Bottom)
            if animation{
                UIView.animate(withDuration: 0.25, animations: {
                    self.snp.updateConstraints({ (make) in
                        make.bottom.equalTo(self.superview!).offset(keyboardHeight)
                    })
                    self.superview?.layoutIfNeeded()
                    if self.delagate != nil{
                        self.delagate?.chatKeyboardDidChangeHeight(height: (self.superview?.height)! - self.y, keyboard: self)
                    }
                }) { (finshed) in
                    self.removeFromSuperview()
                    if self.delagate != nil {
                        self.delagate?.chatKeyboardDidDismiss(keyboard: self, animated: animation)
                    }
                }
            }else{
                self.removeFromSuperview()
                if self.delagate != nil {
                    self.delagate?.chatKeyboardDidDismiss(keyboard: self, animated: animation)
                }
            }
        }
    }
}

extension CODBaseKeyboard:CODKeyboardProtocol{
    func keyboardHeight() -> CGFloat {
        return HEIGHT_CHAT_KEYBOARD
    }
}

protocol CODKeyboardDelegate:NSObjectProtocol{
    
    /// 键盘显示
    ///
    /// - Parameters:
    ///   - keyboard: keyboard
    ///   - animated: 动画
    func chatKeyboardWillShow(keyboard:CODBaseKeyboard,animated:Bool)
    /// 键盘已经显示
    ///
    /// - Parameters:
    ///   - keyboard: keyboard
    ///   - animated: 动画
    func chatKeyboardDidShow(keyboard:CODBaseKeyboard,animated:Bool)
    /// 键盘消失
    ///
    /// - Parameters:
    ///   - keyboard: keyboard
    ///   - animated: 动画
    func chatKeyboardWillDismiss(keyboard:CODBaseKeyboard,animated:Bool)
    /// 键盘已经消失
    ///
    /// - Parameters:
    ///   - keyboard: keyboard
    ///   - animated: 动画
    func chatKeyboardDidDismiss(keyboard:CODBaseKeyboard,animated:Bool)
    
    /// 键盘高度变化 这个就是
    ///
    /// - Parameters:
    ///   - height: 高度
    ///   - keyboard: keyboard
    func chatKeyboardDidChangeHeight(height:CGFloat,keyboard:CODBaseKeyboard)
}

