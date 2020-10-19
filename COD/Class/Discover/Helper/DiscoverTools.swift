//
//  DiscoverTools.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/10.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation


struct DiscoverTools {
    
    
    /**
    1-59分钟显示：XX分钟前
    昨天之前显示：x小时前
    隔天显示：昨天
    其他显示：X天前
    */
    static func toTimeString(_ time: Int) -> String {
        return self._toTimeString(time, Date.milliseconds.int)
    }
    
    static func isYesterday(_ time: Int, _ curTime: Int) -> Bool {
        
        let date = Date(milliseconds: curTime)
        let oldDate = Date(milliseconds: time)
        
        let beginOldDate = oldDate.beginning(of: .day) ?? oldDate
        let beginNewDate = date.beginning(of: .day) ?? date
        var isYesterday = false
        
        let days = beginNewDate.daysSince(beginOldDate)
        
        if days >= 1 && days < 2 {
            isYesterday = true
        }
        
        return isYesterday
        
    }
    
    static func _toTimeString(_ time: Int, _ curTime: Int) -> String {
        
        
        let date = Date(milliseconds: curTime)
        let oldDate = Date(milliseconds: time)
        
        var afterDays = date.daysSince(oldDate)
        let afterHours = date.hoursSince(oldDate)
        
        let beginOldDate = oldDate.beginning(of: .day) ?? oldDate


        if afterHours >= 24 && isYesterday(time, curTime) {
            return NSLocalizedString("昨天", comment: "")
        }
        
        var afterMinutes = date.minutesSince(oldDate)
        
        if afterMinutes < 1 {
            afterMinutes = 1
        }
        
        if afterMinutes < 60 {
            return "\(afterMinutes.int)\(NSLocalizedString("分钟前", comment: ""))"
        }
        
        
        afterDays = date.daysSince(beginOldDate)
        

        if afterDays > 1 && afterHours > 24 {
            return "\(afterDays.int)\(NSLocalizedString("天前", comment: ""))"
        }
        
        var hour = date.hoursSince(oldDate)
        
        if hour < 1 {
            hour = 1
        }
        
        
        return "\(hour.int)\(NSLocalizedString("小时前", comment: ""))"
        
    }
    
    static func toImageBrowserString(_ systemTime: Int = Date.milliseconds.int, time: Int) -> String {
        
        let isToday = DiscoverTools.isSameDay(systemTime, time)
        let isYesterday = DiscoverTools.isYesterday(time, systemTime)
        let date = Date(milliseconds: time, region: .local)
        let systemDate = Date(milliseconds: systemTime)
        
        if isToday {
            
            let hours = systemDate.hoursSince(date)
            
            if hours <= 1 {
                
                var minutes = systemDate.minutesSince(date).int
                minutes = minutes <= 0 ? 1 : minutes
                
                return minutes.string + "\(NSLocalizedString("分钟前", comment: ""))"
                
            } else {
                if CustomUtil.getCurrentLanguage() == "en" {
                    return date.dateString("hh:mm a")
                } else {
                    return DiscoverTools.chineseDateString(date, "hh:mm a")
                }
            }
            
        }
        
        if isYesterday {
            
            if CustomUtil.getCurrentLanguage() == "en" {
                return NSLocalizedString("昨天", comment: "") + " " + date.dateString("hh:mm a")
            } else {
                return NSLocalizedString("昨天", comment: "") + " " + DiscoverTools.chineseDateString(date, "a hh:mm")
            }
            
             
        }
        
        if CustomUtil.getCurrentLanguage() == "en" {
            return date.dateString("yyyy-MM-dd hh:mm a")
        } else {
            return date.dateString("yyyy年MM月dd日 hh:mm a")
        }

        
        
    }
    
    static func chineseDateString(_ date: Date, _ format: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.pmSymbol = "下午"
        dateFormatter.amSymbol = "上午"
        
        return dateFormatter.string(from: date)

    }
    
    static func toNewMessageTimeString(_ time: Int) -> String {
        
        
        let date = Date(milliseconds: time)
        

        if date.isInToday {
            return date.dateString("HH:mm")
        }
        
        
        /// X月X日 X时：X分
        if date.isInCurrentYear {
            return date.dateString("MM/dd, HH:mm")
        }
        
        return date.dateString("MM/dd/yyyy, HH:mm")
        
    }
    
    static func isSameDay(_ time1: Int, _ time2: Int) -> Bool {
        
        let date1 = Date(milliseconds: time1)
        let date2 = Date(milliseconds: time2)
        
        let beginning1 = date1.beginning(of: .day)
        let beginning2 = date2.beginning(of: .day)
        
        return beginning1?.day == beginning2?.day && beginning1?.year == beginning2?.year && beginning1?.month == beginning2?.month
        

    }
    
    static func isSameYear(_ time1: Int, _ time2: Int) -> Bool {
        
        let date1 = Date(milliseconds: time1)
        let date2 = Date(milliseconds: time2)
        
        return date1.beginning(of: .day)?.year == date2.beginning(of: .day)?.year

    }
    
    static func _isInYear(_ systemDate: Date, _ time: Int) -> Bool {
        return Calendar.current.isDate(Date(milliseconds: time), equalTo: systemDate, toGranularity: .year)
    }
    
    
    static func isInYear(_ time: Int) -> Bool {
        return self._isInYear(Date(), time)
    }
    
    static func openDiscoverPublishPage() {
        
        let vc = Xinhoo_DiscoverPublishViewController(nibName: "Xinhoo_DiscoverPublishViewController", bundle: Bundle.main)
        let nav = BaseNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        UIViewController.current()?.present(nav, animated: true)
        
    }
    
    static func downloadMomentBackground(jid: String, url: URL?) {
        
        SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil) { (image, _, _, _, _, _) in
            
            if let image = image {
                saveMomentBackground(jid: jid, image)
            }
            
        }
        
        
    }

    
    static func saveMomentBackground(jid: String = UserManager.sharedInstance.jid, _ image: UIImage, imageName: String? = nil) {
        
        if let newImage = image.sd_resizedImage(with: CGSize(width: (kScreenScale * 375) * 2, height: (kScreenScale * 350) * 2), scaleMode: .aspectFill) {
            
            CODImageCache.default.downloadImageCache?.store(newImage, forKey: DiscoverTools.getMomentBackgroundImageKey(jid: jid), toDisk: true, completion: nil)
            
        }
        
        if let imageName = imageName, let imageIndex = imageName.replacingOccurrences(of: "cover_", with: "").int {
            UserManager.sharedInstance.chooseGoodWork = imageIndex
        }
        
        if let backgroundImage = CODImageCache.default.downloadImageCache?.imageFromDiskCache(forKey: DiscoverTools.getMomentBackgroundImageKey(jid: jid)) {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadMomentBackground), object: nil, userInfo: [
                "jid": jid,
                "image": backgroundImage
            ])
            
        }
        

    }
    
    static func getMomentBackgroundImageKey(jid: String = UserManager.sharedInstance.jid) -> String {
        
        return jid + "_Discover"
        
    }

}
