//
//  CustomUtil+StringTool.swift
//  COD
//
//  Created by 1 on 2020/4/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

enum CryptoAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512

    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:      result = kCCHmacAlgMD5
        case .SHA1:     result = kCCHmacAlgSHA1
        case .SHA224:   result = kCCHmacAlgSHA224
        case .SHA256:   result = kCCHmacAlgSHA256
        case .SHA384:   result = kCCHmacAlgSHA384
        case .SHA512:   result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }

    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:      result = CC_MD5_DIGEST_LENGTH
        case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

extension CustomUtil{
    class func iphoneType() ->String {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let platform = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
            return String(cString: ptr)
        }
        
        if platform == "iPhone1,1" { return "iPhone 2G"}
        if platform == "iPhone1,2" { return "iPhone 3G"}
        if platform == "iPhone2,1" { return "iPhone 3GS"}
        if platform == "iPhone3,1" { return "iPhone 4"}
        if platform == "iPhone3,2" { return "iPhone 4"}
        if platform == "iPhone3,3" { return "iPhone 4"}
        if platform == "iPhone4,1" { return "iPhone 4S"}
        if platform == "iPhone5,1" { return "iPhone 5"}
        if platform == "iPhone5,2" { return "iPhone 5"}
        if platform == "iPhone5,3" { return "iPhone 5C"}
        if platform == "iPhone5,4" { return "iPhone 5C"}
        if platform == "iPhone6,1" { return "iPhone 5S"}
        if platform == "iPhone6,2" { return "iPhone 5S"}
        if platform == "iPhone7,1" { return "iPhone 6 Plus"}
        if platform == "iPhone7,2" { return "iPhone 6"}
        if platform == "iPhone8,1" { return "iPhone 6S"}
        if platform == "iPhone8,2" { return "iPhone 6S Plus"}
        if platform == "iPhone8,4" { return "iPhone SE"}
        if platform == "iPhone9,1" { return "iPhone 7"}
        if platform == "iPhone9,2" { return "iPhone 7 Plus"}
        if platform == "iPhone10,1" { return "iPhone 8"}
        if platform == "iPhone10,2" { return "iPhone 8 Plus"}
        if platform == "iPhone10,3" { return "iPhone X"}
        if platform == "iPhone10,4" { return "iPhone 8"}
        if platform == "iPhone10,5" { return "iPhone 8 Plus"}
        if platform == "iPhone10,6" { return "iPhone X"}
        if platform == "iPhone11,2" { return "iPhone XS"}
        if platform == "iPhone11,4" { return "iPhone XS Max (China)"}
        if platform == "iPhone11,6" { return "iPhone XS Max (China)"}
        if platform == "iPhone11,8" { return "iPhone XR"}
        if platform == "iPhone12,1" { return "iPhone 11"}
        if platform == "iPhone12,3" { return "iPhone 11 Pro"}
        if platform == "iPhone12,5" { return "iPhone 11 Pro Max"}
        
        if platform == "iPod1,1" { return "iPod Touch 1G"}
        if platform == "iPod2,1" { return "iPod Touch 2G"}
        if platform == "iPod3,1" { return "iPod Touch 3G"}
        if platform == "iPod4,1" { return "iPod Touch 4G"}
        if platform == "iPod5,1" { return "iPod Touch 5G"}
        if platform == "iPod7,1" { return "iPod Touch 6G"}
        
        if platform == "iPad1,1" { return "iPad 1"}
        if platform == "iPad2,1" { return "iPad 2"}
        if platform == "iPad2,2" { return "iPad 2"}
        if platform == "iPad2,3" { return "iPad 2"}
        if platform == "iPad2,4" { return "iPad 2"}
        if platform == "iPad2,5" { return "iPad Mini 1"}
        if platform == "iPad2,6" { return "iPad Mini 1"}
        if platform == "iPad2,7" { return "iPad Mini 1"}
        if platform == "iPad3,1" { return "iPad 3"}
        if platform == "iPad3,2" { return "iPad 3"}
        if platform == "iPad3,3" { return "iPad 3"}
        if platform == "iPad3,4" { return "iPad 4"}
        if platform == "iPad3,5" { return "iPad 4"}
        if platform == "iPad3,6" { return "iPad 4"}
        if platform == "iPad4,1" { return "iPad Air"}
        if platform == "iPad4,2" { return "iPad Air"}
        if platform == "iPad4,3" { return "iPad Air"}
        if platform == "iPad4,4" { return "iPad Mini 2"}
        if platform == "iPad4,5" { return "iPad Mini 2"}
        if platform == "iPad4,6" { return "iPad Mini 2"}
        if platform == "iPad4,7" { return "iPad Mini 3"}
        if platform == "iPad4,8" { return "iPad Mini 3"}
        if platform == "iPad4,9" { return "iPad Mini 3"}
        if platform == "iPad5,1" { return "iPad Mini 4"}
        if platform == "iPad5,2" { return "iPad Mini 4"}
        if platform == "iPad5,3" { return "iPad Air 2"}
        if platform == "iPad5,4" { return "iPad Air 2"}
        if platform == "iPad6,3" { return "iPad Pro 9.7"}
        if platform == "iPad6,4" { return "iPad Pro 9.7"}
        if platform == "iPad6,7" { return "iPad Pro 12.9"}
        if platform == "iPad6,8" { return "iPad Pro 12.9"}
        if platform == "iPad6,11" { return "iPad 5"}
        if platform == "iPad6,12" { return "iPad 5"}
        if platform == "iPad7,11" { return "iPad 6"}
        if platform == "iPad7,12" { return "iPad 6"}
        if platform == "iPad7,1" { return "iPad Pro 12.9-inch 2"}
        if platform == "iPad7,2" { return "iPad Pro 12.9-inch 2"}
        if platform == "iPad7,3" { return "iPad Pro 10.5-inch"}
        if platform == "iPad7,4" { return "iPad Pro 10.5-inch"}
        
        if platform == "i386"   { return "iPhone Simulator"}
        if platform == "x86_64" { return "iPhone Simulator"}
        
//        self.analyticxXML(iq: <#T##XMPPIQ#>, result: <#T##(NSDictionary, NSDictionary) -> ()#>)
        
        return platform
    }
    /// 字典转json字符串
    ///
    /// - Parameter dict: 字典
    /// - Returns: json字符串
    class func stringWithDictionary(dict : NSDictionary) -> NSString {
        
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString.init(data: jsonData, encoding: String.Encoding.utf8.rawValue)
        let mutStr = NSMutableString.init(string: jsonString!)
    //       mutStr.replaceOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: NSMakeRange(0, (jsonString?.length)!))
    //        mutStr.replaceOccurrences(of: "\n", with: "", options: NSString.CompareOptions.literal, range: NSMakeRange(0, (mutStr.length)))
        return mutStr
    }
        
    class func stringWithDictionaryRTC(dict : NSDictionary) -> NSString {
        
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString.init(data: jsonData, encoding: String.Encoding.utf8.rawValue)
        let mutStr = NSMutableString.init(string: jsonString!)
        return mutStr
    }
        
    /// 根据json字符串返回字典
    ///
    /// - Parameter jsonStr: json字符串
    /// - Returns: 返回字典
    class func dictionaryWithString(jsonStr : NSString) -> NSDictionary{
        if jsonStr.length == 0 {
            return [:];
        }
            
        let jsonData = jsonStr.data(using: String.Encoding.utf8.rawValue)
        let dic = try! JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.mutableContainers)
        return dic as! NSDictionary
    }
    
    class func getFontName() -> String {
//        NSString *path = oft的path;
//        NSURL *fontUrl = [NSURL fileURLWithPath:path];
//        CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)fontUrl);
//        CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataProvider);
//        CGDataProviderRelease(fontDataProvider);
//        CTFontManagerRegisterGraphicsFont(fontRef, NULL);
//        NSString *fontName = CFBridgingRelease(CGFontCopyPostScriptName(fontRef));
        let otfPath = Bundle.main.path(forResource: "sfuitext-italicg", ofType: "otf")
        let fontUrl = URL.init(fileURLWithPath: otfPath!)
        let fontDataProvider = CGDataProvider.init(url: fontUrl as CFURL)
        let fontRef = CGFont.init(fontDataProvider!)
        CTFontManagerRegisterGraphicsFont(fontRef!, nil)
        return fontRef?.postScriptName! as! String
    }
    
    class func getCurrentLanguage() -> String {
        var languageStr = ""
        if (UserDefaults.standard.object(forKey: kMyLanguage) != nil) && (UserDefaults.standard.object(forKey: kMyLanguage) as! String != "") {
            languageStr = (UserDefaults.standard.object(forKey: kMyLanguage) as? String)!
        }else{
            let arr = UserDefaults.standard.object(forKey: "AppleLanguages") as? NSArray
            languageStr = arr?.firstObject as? String ?? ""
            if (languageStr.contains("zh-Hans")) {
                languageStr = "zh-Hans"
            }else if (languageStr.contains("en")) {
                 languageStr = "en"
            }else if (languageStr.contains("zh-Hant")) {
                languageStr = "zh-Hant"
            }else{
                languageStr = "en"
            }
        }

        return languageStr
    }
    
    //链接使用需要拼接语言参数
    class func getLangString() -> String {
        var language = ""
        
        if let languageWithApp = UserDefaults.standard.object(forKey: kMyLanguage) as? String,languageWithApp.count > 0 {
            
            if languageWithApp.contains("zh-Hans"){
                language = "zh"
            }else if languageWithApp.contains("zh-Hant"){
                language = "zht"
            }else{
                language = "en"
            }
            
        }else{
            let arr = UserDefaults.standard.object(forKey: "AppleLanguages") as? NSArray
            let languageStr = arr?.firstObject as? String
            if languageStr?.contains("zh-Hans") ?? false{
                language = "zh"
            }else if languageStr?.contains("zh-Hant") ?? false{
                language = "zht"
            }else{
                language = "en"
            }
        }
        return language
    }
    
    @objc class func formatterStringWithAppName(str:String) -> String {
        
        return String.init(format: NSLocalizedString(str, comment: ""), kApp_Name)
    }
    
    class func getEmojiName(emojiName:String) -> String{
        
        let path = Bundle.main.path(forResource: "EmojiName", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        if let nameDic = try! JSONSerialization.jsonObject(with:data! as Data, options: JSONSerialization.ReadingOptions()) as? Dictionary<String, String> {
            if let nameString: String = nameDic[emojiName]{
                return "[" + nameString + "]"
            }
        }
        return NSLocalizedString("表情", comment: ""         )
    }
    
    class func getBotAttriString(botName: String) -> NSAttributedString {
        let attriStr = NSMutableAttributedString.init(string: " \(botName)")
        
        let textfristAttachment = NSTextAttachment.init()
        let imgH = UIImage(named: "robot_head")
        textfristAttachment.image = imgH
        textfristAttachment.bounds = CGRect(x: 0, y: -2, width: imgH?.size.width ?? 0, height: imgH?.size.height ?? 0)
        let attributedStringH = NSAttributedString.init(attachment: textfristAttachment)
        attriStr.insert(attributedStringH, at: 0)
        
//        let textAttachment = NSTextAttachment.init()
//        let img = UIImage(named: "bot_sign")
//        textAttachment.image = img
//        textAttachment.bounds = CGRect(x: 0, y: 0, width: img?.size.width ?? 0, height: img?.size.height ?? 0)
//        let attributedString = NSAttributedString.init(attachment: textAttachment)
//        attriStr.append(attributedString)
        
        return attriStr
    }
    
    class func getVersionForHeader() -> String {
        
        let versionSplit = kCFBundleShortVersionStringKey.split(separator: ".")
        let version = String(format: "\(versionSplit[0])%02ld", "\(versionSplit[1])".int ?? 0)
        
        return version
        
    }
}

extension String {
    
    /// 是否包含网址，1为包含，0未包含
    func isContainsURL() -> Int {
        
        do{
            let regex = try NSRegularExpression.init(pattern: kRegexURL, options: .caseInsensitive)
            let arrayOfAllMatches = regex.matches(in: self, options: .reportProgress, range: NSRange.init(location: 0, length: self.count))
            if arrayOfAllMatches.count > 0 {
                return 1
            }else{
                return 0
            }
        }catch{
            return 0
        }
    }
    
    func getFirstUrl() -> String {
        do{
            let regex = try NSRegularExpression.init(pattern: kRegexURL, options: .caseInsensitive)
            let arrayOfAllMatches = regex.matches(in: self, options: .reportProgress, range: NSRange.init(location: 0, length: self.count))
            if arrayOfAllMatches.count > 0 {
                let match = arrayOfAllMatches.first
                let str = self as NSString
                return str.substring(with:match!.range)
            }else{
                return " "
            }
        }catch{
            return " "
        }
    }
    
    func getAllUrl() -> [String] {
        do{
            let regex = try NSRegularExpression.init(pattern: kRegexURL, options: .caseInsensitive)
            let arrayOfAllMatches = regex.matches(in: self, options: .reportProgress, range: NSRange.init(location: 0, length: self.count))
            
            var array = Array<String>.init()
            let str = self as NSString
            for match in arrayOfAllMatches {
                array.append(str.substring(with: match.range))
            }
            return array
        }catch{
            return Array<String>.init()
        }
    }
    
    func toUserNameNumber() -> Int {
        
        return self.removingPrefix("cod_").int ?? 0
        
    }
    
    func hmac(algorithm: CryptoAlgorithm, key: String) -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))

        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)

        let digest = stringFromResult(result: result, length: digestLen)
        
        result.deallocate()

        return digest
    }

    private func stringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
        let hash = NSMutableString()
        for i in 0..<length {
            hash.appendFormat("%02x", result[i])
        }
        return String(hash).lowercased()
    }
}
