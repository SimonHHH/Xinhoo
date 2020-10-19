//
//  CODUserManager.swift
//  COD
//
//  Created by XinHoo on 2019/3/6.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import SwiftyJSON
import AdSupport
import RxSwift
import RxCocoa

let UserInstance = UserManager.sharedInstance

//let Salt = "xInhoO.coM"


private let kNickname           = "kCOD_username"
private let kAvatar             = "kCOD_avatar"
private let kAreaNum            = "kCOD_areaNum"
private let kCountryName        = "kCountryName"
private let kPhoneNum           = "kCOD_phoneNum"
private let kIsLogin            = "kCOD_isLogin"
private let kLoginName          = "kCOD_loginName"
private let kUserDesc           = "kCOD_userDesc"
private let kPassword           = "kCOD_password"
private let kSex                = "kCOD_sex"
private let kEmail              = "kCOD_eMail"
private let kIntro              = "kCOD_intro"
private let kUpdatePassword     = "kCOD_updatePassword"

private let kNotice             = "kCOD_notice"
private let kVoipNotice         = "kCOD_voipnotice"
private let kNoticeDetail       = "kCOD_noticedetail"
private let kSound              = "kCOD_sound"
private let kVibrate            = "kCOD_vibrate"
private let kPreview            = "kCOD_preview"
private let kSmsLogin           = "kCOD_smslogin"
private let kSearchUser         = "kCOD_searchuser"
private let kCOD_deviceToekn    = "kCOD_deviceToekn"
private let kCOD_voipToekn      = "kCOD_voipToekn"
private let kCOD_session        = "kCOD_session"
private let kCOD_resource        = "kCOD_resource"
private let kCOD_readreceipt    = "kCOD_readreceipt"
private let kCOD_searchtel      = "kCOD_searchtel"
private let kCOD_addincard      = "kCOD_addincard"
private let kCOD_addingroup     = "kCOD_addingroup"
private let kCOD_addinqrcode    = "kCOD_addinqrcode"
private let kCOD_timeStamp      = "kCOD_timeStamp"
private let kCOD_spreadMessageCount = "kCOD_spreadMessageCount"
private let kCOD_spreadMessagePic   = "kCOD_spreadMessagePic"
private let kCOD_circleFirstPic     = "kCOD_circleFirstPic"
private let kCOD_contactSortType    = "kCOD_contactSortType"
private let kCOD_chatDrafts         = "kCOD_chatDrafts"
private let kCOD_chooseGoodWork     = "kCOD_chooseGoodWork"

private let kCOD_lastOnlineTime      = "kCOD_lastOnlineTime"
private let kCOD_allowVoip           = "kCOD_allowVoip"
private let kCOD_showTel             = "kCOD_showTel"
private let kCOD_xhassstickytop      = "kCOD_xhassstickytop"
private let kCOD_allowJoinGroup      = "kCOD_allowJoinGroup"
private let kCOD_allowJoinChannel      = "kCOD_allowJoinChannel"
private let kCOD_allowMessage        = "kCOD_allowMessage"
private let kCOD_xhnfmute        = "kCOD_xhnfmute"
private let kCOD_xhnfsticktop        = "kCOD_xhnfsticktop"

struct DeviceInfo {
    static var uuidString: String {

        if let uuid = CODUserDefaults.string(forKey: "DeviceInfo.uuid") {
            return uuid
        } else {
            var uuid = UUID().uuidString
            #if targetEnvironment(simulator)
              // Simulator!
            #else
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled == true && UserManager.sharedInstance.isLogin {
                uuid = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            }
            #endif
            
            CODUserDefaults.set(uuid, forKey: "DeviceInfo.uuid")

            return uuid
        }
    }
}

extension Reactive where Base: UserManager {
    
    /// 朋友圈的点赞评论数
    var spreadMessageCount: Observable<Int> {
        return UserDefaults.standard.rx.observe(Int.self, kCOD_spreadMessageCount).filterNil()
    }
    
    var spreadMessagePic: Observable<String> {
        return UserDefaults.standard.rx.observe(String.self, kCOD_spreadMessagePic).filterNil()
    }
    
    var circleFirstPic: Observable<String> {
        return UserDefaults.standard.rx.observe(String.self, kCOD_circleFirstPic).filterNil()
    }
    
    var contactSortType: Observable<Int> {
        return UserDefaults.standard.rx.observe(Int.self, kCOD_contactSortType).filterNil()
    }
    
}




@objc class UserManager: NSObject {
    class var sharedInstance : UserManager {
        struct Static {
            static let instance : UserManager = UserManager()
        }
        return Static.instance
    }
    
    fileprivate override init() {
        super.init()
    }
    
    
    /// 推送token
    var token: String?{
        get { return UserDefaults.cod_stringForKey(kCOD_deviceToekn) }
        set (newValue) { UserDefaults.cod_setString(kCOD_deviceToekn, value: newValue) }
    }
    
    var voipToken : String?{
        get{ return UserDefaults.cod_stringForKey(kCOD_voipToekn) }
        set (newValue) { UserDefaults.cod_setString(kCOD_voipToekn, value: newValue) }
    }
    
    var session: String? {
        get {
            return UserDefaults.cod_stringForKey(kCOD_session)
        }
        set(newValue) {
            UserDefaults.cod_setString(kCOD_session, value: newValue)
        }
    }
    
    var resource: String? {
        get { return UserDefaults.cod_stringForKey(kCOD_resource, defaultValue: "MOBILE") }
        set (newValue) { UserDefaults.cod_setString(kCOD_resource, value: newValue) }
    }
    
    /// 用户昵称，不是登录名
    var nickname: String? {
        get { return UserDefaults.cod_stringForKey(kNickname, defaultValue: "") }
        set (newValue) {
            UserDefaults.cod_setString(kNickname, value: newValue)
        }
    }
    var avatar: String? {
        get { return UserDefaults.cod_stringForKey(kAvatar, defaultValue: "default_header_80") }
        set (newValue) { UserDefaults.cod_setString(kAvatar, value: newValue?.getHeaderImageFullPath(imageType: 0)) }
    }
    var areaNum: String? {
        get { return UserDefaults.cod_stringForKey(kAreaNum, defaultValue: "86") }
        set (newValue) { UserDefaults.cod_setString(kAreaNum, value: newValue) }
    }
    
    var countryName : String?{
        get {return UserDefaults.cod_stringForKey(kCountryName,defaultValue: "")}
        set (newValue) {UserDefaults.cod_setString(kCountryName, value: newValue)}
    }
    
    var phoneNum: String? {
        get { return UserDefaults.cod_stringForKey(kPhoneNum, defaultValue: "") }
        set (newValue) {
            UserDefaults.cod_setString(kPhoneNum, value: newValue)
        }
    }
    
    var isLogin: Bool {
        get { return UserDefaults.cod_boolForKey(kIsLogin, defaultValue: false) }
        set (newValue) { UserDefaults.cod_setBool(kIsLogin, value: newValue) }
    }
    
    /// 个性签名
    var intro: String? {
        get {return UserDefaults.cod_stringForKey(kIntro, defaultValue: "")}
        set (newValue) {UserDefaults.cod_setString(kIntro, value: newValue)}
    }
    
    /// xmpp登录账号：cod_60000007
    var loginName: String? {
        get { return UserDefaults.cod_stringForKey(kLoginName, defaultValue: "") }
        set (newValue) {
            UserDefaults.cod_setString(kLoginName, value: newValue)
            updateAuthorization()
        }

    }
    
    /// 用户名
    var userDesc: String? {
        get { return UserDefaults.cod_stringForKey(kUserDesc, defaultValue: "") }
        set (newValue) { UserDefaults.cod_setString(kUserDesc, value: newValue) }
    }
    
    var jid: String {
        return String(format: "%@%@", UserDefaults.cod_stringForKey(kLoginName, defaultValue: "")!, XMPPSuffix)
    }
    
    var password: String? {
        get { return UserDefaults.cod_stringForKey(kPassword, defaultValue: "") }
        set (newValue) {
            UserDefaults.cod_setString(kPassword, value: newValue)
            updateAuthorization()
        }

    }
    
    //是否已修改密码
    var changePwd: Bool? {
        get { return UserDefaults.cod_boolForKey(kUpdatePassword, defaultValue: true) }
        set (newValue) { UserDefaults.cod_setBool(kUpdatePassword, value: newValue ?? true) }
    }

    func updateAuthorization() {

        let version = CustomUtil.getVersionForHeader()

        SDWebImageDownloader.shared.setValue("*/*", forHTTPHeaderField: "Accept")
        SDWebImageDownloader.shared.setValue(kAuthorization, forHTTPHeaderField:"Authorization")
        SDWebImageDownloader.shared.setValue(UserManager.sharedInstance.session ?? "", forHTTPHeaderField:"xh-user-token")
        SDWebImageDownloader.shared.setValue(UserManager.sharedInstance.loginName ?? "", forHTTPHeaderField:"xh-user-name")
        SDWebImageDownloader.shared.setValue(UserManager.sharedInstance.resource ?? "", forHTTPHeaderField:"xh-user-resource")
        SDWebImageDownloader.shared.setValue("application/json", forHTTPHeaderField: "Content-Type")
        SDWebImageDownloader.shared.setValue(version, forHTTPHeaderField:"version")
        SDWebImageDownloader.shared.config.downloadTimeout = 30
        SDWebImageDownloader.shared.config.urlCredential = ClientTrust.sendClientCer()
        
    }
    
    @objc class func getVideoDownLoaderHeader() -> Dictionary<String, Any> {
        let nameStr = String(format: "%@:%@",UserManager.sharedInstance.loginName ?? "",UserManager.sharedInstance.password ?? "")
        let utf8Data = nameStr.data(using: String.Encoding.utf8)
        let base64String = utf8Data?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        let authValue = String(format: "Basic %@", base64String ?? "")
        
        let version = CustomUtil.getVersionForHeader()
        
        return ["Accept":"*/*",
                "Authorization":authValue,
                "xh-user-token":UserManager.sharedInstance.session ?? "",
                "xh-user-name":UserManager.sharedInstance.loginName ?? "",
                "xh-user-resource":UserManager.sharedInstance.resource ?? "",
                "version": version]
    }
    
    /// 性别（male/female）
    @objc dynamic var sex: String {
        get {
            if let gender = UserDefaults.cod_stringForKey(kSex, defaultValue: "") {
                if gender.count > 0 {
                    if gender.compareNoCaseForString("MALE") {
                        return "男"
                    }else{
                        return "女"
                    }
                }else{
                    return "男"
                }
            }
            return ""
        }
        set (newValue) {
            UserDefaults.cod_setString(kSex, value: newValue)
        }
    }
    var email: String? {
        get { return UserDefaults.cod_stringForKey(kEmail, defaultValue: "未设置") }
        set (newValue) { UserDefaults.cod_setString(kEmail, value: newValue) }
    }
    
    
    /// 新消息通知
    @objc dynamic var notice: Bool {
        get { return UserDefaults.cod_boolForKey(kNotice, defaultValue: true) }
        set (newValue) {UserDefaults.cod_setBool(kNotice, value: newValue) }
    }
    
    /// 语音聊天通知
    @objc dynamic var voipNotice: Bool {
        get { return UserDefaults.cod_boolForKey(kVoipNotice, defaultValue: true) }
        set (newValue) { UserDefaults.cod_setBool(kVoipNotice, value: newValue) }
    }
    
    /// 通知显示发送人信息
    @objc dynamic var noticeDetail: Bool {
        get { return UserDefaults.cod_boolForKey(kNoticeDetail, defaultValue: true) }
        set (newValue) { UserDefaults.cod_setBool(kNoticeDetail, value: newValue) }
    }
    
    /// 声音
    @objc dynamic var sound: Bool {
        get { return UserDefaults.cod_boolForKey(kSound, defaultValue: true) }
        set (newValue) { UserDefaults.cod_setBool(kSound, value: newValue) }
    }
    
    /// 震动
    @objc dynamic var vibrate: Bool {
        get { return UserDefaults.cod_boolForKey(kVibrate, defaultValue: false) }
        set (newValue) { UserDefaults.cod_setBool(kVibrate, value: newValue) }
    }
    
    /// 预览
    @objc dynamic var preview: Bool {
        get { return UserDefaults.cod_boolForKey(kPreview, defaultValue: true) }
        set (newValue) { UserDefaults.cod_setBool(kPreview, value: newValue) }
    }
    
    /// 禁用验证码登录功能
    var smsLogin: Bool {
        get { return UserDefaults.cod_boolForKey(kSmsLogin, defaultValue: false) }
        set (newValue) { UserDefaults.cod_setBool(kSmsLogin, value: newValue) }
    }
    
    /// 用户名被搜索
    var searchUser: Bool {
        get { return UserDefaults.cod_boolForKey(kSearchUser, defaultValue: true) }
        set (newValue) { UserDefaults.cod_setBool(kSearchUser, value: newValue) }
    }
    
    /// 手机号码被搜索
    var searchtel: Bool {
        get { return UserDefaults.cod_boolForKey(kCOD_searchtel, defaultValue: true) }
        set (newValue) { UserDefaults.cod_setBool(kCOD_searchtel, value: newValue) }
    }
    
    /// 群组添加
    var addingroup: Bool {
        get { return UserDefaults.cod_boolForKey(kCOD_addingroup, defaultValue: true) }
        set (newValue) { UserDefaults.cod_setBool(kCOD_addingroup, value: newValue) }
    }
    
    /// 二维码添加
    var addinqrcode: Bool {
        get { return UserDefaults.cod_boolForKey(kCOD_addinqrcode, defaultValue: true) }
        set (newValue) { UserDefaults.cod_setBool(kCOD_addinqrcode, value: newValue) }
    }
    
    /// 名片添加
    var addincard: Bool {
        get { return UserDefaults.cod_boolForKey(kCOD_addincard, defaultValue: true) }
        set (newValue) { UserDefaults.cod_setBool(kCOD_addincard, value: newValue) }
    }
    
    /// 允许好友查看最后上线时间
    var lastOnlineTime: String? {
        get { return UserDefaults.cod_stringForKey(kCOD_lastOnlineTime, defaultValue: kCOD_all) }
        set (newValue) { UserDefaults.cod_setString(kCOD_lastOnlineTime, value: newValue) }
    }
    
    /// 允许语音通话
    var allowVoip: String? {
        get { return UserDefaults.cod_stringForKey(kCOD_allowVoip, defaultValue: kCOD_all) }
        set (newValue) { UserDefaults.cod_setString(kCOD_allowVoip, value: newValue) }
    }
     
    /// 是否对好友显示电话号码
    var showTel: String? {
        get { return UserDefaults.cod_stringForKey(kCOD_showTel, defaultValue: kCOD_all) }
        set (newValue) { UserDefaults.cod_setString(kCOD_showTel, value: newValue) }
    }
    
    /// 云盘是否置顶
    var xhassstickytop: Bool {
        get { return UserDefaults.cod_boolForKey(kCOD_xhassstickytop, defaultValue: false) }
        set (newValue) { UserDefaults.cod_setBool(kCOD_xhassstickytop, value: newValue) }
    }
    
    /// 新的好友是否静音
    var xhnfmute: Bool {
        get { return UserDefaults.cod_boolForKey(kCOD_xhnfmute, defaultValue: false) }
        set (newValue) { UserDefaults.cod_setBool(kCOD_xhnfmute, value: newValue) }
    }
    
    /// 新的好友是否置顶
    var xhnfsticktop: Bool {
        get { return UserDefaults.cod_boolForKey(kCOD_xhnfsticktop, defaultValue: false) }
        set (newValue) { UserDefaults.cod_setBool(kCOD_xhnfsticktop, value: newValue) }
    }
    
    /// 允许被邀请进群
    var allowJoinGroup: String? {
        get { return UserDefaults.cod_stringForKey(kCOD_allowJoinGroup, defaultValue: kCOD_all) }
        set (newValue) { UserDefaults.cod_setString(kCOD_allowJoinGroup, value: newValue) }
    }
    
    /// 允许被邀请进群
    var allowJoinChannel: String? {
        get { return UserDefaults.cod_stringForKey(kCOD_allowJoinChannel, defaultValue: kCOD_all) }
        set (newValue) { UserDefaults.cod_setString(kCOD_allowJoinChannel, value: newValue) }
    }
    
    /// 允许接收消息
    var allowMessage: String? {
        get { return UserDefaults.cod_stringForKey(kCOD_allowMessage, defaultValue: kCOD_all) }
        set (newValue) { UserDefaults.cod_setString(kCOD_allowMessage, value: newValue) }
    }
    
    /// 时间偏移量
    var timeStamp: Int {
        get { return UserDefaults.cod_integerForKey(kCOD_timeStamp, defaultValue: 0) }
        set (newValue) { UserDefaults.cod_setInteger(kCOD_timeStamp, value: newValue) }
    }
    
    
    /// 已读回执
    var readreceipt: Bool {
        get { return UserDefaults.cod_boolForKey(kCOD_readreceipt, defaultValue: true) }
        set (newValue) { UserDefaults.cod_setBool(kCOD_readreceipt, value: newValue) }
    }
    
    /// 新好友提醒
    var haveNewFriend: Int {
        get { return CODChatListRealmTool.getNewFriendCount() }
        set (newValue) {
            if let rootVC = UIApplication.shared.keyWindow?.rootViewController as? CODCustomTabbarViewController {
                if newValue <= 0 {
                    rootVC.tabBar.items?[0].badgeValue = nil
                }else{
                    rootVC.tabBar.items?[0].cyl_badgeFrame = CGRect.init(x: 0, y: 0, width: 8, height: 8)
                    rootVC.tabBar.items?[0].cyl_badgeRadius = 4
                    rootVC.tabBar.items?[0].cyl_badgeBackgroundColor = .red
                    rootVC.tabBar.items?[0].cyl_showBadge()
                }
            }
            CODChatListRealmTool.setNewFriendCount(count: newValue < 0 ? 0 : newValue)
        }
    }
    
    
    /// 朋友圈的点赞评论数
    var spreadMessageCount: Int {
        get { return UserDefaults.cod_integerForKey(kCOD_spreadMessageCount, defaultValue: 0) }
        set (newValue) {
            UserDefaults.cod_setInteger(kCOD_spreadMessageCount, value: newValue)
        }
    }
    
    var spreadMessagePic: String {
        get { return UserDefaults.cod_stringForKey(kCOD_spreadMessagePic, defaultValue: "")! }
        set (newValue) { UserDefaults.cod_setString(kCOD_spreadMessagePic, value: newValue) }
    }
    
    var circleFirstPic: String {
        get { return UserDefaults.cod_stringForKey(kCOD_circleFirstPic, defaultValue: "")! }
        set (newValue) {
            UserDefaults.cod_setString(kCOD_circleFirstPic, value: newValue)
        }
    }
    
    var chatDrafts: [String : AnyObject]? {
        get { return UserDefaults.cod_dictionaryForKey(kCOD_chatDrafts, defaultValue: nil) }
        set (newValue) {
            guard let newvalue = newValue else { return }
            UserDefaults.cod_setDictionary(kCOD_chatDrafts, value: newvalue)
        }
    }
    
    /// 朋友圈背景，从优秀作品选择
    var chooseGoodWork: Int? {
        
        get {
            return CODUserDefaults.integer(forKey: "\(kCOD_chooseGoodWork)_(\(self.jid)")
        }
        set (newValue) {
            
            if let newValue = newValue {
                UserDefaults.cod_setInteger("\(kCOD_chooseGoodWork)_(\(self.jid)", value: newValue)
            } else {
                CODUserDefaults.removeObject(forKey: "\(kCOD_chooseGoodWork)_(\(self.jid)")
            }
            
        }
        
    }
    
    
    /// 联系人的排序方式：1：按姓名     2：按上线时间
    var contactSortType: Int {
        get { return UserDefaults.cod_integerForKey(kCOD_contactSortType, defaultValue: 0) }
        set (newValue) { UserDefaults.cod_setInteger(kCOD_contactSortType, value: newValue) }
    }
    
    var userInfoSetting = CODUserInfoAndSetting() {
        didSet {
            if let name = userInfoSetting.name {
                if name.count > 0 {
                    self.nickname = name
                    if let members = CODGroupMemberRealmTool.getMembersByJid(self.jid) {
                        if members.count > 0 {
                            try! Realm.init().write {
                                for member in members {
                                    member.name = name
                                }
                            }
                        }
                    }
                }
            }
            
            if let userpic = userInfoSetting.userpic {
                if userpic.count > 0 {
                    self.avatar = userpic
                }
            }
            if let notice = userInfoSetting.notice {
                self.notice = notice
            }
            if let smslogin = userInfoSetting.smslogin {
                self.smsLogin = smslogin
            }
            if let noticedetail = userInfoSetting.noticedetail {
                self.noticeDetail = noticedetail
            }
            if let sex = userInfoSetting.gender {
                self.sex = sex
            }
            if let searchuser = userInfoSetting.searchuser {
                self.searchUser = searchuser
            }
            //因产品经理以及公司领导联合决定，将应用内“声音”，“震动”功能开关状态保存在本地，不以服务器为准
//            if let sound = userInfoSetting.sound {
//                self.sound = sound
//            }
//            if let vibrate = userInfoSetting.vibrate {
//                self.vibrate = vibrate
//            }
            if let userdesc = userInfoSetting.userdesc {
                if userdesc.count > 0 {
                    self.userDesc = userdesc
                }
            }
            if let voipnotice = userInfoSetting.voipnotice {
                self.voipNotice = voipnotice
            }
            if let email = userInfoSetting.email {
                if email.count > 0 {
                    self.email = email
                }
            }
            if let readreceipt = userInfoSetting.readreceipt {
                self.readreceipt = readreceipt
            }
            if let searchtel = userInfoSetting.searchtel {
                self.searchtel = searchtel
            }
            if let addingroup = userInfoSetting.addingroup {
                self.addingroup = addingroup
            }
            if let addincard = userInfoSetting.addincard {
                self.addincard = addincard
            }
            if let addinqrcode = userInfoSetting.addinqrcode {
                self.addinqrcode = addinqrcode
            }
            
            if let lastOnlineTime = userInfoSetting.lastLoginTimeVisible {
                self.lastOnlineTime = lastOnlineTime
            }
            
            if let allowVoip = userInfoSetting.callVisible {
                self.allowVoip = allowVoip
            }
            
            if let showTel = userInfoSetting.showtel {
                self.showTel = showTel
            }
            
            if let xhassstickytop = userInfoSetting.xhassstickytop {
                self.xhassstickytop = xhassstickytop
                if let model:CODChatListModel = CODChatListRealmTool.getChatList(jid: kCloudJid) {
                    try! Realm.init().write {
                        model.stickyTop = xhassstickytop
                    }
                }
            }
            
            if let xhnfmute = userInfoSetting.xhnfmute {
                self.xhnfmute = xhnfmute
                if let model:CODChatListModel = CODChatListRealmTool.getChatList(jid: NewFriendJid) {
                    try! Realm.init().write {
                        model.mute = xhnfmute
                    }
                }
            }

            if let xhnfsticktop = userInfoSetting.xhnfsticktop {
                self.xhnfsticktop = xhnfsticktop
                if let model:CODChatListModel = CODChatListRealmTool.getChatList(jid: NewFriendJid) {
                    try! Realm.init().write {
                        model.stickyTop = xhnfsticktop
                    }
                }
            }

            if let allowJoinGroup = userInfoSetting.inviteJoinRoomVisible {
                self.allowJoinGroup = allowJoinGroup
            }
            if let allowJoinChannel = userInfoSetting.xhinvitejoinchannel {
                self.allowJoinChannel = allowJoinChannel
            }
            
            if let allowMessage = userInfoSetting.messageVisible {
                self.allowMessage = allowMessage
            }
            
            if let phoneNum = userInfoSetting.tel {
                self.phoneNum = phoneNum
            }
            
            if let areaNum = userInfoSetting.areacode {
                self.areaNum = areaNum
            }
            
            if let xhabout = userInfoSetting.xhabout {
                self.intro = xhabout
            }
            
            if let about = userInfoSetting.about {
                self.intro = about
            }
            
            if let updatePassword = userInfoSetting.changePwd {
                self.changePwd = updatePassword
            }
            
        }
    }
    
    
    /**
     webService服务器获取xmpp账号密码成功
     - parameter result: 获取xmpp账号成功后传进来的字典
     */
    func getUserSuccess(_ result: JSON) {
        assert(!(result["username"].string?.contains(XMPPSuffix))!, "username不能包含后缀")
        self.loginName = result["username"].stringValue
        self.password = result["password"].stringValue
        self.isLogin = true
    }
    
    /**
     退出登录
     */
    func userLogout() {
        NotificationCenter.default.post(name: NSNotification.Name.init(kLoginoutNoti), object: nil, userInfo: nil)
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.manager?.stopListening()
        
        MiPushSDK.unsetAlias(self.loginName)
        self.cleanUserInfo()
        CODUserDefaults.set(false, forKey: AccountAndSecurity_Red_Point)
//        CODUserDefaults.set(false, forKey: HAVE_NEWFRIEND_NOTICATION)
        //清除头像的缓存，防止换设备更换头像，头像不会刷新
        CustomUtil.removeImageCahch(imageUrl: self.avatar ?? "")
        CustomUtil.removeImageCahch(imageUrl: self.avatar?.getImageFullPath(imageType: 1) ?? "")
        CustomUtil.removeImageCahch(imageUrl: self.avatar?.getImageFullPath(imageType: 2) ?? "")
        CustomUtil.removeImageCahch(imageUrl: self.avatar?.getImageFullPath(imageType: 3) ?? "")
        NotificationCenter.default.post(name: NSNotification.Name.init(kClearUserInfoNoti), object: nil, userInfo: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            try? Realm().invalidate()
        }


    }
    
    func cleanUserInfo() {
        self.loginName = nil
        self.password = nil
        self.avatar = nil
        self.session = nil
        self.nickname = nil
        self.phoneNum = nil
        self.userDesc = nil
        self.email = nil
        self.sex = ""
        self.intro = ""
        self.isLogin = false
        self.smsLogin = false
        self.addincard = true
        self.addingroup = true
        self.addinqrcode = true
        self.notice = true
        self.noticeDetail = true
        self.readreceipt = true
        self.searchtel = true
        self.searchUser = true
//        self.sound = true
//        self.vibrate = true
        self.voipNotice = true
        
        self.allowVoip = kCOD_all
        self.lastOnlineTime = kCOD_all
        self.allowJoinGroup = kCOD_all
        self.allowJoinChannel = kCOD_all
        self.allowMessage = kCOD_all
        self.showTel = kCOD_all

        print("cleanUserInfo")
    }
    
    ///获取MessageID
    func getMessageId() -> String {
        let timeInterval = Date.milliseconds
        let date = String(format: "%.0f", timeInterval)
        let timeInterValStr = date.truncated(toLength: 13)
        let subUsername = self.loginName?.slicing(from: 6, length: 6)
        return String(format: "%@%@", timeInterValStr,subUsername ?? "")
    }
    
    ///获取CloudDiskMessageID
    func getCloudDiskMessageId() -> String {
        let timeInterval = Date.milliseconds
        let date = String(format: "%.0f", timeInterval)
        let timeInterValStr = date.truncated(toLength: 13)
        return String(format: "%@%@", timeInterValStr,"000000")
    }
}
