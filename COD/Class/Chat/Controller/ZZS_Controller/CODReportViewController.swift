//
//  CODReportViewController.swift
//  COD
//
//  Created by xinhooo on 2020/6/17.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import NextGrowingTextView

class CODReportViewController: BaseViewController,UITextViewDelegate {

    @IBOutlet weak var textBackView: UIView!
    @IBOutlet weak var textBackViewHeightCos: NSLayoutConstraint!
    var textView: NextGrowingTextView = NextGrowingTextView()
    
    var message: CODMessageModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        

        self.navigationItem.title = NSLocalizedString("举报", comment: "")

        self.backButton.setTitle("取消", for: .normal)
        self.backButton.setImage(nil, for: .normal)
        self.setBackButton()
        
        self.setRightTextButton()
        self.rightTextButton.setTitle("完成", for: .normal)
        self.rightTextButton.setTitleColor(UIColor(hexString: "047EF5"), for: .normal)
        self.rightTextButton.setTitleColor(UIColor(hexString: "787878")?.withAlphaComponent(0.4), for: .disabled)
        self.rightTextButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
     
        
        textView.textView.placeholder = NSLocalizedString("其他", comment: "")
        textView.textView.font = UIFont.systemFont(ofSize: 17)
        textBackView.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(8)
            make.left.equalTo(16)
            make.bottom.equalTo(-8)
            make.right.equalTo(-16)
        }
        
        textView.maxNumberOfLines = 10
        textView.minNumberOfLines = 1
        
        // 监控文本输入框的高度，动态改变约束
        textView.delegates.didChangeHeight = { [weak self] (height) in
            
            guard let `self` = self else {
                return
            }
            self.textBackViewHeightCos.constant = height + 16
        }
        
        textView.textView.delegate = self
        self.textViewDidChange(textView.textView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.textView.textView.becomeFirstResponder()
        }
    }

    override func navBackClick() {
        self.dismiss(animated: true, completion: nil)
    }

    override func navRightTextClick() {
        
        self.dismiss(animated: true) {[weak self] in
            guard let `self` = self else {
                return
            }
            CustomUtil.reportMessage(message: self.message, reportType: .other, otherDesc: self.textView.textView.text)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.rightTextButton.isEnabled = (textView.text.count > 0)
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if (textView.text.count >= 100 && text != "") || text.count > 100 || textView.text.count + text.count > 100 {
            return false
        }
        
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
