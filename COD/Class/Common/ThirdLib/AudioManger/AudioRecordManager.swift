//
//  AudioRecordManager.swift
//  TestApp
//
//  Created by syslinc_dabo on 11/14/18.
//  Copyright © 2018 syslinc_dabo. All rights reserved.
//

import Foundation
import AVFoundation


private let audioTemporarySavePath:String = CODFileManager.shareInstanceManger().temporaryDatPathWithName()   //amr 临时路径

let AudioRecordInstance = AudioRecordManager.sharedInstance
class AudioRecordManager: NSObject {
    var recorder: AVAudioRecorder!
    var timer: Timer?
    var operationQueue: OperationQueue!
    weak var delegate: RecordAudioDelegate?
    
    var audioFileSavePath:String {
        return CODFileManager.shareInstanceManger().temporaryMp3PathWithName() //mp3临时路径
    }
    
    fileprivate var startTime: CFTimeInterval! //录音开始时间
    fileprivate var endTimer: CFTimeInterval! //录音结束时间
    fileprivate var audioTimeInterval: NSNumber!
    fileprivate var isFinishRecord: Bool = true
    fileprivate var isCancelRecord: Bool = false
    fileprivate var time: TimeInterval = 0.0
    class var sharedInstance : AudioRecordManager {
        struct Static {
            static let instance : AudioRecordManager = AudioRecordManager()
        }
        return Static.instance
    }
    
    fileprivate override init() {
        self.operationQueue = OperationQueue()
        
        super.init()
    }
    func dispatch_async_safely_to_main_queue(_ block: @escaping ()->()) {
        dispatch_async_safely_to_queue(DispatchQueue.main, block)
    }
    // This methd will dispatch the `block` to a specified `queue`.
    // If the `queue` is the main queue, and current thread is main thread, the block
    // will be invoked immediately instead of being dispatched.
    func dispatch_async_safely_to_queue(_ queue: DispatchQueue, _ block: @escaping ()->()) {
        if queue === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            queue.async {
                block()
            }
        }
    }
    /**
     获取录音权限并初始化录音
     */
    func checkPermissionAndSetupRecord() {
        let session = AVAudioSession.sharedInstance()
        do {
            
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: [])
            do {
                try session.setActive(true)
                session.requestRecordPermission{allowed in
                    if !allowed {
                        CODAlertViewToSetting_show("无法访问您的麦克风", message: "请到设置 -> 隐私 -> 麦克风 ，打开访问权限")
                    }
                }
            } catch _ as NSError {
                CODAlertViewToSetting_show("无法访问您的麦克风")
            }
        } catch _ as NSError {
            CODAlertViewToSetting_show("无法访问您的麦克风")
        }
    }
    fileprivate func showAlertView(title:String,message:String){
        ///
    }
    /**
     监听耳机插入的动作
     */
    func checkHeadphones() {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if currentRoute.outputs.count > 0 {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSession.Port.headphones {
                    //                    log.info("headphones are plugged in")
                    break
                } else {
                    //                    log.info("headphones are unplugged")
                }
            }
        } else {
            //            log.info("checking headphones requires a connection to a device")
        }
    }
    
    
    /**
     开始录音
     */
    func startRecord() {
        //防止点击太快会崩溃的问题
        let currentTime: TimeInterval = Date.init().timeIntervalSince1970
        if currentTime - time < 1 {
            time = currentTime
            if self.delegate != nil {
                self.delegate?.audioRecordCanceled()
                return
            }
        }
        time = currentTime

//        NotificationCenter.default.post(name: NSNotification.Name.init(kAudioCallBegin), object: nil)
        
//        CODAudioPlayerManager.sharedInstance.stop()
        ///先取消录音
        if self.recorder == nil{
            self.timer?.invalidate()
            self.timer = nil
            self.isCancelRecord = false
            self.isFinishRecord = false
            do {
                //基础参数
                let recordSettings:[String : AnyObject] = [
                    //线性采样位数  8、16、24、32
                    AVLinearPCMBitDepthKey: NSNumber(value: 16 as Int32),
                    //设置录音格式  AVFormatIDKey == kAudioFormatLinearPCM
                    AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM as UInt32),
                    //录音通道数  1 或 2
                    AVNumberOfChannelsKey: NSNumber(value: 2 as Int32),
                    //设置录音采样率(Hz) 如：AVSampleRateKey == 8000/44100/96000（影响音频的质量）
                    AVSampleRateKey: NSNumber(value: 44100.0 as Float),
                    AVEncoderAudioQualityKey: NSNumber(value: Int8(AVAudioQuality.min.rawValue))
                ]
                if FileManager.default.fileExists(atPath:audioTemporarySavePath) {
                    FileManager.default.isDeletableFile(atPath: audioTemporarySavePath)
                }
                self.startTime = CACurrentMediaTime()
                self.recorder = try AVAudioRecorder(url: URL(string:audioTemporarySavePath)!, settings: recordSettings)
                self.recorder.delegate = self
                self.recorder.isMeteringEnabled = true
                self.recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
                
                print("112345678")
                self.readyStartRecord()
                
            } catch  {
            
                self.recorder = nil
                #if XINHOO
                CODAlertView_show("初始化录音功能失败", message: error.localizedDescription)
                #endif
            }
            
        }
    }
    /**
     准备录音
     */
    @objc func readyStartRecord() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: [])
        } catch _ as NSError  {
            CODAlertViewToSetting_show("无法访问您的麦克风")
            return
        }
        do {
            try audioSession.setActive(true)
        } catch _ as NSError {
            CODAlertViewToSetting_show("无法访问您的麦克风")
            return
        }
        self.isCancelRecord = false
        let operation = BlockOperation()
        operation.addExecutionBlock(updateRecordTime)
        self.operationQueue.addOperation(operation)
        
        ///边录边转码
        ConvertAudioFile.sharedInstance().conventToMp3(withCafFilePath: audioTemporarySavePath, mp3FilePath: audioFileSavePath, sampleRate: Int32(44100)) {[weak self] (result) in
            if(result){
                try! AVAudioSession.sharedInstance().setCategory(.playback)
                if self?.isCancelRecord ?? false{
                    self?.isCancelRecord = false
                }else{
                    self?.audioRecorderSuccess()
                }
            }
        }
        self.recorder.record()
    }
    
    @objc func updateRecordTime() {
        
        guard let recorder = self.recorder else { return }
        
        repeat {
            recorder.updateMeters()
            self.audioTimeInterval = NSNumber(value: NSNumber(value: recorder.currentTime as Double).floatValue as Float)
            
            let averagePower = recorder.averagePower(forChannel: 0)
            let lowPassResults = pow(10, (0.05 * averagePower)) * 10
            dispatch_async_safely_to_main_queue({ () -> () in
                if self.delegate != nil{
                    self.delegate?.audioRecordVolume(lowPassResults)
                }
            })
            ///更新录音时间
            if self.delegate != nil{
                self.delegate!.audioRecordTime(Int(self.audioTimeInterval!.int32Value))
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kSendVoiceRecord), object: nil, userInfo: [
                "decibel": lowPassResults,
                "recordTime": Int(self.audioTimeInterval!.int32Value)
            ])
            
            //如果大于 60 ,停止录音
            if self.audioTimeInterval.int32Value > 60 {
                self.stopRecord()
            }
            Thread.sleep(forTimeInterval: 0.1)
        } while(recorder.isRecording)
        
    }
    /**
     停止录音
     */
    func stopRecord() {
        self.timer?.invalidate()
        self.timer = nil
        self.isFinishRecord = true
        self.isCancelRecord = false
        self.endTimer = CACurrentMediaTime()
        if (self.endTimer - self.startTime) < 1 {
            dispatch_async_safely_to_main_queue({ () -> () in
                self.delegate?.audioRecordTooShort()
            })
        } else {
            
            if self.audioTimeInterval.int32Value < 1 {
                self.perform(#selector(AudioRecordManager.readyStopRecord), with: self, afterDelay: 0.5)
            } else {
                self.readyStopRecord()
            }
        }
        self.operationQueue.cancelAllOperations()
        
    }
    
    /**
     取消录音
     */
    func cancelRrcord() {
        self.timer?.invalidate()
        self.isCancelRecord = true
        self.timer = nil
        self.isCancelRecord = true
        self.isFinishRecord = false
        if self.recorder != nil {
            self.recorder.stop()
            self.recorder.deleteRecording()
            self.recorder = nil
        }
        self.audioTimeInterval = 0
        ConvertAudioFile.sharedInstance().sendEndRecord()
        self.delegate?.audioRecordCanceled()
    }
    
    @objc func readyStopRecord() {
        if self.recorder == nil {
            return
        }
        self.recorder.stop()
        self.recorder = nil
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
        } catch  _ as NSError {
        }
    }
    
    /**
     删除录音文件
     */
    func deleteRecordFiles() {
        
    }
    
    func otherFunc() {
        
    }
}


// MARK: - @protocol AVAudioRecorderDelegate
extension AudioRecordManager : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag && self.isFinishRecord {
            ConvertAudioFile.sharedInstance().sendEndRecord()
        } else {
            //如果不是取消录音，再进行回调 failed 方法
            if !self.isCancelRecord {
                self.delegate?.audioRecordFailed()
            }
        }
    }
    func audioRecorderSuccess() {
      
        
        ///主线程操作数据 删除数据等等
        dispatch_async_safely_to_main_queue({ () -> () in
            ///设置录音文件名

            let date = Date()
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let strNowTime = timeFormatter.string(from: date as Date) as String
            ///文件名
            let fileName = strNowTime.md5()
            let mp3FileName = CODFileManager.shareInstanceManger().mp3PathWithName(fileName: fileName)
            
            if !FileManager.default.fileExists(atPath:mp3FileName) {
                do {
                    try FileManager.default.copyItem(atPath: self.audioFileSavePath, toPath: mp3FileName)
                }catch{
                    self.delegate?.audioRecordFailed()
                    return
                }
            }
            ///删除临时文件
            do {
                try FileManager.default.removeItem(atPath: audioTemporarySavePath)
                try FileManager.default.removeItem(atPath:self.audioFileSavePath)
            }catch{
            }
            if !FileManager.default.fileExists(atPath: mp3FileName){
                self.delegate?.audioRecordFailed()
                return
            }
            
            self.delegate?.audioRecordFinish(recordTime: self.audioTimeInterval.floatValue,disPlayName:fileName,fileName:mp3FileName)
        })
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if error != nil {
            self.delegate?.audioRecordFailed()
        }
    }
}


