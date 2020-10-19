//
//  CODGroupMemberSearchView.swift
//  COD
//
//  Created by XinHoo on 2019/3/28.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODGroupMemberSearchView: UIView {
    
    weak var delegate :CODGroupMemberSearchViewDelegate?

    
    var isHiddenSearchView = false {
        didSet{
            if isHiddenSearchView {
                searchView.snp.updateConstraints { (make) in
                    make.width.equalTo(0.1)
                }
                textField.snp.updateConstraints { (make) in
                    make.left.equalTo(searchView.snp.right)
                }
            } else {
                searchView.snp.updateConstraints { (make) in
                    make.width.equalTo(15)
                }
                textField.snp.updateConstraints { (make) in
                    make.left.equalTo(searchView.snp.right).offset(8)
                }
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        self.addSubview(searchView)
        self.addSubview(textField)
        
        searchView.snp.makeConstraints { (make) in
            make.height.width.equalTo(15)
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
        }
        
        textField.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(searchView.snp.right).offset(8)
            make.right.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    lazy var searchView: UIImageView = {
        let searchIcon = UIImageView(image: UIImage(named: "search_icon"))
        return searchIcon
    }()
    
    lazy var textField: CODTextField = {
        let textField = CODTextField()
        textField.placeholder = "搜索"
        textField.deleteDelegate = self
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldTextDidChange(field:)), for: UIControl.Event.editingChanged)
        return textField
    }()
    
    @objc func textFieldTextDidChange(field :UITextField) {
        if (delegate != nil) {
            ableToDeleteMember = false
            self.delegate?.searchTextDidEditChange(field: field)
        }
    }
}

extension CODGroupMemberSearchView : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

var ableToDeleteMember = false

extension CODGroupMemberSearchView :CODTextFieldDelegate {
    func keyBoardDeleteBtnClick(field: UITextField) {
        if (field.text?.count)! <= 0 && ableToDeleteMember == false{
            ableToDeleteMember = true
        }else if (field.text?.count)! <= 0 && ableToDeleteMember == true {
            if delegate != nil {
                self.delegate?.deleteMember()
            }
        }
    }

    
}

protocol CODGroupMemberSearchViewDelegate: class {
    func searchTextDidEditChange(field: UITextField)
    func deleteMember()
}


