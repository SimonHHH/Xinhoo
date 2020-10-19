//
//  CODMultipleImageContentNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/28.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport
import SwifterSwift
import RxSwift
import RxCocoa

class CODMultipleImageContentNode: CODChatContentNode {
    
    var imageNode: CODMultipleImageNode!
    
    @_NodeLayout var editNode: CODChatContentLabelNode?
    
    override var contentWidth: CGFloat {
        if vm.model.isCloudDiskMessage || vm.model.chatTypeEnum == .groupChat || vm.model.chatTypeEnum == .channel {
            return (KScreenWidth - 88)
        } else {
            return (KScreenWidth - 70)
        }
    }
    
    
    override init(vm: ChatCellVM, pageVM: CODChatMessageDisplayPageVM) {
        super.init(vm: vm, pageVM: pageVM)
        self.imageNode = CODMultipleImageNode(vm: vm as! Xinhoo_MultipleImageCellVM, pageVM: pageVM)
        self.timeLab.isHidden = !vm.messageModel.text.isEmpty
        
        if vm.messageModel.text.isEmpty == false {
            
            var nikeName: NSMutableAttributedString? = nil
            
            if vm.messageModel.n.count > 0 && vm.messageModel.chatTypeEnum == .channel {
                nikeName = NSMutableAttributedString(string: "\(vm.messageModel.n)")
                nikeName?.yy_color = UIColor(hex: 0x979797)
                nikeName?.yy_font = UIFont.systemFont(ofSize: 11)
            }
            
            let sendTime = NSMutableAttributedString(string: "  \(vm.sendTime)")
            if vm.model.isMeSend && vm.model.chatTypeEnum != .channel && !CustomUtil.getIsCloudMessage(messageModel: vm.messageModel){
                sendTime.yy_color = UIColor(hex: 0x54A044)
            } else {
                sendTime.yy_color = UIColor(hex: 0x979797)
            }

            
            sendTime.yy_font = FONTTime
            
            
            var status: XinhooTimeAndReadView.Status = .unknown
            
            if vm.model.isMeSend && vm.model.chatTypeEnum != .channel {
                
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
            
            if CustomUtil.getIsCloudMessage(messageModel: vm.messageModel) && vm.messageModel.fwn.removeAllSapce.count > 0 {
                status = .unknown
            }
            
            self.editNode = CODChatContentLabelNode(content: vm.messageModel.entities.toAttributeText(text: vm.messageModel.text, onClickTextLink: { [weak self] (url) in
                guard let `self` = self else { return }
                self.pageVM.cellDidTapedLink(self.getSuperTableViewCell() as! CODBaseChatCell, linkString: url)
                }, onClickMention: { [weak self] (username) in
                    guard let `self` = self else { return }
                    if self.vm.model.isGroupChat {
                        self.pageVM.cellTapAt(jidStr: username, model: self.vm.model, cell: self.getSuperTableViewCell() as! CODBaseChatCell)
                    }
                }, onClickPhoneNum: { [weak self] (phone) in
                    guard let `self` = self else { return }
                    self.pageVM.cellDidTapedPhone(self.getSuperTableViewCell() as! CODBaseChatCell, phoneString: phone)
            }), timeAtt: sendTime, nikeName: nikeName, status: status, style: .blue)
            
        }
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        LayoutSpec {
            
            VStackLayout(justifyContent: .center) {
                
                /// 标题，群（人名），频道（频道名）
                if vm.messageModel.chatTypeEnum == .groupChat {
                    
                    if (vm.cellLocation == .top || vm.cellLocation == .only) && vm.cellDirection == .left {
                        self.titleHStackLayout.preferredSize(CGSize(width: self.contentWidth, height: 27))
                    }
                    
                } else if vm.messageModel.chatTypeEnum == .channel || CustomUtil.getIsCloudMessage(messageModel: vm.messageModel) {
                    self.titleHStackLayout
                        .height(27)
                        .maxWidth(self.contentWidth)
                }
                
                /// 转发
                if vm.messageModel.isFw {
                    self.fwLayout
                    .width(self.contentWidth)
                }
                
                if vm.messageModel.text.isEmpty {
                    
                    OverlayLayout(content: {
                        /// 图片
                        self.imageNode
                    }) {
                        ///  时间标签
                        RelativeLayout(horizontalPosition: .end, verticalPosition: .end) {
                            self.createTimeLabLayout()
                        }
                        .padding([.right, .bottom], 6)
                    }
                    
                } else {
                    
                    /// 图片
                    self.imageNode
                    
                    /// 编辑文字描述
                    editNode?
                        .padding(editPadding)
                        .width(self.contentWidth)
                    
                    
                }

                
            }
            
        }
        
    }
    
    var editPadding: UIEdgeInsets {
        
        if vm.cellDirection == .left {
            return UIEdgeInsets(top: 5, left: 10, bottom: 10, right: 5)
        } else {
            return UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 10)
        }
        
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        editNode?.style.width = ASDimension(unit: .points, value: 100)
    }
    
}
