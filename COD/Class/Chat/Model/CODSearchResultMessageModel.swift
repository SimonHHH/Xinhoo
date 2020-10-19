//
//  CODSearchResultMessageModel.swift
//  COD
//
//  Created by XinHoo on 2019/8/19.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODSearchResultMessageModel: Object {
    
    var id = 0
    
    var chatType: CODMessageChatType = .privateChat
    
    var jid = ""
    
    var title = ""
    
    var subTitle = ""
    
    var icon = ""
    
    var lastDateTime = ""
    
    var contact: CODContactModel?
    
    var groupChat: CODGroupChatModel?
    
    var channelChat: CODChannelModel?
    
    var message: CODMessageModel?
    
//    var chatHistory: CODChatHistoryModel?
//    var stickyTop: Bool = false
//    var isAt : Bool = false


}
