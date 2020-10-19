//
//  CODDiscoverNotificationButton.swift
//  COD
//
//  Created by Sim Tsai on 2020/6/1.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport
import RxSwift
import RxCocoa

extension Reactive where Base: CODDiscoverNotificationButton {
    
    var spreadMessagePicBinder: Binder<URL?> {
        return Binder(base) { (node, url) in
            node.headerNode?.setImageURL(url)
        }
    }
    
    var spreadMessageCountBinder: Binder<String> {
        return Binder(base) { (node, value) in
            node.titleNode.attributedText = NSMutableAttributedString(string: value)
            node.setNeedsLayout()
        }
    }
    
}

class CODDiscoverNotificationButton: CODControlNode {

    
    let buttonStyle: CODDiscoverNotificationCellVM.Style
    let bgNode = ASDisplayNode()
    
    var headerNode: CODImageHeaderNode? = nil
    var failImageNode: ASImageNode? = nil
    var titleNode: ASTextNode2!

    
    init(style: CODDiscoverNotificationCellVM.Style) {
        
        self.buttonStyle = style
        self.bgNode.backgroundColor = UIColor(hexString: "#333333")
        
        super.init()
        
        switch self.buttonStyle {
        case .fail:
            failImageNode = ASImageNode(image: UIImage(named: "circle_failure"))
            titleNode = ASTextNode2(text: NSLocalizedString(self.buttonStyle.title, comment: ""))
            
        case .normal:
            
            titleNode = ASTextNode2()
            headerNode = CODImageHeaderNode()

        }
        
    }
    
    var leftImageNode: ASLayoutSpec {
        
        switch self.buttonStyle {
        case .normal:
            
            return LayoutSpec {
                headerNode!
                    .preferredSize(CGSize(width: 32, height: 32))
                    .padding(.left, 6)
            }
            
        case .fail:
            
            return LayoutSpec {
                
                HStackLayout {
                    
                    failImageNode!
                    .preferredSize(CGSize(width: 19, height: 19))
                    .padding(.left, 13)
                    
                    HSpacerLayout(minLength: 10)
                    
                }
                
                
                    
            }
            
        }
        
    }
    

    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        
        LayoutSpec {
            
            HStackLayout(justifyContent: .spaceBetween, alignItems: .center) {
                
                self.leftImageNode
                
                self.titleNode.foregroundColor(.white)
                    .font(UIFont.systemFont(ofSize: 14))
                
                HStackLayout {
                    
                    HSpacerLayout(minLength: 10)
                    
                    ASImageNode(image: UIImage(named: "circle_home_arrow"))
                    .preferredSize(CGSize(width: 12, height: 12))
                    .padding(.right, 10)
                    
                }
                
                
                
            }
            .background(bgNode)

            
        }
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        self.bgNode.view.cornerRadius = self.bgNode.view.height / 2
        
        if let headerNode = self.headerNode {
            headerNode.view.cornerRadius = headerNode.view.height  / 2
        }
        
        
        
    }
    
    override func didLoad() {
        super.didLoad()
        
        if buttonStyle.isFail == false {
            
            UserManager.sharedInstance.rx.spreadMessagePic
                .map { URL(string: $0.getHeaderImageFullPath(imageType: 0 )) }
                .bind(to: self.rx.spreadMessagePicBinder)
                .disposed(by: self.rx.disposeBag)
            
            UserManager.sharedInstance.rx.spreadMessageCount
                .map { return "\($0)\(NSLocalizedString("条新消息", comment: ""))" }
                .bind(to: self.rx.spreadMessageCountBinder)
                .disposed(by: self.rx.disposeBag) 
            
        }
        
        

    }
    
}
