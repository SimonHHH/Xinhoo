//
//  CODDiscoverDetailCellNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverDetailCellNode: CODDiscoverHomeCellNode {
    
    
    required init(_ cellVM: ASTableViewCellVM) {
        super.init(cellVM)
        
        _ = self.contentNode?.lineCount(count: 0)
        
        self.imageNode?.showImageBrowserBlock = { [weak self] isShow in
            
            self?.detailPageVM?.hiddenKeyboard(hidden: isShow)
            
        }
        
        self.videoNode?.showImageBrowserBlock = { [weak self] isShow in
            
            self?.detailPageVM?.hiddenKeyboard(hidden: isShow)
            
        }
        
        presonalBtnNode?.setTitle("", with: nil, with: nil, for: .normal)
        
    }
    
    weak var detailPageVM: CODDiscoverDetailPageVM?
    
    var detailCellNodeVM: CODDiscoverDetailCellNodeVM {
        return cellVM as! CODDiscoverDetailCellNodeVM
    }
    
    override func onClickLike() {
        
        if self.detailCellNodeVM.isLike {
            detailPageVM?.dislike()
        } else {
            detailPageVM?.like()
        }

    }
    
    override func onClickComment() {
        detailPageVM?.comment(replayUser: "", replyUserName: nil)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        LayoutSpec {
            
            HStackLayout(alignItems: .start) {
                
                /// 头像
                headerNode
                    .padding(.right, 10)
                
                VStackLayout() {
                    
                    /// 昵称
                    nickNameNode
                        .padding(.bottom, 5)
                        .alignSelf(.start)
                    
                    /// 文本
                    contentNode?
                        .padding(.bottom, 10)
                    

                    /// 图片
                    imageNode?
                        .padding(.bottom, 10)
                        .alignSelf(.start)
                    
                    /// 视频
                    videoNode?
                        .padding(.bottom, 10)
                        .alignSelf(.start)
                    
                    /// 提到我
                    atTipNode?
                        .flexShrink(1)
                        .padding(.bottom, 10)

                    
                    HStackLayout(justifyContent: .spaceBetween) {
                        
                        VStackLayout() {
                            
                            /// 定位地址
                            localNode?.padding(.bottom, 8)
                            
                            HStackLayout(spacing: 24, justifyContent: .spaceBetween) {
                                
                                /// 发布时间
                                timeNode
                                
                                /// 私密
                                presonalBtnNode
                                
                                /// 限制谁可见
                                checkLimitNode
                                
                                /// 删除
                                deleteBtnNode
                                
                            }
                            
                            
                        }
                        .alignSelf(.end)
                        
                        HStackLayout(alignItems: .center) {
                            
                            HSpacerLayout(minLength: 0)
                            
                            /// 公开提示
                            openTipTextNode?
                                .padding(.right, 8)
                            
                            if detailPageVM?.pageType.isFail != true {
                                /// 更多功能按钮（点赞/评论）
                                funcBtnNode
                            }

                        }
                        .alignSelf(.start)
                        
                        
                        
                        
                        
                    }
                    .padding(.bottom, 7)
                    
                    
                }
                .flexShrink(1)
                .flexGrow(1)
                
            }
            .padding([.top, .left], 10)
            .padding(.right, 15)
            .width(kScreenWidth)
            
            
            
        }
        
    }
    
    override func configPageVM(pageVM: Any?, indexPath: IndexPath) {
        detailPageVM = pageVM as? CODDiscoverDetailPageVM
    }
    
    override func didLoad() {
        super.didLoad()
        
        deleteBtnNode?.addTarget(self, action: #selector(deleteMessage), forControlEvents: .touchUpInside)
    }
    
    override func deleteMessage() {
        
        detailPageVM?.deleteMessage()
        
    }
    

}
