//
//  CODDiscoverReplyNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverReplyNode: YYLabelNode {
    
    var replyModel: CODDiscoverReplyModel!
    
    var indexPath: IndexPath?
    
    var pageVM: CODDiscoverHomePageVM?
    
    var replyCloser: ((String,String?) -> Void)? = nil
    
    var resendBtn: ASButtonNode?

    convenience init(replyModel: CODDiscoverReplyModel, indexPath: IndexPath?, pageVM: CODDiscoverHomePageVM?) {
        
        self.init()
        
        guard let sender = replyModel.sender?.name else {
            return
        }
        
        self.indexPath = indexPath
        self.pageVM = pageVM
        
        let att = NSMutableAttributedString()
        let font = UIFont.systemFont(ofSize: 15)
        
        let nikename = self.createClickAttributedString(text: sender, #selector(onClickSender))

        att.append(nikename)
        

        if let replyWho = replyModel.replyWho?.name {
            
            let temp = NSMutableAttributedString(string: NSLocalizedString("discover.reply", comment: ""))
            temp.yy_font = font
            temp.yy_color = .black
            
            
            let replyWhoAtt = self.createClickAttributedString(text: replyWho, #selector(onClickReplyer))

            att.append(temp)
            att.append(replyWhoAtt)
            
        }
        
        let temp = NSMutableAttributedString(string: "：")
        temp.yy_font = font
        temp.yy_color = .black
        
        att.append(temp)
        
        let contect = NSMutableAttributedString(string: replyModel.text)
        contect.yy_font = font
        contect.yy_color = .black
        
        att.append(contect)
        att.yy_lineSpacing = 2
        
        self.attributedText = att
        
        self.replyModel = replyModel
        _ = self.lineCount(count: 0)
        
        if replyModel.statusEnum == .Failure {
            resendBtn = DiscoverUITools.createResendTipButton()
        }

        NotificationCenter.default.rx.notification(UIMenuController.willHideMenuNotification).bind { [weak self] (_) in
            guard let `self` = self else { return }
            self.view.backgroundColor = UIColor(hexString: kVCBgColorS)
        }
        .disposed(by: self.rx.disposeBag)


    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        var size = CGSize.zero

        dispatch_sync_safely_to_main_queue {
            
            size = self.yyLabel.sizeThatFits(CGSize(width: constrainedSize.max.width, height: CGFloat.greatestFiniteMagnitude))
            self.node.style.preferredSize = size

        }
        
        let layout = ASWrapperLayoutSpec(layoutElement: self.node)
        
        layout.style.preferredSize = size
        
        return LayoutSpec {
            
            VStackLayout {
                
                layout
                    .padding([.top, .bottom], 6)
                
                resendBtn?
                    .padding([.top, .bottom], 6)

            }
            .padding([.left, .right], 8)
            
            
            
        }
        
    }
    
    override func didLoad() {
        super.didLoad()
        
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandle(_:)))
        
        self.view.addGestureRecognizer(longPress)
        
        self.view.addTap { [weak self] in
            print("tap")
            
            guard let `self` = self else { return }
            
            if self.replyModel.isMeSend {
                return
            }
            
            self.view.backgroundColor = UIColor(hexString: "#cbcbcb")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300)) {
                self.view.backgroundColor = UIColor(hexString: kVCBgColorS)
            }
            
            self.replyCloser?(self.replyModel.sender?.jid ?? "",self.replyModel.sender?.name)
            
        }
        
        resendBtn?.addTarget(self, action: #selector(onClickResend), forControlEvents: .touchUpInside)
        
    }
    
    @objc func longPressHandle(_ gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .began {
            self.view.backgroundColor = UIColor(hexString: "#cbcbcb")
            
            let menuController = UIMenuController.shared

            self.view.becomeFirstResponder()

            let copyMenuItem = UIMenuItem(title: NSLocalizedString("复制", comment: ""), action: #selector(self.copyTapped))
            let deleteMenuItem = UIMenuItem(title: NSLocalizedString("删除", comment: ""), action: #selector(self.deleteTapped))
            
            if self.replyModel.isMeSend {
                menuController.menuItems = [copyMenuItem, deleteMenuItem]
            } else {
                menuController.menuItems = [copyMenuItem]
            }

            menuController.setTargetRect(self.view.frame, in: self.view.superview!)
            menuController.setMenuVisible(true, animated:true)
            
        }

    }
    
    func createClickAttributedString(text: String, _ selector: Selector) -> NSMutableAttributedString {
        
        let font = UIFont.boldSystemFont(ofSize: 15)
        var att: NSMutableAttributedString!
        dispatch_sync_safely_to_main_queue {
            let button = UIButton()
            button.setTitle(text, for: .normal)
            button.titleLabel?.font = font
            button.setTitleColor(UIColor(hexString: "#496CB8"), for: .normal)
            button.size = button.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 14))
            button.height = 16
            att = NSMutableAttributedString.yy_attachmentString(withContent: button, contentMode: .bottom, attachmentSize: button.size, alignTo: font, alignment: .center)
            
            button.addTarget(self, action: selector, for: .touchUpInside)
        }
        
        return att
        
    }
    
    @objc func onClickSender() {
        
        self.pageVM?.goToPersonInfo(jid: self.replyModel.sender?.jid ?? "")
        
        print("\(self.replyModel.sender?.name ?? "")")
        
    }
    
    @objc func onClickReplyer() {
        self.pageVM?.goToPersonInfo(jid: self.replyModel.replyWho?.jid ?? "")
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    @objc func copyTapped() {
        
        UIPasteboard.general.string = self.replyModel.text
        
    }
    
    @objc func deleteTapped() {
        
        guard let indexPath = self.indexPath else {
            return
        }
        
        self.pageVM?.deleteComment(indexPath: indexPath, messageId: self.replyModel.serverId)
        
    }
    
    @objc func onClickResend() {
        
        if let model = CODDiscoverReplyModel.getModel(id: self.replyModel.replyId) {
            CirclePublishTool.share.publishReplyWithModel(replyModel: model) { (isSuccess) in

            }
        }
        
        
        
    }

}
