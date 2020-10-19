//
//  CODLoginedDeviceTableViewCell.swift
//  COD
//
//  Created by 黄玺 on 2020/2/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODLoginedDeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLab: UILabel!
    
    @IBOutlet weak var subTitleLab: UILabel!
    
    @IBOutlet weak var otherLab: UILabel!
    
    @IBOutlet weak var timeWidth: NSLayoutConstraint!
    
    var isTop: Bool = false {
        didSet {
            if isTop {
                topLine.isHidden = false
            }else{
                topLine.isHidden = true
            }
        }
    }
    
    public var isLast: Bool? {
        didSet {
            guard let isLast = isLast else {
                return
            }
            if isLast {
                lineView.snp.remakeConstraints { (make) in
                    make.left.right.bottom.equalToSuperview()
                    make.height.equalTo(0.5)
                }
            }else{
                lineView.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.titleLab)
                    make.right.bottom.equalToSuperview()
                    make.height.equalTo(0.5)
                }
            }
        }
    }
    
    private lazy var lineView: UIView = {
        let linev = UIView.init()
        linev.backgroundColor = UIColor(hexString: kSepLineColorS)
        return linev
    }()
    
    private lazy var topLine: UIView = {
        let linev = UIView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: KScreenWidth, height: 0.5))
        linev.backgroundColor = UIColor(hexString: kSepLineColorS)
        return linev
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
    }
    
    private func setupUI() {
        self.addSubview(topLine)
        self.addSubview(lineView)
    }
    
    private func setupLayout() {
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
