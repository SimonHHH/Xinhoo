//
//  CODGroupMyNickVC.swift
//  COD
//
//  Created by XinHoo on 2019/4/11.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODGroupMyNickVC: CODTextFieldBaseViewController {
    
    typealias SuccessUpdateClose = (_ updateStr: String) -> (Void)
    var successUpdateClose: SuccessUpdateClose?
    var textFieldText = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        textField.addTarget(self, action: #selector(myTextDidChange), for: .editingChanged)
    }
    
    @objc func myTextDidChange(textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        if text.count > 20 {
            textField.text = textFieldText
            return
        }
        textFieldText = text
    }
    
    override func navRightTextClick() {
        
        guard let text = textField.text else{
            return
        }
        
        if text == self.defaultText {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
//        CODProgressHUD.showWithStatus(nil)
        
        if text.removeHeadAndTailSpacePro.count <= 0 && text.count > 0 {
            CODProgressHUD.showErrorWithStatus("昵称不可全为空格")
            textField.text = ""
            textField.becomeFirstResponder()
            return
        }
        
        XMPPManager.shareXMPPManager.changeGroupMyNickName(roomId: chatID!, nickName: text, success: {[weak self] successModel in
            print("设置本群的昵称成功")
            //                CODProgressHUD.showSuccessWithStatus("设置成功")
            
            if let selfTemp = self, let username = UserManager.sharedInstance.loginName {
                let memberId = CODGroupMemberModel.getMemberId(roomId: selfTemp.chatID!, userName: username)
                if let model = CODGroupMemberRealmTool.getMemberById(memberId) {
                    try! Realm.init().write {
                        model.nickname = text
                    }
                }
            }
            
            if self?.successUpdateClose != nil {
                self?.successUpdateClose?(text)
            }
            self?.navigationController?.popViewController(animated: true)
            }, fail: { errorString in
                print("设置本群的昵称失败")
                CODProgressHUD.showSuccessWithStatus(errorString)
        })
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

protocol CODTextFieldVCDelegate: class {
    func textFieldDidChangeValue(textField: UITextField)
}
