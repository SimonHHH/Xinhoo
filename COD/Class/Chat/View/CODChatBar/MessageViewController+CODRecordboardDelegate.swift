//
//  MessageViewController+CODRecordboardDelegate.swift
//  COD
//
//  Created by 1 on 2019/6/19.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

//录音的效果
extension MessageViewController:CODRecordKeyboardDelegate{
    ///开始录音
    func chatBarStartRecording(keyboard: CODRecordKeyboard) {
        self.recordKeyboared.recordStatus = .CODRecordRecording
        if self.recordLabel.superview != nil {
//            self.view.addSubview(self.recordLabel)
            self.recordLabel.isHidden = false
            self.recordLabel.text = "松开发送，滑动取消"

        }
        ///开始录音
        self.isRecording = true
        self.messageView.tableView.isUserInteractionEnabled = false
        self.messageView.snp.remakeConstraints{ (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(self.chatBar.snp.top)
        }
//        self.view.layoutIfNeeded()
        self.messageView.scrollToBottomWithAnimation(animation: false)
        self.chatBar.isUserInteractionEnabled = false
        AudioRecordInstance.delegate = self
        AudioRecordInstance.startRecord()
       print("chatBarStartRecording")
    }
    //取消录音
    func chatBarDidCancelRecording(keyboard: CODRecordKeyboard) {
        self.recordKeyboared.recordStatus = .CODRecordInit
        self.recordLabel.text = "录音已取消"
//        UIView.animate(withDuration: 0.2) {
            self.recordLabel.isHidden = true
            self.messageView.snp.remakeConstraints{ (make) in
                make.left.top.right.equalToSuperview()
                make.bottom.equalTo(self.chatBar.snp.top)
            }
//            self.view.layoutIfNeeded()
            self.messageView.scrollToBottomWithAnimation(animation: false)
//        }
        self.isRecording = false
        self.messageView.tableView.isUserInteractionEnabled = true
        self.chatBar.isUserInteractionEnabled = true

        ///取消录音
        AudioRecordInstance.cancelRrcord()
        print("chatBarDidCancelRecording")

    }
    //将要取消录音
    func chatBarWillCancelRecording(keyboard: CODRecordKeyboard,cancle:Bool) {
        if cancle == true {
            self.recordKeyboared.recordStatus = .CODRecordWillCancle
            self.recordLabel.text = "手指松开，取消发送"
        }else {
            self.recordLabel.text = "松开发送，滑动取消"
        }
        print("chatBarWillCancelRecording")

    }
    ///录音完成
    func chatBarFinishedRecoding(keyboard: CODRecordKeyboard) {
        self.recordKeyboared.recordStatus = .CODRecordInit
        self.recordLabel.text = "录音已发送"
//        UIView.animate(withDuration: 0.2) {
            self.recordLabel.isHidden = true
            self.messageView.snp.remakeConstraints{ (make) in
                make.left.top.right.equalToSuperview()
                make.bottom.equalTo(self.chatBar.snp.top)
            }
//            self.view.layoutIfNeeded()
            self.messageView.scrollToBottomWithAnimation(animation: false)
//        }
        self.isRecording = false
        self.messageView.tableView.isUserInteractionEnabled = true
        self.chatBar.isUserInteractionEnabled = true
        ///录音完成
        AudioRecordInstance.stopRecord()
        print("chatBarFinishedRecoding")

    }
    
}
