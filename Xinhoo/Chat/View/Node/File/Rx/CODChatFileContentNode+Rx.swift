//
//  CODChatFileContentNode+Rx.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/31.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AsyncDisplayKit


extension Reactive where Base: CODChatFileContentNode {
    
    var downloadStateBinder: Binder<Xinhoo_FileViewModel.DownloadState> {
        return Binder(base) { (node, value) in
            switch value {
            case .ide:
                node.fileIconNode.buttonState = .ide
                node.fileIconNode.setImage(node.fileVM.downloadImage, for: .normal)
                node.imageFileNode.state = .ide
                node.sizeTextNode.attributedText = node.fileVM.sizeAttr
            case .finished:
                node.fileIconNode.buttonState = .ide
                node.fileIconNode.setImage(node.fileVM.iconImage, for: .normal)
                node.imageFileNode.state = .finish
                node.sizeTextNode.attributedText = node.fileVM.sizeAttr
                
            case .loading:
                node.fileIconNode.buttonState = .downloading
                node.imageFileNode.state = .downloading
                node.fileIconNode.setImage(node.fileVM.cancelImage, for: .normal)
            }
        }
    }
    
    var uploadStateBinder: Binder<UploadTool.Result> {
        return Binder(base) { (node, value) in
            switch value {

            case .success(file: _):
                node.fileIconNode.buttonState = .ide
                node.fileIconNode.setImage(node.fileVM.iconImage, for: .normal)
                node.imageFileNode.state = .finish
                node.sizeTextNode.attributedText = node.fileVM.sizeAttr
                
            case .progress(progress: _):
                node.fileIconNode.buttonState = .downloading
                node.imageFileNode.state = .downloading
                node.fileIconNode.setImage(node.fileVM.cancelImage, for: .normal)
                
            default:
                node.fileIconNode.buttonState = .ide
                node.fileIconNode.setImage(node.fileVM.iconImage, for: .normal)
                node.imageFileNode.state = .ide
                node.sizeTextNode.attributedText = node.fileVM.sizeAttr
            }
        }
    }
    
    var uploadProgressBinder: Binder<UploadTool.Result> {
        return Binder(base) { (node, value) in
            
//            node.fileIconNode.progress = value.cgFloat
//            node.imageFileNode.progress = value
            
            switch value {
                
            case .success(file: _):
                node.sizeTextNode.attributedText = node.fileVM.getDowloadSizeAttr(progress: 1)
                node.fileIconNode.progress = 0.99
                node.imageFileNode.progress = 0.99
            case .progress(progress: let progress):
                node.sizeTextNode.attributedText = node.fileVM.getDowloadSizeAttr(progress: progress.cgFloat)
                if progress < 0.01 {
                    node.fileIconNode.progress = 0.01
                    node.imageFileNode.progress = 0.01
                } else {
                    node.fileIconNode.progress = progress.cgFloat - 0.01
                    node.imageFileNode.progress = progress.float - 0.01
                }
                
            case .fail, .cancal:
                node.sizeTextNode.attributedText = node.fileVM.getDowloadSizeAttr(progress: 0)
            case .none:
                break
                
            }
            
            

        }
    }
    
    var downloadProgressBinder: Binder<Float> {
        return Binder(base) { (node, value) in
            
            node.fileIconNode.progress = value.cgFloat
            node.imageFileNode.progress = value
            
            if node.fileVM.model.fileModel?.downloadStateType == .Downloading {
                node.sizeTextNode.attributedText = node.fileVM.getDowloadSizeAttr(progress: value.cgFloat)
            }
            
        }
    }
    
    var statusBinder: Binder<CODMessageStatus> {
        
        return Binder(base) { (node, value) in
            if value  == .Failed {
                node.setNeedsLayout()
                node.fileIconNode.buttonState = .ide
                node.imageFileNode.state = .finish
            }
        }
        
    }
    
}
