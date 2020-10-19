//
//  CODChatFileImageNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/8/3.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport
import SDWebImage

class CODChatFileImageNode: CODImageNode {
    
    enum State {
        case ide
        case downloading
        case cancel
        case finish
    }
    
    var state: State = .finish {
        didSet {
            
            configState()
        }
    }
    
    lazy var progressNode: CODProgressViewNode = {
        
        let node = CODProgressViewNode()
        node.progressView.size = CGSize(width: 44, height: 44)
        return node
        
    }()
    
    var progress: Float = 0 {
        
        didSet {
            progressNode.progressView.showVideoLoadingView(progress: progress, imageNamed: "image_file_download_cancel")
        }
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        LayoutSpec {
            
            OverlayLayout(content: {
                super.layoutSpecThatFits(constrainedSize)
            }) {
                CenterLayout {
                    self.progressNode.preferredSize(CGSize(width: 44, height: 44))
                }
                
            }
            
        }
        
    }
    
    func configState() {
        switch self.state {
        case .ide:
            self.progressNode.progressView.showHaveNotDownload(imageNamed: "image_file_download")
        case .downloading:
            break
        case .finish:
            self.progressNode.progressView.showDownloadFinished()
        default:
            break
        }
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        
        configState()
        
    }
    
}
