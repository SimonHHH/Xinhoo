//
//  CODDiscoverPersonalListHeaderNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/7.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport
import SwiftyJSON

class CODDiscoverPersonalListHeaderNode: CODDiscoverPersonalListCellNode {
    
    enum JIDType {
        case myself
        case friend
        case stranger
    }
    
    var headerNode: CODImageHeaderNode!
    var contactModel: CODContactModel?
    
    var backgroundNode: CODImageNode!
    
    
    required init(pageVM: CODDiscoverPersonalListVCPageVM?, vm: CODDiscoverPersonalListCellVM) {
        super.init(pageVM: pageVM, vm: vm)
        
        if let jid = self.pageVM?.jid {
            DiscoverHttpTools.getMomentBackground(targeter: jid)
        }
        
        if pageVM?.jid != UserManager.sharedInstance.jid {
            contactModel = CODContactRealmTool.getContactByJID(by: pageVM?.jid ?? "")
        }
        
        headerNode = CODImageHeaderNode(url: self.avatar)
        
        backgroundNode = CODImageNode(image: self.backgroundImage)
        
        self.backgroundNode.imageView.contentMode = .scaleAspectFill
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kReloadMomentBackground), object: nil, queue: nil) { [weak self] ( not ) in
            
            guard let `self` = self else { return }
            
            if let jid = not.userInfo?["jid"] as? String,
                let image = not.userInfo?["image"] as? UIImage,
                jid == self.pageVM?.jid {
                
                self.backgroundNode.imageView.image = image

            }

        }
        
        
    }
    
    var jidType: JIDType {
        if pageVM?.jid == UserManager.sharedInstance.jid {
            return .myself
        } else if contactModel != nil {
            return .friend
        } else {
            return .stranger
        }
    }
    
    var avatar: URL? {
        
        var avatar = ""
        
        switch self.jidType {
        case .friend:
            avatar = contactModel?.userpic.getHeaderImageFullPath(imageType: 1) ?? ""
        case .myself:
            avatar = UserManager.sharedInstance.avatar ?? ""
        default:
            break
        }
        
        return URL(string: avatar)
    }
    
    var signtureAttr: NSAttributedString {
        
        var intro = ""
        
        switch self.jidType {
        case .friend:
            intro = contactModel?.about ?? ""
        case .myself:
            intro = UserManager.sharedInstance.intro ?? ""
        default:
            break
        }
        
        let attr = NSMutableAttributedString(string: intro)
        
        attr.yy_color = UIColor(hexString: "#8E8E8E")
        attr.yy_font = UIFont.systemFont(ofSize: 14)
        attr.yy_alignment = .right
        
        
        
        return attr
        
    }
    
    var nickNameAttr: NSAttributedString {
        
        var nickName = ""
        
        switch self.jidType {
        case .friend:
            nickName = contactModel?.getContactNick() ?? ""
        case .myself:
            nickName = UserManager.sharedInstance.nickname ?? ""
        default:
            break
        }
        
        let attr = NSMutableAttributedString(string: nickName)
        attr.yy_color = .white
        attr.yy_font = UIFont.boldSystemFont(ofSize: 16)
        attr.yy_alignment = .right
        
        return attr
        
    }
    
    var backgroundImage: UIImage? {
        
        if let jid = self.pageVM?.jid {
            
            if let image = CODImageCache.default.downloadImageCache?.imageFromCache(forKey: DiscoverTools.getMomentBackgroundImageKey(jid: jid)) {
                return image
            }

        }
        
        
        return UIImage(named: "circle_defult_bg")
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            
            OverlayLayout(content: {
                
                VStackLayout {
                    
                    OverlayLayout(content: {
                        self.backgroundNode
                            .preferredSize(CGSize(width: 375, height: 302.5).screenScale())
                    }) {
                        RelativeLayout(horizontalPosition: .start, verticalPosition: .end, sizingOption: .minimumSize) {
                            ASImageNode(image: UIImage(named: "discover_shadow"))
                                .preferredSize(CGSize(width: 375, height: 69).screenScale())
                        }
                    }
                    .preferredSize(CGSize(width: 375, height: 302.5).screenScale())
                    
                }
                
            }) {
                
                RelativeLayout(horizontalPosition: .start, verticalPosition: .start, sizingOption: .minimumSize) {
                    
                    VStackLayout {
                        
                        HStackLayout(justifyContent: .end, alignItems: .end) {
                            
                            VStackLayout {
                                
                                ASTextNode2(attributedText: self.nickNameAttr)
                                    .lineCount(count: 1)
                                
                                
                                VSpacerLayout(minLength: 29)
                                
                            }
                            .padding([.left, .right], 15)
                            .flexGrow(1)
                            .flexShrink(1)
                            
                            
                            
                            
                            headerNode
                                .preferredSize(CGSize(width: 75, height: 75))
                                .padding(.right, 10)
                            
                        }
                        .width(constrainedSize.max.width)
                        .padding(.top, -55.5)
                        .padding(.left, 15)
                        .padding(.bottom, 8)
                        .flexGrow(1)
                        .flexShrink(1)
                        
                        
                        ASTextNode2(attributedText: self.signtureAttr)
                            .lineCount(count: 2)
                            .padding([.left, .right], 22)
                            .flexShrink(1)
                        
                    }
                    .width(constrainedSize.max.width)
                    .padding(.top, 302.5 * kScreenScale)
                    .flexGrow(1)
                    .flexShrink(1)
                    
                }
                
            }
            
            
            
        }
    }
    
    override func didLoad() {
        super.didLoad()
        
        headerNode.view.cornerRadius = 75 / 2
        headerNode.view.borderWidth = 2
        headerNode.view.borderColor = .white
        
       
        
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
