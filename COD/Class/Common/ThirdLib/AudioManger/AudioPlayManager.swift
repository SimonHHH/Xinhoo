//
//  AudioPlayerManager.swift
//  TestApp
//
//  Created by syslinc_dabo on 11/14/18.
//  Copyright © 2018 syslinc_dabo. All rights reserved.
//

import Foundation
import AVFoundation
import Alamofire


private let AudioPlayInstance = AudioPlayManager.sharedInstance
private let PLAY_SUCCESS_1 = "播放成功!"

private let PLAY_ERROR_1 = "播放器初始化错误!"

private let PLAY_ERROR_2 = "语音文件损坏！"
private let PLAY_ERROR_3 = "语音文件为空!"

class AudioPlayManager: NSObject {
    var audioPlayer: AVAudioPlayer?
    weak var delegate: PlayAudioDelegate?
    public var isPlaying:Bool = false ///语音播放是否在播放中
    public var playURL:String = "" ///语音播放的地址
    typealias PlayStatusBlock = (_ status:CODPlayerStatusType,_ error:String?) -> Void //播放的
    var playerBlock:PlayStatusBlock?
    class var sharedInstance : AudioPlayManager {
        struct Static {
            static let instance : AudioPlayManager = AudioPlayManager()
        }
        return Static.instance
    }
    
    fileprivate override init() {
        super.init()
        //监听听筒和扬声器
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NSNotification.Name.NSProcessInfoPowerStateDidChange.rawValue), object: UIDevice.current, queue: nil) { (notification) in
            if UIDevice.current.proximityState {
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
                } catch _ {}
            } else {
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                } catch _ {}
            }
        }
    }
    ///开始播放要直接返回播放成功或者失败的按钮回去
    func startPlaying(_ audioModel:CODMessageModel,playerType:@escaping PlayStatusBlock) {
        ///先要判断是下载文件还是本地播放
        ///判断本地文件是不是存在
        self.playerBlock = playerType
        self.playURL = audioModel.audioModel?.audioURL ?? ""
        if (audioModel.audioModel?.audioLocalURL.charactersArray.count ?? 0 > 0){
            if (audioModel.audioModel?.audioLocalURL.count ?? 0 > 0){
                self.playSoundWithPath(audioModel.audioModel?.audioLocalURL ?? "")
            }else{
                ///没有本地文件
                self.setNetWorkPlayAudio(audioModel)
            }
        }else{
            if audioModel.audioModel?.audioURL.charactersArray.count ?? 0 > 0{ ///有远程文件
                self.setNetWorkPlayAudio(audioModel)
            }else{
                self.delegate?.audioPlayFailed()
                self.isPlaying = false;
                if self.playerBlock != nil{
                    self.playerBlock!(CODPlayerStatusType.CODPlayerStatusError,PLAY_ERROR_3)
                }
            }
        }
    }
    
    /// 网络播放 audioModel
    ///
    /// - Parameter audioModel: 模型
    fileprivate func setNetWorkPlayAudio(_ audioModel: CODMessageModel){
        if (audioModel.audioModel?.audioURL.charactersArray.count ?? 0 > 0){
            let url = audioModel.audioModel?.audioURL
            let mD5Url = url?.md5()
            ///判断这个文件存不存在
            let fileName = CODFileManager.shareInstanceManger().mp3PathWithName(fileName: mD5Url ?? "")

            if FileManager.default.fileExists(atPath:fileName){
                self.playSoundWithPath(fileName)
            }else{
                ///文件不存在下载
                self.downloadAudio(audioModel)
            }
        }else{
            self.delegate?.audioPlayFailed()
            self.isPlaying = false;
            if self.playerBlock != nil{
                self.playerBlock!(CODPlayerStatusType.CODPlayerStatusError,PLAY_ERROR_3)
            }
        }
    }
    
    // AVAudioPlayer 只能播放 wav 格式，不能播放 amr
    fileprivate func playSoundWithPath(_ path: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }  catch let error {
            print("Unable to configure audio sesson category: \(error)")
        }
        do {
            self.audioPlayer = try  AVAudioPlayer(contentsOf: URL(fileURLWithPath:path), fileTypeHint: AVFileType.mp3.rawValue)
            self.audioPlayer?.delegate = self
            self.audioPlayer?.prepareToPlay()
            if (self.audioPlayer?.play())!{
                UIDevice.current.isProximityMonitoringEnabled = true
                self.delegate?.audioPlayStart()
                self.isPlaying = true;
            } else {
                self.destroyPlayer()
                self.delegate?.audioPlayFailed()
                self.isPlaying = false;
                if self.playerBlock != nil{
                    self.playerBlock!(CODPlayerStatusType.CODPlayerStatusError,PLAY_ERROR_1)
                }
            }
        } catch {
           self.playSoundWithMp4Path(path)
        }
    }
    
    fileprivate func playSoundWithMp4Path(_ path: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }  catch let error {
            print("Unable to configure audio sesson category: \(error)")
        }
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath:path), fileTypeHint: AVFileType.mp4.rawValue)
            self.audioPlayer?.delegate = self
            self.audioPlayer?.prepareToPlay()
            if (self.audioPlayer?.play())!{
                UIDevice.current.isProximityMonitoringEnabled = true
                self.delegate?.audioPlayStart()
                self.isPlaying = true;
            } else {
                self.isPlaying = false;
                self.destroyPlayer()
                self.delegate?.audioPlayFailed()
                if self.playerBlock != nil{
                    self.playerBlock!(CODPlayerStatusType.CODPlayerStatusError,PLAY_ERROR_1)
                }
            }
        } catch {
            self.destroyPlayer()
            self.isPlaying = false;
            self.delegate?.audioPlayFailed()
            if self.playerBlock != nil{
                self.playerBlock!(CODPlayerStatusType.CODPlayerStatusError,PLAY_ERROR_1)
            }
        }
    }
    
    func destroyPlayer() {
        self.isPlaying = false
        self.stopPlayer()
    }
    
    func stopPlayer() {
        self.isPlaying = false
        if self.audioPlayer == nil {
            return
        }
        if self.playerBlock != nil{
            self.playerBlock!(CODPlayerStatusType.CODPlayerStatusSuccess,PLAY_SUCCESS_1)
        }
        self.audioPlayer!.delegate = nil
        self.audioPlayer!.stop()
        self.audioPlayer?.prepareToPlay() //重置AVAudioSession
        self.audioPlayer = nil
        UIDevice.current.isProximityMonitoringEnabled = false
    }
    /**
     使用 Alamofire 下载并且存储文件
     */
    fileprivate func downloadAudio(_ audioModel: CODMessageModel) {
        let url = audioModel.audioModel?.audioURL
        let mD5Url = CODFileManager.shareInstanceManger().mp3PathWithName(fileName: url?.md5() ?? "")
        let filePath = "file:///" + mD5Url
        var urlString = URLRequest(url: URL(string:audioModel.audioModel?.audioURL ?? "")!)
        let nameStr = String(format: "%@:%@",UserManager.sharedInstance.loginName ?? "",UserManager.sharedInstance.password ?? "")
        let utf8Data = nameStr.data(using: String.Encoding.utf8)
        let base64String = utf8Data?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        let authValue = String(format: "Basic %@", base64String ?? "")
        urlString.setValue("*/*", forHTTPHeaderField: "Accept")
        urlString.setValue(authValue, forHTTPHeaderField: "Authorization")

        let destination = DownloadRequest.suggestedDownloadDestination(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        HttpManager.share.manager.download(urlString, interceptor: afHttpAdapter, to: destination).authenticate(with: ClientTrust.sendClientCer()).downloadProgress { (progress) in
            }.response { (response) in
                if let _ = response.error, let delegate = self.delegate {
                    delegate.audioPlayFailed()
                    self.playSoundWithPath(mD5Url)
                    print("\(response.error)")
                } else {
                    ///下载好的文件移动文件到新的文件夹
                    
                    
                    guard let downURL = response.fileURL else {
                        self.delegate?.audioPlayFailed()
                        if self.playerBlock != nil{
                            self.playerBlock!(CODPlayerStatusType.CODPlayerStatusError,PLAY_ERROR_2)
                        }
                        return
                    }
                    
                    if FileManager.default.fileExists(atPath:downURL.path) {
                        do {
                            //                            self.playSoundWithPath(downURL?.absoluteString ?? "")
                            try FileManager.default.moveItem(at: downURL, to: URL(string: filePath)!)
                        }catch{
                            self.delegate?.audioPlayFailed()
                            if self.playerBlock != nil{
                                self.playerBlock!(CODPlayerStatusType.CODPlayerStatusError,PLAY_ERROR_2)
                            }
                        }
                    }
                    ///播放
                    ///关键在这里
                    self.playSoundWithPath(mD5Url)
                }
        }
    }    
}

// MARK: - @protocol AVAudioPlayerDelegate
extension AudioPlayManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //        log.info("Finished playing the song")
        UIDevice.current.isProximityMonitoringEnabled = false
        if flag {
            self.delegate?.audioPlayFinished()
            if self.playerBlock != nil{
                self.playerBlock!(CODPlayerStatusType.CODPlayerStatusSuccess,PLAY_SUCCESS_1)
            }
        } else {
            self.delegate?.audioPlayFailed()
            if self.playerBlock != nil{
                self.playerBlock!(CODPlayerStatusType.CODPlayerStatusError,PLAY_ERROR_2)
            }
        }
        self.stopPlayer()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        self.stopPlayer()
        self.delegate?.audioPlayFailed()
        if self.playerBlock != nil{
            self.playerBlock!(CODPlayerStatusType.CODPlayerStatusError,error?.localizedDescription)
        }
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        self.stopPlayer()
        self.delegate?.audioPlayFailed()
        if self.playerBlock != nil{
            self.playerBlock!(CODPlayerStatusType.CODPlayerStatusError,PLAY_ERROR_1)
        }
    }
    
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        
    }
}











