//
//  CODToast.swift
//  COD
//
//  Created by 1 on 2020/8/28.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODToast: NSObject {
    //显示消息
    class func showToast(message : String?, aLocationView : UIView, aShowTime : TimeInterval) {
        if Thread.current.isMainThread {
            toastLabel = self.currentToastLabel()
            toastLabel?.removeFromSuperview()
            toastBgView = self.currentToastBgView()
            toastBgView?.removeFromSuperview()
            let AppDlgt = UIApplication.shared.delegate as! AppDelegate
            AppDlgt.window?.addSubview(toastBgView!)
            AppDlgt.window?.addSubview(toastLabel!)
            
            var width = self.stringText(aText: message as NSString?, aFont: 14, isHeightFixed: true, fixedValue: 40)
            var height : CGFloat = 0

            if width > (KScreenWidth - 20) {
                width = KScreenWidth - 20
                height = self.stringText(aText: message as NSString?, aFont: 14, isHeightFixed: false, fixedValue: width)

            }else{
                height = 20

            }
            toastBgView?.snp.remakeConstraints({ (make) in
                make.bottom.equalTo(aLocationView.snp.top);
                make.height.equalTo(height+20)
                make.width.equalTo(width)
                make.right.equalTo(aLocationView.snp.right).offset(-13)
            })
            toastLabel?.snp.remakeConstraints({ (make) in
                make.top.equalTo(toastBgView!.snp.top).offset(5)
                make.height.equalTo(height)
                make.width.equalTo(width)
                make.right.equalTo(toastBgView!.snp.right)
            })

            toastLabel?.text = message as String?
            toastLabel?.alpha = 1
            toastBgView?.alpha = 1

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                self.hiddenToastAction()
            }

        }else{
            DispatchQueue.main.async {
                self.showToast(message: message, aLocationView: aLocationView, aShowTime: aShowTime)
            }
            return
        }
    }
    
    //隐藏菊花
    class func hiddenToastAction() {
        if toastLabel != nil {

            toastLabel?.alpha = 0
            toastLabel?.removeFromSuperview()
        }
        
        if toastBgView != nil {

            toastBgView?.alpha = 0
            toastBgView?.removeFromSuperview()
        }
    }
}

extension CODToast {
    
    static var toastLabel : UILabel?
    class func currentToastLabel() -> UILabel {
        objc_sync_enter(self)
        if toastLabel == nil {
            toastLabel = UILabel.init()
            toastLabel?.backgroundColor = UIColor.clear
            toastLabel?.font = UIFont.systemFont(ofSize: 14)
            toastLabel?.textColor = UIColor.white
            toastLabel?.numberOfLines = 0;
            toastLabel?.textAlignment = .center
            toastLabel?.lineBreakMode = .byCharWrapping
            toastLabel?.layer.masksToBounds = true
            toastLabel?.layer.cornerRadius = 5.0
            toastLabel?.alpha = 0;
        }
        objc_sync_exit(self)
        return toastLabel!
    }
    
    static var toastBgView : UIImageView?
    class func currentToastBgView() -> UIImageView {
        objc_sync_enter(self)
        if toastBgView == nil {
            toastBgView = UIImageView.init()
            let image = UIImage(named: "Reminder_bubble")
            toastBgView?.image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: (image?.size.height)!/2 - 10, left: 10, bottom: 10, right: 25), resizingMode: UIImage.ResizingMode.stretch)
            toastBgView?.backgroundColor = UIColor.clear
            toastBgView?.layer.masksToBounds = true
            toastBgView?.layer.cornerRadius = 5.0
            toastBgView?.alpha = 0;
        }
        objc_sync_exit(self)
        return toastBgView!
    }
    
}

//MARK: config
extension CODToast {
    
    //根据字符串长度获取对应的宽度或者高度
    class func stringText(aText : NSString?, aFont : CGFloat, isHeightFixed : Bool, fixedValue : CGFloat) -> CGFloat {
        var size = CGSize.zero
        if isHeightFixed == true {
            size = CGSize.init(width: CGFloat(MAXFLOAT), height: fixedValue)
        }else{
            size = CGSize.init(width: fixedValue, height: CGFloat(MAXFLOAT))
        }
        //返回计算出的size
        let resultSize = aText?.boundingRect(with: size, options: (NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesLineFragmentOrigin.rawValue | NSStringDrawingOptions.usesFontLeading.rawValue | NSStringDrawingOptions.truncatesLastVisibleLine.rawValue)), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: aFont)], context: nil).size
        if isHeightFixed == true {
            return resultSize!.width + 20 //增加左右20间隔
        } else {
            return resultSize!.height + 20 //增加上下20间隔
        }
    }
}



