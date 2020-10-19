//
//  CODMultipleImageNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/13.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport
import SwifterSwift
import RxSwift
import RxCocoa


class CODMultipleImageCellNode: CODChatCellNode {
    

    var multipleImageContentNode: CODMultipleImageContentNode!
    let textBackground = ASDisplayNode()
    var imageLayoutElement: ASLayoutSpec!
    

    
    override init(vm: ChatCellVM, pageVM: CODChatMessageDisplayPageVM) {
        super.init(vm: vm, pageVM: pageVM)
        
        self.multipleImageContentNode = CODMultipleImageContentNode(vm: vm, pageVM: pageVM)

        self.textBackground.backgroundColor = UIColor.white
        

    }
    

    override func flashingCell() {
        
        self.multipleImageContentNode.view.alpha = 0.5
        
        UIView.animate(withDuration: 1.0) {
            self.multipleImageContentNode.view.alpha = 1
        }
        
        super.flashingCell()
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        LayoutSpec {
            
            VStackLayout() {
                
                if vm.isFirst {
                    
                    ASTextNode2(text: vm.dateTime)
                    .font(UIFont.boldSystemFont(ofSize: 13))
                    .foregroundColor(.white)
                    .padding([.left, .right], 10)
                    .padding([.top, .bottom], 2)
                    .background(dateTimeBG)
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                    .alignSelf(.center)
                    
                }


                HStackLayout(justifyContent: justifyContent, alignItems: .baselineLast) {
                    
                    if (vm.messageModel.toJID.contains(kCloudJid) && vm.messageModel.fw.removeAllSapce.count > 0) {
                        /// 头像
                        self.headerImageNode
                            .preferredSize(CGSize(width: 38, height: 38))
                            .padding(.left, 3)
                            .padding(.bottom, 8)
                            .padding(.right, 2)
                            .alignSelf(.end)
                    }else if vm.messageModel.chatTypeEnum == .groupChat {
                        
                        /// 头像
                        if vm.model.isMeSend == false {
                            self.headerImageNode
                                .preferredSize(CGSize(width: 38, height: 38))
                                .padding(.left, 3)
                                .padding(.bottom, 8)
                                .padding(.right, 2)
                                .alignSelf(.end)
                        }
                        
                        /// 查看消息接收人列表
//                        if vm.model.isMeSend && pageVM.chatListModel.groupChat!.isICanCheckUserInfo() && vm.model.statusType == .Succeed {
//                            self.messageReadNode
//                                .padding(.right, 6)
//                        }
                                            
                        
                    }
                    
                    
                    /// 消息展示内容
                    OverlayLayout(content: {

                        HStackLayout(justifyContent: justifyContent) {

                            if vm.model.statusType == .Pending && vm.cellDirection == .right {
                                activityIndicatorNode.alignSelf(.center)
                                    .padding(.right, 5)
                            }

                            multipleImageContentNode
                                .padding(.all, 2)
                                .background(backgroundNode)
                        }


                    }) {

                        LayoutSpec {

                            /// 阅后即焚
                            if vm.isBurn == false {

                                if vm.cellDirection == .left {

                                    RelativeLayout(horizontalPosition: .end) {
                                        burnIconNode
                                    }

                                } else {

                                    RelativeLayout() {
                                        burnIconNode
                                    }

                                }

                            }

                        }

                    }

                    /// 重发按钮
                    if vm.model.statusType == .Failed {
                        resendBtn
                            .padding(.right, 3)
                            .alignSelf(.end)
                    }
                    
                    /// 快速转发按钮
                    if vm.model.chatTypeEnum == .channel && (vm.model.statusType != .Failed && vm.model.statusType != .Pending) {
                        
                        fwButton
                            .alignSelf(.end)
                            .padding(.left, 5)
                        
                    }
                    
                    /// 云盘消息跳转原消息按钮
                    if vm.showCloudDiskJumButton {
                        
                        cloudDiskJumpButton
                            .alignSelf(.end)
                            .padding(.left, 5)
                        
                    }
                    
                    /// loading 转圈
                    if vm.model.statusType == .Pending && vm.cellDirection == .left {
                        activityIndicatorNode.alignSelf(.center)
                    }
                    
                }
                .width(cellWidth)
                .padding(.bottom, cellBottomPadding)
                
                
                
            }
            
        }
        
    }
    
    override var cellWidth: CGFloat {
        
        if pageVM.isMultipleSelelct.value {
            return KScreenWidth - 47
        } else {
            return KScreenWidth
        }

    }
     
    
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        
        _ = self.multipleImageContentNode.layoutThatFits(self.multipleImageContentNode.constrainedSizeForCalculatedLayout)
        if vm.cellDirection == .right {
            self.multipleImageContentNode.layer.mask = vm?.createRightImageLayer(size: self.multipleImageContentNode.calculatedSize)
        } else {
            self.multipleImageContentNode.layer.mask = vm?.createLeftImageLayer(size: self.multipleImageContentNode.calculatedSize)
        }
        
        
        
    }
    
    override func didLoad() {
        super.didLoad()
        
        
 
        self.multipleImageContentNode.view.addLongTap { [weak self ] in
            
            guard let `self` = self else { return }
            
            if let cell = self.getSuperTableViewCell() {
                self.pageVM.cellLongPressMessage(cellVM: self.vm, cell, self.view)
            }

        }
        
        
    }
    
    
}


