//
//  CODGroupAnnounceEditVC.swift
//  COD
//
//  Created by XinHoo on 2019/4/18.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODGroupAnnounceEditVC: BaseViewController {
    
    var groupChatId: Int!
    var myPower :Int!
    
    weak var delegate: GroupAnnounceDelegate?
    
    
    
    var groupModel :CODGroupChatModel? = nil
    
    
    var announceContent: String = "" {
        didSet {
            textCountLab.text = "\(announceContent.count)/300"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enable = false
        view.backgroundColor = UIColor.white
        self.navigationItem.title = NSLocalizedString("群公告", comment: "")
        self.setBackButton()
        self.setRightTextButton()
        self.rightTextButton.setTitle("完成", for: UIControl.State.normal)
        
        self.setUpUI()
        self.createDataSource()
        self.textView.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    override func navRightTextClick() {
        
        if announceContent == self.groupModel?.notice {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        self.announceContent = self.announceContent.removeHeadAndTailSpacePro
        if self.announceContent.count <= 0 {
            let alertView = UIAlertController.init(title: "确定清空群公告？", message: nil, preferredStyle: UIAlertController.Style.alert)
            var action = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.default) { (action) in
                
            }
            alertView.addAction(action)
            action = UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default, handler: { (action) in
                self.submitContent()
            })
            alertView.addAction(action)
            self.present(alertView, animated: true, completion: nil)
        }else{
            self.submitContent()
        }
    }
    
    func submitContent() {
        //完成
//        CODProgressHUD.showWithStatus(nil)
        
        
        XMPPManager.shareXMPPManager.settingGroupAnnounce(roomId: self.groupChatId, notice: self.announceContent, success: { [weak self] (successModel, nameStr) in
            if nameStr == "setNotice" {
//                CODProgressHUD.showSuccessWithStatus(successModel.msg)
                
                guard let weakSelf = self else {
                    return
                }
                if (weakSelf.delegate) != nil {
                    weakSelf.delegate?.setGroupAnnounceComplete(announceStr: weakSelf.announceContent)
                }
                weakSelf.navigationController?.popViewController(animated: true, nil)
            }
            
            
        }) { (errorModel) in
            CODProgressHUD.showSuccessWithStatus(errorModel.msg)
        }
    }
    
    func createDataSource() {
        if let groupModel = CODGroupChatRealmTool.getGroupChat(id: groupChatId) {
            self.groupModel = groupModel
            if groupModel.notice.count > 0 {
                textLab.text = ""
                textView.text = groupModel.notice
                self.announceContent = groupModel.notice
            }
        }
    }
    
    func setUpUI() {
        self.view.addSubview(lab)
        self.view.addSubview(textViewbackground)
        textViewbackground.addSubview(textView)
        textView.addSubview(textLab)
        self.view.addSubview(textCountLab)
        
        lab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(36)
        }
        
        textViewbackground.snp.makeConstraints { (make) in
            make.top.equalTo(lab.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(KScreenHeight/2-100)
        }
        
        textView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 12, left: 16, bottom: 21, right: 16))
        }
        
        textLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(7)
            make.left.equalToSuperview().offset(5)
        }
        
        textCountLab.snp.makeConstraints { (make) in
            make.bottom.equalTo(textViewbackground)
            make.right.equalTo(textView)
        }
    }
    
    lazy var lab: UILabel = {
        let lab = UILabel()
        lab.text = "发布后将以系统消息发送到群组,  全体群成员可见。"
        lab.textColor = UIColor(hexString: kSubTitleColors)
        lab.backgroundColor = UIColor.clear
        lab.font = UIFont.systemFont(ofSize: 14)
        return lab
    }()
    
    lazy var textViewbackground: UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor.white
        return bg
    }()
    
    lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.delegate = self
        return tv
    }()
    
    lazy var textLab: UILabel = {
        let lab = UILabel()
        lab.text = "你可以发布群公告.."
        lab.isEnabled = false
        lab.backgroundColor = UIColor.clear
        lab.font = UIFont.systemFont(ofSize: 16)
        lab.textColor = UIColor(hexString: kSubTitleColors)
        return lab
    }()

    lazy var textCountLab: UILabel = {
        let lab = UILabel()
        lab.text = "0/300"
        lab.isEnabled = false
        lab.font = UIFont.systemFont(ofSize: 16)
        lab.textColor = UIColor.green
        return lab
    }()

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CODGroupAnnounceEditVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.count > 300 {
            let text = textView.text.prefix(300)
            textView.text = text.description
        }
        textCountLab.text = "\(textView.text.count)/300"
        self.announceContent =  textView.text;
        if (textView.text.count == 0) {
            textLab.text = "你可以发布群公告.."
        }else{
            textLab.text = ""
        }

    }
}

protocol GroupAnnounceDelegate: class {
    func setGroupAnnounceComplete(announceStr: String) -> Void
}
