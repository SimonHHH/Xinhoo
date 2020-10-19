//
//  DiscoverToolsTest.swift
//  COD
//
//  Created by Sim Tsai on 2020/6/30.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Quick
import Nimble
@testable import COD

class DiscoverToolsTest: QuickSpec {
    override func spec() {
        
        describe("test toTimeString") {
            
            context("test minutes") {
                
                it("less 1 minute") {
                    
                    // 2020-06-30 09:54:15 / 2020-06-30 09:54:50
                    let timeStr = DiscoverTools._toTimeString(1593482055000, 1593482090000)
                    
                    expect(timeStr).to(contain("1 mins ago"))
                    
                }
                
                it("5 minutes") {
                    
                    // 2020-06-30 09:54:15 / 2020-06-30 09:59:15
                    let timeStr = DiscoverTools._toTimeString(1593482055000, 1593482355000)
                    
                    expect(timeStr).to(contain("5 mins ago"))
                    
                }
                
                it("59 minutes") {
                    
                    // 2020-06-30 09:54:15 / 2020-06-30 10:54:14
                    let timeStr = DiscoverTools._toTimeString(1593482055000, 1593485654000)
                    
                    expect(timeStr).to(contain("59 mins ago"))
                    
                }
                
            }
            
            context("test hours") {
                
                it("1 hour") {
                    
                    // 2020-06-30 09:54:15 / 2020-06-30 10:54:15
                    let timeStr = DiscoverTools._toTimeString(1593482055000, 1593485655000)
                    
                    expect(timeStr).to(contain("1 hr ago"))
                    
                }
                
                it("12 hour") {
                    
                    // 2020-06-30 09:54:15 / 2020-06-30 21:54:15
                    let timeStr = DiscoverTools._toTimeString(1593482055000, 1593525255000)
                    
                    expect(timeStr).to(contain("12 hr ago"))
                    
                }
                
                it("20 hour") {
                    
                    // 2020-06-30 09:54:15 / 2020-07-01 05:54:15
                    let timeStr = DiscoverTools._toTimeString(1593482055000, 1593554055000)
                    
                    expect(timeStr).to(contain("20 hr ago"))
                    
                }
                
                it("23 hour") {
                    
                    // 2020-06-30 09:54:15 / 2020-07-01 08:54:15
                    let timeStr = DiscoverTools._toTimeString(1593482055000, 1593564855000)
                    
                    expect(timeStr).to(contain("23 hr ago"))
                    
                }
                
                it("less 24 hour") {
                    
                    // 2020-06-30 09:54:15 / 2020-07-01 09:54:14
                    let timeStr = DiscoverTools._toTimeString(1593482055000, 1593568454000)
                    
                    expect(timeStr).to(contain("23 hr ago"))
                    
                }
                
            }
            
            context("test yesterday") {
                
                it("24 hour") {
                    
                    // 2020-06-30 09:54:15 / 2020-07-01 09:54:15
                    let timeStr = DiscoverTools._toTimeString(1593482055000, 1593568455000)
                    
                    expect(timeStr).to(contain("yday"))
                    
                }
                
                it("36 hour") {
                    
                    // 2020-06-30 09:54:15 / 2020-07-01 21:54:15
                    let timeStr = DiscoverTools._toTimeString(1593482055000, 1593611655000)
                    
                    expect(timeStr).to(contain("yday"))
                    
                }
                
                it("38 hour") {
                    
                    // 2020-06-30 09:54:15 / 2020-07-01 23:54:15
                    let timeStr = DiscoverTools._toTimeString(1593482055000, 1593618855000)
                    
                    expect(timeStr).to(contain("yday"))
                    
                }
                
            }
            
            context("test days") {
                
                it("39 hour") {
                    
                    // 2020-06-30 09:54:15 / 2020-07-02 00:54:15
                    let timeStr = DiscoverTools._toTimeString(1593482055000, 1593622455000)
                    
                    expect(timeStr).to(contain("2 days ago"))
                    
                }
                
                it("3 days") {
                    
                    // 2020-06-30 09:54:15 / 2020-07-03 00:54:15
                    let timeStr = DiscoverTools._toTimeString(1593482055000, 1593708855000)
                    
                    expect(timeStr).to(contain("3 days ago"))
                    
                }
                
            }
            
            context("test bug case") {
                
                // 2020-06-29 21:26:15 / 2020-06-29 23:52:15
                let timeStr = DiscoverTools._toTimeString(1593437175768, 1593445935000)
                
                expect(timeStr).to(contain("2 hr ago"))
                
            }
            
            context("test isSameDay") {
                
                var isSameDay = false
                it ("2020-07-10 00:00:00 and 2020-07-10 01:00:00") {
                    isSameDay = DiscoverTools.isSameDay(1594310400000, 1594314000000)
                    expect(isSameDay).to(equal(true))
                }
                
                it ("2020-07-10 00:00:00 and 2020-07-10 01:00:00") {
                    isSameDay = DiscoverTools.isSameDay(1594310400000, 1594314000000)
                    expect(isSameDay).to(equal(true))
                }
                
                it ("2020-07-10 00:00:00 and 2020-07-10 06:00:00") {
                    isSameDay = DiscoverTools.isSameDay(1594310400000, 1594332000000)
                    expect(isSameDay).to(equal(true))
                }
                
                it ("2020-07-10 00:00:00 and 2020-07-10 08:00:00") {
                    isSameDay = DiscoverTools.isSameDay(1594310400000, 1594339200000)
                    expect(isSameDay).to(equal(true))
                }
                
                it ("2020-07-10 00:00:00 and 2020-07-10 12:00:00") {
                    isSameDay = DiscoverTools.isSameDay(1594310400000, 1594353600000)
                    expect(isSameDay).to(equal(true))
                }
                

                it ("2020-07-10 00:00:00 and 2020-07-10 15:00:00") {
                    isSameDay = DiscoverTools.isSameDay(1594310400000, 1594364400000)
                    expect(isSameDay).to(equal(true))
                }
                
                it ("2020-07-10 00:00:00 and 2020-07-10 18:00:00") {
                    isSameDay = DiscoverTools.isSameDay(1594310400000, 1594375200000)
                    expect(isSameDay).to(equal(true))
                }
                
                
                it ("2020-07-10 00:00:00 and 2020-07-10 20:00:00") {
                    isSameDay = DiscoverTools.isSameDay(1594310400000, 1594382400000)
                    expect(isSameDay).to(equal(true))
                }
                
                it ("2020-07-10 00:00:00 and 2020-07-11 00:00:00") {
                    isSameDay = DiscoverTools.isSameDay(1594310400000, 1594396800000)
                    expect(isSameDay).to(equal(false))
                }
                
                
                it ("2020-07-10 00:00:00 and 2020-08-10 00:00:00") {
                    isSameDay = DiscoverTools.isSameDay(1594310400000, 1596988800000)
                    expect(isSameDay).to(equal(false))
                }
                
                it ("2020-07-10 00:00:00 and 2021-07-10 00:00:00") {
                    isSameDay = DiscoverTools.isSameDay(1594310400000, 1625846400000)
                    expect(isSameDay).to(equal(false))
                }
                
                
            }
            
        }
        
        context("test isInYear") {
            
            // 2020-07-13 14:45:24
            let sysDate = Date(milliseconds: 1594622724803)
            
            var isInYear = false
            
            it("2020-01-01 00:00:01") {
                isInYear = DiscoverTools._isInYear(sysDate, 1577808001000)
                expect(isInYear).to(equal(true))
            }
            
            it("2020-07-13 14:49:39") {
                isInYear = DiscoverTools._isInYear(sysDate, 1594622979809)
                expect(isInYear).to(equal(true))
            }
            
            it("2020-12-31 23:59:59") {
                isInYear = DiscoverTools._isInYear(sysDate, 1609430399000)
                expect(isInYear).to(equal(true))
            }
            
            it("2019-12-31 23:59:59") {
                isInYear = DiscoverTools._isInYear(sysDate, 1577807999000)
                expect(isInYear).to(equal(false))
            }
            
            it("2021-01-01 00:00:00") {
                isInYear = DiscoverTools._isInYear(sysDate, 1609430400000)
                expect(isInYear).to(equal(false))
            }
            
        }
        
        context("test isSameYear") {
            
            var isSameYear = false
            
            it("2020-01-01 00:00:01 and 2020-12-31 23:59:59") {
                isSameYear = DiscoverTools.isSameYear(1577808001000, 1609430399000)
                expect(isSameYear).to(equal(true))
            }
            
            it("2020-01-01 00:00:01 and 2020-07-13 15:00:39") {
                isSameYear = DiscoverTools.isSameYear(1577808001000, 1594623639821)
                expect(isSameYear).to(equal(true))
            }
            
            it("2020-06-13 15:01:03 and 2020-07-13 15:00:39") {
                isSameYear = DiscoverTools.isSameYear(1592031663000, 1594623639821)
                expect(isSameYear).to(equal(true))
            }
            
            it("2020-01-01 00:00:01 and 2021-01-01 00:00:00") {
                isSameYear = DiscoverTools.isSameYear(1577808001000, 1609430400000)
                expect(isSameYear).to(equal(false))
            }
            
            it("2019-12-31 23:59:59 and 2020-12-31 23:59:59") {
                isSameYear = DiscoverTools.isSameYear(1577807999000, 1609430399000)
                expect(isSameYear).to(equal(false))
            }
            
            it("2019-12-31 23:59:59 and 2021-01-01 00:00:00") {
                isSameYear = DiscoverTools.isSameYear(1577807999000, 1609430400000)
                expect(isSameYear).to(equal(false))
            }
            
        }
        
        context("test toImageBrowserString") {
            
            // 2020-07-20 09:21:29
            let sysTime = 1595208089376
            var timeStr = ""
            
            it("2020-07-20 09:21:00") {
                
                timeStr = DiscoverTools.toImageBrowserString(sysTime, time: 1595208060000)
                expect(timeStr).to(equal("1 mins ago"))
                
                
            }
            
            it("2020-07-20 08:21:30") {
                
                timeStr = DiscoverTools.toImageBrowserString(sysTime, time: 1595204490000)
                expect(timeStr).to(equal("59 mins ago"))
                
                
            }
            
            it("2020-07-20 08:21:29") {
                
                timeStr = DiscoverTools.toImageBrowserString(sysTime, time: 1595204489000)
                expect(timeStr).to(equal("08:21 AM"))

            }
            
            it("2020-07-19 08:21:29") {
                
                timeStr = DiscoverTools.toImageBrowserString(sysTime, time: 1595118089000)
                expect(timeStr).to(equal("yday 08:21 AM"))

            }
            
            it("2020-07-19 23:59:59") {
                
                timeStr = DiscoverTools.toImageBrowserString(sysTime, time: 1595174399000)
                expect(timeStr).to(equal("yday 11:59 PM"))

            }
            
            it("2020-07-18 23:59:59") {
                
                timeStr = DiscoverTools.toImageBrowserString(sysTime, time: 1595087999000)
                expect(timeStr).to(equal("2020-07-18 11:59 PM"))

            }
            
        }
        
    }
}
