//
//  CODMultipleImageNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import TextureSwiftSupport
import SwifterSwift




class CODMultipleImageNode: CODDisplayNode {
    
    weak var vm: ChatCellVM!
    weak var pageVM: CODChatMessageDisplayPageVM!
    
    var contentWidth: CGFloat {
        if vm.model.isCloudDiskMessage || vm.model.chatTypeEnum == .groupChat || vm.model.chatTypeEnum == .channel {
            return (KScreenWidth - 88)
        } else {
            return (KScreenWidth - 70)
        }
    }
    
    

    
    convenience init(vm: Xinhoo_MultipleImageCellVM, pageVM: CODChatMessageDisplayPageVM) {
        self.init()
        self.vm = vm
        self.pageVM = pageVM
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        createLayoutSpec(imageList: vm.messageModel.imageList.toArray())
    }
    
    func createLayoutSpec(imageList: [PhotoModelInfo]) -> ASLayoutSpec {
        var height: CGFloat = 394
        
        if imageList.count <= 3 {
            height = 142
        } else if imageList.count > 3 && imageList.count <= 6 {
            height = 263
        }
        
        return LayoutSpec {
            
            VStackLayout(spacing: 2) {
                createStackLayout(imageList, height: height)
            }
            
        }
    }
    
    fileprivate func slipImageLists(_ imageList: [PhotoModelInfo]) -> [[PhotoModelInfo]] {
        
        var baseNum = 3
        
        switch imageList.count {
        case 4, 7:
            baseNum = 2
        default:
            break
        }
        
        return slipImageLists(imageList: imageList, imageLists: [], baseNum: baseNum, maxNum: 3)
        
    }
    
    func slipImageLists(imageList: [PhotoModelInfo], imageLists: [[PhotoModelInfo]], baseNum: Int, maxNum: Int = 3) -> [[PhotoModelInfo]] {
        
        var imageList = imageList
        var imageLists = imageLists
        
        if imageList.count > baseNum && imageList.count > maxNum {
            
            imageLists.append(Array(imageList.prefix(upTo: baseNum)))
            imageList.removeFirst(baseNum)
            return slipImageLists(imageList: imageList, imageLists: imageLists, baseNum: baseNum, maxNum: maxNum)
            
            
        } else {
            imageLists.append(imageList)
            return imageLists
        }
        
    }
    
    fileprivate func createStackLayout(_ imageList: [PhotoModelInfo], height: CGFloat) -> [ASLayoutSpec] {
        
        
        var imagess: [[CODChatImageNode]] = []
        let imageLists = slipImageLists(imageList)
        var layoutSpecs: [ASLayoutSpec] = []
        
        for imageList in imageLists {
            imagess.append(createImages(imageList: imageList))
        }
        
        
        for images in imagess {
            
            let layoutSpec = LayoutSpec {
                HStackLayout(spacing: 2) {
                    images
                }
                .height(height / CGFloat(imagess.count))
            }
            
            layoutSpecs.append(layoutSpec)
            
        }
        
        return layoutSpecs
        
    }
    
    
    func createImages(imageList: [PhotoModelInfo]) -> [CODChatImageNode] {
        
        var images: [CODChatImageNode] = []
        
        for imageInfo in imageList {
            
            let image: CODChatImageNode!
            
            if CODImageCache.default.smallImageCache?.diskImageDataExists(withKey: imageInfo.photoId) ?? false == false {
                image = CODChatImageNode(url: URL(string: imageInfo.serverImageId.getImageFullPath(imageType: 1, isCloudDisk:  pageVM.isCloudDisk)), placeholderImage: CustomUtil.getPlaceholderImage())
            } else {
                image = CODChatImageNode(cacheKey: imageInfo.photoId)
            }
            
            image.contentMode = .scaleAspectFill
            image.style.width = ASDimensionMake(floor(contentWidth / CGFloat(imageList.count)))
            image.uploadId = imageInfo.photoId
            
            image.closeClosure = { [weak self] _, uploadId in
                
                guard let `self` = self else { return }
                
                self.pageVM.closeImageUpload(cellVm: self.vm, uploadId: uploadId!)
                
                
            }
            
            image.onClickImage = { [weak self] in
                
                guard let `self` = self else { return }
                
                let index = self.vm.messageModel.imageList.firstIndex { (value) -> Bool in
                    return value.photoId == imageInfo.photoId
                }
                
                if let index = index {
                    self.pageVM.onClickImage(cellVM: self.vm, imageIndex: index)
                }
                

            }
            
            image.isUserInteractionEnabled = !pageVM.isMultipleSelelct.value
            
            images.append(image)
        }
        
        return images
        
        
    }
    
    
    
    
    
    
}
