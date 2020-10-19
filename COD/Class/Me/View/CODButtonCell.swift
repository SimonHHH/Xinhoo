//
//  CODButtonCell.swift
//  COD
//
//  Created by XinHoo on 2019/3/12.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODButtonCell: UITableViewCell {
    
    typealias BtnClickCloser = (_ sender : UIButton) -> ()
    var btnClickCloser : BtnClickCloser!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        self.addSubview(button)
        
        button.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(44)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var button: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.backgroundColor = UIColor(hexString: kSubmitBtnBgColorS)
        btn.layer.cornerRadius = kCornerRadius
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(self.btnClick(_:)), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    @objc func btnClick(_ sender :UIButton) {
        btnClickCloser(sender)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
