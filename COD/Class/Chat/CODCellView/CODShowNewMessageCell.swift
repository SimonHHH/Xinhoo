//
//  CODShowNewMessageCell.swift
//  COD
//
//  Created by 1 on 2019/5/30.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODShowNewMessageCell: UITableViewCell, TableViewCellDataSourcesType {

    weak var viewModel: ChatCellVM?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    public lazy var txtLabel:ActiveLabel = {
        let textLb = ActiveLabel(frame: CGRect.zero)
        textLb.font = UIFont.systemFont(ofSize: 13)
        textLb.textColor = UIColor.init(hexString: "#898990")
        textLb.text = "以下为新消息"

        textLb.backgroundColor = UIColor.init(white: 1, alpha: 0.9)
//        textLb.layer.borderColor = UIColor.white.cgColor
        textLb.layer.borderColor =  UIColor.init(white: 0, alpha: 0.25).cgColor
        textLb.layer.borderWidth = 0.5

        textLb.textAlignment = .center
        return textLb
    }()
    
    func configCellVM(pageVM: Any?, cellVM: TableViewCellVM, lastCellVM: TableViewCellVM?, nextCellVM: TableViewCellVM?, indexPath: IndexPath) {
        
        guard let vm = cellVM as? ChatCellVM else {
            return
        }
        
        viewModel = vm
        
        //因为tableView是反转的
        if let lastCellVM = lastCellVM as? ChatCellVM {
            viewModel?.nextCellVM = lastCellVM
        }
        
        if let nextCellVM = nextCellVM as? ChatCellVM {
            viewModel?.lastCellVM = nextCellVM
        }
    }
    
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setUpView(){
        
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.txtLabel)
        
        self.backgroundColor = UIColor.clear

        
        self.txtLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).offset(0)
            make.bottom.equalTo(self.contentView).offset(-7)
            make.left.right.equalTo(self.contentView)
            make.height.greaterThanOrEqualTo(24)
        }

        
    }
    
}
