//
//  CODPhotoPickerManger.swift
//  COD
//
//  Created by 1 on 2019/3/27.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Photos

//图片请求
class CODPhotoPickerManger: NSObject {
    typealias getPhotoAssetMaxImage = (_ image:UIImage) -> Void
    static let shared:CODPhotoPickerManger = CODPhotoPickerManger()
    /// 图片请求项的配置
    private let options = PHImageRequestOptions()
    /// 相册请求项
    private let photosOptions = PHFetchOptions()
    /// 所有展示的多媒体数据集合
    private var phAssets : PHFetchResult<PHAsset>!
    /// 图片列表的数据模型
    private var models : [CODPhotoAsset]! = [CODPhotoAsset]()
    typealias AllPhotoBlock = (_ models:[CODPhotoAsset]) -> Void
    ///选择全部的图片回调
    public var allPhotoBlock:AllPhotoBlock?
    private override init() {
        super.init()
        ///监听相册变化
        PHPhotoLibrary.shared().register(self)
    }
    override func copy() -> Any {
        return self
    }
    override func mutableCopy() -> Any {
        return self
    }
    
    //  MARK:- 获取全部图片
    public func getAllPhotos(){
        ///权限判断
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if (authStatus == .restricted || authStatus == .denied){
            ///没有权限
            ///请求权限
            PHPhotoLibrary.requestAuthorization { (status) in
                if(authStatus != .restricted && authStatus != .denied){
                    self.takePhoto()
                }
            }
        }else{
            takePhoto()
        }
    }
    deinit {
        ///移除
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    private  func takePhoto(){
        self.options.isSynchronous = true
        self.options.resizeMode = .none
        ///这是图片
        self.photosOptions.predicate = NSPredicate.init(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        ///// 列表是否按创建时间升序排列
        self.photosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending:false)]
        self.phAssets = PHAsset.fetchAssets(with: photosOptions)
        
        self.fetchPhotoModels(photos: self.phAssets)
    }
    
    private func fetchPhotoModels(photos:PHFetchResult<PHAsset>){
        self.models.removeAll()
        photos.enumerateObjects {[weak self] (asset, index, ff) in
            let model = CODPhotoAsset.init(asset: asset)
            model.index = index
            self?.models.append(model)
            if(index == photos.count - 1){
                ///回调
                if(self!.allPhotoBlock != nil){
                    self!.allPhotoBlock!(self!.models!)
                }
            }
        }
    }
    
    ///获取完整的大图
    class func getAssetMaxImageData(assest:PHAsset,block:@escaping getPhotoAssetMaxImage){
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        PHImageManager.default().requestImage(for: assest, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: options) { (image, info) in
            DispatchQueue.main.async {
                if image != nil{
                    block(image!)
                }
            }
        }
    }
    
}
extension CODPhotoPickerManger:PHPhotoLibraryChangeObserver{
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.takePhoto()
        }
    }
    
}
