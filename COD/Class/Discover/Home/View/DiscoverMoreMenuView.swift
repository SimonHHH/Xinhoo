//
//  DiscoverMoreMenuView.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/14.
//  Copyright (c) 2020 XinHoo. All rights reserved.
//

import UIKit
import PopupKit

@IBDesignable
class DiscoverMoreMenuView: UIView, CODPopupViewType {

    // Our custom view from the XIB file
    var view: UIView!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    
    var clickLike: (() -> Void)? = nil
    var clickComment: (() -> Void)? = nil
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    var isLike = false {
        didSet {
            if self.isLike {
                self.likeBtn.setTitle(NSLocalizedString("取消", comment: ""), for: .normal)
            } else {
                self.likeBtn.setTitle(NSLocalizedString("赞", comment: ""), for: .normal)
            }
        }
    }
    
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        commentBtn.addBorder(toSide: .left, withColor: UIColor(hexString: "#383D3F")!, offset: UIEdgeInsets(horizontal: 0, vertical: 15))
        self.cornerRadius = 5
    }

    /**
     Sets up the view by loading it from the xib file and setting its frame
     */
    func setupView() {
        view = loadViewFromXibFile()
        

        let size = view.systemLayoutSizeFitting(CGSize(width: kScreenWidth, height: CGFloat.greatestFiniteMagnitude))
        view.mj_size = size
        self.mj_size = size
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(view)
    }

    /**
     Loads a view instance from the xib file
     - returns: loaded view
     */
    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "DiscoverMoreMenuView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func show(form view: UIView) {
        
        self.popView = PopupView(contentView: self)
        self.popView.maskType = PopupView.MaskType(rawValue: 0)
        self.popView.dismissType = .bounceOut
        self.popView.shouldDismissOnContentTouch = false

        let viewFrame = view.superview?.convert(view.frame, to: nil) ?? .zero
        
        let point = CGPoint(x: (viewFrame.origin.x - (self.width / 2 ) - 10), y: viewFrame.origin.y  + (view.height / 2))

        self.popView.show(at:point,
                          in: UIApplication.shared.keyWindow!)
        

    }
    
    @IBAction func onClickLike(_ sender: Any) {
        self.clickLike?()
        self.dismiss(animated: true)
    }
    
    
    @IBAction func onClickComment(_ sender: Any) {
        self.clickComment?()
        self.dismiss(animated: true)
    }
    
    
    
    
    
}
