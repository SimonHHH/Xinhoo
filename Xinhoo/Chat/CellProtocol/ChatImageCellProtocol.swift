//
//  ChatImageCellProtocol.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

protocol Xinhoo_LoadImageProtocol where ImageView: UIImageView {
    
    associatedtype ImageView
    
    var imgPic: ImageView! { get }
    var messageModel: CODMessageModel { get }
    var isCloudDisk:  Bool { get }
    
    func loadImagePic()
    func loadImageFormServer()
    
    var blurImageView: UIImageView! { get }
    
}

extension Xinhoo_LoadImageProtocol {
    
    func loadImagePic() {
        
        let messageModel = self.messageModel.editMessage ?? self.messageModel
        
        var autoPlay = false
        let isGIF = messageModel.photoModel?.isGIF ?? false
        if messageModel.photoModel?.isGIF ?? false && messageModel.photoModel?.size ?? 0 < 1000 * 1000 {
            autoPlay = true
        }
        
        let key = messageModel.photoModel?.photoLocalURL ?? messageModel.videoModel?.videoId
        
        if CODImageCache.default.originalImageCache?.diskImageDataExists(withKey: key) ?? false {
            self.imgPic.image = CustomUtil.getPlaceholderImage()
            if isGIF {
                let data = CODImageCache.default.originalImageCache?.diskImageData(forKey: key)
                if let data = data, autoPlay {
                    self.imgPic.image = SDAnimatedImage(data: data)
                    self.blurImageView.image  = SDAnimatedImage(data: data)
                }else{
                    
                    if CODImageCache.default.smallImageCache?.diskImageDataExists(withKey: key) ?? false {
                        self.imgPic.image = CODImageCache.default.smallImageCache?.imageFromCache(forKey: key)
                        self.blurImageView.image = CODImageCache.default.smallImageCache?.imageFromCache(forKey: key)
                    } else {
                        loadImageFormServer()
                    }
                    
                    
                }
            } else {
                self.imgPic.image = CODImageCache.default.smallImageCache?.imageFromCache(forKey: key)
                self.blurImageView.image = CODImageCache.default.smallImageCache?.imageFromCache(forKey: key)
            }
            
            self.imgPic.contentMode = .scaleAspectFit
            
            return
        }
        
        loadImageFormServer()
        
        
    }
    
    func loadImageFormServer() {
        
        var autoPlay = false
        if messageModel.photoModel?.isGIF ?? false && messageModel.photoModel?.size ?? 0 < 1000 * 1000 {
            autoPlay = true
        }
        
        var type = 1
        if autoPlay {
            type = 2
        }
        let urlString = messageModel.photoModel?.serverImageId.getImageFullPath(imageType: type, isCloudDisk: self.isCloudDisk) ?? messageModel.videoModel?.firstpicId.getImageFullPath(imageType: 1, isCloudDisk: self.isCloudDisk)
        
        if let string = urlString, let url = URL(string: string) {
            
            self.imgPic.contentMode = .center
            

            self.imgPic.sd_setImage(with: url, placeholderImage: CustomUtil.getPlaceholderImage(), options: [.retryFailed]) { (image, error, type, url) in
                self.blurImageView.image = image
                if error != nil {
                    DDLogInfo("图片加载失败\(url)：\(error)")
                    self.imgPic.contentMode = .center
                    self.imgPic.image = CustomUtil.getPictureLoadFailImage()
                }else{
                    self.imgPic.contentMode = .scaleAspectFit
                }
            }
        }
        
    }
    
}

extension Xinhoo_ImageLeftTableViewCell: Xinhoo_LoadImageProtocol, Xinhoo_BaseLeftCellProtocol {}
extension Xinhoo_ImageRightTableViewCell: Xinhoo_LoadImageProtocol {}


extension Xinhoo_ImageLeftTableViewCell: TableViewCellDataSourcesType {
    func configCellVM(pageVM: Any?, cellVM: TableViewCellVM, lastCellVM: TableViewCellVM?, nextCellVM: TableViewCellVM?, indexPath: IndexPath) {
        
        guard let cellVM = cellVM as? CellViewModelType  else {
            return
        }
        
        self.setupUI()
        
        self.commandConfig(pageVM: pageVM, cellVM: cellVM, lastCellVM: lastCellVM, nextCellVM: nextCellVM, indexPath: indexPath)
        
        configRefreshHeadImage()
        
        cellVM.cellLocationBR
            .distinctUntilChanged()
            .bind(to: self.rx.cellLocationBinder)
            .disposed(by: self.rx.prepareForReuseBag)
        
        let uploadId = messageModel.photoModel?.photoId ?? messageModel.videoModel?.videoId ?? ""
    
        if let observable = UploadTool.uploadTasksPublishRelay[uploadId] {
            
            observable.ignoreWhen({ (result) -> Bool in
                if case .none = result {
                    return true
                } else {
                    return false
                }
            }).map({ (result)  in
                
                switch result {
                    
                case .cancal:
                    return Float(0)
                case .fail:
                    return Float(0)
                case .progress(progress: let progress):
                    return progress.float
                    
                case .success(file: _), .none:
                    return Float(1)
                    
                }
                
            })
                .bind(to: self.rx.progressBinder)
                .disposed(by: self.rx.prepareForReuseBag)
            
        }
        
        if let photoModel = messageModel.photoModel {
            
            photoModel.rx.observe(\.uploadState)
                .filterNil()
                .map { UploadStateType(value: $0) }
                .bind(to: self.rx.uploadStateBinder)
                .disposed(by: self.rx.prepareForReuseBag)
            
        }
        
        if let videoInfo = messageModel.videoModel {
            
            videoInfo.rx.observe(\.uploadState)
                .filterNil()
                .map { UploadStateType(value: $0) }
                .bind(to: self.rx.uploadStateBinder)
                .disposed(by: self.rx.prepareForReuseBag)
            
        }
        
    }
}

extension Xinhoo_ImageRightTableViewCell: TableViewCellDataSourcesType {
    func configCellVM(pageVM: Any?, cellVM: TableViewCellVM, lastCellVM: TableViewCellVM?, nextCellVM: TableViewCellVM?, indexPath: IndexPath) {
        
        guard let cellVM = cellVM as? CellViewModelType  else {
            return
        }
        
        self.commandConfig(pageVM: pageVM, cellVM: cellVM, lastCellVM: lastCellVM, nextCellVM: nextCellVM, indexPath: indexPath)
        
        self.setupUI()
        
        
        cellVM.cellLocationBR
            .distinctUntilChanged()
            .bind(to: self.rx.cellLocationBinder)
            .disposed(by: self.rx.prepareForReuseBag)
        
        let messageModel = cellVM.model.editMessage ?? cellVM.model
        
        let uploadId = messageModel.photoModel?.photoId ?? messageModel.videoModel?.videoId ?? ""
        
        if let observable = UploadTool.uploadTasksPublishRelay[uploadId] {
            
            observable.ignoreWhen({ (result) -> Bool in
                if case .none = result {
                    return true
                } else {
                    return false
                }
            }).map({ (result)  in
                
                switch result {
                    
                case .cancal:
                    return Float(0)
                case .fail:
                    return Float(0)
                case .progress(progress: let progress):
                    return progress.float
                    
                case .success(file: _), .none:
                    return Float(1)
                    
                }
                
            })
                .bind(to: self.rx.progressBinder)
                .disposed(by: self.rx.prepareForReuseBag)
            
        }
        
        if let photoModel = messageModel.photoModel {
            
            photoModel.rx.observe(\.uploadState)
                .filterNil()
                .map { UploadStateType(value: $0) }
                .bind(to: self.rx.uploadStateBinder)
                .disposed(by: self.rx.prepareForReuseBag)
            
        }
        
        if let videoInfo = messageModel.videoModel {
            
            videoInfo.rx.observe(\.uploadState)
                .filterNil()
                .map { UploadStateType(value: $0) }
                .bind(to: self.rx.uploadStateBinder)
                .disposed(by: self.rx.prepareForReuseBag)
            
        }
        
        
        
        
    }
}

protocol XinhooImageCellViewProtocol {
    
    var viewModel: Xinhoo_ImageViewModel? { get }
    var lblStateDesc: UILabel! { get }
    var videoImageView:CODVideoCancleView { get }
    var viewStateDesc: UIView! { get }
    var messageModel: CODMessageModel { get }
    
    func configProgress(_ progress: Float)
    func configUploadState(_ uploadState: UploadStateType)
    
    
}

extension XinhooImageCellViewProtocol {
    
    func configUploadState(_ uploadState: UploadStateType) {
        
        if messageModel.type == .gifMessage {
            return
        }
        
        let messageModel = self.messageModel.editMessage ?? self.messageModel
        
        let messageStatus: CODMessageStatus = CODMessageStatus(rawValue: messageModel.status) ?? .Pending
        
        if messageModel.type == .video {
            
            if messageStatus != .Pending {
                self.videoImageView.showPlayVideoIconView()
            } 
            
        } else {
            self.videoImageView.hide()
        }
        
        let uploadStateType = messageModel.videoModel?.uploadStateType  ?? messageModel.photoModel?.uploadStateType ?? .None
        
        if uploadStateType == .Handling {
            self.configProgress(0)
        }
        
        if uploadStateType == .Handling && messageModel.statusType != .Failed {
            self.lblStateDesc.text = NSLocalizedString("正在处理...", comment: "")
        }
        
        if uploadStateType == .None || uploadStateType == .Fail || uploadStateType == .Finished {
            self.lblStateDesc.isHidden = true
            self.viewStateDesc.isHidden = true
        } else {
            self.lblStateDesc.isHidden = false
            self.viewStateDesc.isHidden = false
        }
        
        if messageModel.photoModel?.isGIF == true {
            self.lblStateDesc.isHidden = false
            self.viewStateDesc.isHidden = false
        }
        
    }
    
    func setupUI() {
        
        self.lblStateDesc.isHidden = true
        self.viewStateDesc.isHidden = true
        
        
        
    }
    
    func configProgress(_ progress: Float) {
        
        var uploadSize: String
        var allSize: String
        
        let messageModel = self.viewModel?.messageModel.editMessage ?? self.viewModel?.messageModel
        
        if messageModel?.statusType == .Succeed || messageModel?.statusType == .Failed || messageModel?.statusType == .Cancal {
            return
        }
        
        if self.viewModel?.messageModel.type == .video {
            
            let size = CGFloat(messageModel?.videoModel?.size ?? 0)
            
            uploadSize = CODFileHelper.getFileSize(fileSize: size * progress.cgFloat)
            allSize = CODFileHelper.getFileSize(fileSize: CGFloat(messageModel?.videoModel?.size ?? 0))
            
        } else {
            
            let size = CGFloat(messageModel?.photoModel?.size ?? 0)
            uploadSize = CODFileHelper.getFileSize(fileSize: size * progress.cgFloat)
            allSize = CODFileHelper.getFileSize(fileSize: CGFloat(messageModel?.photoModel?.size ?? 0))
        }
        
        self.lblStateDesc.text = NSLocalizedString("\(uploadSize) / \(allSize)", comment: "")
        self.videoImageView.showVideoLoadingView(progress: progress)
        
    }
    
}




extension Xinhoo_ImageLeftTableViewCell: XinhooCellViewProtocol, XinhooImageCellViewProtocol { }

extension Xinhoo_ImageRightTableViewCell: XinhooCellViewProtocol, XinhooImageCellViewProtocol { }


