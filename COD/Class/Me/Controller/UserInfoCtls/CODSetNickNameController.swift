//
//  CODSetNickNameController.swift
//  COD
//
//  Created by XinHoo on 2019/3/8.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import XMPPFramework
import RxCocoa
import RxSwift

class CODSetNickNameController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("昵称", comment: "")
        self.setBackButton()
        self.setRightTextButton()
        self.rightTextButton.setTitle("完成", for: UIControl.State.normal)
        
        XMPPManager.shareXMPPManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        self.addSubView()
        self.addSubViewContrains()
        
        
        self.nickField.rx.text.map { [weak self ] in
            guard let `self` = self else { return "" }
            
            let count = self.nickField.limitInputNumber - ($0?.count  ?? 0)
            return count <= 0 ? "0" : "\(count)"
        }
        .bind(to: self.textCountLabel.rx.text)
        .disposed(by: self.rx.disposeBag)
        
//        self.updateTextLabelCount()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
        
    func addSubView() {
        self.view.addSubview(fieldBgView)
        fieldBgView.addSubview(tipsLabel)
        fieldBgView.addSubview(topLine)
        fieldBgView.addSubview(bottomLine)
        fieldBgView.addSubview(nickField)
        fieldBgView.addSubview(textCountLabel)
    }
    
    func addSubViewContrains() {
        
        fieldBgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(32)
            make.left.right.equalToSuperview()
            make.height.equalTo(45)
        }
        
        let textSize = tipsLabel.text?.getLabelStringSize(font: UIFont.systemFont(ofSize: 15.0), lineSpacing: 0, fixedWidth: KScreenWidth)
        
        tipsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
//            make.width.equalTo(textSize?.width ?? 0)
        }
        
        tipsLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
                
        topLine.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(fieldBgView)
        }
        
        bottomLine.snp.makeConstraints { (make) in
             make.left.right.equalToSuperview()
             make.height.equalTo(0.5)
             make.bottom.equalTo(fieldBgView)
         }
        
        nickField.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(tipsLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-47)
            make.height.equalTo(20)
        }
        
        textCountLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-19)
            make.centerY.equalToSuperview()
        }
    }
    
    override func navRightTextClick() {
        guard CODWebRTCManager.whetherConnectedNetwork() else {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            return
        }
        
        guard var nick = nickField.text else{
            return
        }
        
        if nick == UserManager.sharedInstance.nickname {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        
        nick = nick.removeHeadAndTailSpacePro
        if nick.count <= 0 {
            CODProgressHUD.showErrorWithStatus("昵称为必填项(*)")
            return
        }
        if nick.count > 15  {
            CODProgressHUD.showErrorWithStatus("昵称设置请控制在15个字以内哦")
            return
        }
        
        let paramDic = ["name":COD_changePerson,"requester":"\(UserManager.sharedInstance.jid)","setting":["name": nick]] as [String : Any]
        let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting_V2, actionDic: paramDic as NSDictionary)
        XMPPManager.shareXMPPManager.xmppStream.send(iq)
        
    }
    
    lazy var fieldBgView: UIView = {
        let bgv = UIView()
        bgv.backgroundColor = UIColor.white
        return bgv
    }()
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.text = "昵称"
        label.textAlignment = .left
        label.textColor = UIColor(hexString: kMainTitleColorS)
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    lazy var nickField: CODLimitInputNumberTextField = {
        let field = CODLimitInputNumberTextField()
        field.placeholder = ""
        field.text = UserManager.sharedInstance.nickname
        field.font = UIFont.systemFont(ofSize: 15)
//        field.addTarget(self, action: #selector(setNick(_:)), for: UIControl.Event.editingChanged)
        field.setInputNumber(number: 15)
        return field
    }()
    
    lazy var topLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(hexString: kDividingLineColorS)
        return line
    }()
    
    lazy var bottomLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(hexString: kDividingLineColorS)
        return line
    }()
    
    lazy var textCountLabel: UILabel = {
        let label = UILabel()
        label.text = "15"
        label.textColor = UIColor(hexString: kGrayTextCountTextColorS)
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    
//    @objc func setNick(_ field: UITextField){
//        guard let text = field.text else {
//            return
//        }
//
//        if text.count > 15 {
////            self.nickField.text = text.subStringToIndex(20)
//            let subStr = text.prefix(15)
//
//            self.nickField.text = subStr.description
//        }
//
//        self.updateTextLabelCount()
//    }
//
//    func updateTextLabelCount() {
//        textCountLabel.text = "\(15-(self.nickField.text?.count ?? 0))"
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CODSetNickNameController: XMPPStreamDelegate {
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        CustomUtil.analyticxXML(iq: iq) { (actionDict, infoDict) in
            guard let infoDict = infoDict else {
                return
            }
            if (actionDict["name"] as? String == COD_changePerson){
                if let success = infoDict["success"] as? Bool {
                    if success {                        
//                        CODProgressHUD.showSuccessWithStatus("设置成功")
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        if let code = infoDict["code"] as? Int {
                            switch code {
                            
                            default: break
                            }
                        }
                    }
                }
            }
        }
        
        return true
    }
}
