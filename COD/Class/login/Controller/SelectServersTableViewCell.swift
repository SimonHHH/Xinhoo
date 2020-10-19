//
//  SelectServersTableViewCell.swift
//  COD
//
//  Created by xinhooo on 2020/5/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: SelectServersTableViewCell  {
    
    var pingBinder: Binder<String?> {
        return Binder(base) { (cell, ping) in
            
            cell.reloadPing(ping: ping)
            
        }
    }
    
}

class SelectServersTableViewCell: UITableViewCell {

    
    @IBOutlet weak var selectImgView: UIImageView!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var levelImgView: UIImageView!
    
    var serverInfo: ServerInfo? = nil
    
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
