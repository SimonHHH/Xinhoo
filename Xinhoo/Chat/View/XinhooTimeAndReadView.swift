//
//  XinhooTimeAndReadView.swift
//  COD
//
//  Created by Sim Tsai on 2019/12/24.
//  Copyright (c) 2019 XinHoo. All rights reserved.
//

import UIKit
import UIView_FDCollapsibleConstraints

extension XinhooTimeAndReadView.Status {
    var image: UIImage? {
        switch self {
        case .unknown:
            return nil
        case .sendSuccessful:
            return UIImage(named: "readInfo_blue")
        case .haveRead:
            return UIImage(named: "readInfo_blue_Haveread")
        case .sending:
            return UIImage(named: "readInfo_blue_time")
        }
    }
}

@IBDesignable
class XinhooTimeAndReadView: UIView {
    
    enum Status {
        case unknown
        case sending
        case sendSuccessful
        case haveRead
    }
    
    enum ViewType: String {
        case text
        case other
    }
    
    enum Style {

        case white
        case blue
        case gray

    }
    
    @IBInspectable var viewType: String? {
        didSet {
            if viewType == ViewType.text.rawValue {
                self.bottomConst.constant = -6.5
            } else {
                self.bottomConst.constant = 0
            }
        }
    }
    // Our custom view from the XIB file
    var view: UIView!
    @IBOutlet weak var timeLab: UILabel!
    @IBOutlet weak var statuImageView: UIImageView!
    @IBOutlet weak var nikeNameLab: UILabel!
    @IBOutlet weak var bottomConst: NSLayoutConstraint!

    /**
     Initialiser method
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    /**
     Initialiser method
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    /**
     Sets up the view by loading it from the xib file and setting its frame
     */
    func setupView() {
        view = loadViewFromXibFile()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

    /**
     Loads a view instance from the xib file
     - returns: loaded view
     */
    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "XinhooTimeAndReadView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        
        
        return view
    }
    
    func configMessageModel(_ messageModel: CODMessageModel, style: XinhooTimeAndReadView.Style = .white) {
        
        var nikeName: NSMutableAttributedString? = nil
        
        let timeStr = TimeTool.getTimeString(Date.init(timeIntervalSince1970:(Double((messageModel.datetime.int == nil ? "\(Date.milliseconds)":messageModel.datetime)))!/1000), format: XinhooTool.is12Hour ? "h:mm a" : "h:mm")
        
        let time = NSMutableAttributedString(string: timeStr)
        
        if messageModel.edited > 0 {
            time.yy_insertString(NSLocalizedString("已编辑", comment: "") + "  ", at: 0)
        }
        
        
        time.yy_font = FONTTime

        if style == .blue {
            time.yy_color = UIColor(hexString: "#1F9B00")
        } else if style == .gray {
            time.yy_color = UIColor(hexString: "#999999")
        } else {
            time.yy_color = .white
        }
        
        if messageModel.chatTypeEnum == .channel {
            
            let name = messageModel.n
            
            if name.count > 0 {
                nikeName = NSMutableAttributedString(string: name)
            }
            
            nikeName?.yy_font = time.yy_font
            nikeName?.yy_color = time.yy_color
            
        }
        
        let messageStatus: CODMessageStatus = messageModel.statusType
        var status: XinhooTimeAndReadView.Status = .sending
        if messageStatus == .Succeed && messageModel.isReaded {
            status = .haveRead
        } else if messageStatus == .Succeed && !messageModel.isReaded {
            status = .sendSuccessful
        } else if messageStatus == .Pending {
            status = .sending
        }else{
            status = .unknown
        }
        
        self.set(nikename: nikeName, time: time, status: status, style: style)
        
    }
    
    func statusImage(_ status: XinhooTimeAndReadView.Status, style: XinhooTimeAndReadView.Style = .white) -> UIImage? {
        
        if style == .white {
            switch status {
            case .haveRead:
                return UIImage(named: "readInfo_white_isread")
            case .sendSuccessful:
                return UIImage(named: "readInfo_white")
            case .sending:
                return UIImage(named: "readInfo_white_time")
            case .unknown:
                return nil
            }
            
        } else {
            switch status {
            case .unknown:
                return nil
            case .sendSuccessful:
                return UIImage(named: "readInfo_blue")
            case .haveRead:
                return UIImage(named: "readInfo_blue_Haveread")
            case .sending:
                return UIImage(named: "readInfo_blue_time")
            }
        }
        
        
        
    }
    
    func setStatuImage(_ status: XinhooTimeAndReadView.Status, style: XinhooTimeAndReadView.Style = .white) {
        
        statuImageView.fd_collapsed = false
        
        statuImageView.image = statusImage(status, style: style)
        if status == .unknown {
            statuImageView.fd_collapsed = true
        }
        

    }
    

    func set(nikename: NSMutableAttributedString?, time: NSMutableAttributedString, status: XinhooTimeAndReadView.Status, style: XinhooTimeAndReadView.Style = .blue) {
        
        if let nikename = nikename {
            self.nikeNameLab.attributedText = nikename
            time.yy_insertString(", ", at: 0)
        } else {
            self.nikeNameLab.attributedText = NSMutableAttributedString(string: "")
        }
        
        self.timeLab.attributedText = time

        setStatuImage(status, style: style)
        
        
    }
}
