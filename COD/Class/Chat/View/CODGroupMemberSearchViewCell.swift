//
//  CODGroupMemberSearchViewCell.swift
//  COD
//
//  Created by XinHoo on 2019/8/5.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODGroupMemberSearchViewCell: UICollectionViewCell {
    weak var delegate :CODGroupMemberSearchDelegate?
    
    var ableToDeleteMember = false
    
    var cellWidth:CGFloat = 80.0 {
        didSet {
            guard cellWidth >= 80 else {
                return
            }
            self.textField.snp.remakeConstraints { (make) in
                make.left.top.right.bottom.equalToSuperview()
                make.width.equalTo(cellWidth)
                make.height.equalTo(34.0)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textField.snp.remakeConstraints { (make) in
            make.left.top.right.bottom.equalToSuperview()
            make.width.equalTo(cellWidth)
            make.height.equalTo(34.0)
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
        self.addSubview(textField)
        
        textField.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(cellWidth)
            make.height.equalTo(34)
        }
    }
    
    lazy var textField: CODTextField = {
        let textField = CODTextField()
        textField.backgroundColor = UIColor.clear
        textField.tag = 999
        textField.font = UIFont.systemFont(ofSize: 15.0)
        textField.deleteDelegate = self
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldTextDidChange(field:)), for: UIControl.Event.editingChanged)
        return textField
    }()
    
    @objc func textFieldTextDidChange(field :UITextField) {
        
        if (delegate != nil) {
            ableToDeleteMember = false
            self.delegate!.searchTextDidEditChange(field: field)
        }
    }
        
}


extension CODGroupMemberSearchViewCell : UITextFieldDelegate {
 
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if delegate != nil {
            return delegate!.searchFieldShouldBeginEditing(textField)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if delegate != nil {
            delegate?.searchFieldDidEndEditing(textField)
        }
    }

}

extension CODGroupMemberSearchViewCell :CODTextFieldDelegate {
    func keyBoardDeleteBtnClick(field: UITextField) {
        if (field.text?.count)! <= 0 && ableToDeleteMember == false{
            ableToDeleteMember = true
        }else if (field.text?.count)! <= 0 && ableToDeleteMember == true {
            if delegate != nil {
                self.delegate!.deleteMember()
            }
        }
    }
    
}

protocol CODGroupMemberSearchDelegate: class {
    func searchFieldShouldBeginEditing(_ field: UITextField) -> Bool
    func searchFieldDidEndEditing(_ field: UITextField)
    func searchTextDidEditChange(field: UITextField)
    func deleteMember()
}

