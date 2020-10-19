//
//  CODGirdImageNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/13.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport
import JXPhotoBrowser

class CODDiscoverHomeGirdImageNode: CODDisplayNode, YBImageBrowserDelegate {

    var msgID: String = ""
    lazy var browser:YBImageBrowser = {
        
        let browser = YBImageBrowser()
        browser.dataSourceArray = self.imageList.toYBIBImageData()
        let toolHander = YBIBToolViewHandler()
        toolHander.topView.operationType = .more
        toolHander.fromType = FromCircle_Publish
        browser.toolViewHandlers = [toolHander]
        browser.delegate = self

        return browser
    }()
    
    var imageSize = CGSize(width: 80, height: 80)
    
    var maxColumn = 3
    var maxRow = 3
    
    var imageList: [PhotoModelInfo] = []
    var imageNodes: [String: CODImageNode] = [:]

    var showImageBrowserBlock: ((Bool) -> ())? = nil
    
    convenience init(imageList: [PhotoModelInfo]) {
        self.init()
        
        let count = imageList.count
        
        if count == 1 {
            imageSize = DiscoverConfig.getThumbImageSize(CGSize(width: imageList[0].w.cgFloat, height: imageList[0].h.cgFloat))
        }
        
        if count == 4 {
            
            maxColumn = 2
            maxRow = 2
            
        } else if count <= maxColumn {
            maxRow = 1
        } else {
            maxRow = Int(count / maxRow) + 1
        }
        
        self.imageList = imageList
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        return createLayout()
        
    }
    
    func createLayout() -> ASLayoutSpec {
        
        var hLayouts: [ASLayoutSpec] = []
        
        for index in 0 ..< maxRow {
            hLayouts.append(createRow(row: index))
        }
        
        
        return LayoutSpec {
            VStackLayout(spacing: 5, justifyContent: .start) {
                hLayouts
            }
        }
        
    }
    
    func createRow(row: Int) -> ASLayoutSpec {
        
        let beginIndex = row * maxColumn
        
        var images: [CODImageNode] = []
        
        for index in beginIndex ..< imageList.count {
            
            if index - beginIndex >= maxColumn {
                break
            }
            
            images.append(createImage(row: row, column: index - beginIndex))
            
            
        }
        
        
        return LayoutSpec {
            
            HStackLayout(spacing: 5, justifyContent: .start) {
                images
            }
            
        }
        
    }
    
    func createImage(row: Int, column: Int) -> CODImageNode {
        
        let index = (row * maxColumn) + column
        

        var imageNode: CODGirdImageNode!
        
        if let image = CODImageCache.default.smallImageCache?.imageFromCache(forKey: imageList[index].photoId) {
            imageNode = CODGirdImageNode(image: image)
        } else {
            
            
            var imageSize = ServerUrlTools.ImageSize.small
            
            if imageList.count == 1 {
                imageSize = ServerUrlTools.ImageSize.medium
            }
            
            let imageUrl = ServerUrlTools.getMomentsServerUrl(fileType: .Image(imageList[index].serverImageId, imageSize))

            imageNode = CODGirdImageNode(url: URL(string: imageUrl), placeholderImage: UIImage(color: UIColor(hexString: kVCBgColorS)!))
            
        }

        imageNode.style.preferredSize = imageSize
        imageNode.index = index
        
//        imageNodes[imageList[index].serverImageId] = imageNode

        imageNode.onClickCloser = { [weak self] in
            
            guard let `self` = self else { return }
            
            let browser = JXPhotoBrowser()
            browser.numberOfItems = {
                self.imageList.toYBIBImageData().count
            }
            browser.reloadCellAtIndex = {[weak self] context in
                
                guard let `self` = self else {
                    return
                }
                let imageData = self.imageList.toYBIBImageData()[context.index]
                let url: URL = imageData.imageURL ?? URL.init(fileURLWithPath: imageData.imagePath ?? "")
                
                let browserCell = context.cell as? JXPhotoBrowserImageCell
                browserCell?.index = context.index
                
                browserCell?.longPressedAction = { [weak self] (cell,gap) in
                    
                    self?.saveImage(msgID: self?.msgID ?? "", url: url,imageDate:imageData, imageView: browserCell?.imageView ?? UIImageView(), superView: browser.view)

                }
                var placeholderImage = UIImage()
                if let subnodes = self.subnodes {
                    for node in subnodes {

                        if let imageNode = node as? CODGirdImageNode, imageNode.index == context.index {
                            placeholderImage = imageNode.imageView.image ?? UIImage()
                        }
                    }
                }
                let imageView = browserCell?.imageView ?? UIImageView()
                if context.index == context.currentIndex {
                    
                    imageView.ybib_showLoading()
                    imageView.sd_setImage(with: url, placeholderImage: placeholderImage, options:  [], completed: { (_ image, _, _, _ imageURL) in
                        imageView.ybib_hideLoading()

                        browserCell?.setNeedsLayout()
                    })
                }else{
                    
                    imageView.sd_setImage(with: url, placeholderImage: placeholderImage, options:  [], completed: { (_ image, _, _, _ imageURL) in
                        browserCell?.setNeedsLayout()
                    })
                }
            }
            browser.transitionAnimator = JXPhotoBrowserZoomAnimator(previousView: { [weak self] index -> UIView? in
                
                guard let `self` = self, let subnodes = self.subnodes else { return nil }
                
                for node in subnodes {
                    
                    if let imageNode = node as? CODGirdImageNode, imageNode.index == index {
                        return imageNode.imageView
                    }
                
                }
                
                return nil

            })
          
            // UIPageIndicator样式的页码指示器
            browser.pageIndicator = JXPhotoBrowserDefaultPageIndicator()
            browser.pageIndex = index
            browser.show()
        }
        
        return imageNode
        

    }
    
    func saveImage(msgID:String, url: URL, imageDate:YBIBImageData, imageView: UIImageView, superView: UIView )  {
            
        CustomUtil.showCircleActionSheet(msgID: msgID, superView: superView, imageData: imageDate) {[weak self] (sheetString) in
            guard let `self` = self else {
                return
            }
            CustomUtil.imageVeiwDownLoad(picUrl: url, imageView: imageView, placeholderImage: nil, filePath: "") { (image, _, _, _) in
                if let saveImage: UIImage = image {
                    CODPermissions.authorizePhotoWith { (isAuth) in
                        if isAuth {
                            UIImageWriteToSavedPhotosAlbum(saveImage, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
                        }
                    }
                }else{
                    CODProgressHUD.showErrorWithStatus("保存失败")
                }
            }
        }
    }
    
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        if error != nil {
            ///提示图片保存失败
            CODProgressHUD.showErrorWithStatus("保存失败")
        }else{
            CODProgressHUD.showSuccessWithStatus("已保存到系统相册")

        }
    }
    
    
    func yb_imageBrowser(_ imageBrowser: YBImageBrowser, beginTransitioningWithIsShow isShow: Bool) {
        self.showImageBrowserBlock?(isShow)
    }
    

}
