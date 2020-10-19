//
//  CODChatFileNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/28.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODChatFileContentNode: CODChatContentNode {
    
    var sizeTextNode: ASTextNode2!
    var timeTextNode: ASButtonNode!
    var fileNameNode: ASTextNode2!
    var imageFileNode: CODChatFileImageNode!
    var fileIconNode: ChatFileDownloadButtonNode!
    var bgNode: CODControlNode!
    
    @_NodeLayout var editNode: CODChatContentLabelNode!
    
    override init(vm: ChatCellVM, pageVM: CODChatMessageDisplayPageVM) {
        
        super.init(vm: vm, pageVM: pageVM)
        
        bgNode = CODControlNode()
        
        sizeTextNode = ASTextNode2()
        sizeTextNode.displaysAsynchronously = false
        
        timeTextNode = ASButtonNode()
        timeTextNode.displaysAsynchronously = false
        
        fileIconNode = ChatFileDownloadButtonNode()
        fileIconNode.displaysAsynchronously = false
        fileIconNode.setImage(fileVM.iconImage, for: .normal)
        
        fileNameNode = ASTextNode2(attributedText: fileVM.fileNameAtt)
        fileNameNode.displaysAsynchronously = false
        
        imageFileNode = CODChatFileImageNode(url: nil, placeholderImage: UIImage(named: "file_message_placeholderImage"))
        imageFileNode.displaysAsynchronously = false
       
        if let image = CODImageCache.default.originalImageCache?.imageFromCache(forKey: fileVM.model.fileModel?.localFileID ?? "") {
            imageFileNode.imageView.contentMode = .scaleAspectFill
            imageFileNode.imageView.image = image
        } else {
            imageFileNode.setImageURL(fileVM.fileImageThumbURL)
        }
        
        if fileVM.model.statusType == .Failed {
            fileIconNode.buttonState = .ide
            imageFileNode.state = .finish
        }
        

        
        if fileVM.isImage {
            fileNameNode.maximumNumberOfLines = 2
        } else {
            fileNameNode.maximumNumberOfLines = 1
        }
        
        fileNameNode.truncationMode = .byTruncatingMiddle
        
        sizeTextNode.attributedText = fileVM.sizeAttr
        
        if fileVM.cellDirection == .right {
            self.timeLab = ChatUITools.createTimeLab(vm: self.vm, style: .blue)
            editNode = ChatUITools.createContentLabelNode(node: self, vm: vm, pageVM: pageVM, style: contentTimeStyle)
        } else {
            self.timeLab = ChatUITools.createTimeLab(vm: self.vm, style: .gray)
            editNode = ChatUITools.createContentLabelNode(node: self, vm: vm, pageVM: pageVM, style: .gray)
        }
        
    }
    
    var contentTimeStyle: XinhooTimeAndReadView.Style {
        
        if fileVM.cellDirection == .right {
            return .blue
        } else {
            return .gray
        }
        
    }
    
    override func configMessageStatus(status: XinhooTimeAndReadView.Status) {
        
        if fileVM.cellDirection == .left {
            self.timeLab.setStatuImage(.unknown, style: contentTimeStyle)
            self.editNode.setStatus(status: .unknown)
            return
        }
        
        self.timeLab.setStatuImage(status, style: contentTimeStyle)
        self.editNode.setStatus(status: status)
    }
    
    var fileVM: Xinhoo_FileViewModel {
        return self.vm as! Xinhoo_FileViewModel
    }
    
    
    override var cellWidth: CGFloat {
        
        if vm.model.chatTypeEnum != .privateChat && vm.cellDirection == .left {
            return (KScreenWidth - 60 - 40)
        }
        
        return (KScreenWidth - 60)
    }
    
    
    var iconHeight: CGFloat {
        if fileVM.isImage {
            return 74
        } else {
            return 44
        }
    }
    
    override var contentWidth: CGFloat {
        return cellWidth - iconHeight - contentInsets.horizontal
    }
    
    var minContentWidth: CGFloat {
        if fileVM.isImage {
            return 235
        } else {
            return 200
        }
    }
    
    override var contentInsets: UIEdgeInsets {
        
        if vm.model.fileModel?.isImageOrVideo == true {
            
            if vm.cellDirection == .left {
                return UIEdgeInsets(top: 7, left: 15, bottom: 7, right: 11)
            } else {
                return UIEdgeInsets(top: 7, left: 11, bottom: 7, right: 13)
            }
            
        } else {
            
            if vm.cellDirection == .left {
                return UIEdgeInsets(top: 15, left: 15, bottom: 3, right: 11)
            } else {
                return UIEdgeInsets(top: 15, left: 11, bottom: 3, right: 13)
            }
            
        }
        
    }
    
    override var contentNodeLayout: ASLayoutSpec {
        LayoutSpec {
            
            VStackLayout() {
                
                HStackLayout() {
                    
                    if fileVM.isImage {
                        imageFileNode.preferredSize(CGSize(width: iconHeight, height: iconHeight))
                    } else {
                        fileIconNode.preferredSize(CGSize(width: iconHeight, height: iconHeight))
                    }
                    
                    WrapperLayout {
                        
                        VStackLayout(justifyContent: .start) {
                            
                            CenterLayout(centeringOptions: .Y, sizingOptions: .minimumXY) {
                                VStackLayout(spacing: 5) {
                                    
                                    self.fileNameNode.flexShrink(1).flexGrow(1)
                                    
                                    self.sizeTextNode
                                    
                                }
                            }
                            .flexGrow(1)

                            if fileVM.isImage && !fileVM.hasText {
                                self.timeLab
                                    .alignSelf(.end)
                            }
                            
                            
                        }
                    .flexGrow(1)
                        .height(iconHeight)
                        .alignSelf(.center)
                        .padding(.left, 8)
                        
                    }
                    .flexShrink(1)
                    .flexGrow(1)
                    
                }
                .maxWidth(contentWidth)
                .flexShrink(1)
                
                
                if !fileVM.hasText {
                    
                    if !fileVM.isImage {
                        self.timeLab
                    }
                    
                } else {
                    editNode.maxWidth(self.contentWidth)
                        .padding(.top, 26)
                }
                
                
            }
            .minWidth(minContentWidth)
        .background(bgNode)
            
        }
    }
    
    override func didLoad() {
        super.didLoad()
        imageFileNode.view.cornerRadius = 8
        
        fileIconNode.addTarget(self, action: #selector(onClickDownloadButton), forControlEvents: .touchUpInside)
        bgNode.addTarget(self, action: #selector(onClickDownloadButton), forControlEvents: .touchUpInside)
        
        fileIconNode.isUserInteractionEnabled = !pageVM.isMultipleSelelct.value
        view.isUserInteractionEnabled = !pageVM.isMultipleSelelct.value
        
    }
    
    @objc func onClickDownloadButton() {
        
        if self.fileVM.model.statusType == .Pending && self.fileVM.model.fileModel?.fileID.count ?? 0 > 0 {
            
            UploadTool.cancel(uploadId: self.fileVM.model.fileModel?.localFileID ?? "")
            self.pageVM.cellDeleteMessage(message: self.fileVM.model)
            

        } else {
            
            if self.fileVM.model.fileModel?.fileExists == true {
                self.pageVM.cellTapMessage(message: self.fileVM.model, self.getSuperTableViewCell() as! CODBaseChatCell)
                
            } else {
                
                if fileVM.model.fileModel?.downloadStateType == .Downloading {
                    fileVM.model.fileModel?.cancelDownloadFile()
                }
                
                if fileVM.model.fileModel?.fileExists == false {
                    fileVM.model.fileModel?.downloadFile(isCloudDisk: fileVM.model.isCloudDiskMessage)
                }
            }
            
        }
        
        
        
        
        
        
    }
    
    override func bindData() {
        super.bindData()
        
        if fileVM.model.statusType == .Succeed {
            
            fileVM.downloadState.bind(to: self.rx.downloadStateBinder)
                .disposed(by: self.rx.disposeBag)
            
            bindDownloadProgress()
            
        } else {
            bindUploadProgress()
        }
        
        
        
    }
    
    func bindDownloadProgress() {
        fileVM.downloadProgress
            .bind(to: self.rx.downloadProgressBinder)
            .disposed(by: self.rx.disposeBag)
    }
    
    func bindUploadProgress() {
        
        guard let localFileID = self.fileVM.model.fileModel?.localFileID else {
            return
        }
        
        if let uploadPublishRelay = UploadTool.uploadTasksPublishRelay[localFileID] {
            
            uploadPublishRelay
                .bind(to: self.rx.uploadStateBinder)
                .disposed(by: self.rx.disposeBag)
            
            uploadPublishRelay.map { (result) -> Float in
                
                switch result {
                    
                case .progress(progress: let progress):
                    if progress.float < 0.01 {
                        return 0.01
                    } else {
                        return progress.float - 0.01
                    }
                    
                    
                case .success(file: _):
                    return 0.99
                    
                case .fail:
                    return 0
                case .none:
                    return 0.99
                case .cancal:
                    return 0
                }
                
            }
        .debug("uploadPublishRelay", trimOutput: true)
            .bind(to: self.rx.downloadProgressBinder)
            .disposed(by: self.rx.disposeBag)
            

        }
        
        
        
    }
    
}
