//
//  CODEmojiGroupCell.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//
import UIKit

class CODEmojiGroupCell: UICollectionViewCell  {
    
    lazy var selectedView:UIView = {
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor.init(hexString: "#E6E7E9")
        return selectedView
    }()
    lazy var groupIconView:UIImageView = {
        let groupIconView = UIImageView(frame: CGRect.zero)
//        groupIconView.contentMode = UIView.ContentMode.scaleAspectFill
        groupIconView.contentMode = .center
        return groupIconView
    }()
    var emojiGroup:CODExpressionGroupModel?{
        didSet{
            if (emojiGroup?.iconPath) != nil {
                self.groupIconView.image = UIImage(named:(emojiGroup?.iconPath)!)
            }
        }
    }
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        let context = UIGraphicsGetCurrentContext()
//        context?.setLineWidth(0.5)
//        context?.setStrokeColor(UIColor(white: 0.5, alpha: 0.3).cgColor)
//        context?.beginPath()
//        context?.move(to: CGPoint(x: self.width - 0.5, y: 5))
//        context?.addLine(to: CGPoint(x: self.width - 0.5, y: self.height - 5))
//        context?.strokePath()
//    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubviews()
        setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setUpSubviews(){
        self.backgroundColor = UIColor.clear
        self.selectedBackgroundView  = self.selectedView ///选中的背景颜色
        self.contentView.addSubview(self.groupIconView)
    }
    fileprivate func setUpLayout(){
        self.groupIconView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
    }
}
