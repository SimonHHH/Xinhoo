//
//  CODAudioPlayerManager.swift
//  COD
//
//  Created by xinhooo on 2019/6/11.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODAudioPlayerManager: NSObject ,AVAudioPlayerDelegate{

    var player: AVAudioPlayer?
    var playCell : UITableViewCell?
    var playModel : CODMessageModel?
    
    var isAudioPlaying = true
    
    
    typealias FinishBlock = () -> ()
    typealias PlayerInitSuccess = (AVAudioPlayer) -> ()
    var finishBlock:FinishBlock?
    
    class var sharedInstance : CODAudioPlayerManager {
        struct Static {
            static let instance : CODAudioPlayerManager = CODAudioPlayerManager()
        }
        return Static.instance
    }

    fileprivate override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(sensorStateChange(noti:)), name:UIDevice.proximityStateDidChangeNotification , object: nil)
    }
    
    @objc func sensorStateChange(noti:NSNotification) {
        
        if UserDefaults.standard.bool(forKey: kIsVideoCall) {
            return
        }
        
        if UIDevice.current.proximityState {
            try! AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            print("耳朵贴近了")
        }else{
            try! AVAudioSession.sharedInstance().setCategory(.playback)
            print("耳朵离开了")
        }
        
    }
    
    func playAudio(jid:String, audioID:String,playerSuccess: PlayerInitSuccess? = nil,finishBlock:@escaping FinishBlock) {
        
        
        self.finishBlock = finishBlock
        
        let defaultFileManager = FileManager.default
        
        let lastStr = audioID.components(separatedBy: "/").last
        
        let audioFilePath = self.pathUserPathWithAudio(jid: jid).appendingPathComponent(lastStr!).appendingPathExtension("mp3")
        
        if defaultFileManager.fileExists(atPath: audioFilePath!) {
            
            if self.player == nil {
                self.isAudioPlaying = true
                do {
                    self.player = try AVAudioPlayer.init(contentsOf: URL.init(fileURLWithPath: audioFilePath!), fileTypeHint: AVFileType.mp4.rawValue)
                    
                    if self.player != nil {
                        
                        playerSuccess?(self.player!)
                    }
                    
                    self.player?.delegate = self
                    self.player!.prepareToPlay()
                    self.play()
                }catch{
                    print(error)
                }
                
                
            }else{
                
                if self.player?.url?.absoluteString == URL.init(fileURLWithPath: audioFilePath!).absoluteString {
                
                    if self.isAudioPlaying {
                        self.pause()
                        if self.player != nil {
                            
                            playerSuccess?(self.player!)
                        }
                        
                    }else{
                        self.play()
                        if self.player != nil {
                            
                            playerSuccess?(self.player!)
                        }
                    }
                    
                }else{
                    self.isAudioPlaying = true
//                    self.player = try! AVAudioPlayer.init(contentsOf: URL.init(fileURLWithPath: audioFilePath!))
                    do {
                        self.player = try AVAudioPlayer.init(contentsOf: URL.init(fileURLWithPath: audioFilePath!), fileTypeHint: AVFileType.mp4.rawValue)
                        
                        if self.player != nil {
                            
                            playerSuccess?(self.player!)
                        }
                        
                        self.player?.delegate = self
                        self.player!.prepareToPlay()
                        self.play()
                    }catch{
                        print(error)
                    }
                    
                }
            }
        }
    }
    
    func isPlaying() -> Bool {
        if self.player == nil {
            return false
        }else{
            return self.isAudioPlaying
        }
    }
    
    func play() {
        if self.player != nil {
            UIDevice.current.isProximityMonitoringEnabled = true
            self.player?.play()
            self.isAudioPlaying = true
        }
    }
    
    func pause() {
        if self.player != nil {
            UIDevice.current.isProximityMonitoringEnabled = false
            self.player?.pause()
            self.isAudioPlaying = false
            
        }
    }
    
    func stop() {
        if self.player != nil {
            
            if UIDevice.current.proximityState {
                UIDevice.current.isProximityMonitoringEnabled = true
            }else{
                UIDevice.current.isProximityMonitoringEnabled = false
            }
            self.playCell = nil
            self.player?.stop()
            self.player = nil
            self.playModel?.isPlay = false
            self.isAudioPlaying = false
        }
    }
    
    func setCurrentTime(time:TimeInterval) {
        if self.player != nil {
            self.player?.currentTime = time
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playModel?.isPlay = false
        self.isAudioPlaying = false
        if self.finishBlock != nil {
            self.finishBlock!()
        }else{
            
            NotificationCenter.default.post(name: NSNotification.Name.init(kAudioPlayEnd), object: nil)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.init("kDisplayViewAudioPlayEnd"), object: nil)
        
    }
    
    func pathUserPathWithAudio(jid:String) -> String{
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documnetPath = documentPaths[0]
        var userDocumnetPath = documnetPath.appendingPathComponent(UserManager.sharedInstance.loginName!).appendingPathComponent("message").appendingPathComponent(jid).appendingPathComponent("Voices")
        //判断是否有文件存在
        if(!FileManager.default.fileExists(atPath: userDocumnetPath)){
            do{
                try FileManager.default.createDirectory(atPath: userDocumnetPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                CCLog("创建用户文件失败!")
                userDocumnetPath = ""
            }
        }
        return userDocumnetPath
    }

    func audioExists(_ messageModel: CODMessageModel) -> Bool {

        var jid = ""
        
        switch messageModel.chatTypeEnum {
        case .channel, .groupChat:
            jid = messageModel.toJID
            
        case .privateChat:
            if messageModel.fromJID.contains(UserManager.sharedInstance.loginName!) {
                jid = messageModel.toJID
            } else {
                jid = messageModel.fromJID
            }

        }

        var url = ""
        if let audioLocalURL = messageModel.audioModel?.audioLocalURL,audioLocalURL.count > 0 {
            url = audioLocalURL
        } else {
            url = messageModel.audioModel?.audioURL ?? ""
        }
        
        let filePath = self.pathUserPathWithAudio(jid: jid).appendingPathComponent(url).appendingPathExtension("mp3")
        return FileManager.default.fileExists(atPath: filePath ?? "")

    }

}
