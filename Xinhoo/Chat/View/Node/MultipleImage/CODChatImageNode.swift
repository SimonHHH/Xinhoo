//
//  CODImageNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport
import SDWebImage
import RxCocoa
import RxSwift
import RxRealm

struct UIViewAssociatedKeys {
    static var _tapClosure: UInt8 = 0
    static var _longTapClosure: UInt8 = 0
}

extension UIView {
    
    
    var tapClosure: (() -> ())? {
        
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys._tapClosure, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        
        get {
            return objc_getAssociatedObject(self, &UIViewAssociatedKeys._tapClosure) as? () -> ()
        }
        
    }
    
    func addTap(_ closure: @escaping () -> ()) {
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickView)))
        self.tapClosure = closure
        
        
    }
    
    @objc func onClickView() {
        
        self.tapClosure?()
        
    }
    
    func addLongTap(time: TimeInterval = 0.5, _ closure: @escaping () -> ()) {
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressView))
        
        longPress.minimumPressDuration = time
        
        self.addGestureRecognizer(longPress)
        
        self.longTapClosure = closure
        
    }
    
    @objc func longPressView() {
        
        self.longTapClosure?()
        
    }
    
    var longTapClosure: (() -> ())? {
        
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys._longTapClosure, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        
        get {
            return objc_getAssociatedObject(self, &UIViewAssociatedKeys._longTapClosure) as? () -> ()
        }
        
        
    }
    
}

extension Reactive where Base: CODChatImageNode {
    
    var progress: Binder<Float> {
        
        return Binder(base) { (node, progress) in
            
            if let photoInfo = PhotoModelInfo.getPhotoInfo(photoId: node.uploadId ?? ""), photoInfo.uploadStateType == .Finished {
                return
            }
            
            
            node.progress = progress
        }
        
    }
    
    var uploadState: Binder<UploadStateType> {
        
        return Binder(base) { (node, value) in
            
            node.setUploadState(value)
            
        }
        
    }
    
}


class CODChatImageNode: CODImageNode {
    
    var progress: Float = 0 {
        didSet {
            self.progressNode.progress = progress
        }
    }
    
    lazy var progressNode: CODProgressViewNode = {
        
        let node = CODProgressViewNode()
        node.style.preferredSize = CGSize(width: 35, height: 35)
        
        return node
        
    }()
    
    var uploadId: String?
    
    var closeClosure: ((CODChatImageNode, String?) -> ())? = nil
    var onClickImage: (() -> ())? = nil
    
    convenience init(url: URL?, placeholderImage: UIImage? = nil) {
        
        self.init()
        
        (self.node.view as! UIImageView).contentMode = .center
        (self.node.view as! UIImageView).sd_setImage(with: url, placeholderImage: placeholderImage, options: []) { [weak self] (image,error, _, _) in
            guard let `self` = self else { return }
            
            if error != nil {
                return
            }
            
            (self.node.view as! UIImageView).contentMode = .scaleAspectFill
            (self.node.view as! UIImageView).image = image
        }
        
    }
    
    override init() {
        super.init()
        
        progressNode.isHidden = true
        progressNode.addTarget(self, action: #selector(onClickClose), forControlEvents: .touchUpInside)
        self.addTarget(self, action: #selector(onClick), forControlEvents: .touchUpInside)
        
    }
    
    @objc func onClick() {
        
        self.onClickImage?()
        
    }
    
    @objc func onClickClose() {
        
        if let uploadId = self.uploadId, let uploadState = PhotoModelInfo.getPhotoInfo(photoId: uploadId)?.uploadStateType, uploadState != .Finished  {
                        
            self.closeClosure?(self, self.uploadId)
            
        }
        
        
        
    }
    
    convenience init(cacheKey: String)  {
        
        self.init()
        (self.node.view as! UIImageView).contentMode = .scaleAspectFill
        (self.node.view as! UIImageView).image = CODImageCache.default.smallImageCache?.imageFromCache(forKey: cacheKey)
        
        
    }
    
    override func layoutDidFinish() {
        
        if let uploadId = uploadId {
            
            if let photoInfo = PhotoModelInfo.getPhotoInfo(photoId: uploadId) {
                
                //                if photoInfo.uploadStateType == .Finished {
                //                    setUploadState(photoInfo.uploadStateType)
                //                }
                
                photoInfo.rx.observe(\.uploadState)
                    .filterNil().debug("uploadState", trimOutput: true)
                    .map { UploadStateType(value: $0) }
                    .startWith(photoInfo.uploadStateType)
                    .bind(to: self.rx.uploadState)
                    .disposed(by: self.rx.disposeBag)
                
                
            }
            
        }
        
        
        
    }
    
    func setUploadState(_ state: UploadStateType) {
        
        switch state {
            
        case .None, .Handling:
            self.progressNode.isHidden = true
            
        case .Finished:
            (self.progressNode.node.view as? CODVideoCancleView)?.showUploadFinishedIconView()
            self.progressNode.isHidden = false
            
        case .Uploading:
            self.progressNode.isHidden = false
            self.bindProgress()
            
        case .Fail:
            self.progressNode.isHidden = false
            self.progress = 0
            
        case .Cancel:
            break
            
        }
        
    }
    
    func bindProgress() {
        
        if let uploadId = uploadId {
            
            if let obseverable = UploadTool.uploadTasksPublishRelay[uploadId], let uploadInfo = UploadTool.uploadFileInfos[uploadId] {
                
                
                switch uploadInfo {
                case .image(imageInfo: let imageInfo):
                    
                    let endObseverable = obseverable.ignoreWhen { (result) -> Bool in
                        switch result {
                        case .success(file: _), .progress(progress: _):
                            return true
                        default:
                            return false
                        }
                    }
                    
                    obseverable.startWith(imageInfo.result)
                        .takeUntil(endObseverable)
                        .map { (result) -> Float in
                            switch result {
                            case .success(file: _):
                                return 1
                            case .progress(progress: let progress):
                                return progress.float
                            default:
                                return 0
                            }
                    }
                    .bind(to: self.rx.progress)
                    .disposed(by: self.rx.disposeBag)
                    
                default:
                    break
                    
                }
                
                
                
                
            }
            
        }
        
        
    }
    
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        LayoutSpec {
            
            OverlayLayout(content: {
                super.layoutSpecThatFits(constrainedSize)
            }) {
                CenterLayout {
                    self.progressNode
                }
                
            }
            
        }
        
    }
    
    
    
    
}




