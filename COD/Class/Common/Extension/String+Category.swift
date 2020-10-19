//
//  String+Category.swift
//  COD
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit



extension String {
    
    func addSpaceString() -> String{
        return " " + self + " "
    }
    
    func cod_saltMD5() -> String {
        return "\(self)".md5()
//        return "\(Salt)\(self)".md5()
    }
    
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        free(result)
        return String(format: hash as String)
    }
    /*
     *判断是不是全部都是为空的字符串
     */
    func checkIsAllSapce() -> Bool {
        
        let text:String = self.count > 0 ? self : ""
        
        if  text.count > 0 {
            
            var noSapceString = text.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
            noSapceString = noSapceString.removeHeadAndTailSpacePro
            if noSapceString.count > 0{
                return false
            }
            
        }
        return true
    }
    
    /*
     *去掉首尾空格
     */
    var removeHeadAndTailSpace:String {
        let whitespace = NSCharacterSet.whitespaces
        return self.trimmingCharacters(in: whitespace)
    }
    
//    /*
//     *去掉所有的空格
//     */
    var removeAllNewLineSpace:String {
//        let whitespace = NSCharacterSet.newlines
//        return self.trimmingCharacters(in: whitespace)
        return self.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)

    }
    
    /*
     *将所有的换行替换成空格
     */
    var replaceLineSpaceToSpace:String {

        let stringArray = self.components(separatedBy: "\n")
        var newStringArray = [String]()
        for(index, subString)in stringArray.enumerated(){
            if subString.removeAllNewLineSpace.count > 0 {
                newStringArray.append(subString.removeAllNewLineSpace)
            }else if index == 0  || index == stringArray.count - 1 {
                newStringArray.append("")
            }
        }
        
        return newStringArray.joined(separator: " ")
    }
    
    /*
     *去掉首尾空格 包括后面的换行 \n
     */
    var removeHeadAndTailSpacePro:String {
        let whitespace = NSCharacterSet.whitespacesAndNewlines
        return self.trimmingCharacters(in: whitespace)
    }
    
    /*
     *去掉所有空格
     */
    var removeAllSapce: String {
        // 执行两次是因为两个空格不一样
        return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil).replacingOccurrences(of: " ", with: "", options: .literal, range: nil).removeAllNewLineSpace
    }
    
    /// 不区分大小写的字符串比对判断
    ///
    /// - Parameter str: 被比对的字符串
    /// - Returns: 是否一致
    func compareNoCaseForString(_ str: String) -> Bool {
        if(self.caseInsensitiveCompare(str) == ComparisonResult.orderedSame){
            return true
        }
        return false
    }
 
}
//表情处理
extension String{
//    static func messageTextTranscode(text:String,fontSize: UIFont = IMChatTextFont) ->NSAttributedString{
////        CCLog("\(text)")
//        //1、创建一个可变的属性字符串
//        let attributeString = NSMutableAttributedString(string: text)
//        attributeString.addAttributes([NSAttributedString.Key.font : fontSize], range:NSRange(location: 0, length: text.count))
//        
//        //2、通过正则表达式来匹配字符串
//        let regex_emoji = "\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"
//        var regular:NSRegularExpression? = nil
//        do {
//            regular = try NSRegularExpression(pattern: regex_emoji, options: NSRegularExpression.Options.caseInsensitive)
//        } catch {
//            return attributeString
//        }
//        let resultArray = regular?.matches(in: text, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSRange(location: 0, length: text.count))
//        var imageArray:[NSMutableDictionary] = []
//        for match:NSTextCheckingResult in resultArray! {
//            let range = match.range
//            //获取原来字符对应的值
//            let subStr = text.slicing(from: range.location, length: range.length)
//            let group = CODExpressionHelper.sharedHelper().defaultFaceGroup
//            for emoji:CODExpressionModel in group.data! {
//                if emoji.name == subStr{
//                    let textAttachment = NSTextAttachment()
//                    textAttachment.image = UIImage(named: emoji.name!);
//                    
//                    textAttachment.bounds = CGRect(x: 0, y: -4, width: 22, height: 22)
//                    let imageStr = NSAttributedString(attachment: textAttachment)
//                    let imageDic = NSMutableDictionary(capacity: 2)
//                    imageDic["image"] = imageStr
//                    imageDic["range"] = range
//                    imageArray.append(imageDic)
//                }
//            }
//        }
//        if imageArray.count > 0 {
//            for index in (0...(imageArray.count - 1)).reversed() {
//                let range = imageArray[index]["range"] as! NSRange
//                let imageStr = imageArray[index]["image"] as! NSAttributedString
//                attributeString.replaceCharacters(in: range, with: imageStr)
//            }
//        }
//        return attributeString
//    }
    
    static func textString(attributedText: NSAttributedString) -> String {
        
        let resutlAtt = NSMutableAttributedString.init(attributedString: attributedText)
//        let expressionHelpe = CODExpressionHelper.sharedHelper()
        attributedText.enumerateAttributes(in: NSMakeRange(0, attributedText.length), options: NSAttributedString.EnumerationOptions.reverse) { (attrs, range, stop) in
            if let textAtt = attrs[NSAttributedString.Key.attachment] as? CODEmojiAttachment{
                
                if let image = textAtt.image {
                    let text = textAtt.imageName
                    resutlAtt.replaceCharacters(in: range, with: text)
                }
            }
        }
        return resutlAtt.string
    }
    
    
    /// 截取字符到指定字符位置
    ///
    /// - Parameter string: 指定字符
    /// - Returns: 字符结果
    func subStringTo(string : String) -> String {
        let shouldCutString :NSString = self as NSString
        let rect = shouldCutString.range(of: string)
        if rect.location == NSNotFound {
            return self
        }
        return  shouldCutString.substring(to: rect.location)
    }
    
    
    func subStringToIndex(_ index: Int) -> String {
        let shouldCutString :NSString = self as NSString
        if index < shouldCutString.length {
            return shouldCutString.substring(to: index)
        }else{
            return shouldCutString as String
        }
        
    }
    
    
    func subStringToIndexAppendEllipsis(_ index: Int) -> String {
        
        var str = self
        if index < str.count{
            str = "\(str.slice(from: 0, to: index))..."
        }
        
        return str
    }

}


extension String{
  
    //lineSpacing 没有要求时可以直接给 0
    func getStringHeight(font :UIFont = UIFont.systemFont(ofSize: 16),lineSpacing :CGFloat,fixedWidth :CGFloat) -> CGFloat {
        
        guard (self.count) > 0 && fixedWidth > 0 else {
            
            return 0
        }
        
        let rect = self.getLabelStringSize(font: font,lineSpacing: lineSpacing, fixedWidth: fixedWidth)
        
        return rect.size.height + 2
    }
    
    /*
     *获取label中字符串的宽度
     */
    //lineSpacing 没有要求时可以直接给 0
    func getStringWidth(font :UIFont = UIFont.systemFont(ofSize: 16),lineSpacing :CGFloat,fixedWidth :CGFloat) -> CGFloat {
        
        guard (self.count) > 0 && fixedWidth > 0 else {
            
            return 0
        }
        
        let rect = self.getLabelStringSize(font: font, lineSpacing: lineSpacing, fixedWidth: fixedWidth)
        
        return rect.size.width + 2
    }
    
    //lineSpacing 没有要求时可以直接给 0
    func getLabelStringSize(font :UIFont = UIFont.systemFont(ofSize: 16),lineSpacing :CGFloat,fixedWidth :CGFloat) -> CGRect {
        
        var attrDic:Dictionary<NSAttributedString.Key, Any>?
        if lineSpacing > 0 {
            
            let paragraphStyle =  NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
            paragraphStyle.lineSpacing = lineSpacing
            attrDic = [NSAttributedString.Key.font:font, NSAttributedString.Key.paragraphStyle:paragraphStyle]
        } else {
            
            attrDic = [NSAttributedString.Key.font:font]
        }
        
        let attStr = NSMutableAttributedString.init(string: self, attributes: attrDic)
        let size = CGSize(width:fixedWidth, height:CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let rect = attStr.boundingRect(with: size, options: options,context: nil)
        
        return rect
    }

}

extension String{

    
    //图片
//    func getImageFullPath(imageType: Int) -> String {
//
//        //传0不拼 1-缩略图 2-原图 3-中图片
//        if imageType == 0 {
//            if self.hasPrefix("http"){
//                return self
//            }else{
//                return String(format: "%@/%@",downLoadUrl,self)
//            }
//        }
//
//        if self.removeAllSapce.count > 0 {
//
//            if self.hasSuffix(String(format: "?imgtype=%ld", imageType)){
//                return self
//            }
//            //已经拼接过的图片地址，不需要拼接前面的
//            if self.hasPrefix("http"){
//                return String(format: "%@?imgtype=%ld",self,imageType)
//            }
//            //只有图片的ID
//            return String(format: "%@/%@?imgtype=%ld",downLoadUrl,self,imageType)
//        }
//
//        return ""
//    }
    
   func nsRange(from range: Range<String.Index>) -> NSRange {
     let from = range.lowerBound.samePosition(in: utf16)
     let to = range.upperBound.samePosition(in: utf16)
     return NSRange(location: utf16.distance(from: utf16.startIndex, to: from!),
                    length: utf16.distance(from: from!, to: to!))
    }
    func getImageFullPath(imageType: Int,isCloudDisk: Bool = false) -> String {
        
        var id = self
         
        if let url = URL(string: id) {
            id = url.lastPathComponent
        }
        

        //传0不拼 1-缩略图 2-原图 3-中图片
        switch (imageType, isCloudDisk) {
        case (1, true):
            return ServerUrlTools.getServerUrl(store: .CloudDisk(fileType: .Image(id, .small))).absoluteString
        case (2, true):
            return ServerUrlTools.getServerUrl(store: .CloudDisk(fileType: .Image(id, .origin))).absoluteString
        case (3, true):
            return ServerUrlTools.getServerUrl(store: .CloudDisk(fileType: .Image(id, .medium))).absoluteString
        case (1, false):
            return ServerUrlTools.getServerUrl(store: .Message(fileType: .Image(id, .small))).absoluteString
        case (2, false):
            return ServerUrlTools.getServerUrl(store: .Message(fileType: .Image(id, .origin))).absoluteString
        case (3, false):
            return ServerUrlTools.getServerUrl(store: .Message(fileType: .Image(id, .medium))).absoluteString
        case (_, true):
            return ServerUrlTools.getServerUrl(store: .CloudDisk(fileType: .Image(id, .medium))).absoluteString
        case (_, false):
            return ServerUrlTools.getServerUrl(store: .Message(fileType: .Image(id, .medium))).absoluteString
        }
        
        
    }
//    //头像
//    func getHeaderImageFullPath(imageType: Int) -> String {
//        if self.count <= 0 {
//            return ""
//        }
//        //已经拼接过的图片地址，不需要拼接前面的
//        if imageType == 0 {
//            if self.hasPrefix("http"){
//                return self
//            }else{
//                return String(format: "%@/%@",COD_HeaderPic_DownLoadUrl,self)
//            }
//        }
//        if self.removeAllSapce.count > 0 {
//            if self.hasSuffix(String(format: "?imgtype=%ld", imageType)){
//                return self
//            }
//            //已经拼接过的图片地址，不需要拼接前面的
//            if self.hasPrefix("http"){
//                return String(format: "%@?imgtype=%ld",self,imageType)
//            }
//            //只有图片的ID
//            return String(format: "%@/%@?imgtype=%ld",COD_HeaderPic_DownLoadUrl,self,imageType)
//        }
//        return ""
//    }
    //测试头像
    func getHeaderImageFullPath(imageType: Int) -> String {
        
        
        //传0不拼 1-缩略图 2-原图 3-中图片
        
        var id = self
        
        if let url = URL(string: id) {
            id = url.lastPathComponent
        }
        
        switch imageType {
        case 1:
            return ServerUrlTools.getServerUrl(store: .HeadImage(id: id, imageSize: .small)).absoluteString
        case 2:
            return ServerUrlTools.getServerUrl(store: .HeadImage(id: id, imageSize: .origin)).absoluteString
        case 3:
            return ServerUrlTools.getServerUrl(store: .HeadImage(id: id, imageSize: .medium)).absoluteString
        default:
            return ServerUrlTools.getServerUrl(store: .HeadImage(id: id, imageSize: .small)).absoluteString
        }
    }
}

extension URL {
    
    func getHeaderId() -> String {
        return self.lastPathComponent
    }
    
}

extension String{
    //语音聊天的时候s需要的roomID
    static func randomSmallCaseString(length: Int) -> String {

        return random(ofLength: 32) 
    }
}

extension String{
    
    func getSearchBarPlaceholderWidth(font: UIFont = UIFont.systemFont(ofSize: 17)) -> CGFloat {
        
        let textWidth = self.getStringWidth(font: font, lineSpacing: 0, fixedWidth: KScreenWidth)
        
        return 50 + textWidth
    }
    
    func isEnglishCharactersStar() -> Bool {
        
        let pre = NSPredicate.init(format: "SELF MATCHES %@", "^[A-Za-z]\\w+$")  //判断是否字母开头
        if pre.evaluate(with: self) {
            return true
        }else{
            return false
        }
    }
}
