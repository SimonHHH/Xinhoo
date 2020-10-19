//
//  CODEmojiBaseCell.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODEmojiBaseCell: UICollectionViewCell {
    
    var emojiItem: CODExpressionModel?{
        didSet{
            self.updateEmojiItem()
        }
    }
    var highlightImage:UIImage?
    var showHighlightImage:Bool = false {
        didSet{
            updateHighlight()
        }
    }
    lazy var bgView:UIImageView = {
        let bgView = UIImageView(frame:.zero)
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 5
        return bgView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.bgView)
        self.bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func updateEmojiItem(){
        
    }
    /// 更新
    fileprivate func updateHighlight(){
        if self.showHighlightImage {
            self.bgView.image = highlightImage
        }else{
            self.bgView.image = nil
        }
    }
    
}
