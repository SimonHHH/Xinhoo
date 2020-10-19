//
//  DiscoverHeaderView.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/11.
//  Copyright (c) 2020 XinHoo. All rights reserved.
//

import UIKit
import pop
import RxSwift
import RxCocoa

@IBDesignable
class DiscoverHeaderView: UIView {

    // Our custom view from the XIB file
    var view: UIView!
    @IBOutlet weak var loadingView: UIImageView!
    @IBOutlet weak var nickNameLab: UILabel!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headBgView: UIImageView!
    @IBOutlet weak var topShadow: UIImageView!
    @IBOutlet weak var bottomShadow: UIImageView!
    
    var pageVM: CODDiscoverHomePageVM!
    
    
    convenience init(pageVM: CODDiscoverHomePageVM) {
        self.init()
        self.pageVM = pageVM
        
        pageVM.nickName
        .bind(to: self.rx.nickNameBinder)
        .disposed(by: self.rx.disposeBag)
        
        pageVM.headerUrl
        .bind(to: self.rx.headerUrlBinder)
        .disposed(by: self.rx.disposeBag)
        
        DispatchQueue.main.async {
            
            self.setBgImage()
            
        }
        

        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kReloadMomentBackground), object: nil, queue: nil) { [weak self] ( not ) in
            
            guard let `self` = self else { return }
            
            if let jid = not.userInfo?["jid"] as? String,
                let image = not.userInfo?["image"] as? UIImage,
                jid == UserManager.sharedInstance.jid {
                self.setBgImage(image: image)
            }

        }
        

        
    }
    
    func setBgImage(image: UIImage? = nil) {
        
        if let image = image {
            self.headBgView.image = image
        } else {
            
            if let image = CODImageCache.default.downloadImageCache?.imageFromCache(forKey: DiscoverTools.getMomentBackgroundImageKey()) {
                
                self.headBgView.image = image

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

    /**
     Sets up the view by loading it from the xib file and setting its frame
     */
    func setupView() {
        view = loadViewFromXibFile()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)

        headerImageView.addTap {
            
            let vc = CODDiscoverPersonalListVC()
            UIViewController.current()?.navigationController?.pushViewController(vc)
            
        }


    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = self.view.systemLayoutSizeFitting(CGSize(width: kScreenWidth, height: CGFloat.greatestFiniteMagnitude))
        
        size = CGSize(width: size.width / 2, height: size.height / 2)
        
        return size
    }

    /**
     Loads a view instance from the xib file
     - returns: loaded view
     */
    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "DiscoverHeaderView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func showLoading() {
        
        loadingView.isHidden = false
        let anim1 = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
        anim1?.fromValue = 0
        anim1?.toValue = 1
        loadingView.layer.pop_add(anim1, forKey: "Alpha")
        
        
        let anim2 = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
        anim2?.fromValue = 0
        anim2?.toValue = loadingView.center.y
        anim2?.springSpeed = 10
        loadingView.layer.pop_add(anim2, forKey: "PositionY")
        
        let anim3 = POPBasicAnimation(propertyNamed: kPOPLayerRotation)
        anim3?.toValue = Double.pi * 2
        anim3?.repeatForever = true
        anim3?.duration = 1
        anim3?.beginTime = CACurrentMediaTime() + 0.3
        loadingView.layer.pop_add(anim3, forKey: "Rotation")
        
        
    }
    
    func hideLoading() {
        
        loadingView.layer.removeAnimation(forKey: "Alpha")
        loadingView.layer.removeAnimation(forKey: "PositionY")
        loadingView.layer.removeAnimation(forKey: "Alpha")
        loadingView.isHidden = true
        
    }
    
    @IBAction func touchChangeBackground(_ sender: Any) {
        
        CODActionSheet.show(withTitle: "", cancelButtonTitle: NSLocalizedString("取消", comment: ""), destructiveButtonTitle: NSLocalizedString("更换相册封面", comment: ""), otherButtonTitles: [], cancelButtonColor: UIColor(hexString: "#367CDE")!, destructiveButtonColor: UIColor(hexString: "#047EF5")!, otherButtonColors: []) { (sheet, index) in
            
            
            if index == -1 {
                let bgListVC = CODDiscoverChangeBGListVC()
                UIViewController.current()?.navigationController?.pushViewController(bgListVC)
            }
            
            
            
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

}
