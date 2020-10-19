//
//  CODTextFieldTableViewCell.swift
//  COD
//
//  Created by XinHoo on 2019/11/25.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit


class CODTextFieldTableViewCell: UITableViewCell {

    typealias FieldEditingCloser = (_ text : String) -> ()
    var fieldEditingCloser : FieldEditingCloser?
    
    var placeholder: String? {
        didSet {
            if let str = placeholder {
                field.placeholder = str
            }
        }
    }
    
    var isTop: Bool = false {
        didSet {
            if isTop {
                topLine.isHidden = false
            }else{
                topLine.isHidden = true
            }
        }
    }
    
    var isLast: Bool = false {
        didSet {
            if isLast {
                bottomLine.snp.updateConstraints { (make) in
                    make.left.equalTo(0)
                }
            }else{
                bottomLine.snp.updateConstraints { (make) in
                    make.left.equalTo(66)
                }
            }
        }
    }
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.addSubviews([field, topLine, bottomLine])
        field.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-6)
            make.height.greaterThanOrEqualTo(34)
        }
        
        bottomLine.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    lazy var field: UITextView = {
        let field = UITextView()
        field.font = UIFont.systemFont(ofSize: 16)
        field.isScrollEnabled = false
        field.delegate = self
        return field
    }()
    
    private lazy var topLine: UIView = {
        let linev = UIView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: KScreenWidth, height: 0.5))
        linev.backgroundColor = UIColor(hexString: kSepLineColorS)
        linev.isHidden = true
        return linev
    }()
    
    private lazy var bottomLine: UIView = {
        let linev = UIView.init()
        linev.backgroundColor = UIColor(hexString: kSepLineColorS)
        return linev
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}

extension CODTextFieldTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else {
            return
        }
        
        if text.count > 200 {
            let textStr = text.subStringToIndex(200)
            textView.text = textStr
        }
        
        var bounds = textView.bounds
        let size = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let newSize = textView.sizeThatFits(size)
        bounds.size = newSize
        textView.bounds = bounds
        
        if fieldEditingCloser != nil {
            fieldEditingCloser?(text)
        }
    }
}
