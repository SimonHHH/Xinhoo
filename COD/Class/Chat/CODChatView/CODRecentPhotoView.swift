//
//  CODRecentPhotoView.swift
//  COD
//
//  Created by 周波 on 2/19/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
protocol CODRecentPhotoViewDelegate:NSObjectProtocol
{
    func imageViewClick(image: UIImage,asset: PHAsset)
}
class CODRecentPhotoView: NSObject {
    weak var delegate:CODRecentPhotoViewDelegate?
    
    static let recentPhoto = CODRecentPhotoView()  // 创建单例
    weak var showView : UIView!  // 创建单例
    var photoAsset = PHAsset()
    var originalImage = UIImage()
    var isOriginal = false

    lazy var bgImageView:UIImageView = {
        var bgImageView = UIImageView(frame: CGRect.zero)
        bgImageView.contentMode =  .scaleAspectFit
        bgImageView.backgroundColor = UIColor.clear
        bgImageView.image = UIImage.init(named: "photo-down-list")
        bgImageView.isUserInteractionEnabled = true
        return bgImageView
    }()
    
    lazy var photoImageView:UIImageView = {
        var photoImageView = UIImageView(frame: CGRect.zero)
        photoImageView.contentMode =  .scaleAspectFill
        photoImageView.backgroundColor = UIColor.clear
        photoImageView.isUserInteractionEnabled = true
        photoImageView.layer.cornerRadius = 3
        photoImageView.clipsToBounds = true
        photoImageView.layer.borderColor = UIColor.init(hexString: "#B6B6BB")?.cgColor
        photoImageView.layer.borderWidth = 0.2
        return photoImageView
    }()
    
    public lazy var titleLabel:UILabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 11)
        titleLabel.textColor = UIColor.black
        titleLabel.text = NSLocalizedString("你可能要发送的图片：", comment: "")
        titleLabel.backgroundColor = UIColor.white
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    
   func showRecentPhoto(showView: UIView) {
        self.showView = showView
        titleLabel.text = NSLocalizedString("你可能要发送的图片：", comment: "")
        
        self.checkPermission {[weak self] (isPermission ) in
            if isPermission {
                self?.getScreenShotRecentlyAdded(resultHandler: { (recentImage) in
//                    DispatchQueue.main.async {
//                        self?.photoImageView.image = recentImage
//                        self?.setUpView(showView: showView)
//                    }
                })
            }
        }
        self.perform(#selector(dismissRecentPhoto), with: nil, afterDelay: 10)
    }
    
    @objc func dismissRecentPhoto() {
        if self.bgImageView.superview != nil {
            self.bgImageView.removeSubviews()
            self.bgImageView.removeFromSuperview()
//            self.showView = UIView()
        }
        
    }
    
    @objc func imageViewClick() {
        
        if self.delegate != nil {
            self.delegate?.imageViewClick(image: self.photoImageView.image ?? UIImage(), asset: self.photoAsset)
        }
        self.dismissRecentPhoto()
    }
    
    
    func setUpView(showView: UIView) {
        guard let window = UIApplication.shared.keyWindow else{
           return
        }
        self.bgImageView.isHidden = false
        window.addSubview(self.bgImageView)
        self.bgImageView.snp.makeConstraints { (make) in
            make.width.equalTo(70)
            make.height.equalTo(107)
            make.left.equalTo(showView.snp.left).offset(9)
            make.bottom.equalTo(showView.snp.top).offset(-6)
        }
//        self.bgImageView.frame = CGRect(x: 9, y: showView.origin.y - 111 , width: 68, height: 105)
        
        self.bgImageView.addSubviews([self.photoImageView,self.titleLabel])
      
        self.titleLabel.snp.makeConstraints { [weak self] (make) in
            
            guard let `self` = self else { return }
            
            make.left.equalTo(self.bgImageView.snp.left).offset(4)
            make.right.equalTo(self.bgImageView.snp.right).offset(-5)
            make.height.equalTo(30)
            make.top.equalTo(self.bgImageView.snp.top).offset(2)
        }
        
        self.photoImageView.snp.makeConstraints { [weak self] (make) in
            
            guard let `self` = self else { return }
            
            make.left.equalTo(self.titleLabel)
            make.height.width.equalTo(62)
            make.top.equalTo(self.titleLabel.snp.bottom)
        }
        
        self.bgImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClick)))
    }
    
    func checkPermission(resultHandler: @escaping (Bool) -> Void) {
         let status = PHPhotoLibrary.authorizationStatus()
         switch status {
         case .notDetermined:
             PHPhotoLibrary.requestAuthorization { (status) in
                 if status == .authorized {
//                     resultHandler(true)
                 }
             }
            resultHandler(false)

         case .authorized:
             resultHandler(true)

         default:
             resultHandler(false)
         }

     }


     func getScreenShotRecentlyAdded(resultHandler: @escaping (UIImage?) -> Swift.Void) {

        guard let screenshotCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumRecentlyAdded, options: nil).firstObject else {
            return
        }

        let options = PHFetchOptions()

        options.wantsIncrementalChangeDetails = true
        options.predicate = NSPredicate(format: "creationDate > %@", NSDate().addingTimeInterval(-30))
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        guard let screenshot = PHAsset.fetchAssets(in: screenshotCollection, options: options).firstObject else {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH时mm分ss秒"
        let createString: String = dateFormatter.string(from: screenshot.creationDate ?? Date())
           
        let lastTimeString = UserDefaults.standard.string(forKey: "kRecentTime")
        if lastTimeString == createString {
            return
        }else{
            UserDefaults.standard.set(createString as Any, forKey: "kRecentTime")
        }

        if screenshot.mediaType != .image {
            return
        }
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        self.photoAsset = screenshot
        PHImageManager.default().requestImage(for: screenshot, targetSize: CGSize(width: 1000, height: 1000), contentMode: .aspectFill, options: requestOptions) {[weak self]  (image, info) in
            guard let image = image, let info = info else {
                return
            }
            self?.photoImageView.image = image.fixOrientation()
            if self?.photoImageView.superview == nil {
                self?.setUpView(showView: self?.showView ?? UIView())
            }
        }
     }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
