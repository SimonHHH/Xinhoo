//
//  CODConnectionServersCell.swift
//  COD
//
//  Created by XinHoo on 6/23/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: CODConnectionServersCell  {
    
    var pingBinder: Binder<String?> {
        return Binder(base) { (cell, ping) in
            
            cell.reloadPing(ping: ping)
            
        }
    }
    
}

class CODConnectionServersCell: UITableViewCell {
    
    @IBOutlet weak var selectImgView: UIImageView!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var levelImgView: UIImageView!
    
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var bottomLineLeftCos: NSLayoutConstraint!
    
    var serverInfo: ServerInfo? = nil
    
    var isTop: Bool = false {
        didSet {
            topLine.isHidden = !isTop
        }
    }
    
    var isLast: Bool = false {
        didSet {
            bottomLineLeftCos.constant = isLast ? 0.0 : 20.0
        }
    }
    
    func reloadPing(ping: String?) {
        
        let text = "\(serverInfo?.serverName ?? "")(\(ping ?? "")ms)" as NSString
        
        var attributeStr = NSMutableAttributedString(string: text as String)
        
        if ping?.isDigits ?? false {
            attributeStr.yy_setColor(UIColor(hexString: "007EE5"), range: text.range(of: "\(ping ?? "")ms"))
        } else {
            attributeStr = NSMutableAttributedString(string: "\(serverInfo?.serverName ?? "")(\(ping ?? ""))")
            attributeStr.yy_setColor(UIColor(hexString: "007EE5"), range: text.range(of: "\(ping ?? "")"))
        }
        
        self.nameLab.attributedText = attributeStr
        
        if let pingInt = ping?.int {
        
            var levelImgName = ""
            
            if pingInt >= 500 {
                
                levelImgName = "ping_red"
                
            }else if (pingInt >= 200) && (pingInt < 500) {
                
                levelImgName = "ping_yellow"
                
            }else{
                
                levelImgName = "ping_green"
                
            }
            
            self.levelImgView.image = UIImage(named: levelImgName)
            
        }else{
            self.levelImgView.image = UIImage(named: "ping_red")
        }
        
        
        
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
