//
//  CODTextFieldCell.swift
//  COD
//
//  Created by XinHoo on 2019/3/12.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit


class CODTextFieldCell: UITableViewCell, UITextFieldDelegate {
    
    var limitInputNumber: Int = 0 {
        didSet {
            field.setInputNumber(number: self.limitInputNumber)
        }
    }
    
    typealias FieldShouldEndEditCloser = (_ textField: UITextField) -> Bool
    var fieldShouldEndEditCloser : FieldShouldEndEditCloser?
    
    typealias FieldDidEndEditCloser = (_ textField: UITextField) -> ()
    var fieldDidEndEditCloser : FieldDidEndEditCloser?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.addSubview(field)
        field.delegate = self
        field.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(30)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if let ctl = UIViewController.current() {
            ctl.rx.deallocating.bind {
                self.field.delegate = nil
            }
        }
    }
    
    lazy var field: CODLimitInputNumberTextField = {
        let field = CODLimitInputNumberTextField()
        field.font = UIFont.systemFont(ofSize: 15)
        field.clearButtonMode = UITextField.ViewMode.always
        return field
    }()
    
//    @objc func changedTextField(_ textField: UITextField) {
//        guard let text = textField.text else {
//            return
//        }
//        if fieldEditingCloser != nil {
//            fieldEditingCloser?(text)
//        }
//    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if fieldShouldEndEditCloser != nil {
//            fieldDidEndEditCloser!(textField)
//        }
//    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if fieldShouldEndEditCloser != nil {
            return fieldShouldEndEditCloser!(textField)
        }
        return true
    }

}
