//
//  CODSetGroupNameVC.swift
//  COD
//
//  Created by XinHoo on 2019/4/10.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class CODSetGroupNameVC: CODTextFieldBaseViewController {
    
    typealias SuccessUpdateClose = (_ updateStr: String) -> (Void)
    var successUpdateClose: SuccessUpdateClose?
    
    var textFieldContent: String?
    
    let inputLimitLength = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let content = textFieldContent {
            textField.text = content
        }
        textField.addTarget(self, action: #selector(myTextDidChange), for: .editingChanged)

        // Do any additional setup after loading the view.
    }
    @objc func myTextDidChange(textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        if text.count > inputLimitLength {
            textField.text = textField.text?.slice(from: 0, length: inputLimitLength)
        }
        
    }
    override func navRightTextClick() {
        
        guard let text = textField.text else{
            return
        }
        
        if text == textFieldContent {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
//        CODProgressHUD.showWithStatus(nil)
        if text.removeHeadAndTailSpacePro.count <= 0 {
            CODProgressHUD.showErrorWithStatus("请输入群组名称")
            return
        }
        
        if text.count > inputLimitLength{
            CODProgressHUD.showErrorWithStatus(String(format: "群组名称不能超过%d个字符",inputLimitLength))
            return
        }
        
        XMPPManager.shareXMPPManager.changeGroupChatName(roomId: chatID!, roomName: text, success: { [weak self] (successModel, nameStr) in
            
            if nameStr == "editRoomName" {
                print("设置群组名称成功")
                CODGroupChatRealmTool.modifyGroupChatNameByRoomID(by: self?.chatID ?? 0, newRoomName: text)
                if self?.successUpdateClose != nil {
                    self?.successUpdateClose?(text)
                }
                //通知去聊天列表中更新数据
                NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil, userInfo: nil)
                
                self?.navigationController?.popViewController(animated: true)
            }
            
        }, fail: { (errorModel) in
            print("设置群组名称失败")
            CODProgressHUD.showSuccessWithStatus(errorModel.msg)
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
