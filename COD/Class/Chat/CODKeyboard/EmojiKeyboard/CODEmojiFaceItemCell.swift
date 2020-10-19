//
//  CODEmojiFaceItemCell.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODEmojiFaceItemCell: CODEmojiBaseCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    lazy var label: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font  = UIFont.systemFont(ofSize: 28)
        label.textAlignment = .center
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.label)
        setUpLayout()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func  setUpLayout(){
        self.imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        self.label.snp.makeConstraints { (make) in
            make.edges.equalTo(self.imageView)
        }
    }
    override func updateEmojiItem(){
        if emojiItem?.eid == "-1" {///删除按钮
            self.imageView.isHidden = false
            self.label.isHidden = true
            self.imageView.image = UIImage(named:"emojiKB_emoji_delete")
        }else{
            if emojiItem?.type == .CODEmojiTypeFace{
                self.imageView.isHidden = false
                self.label.isHidden = true
                self.imageView.image =  emojiItem?.name == nil ? nil:UIImage(named:(emojiItem?.name)!)
//                self.imageView.image = UIImage(named:"emojiKB_emoji_delete")
            }else{
                self.imageView.isHidden = true
                self.label.isHidden = false
                self.label.text = emojiItem?.name
            }
        }
    }
}

