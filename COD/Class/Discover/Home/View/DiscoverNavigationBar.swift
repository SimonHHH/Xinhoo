//
//  DiscoverNavigationBar.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/11.
//  Copyright (c) 2020 XinHoo. All rights reserved.
//

import UIKit

@IBDesignable
class DiscoverNavigationBar: UIView, DiscoverScrollChangedNavigationBarType {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    var view: UIView!
    
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
        view.frame = CGRect(origin: .zero, size: CGSize(width: kScreenWidth, height: self.cod_safeAreaInsets.top + 44 + UIApplication.shared.statusBarFrame.height))
        
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.frame = view.frame
        
        addSubview(view)
        
        self.backBtn.hitScale = 3
        

    }
    
    /**
     Loads a view instance from the xib file
     - returns: loaded view
     */
    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "DiscoverNavigationBar", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    @IBAction func onClickPublic(_ sender: Any) {
        
        let vc = Xinhoo_DiscoverPublishViewController(nibName: "Xinhoo_DiscoverPublishViewController", bundle: Bundle.main)
        let nav = BaseNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        UIViewController.current()?.present(nav, animated: true)
        
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        UIViewController.current()?.navigationController?.popViewController()
    }
    
    func configAlpha(_ alpha: CGFloat) {
        
        var backImage = UIImage(named: "circle_back_white")
        var cameraImage = UIImage(named: "circle_camera_white")
        
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
            cameraImage = UIImage(named: "circle_camera_blue")
            lineView.isHidden = false
        }
        
        
        self.view.backgroundColor = UIColor.interpolationColor(from: .clear, to:UIColor(hexString: kVCBgColorS)!, percent: alpha)
        
        titleLab.textColor = UIColor.interpolationColor(from: .clear, to: .black, percent: alpha)
        
        backBtn.setImage(backImage, for: .normal)
        cameraBtn.setImage(cameraImage, for: .normal)
        
        
    }
    
    
}
