//
//  CODDiscoverDetailCommentCellNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/16.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverDetailCommentCellNode: CODCellNode, ASCellNodeDataSourcesType {
    
    var headerNode: CODImageNode!
    
    var nickName: ASButtonNode!
    
    var timeNode: ASTextNode2!
    
    var textNode: CODDiscoverDetailReplyNode!
    
    var bgNode = ASDisplayNode()
    
    var commentCellNodeVM: CODDiscoverDetailCommentCellNodeVM {
        return self.cellVM as! CODDiscoverDetailCommentCellNodeVM
    }
    
    var resendBtn: ASButtonNode?
    
    weak var pageVM: CODDiscoverDetailPageVM?
    
    
    required init(_ cellVM: ASTableViewCellVM) {
        super.init(cellVM)
        
        bgNode.backgroundColor = UIColor(hexString: kVCBgColorS)
        
        headerNode = CODImageHeaderNode(url: commentCellNodeVM.headerUrl)
        
        nickName = ASButtonNode()
        nickName.style.flexShrink = 1
        nickName.titleNode.maximumNumberOfLines = 1
        nickName.setTitle(commentCellNodeVM.nickName, with: UIFont.boldSystemFont(ofSize: 16), with: UIColor(hexString: "#496CB8"), for: .normal)
        
        timeNode = ASTextNode2(text: commentCellNodeVM.time).font(UIFont.systemFont(ofSize: 12)).foregroundColor(UIColor(hexString: "#7C7C7C"))
        
        textNode = CODDiscoverDetailReplyNode(replyModel: commentCellNodeVM.replyModel)
        
        self.selectionStyle = .none
        
        createResendButton()
        
        
    }
    
    func createResendButton() {
        
        
        if commentCellNodeVM.replyModelForDB?.statusEnum == .Failure {
            resendBtn = DiscoverUITools.createResendTipButton()
        } else {
            resendBtn = nil
        }
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        LayoutSpec {
            
            HStackLayout(alignItems: .center) {
                
                if self.indexPath?.row == 0 {
                    ASImageNode(image: UIImage(named: "circle_comment_blue"))
                        .padding(.left, 6)
                        .alignSelf(.start)
                } else {
                    ASLayoutSpec().spacingBefore(26)
                }
                
                headerNode
                    .preferredSize(CGSize(width: 35, height: 35))
                    .padding(.left, 2)
                    .padding(.right, 4)
                    .alignSelf(.start)
                
                
                VStackLayout {
                    
                    HStackLayout(justifyContent: .spaceBetween) {
                        
                        nickName
                        
                        timeNode
                        
                    }
                    .flexShrink(1)
                    .padding(.bottom, 5)
                    
                    textNode.flexShrink(1)
                    
                    resendBtn?.padding(.top, 5)
                    
                }
                .padding(.right, 10)
                .flexGrow(1)
                .flexShrink(1)
                
            }
            .padding(.top, 15)
            .padding(.bottom, 8)
            .background(bgNode)
            .padding(.right, 15)
            .padding(.left, 10)
            .width(constrainedSize.max.width)
            
            
            
            
        }
        
    }
    
    override func didLoad() {
        super.didLoad()
        
        headerNode.addTarget(self, action: #selector(onClickHeader), forControlEvents: .touchUpInside)
        nickName.addTarget(self, action: #selector(onClickHeader), forControlEvents: .touchUpInside)
        //        resendBtn?.addTarget(self, action: #selector(onClickResend), forControlEvents: .touchUpInside)
        
        
        commentCellNodeVM.replyModelForDB?.rx.observe(\.status)
            .skip(1)
            .filterNil()
            .map { CODDiscoverReplyModel.StatusType(rawValue: $0) ?? CODDiscoverReplyModel.StatusType.Sending }
            .distinct()
            .bind(to: self.rx.statusBinder)
            .disposed(by: self.rx.disposeBag)
        
        
        
        
        
        
    }
    
    @objc func onClickResend() {
        
        if let replyModel = CODDiscoverReplyModel.getModel(id: commentCellNodeVM.replyModel.replyId) {
            CirclePublishTool.share.publishReplyWithModel(replyModel: replyModel) { (isSuccess) in

            }
        }
        
        
        
    }
    
    @objc func onClickHeader() {
        
        CustomUtil.pushPersonInfoVC(jid: self.commentCellNodeVM.replyModel.sender?.jid ?? "")
        
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        
        headerNode.view.cornerRadius = headerNode.view.width / 2
        
        if self.indexPath?.section ?? 0 >= 2 {
            bgNode.view.addBorder(toSide: .top, withColor: UIColor(hexString: "#DEDEDE")!)
        }
        
        if self.indexPath?.row ?? 0 >= 1 {
            bgNode.view.addBorder(toSide: .top, withColor: UIColor(hexString: "#DEDEDE")!, offset: UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0))
        }
        
        if let indexPath = self.indexPath, (indexPath.row + 1) == self.pageVM?.dataSource.value.last?.items.count {
            self.bgNode.view.roundCorners([.bottomLeft, .bottomRight], radius: 6)
        }
        
        
    }
    
    func configPageVM(pageVM: Any?, indexPath: IndexPath) {
        self.pageVM = pageVM as? CODDiscoverDetailPageVM
    }
    
    
    func didSelected(pageVM: Any?, cellVM: ASTableViewCellVM, indexPath: IndexPath) {
        
        if commentCellNodeVM.replyModelForDB?.statusEnum == .Failure {
            self.onClickResend()
        } else {
            
            if self.commentCellNodeVM.replyModel.sender?.jid == UserManager.sharedInstance.jid {
                self.pageVM?.comment()
            } else {
                self.pageVM?.comment(replayUser: self.commentCellNodeVM.replyModel.sender?.jid ?? "", replyUserName: self.commentCellNodeVM.nickName)
            }
            
            
        }
        
        
        
    }
    
    
}
