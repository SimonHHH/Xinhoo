//
//  CODDiscoverSendFailView.swift
//  COD
//
//  Created by Sim Tsai on 2020/6/3.
//  Copyright (c) 2020 XinHoo. All rights reserved.
//

import UIKit

@IBDesignable
class CODDiscoverSendFailView: UIView {

    // Our custom view from the XIB file
    var view: UIView!
    @IBOutlet weak var sendBtn: UIButton!
    var momentsId: String
    
    @IBOutlet weak var textLab: UILabel!
    
    let pageType: CODDiscoverDetailVC.PageType
    let failType: CODDiscoverNotificationCellVM.Style.FailType?
    

    init(frame: CGRect, pageType: CODDiscoverDetailVC.PageType, failType: CODDiscoverNotificationCellVM.Style.FailType? = nil) {
        
        self.pageType = pageType
        self.momentsId = pageType.momentsId
        self.failType = failType
        super.init(frame: frame)
        setupView()
        
        
    }

    /**
     Initialiser method
     */
    required init?(coder aDecoder: NSCoder) {
        
        self.pageType = .normal(momentsId: "")
        self.momentsId = pageType.momentsId
        self.failType = .moment
        
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
        
        sendBtn.setBackgroundImage(UIImage(color: UIColor(hexString: "#047EF5")!), for: .normal)
        
        sendBtn.cornerRadius = 4
        
        switch self.failType {
        case .like:
            self.textLab.text = NSLocalizedString("该内容已删除，点赞未发送", comment: "")
            self.sendBtn.isHidden = true
            self.sendBtn.setTitle("", for: .normal)
        case .comment:
            self.textLab.text = NSLocalizedString("该内容已删除，评论未发送", comment: "")
            self.sendBtn.isHidden = true
            self.sendBtn.setTitle("", for: .normal)
        default:
            break
        }


        
    }

    /**
     Loads a view instance from the xib file
     - returns: loaded view
     */
    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CODDiscoverSendFailView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    @IBAction func onClickSendMessage(_ sender: Any) {
        
        if let model = CODDiscoverMessageModel.getModel(id: momentsId) {
            CirclePublishTool.share.publishCircleWithDiscoverMessageModel(model: model)
            UIViewController.current()?.navigationController?.popViewController()
        }
        
    }
}
