//
//  CustomUtil.swift
//  COD
//
//  Created by xinhooo on 2019/4/9.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import XMPPFramework
import SwiftyJSON
import LGAlertView

let kCOD_all         = "all"
let kCOD_none        = "none"
let kCOD_roster      = "roster"
func stringClassFromString(_ className: String) -> AnyClass! {

    /// get namespace
    let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String;
    
    var cls: AnyClass
    if !className.contains(namespace) {
        cls = NSClassFromString("\(namespace).\(className)")!
    } else {
        cls = NSClassFromString(className)!
    }

    // return AnyClass!
    return cls;
}



class CustomUtil: NSObject {
    
    enum SortType: Int {
        case asc = 1
        case desc = -1
    }
    
    indirect enum PageReqSortParam {
        case sort(_ field: String, _ sort: SortType, _ sortParam: PageReqSortParam? = nil)
        
        var params: [[String: Any]] {
            
            switch self {
            case .sort(let field, let sort, let addSort):
                
                var params: [[String: Any]] = []
                
                params.append([
                    "field": field,
                    "sort": sort.rawValue
                ])
                
                if let addSort = addSort {
                    params.append(contentsOf: addSort.params)
                }

                return params
            }
        }
    }
    
    enum PageReqParam {
        case page(_ pageNum: Int, _ pageSize: Int, _ sortsParam: PageReqSortParam)
        
        var params: [String: Any] {
            
            switch self {
            case .page(let pageNum, let pageSize, let sorts):
                return [
                    "pageReq": [
                        "page": pageNum,
                        "size": pageSize,
                        "sorts": sorts.params
                    ]
                ]
                
            }
        }
    }
    
    class func createPageReqParams(_ pageReqParam: PageReqParam) -> [String: Any] {
        return pageReqParam.params
    }
    
    class func getRoomID() -> String?{
        
        let roomID = UserDefaults.standard.string(forKey: kIsVideoRoomID)
        
        return roomID
    }
    
    class func setRoomID(roomID:String) {
        
        UserDefaults.standard.set(roomID,forKey: kIsVideoRoomID)
        UserDefaults.standard.synchronize()
    }
    
    class func getRoomJid() -> String?{
        
        let roomID = UserDefaults.standard.string(forKey: kIsVideoRoomJid)
        return roomID
    }
    
    class func setRoomJid(roomID:String?) {
        
        UserDefaults.standard.set(roomID,forKey: kIsVideoRoomJid)
        UserDefaults.standard.synchronize()
    }
    
    class func removeRoomJid() {
        if let _ = self.getRoomJid() {
            self.setRoomJid(roomID: nil)
        }
    }
    
    class func showChangeIPAlerView(){
        
        let newLifeCycle = UserDefaults.standard.bool(forKey: kNewLifeCycle)
        
        if newLifeCycle {
            UserDefaults.standard.set(false, forKey: kNewLifeCycle)
            let alert = UIAlertController(title: nil, message: NSLocalizedString("长时间连接不上，可以尝试切换服务器", comment: ""), preferredStyle: .alert)
            alert.addAction(title: "取消", style: .cancel, isEnabled: true) { (action) in
                
            }
            alert.addAction(title: "切换", style: .default, isEnabled: true) { (action) in
                let selectServersView = Bundle.main.loadNibNamed("SelectServersView", owner: self, options: nil)?.first as! SelectServersView
                selectServersView.show()
            }
            UIViewController.current()?.present(alert, animated: true, completion: nil)
        }
        
    }
    
    class func getOnlineTimeStringAndStrColor(with model: CODContactModel) -> (timeStr:String, strColor:UIColor) {
        var timeStr = ""
        var strColor: UIColor!
        if model.loginStatus.compareNoCaseForString("ONLINE") {
            timeStr = NSLocalizedString("当前在线", comment: "")
            strColor = UIColor(hexString: kTabItemSelectedColorS)!
        }else{
            if model.lastLoginTimeVisible && model.isValid {
                timeStr = TimeTool.getLastLoginTimeString(Date.init(timeIntervalSince1970:(Double(model.lastlogintime))/1000))
                strColor = UIColor(hexString: kSubTitleColors)!
            }else{
                timeStr = NSLocalizedString("最后上线于不久前", comment: "")
                strColor = UIColor(hexString: kSubTitleColors)!
            }
        }
        if model.rosterID == RobotRosterID {
            timeStr = "服务通知"
        }
        return (timeStr, strColor)
    }
    
    class func getOnlineTimeStringAndStrColor(with model: CODGroupMemberModel) -> (timeStr:String, strColor:UIColor) {
        var timeStr = ""
        var strColor: UIColor!
        var isFriend: Bool = false
        if let model = CODContactRealmTool.getContactByJID(by: model.jid), model.isValid == true {
            isFriend = true
        }
        if model.loginStatus.compareNoCaseForString("ONLINE") {
            timeStr = NSLocalizedString("当前在线", comment: "")
            strColor = UIColor(hexString: kTabItemSelectedColorS)!
        }else{
            if model.lastLoginTimeVisible && isFriend {
                timeStr = TimeTool.getLastLoginTimeString(Date.init(timeIntervalSince1970:(Double(model.lastlogintime))/1000))
                strColor = UIColor(hexString: kSubTitleColors)!
            }else{
                timeStr = NSLocalizedString("最后上线于不久前", comment: "")
                strColor = UIColor(hexString: kSubTitleColors)!
            }
        }

        return (timeStr, strColor)
    }
    
    class func stopAudioPlay() {
        
        if CODAudioPlayerManager.sharedInstance.playCell != nil {
            let cell = CODAudioPlayerManager.sharedInstance.playCell
            if (cell?.isKind(of: CODZZS_AudioRightTableViewCell.classForCoder()))! {
                let cell = CODAudioPlayerManager.sharedInstance.playCell as! CODZZS_AudioRightTableViewCell
                
                cell.reset()
            }else{
                let cell = CODAudioPlayerManager.sharedInstance.playCell as! CODZZS_AudioLeftTableViewCell
                
                cell.reset()
            }
        }
        
    }
    
    //判断群组是否有效
    class func judgeInGroupRoom(roomId: Int) -> String?{
        
        if let model = CODGroupChatRealmTool.getGroupChat(id: roomId) {
            if model.isValid {
                return ""
            }else{
                return "你已不在本群"
            }
        }
        return ""
    }
    
    //判断群组在群组中是否可以发言
    class func judgeInGroupRoomCanSpeak(roomId: Int) -> Bool{
        if let model = CODGroupChatRealmTool.getGroupChat(id: roomId) {
            if self.getIsManager(roomId: roomId, userName: UserManager.sharedInstance.jid) {
                return true
            }else{
                if model.canspeak {
                    return true
                }else{
                    return false
                }
            }
        }
        return true
    }
    
    //判断频道是否有效
    class func judgeInChannelRoom(roomId: Int) -> (isManager: Bool,isOpenNoti: Bool){
        
        if let model = CODChannelModel.getChannel(by: roomId){
            if let channelMember = model.getMember(by: UserManager.sharedInstance.loginName ?? ""){
                if channelMember.userpower == 10 || channelMember.userpower == 20{
                    return (true, model.mute)
                }else{
                    return (false, model.mute)
                }
            }else{
                return (false, model.mute)
            }
        }
        return (false, false)
    }
    
    //判断是否加入此频道
    class func judgeJoinChannelRoom(roomId: Int) -> Bool{
        
        if let chatListModel = CODChatListRealmTool.getChatList(id: roomId) {
            if chatListModel.isInValid == true {
                return false
            }
        }
        
        guard let channel = CODChannelModel.getChannel(by: roomId) else {
            return false
        }
        
        return channel.isMember(by: UserManager.sharedInstance.jid)

    }
    
    //判断是不是好友
    class func judgeInMyFriendByJID(jid: String) -> String?{
        
        if let contact = CODContactRealmTool.getContactByJID(by: jid) {
            if contact.isValid {
                return ""
            }else{
                return "对方已不是你的好友，无法发送消息"
            }
        }
        return "对方已不是你的好友，无法发送消息"
    }
    
    //判断是不是黑名单里面
    class func judgeInMyBlackListByJID(jid: String) -> String?{
        if let contact = CODContactRealmTool.getContactByJID(by: jid){
            if contact.blacklist {
                return "请您将好友移出黑名单"
            }
        }else{
            return "对方已不是你的好友，无法发送消息"
        }
        return ""

    }
    
     class func getIsManager(roomId: Int, userName: String) -> Bool {
         let memberId = CODGroupMemberModel.getMemberId(roomId: roomId, userName: userName)
         if let memberModel = CODGroupMemberRealmTool.getMemberById(memberId) {
             if memberModel.userpower < 30{
                 return true
             }
         }
         return false
     }
    
    
    class func getChatDrafts(jid: String) -> Array<Dictionary<String, Any>>? {
        if let drafts = UserManager.sharedInstance.chatDrafts {
            return drafts[jid] as? Array<Dictionary<String, Any>> ?? nil
        }
        return nil
    }
    
    class func setChatDrafts(jid: String, value: Array<Dictionary<String, Any>>?) {
        if var drafts = UserManager.sharedInstance.chatDrafts {
            if let value = value, value.count > 0 {
                drafts[jid] = value as AnyObject
            }else{
                drafts.removeValue(forKey: jid)
            }
            UserManager.sharedInstance.chatDrafts = drafts
        }else{
            guard let value = value else { return }
            UserManager.sharedInstance.chatDrafts = [jid: value as AnyObject]
        }
    }
    
    class func generateThumbnailForVideo(at url: URL) -> UIImage? {
           let kPreferredTimescale: Int32 = 1000
           let asset = AVURLAsset(url: url)
           let generator = AVAssetImageGenerator(asset: asset)
           generator.appliesPreferredTrackTransform = true

           var actualTime: CMTime = CMTime(seconds: 0, preferredTimescale: kPreferredTimescale)
           //generates thumbnail at first second of the video
           let cgImage = try? generator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: kPreferredTimescale), actualTime: &actualTime)
           return cgImage.flatMap() { return UIImage(cgImage: $0, scale: UIScreen.main.scale, orientation: .up) }
    }
    
}

extension UISearchBar{
    
    var customTextField: UITextField? {
        get {
            if #available(iOS 13.0, *) {
                return self.searchTextField
            }else{
                let searchBarTF = self.value(forKey: "_searchField") as? UITextField
                return searchBarTF
            }
        }
    }

}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint

     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
    */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {

        NSLayoutConstraint.deactivate([self])

        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)

        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier

        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

extension UIImage {
    class func sendIcon() -> UIImage{
        #if MANGO
        let sendImage:UIImage = UIImage(named:"mango_send_icon")!
//        let kMoreSendImageHL:UIImage = UIImage(named:"mango_send_icon")!
        #elseif PRO
        let sendImage:UIImage = UIImage(named:"send_icon")!
//        let kMoreSendImageHL:UIImage = UIImage(named:"send_icon")!
        #else
        let sendImage:UIImage = UIImage(named:"im_send_icon")!
//        let kMoreSendImageHL:UIImage = UIImage(named:"im_send_icon")!
        #endif
        return sendImage
    }
    
    class func sendVoiceIcon() -> UIImage{
        #if MANGO
        let sendImage:UIImage = UIImage(named:"mango_send_voice_icon")!
        #elseif PRO
        let sendImage:UIImage = UIImage(named:"flygram_send_voice_icon")!
        #else
        let sendImage:UIImage = UIImage(named:"xinhoo_send_voice_icon")!
        #endif
        return sendImage
    }
    
    class func helpIcon() -> UIImage {
        #if MANGO
        let helpIcon = UIImage(named: "Mango_help_icon")!
        #elseif PRO
        let helpIcon = UIImage(named: "cod_help_icon")!
        #else
        let helpIcon = UIImage(named: "im_security_code_logo")!
        #endif
        return helpIcon
    }
    
    class func getHelpIconName() -> String {
        #if MANGO
        let helpIcon = "Mango_help_icon"
        #elseif PRO
        let helpIcon = "cod_help_icon"
        #else
        let helpIcon = "im_security_code_logo"
        #endif
        return helpIcon
    }
    
    class func getChatSearchLeftIconName()-> UIImage? {

        
       let languageStr = CustomUtil.getCurrentLanguage()
        var iconName = ""
        if (languageStr.contains("zh-Hans")) {
            iconName = "member_search_from"
        }else if (languageStr.contains("en")) {
            iconName = "member_search_from_en"
        }else if (languageStr.contains("zh-Hant")) {
            iconName = "member_search_from_zn"
        }else{
            iconName = "member_search_from_en"
        }
        return UIImage.init(named: iconName)
    }
    
    class func getGifImage(imageName: String) -> UIImage? {
        if let bundlePath = Bundle.main.url(forResource: imageName, withExtension: "gif"),let fileData = NSData.init(contentsOf: bundlePath){
            return UIImage.init(data: fileData as Data)
        }
        return self.init(named: "")
    }
    
    
}

extension Data {
    
    func sha512() -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        CC_SHA512([UInt8](self), CC_LONG(self.count), &digest)
        
        
        /// 转base64
        /*
        let resultBytes = Data(bytes: digest, count: Int(CC_SHA512_DIGEST_LENGTH))
        let resultStr = resultBytes.base64EncodedString()
        return resultStr
        */
        
        /// 无需base64输出,装换为16进制字符串输出
        let output = NSMutableString(capacity: Int(CC_SHA512_DIGEST_LENGTH))
        for byte in digest {
            output.appendFormat("%02x", byte)
        }
        return output as String
        
    }
}

extension URL {
    /// check if the URL is a directory and if it is reachable
    func isDirectoryAndReachable() throws -> Bool {
        guard try resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true else {
            return false
        }
        return try checkResourceIsReachable()
    }

    /// returns total allocated size of a the directory including its subFolders or not
    func directoryTotalAllocatedSize(includingSubfolders: Bool = false) throws -> Int? {
        guard try isDirectoryAndReachable() else { return nil }
        if includingSubfolders {
            guard
                let urls = FileManager.default.enumerator(at: self, includingPropertiesForKeys: nil)?.allObjects as? [URL] else { return nil }
            return try urls.lazy.reduce(0) {
                    (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0) + $0
            }
        }
        return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil).lazy.reduce(0) {
                 (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
                    .totalFileAllocatedSize ?? 0) + $0
        }
    }

    /// returns the directory total size on disk
    func sizeOnDisk() throws -> Int? {
        guard let size = try directoryTotalAllocatedSize(includingSubfolders: true) else { return nil }
        return size
    }
}
