//
//  CODCodeAlertView.swift
//  COD
//
//  Created by XinHoo on 10/12/20.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class CODCodeAlertView: UIView {
    
    var errorStr: String! {
        didSet{
            if self.errorStr.count > 0 {
                self.updateCode()
                self.errorLab.text = self.errorStr
                self.errorLab.isHidden = false
            }else{
                self.errorLab.isHidden = true
            }
        }
    }
    
    typealias ConfirmBlock = (_ alertView: CODCodeAlertView, _ codeStr: String?) -> Void
    
    var confirmBlock: ConfirmBlock?
    
    @IBOutlet weak var codeField: UITextField!
        
    @IBOutlet weak var errorLab: UILabel!
    
    @IBOutlet weak var imageBtn: UIButton!
    
    @IBAction func cancel(_ sender: Any) {
        dismiss()
    }
    
    @IBAction func confirm(_ sender: Any) {
        if confirmBlock != nil {
            confirmBlock!(self, codeField.text)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.alpha = 0.0
    }
    
    @IBAction func updateCode(_ sender: Any) {
        self.codeField.clear()
        self.updateCode()
    }
    
    func updateCode() {
        print("updateCode")
                
        let requestUrl = URL(string: HttpConfig.getPicCodeUrl)
        
        SDWebImageDownloader.shared.downloadImage(with: requestUrl, options: [.useNSURLCache, ], context: nil, progress: nil) { (image, data, error, isOk) in
            print(error)
            if let image = image {
                self.imageBtn.setImage(image, for: .normal)
            }
        }
        
        self.codeField.becomeFirstResponder()
        
    }
    
    lazy var backgroundView: ChatMoreOptionsBackgroundView = {
        let bg = ChatMoreOptionsBackgroundView(frame: UIScreen.main.bounds)
        bg.backgroundColor = UIColor(hexString: "000000", transparency: 0.41)
        bg.isUserInteractionEnabled = false
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(dismiss))
        bg.addGestureRecognizer(tap)
        return bg
    }()
    
    func vShow() {
        self.errorStr = ""
        self.updateCode()
        self.show()
    }
    
    func show() {
        let window = UIApplication.shared.keyWindow
        window?.addSubview(backgroundView)
        window?.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
        }
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }
    
    
    func vDismiss() {
        self.dismiss()
        self.codeField.clear()
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }) { (bool) in
            self.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
        }
    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
