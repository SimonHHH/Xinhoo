//
//  Xinhoo_FileViewModel.swift
//  COD
//
//  Created by xinhooo on 2019/12/9.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Xinhoo_FileViewModel: ChatCellVM {
    
    enum DownloadState {
        case ide
        case loading
        case finished
    }
    
    static var downloadProgressDic: Dictionary<String, BehaviorRelay<Float>> = [:]
 
    var downloadProgress: BehaviorRelay<Float>
    
    var isFW: Bool {
        return self.model.isFw
    }
    
    var iconImage: UIImage? {
        
        if cellDirection == .right {
            return UIImage(named: "chat_right_file")
        } else {
            return UIImage(named: "chat_left_file")
        }
        
    }
    
    var cancelImage: UIImage? {
        if cellDirection == .right {
            return UIImage(named: "file_download_cancel_right")
        } else {
            return UIImage(named: "file_download_cancel_left")
        }
    }
    
    var fileNameAtt: NSAttributedString {
        
        let filename = self.model.fileModel?.filename ?? ""
        
        let name = NSMutableAttributedString(string: filename)
        
        name.yy_font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        if cellDirection == .right {
            
            name.yy_color = UIColor(hexString: "#4FB54F")
            
        } else {
            name.yy_color = UIColor(hexString: "#007EE5")
        }
        
        return name
        
    }
    
    var sizeString: String {
        
        if messageModel.fileModel?.fileSizeString.count ?? 0 > 0{
            return messageModel.fileModel?.fileSizeString ?? ""
        }else{
            return String(format: "%ld", messageModel.fileModel?.size ?? 0)
        }
        
    }
    
    var sizeAttr: NSAttributedString {
        
        
        let sizeAttr = NSMutableAttributedString(string: self.sizeString)
        
        sizeAttr.yy_font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        if cellDirection == .right {
            
            sizeAttr.yy_color = UIColor(hexString: "#6BB968")
            
        } else {
            sizeAttr.yy_color = UIColor(hexString: "#999999")
        }
        
        return sizeAttr
        
    }
    
    func getDowloadSizeAttr(progress: CGFloat) -> NSAttributedString {
        
        let sizeAttr = self.sizeAttr.mutableCopy() as! NSMutableAttributedString
        
        let fileSize = (self.model.fileModel?.size ?? 0).cgFloat * progress
        let fileSizeStr = CODFileHelper.getFileSize(fileSize: fileSize)

        sizeAttr.yy_insertString("\(fileSizeStr)/ ", at: 0)
        
        return sizeAttr
    }
    
    
    var downloadImage: UIImage? {
        
        if self.cellDirection == .left {
            return UIImage(named: "file_message_left_download")
        } else {
            return UIImage(named: "file_message_right_download")
        }
        
    }

    
    var hasText: Bool {
        return self.model.fileModel?.descriptionFile.count ?? 0 > 0
    }
    
    var isImage: Bool {
        return self.model.fileModel?.isImageOrVideo ?? false
    }
    
    var fileImageThumbURL: URL? {
        
        let thumb = self.model.fileModel?.thumb ?? ""
        
        if self.model.isCloudDiskMessage {
            return ServerUrlTools.getServerUrl(store: .CloudDisk(fileType: .Image(thumb, .small)))
        } else {
            return ServerUrlTools.getServerUrl(store: .Message(fileType: .Image(thumb, .small)))
        }
        

    }
    
    var downloadState: Observable<DownloadState> {
        
        if messageModel.statusType != .Succeed {
            return Observable.empty()
        }
        
        guard let fileModel = messageModel.fileModel else {
            return Observable.empty()
        }
        
        if fileModel.fileExists {
            return Observable.just(DownloadState.finished)
        }
        
        return fileModel.rx.observe(\.downloadState)
        .filterNil().map { DownloadStateType(value: $0) }
        .map {
            
            switch $0 {
                
            case .Downloading:
                return .loading
            case .None:
                return (fileModel.fileExists ? .finished : .ide)
            case .Finished:
                return (fileModel.fileExists ? .finished : .ide)
            case .Cancel:
                return .ide
                
            }
            
        }
        .do(onNext: { [weak self] (value) in
            guard let `self` = self else { return }
            if value == .finished { self.downloadProgress.accept(0) }
        })
        
        
        

    }
    
    override init(name: String = UITableViewCell.self.description(), messageModel: CODMessageModel, cellHeight: CGFloat = UITableView.automaticDimension) {
        
        if let fileModel = messageModel.fileModel   {
            if let downloadProgress = Xinhoo_FileViewModel.downloadProgressDic[fileModel.localFileID] {
                self.downloadProgress = downloadProgress
            } else {
                
                if fileModel.fileExists {
                    self.downloadProgress = BehaviorRelay<Float>(value: 0)
                } else {
                    self.downloadProgress = BehaviorRelay<Float>(value: 0)
                }
                
                Xinhoo_FileViewModel.downloadProgressDic[fileModel.localFileID] = self.downloadProgress
                
            }
        } else{
            self.downloadProgress = BehaviorRelay<Float>(value: 0)
        }
        
        super.init(name: name, messageModel: messageModel)
        
        self.cellType = CODChatTextureCell.self.description()
        
        
        
    }
    
}
