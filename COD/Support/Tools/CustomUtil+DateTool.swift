//
//  CustomUtil+DateTool.swift
//  COD
//
//  Created by 1 on 2020/4/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

extension CustomUtil{
    
    /// 根据传入的时间计算时间差
    ///
    /// - Parameters:
    ///   - starTime: 开始时间
    ///   - endTime: 结束时间
    /// - Returns: 时间差
    class func getTimeDiff(starTime:NSString,endTime:NSString) -> TimeInterval {
        let startDate:Date = Date.init(timeIntervalSince1970: Double(starTime.longLongValue)/1000.0)
        let endDate:Date = Date.init(timeIntervalSince1970: Double(endTime.longLongValue)/1000.0)
        return endDate.timeIntervalSince(startDate)
    }
    
    
    /// 根据传入时间判断是否是同一天
    ///
    /// - Parameters:
    ///   - starTime: 开始时间
    ///   - endTime: 结束时间
    /// - Returns:  判断结果
    class func isSameDay(starTime:NSString,endTime:NSString) -> Bool {
        let startDate:Date = Date.init(timeIntervalSince1970: Double(starTime.longLongValue)/1000.0)
        let endDate:Date = Date.init(timeIntervalSince1970: Double(endTime.longLongValue)/1000.0)
        let calendar = NSCalendar.current
        let comp1 = calendar.dateComponents([.year,.month,.day], from: startDate)
        let comp2 = calendar.dateComponents([.year,.month,.day], from: endDate)
        return (comp1.day == comp2.day) && (comp1.month == comp2.month) && (comp1.year == comp2.year)
    }
    
    
    /// 根据秒数阅后即焚的描述
    ///
    /// - Parameter burn: 秒数
    /// - Returns: 描述
    class func convertBurnStr(burn: Int) -> (String, Int) {
        switch burn {
        case 0:
            return (NSLocalizedString("关闭", comment: ""),0)
        case 1:
            return (NSLocalizedString("即刻焚烧", comment: ""),1)
        case 10:
            return (NSLocalizedString("10秒", comment: ""),2)
        case 300:
            return (NSLocalizedString("5分钟", comment: ""),3)
        case 3600:
            return (NSLocalizedString("1小时", comment: ""),4)
        case 86400:
            return (NSLocalizedString("24小时", comment: ""),5)
        default:
            return (NSLocalizedString("关闭", comment: ""),6)
        }
    }
    
    class func timeFromChinaSeconds(seconds:Int) -> String {
        
        if seconds > 3600 {
            let hour = String(format: "%ld", seconds/3600)
            let minute = String(format: "%ld", (seconds%3600)/60)
            return "\(hour)时\(minute)分"
        }else if seconds > 60 {
            let minute = String(format: "%ld", seconds/60)
            let seconds = String(format: "%ld", seconds%60)
            return "\(minute)分\(seconds)秒"
        }else{
            let seconds = String(format: "%ld", seconds%60)
            return "\(seconds)秒"
        }
        
    }
    
    class  func transToHourMinSec(time: Float) -> String
      {
          let allTime: Int = Int(time)
          var hours = 0
          var minutes = 0
          var seconds = 0
          var hoursText = ""
          var minutesText = ""
          var secondsText = ""
          
          hours = allTime / 3600
          hoursText = hours > 9 ? "\(hours)" : "0\(hours)"
          
          minutes = allTime / 60
          minutesText = minutes > 9 ? "\(minutes)" : "0\(minutes)"
          
          seconds = allTime % 3600 % 60
          secondsText = seconds > 9 ? "\(seconds)" : "0\(seconds)"
          
          return "\(minutesText):\(secondsText)"
      }
      
      
      /// 判断当前系统是否是12小时制
      ///
      /// - Returns: 是/否
      class func is12Hour() -> Bool{
          let locale = NSLocale.current
          let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale)
          if dateFormat?.range(of: "a") != nil {
              return true
          }else{
              return false
          }
      }
    
      //获取当前的时间并且已经加上了偏移量
      class func getCurrentTime() -> Int {
          return Int(Date.milliseconds)+UserManager.sharedInstance.timeStamp
      }
      
      class func getTimeTampIsSameDay(time1: Int, time2: Int) -> Bool {
          let date1 = Date.init(timeIntervalSince1970:(TimeInterval(time1/1000)))
          let date2 = Date.init(timeIntervalSince1970:(TimeInterval(time2/1000)))
    
          let calendar = Calendar.current
          let comp1 = calendar.dateComponents([.year,.month,.day], from: date1)
          let comp2 = calendar.dateComponents([.year,.month,.day], from: date2)
          
          //开始比较
          if comp1.year == comp2.year && comp1.month == comp2.month && comp1.day == comp2.day {
             return true
          }else {
              return false
          }
      }

}
