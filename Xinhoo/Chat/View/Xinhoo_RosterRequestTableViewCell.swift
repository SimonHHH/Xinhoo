//
//  Xinhoo_RosterRequestTableViewCell.swift
//  COD
//
//  Created by xinhooo on 2020/3/12.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: Xinhoo_RosterRequestTableViewCell {
    
    var reloadUIBinder: Binder<Int> {
        return Binder(base) { (cell, value) in
            cell.configView()
        }
    }
}

class Xinhoo_RosterRequestTableViewCell: UITableViewCell {
    
    let titleLabLeftCos: CGFloat = 60.0
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var descLab: UILabel!
    @IBOutlet weak var ignoreBtn: UIButton!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var ignoreCos: NSLayoutConstraint!
    @IBOutlet weak var statusCos: NSLayoutConstraint!
    @IBOutlet weak var titleIgnoreCos: NSLayoutConstraint!
    @IBOutlet weak var titleStatusCos: NSLayoutConstraint!
    
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var bottomLineLeftCos: NSLayoutConstraint!
    
    var requestModelVM:RosterRequestVM!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configModel(modelVM:RosterRequestVM, models: Array<RosterRequestVM>, indexPath: IndexPath) {
        
        self.requestModelVM = modelVM
        
        nameLab.text = self.requestModelVM.senderNickName
        descLab.text = self.requestModelVM.desc
        
        CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: self.requestModelVM.senderPic) { (image) in
            self.headImageView.image = image
        }
        
        ignoreCos.priority = .init(floatLiteral: 800)
        statusCos.priority = .init(floatLiteral: 801)
        
        titleIgnoreCos.priority = .init(floatLiteral: 800)
        titleStatusCos.priority = .init(floatLiteral: 801)
        
        requestModelVM?.reloadUI?.bind(to: self.rx.reloadUIBinder)
            .disposed(by: self.rx.prepareForReuseBag)
        
        if indexPath.row == 0 {
            self.topLine.isHidden = false
        }else{
            self.topLine.isHidden = true
        }
        
        if indexPath.row == models.count-1 {
            self.bottomLineLeftCos.constant = 0.0
        }else{
            self.bottomLineLeftCos.constant = titleLabLeftCos
        }
    }
    
    func configView() {
        switch requestModelVM?.type {
        case .normal:
        
            self.ignoreBtn.isHidden = false
            self.statusBtn.isUserInteractionEnabled = true
            
            ignoreCos.priority = .init(floatLiteral: 801)
            statusCos.priority = .init(floatLiteral: 800)
            
            titleIgnoreCos.priority = .init(floatLiteral: 801)
            titleStatusCos.priority = .init(floatLiteral: 800)
            
            self.configStatusBtn(title: NSLocalizedString("通过", comment: ""), backgroundColor: UIColor(hexString: "047EF5"), titleColor: UIColor(hexString: "FFFFFF"))
            self.ignoreBtn.setTitle(NSLocalizedString("忽略", comment: ""), for: .normal)
            
            break
        case .friend:
            
            self.ignoreBtn.isHidden = true
            self.statusBtn.isUserInteractionEnabled = false
            self.configStatusBtn(title: NSLocalizedString("已添加", comment: ""))
            break
        case .ignore:
            self.ignoreBtn.isHidden = true
            self.statusBtn.isUserInteractionEnabled = false
            self.configStatusBtn(title: NSLocalizedString("已忽略", comment: ""))
            break
        case .deadline:
            self.ignoreBtn.isHidden = true
            self.statusBtn.isUserInteractionEnabled = false
            self.configStatusBtn(title: NSLocalizedString("已过期", comment: ""))
            break
            
        default:
            break
        }
    }
    
    func configStatusBtn(title:String,backgroundColor:UIColor? = UIColor(hexString: kVCBgColorS)?.withAlphaComponent(0),titleColor:UIColor? = UIColor(hexString: kWeakTitleColorS)) {
        self.statusBtn.setTitle(NSLocalizedString(title, comment: ""), for: .normal)
        self.statusBtn.backgroundColor = backgroundColor
        self.statusBtn.setTitleColor(titleColor, for: .normal)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func statusAction(_ sender: Any) {
        requestModelVM.updateStatus(status: 1)
    }
    
    @IBAction func ignoreAction(_ sender: Any) {
        requestModelVM.updateStatus(status: 2)
    }
}
