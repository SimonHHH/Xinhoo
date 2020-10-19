//
//  CODLikerHeaderCell.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODLikerHeaderCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        imageView.cornerRadius = imageView.width / 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.frame = self.contentView.bounds
        imageView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        self.contentView.backgroundColor = UIColor.clear
        
        self.contentView.addSubview(imageView)
        
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
