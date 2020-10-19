//
//  TimeTool.m
//  COD
//
//  Created by xinhooo on 2019/3/25.
//  Copyright © 2019 xinhoo. All rights reserved.
//

#import "TimeTool.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@implementation TimeTool

// 仿照微信的逻辑，显示一个人性化的时间字串

+ (NSString*)getTimeStringAutoShort2:(NSDate*)dt mustIncludeTime:(BOOL)includeTime theOffSetMS:(NSInteger)offSetMS{
    
    NSString*ret = nil;
    
    NSCalendar*calendar = [NSCalendar currentCalendar];
    
    // 当前时间
    
    NSDate*currentDate = [NSDate dateWithTimeIntervalSinceNow:offSetMS/1000];
    
    NSDateComponents*curComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitWeekOfYear fromDate:currentDate];
    
    NSInteger currentYear=[curComponents year];
    
    NSInteger currentMonth=[curComponents month];
    
    NSInteger currentDay=[curComponents day];
    
    NSInteger currentWeek = [curComponents weekOfYear];
    
    // 目标判断时间
    
    NSDateComponents*srcComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitWeekOfYear fromDate:dt];
    
    NSInteger srcYear=[srcComponents year];
    
    NSInteger srcMonth=[srcComponents month];
    
    NSInteger srcDay=[srcComponents day];
    
    NSInteger srcWeek = [srcComponents weekOfYear];
    
    // 要额外显示的时间分钟
    
    NSString*timeExtraStr = (includeTime?[TimeTool getTimeString:dt format:@" hh:mm a"]:@"");
    
    // 当年
    
    if(currentYear == srcYear) {
        
        long currentTimestamp = [TimeTool getIOSTimeStamp_l:currentDate];
        
        long srcTimestamp = [TimeTool getIOSTimeStamp_l:dt];
        
        // 相差时间（单位：秒）
        
        long delta = currentTimestamp - srcTimestamp;
        
        // 当天（月份和日期一致才是）
        
        if((currentMonth == srcMonth) && (currentDay == srcDay)) {
            
            // 时间相差60秒以内
            
            if(delta < 60)
                
                ret = [TimeTool getTimeString:dt format:@"hh:mm a"];
            
            // 否则当天其它时间段的，直接显示“时:分”的形式
            
            else
                
                ret = [TimeTool getTimeString:dt format:@"hh:mm a"];
            
        }
        
        // 当年 && 当天之外的时间（即昨天及以前的时间）
        
        else{
            
            // 昨天（以“现在”的时候为基准-1天）
            
            NSDate*yesterdayDate = [NSDate dateWithTimeIntervalSinceNow:offSetMS/1000];
            
            yesterdayDate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:yesterdayDate];
            
            NSDateComponents*yesterdayComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:yesterdayDate];
            
            NSInteger yesterdayMonth=[yesterdayComponents month];
            
            NSInteger yesterdayDay=[yesterdayComponents day];
            
            // 前天（以“现在”的时候为基准-2天）
            
            NSDate*beforeYesterdayDate = [NSDate dateWithTimeIntervalSinceNow:offSetMS/1000];
            
            beforeYesterdayDate = [NSDate dateWithTimeInterval:-48*60*60 sinceDate:beforeYesterdayDate];
            
            NSDateComponents*beforeYesterdayComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:beforeYesterdayDate];
            
            NSInteger beforeYesterdayMonth=[beforeYesterdayComponents month];
            
            NSInteger beforeYesterdayDay=[beforeYesterdayComponents day];
            
            // 用目标日期的“月”和“天”跟上方计算出来的“昨天”进行比较，是最为准确的（如果用时间戳差值
            
            // 的形式，是不准确的，比如：现在时刻是2019年02月22日1:00、而srcDate是2019年02月21日23:00，
            
            // 这两者间只相差2小时，直接用“delta/3600” > 24小时来判断是否昨天，就完全是扯蛋的逻辑了）
            
            if(srcMonth == yesterdayMonth && srcDay == yesterdayDay)
                
                ret = [NSString stringWithFormat:@"昨天%@", [TimeTool getTimeString:dt format:@" hh:mm a"]];// -1d
            
            // “前天”判断逻辑同上
            
//            else if(srcMonth == beforeYesterdayMonth && srcDay == beforeYesterdayDay)
//
//            ret = [NSString stringWithFormat:@"前天%@", timeExtraStr];// -2d
            
            else{
                
                // 跟当前时间相差的小时数
                
                long deltaHour = (delta/3600);
                
                
                
                // 如果小于或等 7*24小时就显示周几
                
                if(deltaHour <= 7*24 && currentWeek == srcWeek){
                    
                    NSArray<NSString*> *weekdayAry = [NSArray arrayWithObjects:@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
                    
                    // 取出的周数：1表示周天，2表示周一，3表示周二。。。。 6表示周五，7表示周六
                    
                    NSInteger srcWeekday=[srcComponents weekday];
                    
                    // 取出当前是周几
                    
                    NSString*weedayDesc = [weekdayAry objectAtIndex:(srcWeekday-1)];
                    
                    ret = [NSString stringWithFormat:@"%@%@", weedayDesc, timeExtraStr];
                    
                }
                
                // 否则直接显示完整日期时间
                
                else
                    
                    ret = [NSString stringWithFormat:@"%@%@", [TimeTool getTimeString:dt format:@"MM/dd"], timeExtraStr];
                
            }
            
        }
        
    }
    
    // 往年
    
    else{
        
        ret = [NSString stringWithFormat:@"%@%@", [TimeTool getTimeString:dt format:@"yyyy/M/d"], timeExtraStr];
        
    }
    
    return ret;
    
}

+ (NSString*)getLastLoginTimeString:(NSDate*)dt{
    
    NSString*ret = nil;
    NSCalendar*calendar = [NSCalendar currentCalendar];
    // 当前时间
    NSDate*currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateComponents*curComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitWeekOfYear fromDate:currentDate];
    NSInteger currentYear=[curComponents year];
    NSInteger currentMonth=[curComponents month];
    NSInteger currentDay=[curComponents day];
    
    // 目标判断时间
    NSDateComponents*srcComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitWeekOfYear fromDate:dt];
    NSInteger srcYear=[srcComponents year];
    NSInteger srcMonth=[srcComponents month];
    NSInteger srcDay=[srcComponents day];
    
    // 要额外显示的时间分钟
    NSString*timeExtraStr = [TimeTool getTimeString:dt format:@" HH:mm"];
    
    long currentTimestamp = [TimeTool getIOSTimeStamp_l:currentDate];
    long srcTimestamp = [TimeTool getIOSTimeStamp_l:dt];
    // 相差时间（单位：秒）
    long delta = currentTimestamp - srcTimestamp;
    
    // 当年
    if(currentYear == srcYear) {
        
        // 当天（月份和日期一致才是）
        if((currentMonth == srcMonth) && (currentDay == srcDay)) {
            // 时间相差60秒以内
            if(delta < 60)
                ret = [NSString stringWithFormat:NSLocalizedString(@"最后上线 于 %@", nil),[TimeTool getTimeString:dt format:@"HH:mm"]];
            // 否则当天其它时间段的，直接显示“时:分”的形式
            else
                ret = [NSString stringWithFormat:NSLocalizedString(@"最后上线 于 %@", nil),[TimeTool getTimeString:dt format:@"HH:mm"]];
        }
        // 当年 && 当天之外的时间（即昨天及以前的时间）
        else{
            // 昨天（以“现在”的时候为基准-1天）
            NSDate*yesterdayDate = [NSDate dateWithTimeIntervalSinceNow:0];
            yesterdayDate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:yesterdayDate];
            NSDateComponents*yesterdayComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:yesterdayDate];
            NSInteger yesterdayMonth=[yesterdayComponents month];
            NSInteger yesterdayDay=[yesterdayComponents day];
            // 用目标日期的“月”和“天”跟上方计算出来的“昨天”进行比较，是最为准确的（如果用时间戳差值
            // 的形式，是不准确的，比如：现在时刻是2019年02月22日1:00、而srcDate是2019年02月21日23:00，
            // 这两者间只相差2小时，直接用“delta/3600” > 24小时来判断是否昨天，就完全是扯蛋的逻辑了）
            
            if(srcMonth == yesterdayMonth && srcDay == yesterdayDay)
                ret = [NSString stringWithFormat:NSLocalizedString(@"最后上线 于 昨天%@", nil), timeExtraStr];// -1d
            else{
                // 跟当前时间相差的小时数
                long deltaHour = (delta/3600);
                // 如果大于30*24小时就显示最近没有上线
                if(deltaHour > 30*24){
                    ret = [NSString stringWithFormat:NSLocalizedString(@"最近没有上线", nil)];
                }else{
                    ret = [NSString stringWithFormat:NSLocalizedString(@"最后上线 于 %@%@", nil), [TimeTool getTimeString:dt format:@"MM/dd"], timeExtraStr];
                }
            }
        }
    }else{
        // 昨天（以“现在”的时候为基准-1天）
        NSDate*yesterdayDate = [NSDate dateWithTimeIntervalSinceNow:0];
        yesterdayDate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:yesterdayDate];
        NSDateComponents*yesterdayComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:yesterdayDate];
        NSInteger yesterdayMonth=[yesterdayComponents month];
        NSInteger yesterdayDay=[yesterdayComponents day];
        // 用目标日期的“月”和“天”跟上方计算出来的“昨天”进行比较，是最为准确的（如果用时间戳差值
        // 的形式，是不准确的，比如：现在时刻是2019年02月22日1:00、而srcDate是2019年02月21日23:00，
        // 这两者间只相差2小时，直接用“delta/3600” > 24小时来判断是否昨天，就完全是扯蛋的逻辑了）
        
        if(srcMonth == yesterdayMonth && srcDay == yesterdayDay)
            ret = [NSString stringWithFormat:NSLocalizedString(@"最后上线 于 昨天%@", nil), timeExtraStr];// -1d
        else{
            // 跟当前时间相差的小时数
            long deltaHour = (delta/3600);
            // 如果大于30*24小时就显示最近没有上线
            if(deltaHour > 30*24){
                ret = [NSString stringWithFormat:NSLocalizedString(@"最近没有上线", nil)];
            }else{
                ret = [NSString stringWithFormat:NSLocalizedString(@"最后上线 于 %@%@", nil), [TimeTool getTimeString:dt format:@"yyyy/MM/dd"], timeExtraStr];
            }
        }
    }
    return ret;
}

+ (NSString*)getTimeString:(NSDate*)dt format:(NSString*)fmt{
    
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    
    [format setDateFormat:fmt];
    
    if ([fmt isEqualToString:@"MMMM d"]) {
        format.locale = [NSLocale localeWithLocaleIdentifier:@"en"];
    }
    
    format.AMSymbol = NSLocalizedString(@"上午", nil);
    format.PMSymbol = NSLocalizedString(@"下午", nil);
    
    return[format stringFromDate:(dt==nil?[TimeTool getIOSDefaultDate]:dt)];
    
}

+ (NSTimeInterval) getIOSTimeStamp:(NSDate*)dat{
    
    NSTimeInterval a = [dat timeIntervalSince1970];
    
    return a;
    
}

+ (long) getIOSTimeStamp_l:(NSDate*)dat{
    
    return[[NSNumber numberWithDouble:[TimeTool getIOSTimeStamp:dat]] longValue];
    
}

+ (NSDate*)getIOSDefaultDate
{
    return [NSDate date];
}

+ (NSString *)getShowDateWithTime:(NSString *)time{
    /**
     传入时间转NSDate类型
     */
    NSDate *timeDate = [[NSDate alloc]initWithTimeIntervalSince1970:[time longLongValue]/1000.0];
    
    /**
     初始化并定义Formatter
     
     :returns: NSDate
     */
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm";
    
    /**
     *  使用Formatter格式化时间（传入时间和当前时间）为NSString
     */
    NSString *timeStr = [dateFormatter stringFromDate:timeDate];
    NSString *nowDateStr = [dateFormatter stringFromDate:[NSDate date]];
    
    /**
     *  判断前四位是不是本年，不是本年直接返回完整时间
     */
    if ([[timeStr substringWithRange:NSMakeRange(0, 4)] rangeOfString:[nowDateStr substringWithRange:NSMakeRange(0, 4)]].location == NSNotFound) {
        return [timeStr substringWithRange:NSMakeRange(0, 10)];
    }else{
        /**
         *  判断是不是本天，是本天返回HH:mm,不是返回MM-dd HH:mm
         */
        if ([[timeStr substringWithRange:NSMakeRange(5, 5)] rangeOfString:[nowDateStr substringWithRange:NSMakeRange(5, 5)]].location != NSNotFound) {
            return [timeStr substringWithRange:NSMakeRange(11, 5)];
        }else{
            return [timeStr substringWithRange:NSMakeRange(5, 11)];
        }
    }
}

- (NSString *)compareDate:(NSDate *)date{
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *tomorrow, *yesterday;
    
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
    
    NSString * dateString = [[date description] substringToIndex:10];
    
    if ([dateString isEqualToString:todayString])
    {
        return NSLocalizedString(@"今天", comment: nil);
    } else if ([dateString isEqualToString:yesterdayString])
    {
        return NSLocalizedString(@"昨天", comment: nil);
    }else if ([dateString isEqualToString:tomorrowString])
    {
        return @"明天";
    }
    else
    {
        return dateString;
    }
}
//----------------------------------------------

/**
 /////  和当前时间比较
 ////   1）1分钟以内 显示        :    刚刚
 ////   2）1小时以内 显示        :    X分钟前
 ///    3）今天或者昨天 显示      :    今天 09:30   昨天 09:30
 ///    4) 今年显示              :   09月12日
 ///    5) 大于本年      显示    :    2013/09/09
 **/

+ (NSString *)formateDate:(NSDate*)dt withFormate:(NSString *) formate
{
    
    @try {
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:formate];
        
        NSDate * nowDate = [NSDate date];
        
        /////  将需要转换的时间转换成 NSDate 对象
        NSDate * needFormatDate = dt;
        /////  取当前时间和转换时间两个日期对象的时间间隔
        /////  这里的NSTimeInterval 并不是对象，是基本型，其实是double类型，是由c定义的:  typedef double NSTimeInterval;
        NSTimeInterval time = [nowDate timeIntervalSinceDate:needFormatDate];
        
        //// 再然后，把间隔的秒数折算成天数和小时数：
        
        NSString *dateStr = @"";
        
//        if (time<=60) {  //// 1分钟以内的
//            dateStr = @"刚刚";
//        }else if(time<=60*60){  ////  一个小时以内的
//            
//            int mins = time/60;
//            dateStr = [NSString stringWithFormat:@"%d分钟前",mins];
//            
//        }else
            if(time<=60*60*24){   //// 在两天内的
            
            [dateFormatter setDateFormat:@"yyyy/MM/dd"];
            NSString * need_yMd = [dateFormatter stringFromDate:needFormatDate];
            NSString *now_yMd = [dateFormatter stringFromDate:nowDate];
            
            [dateFormatter setDateFormat:@"HH:mm"];
            if ([need_yMd isEqualToString:now_yMd]) {
                //// 在同一天
                dateStr = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"今天", comment: nil), [dateFormatter stringFromDate:needFormatDate]];
            }else{
                ////  昨天
                dateStr = [NSString stringWithFormat:@"昨天 %@",[dateFormatter stringFromDate:needFormatDate]];
            }
        }else {
            
            [dateFormatter setDateFormat:@"yyyy"];
            NSString * yearStr = [dateFormatter stringFromDate:needFormatDate];
            NSString *nowYear = [dateFormatter stringFromDate:nowDate];
            
            if ([yearStr isEqualToString:nowYear]) {
                ////  在同一年
                [dateFormatter setDateFormat:NSLocalizedString(@"MM月dd日", nil)];
                dateStr = [dateFormatter stringFromDate:needFormatDate];
            }else{
                [dateFormatter setDateFormat:@"yyyy/MM/dd"];
                dateStr = [dateFormatter stringFromDate:needFormatDate];
            }
        }
        
        return dateStr;
    }
    @catch (NSException *exception) {
        return @"";
    }
}
+ (NSDate *)getCurrentDay{
    /**
     *  获取当天凌晨时间
     */
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    
    [calendar setTimeZone:gmt];
    
    NSDate *date = [NSDate date];
    
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:date];
    
    components.day-=1;
    
    [components setHour:0];
    
    [components setMinute:0];
    
    [components setSecond: 0];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    return endDate;
}
@end
