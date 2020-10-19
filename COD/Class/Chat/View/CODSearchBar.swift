//
//  CODSearchBar.swift
//  COD
//
//  Created by 1 on 2019/3/20.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODSearchBar: UISearchBar {
//    var cancleButton = UIButton.init(type: .custom)
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        self.searchBarStyle = .minimal
        self.backgroundImage = UIImage()
        self.barTintColor = UIColor.white
//        self.tintColor = UIColor.red
        
        ///设置圆角和边框
//        let searchField = self.value(forKey: "_searchField") as? UITextField
        let searchField = self.customTextField
        if (searchField != nil) {
            searchField?.backgroundColor = UIColor.white
            searchField?.layer.cornerRadius = 14.0
            searchField?.layer.masksToBounds = true
            ///光标的颜色
            searchField?.tintColor = UIColor.init(hexString: "#426BF2")
            //字体颜色大小
            searchField?.font = FONT16
            searchField?.textColor = UIColor.black
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UISearchBar {
    
    func setCancelButton() {
        ///取消按钮
//        for v in self.subviews {
//            for _v in v.subviews {
//                for __v in _v.subviews {
//                    if let _cls = NSClassFromString("UINavigationButton") {
//                        if __v.isKind(of: _cls) {
//                            guard let btn = __v as? UIButton else { return }
//                            btn.setTitle(NSLocalizedString("取消", comment: ""), for: .normal)
//                            btn.setTitleColor(UIColor.init(hexString: kMainBlueBgColorS), for: .normal)
//                            btn.titleLabel?.font = FONT16
//                            btn.setBackgroundImage(UIImage.imageFromColor(color: UIColor.clear, viewSize: btn.size), for: .normal)
//                            btn.setBackgroundImage(UIImage.imageFromColor(color: UIColor.clear, viewSize: btn.size), for: .highlighted)
//                            btn.backgroundColor = UIColor.clear
//                            return
//                        }
//                    }
//                }
//            }
//        }
        
        var btn: UIButton!
        if #available(iOS 13.0, *) {
            let index = indexOfCancelBtnInSubviewsForiOS13()
            btn = subviews[0].subviews[index.0!].subviews[index.1!] as? UIButton
        }else{
            if let index = indexOfCancelBtnInSubviews() {
                btn = subviews[0].subviews[index] as? UIButton
            }
        }
        btn.setTitle(NSLocalizedString("取消", comment: ""), for: .normal)
        btn.setTitleColor(UIColor.init(hexString: kMainBlueBgColorS), for: .normal)
        btn.titleLabel?.font = FONT16
        btn.setBackgroundImage(UIImage.imageFromColor(color: UIColor.clear, viewSize: btn.size), for: .normal)
        btn.setBackgroundImage(UIImage.imageFromColor(color: UIColor.clear, viewSize: btn.size), for: .highlighted)
        btn.backgroundColor = UIColor.clear
        btn.sizeToFit()
        self.layoutSubviews()
        
    }
        
    
    func indexOfCancelBtnInSubviews() -> Int! {
        var index: Int!
        let searchBarView = subviews[0]
        for i in 0..<searchBarView.subviews.count {
            if searchBarView.subviews[i].isKind(of: UIButton.self) {
                index = i
                break
            }
        }
        return index
    }
    
    func indexOfCancelBtnInSubviewsForiOS13() -> (Int?,Int?) {
        var index1: Int!
        var index2: Int!
        let searchBarView = subviews[0]
        for i in 0..<searchBarView.subviews.count {
            let subViews2 = searchBarView.subviews[i]
            for j in 0..<subViews2.subviews.count {
                if subViews2.subviews[j].isKind(of: UIButton.self) {
                    index1 = i
                    index2 = j
                    break
                }
            }
            
        }
        return (index1,index2)
    }
    
    func setContentInset(contentInset:UIEdgeInsets?) {
        // view是searchBar中的唯一的直接子控件
        for view in self.subviews {
            // UISearchBarBackground与UISearchBarTextField是searchBar的简介子控件
            for subview in view.subviews {
                
                // 找到UISearchBarTextField
                if subview.isKind(of: UITextField.classForCoder()) {
                    
                    if let textFieldContentInset = contentInset { // 若contentInset被赋值
                        // 根据contentInset改变UISearchBarTextField的布局
                        subview.frame = CGRect(x: textFieldContentInset.left, y: textFieldContentInset.top, width: self.bounds.width - textFieldContentInset.left - textFieldContentInset.right, height: self.bounds.height - textFieldContentInset.top - textFieldContentInset.bottom)
                    } else { // 若contentSet未被赋值
                        // 设置UISearchBar中UISearchBarTextField的默认边距
//                        let top: CGFloat = (self.bounds.height - 28.0) / 2.0
//                        let bottom: CGFloat = top
//                        let left: CGFloat = 8.0
//                        let right: CGFloat = left
                    }
                }
            }
        }
    }
    
    func addCancelTarget() {
        var btn: UIButton!
        if #available(iOS 13.0, *) {
            let index = indexOfCancelBtnInSubviewsForiOS13()
            btn = subviews[0].subviews[index.0!].subviews[index.1!] as? UIButton
        }else{
            if let index = indexOfCancelBtnInSubviews() {
                btn = subviews[0].subviews[index] as? UIButton
            }
        }
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
    }
    
    @objc func cancelAction() {
        self.customTextField?.endEditing(true)
    }
}


