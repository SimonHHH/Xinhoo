//
//  DiscoverNavigationBar.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/11.
//  Copyright (c) 2020 XinHoo. All rights reserved.
//

import UIKit

@IBDesignable
class CODDiscoverPersonalListNavigationBar: UIView {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var yearLab: UILabel!
    
    let jid: String
    
    var view: UIView!
    
    init(jid: String = UserManager.sharedInstance.jid) {
        self.jid = jid
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    /**
     Initialiser method
     */
    override init(frame: CGRect) {
        self.jid = UserManager.sharedInstance.jid
        super.init(frame: frame)
        setupView()
    }
    
    /**
     Initialiser method
     */
    required init?(coder aDecoder: NSCoder) {
        self.jid = UserManager.sharedInstance.jid
        super.init(coder: aDecoder)
        setupView()
    }
    
    /**
     Sets up the view by loading it from the xib file and setting its frame
     */
    func setupView() {
        view = loadViewFromXibFile()
        view.frame = CGRect(origin: .zero, size: CGSize(width: kScreenWidth, height: self.cod_safeAreaInsets.top + 44 + UIApplication.shared.statusBarFrame.height + 25))
        
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.frame = view.frame
        
        addSubview(view)
        
        self.backBtn.hitScale = 3
        self.moreBtn.hitScale = 3
        
        if jid != UserManager.sharedInstance.jid {
            moreBtn.isHidden = true
        }
        

    }
    
    /**
     Loads a view instance from the xib file
     - returns: loaded view
     */
    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CODDiscoverPersonalListNavigationBar", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    @IBAction func onClickMore(_ sender: Any) {
        
//        CODActionSheet
        

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(title: NSLocalizedString("消息列表", comment: ""), style: .default, isEnabled: true) { (action) in
            let newMessagePage = CODDiscoverNewMessageListVC(pageType: .all)
            UIViewController.current()?.navigationController?.pushViewController(newMessagePage)
        }
        

        alert.addAction(title: NSLocalizedString("取消", comment: ""), style: .cancel, isEnabled: true, handler: nil)
        UIViewController.current()?.navigationController?.present(alert, animated: true, completion: nil)
        

    }
    
    @IBAction func onClickBack(_ sender: Any) {
        UIViewController.current()?.navigationController?.popViewController()
    }
    
    func showYear(year: String) {
        
        dateView.isHidden = false
        
        if CustomUtil.getCurrentLanguage() == "en" {
            yearLab.text = "\(year)"
        } else {
            yearLab.text = "\(year)\(NSLocalizedString("年", comment: ""))"
        }
        
        
    }
    
    func hiddenYear() {
        dateView.isHidden = true
    }
    
    func configAlpha(_ alpha: CGFloat) {
        
        var backImage = UIImage(named: "circle_back_white")
        var moreImage = UIImage(named: "discover_personal_more")
        
        var alpha = alpha
        
        if alpha < 0.1 {
            alpha = 0
        }
        
        if alpha > 0.9 {
            alpha = 1
        }
        
        lineView.isHidden = true
        if alpha > 0.5 {
            backImage = UIImage(named: "circle_back_publish")
            moreImage = UIImage(named: "discover_personal_more_bule")
            lineView.isHidden = false
        }
        
        
        self.titleView.backgroundColor = UIColor.interpolationColor(from: .clear, to:UIColor(hexString: "#F7F7F7")!, percent: alpha)
        
        titleLab.textColor = UIColor.interpolationColor(from: .clear, to: .black, percent: alpha)
        
        backBtn.setImage(backImage, for: .normal)
        moreBtn.setImage(moreImage, for: .normal)
        
        
    }
    
    
}
