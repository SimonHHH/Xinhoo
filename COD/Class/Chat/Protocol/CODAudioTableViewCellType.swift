//
//  CODAudioTableViewCellType.swift
//  COD
//
//  Created by Sim Tsai on 2019/12/6.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation
import UIKit



protocol CODAudioTableViewCellType {
    
    func initPlayButtonState(_ button: CODAudioPlayButton)
    func onClickAudioPlayButton(_ button: CODAudioPlayButton, _ messageModel: CODMessageModel)
    func downloadAudio(_ button: CODAudioPlayButton, _ messageModel: CODMessageModel)
    func playAudio()
    
    var isNoFile: Bool { get }
    var messageModel: CODMessageModel { get }
}

extension CODAudioTableViewCellType {
    
    var isNoFile: Bool {
        return !CODAudioPlayerManager.sharedInstance.audioExists(self.messageModel)
    }
    
    func downloadAudio(_ button: CODAudioPlayButton, _ messageModel: CODMessageModel) {
        CODDownLoadManager.sharedInstance.downloadAudio(messageModel: messageModel) {
            button.progress = (Float($0.completedUnitCount) / Float($0.totalUnitCount)).cgFloat
        }
        button.payButtonState = .downloading
    }
    
    func onClickAudioPlayButton(_ button: CODAudioPlayButton, _ messageModel: CODMessageModel) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kSendVoiceStopPlay), object: nil)
        
        if button.payButtonState == .noFile {
            downloadAudio(button, messageModel)
        } else if button.payButtonState == .downloading {
            button.payButtonState = .noFile
            button.progress = 0
            CODDownLoadManager.sharedInstance.cancelAudioDownload(messageModel: messageModel)
        } else if button.payButtonState == .pause {
            self.playAudio()
            button.payButtonState = .play
        } else {
            self.playAudio()
            button.payButtonState = .pause
        }
    }
    
    func autoDownloadAudio(_ button: CODAudioPlayButton, _ messageModel: CODMessageModel) {
        if self.isNoFile {
            self.downloadAudio(button, messageModel)
        }
    }
    
    func initPlayButtonState(_ button: CODAudioPlayButton) {
        if self.isNoFile {
            button.payButtonState = .noFile
        } else {
            if self.messageModel.isPlay {
                button.payButtonState = .play
            }else{
                button.payButtonState = .pause
            }
        }
    }
    
}


extension CODZZS_AudioRightTableViewCell: CODAudioTableViewCellType {}
extension CODZZS_AudioLeftTableViewCell: CODAudioTableViewCellType {}
