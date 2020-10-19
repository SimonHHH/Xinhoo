//
//  CODInviteGroupCell.swift
//  COD
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODInviteGroupCell: CODBaseChatCell {
    
    fileprivate lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textAlignment = .left
        titleLabel.text = "邀请你加入群组"
        return titleLabel
    }()
    fileprivate lazy var detailLabel: UILabel = {
        let detailLabel = UILabel(frame: CGRect.zero)
        detailLabel.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        detailLabel.font = UIFont.systemFont(ofSize: 14)
        detailLabel.textAlignment = .left
        detailLabel.numberOfLines = 0
        detailLabel.text = "Yvonne邀请你加入“ 金都工 作室”,点击查看详情"
        return detailLabel
    }()
    fileprivate lazy var groupImageView:UIImageView = {
        let groupImageView = UIImageView(frame: .zero)
        groupImageView.contentMode = .scaleAspectFill
        groupImageView.image = UIImage(named: "groupIcon")
        return groupImageView
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(self.bubbleImageView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.detailLabel)
        self.contentView.addSubview(self.groupImageView)
        self.contentView.addSubview(self.readImageView)
        
        self.updateSnapkt()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateSnapkt(){
        if self.fromMe {
            self.bubbleImageView.image = UIImage(named: "SenderImageNodeBorder")?.imageWithTintColor(tintColor: UIColor.white, blendMode: CGBlendMode.overlay)
            self.bubbleImageView.snp.makeConstraints { (make) in
                make.top.equalTo(self.avatarImageView.snp.top).offset(0)
                make.right.equalTo(self.avatarImageView.snp.left).offset(-IMChatBubbleMaginLeft)
                make.width.equalTo(263)
                make.bottom.equalToSuperview()
            }
            self.groupImageView.snp.makeConstraints { (make) in
                make.right.equalTo(self.bubbleImageView.snp.right).offset(-18)
                make.bottom.equalTo(self.bubbleImageView.snp.bottom).offset(-18)
                make.size.equalTo(CGSize(width: 43, height: 40))
            }
            self.titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(self.bubbleImageView.snp.top).offset(15)
                make.left.equalTo(self.bubbleImageView.snp.left).offset(12)
            }
            self.detailLabel.snp.makeConstraints { (make) in
                make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
                make.left.equalTo(self.titleLabel.snp.left).offset(0)
                make.right.equalTo(self.groupImageView.snp.left).offset(-14)
                make.bottom.equalTo(self.bubbleImageView.snp.bottom).offset(-19)
            }
            self.readImageView.snp.makeConstraints { (make) in
                make.top.equalTo(self.groupImageView.snp.bottom).offset(1)
                make.right.equalTo(self.groupImageView.snp.right).offset(0)
                make.size.equalTo(CGSize(width: 17, height: 9))
            }
        }else{
            self.bubbleImageView.image = UIImage(named: "ReceiverImageNodeBorder")
            self.bubbleImageView.snp.makeConstraints { (make) in
                make.top.equalTo(self.avatarImageView.snp.top).offset(0)
                make.left.equalTo(self.avatarImageView.snp.right).offset(IMChatBubbleMaginLeft)
                make.width.equalTo(263)
                make.bottom.equalToSuperview()
                
            }
            self.groupImageView.snp.makeConstraints { (make) in
                make.right.equalTo(self.bubbleImageView.snp.right).offset(-18)
                make.bottom.equalTo(self.bubbleImageView.snp.bottom).offset(-18)
                make.size.equalTo(CGSize(width: 43, height: 40))
            }
            self.titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(self.bubbleImageView.snp.top).offset(15)
                make.left.equalTo(self.bubbleImageView.snp.left).offset(12)
            }
            self.detailLabel.snp.makeConstraints { (make) in
                make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
                make.left.equalTo(self.titleLabel.snp.left).offset(0)
                make.right.equalTo(self.groupImageView.snp.left).offset(-14)
                make.bottom.equalTo(self.bubbleImageView.snp.bottom).offset(-19)
            }
        }
        //拉伸图片区域
        let bubbleImage = bubbleImageView.image?.resizableImage(withCapInsets: UIEdgeInsets(top: (bubbleImageView.image?.size.height ?? 0)/2, left: 20, bottom: (bubbleImageView.image?.size.height ?? 0)/2, right: 20), resizingMode: .stretch)
        self.bubbleImageView.image = bubbleImage;
        self.setNeedsLayout()
    }
    
    
}
