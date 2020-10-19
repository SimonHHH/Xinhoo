//
//  CODEmojiHelper.swift
//  COD
//
//  Created by 1 on 2019/6/11.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODEmojiHelper: NSObject {
    typealias TranscodeSuccessBlock = (_ attributeString:NSMutableAttributedString) -> ()
    //得到图片
    static func getDefaultEmojiImage(with imageName: String) -> UIImage? {
        return UIImage(named:imageName)
    }
    static func height(for font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: 100, height: CGFloat.greatestFiniteMagnitude)
        return "/".boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes:[NSAttributedString.Key.font: font], context: nil).size.height
    }
    //插入新的表情文字 使用这个方法
    static func insertEmoji(for textView: UITextView, defaultEmojiImageName: String, desc: String, complete: (() -> ())? = nil) {
        
        let font = IMChatTextFont
        let emojiAttachment = CODEmojiAttachment()
        emojiAttachment.imageName = defaultEmojiImageName
        emojiAttachment.desc = desc
        emojiAttachment.image = getDefaultEmojiImage(with: defaultEmojiImageName)
        let emojiSize = height(for: font)
        emojiAttachment.bounds = CGRect(x: 0, y: -3, width: emojiSize, height: emojiSize)
        
        textView.textStorage.insert(NSAttributedString(attachment: emojiAttachment), at: textView.selectedRange.location)
        textView.selectedRange = NSRange(location: textView.selectedRange.location + 1, length: textView.selectedRange.length)
        let wholeRange = NSRange(location: 0, length: textView.textStorage.length)
        textView.textStorage.removeAttribute(NSAttributedString.Key.font, range: wholeRange)
        textView.textStorage.addAttributes([NSAttributedString.Key.font: font], range: wholeRange)
        textView.scrollRectToVisible(CGRect(x: 0, y: 0, width: textView.contentSize.width, height: textView.contentSize.height), animated: false)
        complete?()
    }
    
    //表情文本转为富文本
//    static func messageTextTranscode(text:String,fontSize: UIFont = IMChatTextFont,callBlock:@escaping TranscodeSuccessBlock){
//        CCLog("\(text)")
//        ///多线程解析
//        let queue = DispatchQueue(label: "CODQueue", attributes: .concurrent)//定义队列
//        queue.async {
//            //1、创建一个可变的属性字符串
//            let attributeString = NSMutableAttributedString(string: text)
//            attributeString.addAttributes([NSAttributedString.Key.font : fontSize], range:NSRange(location: 0, length: text.count))
//            
//            //2、通过正则表达式来匹配字符串
//            let regex_emoji = "\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"
//            var regular:NSRegularExpression? = nil
//            do {
//                regular = try NSRegularExpression(pattern: regex_emoji, options: NSRegularExpression.Options.caseInsensitive)
//            } catch {
//                DispatchQueue.main.async {
//                    callBlock(attributeString)
//                }
//            }
//            let resultArray = regular?.matches(in: text, options:[], range: NSRange(location: 0, length: text.utf16.count))
//            var imageArray:[NSMutableDictionary] = []
//            for match:NSTextCheckingResult in resultArray! {
//                let range = match.range
//                //获取原来字符对应的值
//                let subStr = (text as NSString).substring(with: range)
//                let group = CODExpressionHelper.sharedHelper().defaultFaceGroup
//                for emoji:CODExpressionModel in group.data! {
//                    if emoji.name == subStr{
//                        let textAttachment = CODEmojiAttachment()
//                        textAttachment.image = UIImage(named: emoji.name!);
//                        textAttachment.imageName =  emoji.name!
//                        textAttachment.desc =  emoji.name!
//                        let emojiSize = height(for: fontSize)
//                        textAttachment.bounds = CGRect(x: 0, y: -3, width: emojiSize, height: emojiSize)
//                        let imageStr = NSAttributedString(attachment: textAttachment)
//                        let imageDic = NSMutableDictionary(capacity: 2)
//                        imageDic["image"] = imageStr
//                        imageDic["range"] = range
//                        imageArray.append(imageDic)
//                    }
//                }
//            }
//            if imageArray.count > 0 {
//                for index in (0...(imageArray.count - 1)).reversed() {
//                    let range = imageArray[index]["range"] as! NSRange
//                    let imageStr = imageArray[index]["image"] as! NSAttributedString
//                    attributeString.replaceCharacters(in: range, with: imageStr)
//                }
//            }
//            DispatchQueue.main.async {
//                callBlock(attributeString)
//            }
//        }
//        
//    }
}
