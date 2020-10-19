//
//  NSDate+Extension.swift
//  COD
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

public extension Date {
    static var milliseconds: TimeInterval {
        get { return Date().timeIntervalSince1970 * 1000 }
    }
    
    func shortTimeTextOfDate() ->String {
        let date = self
        var interval = date.timeIntervalSince(Date())
        interval = -interval
        if date.isInToday {
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "aHH:mm"
            dateFormat.amSymbol = ""
            dateFormat.pmSymbol = ""
            return "\(NSLocalizedString("今天", comment: ""))  " + dateFormat.string(from: date)
        }else if date.isInYesterday {
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "aHH:mm"
            dateFormat.amSymbol = ""
            dateFormat.pmSymbol = ""
            return "\(NSLocalizedString("昨天", comment: ""))  " + dateFormat.string(from: date)
        }else {
            if date.isInCurrentYear {
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "dd/MM/yy  HH:mm"
                return dateFormat.string(from: date)
            }else {
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "dd/MM/yy  HH:mm"
                return dateFormat.string(from: date)
            }
        }
        
    }
    
    func week() -> String {
        let myWeekday: Int = (Calendar.current as NSCalendar).components([NSCalendar.Unit.weekday], from: self).weekday!
        switch myWeekday {
        case 1:
            return "周日"
        case 2:
            return "周一"
        case 3:
            return "周二"
        case 4:
            return "周三"
        case 5:
            return "周四"
        case 6:
            return "周五"
        case 7:
            return "周六"
        default:
            break
        }
        return "未取到数据"
    }
    
    static func messageAgoSinceDate(_ date: Date) -> String {
        return self.timeAgoSinceDate(date, numericDates: false)
    }
    
    static func timeAgoSinceDate(_ date: Date, numericDates: Bool) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([
            NSCalendar.Unit.minute,
            NSCalendar.Unit.hour,
            NSCalendar.Unit.day,
            NSCalendar.Unit.weekOfYear,
            NSCalendar.Unit.month,
            NSCalendar.Unit.year,
            NSCalendar.Unit.second
            ], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.year! >= 2) {
            return "\(components.year ?? 0) 年前"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 年前"
            } else {
                return "去年"
            }
        } else if (components.month! >= 2) {
            return "\(components.month ?? 0) 月前"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 个月前"
            } else {
                return "上个月"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear ?? 0) 周前"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 周前"
            } else {
                return "上一周"
            }
        } else if (components.day! >= 2) {
            return "\(components.day ?? 0) 天前"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 天前"
            } else {
                return NSLocalizedString("昨天", comment: "")
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour ?? 0) 小时前"
        } else if (components.hour! >= 1){
            return "1 小时前"
        } else if (components.minute! >= 2) {
            return "\(components.minute ?? 0) 分钟前"
        } else if (components.minute! >= 1){
            return "1 分钟前"
        } else if (components.second! >= 3) {
            return "\(components.second ?? 0) 秒前"
        } else {
            return "刚刚"
        }
    }
    
     func getTimeStamp() -> String{
        //获取当前时间
        let now = NSDate()
        // 创建一个日期格式器
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        print("当前日期时间：\(dformatter.string(from: now as Date))")
        //当前时间的时间戳
        let timeInterval:TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    
    static func getTimeStrForNow() -> String{
        // 创建一个日期格式器
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
        let time = dateformatter.string(from: Date())
        return time
    }
    
    static func getTimeStrForTimeInterval(_ timeInterval: Int) -> String{
        // 创建一个日期格式器
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = Date.init(timeIntervalSince1970: TimeInterval(timeInterval/1000))
        let time = dateformatter.string(from: date)
        return time
    }
    
    // 日期转换,Format默认2019-08-29, 08:08:8
    func dateString(_ format: String = "yyyy-MM-dd, hh:mm a") -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
   
    // 获取几年前的今天的日期
    func beforeYearsByCurrentDate(_ dYears: Int) -> Date? {
        guard let calendar = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.gregorian) else {
            return nil
        }
        
        var dateComponents = DateComponents()
        dateComponents.year = dYears
        
        let newdate = calendar.date(byAdding: dateComponents, to: self, options: NSCalendar.Options.init(rawValue: 0))
        return newdate!
    }
}
