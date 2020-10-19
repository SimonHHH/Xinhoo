//
//  CODChatFileNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/28.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODChatFileContentNode: CODChatCellNode {
    
    var sizeTextNode: ASTextNode2!
    var timeTextNode: ASButtonNode!
    
    @_NodeLayout var editNode: CODChatContentLabelNode!
    
    override init(vm: ChatCellVM, pageVM: CODChatMessageDisplayPageVM) {
        super.init(vm: vm, pageVM: pageVM)
        
        sizeTextNode = ASTextNode2()
        timeTextNode = ASButtonNode()
        
        sizeTextNode.attributedText = fileVM.sizeAttr
        
        
        editNode = ChatUITools.createContentLabelNode(node: self, vm: vm, pageVM: pageVM, style: .blue)
        
    }
    
    var fileVM: Xinhoo_FileViewModel {
        return self.vm as! Xinhoo_FileViewModel
    }
    
    lazy var timeLab: XinhooTimeAndReadViewNode = {
        
        return ChatUITools.createTimeLab(vm: self.vm, style: .blue)
        
        
    }()
    
    var cellWidth: CGFloat {
        return (KScreenWidth - 60)
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            
            HStackLayout {
                
                HSpacerLayout()
                
                VStackLayout() {
                    
                    if fileVM.isFW {
                        self.fwButton
                    }
                    
                    HStackLayout() {
                        
                        ASImageNode(image: fileVM.iconImage)
                        
                        VStackLayout(justifyContent: .spaceBetween) {
                            
                            ASTextNode2(attributedText: fileVM.fileNameAtt)
                            
                            self.sizeTextNode
                            
                        }
                        .height(36)
                        .alignSelf(.center)
                        .padding(.left, 8)
                        .padding(.right, 14)
                        
                        
                    }
                    
                    if !fileVM.hasText {
                        
                        self.timeLab
                            .padding(.right, 14)
                        
                    } else {
                        editNode.maxWidth(self.cellWidth)
                            .padding(.top, 26)
                    }
                    

                }
                .padding([.right, .left], 10)
                .padding(.bottom, 7)
                .padding(.top, 15)
                .background(self.backgroundNode)
                .maxWidth(self.cellWidth)
                
                
            }
            .width(KScreenWidth)
            
            

        }
        
        
    }

}
