//
//  TransmitSelectPersonViewController.swift
//  COD
//
//  Created by xinhooo on 2019/8/12.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class TransmitSelectPersonViewController: BaseViewController {

    let contactCtl = ContactsViewController()
    let chatCtl = ChatViewController()
    var currentVC:UIViewController?
    
    var messages = Array<CODMessageModel>()
    
    typealias ChooseChatListCompeleteBlock = (_ model: CODChatListModel) -> Void ///选择聊天列表
    public var chooseChatListBlock:ChooseChatListCompeleteBlock?
    
    typealias ChoosePersonCompeleteBlock = (_ model: CODContactModel) -> Void ///选择联系人
    public var choosePersonBlock: ChoosePersonCompeleteBlock?
    
    typealias ChooseGroupCompeleteBlock = (_ model: CODGroupChatModel) -> Void ///选择群
    public var chooseGroupBlock: ChooseGroupCompeleteBlock?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewBottomConstrains: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.definesPresentationContext = true
        self.extendedLayoutIncludesOpaqueBars = true
        
        self.navigationItem.title = NSLocalizedString("转发", comment: "")
        self.setBackButton()        
        self.chatCtl.type = .selectPerson
        self.chatCtl.searchActionDelegate = self
        self.chatCtl.chooseChatListBlock = { [weak self] (chatListModel) in
            
            if self?.chooseChatListBlock != nil {
                self?.chooseChatListBlock!(chatListModel)
//                self?.navigationController?.popViewController()
            }
        }
        
        self.chatCtl.choosePersonBlock = { [weak self] (contactModel) in
            
            if self?.choosePersonBlock != nil {
                self?.choosePersonBlock!(contactModel)
//                self?.navigationController?.popViewController()
            }
        }
        
        self.chatCtl.chooseGroupBlock = { [weak self] (groupModel) in
            if self?.chooseGroupBlock != nil {
                self?.chooseGroupBlock!(groupModel)
//                self?.navigationController?.popViewController()
            }
        }
        
        self.contactCtl.type = .selectPerson
        self.contactCtl.searchActionDelegate = self
        self.contactCtl.choosePersonBlock = { [weak self] (contactModel) in
            if self?.choosePersonBlock != nil {
                self?.choosePersonBlock!(contactModel)
//                self?.navigationController?.popViewController()
            }
        }
        
        self.contactCtl.chooseGroupBlock = {[weak self] (groupModel) in
            if self?.chooseGroupBlock != nil {
                self?.chooseGroupBlock!(groupModel)
//                self?.navigationController?.popViewController()
            }
        }
        
        self.addChild(chatCtl)
        self.addChild(contactCtl)
        self.view.addSubview(chatCtl.view)
        currentVC = chatCtl
        chatCtl.view.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalToSuperview().offset(self.bottomView.height + UIApplication.shared.statusBarFrame.height + self.view.safeAreaInsets.top)
            } else {
                make.top.equalToSuperview().offset(self.bottomView.height + UIApplication.shared.statusBarFrame.height)
                // Fallback on earlier versions
            }
            make.bottom.equalTo(self.bottomView.snp.top).offset(0)
        }
        
        
        self.rightTextButton.setTitle(NSLocalizedString("选择", comment: ""), for: .normal)
        self.rightTextButton.setTitleColor(UIColor.init(hexString: kSubmitBtnBgColorS), for: .normal)
        self.rightTextButton.setImage(nil, for: .normal)
        self.setRightTextButton()
    }

    override func navRightTextClick() {
        let vc = TransmitMultiSelectViewController(nibName: "TransmitMultiSelectViewController", bundle: Bundle.main)
        vc.messages = self.messages
        vc.modalPresentationStyle = .overFullScreen
        
        vc.dismissBlock = { [weak self] in
            
            self?.navigationController?.popViewController(animated: true, {
                CODProgressHUD.showSuccessWithStatus(NSLocalizedString("已转发", comment: ""))
            })
        }
        
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func segmentAction(_ sender: Any) {
        
        switch self.segmentedControl.selectedSegmentIndex {
        case 0:
            
            self.transition(from: currentVC!, to: chatCtl, duration: 0, options: .curveLinear, animations: nil) { [weak self] (finish) in
                guard let `self` = self else {
                    return
                }
                self.currentVC = self.chatCtl
                self.chatCtl.view.snp.makeConstraints({ (make) in
                    make.left.right.equalToSuperview()
                    if #available(iOS 11.0, *) {
                        make.top.equalToSuperview().offset(self.view.safeAreaInsets.top)
                    } else {
                        make.top.equalToSuperview()
                        // Fallback on earlier versions
                    }
                    make.bottom.equalTo(self.bottomView.snp.top).offset(0)
                })
            }
            
            break
        case 1:
            self.transition(from: currentVC!, to: contactCtl, duration: 0, options: .curveLinear, animations: nil) { [weak self] (finish) in
                guard let `self` = self else {
                    return
                }
                self.currentVC = self.contactCtl
                self.contactCtl.view.snp.makeConstraints({ (make) in
                    make.left.right.equalToSuperview()
                    if #available(iOS 11.0, *) {
                        make.top.equalToSuperview().offset(self.view.safeAreaInsets.top)
                    } else {
                        make.top.equalToSuperview()
                        // Fallback on earlier versions
                    }
                    make.bottom.equalTo(self.bottomView.snp.top).offset(0)
                })
            }
            break
        default:
            break
        }
        
    }
    
    func setBottomViewHidden(_ hidden: Bool) {
        if hidden {
            UIView.animate(withDuration: 0.3) {
                self.bottomViewBottomConstrains.constant = -78.0
            }
        }else{
            UIView.animate(withDuration: 0.3) {
                self.bottomViewBottomConstrains.constant = 0.0
            }
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    deinit {
        print("单选转发控制器销毁了")
    }
    
}

extension TransmitSelectPersonViewController: ChatViewSearchActionDelegate {
    func startSearchAction() {
        self.setBottomViewHidden(true)
    }
    
    func endSearchAction() {
        self.setBottomViewHidden(false)
    }
}

extension TransmitSelectPersonViewController: contactsViewSearchActionDelegate {
    func startSearchEvent() {
        self.setBottomViewHidden(true)
    }
    
    func endSearchEvent() {
        self.setBottomViewHidden(false)
    }
}


