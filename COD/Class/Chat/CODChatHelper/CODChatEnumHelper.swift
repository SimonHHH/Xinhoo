//
//  CODChatEnumHelper.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

enum CODChatBarStatus:Int {
    case CODChatBarStatusInit = 0 ///初始化
    case CODChatBarStatusVoice ///语音
    case CODChatBarStatusEmoji ///表情
    case CODChatBarStatusMore ///更多
    case CODChatBarStatusKeyboard ///文字键盘
    case CODChatBarStatusEditing///正在输入文字
}

enum CODRecordStatus:Int {
    case CODRecorderStatusRecording ///开始录音
    case CODRecorderStatusWillCancel ///取消录音
    case CODRecorderStatusCountDown ///倒计时录音时间
    case CODRecorderStatusTooShort ///录音太短
}

enum CODGroupControlSendButtonStatus:Int {
    case CODGroupControlSendButtonStatusGray
    case CODGroupControlSendButtonStatusBlue
    case CODGroupControlSendButtonStatusNone
    
}
///表情的类型
enum CODEmojiType:Int{
    case CODEmojiTypeEmoji
    case CODEmojiTypeFace
    case CODEmojiTypeImage ///带图片的表情
    case CODEmojiTypeImageWithTitle ///带图片文字的表情
    case CODEmojiTypeOther ///其他表情
}

///更多的类型
enum CODMoreKeyboardItemType:Int{
    case CODMoreKeyboardItemTypeImage
    case CODMoreKeyboardItemTypeCamera
    case CODMoreKeyboardItemTypeVideo
    case CODMoreKeyboardItemTypeVoiceCall
    case CODMoreKeyboardItemTypeVideoCall
    case CODMoreKeyboardItemTypeWallet
    case CODMoreKeyboardItemTypeTransfer
    case CODMoreKeyboardItemTypePosition
    case CODMoreKeyboardItemTypeFavorite
    case CODMoreKeyboardItemTypeBusinessCard
    case CODMoreKeyboardItemTypeVoice
    case CODMoreKeyboardItemTypeCards
    case CODMoreKeyboardItemTypeFile
    case CODMoreKeyboardItemTypeCloudDisk

}

///会话的类型
enum CODConversationType:Int{
    case CODConversationTypeChat ///单人
    case CODConversationGroupChat ///群组织
    case CODConversationTypeChatRoom ///聊天室
}

//播放的类型
enum CODPlayerStatusType:Int{
    case CODPlayerStatusSuccess ///成功
    case CODPlayerStatusError   ///失败
    case CODPlayerStatusUnknow ///未知错误
}

