//
//  ChatUITools.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/28.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation


struct ChatUITools {
    
    static func createTimeLab(vm: ChatCellVM, style: XinhooTimeAndReadView.Style = .white) -> XinhooTimeAndReadViewNode {
        
        var nikeName: NSMutableAttributedString? = nil

        let time = NSMutableAttributedString(string: vm.sendTime)
        
        if vm.messageModel.edited > 0 {
            time.yy_insertString(NSLocalizedString("已编辑", comment: "") + "  ", at: 0)
        }
        
        
        time.yy_font = FONTTime
        
        if style == .white {
            time.yy_color = .white
        } else if style == .gray {
            time.yy_color = UIColor(hexString: "#999999")
        } else {
            time.yy_color = UIColor(hexString: "#1F9B00")
        }
        
        
        if vm.model.chatTypeEnum == .channel {
            
            let name = vm.messageModel.n
            
            if name.count > 0 {
                nikeName = NSMutableAttributedString(string: name)
            }
            
            nikeName?.yy_font = time.yy_font
            nikeName?.yy_color = time.yy_color
            
        }
        
        if vm.cellDirection == .right {
            return XinhooTimeAndReadViewNode(messageModel: vm.model, style: style)
        } else {
            return XinhooTimeAndReadViewNode(nikename: nikeName, time: time, status: .unknown, style: style)
        }
        
        
    }
    
    static func createContentLabelNode(node: CODDisplayNode, vm: ChatCellVM, pageVM: CODChatMessageDisplayPageVM, style: XinhooTimeAndReadView.Style = .white) -> CODChatContentLabelNode {
        
        var nikeName: NSMutableAttributedString? = nil

        let sendTime = NSMutableAttributedString(string: vm.sendTime)
        
        sendTime.yy_font = FONTTime
        
        if style == .white {
            sendTime.yy_color = .white
        } else if style == .gray {
            sendTime.yy_color = UIColor(hexString: "#999999")
        } else {
            sendTime.yy_color = UIColor(hexString: "#1F9B00")
        }
        
        var status: XinhooTimeAndReadView.Status = .unknown
        
        if vm.cellDirection == .right {
            if vm.model.statusType == .Succeed && vm.model.isReaded {
                status = .haveRead
            } else if vm.model.statusType == .Succeed && vm.model.isReaded == false {
                status = .sendSuccessful
            } else if vm.model.statusType == .Pending {
                status = .sending
            } else {
                status = .unknown
            }
        }
        
        if vm.model.chatTypeEnum == .channel {
            
            let name = vm.messageModel.n
            
            if name.count > 0 {
                nikeName = NSMutableAttributedString(string: name)
            }
            
            nikeName?.yy_font = sendTime.yy_font
            nikeName?.yy_color = sendTime.yy_color
            
        }
        
        
        
        var text = vm.messageModel.text
        
        if vm.messageModel.type == .file {
            text = vm.messageModel.fileModel?.descriptionFile ?? ""
        }
        
        return CODChatContentLabelNode(content: vm.messageModel.entities.toAttributeText(text: text, onClickTextLink: { [weak pageVM]  (url) in
            
            guard let pageVM = pageVM else { return }
            
            pageVM.cellDidTapedLink(node.getSuperTableViewCell() as! CODBaseChatCell, linkString: url)
            }, onClickMention: { [weak pageVM]  (username) in
                
                guard let pageVM = pageVM else { return }
                
                if vm.model.isGroupChat {
                    pageVM.cellTapAt(jidStr: username, model: vm.model, cell: node.getSuperTableViewCell() as! CODBaseChatCell)
                }
                
            }, onClickPhoneNum: { [weak pageVM] (phone) in
                guard let pageVM = pageVM else { return }
                pageVM.cellDidTapedPhone(node.getSuperTableViewCell() as! CODBaseChatCell, phoneString: phone)
        }), timeAtt: sendTime, nikeName: nikeName, status: status, style: .blue)
        
    }
    
}
