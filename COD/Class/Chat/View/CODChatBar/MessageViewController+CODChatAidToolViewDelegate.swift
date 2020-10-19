//
//  MessageViewController+CODChatAidToolViewDelegate.swift
//  COD
//
//  Created by 1 on 2019/8/27.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

extension MessageViewController:CODChatAidToolViewDelegate{
    
    //搜索
    func searchClick() {
        print("搜索")
        self.searchBar.isHidden = false
        self.searchBar.becomeFirstResponder()
        self.searchToolView.isHidden = !self.searchToolView.isHidden
        self.chatBar.isHidden = !self.searchToolView.isHidden
        self.editView.isHidden = true
        self.updateMessageView()
        self.dismissToolView()
        self.dismisskeyboard()
    }
    
    //免打扰
    func donotdisturClick(button: UIButton) {
        
        if chatType == .groupChat || chatType == .privateChat {
            
            var dict = ["name":COD_changeGroup,
                        "requester":UserManager.sharedInstance.jid,
                        "itemID":self.chatId,
                        "setting":["mute":button.isSelected]] as [String : Any]
            if !self.isGroupChat {
                dict["name"] = COD_changeChat
            }
            let iq = CustomUtil.xmppIQWithType(type: XMPPIQ.IQType.set, xmlns: COD_com_xinhoo_setting, actionDic: dict as NSDictionary)
            XMPPManager.shareXMPPManager.xmppStream.send(iq)
            self.dismissToolView()
            
        } else if chatType == .channel {
            XMPPManager.shareXMPPManager.channelSetting(roomID: self.chatId, mute: button.isSelected)
        }
        
        
    }
    
    //打电话
    func callClick() {
        self.vioceCall(callType: COD_call_type_voice)
        self.dismissToolView()
    }
    
    //联系人信息
    func aboutClick() {
        self.dismissToolView()
        self.navRightClick()
    }
    
}
extension MessageViewController{
    
    @objc func titleBackGroupViewTap() {
        if self.chatId > 0 {
            if self.isSearch {
                self.searchBar.becomeFirstResponder()
                return
            }
            self.toolView.isHidden  = false
            self.topMessageView.isHidden = true
            self.inCallView.isHidden = true
            self.dismisskeyboard()
            let offset = 0
            if self.isShowToolView {
                self.dismissToolView()
            }else{
                UIView.animate(withDuration: 0.1, animations: {
                    self.toolView.snp.remakeConstraints({ (make) in
                        make.top.equalTo(self.view).offset(offset)
                        make.left.right.equalTo(self.view)
                        make.height.equalTo(54)
                    })
                })
                self.isShowToolView = !self.isShowToolView
            }

        }else{
            self.pushToShareMediaVC()
        }
    }
    
    func pushToShareMediaVC() {
        let vc = SharedMediaFileViewController.init(nibName: "SharedMediaFileViewController", bundle: nil)
        vc.chatId = CloudDiskRosterID
        vc.isCloudDisk = true
        vc.title = NSLocalizedString("共享媒体", comment: "")
        vc.list = self.chatListModel?.chatHistory?.messages
        self.navigationController?.pushViewController(vc, animated: true)
    }
  
    func dismissToolView() {
        self.updateTopMessageView()
        self.updateInCallView()
        
        self.toolView.isHidden  = true
        UIView.animate(withDuration: 0.1, animations: {
            self.toolView.snp.remakeConstraints({ (make) in
                make.top.equalTo(self.view).offset(-54)
                make.left.right.equalTo(self.view)
                make.height.equalTo(54)
            })
        })
         self.isShowToolView = false
    }
    func hideSearchToolView()  {
        if self.isSearch {
            self.dismissToolView()
            self.dismisskeyboard()
            self.searchBarCancelButtonClicked(self.searchBar)
            
        }
     
    }
}

