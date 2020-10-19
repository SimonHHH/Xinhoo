//
//  CODChatMessageDisplayViewDelegate.swift
//  COD
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

protocol CODChatMessageDisplayViewDelegate:NSObjectProtocol
{
    /*界面的点击事件 用于收起键盘*/
    func chatMessageDisplayViewDidTouched(chatTVC:CODChatMessageDisplayView)
    
    func loadMoreMessage()
    
    func longTapHeadImageView(model: CODGroupMemberModel)
    
    func newMessageHaveCreate()
    
    /*编辑*/
    func editMessage(message: CODMessageModel)
    
    /*编辑*/
    func fileMessage(message: CODMessageModel,imageView: UIImageView)
    
    /*图片的点击事件*/
    func photoClick(message: CODMessageModel,imageView: UIImageView)
    
    /*语音的点击事件*/
    func audioClick(message:CODMessageModel,showCell: CODAudioChatCell)
    
    /*视频的点击事件*/
    func voideClick(message:CODMessageModel,imageView: UIImageView)
    
    /*语音视频的点击事件*/
    func videoCall(message:CODMessageModel,fromMe: Bool)
    
    /*删除*/
    func deleteMessage(message:CODMessageModel)
    
    /*回复*/
    func replyMessage(message:CODMessageModel)
    
    /*转发*/
    func transMessage(message:CODMessageModel)
    
    /*置顶*/
    func topMessage(message:CODMessageModel)
    
    /*更多*/
    func more()
    
    /*收藏*/
    func collectionMessage(message:CODMessageModel)
    
    /* 举报 */
    func reportOther(message:CODMessageModel, reportType: BalloonActionViewController.ReportType)
    
    func tapAtAll()
}


