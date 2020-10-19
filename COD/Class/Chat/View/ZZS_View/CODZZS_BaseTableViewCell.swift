//
//  CODZZS_BaseTableViewCell.swift
//  COD
//
//  Created by xinhooo on 2019/7/31.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODZZS_BaseTableViewCell: MGSwipeTableCell {

    typealias TapBlock = (_ model:CODMessageModel) -> Void
    var tapRpViewBlock:TapBlock?

    var rpContentView:CODZZS_ReplyView
    var fwContentView:CODZZS_ForwardingView
    
    var messageModel = CODMessageModel()
    var nextModel : CODMessageModel?
    var startLocation:CGPoint?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let view = UIView.init(frame: .zero)
        view.backgroundColor = .clear
        self.multipleSelectionBackgroundView = view
        self.selectedBackgroundView = view
        
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        self.rpContentView = Bundle.main.loadNibNamed("CODZZS_ReplyView", owner: nil, options: nil)?.last as! CODZZS_ReplyView
        self.fwContentView = Bundle.main.loadNibNamed("CODZZS_ForwardingView", owner: nil, options: nil)?.last as! CODZZS_ForwardingView
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.rpContentView = Bundle.main.loadNibNamed("CODZZS_ReplyView", owner: nil, options: nil)?.last as! CODZZS_ReplyView
        self.fwContentView = Bundle.main.loadNibNamed("CODZZS_ForwardingView", owner: nil, options: nil)?.last as! CODZZS_ForwardingView
        super.init(coder: aDecoder)
    }
    
    @objc func panAction(pan:UIPanGestureRecognizer) {
        
        let point = pan.location(in: self.contentView)
        
        switch pan.state {
        case .began:
            self.startLocation = point
            break
        case .ended:
            let threshold:CGFloat = 100.0
            let stopLocation = pan.location(in: self.contentView)
            let dx = stopLocation.x - (startLocation?.x ?? 0.0)
            let dy = stopLocation.y - (startLocation?.y ?? 0.0)
            let distance = sqrt(dx*dx + dy*dy)
            if distance > threshold {
                print("OKKKKKKKKK")
            }
            break
        default:
            break
        }
        
    }
    
    @objc func swipeAction(swipe:UISwipeGestureRecognizer) {
        
        let threshold:CGFloat = 100.0
        if swipe.state == .began {
            startLocation = swipe.location(in: self.contentView)
        }else if (swipe.state == .ended){
            let stopLocation = swipe.location(in: self.contentView)
            let dx = stopLocation.x - (startLocation?.x ?? 0.0)
            let dy = stopLocation.y - (startLocation?.y ?? 0.0)
            let distance = sqrt(dx*dx + dy*dy)
            if distance > threshold {
                print("OKKKKKKKKK")
            }
        }
        
        
        
    }

    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    
        return true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func flashingCell() {
        UIView.animate(withDuration: 0.25, animations: {
            self.contentView.backgroundColor = UIColor.init(hexString: "007EE5")?.withAlphaComponent(0.5)
        }) { (finish) in
            
            UIView.animate(withDuration: 0.25, animations: {
                self.contentView.backgroundColor = .clear
            }, completion: { (finish) in
                UIView.animate(withDuration: 0.25, animations: {
                    self.contentView.backgroundColor = UIColor.init(hexString: "007EE5")?.withAlphaComponent(0.5)
                }) { (finish) in
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        self.contentView.backgroundColor = .clear
                    }, completion: { (finish) in
                        
                    })
                }
            })
        }
    }
    
}
