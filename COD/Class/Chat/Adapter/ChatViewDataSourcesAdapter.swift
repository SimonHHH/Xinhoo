//
//  ChatViewDataSourcesAdapter.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxDataSources
import MJRefresh

class ChatViewDataSourcesAdapter<Section: SectionVMType>: TableViewDataSourcesAdapter<Section>, MGSwipeTableCellDelegate {
    
    override func configureCell(dataSource: TableViewSectionedDataSource<Section> , tableView: UITableView, indexPath: IndexPath, item: Section.Item) -> UITableViewCell {
        
        let cell = super.configureCell(dataSource: dataSource, tableView: tableView, indexPath: indexPath, item: item)
        
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        return cell
        
    }
    
    override func canEditRowAtIndexPath(dataSource: TableViewSectionedDataSource<Section>, indexPath: IndexPath) -> Bool {
        
        if let vm = self.dataSources.value[indexPath.section].items[indexPath.row] as? ChatCellVM {
            
            if vm.messageModel.type == .notification || vm.messageModel.type == .newMessage {
                return false
            } else {
                return true
            }
            
        }
        
        return false
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        hiddenGoToNewMessageView(willDisplay: cell)
        
        guard let pageVM = self.pageVM as? CODChatMessageDisplayPageVM else {
            return
        }
        
        guard let baseCell = cell as? CODBaseChatCell else {
            return
        }
        
        guard let cellVM = self.dataSources.value[indexPath.section].items[indexPath.row] as? ChatCellVM else {
            return
        }
        
        guard let view = self.delegate as? CODChatMessageDisplayView else {
            return
        }
        
        if cell.isKind(of: CODShowNewMessageCell.self) {
            tableView.reloadRows(at: [IndexPath(row: indexPath.row - 1, section: indexPath.section)], with: .none)
        }
        
        cellVM.cellHeight = cell.height
        baseCell.delegate = self
        
        
        if pageVM.rpIndexPath.value?.row == indexPath.row {
            pageVM.rpIndexPath.accept(nil)
            baseCell.flashingCell()
        }
        
        if let atIndexPath =  view.flashingPath, indexPath.row == atIndexPath.row {
            baseCell.flashingCell()
            view.flashingPath = nil
        }
        
        
        if tableView.isEditing {
            
            if cellVM.isSelect {
                
                if cellVM.messageModel.type == .voiceCall || cellVM.messageModel.type == .videoCall {
                    view.selectedCallTypeMsgCount += 1
                }
                
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        
    }
    
    func hiddenGoToNewMessageView(willDisplay cell: UITableViewCell) {
        
        guard let view = self.delegate as? CODChatMessageDisplayView else {
            return
        }
        
        if !cell.isKind(of: CODShowNewMessageCell.self) {
            return
        }
        
        view.newMessageCount = 0
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let view = self.delegate as? CODChatMessageDisplayView else {
            return
        }
        
        view.scrollViewDidScroll(scrollView)
        
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        guard let view = self.delegate as? CODChatMessageDisplayView else {
            return
        }
        
        
        
        view.scrollViewDidEndDecelerating(scrollView)
        
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let view = self.delegate as? CODChatMessageDisplayView else {
            return
        }
        
        view.scrollViewWillBeginDragging(scrollView)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let view = self.delegate as? CODChatMessageDisplayView else {
            return
        }
        
        view.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    override func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        guard let view = self.delegate as? CODChatMessageDisplayView else {
            return true
        }
        
        return view.scrollViewShouldScrollToTop(scrollView)
    }
    

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        guard let view = self.delegate as? CODChatMessageDisplayView,
        let cellVM = self.dataSources.value[indexPath.section].items[indexPath.row] as? ChatCellVM else {
            return
        }

        
        if tableView.isEditing {
            
            if cellVM.messageModel.type == .notification || cellVM.messageModel.type == .newMessage {
                return
            }
            
            if cellVM.messageModel.type == .voiceCall || cellVM.messageModel.type == .videoCall {
                view.selectedCallTypeMsgCount -= 1
            }
            
            cellVM.isSelect = false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let view = self.delegate as? CODChatMessageDisplayView,
        let cellVM = self.dataSources.value[indexPath.section].items[indexPath.row] as? ChatCellVM else {
            return
        }
        
        if tableView.isEditing{
            
            if cellVM.messageModel.type == .newMessage || cellVM.messageModel.type == .notification {
                return
            }
            if cellVM.messageModel.type == .voiceCall || cellVM.messageModel.type == .videoCall {
                view.selectedCallTypeMsgCount += 1
            }
            cellVM.isSelect = true

        }
    }
    
    
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        
        if cell.isKind(of: Xinhoo_CallLeftTableViewCell.classForCoder()) || cell.isKind(of: Xinhoo_CallRightTableViewCell.classForCoder()){
            return false
        }
        
        guard let view = self.delegate as? CODChatMessageDisplayView else {
            return false
        }
        
        if let cell = cell as? CODBaseChatCell {
            if cell.messageModel.type == .unknown { return false }
        }
        if view.chatType == .channel {
            let channleResult = CustomUtil.judgeInChannelRoom(roomId: view.chatId)
            if channleResult.isManager {
                return true
            }else{
                return false
            }
        }
        if !CustomUtil.judgeInGroupRoomCanSpeak(roomId: view.chatId) {
            return false
        }
        return true && !view.isCloudDisk ;
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        
        guard let view = self.delegate as? CODChatMessageDisplayView else {
            return nil
        }
        
        swipeSettings.transition = MGSwipeTransition.border;
        expansionSettings.buttonIndex = 0;
        
        
        if direction == MGSwipeDirection.rightToLeft {
            expansionSettings.fillOnTrigger = false;
            expansionSettings.threshold = 1;
            return [
                MGSwipeButton.init(title: "", icon: UIImage.init(named: "reply_icon"), backgroundColor: .clear, padding: 15, callback: { [weak view](cell) -> Bool in
                    
                    guard let view = view else { return false }
                    
                    if let path = view.tableView.indexPath(for: cell) {
                       
                        view.cellVM = view.messageDisplayViewVM.dataSources[path.section].items[path.row]
                        view.replyMessage()
                        
                    }
                    
                    return true
                })
            ]
        }
        else {
            return nil
        }
        
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, didChange state: MGSwipeState, gestureIsActive: Bool) {
        
        guard let view = self.delegate as? CODChatMessageDisplayView else {
            return
        }
        
        view.tableView.isScrollEnabled = !gestureIsActive
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
}
