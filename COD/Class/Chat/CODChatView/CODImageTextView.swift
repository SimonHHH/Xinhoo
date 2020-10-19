//
//  CODImageTextView.swift
//  COD
//
//  Created by 1 on 2019/9/4.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODImageTextView: UIView {
    var seeker = CharacterLocationSeeker.init()

    public lazy var textLabel:YYLabel = {
        let label = YYLabel(frame: CGRect.zero)
        label.font = UIFont.init(name: "PingFangSC-Regular", size: 16)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        return label;
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView() {
        self.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
         make.left.right.top.bottom.equalTo(self)
        }
    }
    
    func setContentText(textString: String,isEdit: Bool, maxWidth: CGFloat) -> (isSame: Bool,labelSize: CGSize) {
        self.textLabel.attributedText =  NSAttributedString.init(string: textString)
        self.textLabel.font = UIFont.init(name: "PingFangSC-Regular", size: CGFloat(17+(UserDefaults.standard.integer(forKey: kFontSize_Change))))
        self.configText(maxWidth: maxWidth - 9.0)
        var contentSize = self.textLabel.sizeThatFits(CGSize.init(width:maxWidth - 9.0, height: CGFloat(MAXFLOAT)))
        // 很奇怪，sizeThatFits这个方法计算出label的size有可能会比指定的size要大，所以做一次判断处理，如果要大于或等于指定的size，就让计算出来的size等于指定的size
        if contentSize.width >= (maxWidth - 9.0) {
            contentSize.width = maxWidth - 9.0
        }
        let timeWidth:CGFloat = XinhooTool.is12Hour ? 65 : 45

        if contentSize.width + timeWidth <= maxWidth {
          return (isSame: true ,labelSize: contentSize)
        }else{
            let rect = self.seeker.lastCharacterRect(for: self.textLabel.attributedText, drawing: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: contentSize))
            
            if rect.maxX + timeWidth > maxWidth{
                return (isSame: false, labelSize: contentSize)
            }else{
                return (isSame: true, labelSize: contentSize)
            }
            
        }
    }
    
    private func configText(maxWidth: CGFloat){
        self.textLabel.preferredMaxLayoutWidth = maxWidth
        self.textLabel.numberOfLines = 0
        self.textLabel.textAlignment = .left
    }
}
