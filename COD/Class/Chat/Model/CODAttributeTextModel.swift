//
//  CODAttributeTextModel.swift
//  COD
//
//  Created by xinhooo on 2020/4/13.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import HandyJSON
import RealmSwift

class CODAttributeTextModel: Object,HandyJSON {
    
    enum AttributeType :Int {
        
        case bold = 0
        case italic  = 1
        case underline = 2
        case text_link = 3
        case strikethrough  = 4
        case text_mention  = 5
        case phone_number  = 6
        case text_color  = 7
        case unknown  = -999
    }
    
    @objc dynamic var offset = 0
    @objc dynamic var length = 0
    @objc dynamic var type = ""
    @objc dynamic var url = ""
    @objc dynamic var color = ""
    @objc dynamic var user:AttributeText_User?
    
    var typeEnum:AttributeType  {
        get {
            switch type {
            case "bold":
                return .bold
            case "italic":
                return .italic
            case "underline":
                return .underline
            case "text_link":
                return .text_link
            case "strikethrough":
                return .strikethrough
            case "text_mention":
                return .text_mention
            case "phone_number":
                return .phone_number
            case "text_color":
                return .text_color
            default:
                return .unknown
            }
        }
    }
    
    override static func indexedProperties() -> [String] {
        return ["typeEnum"]
    }
}

class AttributeText_User: Object,HandyJSON {
    @objc dynamic var username = ""
}


extension List where Element: CODAttributeTextModel {
    
    func toArrayJSON() -> [[String : Any]]? {
        
        var entitiesArr = Array<Dictionary<String,Any>>()
        
        self.forEach({ (model) in
            
            if let json = model.toJSON() {
                entitiesArr.append(json)
            }
            
        })
        
        return entitiesArr
        
    }
    
    func hasLink() -> Bool {
        
        for model in self {
            
            if model.typeEnum == .text_link {
                return true
            }
            
        }
        
        return false
        
    }
    
    func toAttributeText(text: String,
                         onClickTextLink: ((_ url: URL) -> ())? = nil,
                         onClickMention: ((_ username: String) -> ())? = nil,
                         onClickPhoneNum: ((_ phoneString: String) -> ())? = nil) -> NSMutableAttributedString {
        
        var attText = NSMutableAttributedString(string: text)
        
        let font = UIFont.systemFont(ofSize: CGFloat(17+(UserDefaults.standard.integer(forKey: kFontSize_Change))))
        attText.yy_font = font
        
        if self.count > 0  {
            for attributeModel in self {
                
                let textRange = NSRange(location: 0, length: attText.length)
                
                let range = NSRange(location: attributeModel.offset, length: attributeModel.length)
                
                if NSIntersectionRange(textRange, range).length != range.length {
                    continue
                }
                
                if attributeModel.typeEnum == .text_link {
                    
                    attText.yy_setLink(attributeModel.url, range: range)
                    
                    attText.yy_setTextHighlight(range, color: UIColor.init(hexString: "#1D49A7"), backgroundColor: UIColor.init(hexString: "#367CDE")?.withAlphaComponent(0.3), tapAction: {  (containerView, text, range, rect) in
                        if let url = URL(string: attributeModel.url) {
                            onClickTextLink?(url)
                        } else {
                            let alert = UIAlertController(title: "无效的链接", message: attributeModel.url, preferredStyle: .alert)
                            alert.addAction(title: "知道了", style: .cancel, isEnabled: true, handler: nil)
                            UIViewController.current()?.present(alert, animated: true, completion: nil)
                        }
                    })
                    
                } else if attributeModel.typeEnum == .text_mention {
                    
                    let attachment = YYTextAttachment.init(content:nil)
                    attachment.userInfo = ["jid":attributeModel.user?.username ?? ""]
                    attText.yy_setTextAttachment(attachment, range: range)
                    
                    attText.yy_setTextHighlight(range, color: UIColor.init(hexString: "#1D49A7"), backgroundColor: UIColor.init(hexString: "#367CDE")?.withAlphaComponent(0.3)) {  (containerView, text, range, rect) in
                        onClickMention?(attributeModel.user?.username ?? "")
                    }
                    
                } else if attributeModel.typeEnum == .phone_number {
                    
                    attText.yy_setTextHighlight(range, color: UIColor.init(hexString: "#1D49A7"), backgroundColor: UIColor.init(hexString: "#367CDE")?.withAlphaComponent(0.3)) {  (containerView, text, range, rect) in
                        
                        let str:NSString = text.string as NSString
                        let targetStr = str.substring(with: range) as String
                        onClickPhoneNum?(targetStr)
                        
                    }
                }else{
                    
                    attText = attText.addAttributes(model: attributeModel)
                }
            }
            

        }
        
        return attText
    }
    
}
