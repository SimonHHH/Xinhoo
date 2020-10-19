//
//  DiscoverUITools.swift
//  COD
//
//  Created by Sim Tsai on 2020/6/10.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit

struct DiscoverUITools {
    
    static func createResendTipButton() -> ASButtonNode {
        
        let resendBtn = ASButtonNode()
        resendBtn.setImage(UIImage(named: "circle_failure_samll"), for: .normal)
        resendBtn.setTitle(NSLocalizedString("发送失败，轻触以再次发送。", comment: ""), with: UIFont.systemFont(ofSize: 14), with: UIColor(hexString: "#737373"), for: .normal)
        resendBtn.imageAlignment = .beginning
        resendBtn.contentSpacing = 10
        resendBtn.contentHorizontalAlignment = .left
        
        return resendBtn
        
    }
    
    static func createDayAndMonthAttr(_ time: Int) -> NSAttributedString {
        
        let str = NSMutableAttributedString()
        
        let date = Date(milliseconds: time)
        
        let isEnglish = (CustomUtil.getCurrentLanguage() == "en")

        if date.isInToday && isEnglish == false {
            str.yy_appendString("今天")
            str.yy_font = UIFont.boldSystemFont(ofSize: 28)
            str.yy_color = UIColor(hexString: "#1A1A1A")
            return str
        }
        
        if date.isInTomorrow && isEnglish == false {
            str.yy_appendString("昨天")
            str.yy_font = UIFont.boldSystemFont(ofSize: 28)
            str.yy_color = UIColor(hexString: "#1A1A1A")
            return str
        }
        
        str.yy_appendString(String(format: "%02ld ", date.day))
        str.yy_font = UIFont.boldSystemFont(ofSize: 28)
        str.yy_color = UIColor(hexString: "#1A1A1A")

        let month = NSMutableAttributedString(string: NSLocalizedString("\(date.month)\(NSLocalizedString("月", comment: ""))", comment: ""))
        
        month.yy_font = UIFont.boldSystemFont(ofSize: 12)
        month.yy_color = UIColor(hexString: "#1A1A1A")
        
        str.append(month)
        
        return str

        
    }
    
}
