//
//  Constraint.swift
//  Gooker
//
//  Created by Wilson on 2018/7/19.
//  Copyright © 2018 Libiao. All rights reserved.
//

import Foundation

// MARK:- 全局颜色
public let kVCBgColorS         = "F7F7F7"         // 全局vc背景色
public let kNavBarBgColorS         = "F7F7F7"     // navBar背景色
public let kNavTitleColorS         = "000000"     // navTitle颜色
public let kNavRightBtnTitleColorS         = "496B8D"     //navRightBtnTitle颜色
public let kTabItemUnselectedColorS        = "9C9C9C"     // tabbarItem未选中标题色
public let kTabItemSelectedColorS          = "047EF5"     // tabbarItem选中标题色
public let kTabBarBackgroundColorS         = "F7F7F7"     // tabbar背景色
public let kMainTitleColorS           = "333333"      // 常用黑字体颜色
public let kEmptyTitleColorS          = "666666"      // 缺省图黑字体颜色
public let kSubTitleColors     = "8E8E93"         // 子标题灰色
public let kBtnDisenableColors = "787878"         //按钮不可点击的颜色
public let kSubTitleColors8E8E92     = "8E8E93"
public let kDividingLineColorS = "E6E6E6"         // 分割线颜色
public let kSubmitBtnBgColorS = "047EF5"          //提交按钮的颜色
public let kMainBlueBgColorS = "0374E2"           //项目的主色
public let kBlueBtnColorS = "3698f7"              //项目的主色
public let kBlueTitleColorS = "367CDE"            //蓝色的TitleColor
public let kSepLineColorS = "C8C7CC"              //line颜色
public let kSearchBarTextFieldBackGdColorS = "E9E9E9"    //搜索框背景颜色
public let kSectionHeaderTextColorS = "8E8E93"    //排序后索引（A-Z）cell的头部文字颜色
public let kSectionFooterTextColorS = "6D6D71"    //SectionFootViewTitleColor
public let kGrayTextCountTextColorS = "D3D3D7"    //灰色用于字数限制的字体颜色
public let kRedTextForLimitColorS = "E1472F"    //红色用于限制类的字体颜色
public let kWeakTitleColorS = "999999"    //灰色用于弱提示的字体颜色
public let kChannelNameColorS = "3C72ED"    //频道会话页面统一的名字字体颜色

public let kLocalVideoWidth = KScreenWidth * 90/375.0
public let kLocalVideoHeigth = KScreenHeight * 160/667.0

// MARK:- 全局圆角
public let kCornerRadius : CGFloat = 5.0
// MARK:- 全局字体

// MARK:- 屏幕尺寸
public let kScreenWidth    = UIScreen.main.bounds.size.width
public let kScreenHeight   = UIScreen.main.bounds.size.height
public let kScreenScale    = kScreenWidth / 375.0

public let IsiPhone4       = UIScreen.instancesRespond(to: #selector(getter: RunLoop.currentMode)) ? (CGSize(width: 640, height: 960).equalTo((UIScreen.main.currentMode?.size)!)) : false
public let IsiPhone5       = UIScreen.instancesRespond(to: #selector(getter: RunLoop.currentMode)) ? (CGSize(width: 640, height: 1136).equalTo((UIScreen.main.currentMode?.size)!)) : false
public let IsiPhone6       = UIScreen.instancesRespond(to: #selector(getter: RunLoop.currentMode)) ? (CGSize(width: 750, height: 1334).equalTo((UIScreen.main.currentMode?.size)!)) : false
public let IsiPhone6P      = UIScreen.instancesRespond(to: #selector(getter: RunLoop.currentMode)) ? (CGSize(width: 1242, height: 2208).equalTo((UIScreen.main.currentMode?.size)!)) : false

// 5.8 英⼨寸超视⽹网膜显示屏
public let IS_IPHONE_X     = UIScreen.instancesRespond(to: #selector(getter: RunLoop.currentMode)) ? (CGSize(width: 1125, height: 2436).equalTo((UIScreen.main.currentMode?.size)!)) : false
public let IS_IPHONE_XS    = UIScreen.instancesRespond(to: #selector(getter: RunLoop.currentMode)) ? (CGSize(width: 1125.0, height: 2436.0).equalTo((UIScreen.main.currentMode?.size)!)) : false

// 6.5 英⼨寸超视⽹网膜显示屏
public let IS_IPHONE_XR    = UIScreen.instancesRespond(to: #selector(getter: RunLoop.currentMode)) ? (CGSize(width: 750.0, height: 1624.0).equalTo((UIScreen.main.currentMode?.size)!)) : false
public let IS_IPHONE_XS_MAX  = UIScreen.instancesRespond(to: #selector(getter: RunLoop.currentMode)) ? (CGSize(width: 1125.0, height: 2436.0).equalTo((UIScreen.main.currentMode?.size)!)) : false

public let IsiPhoneX = UIApplication.shared.statusBarFrame.height >= 44

// MARK:- 安全高度定义
public let kSafeArea_Top: CGFloat = (IsiPhoneX ? 24.0 : 0.0)
public let kSafeArea_Bottom: CGFloat = (IsiPhoneX ? 34.0 : 0.0)

// MARK:- 导航栏高度
public let kNavBarHeight: CGFloat = 64.0
public let kTabBarHeight: CGFloat = 49.0

public let kSafeArea_Height = KScreenHeight - kSafeArea_Top - kSafeArea_Bottom - kNavBarHeight - kTabBarHeight

// MARK:- 通知关键字
public let statusBarNotification = "statusBarNotification"               // 点击状态栏
public let kGetUserSuccessNoti = "kGetUserSuccessNoti"               // 获取XMPP账号密码成功
public let kChangeRootCtlNoti = "kChangeRootCtlNoti"                 // 登录成功切换RootViewController
public let kLoginoutNoti = "kLoginoutNoti"                           // 退出登录
public let kClearUserInfoNoti = "kClearUserInfoNoti"                 // 退出登录清除个人信息
public let kUploadCellUpdateNoti  = "kUploadCellUpdateNoti"    // 上传通知cell刷新
public let kUpdateGKMeHeaderViewNoti = "kUpdateGKMeHeaderViewNoti"   // 更新我的头像，昵称
public let kUpdateGKMeInfoNoti       = "kUpdateGKMeInfoNoti"         // 更新个人信息
public let kRefreshHeaderNoti      = "kRefreshHeaderNoti"         // 刷新头像
public let kXMPPPresenceNoti       = "kXMPPPresenceNoti"         // 出席通知
public let kReloadChatListNoti       = "kReloadChatListNoti"         // 刷新最近聊天列表
public let kCollectionMessageSuccess      = "kCollectionMessageSuccess"         // 收藏消息发送成功
public let kApplicationBecomeAvailable       = "kApplicationBecomeAvailable"         // APP开始启动
public let kApplicationBecomeUnavailable       = "kApplicationBecomeUnavailable"         // APP退到后台
public let kApplicationBecomeUnavailableLock       = "kApplicationBecomeUnavailableLock"         // 锁屏
public let kReloadRedPoint           = "kReloadRedPoint"             // 刷新小红点
public let kUpdataMessageView        = "kUpdataMessageView"         // 更新会话列表
public let kUpdataMessageStatueView       = "kUpdataMessageStatueView"         // 更新会话列表某一条数据的发送状态
public let kReloadCallVC             = "kReloadCallVC"              // 刷新呼叫模块页面
public let kReloadTabCount             = "kReloadTabCount"              // 动态更新tabbar数量
public let kReloadMomentBackground  = "kReloadMomentBackground"              // 刷新朋友圈首页背景

public let kRepairSuccess       = "kRepairSuccess"              // 修复数据成功
public let kSendVoiceMoveTouch       = "kSendVoiceMoveTouch"              // 发送语音时，手势移动的通知
public let kSendVoiceRecord         = "kSendVoiceRecord"              // 发送语音时，录音的通知
public let kSendVoiceStopPlay         = "kSendVoiceStopPlay"              // 停止播放录音通知

public let kUpdateGroupMemberCountNoti    = "kUpdateGroupMemberCountNoti"         // 更新群成员数量
public let kDeleteChatListNoti       = "kDeleteChatListNoti"         // 退出群组删除聊天记录
public let kDeleteMessageNoti       = "kDeleteMessageNoti"         // 删除聊天信息

public let kChangeLanguageNoti       = "kChangeLanguageNoti"         // 系统语言改变
public let kChangeSystemNoti         = "kChangeSystemNoti"         // 系统通知改变
public let kConfigRealmSuccess       = "kConfigRealmSuccess"         // realm数据库配置成功
public let kClickTabbarItemNoti      = "kClickTabbarItemNoti"         // 点击tabbar通知

public let kWaitNetwork               = "kWaitNetwork"                // 等待网络中
public let kConnecting               = "kConnecting"                // 断线重连中
public let kBeginGetHistory          = "kBeginGetHistory"           // 开始获取历史消息
public let kEndGetHistory            = "kEndGetHistory"             // 结束获取历史消息
public let kConnectFail              = "kConnectFail"               // 连接失败，需要清除引导页


public let kUpdateTheMessageNoti     = "kUpdateTheMessageNoti"  //更新一条消息（目前只用于更新发送被拒收的消息）

public let kReceiveVideoCall         = "kReceiveVideoCall"          // 接收到语音通话相关的消息

public let kAudioPlayEnd             = "kAudioPlayEnd"          // 语音播放结束通知
public let kAudioCallBegin           = "kAudioCallBegin"          // 开始语音通话通知

public let kAtAll                    = "ALL"          // @所有人
public let kCloudJid                 = "clouddisk"          // 云盘

#if PRO
public let kApp_Name            = "Flygram"
#elseif MANGO
public let kApp_Name            = "Mango"
#else
public let kApp_Name            = "星河IM"
#endif



// MARK:- 文件存储

// MARK:- UserDefaults 关键字
public let kCurrentUUID  = "kCurrentUUID"             // 当前用户UUID 用于区分当前用户所属的文件夹
public let kCurrentToken = "kCurrentToken"           // 当前用户token
public let kLoginToken   = "kLoginToken"               // 登录之后的token 还未填写资料的时候记录
public let kRemeberAccount = "kRemeberAccount"         // 记录登录的手机号码
public let kChat_BGImg = "kChat_BGImg"         // 聊天页面背景图片
public let kIsVideoCall = "kIsVideoCall"                //当前用户是否处于音视频通话状态
public let kIsVideoRoomID = "kIsVideoRoomID"                //当前用户正在通话的roomID
public let kIsVideoRoomJid = "kIsVideoRoomJid"                //当前用户正在通话的jid
public let kIsFirst     = "kIsFirst"                //是否第一次启动
public let kVersion     = "kVersion"                //版本号
public let kShowCallTab     = "kShowCallTab"                //显示呼叫模块tabbar
public let kServersName     = "kServersNameV3"                //服务器名称
public let kServersList     = "kServersListV3"                //服务器列表
public let kServerConfig     = "kServerConfig"                //服务器配置

public let kNewLifeCycle = "kNewLifeCycle"      //一个新的生命周期

public let kLastMessageTime = "kLastMessageTime" //最后一条消息时间，保存到UserDefaults，用来获取历史消息
public let kLastUpdateContactTime = "kLastUpdateContactTime" //增量更新通讯录的时间，由服务器返回
public let kLastCDMessageTime = "kCloudDiskLastMessageTime" //云盘最后一条消息时间，保存到UserDefaults，用来获取云盘历史消息
public let kLastSound_Message = "kLastSound_Message" //最后响声音的一条消息，保存到UserDefaults，用来处理是否声音提示 当消息发送时间跟kLastSound_Message不小于1s，就不响提示音
//public let kLastPushTime    = "kLastPushTime" //最后一条消息时间，保存到UserDefaults，用来获取历史消息

public let kFontSize_Change = "kFontSize_Change"        //记录当前调整的字体大小
public let kSecurityCode = "kSecurityCode"        //锁屏码
public let kSecurityCodeLeaveTime = "kSecurityCode_LeaveTime"        //锁屏码-记录用户离开的时间
public let kSecurityCodeAutoLockingTime = "kSecurityCode_AutoLockingTime"        //锁屏码-自动锁定时间
public let kSecurityCode_ClearData = "kSecurityCode_ClearData"        //锁屏码
public let kSecurityCode_Smooth = "kSecurityCode_Smooth"        //锁屏码
public let kMyLanguage = "kMyLanguage"         // 记录当前程序语言
public let kIsTourist   = "kIsTourist" // 是否为游客模式

public let kShowWelcomState = "kShowWelcomState"    // 记录 是否显示引导页0
public let kNotificationState = "kNotificationState" //消息通知是否开启 0,未设置,1开启 2关闭
public let kNotificationSoundState = "kNotificationSoundState" //消息通知声音是否开启  0,未设置,1开启 2关闭
public let kNotificationVibrateState = "kNotificationVibrateState" //消息通知是否开启  0,未设置,1开启 2关闭

public let kNotificationDidEnterBackground = "kNotificationAppDidEnterBackground" // app 进入到后台的通知
public let kNotificationAppWillEnterForeground = "kNotificationAppWillEnterForeground" // apkScreenHeight台的通知

public let kNotificationUpdateGroupMember = "kNotificationUpdateGroupMember" // 更新群成员列表kScreenHeightkNotificationUserLoginOut = "kNotificationUserLoginOut" // 用户被挤下线
public let kNotificationUpdateChannel = "kNotificationUpdateChannel" // 更新频道
public let kNotificationReloadAllMessgae = "kNotificationReloadAllMessgae" // 刷新所有消息

public let kNotificationTopMessage = "kNotificationTopMessage" // 置顶消息通知刷新
public let kNotificationUpdateAtMessage = "kNotificationUpdateAtMessage" // 艾特通知刷新

public let kNotificationUpdateGroupInfoVC = "kNotificationUpdateGroupInfoVC"

// MARK:- 第三方框架key
public let kBugTagsTestKey    = "8f32b79be5f1a994295b50dc6895fba3"
public let kBugTagsReleaseKey = "52ab0e67bd7dc63e57e24a10330c7f35"

// MARK:- 通用闭包回调
typealias Success = (AnyObject?, String) -> Void
typealias Failure = (String, URL) -> Void
typealias ProgressHandle = (CGFloat) -> Void
typealias ConfirmHandle = (String) -> Void
typealias CancelHandle = (String) -> Void
typealias SelectHandle = (Int, UIImage) -> Void
typealias VoidHandle = () -> Void
typealias VoidHandleError = (String,Error?) -> Void
typealias CommonHandleError = (AnyObject?,AnyObject?) -> Void

// MARK:- 系统相关
public let KeyWindow = UIApplication.shared.delegate?.window
public let kCFBundleShortVersionStringKey = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String   // 版本version 【1.3.0 版本号， 保存的当前app 版本号】
public let kCFBundleVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as! String                            // bulid版本号
public let kCFBundleDisplayName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String                    // app名称
public let kSystemVersion = UIDevice.current.systemVersion //iOS系统版本
public let kSystemVersionInt = UIDevice.current.systemVersion.int //iOS系统版本

/// 设置目录
public func kAppSettingUrl() -> (NSURL) {
    let url = NSURL(string: UIApplication.openSettingsURLString)
    return url!
}
//IM未知消息
public let kUnKownMessageString = "此条消息无法显示,请升级App版本后查看"

//widget App点击自动接单跳转
public let kGKWidgetAutomaticReceipt = "kGKWidgetAutomaticReceipt"
//新的消息
public let kGKHaveNewMessage = "kGKHaveNewMessage"

// MARK:- js 交互字段
public let kJSReLogin = "reLogin" // 重新登录
public let kJSWebBack = "webBack" // 退出当前界面
public let kJSRefreshData = "refreshData" // 重新加载


//MARK: 网址正则
let kRegexURL = "(?i)((http[s]{0,1}://|ftp://)?((([a-zA-Z0-9\\-]+\\.){1,10}(in|ms|me|cc|com|cn|re|fm|edu|gov|int|im|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|mobi|xyz|wang|top|club|ren|pub|market|rocks|band|software|social|lawyer|engineer|ac|adm))|((1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|[1-9])\\.(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\.(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\.(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)))(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.([a-zA-Z0-9\\-]+\\.){1,10}(in|ms|me|cc|com|cn|re|fm|edu|gov|int|im|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|mobi|xyz|wang|top|club|ren|pub|market|rocks|band|software|social|lawyer|engineer|ac|adm)(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(http[s]{0,1}://|ftp://)?((1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|[1-9])\\.(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\.(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\.(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d))"

let kChatImageMaxWidth: CGFloat = 260                                       //最大的图片宽度
let kChatImageMinWidth: CGFloat = 170                                       //最小的图片宽度
let kChatImageMaxHeight: CGFloat = 260                                      //最大的图片高度
let kChatImageMinHeight: CGFloat = 74                                      //最小的图片高度
