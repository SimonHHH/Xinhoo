//
//  CODChatBarDelegate.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

protocol CODChatBarDelegate:NSObjectProtocol
{
    
    /// ChatBar状态的改变
    ///
    /// - Parameters:
    ///   - chatBar: ChatBar
    ///   - fromStatus: 开始的状态
    ///   - toStatus: 要改变的状态
    func chatBarChange(chatBar:CODChatBar,fromStatus:CODChatBarStatus,toStatus:CODChatBarStatus)
    
    /// ChatBar的输入框改变
    ///
    /// - Parameters:
    ///   - chatBar: ChatBar
    ///   - height: 输入框的高度
    func changeTextViewHeight(chatBar:CODChatBar,height:CGFloat)
    
    
    /// 发送文字
    ///
    /// - Parameters:
    ///   - chatBar: ChatBar
    ///   - text: 发送文字内容
    func sendText(chatBar:CODChatBar,text:NSAttributedString)
    
    
    /// 文字输入的变化
    ///
    /// - Parameters:
    ///   - chatBar: 聊天输入栏
    ///   - text: 变化的内容
    func chatBar(chatBar:CODChatBar, textDidChange text: NSAttributedString)
    
    // MARK: - 录音控制
    /// 开始录音
    ///
    /// - Parameter chatBar: ChatBar
    func chatBarStartRecording(chatBar:CODChatBar)
    ///结束录音
    ///
    /// - Parameter chatBar: ChatBar
    func chatBarDidCancelRecording(chatBar:CODChatBar)
    
    /// 取消
    ///
    /// - Parameters:
    ///   - chatBar: ChatBar
    ///   - cancle: 取消
    func chatBarWillCancelRecording(chatBar:CODChatBar,cancle:Bool)
    
    /// 结束
    ///
    /// - Parameter chatBar: ChatBar
    func chatBarFinishedRecoding(chatBar:CODChatBar)
    
    
    /// 推出群成员列表
    func presentGroupMember()
}
