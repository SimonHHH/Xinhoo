//
//  CODString+Date.swift
//  COD
//
//  Created by XinHoo on 2019/3/25.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation
import SwifterSwift

extension String{
    
    func getMessageDateString() -> String? {
        var dateStr: String?
        let dateFormatter = DateFormatter()
        
        guard self.count > 0 else {
            return ""
        }
        if self.isIncludeChineseIn(string: self) {
            return self
        }
        let timeInterval = TimeInterval(self.double()!)
        let date = Date(timeIntervalSince1970: timeInterval/1000)
        
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateStr = dateFormatter.string(from: date)
        
        if (date.isInToday) {   //是否今天
            dateFormatter.dateFormat = "HH:mm"
            dateStr = dateFormatter.string(from: date)
            return dateStr
        }else{
            if date.isInCurrentWeek {   //判断是否本周
                return "\(date.week()) \(dateFormatter.string(from: date))"
            }
            
            if date.isInCurrentYear {  //判断是否本年
                dateFormatter.dateFormat = "MM/dd"
                dateStr = dateFormatter.string(from: date)
                return dateStr
            }
            
            dateFormatter.dateFormat = "yyyy/MM/dd"
            dateStr = dateFormatter.string(from: date)
            return dateStr
        }
    }
    
    /**
     *  是否为今年
     */
    func isThisYear(date: Date) -> Bool {
        let calendar = Calendar.current
        let nowCmps = calendar.dateComponents([.year], from: Date())
        let selfCmps = calendar.dateComponents([.year], from: date)
        let result = nowCmps.year == selfCmps.year
        return result
    }

        
    
    func isIncludeChineseIn(string: String) -> Bool {
        
        for (_, value) in string.enumerated() {
            
            if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                return true
            }
        }
        
        return false
    }
 
  
}
