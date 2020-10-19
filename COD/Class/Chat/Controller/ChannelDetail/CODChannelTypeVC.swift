//
//  CODChannelTypeVC.swift
//  COD
//
//  Created by 1 on 2019/11/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

enum CODChannelTypeVCType : Int {
    case create = 1
    case edit = 2
}



class CODChannelTypeVC: BaseViewController {
    

    var channelModel: CODChannelModel?
    
    
    var channelType: CODChannelType = .CPUB
    var publicUrlStr: String = ""
    var privateUrl: String = "" {
        didSet {
            if self.channelType == .CPRI {
                preLabel.text = CODAppInfo.channelSharePrivateLink + (self.privateUrl)
            }
        }
    }
    
    var  vcType: CODChannelTypeVCType?
    
    fileprivate lazy var typeBgView: UIView = {
         let bgView = UIView.init()
         bgView.backgroundColor = UIColor.clear
         return bgView
     }()
    
    fileprivate lazy var publicControl: UIControl = {
         let control = UIControl.init()
         control.backgroundColor = UIColor.white
         return control
     }()
    
    fileprivate lazy var publicImageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.white
        imageView.image = UIImage.init(named: "link_Type_Selected")
        return imageView
     }()
    
    fileprivate lazy var privateImageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.white
        imageView.image = UIImage.init(named: "link_Type_Selected")
        return imageView
     }()
    
    fileprivate lazy var privateControl: UIControl = {
         let control = UIControl.init()
         control.backgroundColor = UIColor.white
         return control
     }()
    
    fileprivate lazy var ruleLabel: UILabel = {
        let ruleLb = UILabel(frame: CGRect.zero)
        ruleLb.textColor = UIColor.init(hexString: kSectionFooterTextColorS)
        ruleLb.font = UIFont.systemFont(ofSize: 11)
        ruleLb.text = NSLocalizedString("公开频道可以被搜索，任何人都可以加入。", comment: "")
        return ruleLb
    }()
    
    fileprivate lazy var bgView: UIView = {
         let bgView = UIView.init()
         bgView.backgroundColor = UIColor.white
         return bgView
     }()
    
    fileprivate lazy var checkView: UIView = {
         let bgView = UIView.init()
         bgView.backgroundColor = UIColor.clear
        bgView.isHidden = true
         return bgView
     }()
    
    fileprivate lazy var testLabel: UILabel = {
        let testLb = UILabel(frame: CGRect.zero)
        testLb.textColor = UIColor.init(hexString: "#BE3E38")
        testLb.font = UIFont.systemFont(ofSize: 11)
        testLb.text = ""
        testLb.isHidden = true
        return testLb
    }()
    
    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = {
         let activeVeiw = UIActivityIndicatorView.init(style: .gray)
         activeVeiw.backgroundColor = UIColor.clear
         activeVeiw.hidesWhenStopped = false
         return activeVeiw
     }()
    
//    let preString: String = "noone.ltd/"
    
    fileprivate lazy var textField: UITextField = {
        let textField = UITextField(frame: CGRect.zero)
        textField.textColor = UIColor.black
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.backgroundColor = UIColor.white
        textField.placeholder = NSLocalizedString("链接", comment: "")
        textField.keyboardType = .asciiCapable
        return textField
    }()
    
    fileprivate lazy var tipLabel: UILabel = {
        let tipLb = UILabel(frame: CGRect.zero)
        tipLb.textColor = UIColor.init(hexString: kSectionFooterTextColorS)
        tipLb.font = UIFont.systemFont(ofSize: 11)
        tipLb.text = CustomUtil.formatterStringWithAppName(str: "用户可与他人分享此链接，使用 %@ 搜索也能找到您的频道。")
        return tipLb
    }()
    
    fileprivate lazy var bottomView: UIView = {
         let bgView = UIView.init()
         bgView.backgroundColor = UIColor.white
         return bgView
     }()
    
    var preLabel: UILabel = UILabel.init()
    fileprivate func generatePrivateUserId() {
        XMPPManager.shareXMPPManager.getRequest(param: [
            "name": "getuniqueshareid",
            "roomName": self.channelModel?.jid ?? ""
        ], xmlns: COD_com_xinhoo_channelsetting) { [weak self] (result) in
            
            guard let `self` = self else { return }
            
            switch result {
                
            case .success(let model):
                self.privateUrl = model.dataJson?.stringValue ?? ""
                break
            case .failure(_):
                break
                
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("频道", comment: "")
        self.setBackButton()
        if self.vcType == .create{
            self.rightTextButton.setTitle(NSLocalizedString("下一步", comment: ""), for: .normal)
        }else{
            self.rightTextButton.setTitle(NSLocalizedString("完成", comment: ""), for: .normal)
        }
        
        if self.channelModel?.channelTypeEnum == .CPUB {
            
            self.publicUrlStr = self.channelModel?.userid ?? ""
            generatePrivateUserId()

        } else {
            self.privateUrl = self.channelModel?.userid ?? ""
        }
       
        
        self.setRightTextButton()
        self.setUpView()
        
        if self.vcType == .edit {
            
            if self.channelModel?.channelTypeEnum == .CPUB {
                self.publicControlAction()
                self.textField.text = self.channelModel?.userid
            } else {
                self.privateControlAction()
            }

        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    fileprivate func setChannelLink(_ channelModel: CODChannelModel, _ linkUrl: String) {
        
        CODProgressHUD.showWithStatus(nil)
        XMPPManager.shareXMPPManager.channelSetting(roomID: channelModel.chatId , type: self.channelType, linkUrl: linkUrl) { [weak self, channelModel] result in
            
            CODProgressHUD.dismiss()
            
            switch result {
                
            case .success(_):
                guard let `self` = self else { return }
                if self.channelType == .CPUB {
                    channelModel.updateChannel(channelType: self.channelType, link: self.publicUrlStr)
                } else {
                    channelModel.updateChannel(channelType: self.channelType)
                }
                
                if self.vcType == .create {
                    
                    let creGroupVC = CreGroupChatViewController()
                    creGroupVC.ctlType = .createChannel
                    creGroupVC.channelModel = channelModel
                    
                    self.navigationController?.pushViewController(creGroupVC, animated: true)
                    
                } else {
                    channelModel.updateChannel(channelType: self.channelType, link: linkUrl)
                    self.navigationController?.popViewController(animated: true)
                }
                
            case .failure(.iqReturnError(let code, let msg)):
                
                switch code {
                case 30036:
                    CODProgressHUD.showWarningWithStatus(NSLocalizedString("抱歉，此链接无效", comment: ""))
                case 30002:
                    CODProgressHUD.showWarningWithStatus(NSLocalizedString("此链接已存在", comment: ""))
                default:
                    CODProgressHUD.showWarningWithStatus(NSLocalizedString("抱歉，此链接无效", comment: ""))
                }
            default:
                break
                
                
            }
            
            
        }
        
    }
    
    override func navRightTextClick() {
        
        guard let channelModel = self.channelModel else {
            return
        }
        
        if channelType == .CPUB {
            
            self.publicUrlStr = self.publicUrlStr.removeAllSapce
            
            if self.publicUrlStr.count < 5 {
                CODProgressHUD.showWarningWithStatus(NSLocalizedString("频道链接必须包含至少5个字符", comment: ""))
                return
            }
            
            if self.publicUrlStr.count > 32 {
                CODProgressHUD.showWarningWithStatus(NSLocalizedString("频道链接字符超过最大限制", comment: ""))
                return
            }
            
            if !self.publicUrlStr.isEnglishCharactersStar() {
                CODProgressHUD.showWarningWithStatus(NSLocalizedString("频道链接必须以字母开头", comment: ""))
                return
            }

        }
        
        var linkUrl = ""
        
        if channelType == .CPUB {
            linkUrl = self.publicUrlStr
        } else {
            linkUrl = self.privateUrl
        }
        
        if channelType == .CPUB && vcType == .create {
            
            CODAlertVcPresent(confirmBtn: NSLocalizedString("好", comment: ""), message: NSLocalizedString("请注意:  如果您选择给您的频道创建一个公开链接,  任何人都可以通过搜索找到您的频道并加入。\n\n如果您想保持频道的私密性,请不要创建此链接", comment: ""), title: "", cancelBtn: NSLocalizedString("取消", comment: ""), handler: { [weak self] (action) in
                
                guard let `self` = self else { return }
                
                if action.style == .default{
                    
                    self.setChannelLink(channelModel, linkUrl)
                }
            }, viewController: self)
            
            
        } else {
            CODProgressHUD.showWithStatus(nil)
            setChannelLink(channelModel, linkUrl)
        }

    }
    
    func setUpView() {
        
        self.setUpTypeView()
        
        self.setUpLinkView()
        
        if self.vcType == .edit{
           self.setUpBottomView()
        }
    }
    
    func setUpTypeView() {
        self.view.addSubview(self.typeBgView)
        
        let typeLabel = UILabel(frame: CGRect.zero)
        typeLabel.textColor = UIColor.init(hexString: "#B2B2B2")
        typeLabel.font = UIFont.systemFont(ofSize: 12)
        typeLabel.text = NSLocalizedString("频道类型", comment: "")
        
        let topLineViwe = UIView.init()
        topLineViwe.backgroundColor = UIColor.init(hexString: kSepLineColorS)
        
        let publicLabel = UILabel(frame: CGRect.zero)
        publicLabel.textColor = UIColor.black
        publicLabel.font = UIFont.systemFont(ofSize: 17)
        publicLabel.text = NSLocalizedString("公开", comment: "")
        
        let middleLineView = UIView.init()
        middleLineView.backgroundColor = UIColor.init(hexString: kSepLineColorS)
        
        let privateLabel = UILabel(frame: CGRect.zero)
        privateLabel.textColor = UIColor.black
        privateLabel.font = UIFont.systemFont(ofSize: 17)
        privateLabel.text = NSLocalizedString("私人", comment: "")
        
        let bottomLineView = UIView.init()
        bottomLineView.backgroundColor = UIColor.init(hexString: kSepLineColorS)
        self.typeBgView.addSubviews([typeLabel,self.publicControl,self.publicImageView,self.privateControl,publicLabel,privateLabel, self.privateImageView,topLineViwe,middleLineView,bottomLineView,self.ruleLabel])
        
        self.typeBgView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(210)
        }
        
        typeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(15)
            make.top.equalTo(self.typeBgView).offset(35)
            make.height.equalTo(17)
        }
        
        topLineViwe.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.typeBgView)
            make.height.equalTo(0.5)
            make.top.equalTo(typeLabel.snp.bottom).offset(4)
        }
        
        self.publicControl.addTarget(self, action: #selector(publicControlAction), for: .touchUpInside)
        self.publicControl.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(topLineViwe)
            make.height.equalTo(43.5)
        }
        
        self.publicImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.typeBgView).offset(14)
            make.centerY.equalTo(self.publicControl)
            make.height.width.equalTo(16)
        }
        
        publicLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.publicImageView.snp.right).offset(14)
            make.centerY.equalTo(self.publicControl)
        }
        
        middleLineView.snp.makeConstraints { (make) in
            make.left.equalTo(self.typeBgView).offset(44)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.bottom.equalTo(self.publicControl.snp.bottom)
        }
        
        self.privateControl.addTarget(self, action: #selector(privateControlAction), for: .touchUpInside)
        self.privateControl.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.publicControl.snp.bottom)
            make.height.equalTo(43.5)
        }
        
        self.privateImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.typeBgView).offset(14)
            make.centerY.equalTo(self.privateControl)
            make.height.width.equalTo(16)
        }
        
        privateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.privateImageView.snp.right).offset(14)
            make.centerY.equalTo(self.privateControl)
        }
        
        bottomLineView.snp.makeConstraints { (make) in
            make.left.equalTo(self.typeBgView).offset(0)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.bottom.equalTo(self.privateControl.snp.bottom)
        }
        
        self.ruleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.typeBgView).offset(15)
            make.top.equalTo(self.privateControl.snp.bottom).offset(7)
            make.height.equalTo(16)
        }
        self.publicImageView.isHidden  = false
        self.privateImageView.isHidden  = true
        
    }
    
    func setUpLinkView() {
        let topLineViwe = UIView.init()
        topLineViwe.backgroundColor = UIColor.init(hexString: kSepLineColorS)
        
        self.preLabel = UILabel(frame: CGRect.zero)
        self.preLabel.textColor = UIColor.black
        self.preLabel.font = UIFont.systemFont(ofSize: 17)
        self.preLabel.text = CODAppInfo.channelSharePublicLink;
        self.preLabel.setContentHuggingPriority(.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
        
        let bottomLineView = UIView.init()
        bottomLineView.backgroundColor = UIColor.init(hexString: kSepLineColorS)

        
        let checkLabel = UILabel(frame: CGRect.zero)
        checkLabel.textColor = UIColor.init(hexString: kSectionFooterTextColorS)
        checkLabel.font = UIFont.systemFont(ofSize: 11)
        checkLabel.text = NSLocalizedString("正在检查名称...", comment: "")
        
        self.bgView.addSubviews([topLineViwe,self.preLabel,bottomLineView,self.textField,self.tipLabel])

        self.checkView.addSubviews([self.activityIndicatorView,checkLabel])
        self.view.addSubview(self.testLabel)
        self.view.addSubviews([self.bgView,self.checkView,self.testLabel])


        self.bgView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.typeBgView.snp.bottom).offset(0)
            make.height.equalTo(43.5)
        }

        topLineViwe.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.bgView)
            make.top.equalTo(self.bgView).offset(0)
            make.height.equalTo(0.5)
        }

        bottomLineView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(self.bgView)
            make.height.equalTo(0.5)
        }

        self.preLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.bgView).offset(15)
//            make.width.equalTo(81)
            make.centerY.equalTo(self.bgView)
//            make.right.equalTo(self.textField.snp_leftMargin)
        }

//
        self.textField.addTarget(self, action: #selector(changedTextField(textField:)), for: .editingChanged)
//        self.textField.becomeFirstResponder()

        self.textField.snp.makeConstraints { (make) in
            make.left.equalTo(self.preLabel.snp.right)
            make.right.equalTo(self.bgView).offset(-30)
            make.centerY.equalTo(self.bgView)
        }

        self.tipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(15)
            make.right.equalTo(self.view).offset(-30)
            make.top.equalTo(self.bgView.snp.bottom).offset(9)
        }

        self.testLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.bgView.snp.bottom).offset(16)
            make.left.equalTo(self.view).offset(15)
            make.right.equalTo(self.view).offset(-30)
        }

        self.checkView.snp.makeConstraints { (make) in
            make.top.equalTo(self.bgView.snp.bottom).offset(16)
            make.left.equalTo(self.view).offset(15)
            make.right.equalTo(self.view).offset(-30)
        }

        self.activityIndicatorView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.width.equalTo(24)
        }

        checkLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.activityIndicatorView.snp.right)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
   
    @objc func changedTextField(textField: UITextField) {
//        if textField.text?.removeAllSapce.count ?? 0 > 0{
//            self.testLabel.isHidden = false
//            if textField.text?.removeAllSapce.count ?? 0 > 32 {
//                self.testLabel.text  = "频道名称字符长度超过最大限制"
//                self.testLabel.textColor = UIColor.init(hexString: "#BE3E38")
//            }else{
//                self.testLabel.text  = (textField.text ?? "") + "可用"
//                self.testLabel.textColor = UIColor.init(hexString: "#4B953C")
//                self.publicUrlStr = textField.text ?? ""
//            }
//            self.tipLabel.snp.remakeConstraints { (make) in
//                make.left.equalTo(self.view).offset(15)
//                make.right.equalTo(self.view).offset(-30)
//                make.top.equalTo(self.testLabel.snp.bottom).offset(12)
//            }
//        }else{
//            self.testLabel.isHidden = true
//            self.tipLabel.snp.remakeConstraints { (make) in
//                make.left.equalTo(self.view).offset(15)
//                make.right.equalTo(self.view).offset(-30)
//                make.top.equalTo(self.bgView.snp.bottom).offset(9)
//            }
//        }
        self.publicUrlStr = textField.text ?? ""
    }
    
    func setUpBottomView() {
        let topLineView = UIView.init()
        topLineView.backgroundColor = UIColor.init(hexString: kSepLineColorS)
        
        let bottomLineView = UIView.init()
        bottomLineView.backgroundColor = UIColor.init(hexString: kSepLineColorS)
        self.view.addSubview(self.bottomView)
        self.bottomView.snp.makeConstraints { (make) in
            make.top.equalTo(self.tipLabel.snp.bottom).offset(43 )
            make.left.right.equalToSuperview()
            make.height.equalTo(131)
        }
        
        let nameArray = [
            NSLocalizedString("拷贝链接", comment: ""),
            NSLocalizedString("刷新链接", comment: ""),
            NSLocalizedString("分享链接", comment: "")
        ]
        let tag: Int = 100
        var lastView = topLineView
        self.bottomView.addSubviews([topLineView,bottomLineView])
        topLineView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        bottomLineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        
        for (index, nameString) in nameArray.enumerated()  {
            
            let control = UIControl.init()
            control.tag = tag + index
            control.addTarget(self, action: #selector(controlAction(control:)), for: .touchUpInside)
            
            let textLabel = UILabel(frame: CGRect.zero)
            textLabel.textColor = UIColor.init(hexString: kSubmitBtnBgColorS)
            textLabel.font = UIFont.systemFont(ofSize: 17)
            textLabel.text = nameString
            
            self.bottomView.addSubviews([control,textLabel])
            control.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(lastView.snp.bottom)
                make.height.equalTo(43.5)
            }
            
            textLabel.snp.makeConstraints { (make) in
                make.left.equalTo(self.bottomView).offset(15)
                make.centerY.equalTo(control)
            }
            lastView = control
            if nameString != nameArray.last ?? "" {
                let lineView = UIView.init()
                lineView.backgroundColor = UIColor.init(hexString: kSepLineColorS)
                self.bottomView.addSubviews([lineView])
                lineView.snp.makeConstraints { (make) in
                    make.left.equalTo(self.bottomView).offset(15)
                    make.height.equalTo(0.5)
                    make.right.equalToSuperview()
                    make.bottom.equalTo(control)
                }
            }
            
        }
        
    }
    
    
}

extension CODChannelTypeVC{
    
    @objc func controlAction(control: UIControl){
        
        switch control.tag {
        case 100:
            self.copyAction()
        break
        case 101:
            self.revokeAction()
        break
        default:
            self.shareAction()
        break
        }
    }
    
    @objc func publicControlAction() {
        
        self.bottomView.isHidden = true
        
        if self.privateImageView.isHidden {
            return
        }
        
        self.publicClick()


    }
    
    func publicClick()  {
        self.publicImageView.isHidden = false
        self.privateImageView.isHidden = true
        
        self.ruleLabel.text = NSLocalizedString("公开频道可以被搜索，任何人都可以加入。", comment: "")
        preLabel.snp.remakeConstraints { (make) in
            make.left.equalTo(bgView).offset(15)
//            make.width.equalTo(81)
            make.centerY.equalTo(bgView)
//            make.right.equalTo(self.textField.snp_leftMargin)
        }

        self.textField.snp.updateConstraints { (make) in
            make.left.equalTo(preLabel.snp.right)
            make.right.equalTo(bgView).offset(-30)
            make.centerY.equalTo(bgView)
        }
        preLabel.text = CODAppInfo.channelSharePublicLink
//        self.textField.isEnabled = true
        self.textField.isHidden = false
        self.textField.text = self.publicUrlStr
        
//        self.textField.becomeFirstResponder()
        self.channelType = .CPUB
    }
    
    @objc func privateControlAction() {
        if self.publicImageView.isHidden {
            return
        }
        
        if vcType == .edit {
            self.bottomView.isHidden = false
        }
        

        self.publicImageView.isHidden = true
        self.privateImageView.isHidden = false
        self.ruleLabel.text = NSLocalizedString("私人频道只能通过邀请链接加入。", comment: "")
        preLabel.snp.remakeConstraints { (make) in
            make.left.equalTo(bgView).offset(15)
            make.width.equalTo(KScreenWidth - 27)
            make.centerY.equalTo(bgView)
        }

        self.textField.snp.updateConstraints { (make) in
            make.left.equalTo(preLabel.snp.right)
            make.right.equalTo(bgView).offset(-30)
            make.centerY.equalTo(bgView)
        }
        preLabel.text = CODAppInfo.channelSharePrivateLink + (self.privateUrl)
        self.textField.isHidden = true
        self.textField.resignFirstResponder()
        self.channelType = .CPRI
    }
    
    func copyAction() {
        
        UIPasteboard.general.string = preLabel.text
        
        CODAlertVcPresent(confirmBtn: NSLocalizedString("好", comment: ""), message: NSLocalizedString("邀请链接已复制到剪贴板。", comment: ""), title: "", cancelBtn: "", handler: { (action) in
            if action.style == .default{
            }
        }, viewController: self)
    }
    
    func revokeAction() {
        CODAlertVcPresent(confirmBtn: NSLocalizedString("确定", comment: ""), message: NSLocalizedString("我们将生成一个新的邀请链接，设置完成后原有链接将失效", comment: ""), title: "", cancelBtn: NSLocalizedString("取消", comment: ""), handler: { [weak self] (action) in
            
            guard let `self` = self else { return }
            
            if action.style == .default{
                self.generatePrivateUserId()
            }
        }, viewController: self)
    }
    
    func shareAction() {
        
        var linkUrl = ""
        
        if channelType == .CPUB {
            linkUrl = CODAppInfo.channelSharePublicLink + self.publicUrlStr
        } else {
            linkUrl = CODAppInfo.channelSharePrivateLink + self.privateUrl
        }
        let shareView = CODShareImagePicker(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
        shareView.contactListArr = CODGlobalDataSource.getContactGroupChannelModelData(isHeadCloudDisk: true, ignoreIDs: [NewFriendRosterID])
        shareView.shareText = linkUrl
        shareView.fromType = .Chat
        shareView.show()
    }
    
}
