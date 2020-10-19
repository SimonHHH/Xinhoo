//
//  CODPictrueSelectView.swift
//  COD
//
//  Created by 1 on 2019/3/25.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

public let HWSCALE:CGFloat = 16.0/9.0
class CODPictrueSelectView: UIView{
    
    typealias SelectPhotoAssetBlock = (CODPhotoAsset) -> Void
    typealias PushPhotoBlock = () -> Void
    var tzImagePickerVc: TZImagePickerController?
    var operationQueue: OperationQueue?

    public var selectPhotoAssetBlock:SelectPhotoAssetBlock? = nil
    public var pushPhotoBlock:PushPhotoBlock? = nil
    
    public var photos:[TZAssetModel] = [TZAssetModel](){
        didSet{
            self.collectionView.reloadData()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()

        self.operationQueue = OperationQueue.init()
        self.operationQueue?.maxConcurrentOperationCount = 3
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    // 当前默认显示选显示的
    
    // 传入的数据源
    var collectionSource:Array<String> = []{
        didSet{
            self.collectionView.reloadData()
        }
    }
    private  lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.minimumLineSpacing = 5
        return flowLayout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(TZAssetCell.self, forCellWithReuseIdentifier: "TZAssetCell")
        collectionView.register(CODPictrueSelectCell.self, forCellWithReuseIdentifier: "CODPictrueSelectCellID")

        return collectionView
    }()
    
}

extension CODPictrueSelectView : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if indexPath.section == 0 {
//            return CGSize(width: 92, height: 92 * HWSCALE)
//        }else{
//            let model = self.photos[indexPath.row]
//            ///计算宽度
//            let scale:CGFloat = CGFloat(model.asset.pixelHeight) / CGFloat(model.asset.pixelWidth)
//            var width = (92 * HWSCALE)/scale
//            if scale > 4{///特别高的图片
//                width = (92 * HWSCALE)/3
//            }
//            if scale < 0.5{///特别宽的图片
//                width = (92 * HWSCALE)/0.5
//            }
//            return CGSize(width:width, height: 92 * HWSCALE)
//        }
        return CGSize(width:92, height: 84)
    }
}

extension CODPictrueSelectView : UICollectionViewDataSource,UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return self.photos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell:CODPictrueSelectCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CODPictrueSelectCellID", for: indexPath) as! CODPictrueSelectCell
                cell.imageString = "camera_icon"
            return cell
        }else{
            let cell:TZAssetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TZAssetCell", for: indexPath) as! TZAssetCell
            cell.allowPickingMultipleVideo = true
            cell.allowPickingGif = true
            cell.allowPreview = false
            let model = self.photos[indexPath.item]
            cell.model = model
            cell.allowPickingMultipleVideo = self.tzImagePickerVc?.allowPickingMultipleVideo ?? true
            cell.photoDefImage = self.tzImagePickerVc?.photoDefImage
            cell.photoSelImage = self.tzImagePickerVc?.photoSelImage
            cell.assetCellDidSetModelBlock = self.tzImagePickerVc?.assetCellDidSetModelBlock
            cell.assetCellDidLayoutSubviewsBlock = self.tzImagePickerVc?.assetCellDidLayoutSubviewsBlock
            cell.showSelectBtn = false
            cell.allowPreview = false
            cell.didSelectPhotoBlock = { [unowned self] (_ isSelected:Bool) in
                self.cellSelet(model: model)
            }

            return cell
        }
   

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            
//            let model = self.photos[indexPath.row]
//            self.cellSelet(model: model)
        }else{
            ///进入拍照
            if self.pushPhotoBlock != nil{
                self.pushPhotoBlock!()
            }
        }
        
    }
    
    func cellSelet(model: TZAssetModel) {
        let operation = TZImageRequestOperation.init(asset: model.asset, completion: { [weak self](photo, info, _) in
            
            if photo != nil {
                var scaleImage = photo
                if !(TZImagePickerConfig.sharedInstance()?.notScaleImage ?? true) {
                    scaleImage = TZImageManager.default()?.scale(photo, to: CGSize(width: self?.tzImagePickerVc?.photoWidth ?? 0, height: ((self?.tzImagePickerVc?.photoWidth ?? 0) * photo.size.height / photo.size.width))) ?? photo
                }
                self?.callDelegateMethodWithPhotos(photo: scaleImage, assets: model.asset, info: info)
                
            }
        }) { (progress, error, stop, info) in
//            print("\(error.localizedDescription)")
            
        }
        self.operationQueue?.addOperation(operation)
    }
    
    func callDelegateMethodWithPhotos(photo: UIImage,assets: PHAsset,info:[AnyHashable:Any]) {
        if TZImageManager.default()?.isVideo(assets) ?? false {
            
            if self.tzImagePickerVc?.pickerDelegate != nil {
                tzImagePickerVc?.pickerDelegate.imagePickerController?(self.tzImagePickerVc, didFinishPickingVideo: photo, sourceAssets: assets)
            }
        }else{
            tzImagePickerVc?.pickerDelegate.imagePickerController?(self.tzImagePickerVc, didFinishPickingPhotos: [photo], sourceAssets: [assets], isSelectOriginalPhoto: false)
        }
    }
    
}


