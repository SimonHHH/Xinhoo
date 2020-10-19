//
//  CustomTextView.swift
//  COD
//
//  Created by xinhooo on 2020/4/13.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

extension NSAttributedString {
    
    func toAttributeTextModelList() -> [CODAttributeTextModel] {
        
        var list = [CODAttributeTextModel]()
        let arr = self.getAttributesWithArray()
        for dic in arr{
            if let model = CODAttributeTextModel.deserialize(from: dic) {
                list.append(model)
            }
        }
        
        return list
        
    }
    
    func getAttributesWithArray(isSend: Bool = true) -> Array<Dictionary<String, Any>> {
        
        var array = Array<[String:Any]>()
        
        self.enumerateAttributes(in: NSRange.init(location: 0, length: self.length), options: .longestEffectiveRangeNotRequired) { (dic, range, p) in
            
            
            if let font = dic[.font] as? UIFont{
                
                //获取当前字体是否是粗体
                let bold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
                //获取当前字体是否是斜体
                let italic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
                
                if bold {
                    array.append(["offset":range.location,"length":range.length,"type":"bold"])
                }
                if italic {
                    array.append(["offset":range.location,"length":range.length,"type":"italic"])
                }
            }
            
            if let style = dic[.underlineStyle] as? Int,style == 1 {
                array.append(["offset":range.location,"length":range.length,"type":"underline"])
            }
            
            if let _ = dic[.strikethroughStyle] {
                array.append(["offset":range.location,"length":range.length,"type":"strikethrough"])
            }
            
            if let link = dic[.link] {
                array.append(["offset":range.location,"length":range.length,"type":"text_link","url":"\(link)"])
            }
            
            if let attachment = dic[NSAttributedString.Key(rawValue: "YYTextAttachment")] as? YYTextAttachment {
                if let jid = attachment.userInfo?["jid"] {
  
                    array.append(["offset":range.location,"length":range.length,"type":"text_mention","user":["username":jid]])
                }
            }
            
        }
        
        let pattern_url = kRegexURL
        let regex_url = try! NSRegularExpression(pattern: pattern_url, options: NSRegularExpression.Options(rawValue:0))
        let res_url = regex_url.matches(in: self.string, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, self.length))
        
        let pattern_phone = "(1[3-9])\\d{9}"
        let regex_phone = try! NSRegularExpression(pattern: pattern_phone, options: NSRegularExpression.Options(rawValue:0))
        let res_phone = regex_phone.matches(in: self.string, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, self.length))
        
        for urlRange in res_url {
            
            let inter = array.contains { (dic) -> Bool in
                
                if let offset = dic["offset"] as? Int,let length = dic["length"] as? Int,let type = dic["type"] as? String {
                
                    let text_linkRange = NSRange(location: offset, length: length)
                    
                    if (text_linkRange.intersection(urlRange.range) != nil) && (type == "text_link") {
                        return true
                    }else{
                        return false
                    }
                }else{
                    return false
                }
            }
            if !inter {
                array.append(["offset":urlRange.range.location,"length":urlRange.range.length,"type":"text_link","url":"\(self.attributedSubstring(from: urlRange.range).string)"])
            }
        }
        
        for range in res_phone {
            //遍历所有的手机号码正则结果
            //超链接中是否包含手机号码 默认 false
            var isContainsPhone = false
            for dic in array {
                //遍历所有的富文本结果
                if let offset = dic["offset"] as? Int,let length = dic["length"] as? Int,let type = dic["type"] as? String {
                    let text_linkRange = NSRange(location: offset, length: length)
                    //判断如果当前富文本属性range跟手机号码range有交集，并且服务本属性是text_link，则断定超链接中包含手机号码
                    if range.range.intersection(text_linkRange) != nil && (type == "text_link") {
                        isContainsPhone = true
                    }
                }
            }
            //当超链接中包含手机号码，则不添加手机号码富文本属性（phone_number）
            if !isContainsPhone {
                array.append(["offset":range.range.location,"length":range.range.length,"type":"phone_number"])
            }
        }
        
        return array
    }
    
    func addAttributes(model:CODAttributeTextModel) -> NSMutableAttributedString {
        
        let attribute = NSMutableAttributedString.init(attributedString: self)
        
        let textRange = NSRange(location: 0, length: attribute.length)
        
        let range = NSRange(location: model.offset, length: model.length)
        
        if NSIntersectionRange(textRange, range).length != range.length {
            return attribute
        }
        
        switch model.typeEnum {
        case .bold,.italic:
            attribute.enumerateAttributes(in: range, options: .longestEffectiveRangeNotRequired) { [weak self](dic, range, p) in
                guard self != nil else { return }
                if let font = dic[.font] as? UIFont {
                    //获取当前字体是否是粗体
                    let bold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
                    
                    //获取当前字体是否是斜体
                    let italic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
                    var customFont:UIFont? = nil
                    if (model.typeEnum == .bold && italic) || (model.typeEnum == .italic && bold) {
                        
                         customFont = UIFont.init(descriptor: (font.fontDescriptor.withSymbolicTraits([UIFontDescriptor.SymbolicTraits.traitBold,UIFontDescriptor.SymbolicTraits.traitItalic]))!, size: font.pointSize)
                        
                        
                    }else if model.typeEnum == .bold{
                        
                        customFont = UIFont.boldSystemFont(ofSize: font.pointSize)
                        
                    }else if model.typeEnum == .italic {
                        
                        customFont  = UIFont.italicSystemFont(ofSize: font.pointSize)
                    }
                    attribute.yy_setFont(customFont, range: range)

                }
                
            }
            break
        case .underline:
            attribute.yy_setUnderlineStyle(.single, range: range)
            break
        case .strikethrough:
            let decoration = YYTextDecoration(style: .single, width: nil, color: nil)
            attribute.yy_setTextStrikethrough(decoration, range: range)
            attribute.addAttributes([.strikethroughStyle:NSUnderlineStyle.single.rawValue], range: range)
            break
        case .text_color:
            attribute.yy_setColor(UIColor(hexString: model.color), range: range)
            break
        default:
            break
        }
        return attribute
    }
    
}

class CustomTextView: UITextView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return super.hitTest(point, with: event)
    }
    
    override func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        
        if self.selectedRange.length > 0 || self.text.count == 0, action == #selector(select(_:)) {
            return nil
        }
        
        return super.target(forAction: action, withSender: sender)
        
    }
    
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        

        if self.text.count == 0,action != #selector(paste(_:)) {
            return false
        }
        
        let menuController = UIMenuController.shared
        if var menuItems = menuController.menuItems,
            (menuItems.map { $0.action }).elementsEqual([.toggleBoldface, .toggleItalics, .toggleUnderline]) {
            
            if self.selectedRange.length > 0 {
                menuItems.append(UIMenuItem(title: "删除线", action: .toggleStrikethrough))
                menuController.menuItems = menuItems
                
                menuItems.append(UIMenuItem(title: "链接", action: .linkAction))
                menuController.menuItems = menuItems
            }
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func toggleItalics(_ sender: Any?) {
        let attributeText = NSMutableAttributedString.init(attributedString: self.attributedText)
        let customSlectRange = self.selectedRange
        //查询选中的区域是否有“NSAttributedString.Key.font”的属性
        self.attributedText.enumerateAttribute(NSAttributedString.Key.font, in: selectedRange, options: .longestEffectiveRangeNotRequired) { [weak self](key, range, p) in
            guard let `self` = self else { return }
            if let font = key as? UIFont {
                
                //获取当前字体是否是粗体
                let bold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
                
                //获取当前字体是否是斜体
                let italic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
                if italic {
                    
                    let customFont = bold ? UIFont.boldSystemFont(ofSize: font.pointSize) : UIFont.systemFont(ofSize: font.pointSize)
                    attributeText.addAttributes([.font:customFont], range: range)
                    
                }else{
                    
                    let customFont = bold ? UIFont.init(descriptor: (self.font?.fontDescriptor.withSymbolicTraits([UIFontDescriptor.SymbolicTraits.traitBold,UIFontDescriptor.SymbolicTraits.traitItalic]))!, size: font.pointSize) : UIFont.italicSystemFont(ofSize: font.pointSize)
                    attributeText.addAttributes([.font:customFont], range: range)
                }
                
                self.attributedText = attributeText
            }
        }
        self.selectedRange = customSlectRange
        self.scrollRangeToVisible(self.selectedRange)
    }
    
    override func toggleBoldface(_ sender: Any?) {

        let attributeText = NSMutableAttributedString.init(attributedString: self.attributedText)
        let customSlectRange = self.selectedRange
        //查询选中的区域是否有“NSAttributedString.Key.font”的属性
        self.attributedText.enumerateAttribute(NSAttributedString.Key.font, in: selectedRange, options: .longestEffectiveRangeNotRequired) { [weak self](key, range, p) in
            guard let `self` = self else { return }
            if let font = key as? UIFont {
                
                //获取当前字体是否是粗体
                let bold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
                
                //获取当前字体是否是斜体
                let italic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
                if bold {
                    
                    let customFont = italic ? UIFont.italicSystemFont(ofSize: font.pointSize) : UIFont.systemFont(ofSize: font.pointSize)
                    attributeText.addAttributes([.font:customFont], range: range)
                    
                }else{
                    
                    let customFont = italic ? UIFont.init(descriptor: (self.font?.fontDescriptor.withSymbolicTraits([UIFontDescriptor.SymbolicTraits.traitBold,UIFontDescriptor.SymbolicTraits.traitItalic]))!, size: font.pointSize) : UIFont.boldSystemFont(ofSize: font.pointSize)
                    attributeText.addAttributes([.font:customFont], range: range)
                }
                
                self.attributedText = attributeText
                
            }
        }
        self.selectedRange = customSlectRange
        self.scrollRangeToVisible(self.selectedRange)
    }
    
    override func toggleUnderline(_ sender: Any?) {
        let attributeText = NSMutableAttributedString.init(attributedString: self.attributedText)
        let customSlectRange = self.selectedRange
        attributeText.enumerateAttribute(.underlineStyle, in: selectedRange, options: .longestEffectiveRangeNotRequired) { [weak self](type, range, p) in
            guard let `self` = self else { return }
            if type != nil {
                
                attributeText.removeAttribute(.underlineStyle, range: range)
                
            }else{
                attributeText.addAttributes([.underlineStyle:NSUnderlineStyle.single.rawValue], range: range)
                
            }
            self.attributedText = attributeText
        }
        self.selectedRange = customSlectRange
        self.scrollRangeToVisible(self.selectedRange)
    }
    
    @objc func toggleStrikethrough(_ sender: Any?) {
        
        let attributeText = NSMutableAttributedString.init(attributedString: self.attributedText)
        let customSlectRange = self.selectedRange
        attributeText.enumerateAttribute(.strikethroughStyle, in: selectedRange, options: .longestEffectiveRangeNotRequired) { [weak self](type, range, p) in
            guard let `self` = self else { return }
            if type != nil {
                
                attributeText.removeAttribute(.strikethroughStyle, range: range)
                
            }else{
                attributeText.addAttributes([.strikethroughStyle:NSUnderlineStyle.single.rawValue], range: range)
                
            }
            self.attributedText = attributeText
        }
        self.selectedRange = customSlectRange
        self.scrollRangeToVisible(self.selectedRange)
    }
    
    @objc func linkAction(_ sender: Any?) {
        
        let range = self.selectedRange

        let message = self.text(in: self.selectedTextRange!)

        let alert = UIAlertController(title: "添加链接", message: String(format: NSLocalizedString("此链接将显示为“%@”", comment: ""), message!), preferredStyle: .alert)
        alert.addTextField(text: nil, placeholder: "链接", editingChangedTarget: self, editingChangedSelector: #selector(textEdit(_:)))

        alert.addAction(title: "取消", style: .cancel, isEnabled: true, handler: nil)
        
        alert.addAction(title: "完成", style: .default, isEnabled: false) { [weak self,weak alert](action) in

            guard let `self` = self,let alert = alert else { return }
            
            if let tf = alert.textFields?.first {

                let attributeText = NSMutableAttributedString.init(attributedString: self.attributedText)
                //添加链接的时候，遍历富文本YYTextAttachment属性
                attributeText.enumerateAttribute(NSAttributedString.Key(rawValue: "YYTextAttachment"), in: NSRange(location: 0, length: attributeText.length), options: .longestEffectiveRangeNotRequired) { (key, range1, p) in
                    //如果YYTextAttachment跟当前添加链接的range相交集，则删掉YYTextAttachment属性，已链接为准
                    if range1.intersection(range) != nil {
                        attributeText.removeAttribute(NSAttributedString.Key(rawValue: "YYTextAttachment"), range: range1)
                    }
                }
                attributeText.yy_setLink(URL.init(string: tf.text!), range: range)
                self.attributedText = attributeText
            }

        }
        UIViewController.current()?.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func textEdit(_ sender: UITextField) {
        
        let tf = sender as UITextField
        var resp : UIResponder = tf
        
        while !(resp is UIAlertController) {
            
            guard let nextResp = resp.next else {
                return
            }
            resp = nextResp
        }
        let alert = resp as! UIAlertController
        
        if let text = sender.text,URL.init(string: text) != nil {
            
            (alert.actions[1] as UIAlertAction).isEnabled = true
            
        }else{
            (alert.actions[1] as UIAlertAction).isEnabled = false
        }
    }
    
    override func paste(_ sender: Any?) {
        let pastboard = UIPasteboard.general
        if let pastboardAttri = pastboard.yy_AttributedString {
            
            let attribute = NSMutableAttributedString.init(attributedString: self.attributedText)
            attribute.replaceCharacters(in: self.selectedRange, with: pastboardAttri)
            let typingAttributes = self.typingAttributes
            self.attributedText = attribute
            self.typingAttributes = typingAttributes
            self.changeTextHeight()
            self.changeButtonImage()
            
            let arr = attribute.getAttributesWithArray()
            for dic in arr{
                if let attributeModel = CODAttributeTextModel.deserialize(from: dic) {
                    
                    if attributeModel.typeEnum == .text_mention{
                        self.addMember(jid: attributeModel.user?.username ?? "")
                    }
                }
            }
            
            
        }else{
            super.paste(sender)
        }
    }
    
    func changeTextHeight() {
        if self.superview?.isKind(of: CODChatBar.classForCoder()) ?? false {
            let chatBar = self.superview as! CODChatBar
            chatBar.changeTextViewWithAnimation(animation: false)
        }
    }
    
    func changeButtonImage() {
        if self.superview?.isKind(of: CODChatBar.classForCoder()) ?? false {
            let chatBar = self.superview as! CODChatBar
            chatBar.changeVoiceImage()
        }
    }
    
    func addMember(jid: String) {
        
        if self.superview?.isKind(of: CODChatBar.classForCoder()) ?? false {
            let chatBar = self.superview as! CODChatBar
            
            if jid == kAtAll {
                
                let allMember = CODGroupMemberModel.init()
                allMember.nickname = NSLocalizedString("all", comment: "")
                allMember.jid = kAtAll
                chatBar.memberNotificationArr.append(allMember)
            } else {
                
                if let model = CODGroupMemberRealmTool.getMembersByJid(jid)?.first {
                    chatBar.memberNotificationArr.append(model)
                }
                
            }
            
        }
    }
    
}

fileprivate extension Selector {
    static let toggleBoldface = #selector(CustomTextView.toggleBoldface(_:))
    static let toggleItalics = #selector(CustomTextView.toggleItalics(_:))
    static let toggleUnderline = #selector(CustomTextView.toggleUnderline(_:))
    static let toggleStrikethrough = #selector(CustomTextView.toggleStrikethrough(_:))
    static let linkAction = #selector(CustomTextView.linkAction(_:))
}

