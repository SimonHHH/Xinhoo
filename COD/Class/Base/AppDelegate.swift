//
//  AppDelegate.swift
//  COD
//
//  Created by XinHoo on 2019/2/18.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
//import JitsiMeet
import AdSupport
import PushKit
import CallKit
//import DoraemonKit
import SDWebImage
#if XINHOO
import EchoSDK
#endif
import LGAlertView

import SafariServices

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import SwiftyJSON

struct ConnectServerInfo {
    let address: String
    let port: Int
    
    var host: String {
        
        if let url = address.url, url.scheme != nil {
            
            return url.host ?? ""
            
        } else {
            return address
        }

    }
    
    var serverHttpsURL: String {
        
        guard var url = URL(string: address) else { return address }
        
        if url.scheme == nil {
            
            if let newURL = URL(string: "https://\(address)") {
                url = newURL
            }
            
        }
        
        if url.port == nil && port > 0 {
            if let newURL = URL(string: "https://\(address):\(port)") {
                url = newURL
            }
        }
        
        return url.absoluteString

    }
    
    func toJson() -> [String: Any] {
        
        return [
            "address": address,
            "port": port
        ]
        
    }
    
    init(address: String, port: Int) {
        self.address = address
        self.port = port
    }
    
    init(json: JSON) {
        address = json["address"].stringValue
        port = json["port"].intValue
    }
    
}

struct CODAppInfo {
    struct serverConfig {
        let uploadfileAllowsMaxsize: String?
        let uploadfileAllowsType: String?
        let chatLimitMessageDelete: String?
        let groupLimitMessageDelete: String?
        let messageDditTimeLimit: String?
        let qrcodePrefix: String?
        let channelLimitMessageDelete: String?
        init(json: JSON) {

            uploadfileAllowsMaxsize = json["uploadfileAllowsMaxsize"].stringValue
            uploadfileAllowsType = json["uploadfileAllowsType"].stringValue
            chatLimitMessageDelete = json["chatLimitMessageDelete"].stringValue
            groupLimitMessageDelete = json["groupLimitMessageDelete"].stringValue
            messageDditTimeLimit = json["messageDditTimeLimit"].stringValue
            qrcodePrefix = json["qrcodePrefix"].stringValue
            channelLimitMessageDelete = json["channelLimitMessageDelete"].stringValue
        }
    }
    struct ServerClass {
        
        let descZht: String?
        let descZh: String?
        let descEn: String?
        
        let localTeamName: String
        
        var teamName: String {
            
            let lan = CustomUtil.getLangString()
            
            switch lan {
            case "zh":
                if let descZh = descZh, descZh.count > 0 {
                    return descZh
                } else {
                    return localTeamName
                }
            case "en":
                if let descEn = descEn, descEn.count > 0 {
                    return descEn
                } else {
                    return localTeamName
                }
            case "zht":
                if let descZht = descZht, descZht.count > 0 {
                    return descZht
                } else {
                    return localTeamName
                }
            default:
                return localTeamName
            }
            
            
            
        }
        
        let imServer: ConnectServerInfo
        
        let apiServer: ConnectServerInfo
        
        let fileServer: ConnectServerInfo
        
        let restApiServer: ConnectServerInfo
        
        let momnetServer: ConnectServerInfo
        
        
        func toJsonString() -> String? {
            
            return [
                "momentServers": momnetServer.toJson(),
                "apiServers": apiServer.toJson(),
                "imServers": imServer.toJson(),
                "fileServers": fileServer.toJson(),
                "restApiServers": restApiServer.toJson(),
                "descZh": descZh ?? "",
                "descEn": descEn ?? "",
                "descZht": descZht ?? ""
            ]
            .jsonString()
            
        }
        
        init(localTeamName: String, imServer: ConnectServerInfo, apiServer: ConnectServerInfo, fileServer: ConnectServerInfo, restApiServer: ConnectServerInfo, momnetServer: ConnectServerInfo) {
            self.localTeamName = localTeamName
            self.imServer = imServer
            self.apiServer = apiServer
            self.fileServer = fileServer
            self.restApiServer = restApiServer
            self.momnetServer = momnetServer
            self.descZh = nil
            self.descEn = nil
            self.descZht = nil
        }
        
        init(json: JSON) {
            let imServers = json["imServers"]
            let fileServers = json["fileServers"]
            let apiServers = json["apiServers"]
            
            let restApiServers = json["restApiServers"]
            let momentServers = json["momentServers"]
            
            localTeamName = json["descZh"].stringValue
            descZh = json["descZh"].stringValue
            descEn = json["descEn"].stringValue
            descZht = json["descZht"].stringValue
            
            imServer = ConnectServerInfo(json: imServers)
            apiServer = ConnectServerInfo(json: apiServers)
            fileServer = ConnectServerInfo(json: fileServers)
            restApiServer = ConnectServerInfo(json: restApiServers)
            momnetServer = ConnectServerInfo(json: momentServers)

        }
        
        
    }
    
    
    struct CODAppKey {
        
        #if MANGO
        static let appcenterAppID = "762c7d3c-f99a-4253-9f09-3fe6f8e29a88"
        
        #elseif PRO
        static let appcenterAppID = "c104973f-0d1e-4527-a75e-8122a6620d4d"
        
        #else
        static let appcenterAppID = "c5ee7a37-116f-49e3-aa74-cbb957e6e5da"
        #endif
        
        
    }
    
    static var uploadfileAllowsMaxsize: String {
        if let uploadfileAllowsMaxsize = UserDefaults.standard.string(forKey: kServerConfig) {
        
        return ""
        } else {
        
        return ""
        }
    }
    
    
    #if MANGO
    static let channelSharePublicLink = "https://imango.im/"
    static let channelSharePrivateLink = "https://imango.im/joinchat/"
    
    
    
    
    
    static var serverList:[ServerClass] {
        
        if let serversList = UserDefaults.standard.string(forKey: kServersList) {
        
        return getServerList(JSON(parseJSON: serversList))
        
        } else {
        

        let server1 = ServerClass(
        localTeamName: NSLocalizedString("主服务器", comment: ""),
        imServer: .init(address: "im.rezffb.com", port: 5222),
        apiServer: .init(address: "https://imapi.rezffb.com", port: 0),
        fileServer: .init(address: "https://file.rezffb.com", port: 0),
        restApiServer: .init(address: "https://restapi.rezffb.com", port: 0),
        momnetServer: .init(address: "https://moments.rezffb.com", port: 0)
        )
        
        let server2 = ServerClass(
        localTeamName: NSLocalizedString("其他服务器0", comment: "") + "1",
        imServer: .init(address: "im.mg-hk02.com", port: 5222),
        apiServer: .init(address: "https://imapi.mg-hk02.com", port: 0),
        fileServer: .init(address: "https://file.mg-hk02.com", port: 0),
        restApiServer: .init(address: "https://restapi.mg-hk02.com", port: 0),
        momnetServer: .init(address: "https://moments.mg-hk02.com", port: 0)
        )
        
        let server3 = ServerClass(
        localTeamName: NSLocalizedString("其他服务器0", comment: "") + "2",
        imServer: .init(address: "im.mg-hk03.com", port: 5222),
        apiServer: .init(address: "https://imapi.mg-hk03.com", port: 0),
        fileServer: .init(address: "https://file.mg-hk03.com", port: 0),
        restApiServer: .init(address: "https://restapi.mg-hk03.com", port: 0),
        momnetServer: .init(address: "https://moments.mg-hk03.com", port: 0)
        )
        
        let server4 = ServerClass(
        localTeamName: NSLocalizedString("其他服务器0", comment: "") + "3",
        imServer: .init(address: "im.mg-hk04.com", port: 5222),
        apiServer: .init(address: "https://imapi.mg-hk04.com", port: 0),
        fileServer: .init(address: "https://file.mg-hk04.com", port: 0),
        restApiServer: .init(address: "https://restapi.mg-hk04.com", port: 0),
        momnetServer: .init(address: "https://moments.mg-hk04.com", port: 0)
        )
        
        let server5 = ServerClass(
        localTeamName: NSLocalizedString("其他服务器0", comment: "") + "4",
        imServer: .init(address: "im.mg-hk05.com", port: 5222),
        apiServer: .init(address: "https://imapi.mg-hk05.com", port: 0),
        fileServer: .init(address: "https://file.mg-hk05.com", port: 0),
        restApiServer: .init(address: "https://restapi.mg-hk05.com", port: 0),
        momnetServer: .init(address: "https://moments.mg-hk05.com", port: 0)
        )
        
        let server6 = ServerClass(
        localTeamName: NSLocalizedString("其他服务器0", comment: "") + "5",
        imServer: .init(address: "im.mg-ph06.com", port: 5222),
        apiServer: .init(address: "https://imapi.mg-ph06.com", port: 0),
        fileServer: .init(address: "https://file.mg-ph06.com", port: 0),
        restApiServer: .init(address: "https://restapi.mg-ph06.com", port: 0),
        momnetServer: .init(address: "https://moments.mg-ph06.com", port: 0)
        )
        
        let server7 = ServerClass(
        localTeamName: NSLocalizedString("其他服务器0", comment: "") + "6",
        imServer: .init(address: "im.mg-ph07.com", port: 5222),
        apiServer: .init(address: "https://imapi.mg-ph07.com", port: 0),
        fileServer: .init(address: "https://file.mg-ph07.com", port: 0),
        restApiServer: .init(address: "https://restapi.mg-ph07.com", port: 0),
        momnetServer: .init(address: "https://moments.mg-ph07.com", port: 0)
        )

        return [
        server1,
        server2,
        server3,
        server4,
        server5,
        server6,
        server7,
        ]
        
        }
        
    }
    
    #elseif PRO
    static let channelSharePublicLink = "https://f.flygram.im/"
    static let channelSharePrivateLink = "https://f.flygram.im/joinchat/"
    
    static var serverList:[ServerClass] {
        
        if let serversList = UserDefaults.standard.string(forKey: kServersList) {
        
        return getServerList(JSON(parseJSON: serversList))
        
        } else {
        
        let server1 = ServerClass(
        localTeamName: NSLocalizedString("主服务器", comment: ""),
        imServer: .init(address: "im.r7lz6.com", port: 5222),
        apiServer: .init(address: "https://imapi.r7lz6.com", port: 0),
        fileServer: .init(address: "https://file.r7lz6.com", port: 0),
        restApiServer: .init(address: "https://restapi.r7lz6.com", port: 0),
        momnetServer: .init(address: "https://moments.r7lz6.com", port: 0)
        )
        
        let server2 = ServerClass(
        localTeamName: NSLocalizedString("其他服务器0", comment: "") + "1",
        imServer: .init(address: "im.fg-hk01.com", port: 5222),
        apiServer: .init(address: "https://imapi.fg-hk01.com", port: 0),
        fileServer: .init(address: "https://file.fg-hk01.com", port: 0),
        restApiServer: .init(address: "https://restapi.fg-hk01.com", port: 0),
        momnetServer: .init(address: "https://moments.fg-hk01.com", port: 0)
        )
        
        let server3 = ServerClass(
        localTeamName: NSLocalizedString("其他服务器0", comment: "") + "2",
        imServer: .init(address: "im.fg-hk02.com", port: 5222),
        apiServer: .init(address: "https://imapi.fg-hk02.com", port: 0),
        fileServer: .init(address: "https://file.fg-hk02.com", port: 0),
        restApiServer: .init(address: "https://restapi.fg-hk02.com", port: 0),
        momnetServer: .init(address: "https://moments.fg-hk02.com", port: 0)
        )
        
        
        let server4 = ServerClass(
        localTeamName: NSLocalizedString("其他服务器0", comment: "") + "3",
        imServer: .init(address: "im.fg-hk03.com", port: 5222),
        apiServer: .init(address: "https://imapi.fg-hk03.com", port: 0),
        fileServer: .init(address: "https://file.fg-hk03.com", port: 0),
        restApiServer: .init(address: "https://restapi.fg-hk03.com", port: 0),
        momnetServer: .init(address: "https://moments.fg-hk03.com", port: 0)
        )
        
        let server5 = ServerClass(
        localTeamName: NSLocalizedString("其他服务器0", comment: "") + "4",
        imServer: .init(address: "im.fg-hk04.com", port: 5222),
        apiServer: .init(address: "https://imapi.fg-hk04.com", port: 0),
        fileServer: .init(address: "https://file.fg-hk04.com", port: 0),
        restApiServer: .init(address: "https://restapi.fg-hk04.com", port: 0),
        momnetServer: .init(address: "https://moments.fg-hk04.com", port: 0)
        )
        
        let server6 = ServerClass(
        localTeamName: NSLocalizedString("其他服务器0", comment: "") + "5",
        imServer: .init(address: "im.fg-ph05.com", port: 5222),
        apiServer: .init(address: "https://imapi.fg-ph05.com", port: 0),
        fileServer: .init(address: "https://file.fg-ph05.com", port: 0),
        restApiServer: .init(address: "https://restapi.fg-ph05.com", port: 0),
        momnetServer: .init(address: "https://moments.fg-ph05.com", port: 0)
        )
        

        return [
        server1,
        server2,
        server3,
        server4,
        server5,
        server6,
        ]
        }
        
    }
    
    #else
    static let channelSharePublicLink = "https://f.me.xinhoo.com/"
    static let channelSharePrivateLink = "https://f.me.xinhoo.com/joinchat/"
    
    static var serverList: [ServerClass] {
        
        if let serversList = UserDefaults.standard.string(forKey: kServersList) {
        
        return getServerList(JSON(parseJSON: serversList))
        
        } else {
        
        
        let server1 = ServerClass(
        localTeamName: NSLocalizedString("主服务器", comment: ""),
        imServer: .init(address: "im-master.xinhoo.com", port: 5222),
        apiServer: .init(address: "https://imapi-master.xinhoo.com", port: 0),
        fileServer: .init(address: "https://file-master.xinhoo.com", port: 0),
        restApiServer: .init(address: "https://rest-master.xinhoo.com", port: 0),
        momnetServer: .init(address: "https://mom-master.xinhoo.com", port: 0)
        )
        
        
        let server2 = ServerClass(
        localTeamName: NSLocalizedString("其他服务器0", comment: "") + "1",
        imServer: .init(address: "im-cn01.xinhoo.com", port: 5222),
        apiServer: .init(address: "https://imapi-cn01.xinhoo.com", port: 0),
        fileServer: .init(address: "https://file-cn01.xinhoo.com", port: 0),
        restApiServer: .init(address: "https://rest-cn01.xinhoo.com", port: 0),
        momnetServer: .init(address: "https://mom-cn01.xinhoo.com", port: 0)
        )
        
        let server3 = ServerClass(
        localTeamName: NSLocalizedString("其他服务器0", comment: "") + "2",
        imServer: .init(address: "im-hk01.xinhoo.com", port: 5222),
        apiServer: .init(address: "https://imapi-hk01.xinhoo.com", port: 0),
        fileServer: .init(address: "https://file-hk01.xinhoo.com", port: 0),
        restApiServer: .init(address: "https://rest-hk01.xinhoo.com", port: 0),
        momnetServer: .init(address: "https://mom-hk01.xinhoo.com", port: 0)
        )
        
        return [
        server1,
        server2,
        server3
        ]
        }
        
    }
    
    #endif
    
    static func getServerList(_ json: JSON) -> [ServerClass] {
        
        let serverTeamList = json["serverTeamList"].arrayValue
        
        var serverList: [ServerClass] = []
        
        for serverTeam in serverTeamList {
            serverList.append(.init(json: serverTeam))
        }
        
        return serverList
        
    }
    
    
    static func getCurrentServerClass() -> ServerClass? {
        
        
        if let currentServerClass = UserDefaults.standard.string(forKey: kServersName) {
            
            return ServerClass(json: JSON(parseJSON: currentServerClass))
            

        } else {
            return nil
        }
        
        
    }
    
    static func isAllowsMaxsize(fileData: NSData, isShowHub: Bool = true) -> Bool{
        let dataCount = fileData.count / 1048576
 
        if dataCount > self.getUploadfileAllowsMaxsize()?.int ?? 0 {
            if isShowHub {
                CustomUtil.showUploadfileAllowsMaxsizeTip()
            }
            return false
        }
         return true
        
    }
    
    static func getUploadfileAllowsMaxsize() -> String? {
        
        if let ServerConfig = UserDefaults.standard.string(forKey: kServerConfig) {
            
            return serverConfig.init(json: JSON(parseJSON: ServerConfig)).uploadfileAllowsMaxsize
        } else {
            
            return "500"
        }
    }
    
    
}



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,BMKLocationAuthDelegate,MiPushSDKDelegate, UNUserNotificationCenterDelegate, CXCallObserverDelegate{
    
    var manager:NetworkReachabilityManager? = nil
    
    let callObserver = CXCallObserver()
    
    var window: UIWindow?
    var blockRotation = Bool()
    var floatVoiceWindow:CODFloatVoiceWindow?
    var floatVideoWindow:CODFloatVideoWindow?
    var mapManager:BMKMapManager? = nil
    var backgroundTask:UIBackgroundTaskIdentifier?
    var isLogin : Bool = false
    var isNetwork : Bool = true
    var curNavgation: UINavigationController? = nil
    
    var launchImageView:UIImageView?
    var pushInfo: [AnyHashable : Any]?
    
    var xmppConnectedSemaphore = DispatchSemaphore(value: 1)
    
    lazy var updateTipView : UpdateTipView = {
        
        let updateTipView = Bundle.main.loadNibNamed("UpdateTipView", owner: self, options: nil)?.last as! UpdateTipView
        updateTipView.frame = CGRect(x: 0, y: 0, width: 270, height: 300)
        updateTipView.iconImageView.image = UIImage.helpIcon()
        return updateTipView
    }()
    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        
        // "outgoing(拨打)  onHold(待接通)   hasConnected(接通)   hasEnded(挂断)"
//        if (!call.outgoing && !call.onHold && !call.hasConnected && !call.hasEnded) {
//            NSLog(@"来电");
//        } else if (!call.outgoing && !call.onHold && !call.hasConnected && call.hasEnded) {
//            NSLog(@"来电-挂掉(未接通)");
//        } else if (!call.outgoing && !call.onHold && call.hasConnected && !call.hasEnded) {
//            NSLog(@"来电-接通");
//        } else if (!call.outgoing && !call.onHold && call.hasConnected && call.hasEnded) {
//            NSLog(@"来电-接通-挂掉");
//        } else if (call.outgoing && !call.onHold && !call.hasConnected && !call.hasEnded) {
//            NSLog(@"拨打");
//        } else if (call.outgoing && !call.onHold && !call.hasConnected && call.hasEnded) {
//            NSLog(@"拨打-挂掉(未接通)");
//        } else if (call.outgoing && !call.onHold && call.hasConnected && !call.hasEnded) {
//            NSLog(@"拨打-接通");
//        } else if (call.outgoing && !call.onHold && call.hasConnected && call.hasEnded) {
//            NSLog(@"拨打-接通-挂掉");
//        }
        
        if !call.isOutgoing && !call.isOnHold && !call.hasConnected && !call.hasEnded {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kSendVoiceStopPlay), object: nil)
        }
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        callObserver.setDelegate(self, queue: DispatchQueue.main)
        
        #if XINHOO
        
        ECOClient.shared()?.registerPlugin(CODXmppPlugin.self)
        ECOClient.shared()?.start()
        #endif
        
        DebugTools.setup()
        CODLoggerFileManger.default.setup()
        CODGroupMemberOnlineManger.default.setup()
        CODAutoResendMessageManger.default.setup()
        //
        //        CODLoggerFileManger.default.fileLogger.log(message: <#T##DDLogMessage#>)
        
        //
        //        DDLogInfo("pushNotificationKey")
        //        if let pushNotificationKey = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable : Any] {
        //
        //        DDLogInfo("pushNotificationKey = \(pushNotificationKey)")
        //
        //            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
        //                DDLogInfo("self.pushToMessageVC(pushInfo: pushNotificationKey)")
        //                self.pushToMessageVC(pushInfo: pushNotificationKey)
        //            }
        //
        //
        //
        //        }
        
        CustomUtil.removeRoomJid()
        
        if UserManager.sharedInstance.isLogin {
            if let server = UserDefaults.standard.string(forKey: kServersName) {
                
                // ip地址清单有可能会变，用户保存的当前ip可能会被删掉，如果不包含则选择一个最优的ip
                
                let serverClass = CODAppInfo.serverList.first { (value) -> Bool in
                    return value.imServer.address == CODAppInfo.getCurrentServerClass()?.imServer.address
                }
                
                
                if let serverClass = serverClass {
                    AutoSwitchIPManager.share.updateServer(serverClass: serverClass)

                } else {
                    AutoSwitchIPManager.share.setBestIP()
                }
                
                
            }else{
                
                AutoSwitchIPManager.share.updateServer(serverClass: CODAppInfo.serverList[0])
            }
            
            
            
            
            
        }else{
            
            AutoSwitchIPManager.share.setBestIP()
            
        }
        
        UserDefaults.standard.set(true, forKey: kNewLifeCycle)
        
        
        
        XinhooTool.addLog(log: "应用启动")
        let screen = UIScreen.main.bounds
        window = UIWindow(frame: screen)
        window?.backgroundColor = .black
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        self.replyPushNotificationAuthorization(application: application)
        
        UILabel.initializeMethod()
        UIButton.initializeMethod()
        
        if (UserDefaults.standard.object(forKey: kMyLanguage) != nil) && (UserDefaults.standard.object(forKey: kMyLanguage) as! String != "") {
            Bundle.setLanguage(UserDefaults.standard.object(forKey: kMyLanguage) as? String)
        }else{
            let arr = UserDefaults.standard.object(forKey: "AppleLanguages") as? NSArray
            let languageStr = arr?.firstObject as? String
            if (languageStr?.contains("zh-Hans"))! {
                Bundle.setLanguage("zh-Hans")
            }else if (languageStr?.contains("en"))! {
                Bundle.setLanguage("en")
            }else if (languageStr?.contains("zh-Hant"))! {
                Bundle.setLanguage("zh-Hant")
            }else{
                Bundle.setLanguage("en")
            }
        }
        
//        checkUpdateVersion()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTabCount), name: NSNotification.Name.init(kReloadTabCount), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(alertDidDismiss), name: NSNotification.Name.LGAlertViewDidDismiss, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(videoPlay), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(videoPlay), name: NSNotification.Name(rawValue: "kImageBrowserHidden"), object: nil)
        
        /* 程序版本号是否跟上次不一样，如果不一样就推出引导页 */
        /* let infoDictionary = Bundle.main.infoDictionary
         let majorVersion :String? = infoDictionary!["CFBundleShortVersionString"] as! String?//主程序版本号
         
         if (UserDefaults.standard.string(forKey: kVersion) != nil) {
         
         if UserDefaults.standard.string(forKey: kVersion) != majorVersion {
         let vc = CODGuidePageViewController()
         vc.completeBlock = {
         UserDefaults.standard.set(majorVersion, forKey: kVersion)
         self.configRootViewController()
         }
         window?.rootViewController = vc
         window?.makeKeyAndVisible()
         }else{
         self.configRootViewController()
         }
         
         }else{
         let vc = CODGuidePageViewController()
         vc.completeBlock = {
         UserDefaults.standard.set(majorVersion, forKey: kVersion)
         self.configRootViewController()
         }
         window?.rootViewController = vc
         window?.makeKeyAndVisible()
         }*/
        
        /* 程序是否是第一次启动，如果是第一次启动就推出引导页   */
        
        if !UserDefaults.standard.bool(forKey: kIsFirst) {
            let vc = CODGuidePageViewController()
            vc.completeBlock = {
                UserDefaults.standard.set(true, forKey: kIsFirst)
                self.configRootViewController()
            }
            window?.rootViewController = vc
            window?.makeKeyAndVisible()
        }else{
            self.configRootViewController()
        }
        
        
        
        
        
        #if DEBUG
        #else
        MSAppCenter.start(CODAppInfo.CODAppKey.appcenterAppID, withServices: [MSCrashes.self,MSAnalytics.self])
        #endif
        
        if launchOptions == nil { return false }
        
        return true;
        //        return JitsiMeet.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
    }
    
    @objc func videoPlay(noti:Notification) {
        
        if !UserDefaults.standard.bool(forKey: kIsVideoCall) {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        
    }
    
    fileprivate func checkUpdateVersion() {
        //MARK: 检查版本更新
        
        //        #if MANGO || XINHOO
        
        let infoDictionary = Bundle.main.infoDictionary
        let majorVersion :AnyObject? = infoDictionary!["CFBundleShortVersionString"] as AnyObject?//主程序版本号
        let requestUrl = HttpConfig.checkVersion
        HttpManager().post(url: requestUrl, param: ["resource":"IOS",
                                                    "appVersion":majorVersion as Any,
                                                    "lang":CustomUtil.getLangString()], successBlock: { (result, json) in
                                                        
                                                        let isUpdate = result["isSuccess"] as! Bool
                                                        if isUpdate {
                                                            self.checkApp(versionDict: result as! Dictionary<String, Any>)
                                                        }
        }) { (error) in
            
            
        }
        
        //        #endif
    }
    
    func configRootViewController() {
        
        self.launchImageView = self.launchImage()
        self.launchImageView?.frame = UIScreen.main.bounds
        
        self.floatVideoWindow = CODFloatVideoWindow.init(frame: CGRect.init(x: KScreenWidth - kLocalVideoWidth - 5, y: kSafeArea_Top + kNavBarHeight + 5, width: kLocalVideoWidth, height: kLocalVideoHeigth))
        self.floatVideoWindow?.layer.cornerRadius = 5
        self.floatVideoWindow?.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
        self.floatVideoWindow?.layer.borderWidth = 0.5
        self.floatVideoWindow?.makeKeyAndVisible()
        self.floatVideoWindow?.isHidden = true
        
        self.floatVoiceWindow = CODFloatVoiceWindow.init(frame: CGRect.init(x: KScreenWidth - 65 - 5, y: kSafeArea_Top + kNavBarHeight + 5, width: 65, height: 65))
        self.floatVoiceWindow?.makeKeyAndVisible()
        self.floatVoiceWindow?.isHidden = true
        
        self.initBMKMapManager()
        
        
        
        if UserDefaults.standard.string(forKey: kFontSize_Change) == nil {
            UserDefaults.standard.set("0" as String, forKey: kFontSize_Change)
        }
        
        #if MANGO
        #else
        if let chatBGStr = UserDefaults.standard.object(forKey: kChat_BGImg) as? String {
            if chatBGStr == "bg_img_5.jpg" {
                UserDefaults.standard.set("bg_img_1.jpg" as String, forKey: kChat_BGImg)
            }
        }
        #endif
        
        if UserDefaults.standard.string(forKey: kChat_BGImg) == nil{
            
            #if MANGO
            UserDefaults.standard.set("bg_img_0.jpg" as String, forKey: kChat_BGImg)
            #else
            UserDefaults.standard.set("bg_img_1.jpg" as String, forKey: kChat_BGImg)
            #endif
        }
        
        if UserDefaults.standard.string(forKey: kShowCallTab) == nil {
            UserDefaults.standard.set("true" as String, forKey: kShowCallTab)
        }
        
        UserDefaults.standard.set(false, forKey: kIsVideoCall)
        UserDefaults.standard.synchronize()
        
        self.applicationConfigInit()
        
        self.addNotificationCenter()
        
        //        self.voipRegistration()
        
        self.checkUserInfo()
        
        isLogin = UserManager.sharedInstance.isLogin
        if isLogin {
            
            Bugly.setUserIdentifier(UserManager.sharedInstance.jid)
            
            self.SDWebImageDownloaderConfigInit()
            
            CODRealmTools.default.configRealm()
            
            // 数据未迁移完，页面不启动
            let vc = UIViewController()
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
            self.window?.addSubview(self.launchImageView!)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.removeLaunchImageView), name: NSNotification.Name.init(kEndGetHistory), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.removeLaunchImageView), name: NSNotification.Name.init(kConnectFail), object: nil)
            
            CODRealmTools.default.returnSuccessBlock = {
                
                // 删除数据库垃圾数据
                CODMessageRealmTool.deleteDirtyMsg()
                
                // 朋友圈发送失败重发逻辑
                CODDiscoverFailureAndSendingListModel.setSendingMessagToFailure()
                
                
                
                if UserManager.sharedInstance.isLogin {
                    let username : NSString = UserManager.sharedInstance.loginName! as NSString
                    let password : NSString = UserManager.sharedInstance.password! as NSString
                    if username.length > 0 && password.length > 0 {
                        self.afterLoginConfig()
                        // 获取朋友圈相关的数据
                        DiscoverHttpTools.getAndUpdateNewMoments()
                    }
                }
                
                do{
                    if let helpChatListmodel = CODChatListRealmTool.getChatList(id: 0) {
                        try Realm().write {
                            helpChatListmodel.title = "\(kApp_Name)小助手"
                        }
                        if let helpContact =  CODContactRealmTool.getContactById(by: 0) {
                            try Realm().write {
                                helpContact.userpic = UIImage.getHelpIconName()
                                helpContact.pinYin = ChineseString.getPinyinBy(CustomUtil.formatterStringWithAppName(str: "%@小助手"))
                                helpContact.name = "\(kApp_Name)小助手"
                            }
                        }
                    }
                } catch{}
                
                let vc = CODCustomTabbarViewController()
                vc.configCall()
                
                self.window?.rootViewController = vc
                self.window?.makeKeyAndVisible()
                
                
//                if let securityCode = UserDefaults.standard.string(forKey: kSecurityCode + UserManager.sharedInstance.loginName!){
//                    if securityCode.count > 0 {
//                        let ctl = CODSecurityCodeViewController()
//                        ctl.modalPresentationStyle = .overFullScreen
//                        self.window?.rootViewController?.present(ctl, animated: true, completion: nil)
//                    }
//                }
                
                if let pushInfo = self.pushInfo {
                    self.pushToMessageVC(pushInfo: pushInfo)
                }
                
                
            }
            
            
        }else{
            let nav = BaseNavigationController(rootViewController: LoginViewController())
            self.window?.rootViewController = nav
            self.window?.makeKeyAndVisible()
        }
        
        
        
    }
    
    func checkUserInfo() {
        
        isLogin = UserManager.sharedInstance.isLogin
        if isLogin {
            let nickName = UserManager.sharedInstance.nickname
            if nickName == nil || (nickName?.count)! <= 0 {
                UserManager.sharedInstance.userLogout()
            }
        }
    }
    
    @objc func removeLaunchImageView() {
        
        NSLog("启动页销毁#################")
        
        UIView.animate(withDuration: 1.0, animations: {
            self.launchImageView?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.launchImageView?.alpha = 0
        }, completion: { (finish) in
            if finish{
                self.launchImageView?.removeFromSuperview()
            }
        })
    }
    
    //    #if MANGO || XINHOO
    //MARK: 更新app
    func checkApp(versionDict:Dictionary<String, Any>) {
        
        self.updateTipView.configView(versionDict:versionDict)
        self.updateTipView.show()
        
        
        
    }
    //    #endif
    
    
    
    //解锁 操作 去更新焚烧消息使用
    func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
//        NotificationCenter.default.post(name: NSNotification.Name.init(kApplicationBecomeAvailable), object: nil)
        print("解锁")
    }
    
    //锁屏 操作 去更新焚烧消息使用
    func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name.init(kApplicationBecomeUnavailable), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.init(kApplicationBecomeUnavailableLock), object: nil)
        print("锁屏")
        //        XMPPManager.shareXMPPManager.disconnect()
    }
    
    func SDWebImageDownloaderConfigInit() {
        
        UserManager.sharedInstance.updateAuthorization()
        MiPushSDK.setAlias(UserManager.sharedInstance.loginName ?? "")
        
    }
    
    //    func voipRegistration() {
    //
    //        let mainQueue = DispatchQueue.main
    //
    //        // Create a push registry object
    //
    //        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
    //
    //        // Set the registry's delegate to self
    //
    //        voipRegistry.delegate = self
    //
    //        // Set the push type to VoIP
    //
    //        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    //
    //    }
    
    //初始化百度地图
    func initBMKMapManager() {
        
        #if PRO
        let BaiduAK = "nK3perT7opLRh7XseYUMrd8aa0DltZGQ"
        #elseif MANGO
        let BaiduAK = "WwgGGZpnAbtt24CB1LXtlW7zpi540gyO"
        #else
        let BaiduAK = "MCaxqhEvkwGpezT0951N9L1e70oBEixc"
        #endif
        
        self.mapManager = BMKMapManager()
        let ret = self.mapManager!.start(BaiduAK, generalDelegate: nil)
        if ret == false {
            print("manager start failed!")
        }
        if BMKMapManager.setCoordinateTypeUsedInBaiduMapSDK(BMK_COORD_TYPE.COORDTYPE_BD09LL) {
            NSLog("经纬度类型设置成功")
        } else {
            NSLog("经纬度类型设置失败")
        }
        // 初始化定位SDK
        BMKLocationAuth.sharedInstance()?.checkPermision(withKey: BaiduAK, authDelegate: self)
    }
    
    func onCheckPermissionState(_ iError: BMKLocationAuthErrorCode) {
        if iError == BMKLocationAuthErrorCode.success {
            print("百度地图授权成功")
        }else{
            print("百度地图授权失败")
        }
    }
    
    func applicationConfigInit() {
        CODProgressHUD.initHUD()
        self.setKeyBoard()
    }
    
    func addNotificationCenter() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(getUserSuccess), name: NSNotification.Name.init(kGetUserSuccessNoti), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clearUserInfo), name: NSNotification.Name.init(kClearUserInfoNoti), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeRootCtl), name: NSNotification.Name.init(kChangeRootCtlNoti), object: nil)
    }
    
    
    //全局添加键盘
    func setKeyBoard() {
        let keyboardManager = IQKeyboardManager.shared
        keyboardManager.enable = true
        keyboardManager.shouldResignOnTouchOutside = true
        keyboardManager.shouldToolbarUsesTextFieldTintColor = true
        keyboardManager.toolbarManageBehaviour = IQAutoToolbarManageBehaviour.byTag
        keyboardManager.enableAutoToolbar = false
        keyboardManager.shouldShowToolbarPlaceholder = true
        keyboardManager.placeholderFont = UIFont.systemFont(ofSize: 17.0)
        keyboardManager.keyboardDistanceFromTextField = 35
    }
    
    
    @objc func getUserSuccess() {
        self.setSession { [weak self] (successStatus) in
            if successStatus == 0 {
                self?.loginStep()
                DiscoverHttpTools.getMomentBackground()
                DiscoverHttpTools.getAndUpdateNewMoments()
            }
        }
    }
    
    func loginStep() {
        
        //登录XMPP成功，配置数据库
        
        if UserDefaults.standard.string(forKey: kSecurityCode + UserManager.sharedInstance.loginName!) == nil {
            UserDefaults.standard.set("" as String, forKey: kSecurityCode + UserManager.sharedInstance.loginName!)              //安全码
            UserDefaults.standard.set(false, forKey: kSecurityCode_ClearData + UserManager.sharedInstance.loginName!)           //安全码数据保护（超过5次输入错误，清除本地聊天数据）
            UserDefaults.standard.set(false, forKey: kSecurityCode_Smooth + UserManager.sharedInstance.loginName!)              //安全码通讯流畅保护（信号不好时，不允许使用app）
        }
        
        self.SDWebImageDownloaderConfigInit()
        CODRealmTools.default.configRealm()
        CODRealmTools.default.returnSuccessBlock = {
            
            self.afterLoginConfig()
            
            let vc = CODCustomTabbarViewController()
            vc.configCall()
            self.window?.rootViewController = vc
            CODProgressHUD.showWithStatus(nil)  ///切换账号时，或者第一次登录时，避免网络不好时，直接进入APP页面
            
            self.window?.makeKeyAndVisible()
            
        }
    }
    
    //MARK: 注册session
    func setSession(successBlock: @escaping (_ status: Int) -> Void ) {
        
        let infoDictionary = Bundle.main.infoDictionary
        let majorVersion: String = infoDictionary?["CFBundleShortVersionString"] as? String ?? ""//主程序版本号
        
        
        
        let requestUrl = HttpConfig.setPushSession
        XinhooTool.addLog(log:"userservice/loginsession")
        HttpManager().post(url: requestUrl, param: ["username":UserManager.sharedInstance.loginName ?? "",
                                                    "password":UserManager.sharedInstance.password ?? "",
                                                    "deviceID":DeviceInfo.uuidString,
                                                    "deviceResource":"iOS",
                                                    "loginResource":"MOBILE",
                                                    "deviceModel":"APPLE",
                                                    "devicePlatforms":"\(CustomUtil.iphoneType()),\(UIDevice.current.systemVersion)",
            "pushToken":UserManager.sharedInstance.token ?? "",
            "voipToken":UserManager.sharedInstance.voipToken ?? "",
            "description":UIDevice.current.name,
            "clientVersion":majorVersion,
            "lang":CustomUtil.getLangString()], successBlock: { (result, json) in
                
                if let success = result["isSuccess"] as? Bool {
                    if success {
                        if let token = result["token"] as? String {
                            UserManager.sharedInstance.session = token
                        }else{
                            UserManager.sharedInstance.session = "0"
                        }
                        if let resource = result["resource"] as? String  {
                            UserManager.sharedInstance.resource = resource
                        }
                        successBlock(0)
                    }else{
                        UserManager.sharedInstance.userLogout()
                        CODProgressHUD.showErrorWithStatus("获取鉴权失败")
                        successBlock(1)
                    }
                }
                
        }) { (error) in
            
            switch error.code {
            case 10053:
                
                UserManager.sharedInstance.userLogout()
                CODProgressHUD.showErrorWithStatus("消息服务已经限制使用")
            case 10031:
                CODProgressHUD.showErrorWithStatus("因涉嫌违规或被用户投诉，您的账号已被冻结")
            default: break
                
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touchLocation = event?.allTouches?.first?.location(in: self.window) {
            
            let statusBarFrame = UIApplication.shared.statusBarFrame
            if statusBarFrame.contains(touchLocation) {
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: statusBarNotification)))
            }
            
        }
    }
    
    //    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        super.touchesEnded(touches, with: event)
    //        if let touchLocation = event?.allTouches?.first?.location(in: self.window) {
    //
    //            let statusBarFrame = UIApplication.shared.statusBarFrame
    //            if statusBarFrame.contains(touchLocation) {
    //                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: statusBarNotification)))
    //            }
    //
    //        }
    //
    //    }
    
    
    /// 切换Tabbar控制器
    @objc func changeRootCtl() {
        Bugly.setUserIdentifier(UserManager.sharedInstance.jid)
        let vc = CODCustomTabbarViewController()
        vc.configCall()
        self.window?.rootViewController = vc
    }
    
    @objc func clearUserInfo() {
        XinhooTool.addLog(log:"【主动断开连接】退出登录")
        XMPPManager.shareXMPPManager.disconnect()
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        let rootVindow:UIWindow = ((UIApplication.shared.delegate?.window)!)!
        // 登录
        CODContactRealmTool.default.contactNotificationToken = nil
        let navi = BaseNavigationController.init(rootViewController: LoginViewController())
        _ = rootVindow.subviews.map { $0.removeFromSuperview()} // 移除所有子视图 释放所有VC
        rootVindow.rootViewController = navi
    }
    
    @objc func reloadTabCount() {
        if UserDefaults.standard.string(forKey: kShowCallTab) == "true" {
            
            let vc = CODCustomTabbarViewController()
            vc.switchCallConfig()
            let oldRootVC = self.window?.rootViewController as! CODCustomTabbarViewController
            vc.tabBarItemsAttributes = [oldRootVC.contactDic,oldRootVC.callDic,oldRootVC.chatDic,oldRootVC.discoverDic,oldRootVC.meDic]
            vc.viewControllers = [oldRootVC.viewControllers[0],vc.callNav,oldRootVC.viewControllers[1],oldRootVC.viewControllers[2],oldRootVC.viewControllers[3]] as! [UIViewController]
            self.window?.rootViewController = vc
            vc.selectedIndex = 4
            
        }else{
            
            let vc = CODCustomTabbarViewController()
            vc.switchCallConfig()
            let oldRootVC = self.window?.rootViewController as! CODCustomTabbarViewController
            vc.tabBarItemsAttributes = [oldRootVC.contactDic,oldRootVC.chatDic,oldRootVC.discoverDic,oldRootVC.meDic]
            vc.viewControllers = [oldRootVC.viewControllers[0],oldRootVC.viewControllers[2],oldRootVC.viewControllers[3],oldRootVC.viewControllers[4]]
            self.window?.rootViewController = vc
            vc.selectedIndex = 3
        }
        
        
    }
    
    @objc func alertDidDismiss() {
        
        if let _ = self.floatVoiceWindow?.imgHead.image {
            //            self.floatVoiceWindow?.isHidden = false
            self.window?.makeKeyAndVisible()
        }
        
    }
    
    @objc func afterLoginConfig() {
        
        
        
        manager = NetworkReachabilityManager(host: "www.baidu.com")
        manager?.startListening(onUpdatePerforming: { status in
            
            switch status {
            case .notReachable:
                print("无网络")
                self.isNetwork = false
                XinhooTool.addLog(log:"【主动断开连接】检查到没有网络")
                XMPPManager.shareXMPPManager.xmppStream.disconnect()
                XMPPManager.shareXMPPManager.xmppReconnect.stop()
                XMPPManager.shareXMPPManager.xmppDisconnetIQRequsetHandler()
                NotificationCenter.default.post(name: NSNotification.Name.init(kWaitNetwork), object: nil, userInfo:nil)
                
            case .unknown:
                print("未知网络")
                break
            case .reachable(.ethernetOrWiFi):
                
                print("wifi网络")
                self.isNetwork = true
                
                AutoSwitchIPManager.share.setBestIP(autoSwitch: false)
                
                self.XMPPlogin()
                
                break
                
            case .reachable(.cellular):
                
                print("2G/3G/4G网络")
                self.isNetwork = true
                
                AutoSwitchIPManager.share.setBestIP(autoSwitch: false)
                
                self.XMPPlogin()
                
                break
                
            }
        })
        
        //        self.XMPPlogin()
        
        CODImageCache.default.setup()
        
        
        
    }
    
    func XMPPlogin() {
        XMPPManager.shareXMPPManager.xmppConnect(username: UserManager.sharedInstance.loginName!, password: UserManager.sharedInstance.password!)
    }
    
    
    func timeStampValid(isSuccessBlock: @escaping (_ isSuccess:Bool) -> Void) {
        let dateInterval1 = Date.milliseconds
        HttpManager.share.post(url: HttpConfig.validTimeStamp, param: ["localtimestamp":Int64(Date.milliseconds)], successBlock: { (success, json) in
            if let result = success["data"] as? Dictionary<String, Any> {
                let dateInterval2 = Date.milliseconds
                let timeStamp = dateInterval2 - dateInterval1
                if let offset = result["offset"] as? Int ,timeStamp < 300.00 {
                    UserManager.sharedInstance.timeStamp = offset
                    isSuccessBlock(true)
                    let alert = UIAlertController(title: "时间偏移量\(offset),获取耗时：\(timeStamp)", message: nil, preferredStyle: UIAlertController.Style.alert)
                    let action = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (action) in
                    })
                    alert.addAction(action)
                    let ctl = UIViewController.current()
                    ctl?.present(alert, animated: true, completion: nil)
                }else{
                    isSuccessBlock(false)
                }
                
            }
            
            print("时间偏移量%@",json)
        }) { (error) in
            print("时间偏移量%@",error)
            isSuccessBlock(false)
            //            let alert = UIAlertController(title: "时间偏移量获取失败\(error)", message: nil, preferredStyle: UIAlertController.Style.alert)
            //            let action = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (action) in
            //
            //            })
            //            alert.addAction(action)
            //            let ctl = UIViewController.current()
            //            ctl?.present(alert, animated: true, completion: nil)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        if UserManager.sharedInstance.isLogin {
            if let securityCode = UserDefaults.standard.string(forKey: kSecurityCode + UserManager.sharedInstance.loginName!){
                if securityCode.count > 0 {
                    SecurityCodeAutoLocking.setLeaveCurrentTimeInterval()
                }
            }
        }
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name.init(kApplicationBecomeUnavailable), object: nil)
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        self.beginBackgroundTask()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kSendVoiceStopPlay), object: nil)
        
        //try! AVAudioSession.sharedInstance().setCategory(.soloAmbient)
        
        if UserManager.sharedInstance.isLogin {
            
            //            if let _ = XMPPManager.shareXMPPManager.xmppStream,XMPPManager.shareXMPPManager.xmppStream.isConnected {
            //                let presence = XMPPPresence(type: "unavailable")
            //                XMPPManager.shareXMPPManager.xmppStream.send(presence)
            //            }
            
            do{
                var count = 0
                let results = try Realm.init().objects(CODChatListModel.self).filter("(contact.mute = false || groupChat.mute = false || channelChat.mute = false) && isInValid = false")
                for chatModel in results {
                    count = count + chatModel.count
                }
                //            UIApplication.shared.applicationIconBadgeNumber = 0
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                UIApplication.shared.applicationIconBadgeNumber = count
                let requestUrl = HttpConfig.unreadCount_URL
                HttpManager().post(url: requestUrl, param: ["username":UserManager.sharedInstance.loginName as Any,
                                                            "loginResource":UserManager.sharedInstance.resource ?? "",
                                                            "deviceID":DeviceInfo.uuidString,
                                                            "token":UserManager.sharedInstance.session as Any,
                                                            "pushQty":count], successBlock: { (result, json) in
                                                                self.endBackgroundTask()
                }) { (error) in
                    self.endBackgroundTask()
                }
                
            }catch{}
        }else{
            UIApplication.shared.applicationIconBadgeNumber = 0
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
//        checkUpdateVersion()
        
        application.applicationIconBadgeNumber = 1
        application.applicationIconBadgeNumber = 0
        
        NotificationCenter.default.post(name: NSNotification.Name.init(kChangeSystemNoti), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
//        NotificationCenter.default.post(name: NSNotification.Name.init(kApplicationBecomeAvailable), object: nil)
        
        
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        XinhooTool.is12Hour = CustomUtil.is12Hour()
        DiscoverHttpTools.getMomentBackground()
        DiscoverHttpTools.getAndUpdateNewMoments()
        //        if let _ = XMPPManager.shareXMPPManager.xmppStream,XMPPManager.shareXMPPManager.xmppStream.isConnected {
        //            let presence = XMPPPresence(type: "")
        //            XMPPManager.shareXMPPManager.xmppStream.send(presence)
        //        }
        if (UIViewController.current()?.isKind(of: IPLockViewController.classForCoder())) ?? false {
            self.XMPPlogin()
        }
        
        self.attemptShowSecurityCodeVC { [weak self] in
            self?.checkUpdateVersion()
        }
    }
    
    func attemptShowSecurityCodeVC(completeBlock: @escaping () -> Void) {
        guard UserManager.sharedInstance.isLogin else {
            completeBlock()
            return
        }
        guard let securityCode = UserDefaults.standard.string(forKey: kSecurityCode + UserManager.sharedInstance.loginName!) , securityCode.count > 0, SecurityCodeAutoLocking.isLock else {
            completeBlock()
            return
        }
        guard let subviews = self.window?.subviews, subviews.count > 0 else {
            completeBlock()
            return
        }
        
        let isContrainSecurityCodeVC = subviews.contains(where: { (view) -> Bool in
            return view.isKind(of: CODSecurityCodeViewController.self)
        })
        
        guard !isContrainSecurityCodeVC else {
            completeBlock()
            return
        }
        
        var imageBro = [UIView]()
        for view in subviews {
            if view.isKind(of: YBImageBrowser.self) {
                imageBro.append(view)
                view.isHidden = true
            }
        }
        let ctl = CODSecurityCodeViewController()
        ctl.modalPresentationStyle = .overFullScreen
        ctl.dismissBlock = {
            let _ = imageBro.map { $0.isHidden = false }
            SecurityCodeAutoLocking.isUnlock = true
            completeBlock()
        }
        self.window?.rootViewController?.present(ctl, animated: true, completion: nil)
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        XinhooTool.addLog(log:"【主动断开连接】系统干掉应用")
        XMPPManager.shareXMPPManager.disconnect()
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        
        if #available(iOS 13.0, *) {
            
            let deviceTokenString = NSMutableString.init()
            let bytes = deviceToken.bytes
            for i in 0...deviceToken.count-1 {
                deviceTokenString.appendFormat("%02x", bytes[i]&0x000000FF)
            }
            UserManager.sharedInstance.token = deviceTokenString as String;
            print("APNS Token: \(deviceTokenString)")
            
        }else{
            let nsdata = NSData(data: deviceToken)
            var token = nsdata.description
            token = token.replacingOccurrences(of: " ", with: "")
            token = token.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "")
            UserManager.sharedInstance.token = token;
            print("APNS Token: \(token)")
            MiPushSDK.bindDeviceToken(deviceToken)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // 自行处理失败
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        MiPushSDK.handleReceiveRemoteNotification(userInfo)
        let log = "APNs notify: \(userInfo)"
        NSLog(log)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo: [AnyHashable : Any] = notification.request.content.userInfo;
        if notification.request.trigger is UNPushNotificationTrigger {
            MiPushSDK.handleReceiveRemoteNotification(userInfo)
        }
        //        if UserManager.sharedInstance.preview {
        //            completionHandler(UNNotificationPresentationOptions.alert)
        //        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo: [AnyHashable : Any] = response.notification.request.content.userInfo;
        if response.notification.request.trigger is UNPushNotificationTrigger {
            MiPushSDK.handleReceiveRemoteNotification(userInfo)
            let log = "MiPush notify: \(userInfo)";
            NSLog(log)
        }
        completionHandler()
        
        if UIApplication.shared.applicationState == .inactive {
            
            self.pushInfo = userInfo
            pushToMessageVC(pushInfo: userInfo)
            
        } else if UIApplication.shared.applicationState == .background {
            self.pushInfo = userInfo
            pushToMessageVC(pushInfo: userInfo)
        }
        
        
    }
    
    func pushToMessageVC(pushInfo: [AnyHashable : Any]) {
        
        
        if UserManager.sharedInstance.isLogin == false {
            return
        }
        
        let json = JSON(pushInfo)
        
        DDLogInfo("pushToMessageVC json : \(json)")
        
        if let jid = json["data"]["jid"].string, let messageTypeInt = json["data"]["msgType"].int, let msgType = EMMessageBodyType(rawValue: messageTypeInt) {
            
            if msgType == .videoCall || msgType == .voiceCall {
                return
            }
            
            CustomUtil.pushToMessageVC(jid: jid)
            
            
            
        }
        
        
    }
    
    /// 小米推送异步回调
    ///
    /// - Parameters:
    ///   - selector: 请求方法
    ///   - data: 返回的字典
    func miPushRequestSucc(withSelector selector: String!, data: [AnyHashable : Any]!) {
        
        if selector == "setAlias:" {
            print("设置别名成功")
        }
        
        if selector == "bindDeviceToken:" {
            let regId = data["regid"]
            print("regId = \(String(describing: regId))")
        }
    }
    
    func miPushRequestErr(withSelector selector: String?, error: Int32, data: [AnyHashable : Any]?) {
        let log = "command error(\(error)|\(String(describing: selector))): \(data?.description ?? "")"
        NSLog(log)
    }
    
    
    /// 收到消息推送
    ///
    /// - Parameter data: 消息内容
    func miPushReceiveNotification(_ data: [AnyHashable : Any]!) {
        let log = "MiPush notify: \(String(describing: data))";
        NSLog(log)
    }
    
    // MARK: - Linking delegate methods
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        //        return JitsiMeet.sharedInstance().application(application, continue: userActivity, restorationHandler: restorationHandler)
        return true;
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        //        return JitsiMeet.sharedInstance().application(app, open: url, options: options)
        print("外部链接\(url)")
        xmppConnectedSemaphore = DispatchSemaphore(value: 0)
        let urlString = url.absoluteString
        
        if urlString.contains(OPEN_ChannleURL) {
            if UserManager.sharedInstance.isLogin {
                var strUrl = urlString.removeHeadAndTailSpace
                if strUrl.lowercased().hasPrefix("http://") == false && strUrl.lowercased().hasPrefix("https://") == false{
                    strUrl = "http://" + strUrl
                }
                
                if XMPPManager.shareXMPPManager.xmppStream.isAuthenticated {
                    self.joinChannel(urlString: strUrl)
                }else{
                    DispatchQueue.global().async {
                        self.xmppConnectedSemaphore.wait()
                        DispatchQueue.main.async {
                            
                            self.joinChannel(urlString: strUrl)
                        }
                    }
                }
            }
            
        }else{
            self.isNotMyUrl(urlString: url.absoluteString)
            
        }
        
        return true;
    }
    func getChannleTypeAndID(urlString: String) -> (channleType: String, channleID: String) {
        
        var channleType = ""
        var channleID = ""
        
        if let match = urlString.range(of: "(?<==)[^&]+", options: .regularExpression) {
            channleType = String(urlString[match])
            channleID = urlString.components(separatedBy: "&id=").last ?? ""
        }
        return(channleType,channleID)
    }
    
    func joinChannel(urlString: String) {
        let userDetail = self.getChannleTypeAndID(urlString: urlString)
        var strUrl = urlString.removeHeadAndTailSpace
        if strUrl.lowercased().hasPrefix("http://") == false && strUrl.lowercased().hasPrefix("https://") == false{
            strUrl = "http://" + strUrl
        }
        
        let dict:[String:Any] = ["name": COD_MemberJoin,
                                 "requester": UserManager.sharedInstance.jid,
                                 "inviter": UserManager.sharedInstance.jid,
                                 "userid": userDetail.channleID.removeHeadAndTailSpace,
                                 "add": false,
                                 "typeUserID": (userDetail.channleType.contains("pub"))
        ]
        
        CODProgressHUD.showWithStatus(nil)
        XMPPManager.shareXMPPManager.getRequest(param: dict, xmlns: COD_com_xinhoo_groupchannel) { (response) in
            
            //              guard let `self` = self else { return }
            CODProgressHUD.dismiss()
            switch response {
            case .success(let model):
                
                if let vc = UIViewController.current() as? MessageViewController, vc.chatId == model.dataJson?["roomID"].int {
                    vc.pustToMessageDetail()
                    
                }else{
                    if model.dataJson?["type"].stringValue != CODGroupType.MPRI.rawValue {
                        CustomUtil.joinChannlHandle(model: model)
                    } else {
                        CustomUtil.joinGroupHandle(model: model, linkString: userDetail.channleID.removeHeadAndTailSpace,isNeedPub: true,isPub: (userDetail.channleType.contains("pub")))
                    }
                }
                
                break
            default:
                LGAlertView(title: nil, message: NSLocalizedString("此邀请链接无效或已过期", comment: ""), style: .alert, buttonTitles: nil, cancelButtonTitle: "知道了", destructiveButtonTitle: nil, actionHandler: nil, cancelHandler: nil, destructiveHandler: nil).show()
                break
            }
        }
        
    }
    
    func isNotMyUrl(urlString: String) {
        
        let alert = UIAlertController.init(title: urlString, message: nil, preferredStyle: .actionSheet)
        let subview = alert.view.subviews.first! as UIView
        let alertContentView = subview.subviews.first! as UIView
        alertContentView.backgroundColor = UIColor.white
        alertContentView.layer.cornerRadius = 15
        
        let openAction = UIAlertAction.init(title: NSLocalizedString("打开", comment: ""), style: .default) { (action) in
            self.openURL(url: urlString)
        }
        
        let copyAction = UIAlertAction.init(title: NSLocalizedString("拷贝", comment: ""), style: .default) { (action) in
            let pastboard = UIPasteboard.general
            pastboard.string = urlString
        }
        
        let cancelAction = UIAlertAction.init(title: NSLocalizedString("取消", comment: ""), style: .cancel) { (action) in
        }
        
        alert.addAction(openAction)
        alert.addAction(copyAction)
        alert.addAction(cancelAction)
        
        UIViewController.current()?.present(alert, animated: true, completion: nil)
    }
    
    func openURL(url:String) {
        var strUrl : NSString = url as NSString
        if strUrl.lowercased.hasPrefix("http://") == false && strUrl.lowercased.hasPrefix("https://") == false{
            strUrl = NSString.init(string: "http://").appending(strUrl as String) as NSString
        }
        let safariVC = SFSafariViewController.init(url: URL.init(string: strUrl as String)!)
        UIViewController.current()!.present(safariVC, animated: true, completion: nil)
    }
    
    
    
    func beginBackgroundTask() {
        self.backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundTask()
        })
    }
    
    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(self.backgroundTask!)
        self.backgroundTask = .invalid
    }
    
    func launchImage() -> UIImageView {
        
        var launchImage     : UIImage!
        var viewOrientation : String!
        let viewSize        = UIScreen.main.bounds.size
        let orientation     = UIApplication.shared.statusBarOrientation
        //  获取屏幕方向
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            viewOrientation = "Landscape"
        } else {
            viewOrientation = "Portrait"
        }
        let imagesInfo = Bundle.main.infoDictionary!["UILaunchImages"]
        for dic: Dictionary<String, String> in imagesInfo as! Array {
            
            var imageSizeString = dic["UILaunchImageSize"]
            imageSizeString = imageSizeString?.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "").replacingOccurrences(of: " ", with: "")
            
            let arr = imageSizeString?.components(separatedBy: ",")
            let imageSize = CGSize.init(width: arr?.first?.int ?? 0, height: arr?.last?.int ?? 0)
            if imageSize.equalTo(viewSize) && viewOrientation == dic["UILaunchImageOrientation"]! as String {
                
                launchImage = UIImage(named: dic["UILaunchImageName"]!)
            }
        }
        
        let imageview = UIImageView.init(image: launchImage)
        imageview.isUserInteractionEnabled = false
        return imageview
    }
    
    
    func replyPushNotificationAuthorization(application:UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [UNAuthorizationOptions.badge,UNAuthorizationOptions.sound,UNAuthorizationOptions.alert]) { (granted, error) in
            if granted {
                center.getNotificationSettings { (settings) in
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
            }
        }
    }
    
    //    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    //
    //        KScreenWidth = UIScreen.main.bounds.size.width
    //        KScreenHeight = UIScreen.main.bounds.size.height
    //        if blockRotation {
    //            return .portrait //支持横竖屏旋转
    //            //            return .landscapeLeft //强制横屏时这里可保持一个方向
    //        }
    //
    //        if UserDefaults.standard.bool(forKey: kIsVideoCall) {
    //            return .portrait
    //        }
    //        return .all
    //    }
}

/*
 extension AppDelegate:PKPushRegistryDelegate{
 
 
 func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
 
 if #available(iOS 13.0, *) {
 
 let deviceTokenString = NSMutableString.init()
 let bytes = credentials.token.bytes
 for i in 0...credentials.token.count-1 {
 deviceTokenString.appendFormat("%02x", bytes[i]&0x000000FF)
 }
 print("voip token = \(deviceTokenString)")
 UserManager.sharedInstance.voipToken = deviceTokenString as String;
 
 }else{
 let nsdataStr = NSData.init(data: credentials.token)
 let datastr = nsdataStr.description.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
 print("voip token = \(datastr)")
 UserManager.sharedInstance.voipToken = datastr;
 }
 
 
 }
 
 func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
 //        print("/// payload:\(payload.dictionaryPayload), type:\(type) ///")
 //        payload:[AnyHashable("aps"): {
 //        alert =     {
 //            body = "[\U89c6\U9891\U901a\U8bdd]";
 //            title = xruby10;
 //        };
 //        badge = 1;
 //        sound = default;
 //        }, AnyHashable("msgtype"): 13, AnyHashable("rosterid"): 1113], type:PKPushType(_rawValue: PKPushTypeVoIP)
 
 if UserDefaults.standard.bool(forKey: kIsVideoCall) {
 return
 }
 
 //        if let rosterID = payload.dictionaryPayload["rosterid"] {
 //
 //            if let contactModel = CODContactRealmTool.getContactById(by: rosterID as! Int){
 //                let center = UNUserNotificationCenter.current()
 //                let content = UNMutableNotificationContent.init()
 //
 //                let type = payload.dictionaryPayload["msgtype"] as! Int
 //                let strType = type == EMMessageBodyType.voiceCall.rawValue ? "语音" : "视频"
 //                content.body = "\(contactModel.getContactNick())邀请你\(strType)通话..."
 //
 //                let customSound = UNNotificationSound.init(named: UNNotificationSoundName.init(rawValue: "voip_call.caf"))
 //                content.sound = customSound
 //                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
 //                let request = UNNotificationRequest.init(identifier: "Voip_Push", content: content, trigger: trigger)
 //                center.add(request) { (error) in
 ////                    completion()
 //                }
 //            }
 //        }
 
 //                let center = UNUserNotificationCenter.current()
 //                let content = UNMutableNotificationContent.init()
 //
 //                content.body = "hahhaha"
 //
 //                let customSound = UNNotificationSound.init(named: UNNotificationSoundName.init(rawValue: "voip_call.caf"))
 //                content.sound = customSound
 //                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
 //                let request = UNNotificationRequest.init(identifier: "Voip_Push", content: content, trigger: trigger)
 //                center.add(request) { (error) in
 //                }
 
 let configuration = CXProviderConfiguration.init(localizedName: "hello")
 let provider = CXProvider.init(configuration: configuration)
 let update = CXCallUpdate.init()
 provider.reportNewIncomingCall(with: UUID.init(), update: update) { (error) in
 
 }
 }
 
 func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
 if UserDefaults.standard.bool(forKey: kIsVideoCall) {
 return
 }
 
 if let rosterID = payload.dictionaryPayload["rosterid"] {
 
 if let contactModel = CODContactRealmTool.getContactById(by: rosterID as! Int){
 let center = UNUserNotificationCenter.current()
 let content = UNMutableNotificationContent.init()
 
 let type = payload.dictionaryPayload["msgtype"] as! Int
 let strType = type == EMMessageBodyType.voiceCall.rawValue ? "语音" : "视频"
 content.body = "\(contactModel.getContactNick())邀请你\(strType)通话..."
 
 let customSound = UNNotificationSound.init(named: UNNotificationSoundName.init(rawValue: "voip_call.caf"))
 content.sound = customSound
 let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
 let request = UNNotificationRequest.init(identifier: "Voip_Push", content: content, trigger: trigger)
 center.add(request) { (error) in
 //                    completion()
 }
 }
 }
 }
 
 
 }
 */
