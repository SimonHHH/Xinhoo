//
//  SecurityCodeView.swift
//  COD
//
//  Created by xinhooo on 2019/5/24.
//  Copyright © 2019 XinHoo. All rights reserved.
//

#warning("此视图宽度为214，并且不可修改")

import UIKit

typealias textBlock = (String?) -> ()
class SecurityCodeView: UIView {

    @IBOutlet weak var codeTF: ZZS_TextField!
    
    @IBOutlet weak var aLab: UIView!
    @IBOutlet weak var bLab: UIView!
    @IBOutlet weak var cLab: UIView!
    @IBOutlet weak var dLab: UIView!
    @IBOutlet weak var eLab: UIView!
    @IBOutlet weak var fLab: UIView!

    var inputTextCompeleteBlock : textBlock?
    var deleteTextBlock : textBlock?
    private var _color : UIColor?
    
    var color: UIColor? {
        get {
            return _color
        }
        set {
            _color = newValue
            aLab.backgroundColor = _color
            bLab.backgroundColor = _color
            cLab.backgroundColor = _color
            dLab.backgroundColor = _color
            eLab.backgroundColor = _color
            fLab.backgroundColor = _color
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame = CGRect.init(x: 0, y: 0, width: 214, height: 22)
        self.codeTF.zzsDelegate = self
    }
    
    @IBAction func textChangeAction(_ sender: Any) {
        
        if let text = self.codeTF.text {
            if text.count >= 6{
                if self.inputTextCompeleteBlock != nil {
                    self.inputTextCompeleteBlock!(text)
                }
            }
            
//            if text.count == 0{
//                if self.deleteTextBlock != nil {
//                    self.deleteTextBlock!(text)
//                }
//            }
        }

    }
    
    func clearInputText() {
        self.codeTF.text = ""
        for i in [6,5,4,3,2,1] {
            self.viewAnimation(count: i, text: "")
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

extension SecurityCodeView:UITextFieldDelegate,ZZS_TextFieldDelegate{
   
    func delete(text: String?) {
        if text?.count == 0{
            if self.deleteTextBlock != nil {
                self.deleteTextBlock!(text)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text!.count >= 6 && string != ""{
            return false
        }else{
            
            if string == "" && textField.text?.count == 0{
                return true
            }
            
            self.viewAnimation(count: textField.text!.count, text: string)
            return true
        }
    }
    
    func viewAnimation(count:Int,text:String) {
        
        
        let animationSize = POPSpringAnimation.init(propertyNamed: kPOPLayerSize)
        animationSize?.springSpeed = 8
        animationSize?.springBounciness = 8
        let animationCorner = POPSpringAnimation.init(propertyNamed: kPOPLayerCornerRadius)
        animationCorner?.springSpeed = 8
        animationCorner?.springBounciness = 8
        if text == "" {
            animationSize?.fromValue = NSValue.init(cgSize: CGSize.init(width: 18, height: 18))
            animationSize?.toValue = NSValue.init(cgSize: CGSize.init(width: 18, height: 3))
            animationCorner?.toValue = NSNumber.init(value: 0)
        }else{
            animationSize?.fromValue = NSValue.init(cgSize: CGSize.init(width: 18, height: 3))
            animationSize?.toValue = NSValue.init(cgSize: CGSize.init(width: 18, height: 18))
            animationCorner?.toValue = NSNumber.init(value: 9)
        }
        
        let text_count = (text == "") ? count - 1 : count
        
        
        switch text_count {
        case 0:
            self.aLab.layer.pop_add(animationSize, forKey: "size")
            self.aLab.pop_add(animationCorner, forKey: "corner")
            break
        case 1:
            self.bLab.layer.pop_add(animationSize, forKey: "size")
            self.bLab.pop_add(animationCorner, forKey: "corner")
            break
        case 2:
            self.cLab.layer.pop_add(animationSize, forKey: "size")
            self.cLab.pop_add(animationCorner, forKey: "corner")
            break
        case 3:
            self.dLab.layer.pop_add(animationSize, forKey: "size")
            self.dLab.pop_add(animationCorner, forKey: "corner")
            break
        case 4:
            self.eLab.layer.pop_add(animationSize, forKey: "size")
            self.eLab.pop_add(animationCorner, forKey: "corner")
            break
        case 5:
            self.fLab.layer.pop_add(animationSize, forKey: "size")
            self.fLab.pop_add(animationCorner, forKey: "corner")
            break
        default:
            break
        }
    }
}

protocol ZZS_TextFieldDelegate:class{
    
    func delete(text:String?)

}

class ZZS_TextField : UITextField {
    
    weak var zzsDelegate:ZZS_TextFieldDelegate?
    
    /// 监控当没有输入任何字符时，点击键盘删除按钮的动作
    override func deleteBackward() {
        super.deleteBackward()
        if self.zzsDelegate != nil {
            self.zzsDelegate?.delete(text: self.text)
        }
    }
}
