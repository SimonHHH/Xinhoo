//
//  CODDiscoverNewMessageCellNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/18.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverNewMessageCellNode: CODCellNode, ASCellNodeDataSourcesType {
    
    var headerNode: CODImageNode!
    var nickNameNode: ASButtonNode!
    var replyNode: ASTextNode2?
    var timeNode: ASTextNode2!
    
    var textMessageNode: ASTextNode2?
    
    var imageNode: CODImageNode?
    
    var videoNode: CODImageNode?
    
    var likerNode: ASImageNode?
    
    var deleteTipNode: ASTextNode2?
    
    var deleteTipNodeBG: ASDisplayNode!
    
    let rightItemSize = CGSize(width: 60, height: 60)
    
    var vm: CODDiscoverNewMessageCellNodeVM {
        return self.cellVM as! CODDiscoverNewMessageCellNodeVM
    }
    
    
    required init(_ cellVM: ASTableViewCellVM) {
        
        let cellVM: CODDiscoverNewMessageCellNodeVM = cellVM as! CODDiscoverNewMessageCellNodeVM
        
        headerNode = CODImageHeaderNode(url: cellVM.headerUrl)
        headerNode.style.preferredSize = CGSize(width: 47, height: 47)
        
        
        nickNameNode = ASButtonNode()
        nickNameNode.titleNode.maximumNumberOfLines = 1
        nickNameNode.setTitle(cellVM.nickName, with: UIFont.boldSystemFont(ofSize: 14), with: UIColor(hexString: "#007EE5"), for: .normal)
        
        if cellVM.messageType == .comment {
            replyNode = ASTextNode2(attributedText: cellVM.replyAtt)
        } else if cellVM.messageType == .like {
            likerNode = ASImageNode(image: UIImage(named: "circle_like_blue_16"))
        }
        
        
        
        switch cellVM.messageType {
        case .comment:
            replyNode = ASTextNode2(attributedText: cellVM.replyAtt)
        case .like:
            likerNode = ASImageNode(image: UIImage(named: "circle_like_blue_16"))
        case .at:
            replyNode = ASTextNode2(attributedText: cellVM.atAtt)
        }
        
        timeNode = ASTextNode2(text: cellVM.createTime).font(UIFont.systemFont(ofSize: 14)).foregroundColor(UIColor(hexString: "#808080"))
        
        switch cellVM.momentsType {
        case .image:
            if let imageInfo = cellVM.model?.image {
                imageNode = CODImageNode(url: URL(string: ServerUrlTools.getMomentsServerUrl(fileType: .Image(imageInfo.serverImageId, .small))), placeholderImage: UIImage(color: UIColor(hexString: kVCBgColorS)!))
            }
            
        case .video:
            if let videoInfo = cellVM.model?.video {
                videoNode = CODImageNode(url: URL(string: ServerUrlTools.getMomentsServerUrl(fileType: .Image(videoInfo.firstpicId, .small))), placeholderImage: UIImage(color: UIColor(hexString: kVCBgColorS)!))
            }
            
            
        default:
            textMessageNode = ASTextNode2(text: cellVM.model?.content ?? "")
                .font(UIFont.systemFont(ofSize: 14))
                .foregroundColor(UIColor(hexString: "#838383"))
                .lineCount(count: 3)
                .lineSpacing(1)
            
        }
        
        if cellVM.model?.isDelete ?? false {
            
            if cellVM.messageType == .comment {
                
                deleteTipNode = ASTextNode2(text: NSLocalizedString("该评论已删除", comment: ""))
                    .font(UIFont.systemFont(ofSize: 12))
                    .foregroundColor(UIColor(hexString: "#808080"))
                deleteTipNodeBG = ASDisplayNode()
                deleteTipNodeBG.backgroundColor = UIColor(hexString: kVCBgColorS)
                
            }
                        
        }
        
        
    
        
        super.init(cellVM)
        
        self.selectionStyle = .none
        
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        LayoutSpec {
            
            HStackLayout(justifyContent: .spaceBetween) {
                
                HStackLayout(alignItems: .start) {
                    
                    self.headerNode
                        .padding(.left, 10)
                        .padding(.right, 8)
                    
                    VStackLayout(alignItems: .start) {
                        
                        nickNameNode
                            .padding(.bottom, 7)
                        
                        if (vm.model?.isDelete ?? false) && vm.messageType == .comment {
                            
                            
                            deleteTipNode?
                                .padding(UIEdgeInsets(horizontal: 10, vertical: 7))
                                .background(deleteTipNodeBG)
                                
                            
                        } else {
                            
                            replyNode?.padding(.bottom, 2)

                            likerNode?.padding(.bottom, 3)
                            
                        }
                        
                        timeNode
                            .padding(.top, 4)

                    }
                    .padding(.right, 20)
                    .flexShrink(1)
                }
                .flexShrink(1)
                
                textMessageNode?
                    .preferredSize(rightItemSize)

                imageNode?
                    .preferredSize(rightItemSize)
                    .padding(.top, 1)
                
                if vm.momentsType == .video {
                    
                    OverlayLayout(content: {
                        
                        videoNode!
                            .preferredSize(rightItemSize)
                        
                        
                    }) {
                        RelativeLayout(horizontalPosition: .start, verticalPosition: .end, sizingOption: .minimumSize) {
                            ASImageNode(image: UIImage(named: "circle_video"))
                                .preferredSize(CGSize(width: 20, height: 16))
                        }
                        .padding(.left, 3)
                        .padding(.bottom, 2)
                    }
                    .padding(.top, 1)
                    .preferredSize(rightItemSize)
                    

                }
                

            }
            .padding(.top, 9)
            .padding(.right, 10)
            .padding(.bottom, 5)

        }
    }
    
    override func didLoad() {
        super.didLoad()
        
        
        headerNode.addTarget(self, action: #selector(gotoPersionInfo), forControlEvents: .touchUpInside)
        nickNameNode.addTarget(self, action: #selector(gotoPersionInfo), forControlEvents: .touchUpInside)
        
        headerNode.view.cornerRadius = 47/2
        
        self.view.addBorder(toSide: .bottom, withColor: UIColor(hexString: "#E5E5E5")!, borderWidth: 0.5, offset: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        
        if deleteTipNodeBG != nil {
            deleteTipNodeBG.view.cornerRadius = 2
        }

    }
    
    @objc func gotoPersionInfo() {
        
        CustomUtil.pushPersonInfoVC(jid: vm.model?.sender?.jid ?? "")
        
    }
    
    func didSelected(pageVM: Any?, cellVM: ASTableViewCellVM, indexPath: IndexPath) {
        
        
        CODProgressHUD.showWithStatus(nil)
        DiscoverHttpTools.getMoments(id: vm.model?.momentsId ?? "") {  (response) in
            

            CODProgressHUD.dismiss()
            
            guard let value = response.value else {
                CODAlertView_show(NSLocalizedString("该内容已不可见", comment: ""))
                return
            }
            
            if value.momentsStatus == .delete {
                CODAlertView_show(NSLocalizedString("该内容已不可见", comment: ""))
                return
            }
            
            if let model = CODDiscoverMessageModel.getModel(serverMsgId: value.momentsId.string) {
                let vc = CODDiscoverDetailVC(pageType: .normal(momentsId: model.msgId))
                UIViewController.current()?.navigationController?.pushViewController(vc)
                
            }

        }
        

    }
    
    
}
