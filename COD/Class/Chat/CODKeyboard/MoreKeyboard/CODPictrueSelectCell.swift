//
//  CODPictrueSelectCell.swift
//  COD
//
//  Created by 1 on 2019/3/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Photos

class CODPictrueSelectCell: UICollectionViewCell {
    var representedAssetIdentifier : String!
    var requestID:PHImageRequestID? = nil
    
    lazy var options:PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        return options
    }()
    
    public var photoAsset:CODPhotoAsset? = nil{
        didSet{
            self.updataImageView()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    public var imageString: String? {
        didSet {
            imgView.image = UIImage.init(named: imageString ?? "")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        return imgView
    }()
    
    func setupUI() {
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.height.equalTo(84)
            make.width.equalTo(92)
        }
    }
    func updataImageView() {
        
//        PHCachingImageManager.default().requestImageData(for: self.photoAsset!.asset, options: self.options) { (imageData, dataUTI, orientation, info) in
//            self.imgView.image = UIImage.init(data: imageData ?? Data())
//        }
        self.representedAssetIdentifier = self.photoAsset!.asset.localIdentifier
//        let  thumbnailSize = CGSize(width: self.bounds.size.width*3, height:self.bounds.size.height*3)
        self.requestID = PHCachingImageManager.default().requestImage(for: self.photoAsset!.asset,
                                                                      targetSize: PHImageManagerMaximumSize,
                                                                      contentMode: .default,
                                                                      options: self.options)
        { [unowned self] (image, nil) in
            DispatchQueue.main.async {
                if self.representedAssetIdentifier == self.photoAsset!.asset.localIdentifier{
                    self.imgView.image = image
                    self.photoAsset?.photoImage = image
                }else{
                    if self.requestID != nil{
                        PHCachingImageManager.default().cancelImageRequest(self.requestID!)
                    }
                }
            }
        }
    }
    
}
