//
//  CustomUtil+HttpToos.swift
//  COD
//
//  Created by xinhooo on 2020/8/11.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import HandyJSON

extension CustomUtil {
    
    class func checkVersion() {
        
        /* 程序版本号是否跟上次不一样，如果不一样获取更新内容，写入小助手内 */
        let infoDictionary = Bundle.main.infoDictionary
        let majorVersion :String? = infoDictionary!["CFBundleShortVersionString"] as! String?//主程序版本号
        
        if let version = UserDefaults.standard.string(forKey: kVersion),version.count > 0 {
            
            if version != majorVersion {
                
                CustomUtil.getUpdateTip(version: version)
                
                UserDefaults.standard.set(majorVersion, forKey: kVersion)
                
            }
            
        }else{
            
            // 如果当前没有记录kVersion
            // 默认当与上次不一样处理
            UserDefaults.standard.set(majorVersion, forKey: kVersion)
            
        }
        
        UserDefaults.standard.synchronize()
        
    }
    
    class func getUpdateTip(version: String) {
        
        let requestUrl = HttpConfig.checkVersion
        HttpManager().post(url: requestUrl,
                           param: ["resource":"IOS",
                                   "appVersion":version,
                                   "lang":CustomUtil.getLangString()],
                           successBlock: { (result, json) in
                            
                            let isUpdate = result["isSuccess"] as! Bool
                            if isUpdate {
                                
                                
                                if let versionDict = result as? Dictionary<String, Any> {
                                    
                                    var historyVersionURL = ""
                                    
                                    #if MANGO
                                    historyVersionURL = "https://imangoim.com/history?lang=\(CustomUtil.getLangString())"
                                    #elseif PRO
                                    historyVersionURL = "https://web.by52eg.com/history?lang=\(CustomUtil.getLangString())"
                                    #else
                                    historyVersionURL = "https://cod.xinhoo.com/history?lang=\(CustomUtil.getLangString())"
                                    #endif
                                    
                                    
                                    let content = """
                                    \(kApp_Name) iOS \(NSLocalizedString("已更新到", comment: "")) v\(versionDict["appVersion"] as? String ?? "")
                                    \(versionDict["content"] as? String ?? "")
                                    
                                    \(NSLocalizedString("更多版本记录请在这里查看：", comment: ""))
                                    \(historyVersionURL)
                                    """
                                    
                                    let msgModel = CODMessageModelTool.default.createTextModel(msgID: UserManager.sharedInstance.getMessageId(), toJID: UserManager.sharedInstance.jid, textString: content, chatType: .privateChat, roomId: nil, chatId: RobotRosterID, burn:  0, sendTime: nil)
                                    msgModel.fromWho = "cod_60000000\(XMPPSuffix)"
                                    msgModel.fromJID = "cod_60000000\(XMPPSuffix)"
                                    CODChatListRealmTool.addChatListMessage(id: RobotRosterID, message: msgModel)
                                    NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
                                }
                                
                                
                            }
        }) { (error) in
            
            
        }
    }
    
    class func getAll_IP_List() {
        
        HttpManager.share.post(url: HttpConfig.COD_GetALLIPList, param: nil, isShowNoNetwork: false, successBlock: { (dic, json) in
            
            var dataJson = json["data"]
            
            /// 如果加密就走加密处理
            if let dataString = json["data"].string {
                let jsonString = dataString.aes128DecryptECB(key: .serverList)
                dataJson = JSON(parseJSON: jsonString)
            }

            let serverTeamList = dataJson["serverTeamList"].arrayValue
            if let serverConfig = dataJson["serverConfig"].dictionaryObject?.jsonString() {
                UserDefaults.standard.set(serverConfig, forKey: kServerConfig)
                UserDefaults.standard.synchronize()
            }
            
            if serverTeamList.count > 0 {
                
                if let jsonString = dataJson.dictionaryObject?.jsonString() {
                    UserDefaults.standard.set(jsonString, forKey: kServersList)
                    
                    if UserDefaults.standard.synchronize() {
                        AutoSwitchIPManager.share.updateServerList()
                    }
                }
                                
            }
            
            
            
        }) { (eoor) in
            
//            CODProgressHUD.showSuccessWithStatus(NSLocalizedString("网络请求失败，请稍后再试", comment: ""))
        }
        
    }
    
}

class ServerIPListModel: HandyJSON {
    
    var apiServers: [ServerIPModel] = []
    
    var fileServers: [ServerIPModel] = []
    
    required init() {}
}

class ServerIPModel: HandyJSON {
    
    /// IP 地址
    var address = ""
    
    /// 1 是主服务器，2 不是主服务器
    var master: Int = 2
    
    /// 中文描述
    var descZh = ""
    
    /// 英文描述
    var descEn = ""
    
    /// 繁体描述
    var descZht = ""
    
    /// 服务器类型 1.IM/API服务器 2.文件服务器
    var type: Int = 2
    
    /// 优先级
    var priority: Int = 0
    
    
    required init() {}
}
