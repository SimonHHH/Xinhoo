//
//  CODIMChatCellDelegate.swift
//  COD
//
//  Created by 1 on 2019/3/6.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

@objc protocol CODIMChatCellDelegate: class {

    /**
     点击了 cell 本身
     */
    @objc optional func cellDidTaped(_ cell: CODBaseChatCell,model: CODMessageModel)
    
    /**
     点击了 cell 的头像
     */
    func cellDidTapedAvatarImage(_ cell: CODBaseChatCell,model: CODMessageModel)
    
    /**
     点击了 cell 的转发 （频道）
     */
    func cellDidTapedFwdImageView(_ cell: CODBaseChatCell,model: CODMessageModel)
    
    /// 长按头像
    ///
    /// - Parameters:
    ///   - cell: self
    ///   - model: 消息模型
    func cellDidLongTapedAvatarImage(_ cell: CODBaseChatCell,model: CODMessageModel)
    
    /**
     点击了 cell 中文字的 URL 标签 等等
     */
    func cellDidTapedLink(_ cell: CODBaseChatCell, linkString: URL)
    
    
    /**
     点击了 cell 电话号码
     */
    func cellDidTapedPhone(_ cell: CODBaseChatCell, phoneString: String)
    
//    /// 重新发送消息
//    ///
//    /// - Parameters:
//    ///   - cell: cell
//    ///   - message: 消息
    func cellSendMsgReation(message: CODMessageModel?)
    //    /// 名片的点击事件
    //    ///
    //    /// - Parameters:
    //    ///   - cell: cell
    //    ///   - message: 消息
    func cellCardAction(_ cell: CODBaseChatCell,message: CODMessageModel?)
//
//
    /// 单按事件
    ///
    /// - Parameters:
    ///   - message: 当前的消息体
    ///   - cell: 当前的单元格
    func cellTapMessage(message:CODMessageModel?,_ cell: CODBaseChatCell)

//    /// 长按事件
//    ///
//    /// - Parameters:
//    ///   - message: 当前的消息体
//    ///   - cell: 当前的单元格
//    func cellLongPressMessage(cellVM: ChatCellVM?, _ cell: UIView,_ view : UIView)
    
    func cellDeleteMessage(message:CODMessageModel?)
   
    
    /// 单击消息体内 @all
    /// - Parameters:
    ///   - message: 当前消息体
    ///   - cell: 当前cell
    func cellTapAtAll(message:CODMessageModel?,cell:CODBaseChatCell)

}

