//
//  CODDiscoverHomeVideoNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/13.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverHomeVideoNode: CODControlNode, YBImageBrowserDelegate {
    
    var msgID: String = ""
    var imageNode: CODImageNode!
    var playNode = ASImageNode(image: UIImage(named: "circle_play"))
    var videoInfo: VideoModelInfo!
    
    lazy var browser:YBImageBrowser = {
        
        let browser = YBImageBrowser()
        let videoData: YBIBVideoData = self.videoInfo.toYBIBVideoData()
        videoData.msgID = self.msgID
        videoData.singleTouchBlock = { (data) in

        }
        browser.dataSourceArray = [videoData]
        let toolHander = YBIBToolViewHandler()
        toolHander.topView.operationType = .more
        toolHander.fromType = FromCircle_Publish
        browser.toolViewHandlers = [toolHander]
        browser.currentPage = 0
        browser.delegate = self
   
        return browser
        
    }()
    
    var showImageBrowserBlock: ((Bool) -> ())? = nil
    
    convenience init(videoInfo: VideoModelInfo) {
        self.init()
        
        self.videoInfo = videoInfo
        
        var imageUrl = URL(string: ServerUrlTools.getMomentsServerUrl(fileType: .Image(videoInfo.firstpicId, .small)))
        
        if CODImageCache.default.smallImageCache?.diskImageDataExists(withKey: videoInfo.videoId) ?? false {
            
            imageUrl = URL(fileURLWithPath: CODImageCache.default.smallImageCache?.cachePath(forKey: videoInfo.videoId) ?? "")
            
        }

        imageNode = CODImageNode(url: imageUrl, placeholderImage: UIImage(color: UIColor(hexString: kVCBgColorS)!))
        
        imageNode.style.preferredSize = DiscoverConfig.resetImgSize(originalSize: CGSize(width: videoInfo.w.cgFloat, height: videoInfo.h.cgFloat), maxImageLenght: 225)

    }
    
    @objc func onClickView() {
        
        self.browser.backgroundColor = UIColor.black
        self.browser.shouldHideStatusBar = false
        self.browser.show(to: UIViewController.current()?.view ?? UIView())
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            
            OverlayLayout(content: {
                imageNode
            }) {
                CenterLayout {
                    playNode
                }
            }
            
        }
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.addTarget(self, action: #selector(onClickView), forControlEvents: .touchUpInside)
    }
    
    func yb_imageBrowser(_ imageBrowser: YBImageBrowser, beginTransitioningWithIsShow isShow: Bool) {
        self.showImageBrowserBlock?(isShow)
    }
    
}
