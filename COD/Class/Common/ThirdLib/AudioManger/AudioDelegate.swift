//
//  RecordAudioDelegate.swift
//  TestApp
//
//  Created by syslinc_dabo on 11/14/18.
//  Copyright © 2018 syslinc_dabo. All rights reserved.
//

import Foundation

/**
 *  录音的 delegate 函数
 */
protocol RecordAudioDelegate: class {
    
    /// 更新录音的音量
    ///
    /// - Parameter audiotime: 录音的音量
    func audioRecordVolume(_ volume: Float)
    /// 更新录音的时间
    ///
    /// - Parameter audiotime: 录音的时间
    func audioRecordTime(_ audioTime:Int)
    /**
     录音太短
     */
    func audioRecordTooShort()
    /**
     录音失败
     */
    func audioRecordFailed()
    
    /**
     取消录音
     */
    func audioRecordCanceled()
    
    /**
     录音完成
     
     - parameter recordTime:        录音时长
     - parameter fileName:          音频数据的文件地址
     */
    func audioRecordFinish(recordTime: Float,disPlayName:String ,fileName: String)
}



/**
 *  播放的 delegate 函数
 */
protocol PlayAudioDelegate: class {
    /**
     播放开始
     */
    func audioPlayStart()

    /**
     播放完毕
     */
    func audioPlayFinished()
    
    /**
     播放失败
     */
    func audioPlayFailed()
    
    
    /**
     播放被中断
     */
    func audioPlayInterruption()
}

