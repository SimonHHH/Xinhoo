//
//  CODLocationBottomView.swift
//  COD
//
//  Created by 1 on 2019/4/15.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODLocationBottomView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)        
    
        self.setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var locationBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage.init(named: "message_location"), for: .normal)
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let nameLabel = UILabel(frame: CGRect.zero)
        nameLabel.textColor = UIColor.black
        nameLabel.font = UIFont.systemFont(ofSize: 20)
        nameLabel.textAlignment = .left
        nameLabel.text = "xxx"
        return nameLabel
    }()
    
    lazy var subTitleLabel: UILabel = {
        let nameLabel = UILabel(frame: CGRect.zero)
        nameLabel.textColor = UIColor.init(hexString: kEmptyTitleColorS)
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.textAlignment = .left
        nameLabel.text = "xxx"
        return nameLabel
    }()
    
    func setUpView() {
        let imageView = UIImageView()
        let originalImage = UIImage.imageFromColor(color: UIColor.white, viewSize: CGSize(width: KScreenWidth, height: 80))
        //获取原始图片
        let inputImage =  CIImage(image: originalImage)
        //使用高斯模糊滤镜
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(inputImage, forKey:kCIInputImageKey)
        //设置模糊半径值（越大越模糊）
        filter.setValue(300, forKey: kCIInputRadiusKey)
        let outputCIImage = filter.outputImage!
        let rect = CGRect(origin: CGPoint.zero, size: originalImage.size)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(outputCIImage, from: rect)
        //显示生成的模糊图片
        imageView.image = UIImage(cgImage: cgImage!)
        self.addSubview(imageView)
        self.addSubviews([locationBtn,titleLabel,subTitleLabel])
        let gap = 10
        imageView.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(self)
        }
        self.locationBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(-gap)
            make.width.height.equalTo(50)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(gap)
            make.top.equalTo(self).offset(15)
            make.right.equalTo(self.locationBtn.snp.left).offset(-gap)
        }
        
        self.subTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(gap)
            make.bottom.equalTo(self).offset(-15)
            make.right.equalTo(self.locationBtn.snp.left).offset(-gap)
        }
        
     
        
    }
    

}
