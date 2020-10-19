//
//  MessageViewController+CODMessageSearchResultView.swift
//  COD
//
//  Created by 1 on 2019/8/27.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Foundation

extension MessageViewController:CODMessageSearchResultViewDelegate{
    
    func nextPage(currentPage: Int) {
        self.clickPage(currentPage: currentPage)
    }
    
    func previousPage(currentPage: Int) {
        self.clickPage(currentPage: currentPage)
    }
    
    func clickPage(currentPage: Int) {
        let cellIndex = self.searchDatas.count - currentPage
        if cellIndex >= 0 {
            let searchMessage = self.searchDatas[cellIndex]
            self.scrollToSearchMessage(message: searchMessage)
        }
    }
    
    func dateAction() {
        
        let currentDate = TimeTool.getCurrentDay()
        RPicker.selectDate(title: "", hideCancel: false, minDate: currentDate.beforeYearsByCurrentDate(-3), maxDate: currentDate, didSelectDate: {[weak self] (selectedDate) in
            let temp = Int(selectedDate.timeIntervalSince1970 * 1000)
            self?.searchMessageDate(temp: temp)
        })
        self.view.resignFirstResponder()
        self.view.endEditing(true)
        if let cancleButton = self.searchBar.value(forKey: "cancelButton") as? UIButton {
            cancleButton.isEnabled = true
        }
    }
    
    func groupMemberAction() {
        self.setSearchLeftView(isMember: true)
        if self.memberToolView.chatId == 0 {
            self.memberToolView.chatId = self.chatId
        }
        self.memberToolView.nameString = ""
    }
    
    @objc func cancleAction(){
        print("quxiao")
    }
    
}
extension MessageViewController: UISearchBarDelegate{
    ///开始编辑
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //开始
        self.isSearch = true
        UIView.animate(withDuration: 0.25, animations: {
            self.navigationController?.navigationBar.isHidden = true
            var view_frame = self.view.frame
            view_frame.origin.y = CGFloat(KNAV_STATUSHEIGHT)
            view_frame.size.height = KScreenHeight - CGFloat(KNAV_STATUSHEIGHT)
            self.view.frame = view_frame
            self.view.setNeedsLayout()
            self.view.setNeedsUpdateConstraints()
        }) { (finished) in
            searchBar.showsCancelButton = true
            searchBar.setCancelButton()
        }
        self.updateTopMessageView()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        ///取消
        self.initSearchView()
        self.initSearchToolView()
        self.initMemberToolView()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        if searchBar.text?.count == 0 {
            return true
        }
        
        if self.memberToolView.isHidden == false {
            return true
        }

        self.haveChangeText(searchString: searchBar.text ?? "")
        return true
    }
    /* 点击了清空文字按钮 */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchDatas.removeAll()
        if  self.currentSearchModel != nil {
            
            self.setSearchBarTextColor()
        }else if !self.memberToolView.isHidden || self.memberToolView.chatId  != 0{
            
            if searchText.count == 0 && self.searchBar.text?.removeHeadAndTailSpacePro.count == 0 {
                if self.memberToolView.nameString.removeHeadAndTailSpacePro.count != 0 {
                    self.memberToolView.nameString = searchBar.text ?? ""
                }else{
                    self.setSearchLeftView(isMember: false)
                }
                return
            }else{
                self.memberToolView.nameString = searchBar.text ?? ""
            }
        }else{
            if self.searchBar.text?.count == 0 {
                self.setSearchLeftView(isMember: false)
            }
            ///搜索消息
            self.searchMessage()
        }
        
    }
    
    /*点击搜索*/
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        ///搜索模式
        self.isSearch = true
        ///关闭编辑
        searchBar.endEditing(true)
        ///搜索消息
        if self.memberToolView.isHidden || self.isCloudDisk {
            self.searchMessage()
        }else{
            self.memberToolView.nameString = searchBar.text ?? ""
        }
        self.memberToolView.chatId = 0
//        self.setSearchLeftView(isMember: false)
        self.updateTopMessageView()
        
    }
    
    @objc func textFieldDidDeleteBackward(){
        if self.searchBar.text?.removeHeadAndTailSpacePro.count == 0 && self.memberToolView.chatId > 0{
            if self.memberToolView.nameString.count != 0 {
                self.memberToolView.nameString = searchBar.text ?? ""
            }else{
                self.setSearchLeftView(isMember: false)
            }
        }
    }
    
    ///内容变化
    @objc func textFieldChanged(textField:UITextField) {
        
        if textField.text?.count == 0 {
            return
        }
        self.haveChangeText(searchString: textField.text ?? "")
        
    }
    
    func searchMessage() {
        if searchBar.text == self.currentSearchString && searchBar.text != "" {
            return             
        }
        self.searchDatas.removeAll()
        if self.searchBar.text?.removeAllSapce.count ?? 0 > 0{
            
            if let groupModel = self.currentSearchModel {
                
                let nickName: String = " " + groupModel.getMemberNickName() + " "
                var searchString = nickName
                if self.searchBar.text?.contains(nickName) ?? false {
                    searchString = self.searchBar.text!.components(separatedBy: nickName).last ?? ""
                }
                
                self.searchDatas = CODChatHistoryRealmTool.searchMessageByMember(from: self.chatId, textStr: searchString, fromJID: groupModel.jid) ?? []
                self.searchToolView.totalPage = self.searchDatas.count
                if self.searchDatas.count == 0{
                    
                    self.searchToolView.totalPage = 0
                    self.searchToolView.pageLabelString = "无搜索结果"
                }else{
                    
                    if let searchModel: CODMessageModel = self.searchDatas.first {
                        
                        CODProgressHUD.showWithStatus(nil)
                        self.messageView.messageDisplayViewVM.getLocalHistoryList(beginTime: searchModel.datetime, endTime: self.messageView.messageDisplayViewVM.lastMessageDataTime.string) {[weak self] (vms) in
                            CODProgressHUD.dismiss()
                            guard let `self` = self else {
                                return
                            }
                            self.messageView.messageDisplayViewVM.appendChatCellVMs(cellVms: vms)
                            self.scrollToSearchMessage(message: searchModel)
                            self.searchToolView.currentPage =  1
                        }
                        

                    }
                }
            }else{
                
                self.searchDatas = CODChatHistoryRealmTool.searchMessageContainFile(from: self.chatId, textStr: self.searchBar.text ?? "") ?? []
                self.searchToolView.totalPage = self.searchDatas.count
                
                if self.searchDatas.count == 0{
                    
                    self.searchToolView.totalPage = 0
                    self.searchToolView.pageLabelString = "无搜索结果"
                }else{
                    
                    if let searchModel: CODMessageModel = self.searchDatas.last {
                        
                        self.scrollToSearchMessage(message: searchModel)
                        self.searchToolView.currentPage =  1
                    }
                }
                
            }
        }else{
            
            self.searchToolView.totalPage = 0
            self.searchToolView.pageLabelString = ""
        }
        if self.chatType != .groupChat || self.searchDatas.count > 0 {
           
           self.searchToolView.memberBtn.isHidden = true
       }
        if self.searchDatas.count > 1,
            let last = self.searchDatas.last, let first = self.searchDatas.first {
            
            if self.messageView.messageDisplayViewVM.contains(msgTime: first.datetimeInt) == false {
                
                CODProgressHUD.showWithStatus(nil)
                self.messageView.messageDisplayViewVM.getLocalHistoryList(beginTime: first.datetime, endTime: self.messageView.messageDisplayViewVM.lastMessageDataTime.string) { [weak self] (VMs) in
                    
                    guard let `self` = self else {
                        CODProgressHUD.dismiss()
                        return
                    }
                    
                    self.messageView.messageDisplayViewVM.appendChatCellVMs(cellVms: VMs)
                    
                    if let indexPath = self.messageView.messageDisplayViewVM.findIndexPath(messageId: last.msgID) {
                        CODProgressHUD.dismiss()
                        self.messageView.flashingCell(indexPath: indexPath)
                        
                    } else {
                        CODProgressHUD.dismiss()
                    }
                    

                }
                
            } else {
                
                if let indexPath = self.messageView.messageDisplayViewVM.findIndexPath(messageId: last.msgID) {
                    self.messageView.flashingCell(indexPath: indexPath)
                }
                
            }
            

        } else if self.searchDatas.count == 1  {
            
            if let indexPath = self.messageView.messageDisplayViewVM.findIndexPath(messageId: self.searchDatas[0].msgID) {
                self.messageView.flashingCell(indexPath: indexPath)
            }
            
        }
        
    }
    
    func getMessageIndePath(messages: Array<CODMessageModel>) -> Array<Int> {
        
        var indexs:Array<Int> = []
        for message in messages {
            if let indexPath = self.getMessageCellRow(message: message) {
                indexs.append(indexPath)
            }
        }
        
        return indexs
    }
    
    func searchMessageDate(temp: Int) {
        self.searchDatas.removeAll()
        
    /// 服务器迁移到mango后在放开
//        CODProgressHUD.showWithStatus(nil)
//        self.messageView.messageDisplayViewVM.getRemoteHistoryList(toDate: "\(temp)") { [weak self] (cellVM) in
//
//            guard let `self` = self else { return }
//
//            CODProgressHUD.dismiss()
//
//            self.messageView.messageDisplayViewVM.appendChatCellVMs(cellVms: cellVM)
//            self.messageView.scrollToTopMessage()
//        }
        
        CODProgressHUD.showWithStatus(nil)
        
        self.messageView.messageDisplayViewVM.getLocalHistoryList(beginTime: "\(temp)", endTime: "\(self.messageView.messageDisplayViewVM.lastMessageDataTime)") { [weak self] (cellVM) in
            
            CODProgressHUD.dismiss()
            guard let `self` = self else { return }
                    
            self.messageView.messageDisplayViewVM.appendChatCellVMs(cellVms: cellVM)
            
            if let indexPath = self.messageView.messageDisplayViewVM.findIndexPath(datatime: temp) {
                self.messageView.scrollToMessage(index: indexPath.row, at: .bottom)
            } else {
                self.messageView.scrollToTopMessage()
            }
                        
        }

    }
    
    func setSearchLeftView(isMember: Bool) {
        self.searchBar.customTextField?.leftViewMode = .always
        self.searchBar.customTextField?.contentMode = .center
        if isMember {
            self.leftSearchView.isHiddenLable(isHidden: false)
            self.memberToolView.isHidden = false
            if self.memberToolView.chatId == 0 {
                if #available(iOS 13.0, *) {
                    self.searchBar.searchTextField.contentHorizontalAlignment = .center
                    self.searchBar.searchTextField.contentVerticalAlignment = .center
                    //这里一定要新创建一个View才能添加上去
                    self.searchBar.customTextField?.leftView = self.createLeftView(isHidden: false)
                    self.searchBar.placeholder = NSLocalizedString("搜索成员", comment: "")
                    
                }else{
                    self.leftSearchView.frame = CGRect(x: 0, y: 0, width: 55, height: 44)
                    self.searchBar.textField?.leftView =  self.leftSearchView
                    self.searchBar.placeholder = NSLocalizedString("搜索成员", comment: "")
                }
                self.searchToolView.memberBtn.isHidden = true
                self.searchToolView.dateBtn.isHidden = true
            }
            self.searchBar.layoutIfNeeded()
        }else{
            self.leftSearchView.isHiddenLable(isHidden: true)
            self.leftSearchView.frame = CGRect(x: 0, y: 0, width: 16, height: 20)
            if #available(iOS 13.0, *) {
                self.searchBar.customTextField?.leftView = self.createLeftView(isHidden: true)
            }else{
                self.searchBar.customTextField?.leftView = self.leftSearchView
            }
            
            self.searchBar.placeholder = NSLocalizedString("搜索此对话", comment: "")
            self.memberToolView.chatId = 0
            self.searchToolView.memberBtn.isHidden = false
            self.searchToolView.dateBtn.isHidden = false
            self.memberToolView.isHidden = true
            self.searchBar.layoutIfNeeded()
        }
        
        if self.chatType != .groupChat {
            
           self.searchToolView.memberBtn.isHidden = true
        }
    }
    
    func createLeftView(isHidden: Bool) -> UIView{
        
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 55, height: 44))
        view.contentMode = .scaleAspectFit
        
        if isHidden {
            view.frame = CGRect(x: 0, y: 11, width: 16, height: 20)
            view.layer.contents = UIImage.init(named: "member_search")?.cgImage
        }else{
            view.layer.contents = UIImage.getChatSearchLeftIconName()?.cgImage
        }
        return view
    }
}

extension MessageViewController:CODMemberDisplayViewDelegate{
    
    func cellDidSelectMember(groupModel: CODGroupMemberModel) {
        
        self.currentSearchModel = groupModel
        let nickName: String = " " + groupModel.getMemberNickName() + " "

        if let text = self.searchBar.text, text.firstCharacterAsString != " " {
            self.searchBar.text = nickName + text
            self.searchMessage()
        } else {
            self.searchBar.text = nickName
        }
                
        self.setSearchBarChooseMemberColor(nickName: nickName)
        self.memberToolView.isHidden = true
    }
    

}

extension MessageViewController{
    func setSearchBarTextColor() {
        
        if let groupModel = self.currentSearchModel {
            let nickName: String = " " + groupModel.getMemberNickName() + " "
            if self.searchBar.text?.hasPrefix(nickName) ?? false {
                self.setSearchBarChooseMemberColor(nickName: nickName)
            }else{
                self.setSearchBarCustomrColor(nickName: nickName)
                self.currentSearchModel = nil
           }
       }
    }
    
    func setSearchBarChooseMemberColor(nickName: String) {
        
        let string = NSMutableAttributedString(string: self.searchBar.text ?? "")
        string.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: kSubmitBtnBgColorS) ?? UIColor.black], range: NSMakeRange(0,nickName.count - 1))
        string.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], range: NSMakeRange(nickName.count - 1,self.searchBar.text!.count - nickName.count))
        self.searchBar.customTextField?.attributedText = string
    }
    
    func setSearchBarCustomrColor(nickName: String) {
        
        let string = NSMutableAttributedString(string: self.searchBar.text ?? "")
        string.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], range: NSMakeRange(0,self.searchBar.text!.count))
        self.searchBar.customTextField?.attributedText = string
        self.currentSearchModel = nil
    }
    
    func initSearchView() {
        
        self.searchBar.endEditing(true)
        self.searchBar.showsCancelButton = false
        searchBar.text = ""
        self.isSearch = false
        self.leftSearchView.isHiddenLable(isHidden: true)
        self.setSearchLeftView(isMember: false)
    }
    
    func initSearchToolView() {
        
        self.searchToolView.totalPage = 0
        self.searchToolView.pageLabelString = ""
        if self.chatType == .groupChat {
            self.searchToolView.dateBtn.isHidden = false
            self.searchToolView.memberBtn.isHidden = false
        }else{
            self.searchToolView.memberBtn.isHidden = true
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.navigationController?.navigationBar.isHidden = true
            var view_frame = self.view.frame
            view_frame.origin.y = CGFloat(KNAV_HEIGHT)
            view_frame.size.height = KScreenHeight - CGFloat(KNAV_HEIGHT)
            self.view.frame = view_frame
            self.searchBar.isHidden = true
            self.searchToolView.isHidden = true
            self.chatBar.isHidden = false
            self.chatBar.textView.resignFirstResponder()
        }) { (finished) in
            self.navigationController?.navigationBar.isHidden = false
            self.searchBar.showsCancelButton = false
        }
        self.updateTopMessageView()
    }
    
    func initMemberToolView() {
        
        self.currentSearchModel = nil
        self.memberToolView.nameString = ""
//        if self.chatType == .groupChat {
            self.memberToolView.isHidden = true
            self.memberToolView.chatId = 0
//        }
    }
    
    func haveChangeText(searchString: String) {
        
        self.isSearch = true
        if self.currentSearchModel != nil {
            
            self.setSearchBarTextColor()
        }else if !self.memberToolView.isHidden || self.memberToolView.chatId != 0{
            
            if self.searchBar.text?.count == 0 {
                self.setSearchLeftView(isMember: false)
            }
            self.memberToolView.nameString = searchString
        }else{
            ///搜索消息
            self.searchMessage()
        }
        self.updateTopMessageView()
    }
    
    func updateMessageView(searchModel: CODMessageModel) {
        
        
    }
}


