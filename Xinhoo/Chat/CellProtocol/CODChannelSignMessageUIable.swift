//
//  CODChannelSignMessageUIType.swift
//  COD
//
//  Created by Sim Tsai on 2020/1/11.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

protocol CODChatCellViewModelType {
    var model: CODMessageModel { get }
}

extension Xinhoo_LocationViewModel: CODChatCellViewModelType {}
extension Xinhoo_ImageViewModel: CODChatCellViewModelType {}
extension Xinhoo_FileViewModel: CODChatCellViewModelType {}
extension Xinhoo_CardViewModel: CODChatCellViewModelType {}
extension Xinhoo_AudioViewModel: CODChatCellViewModelType {}



protocol CODChannelSignMessageUIable {
    
    var signMessageUIableCellVM: CODChatCellViewModelType { get }
    
    var timeView: XinhooTimeAndReadView! { get }
    var messageModel: CODMessageModel { get }
    
    func configSignMessageUI(textColor: UIColor?)
    func setSignMessage(name: String, textColor: UIColor?)
    
}


extension CODChannelSignMessageUIable {
    
    func configSignMessageUI(textColor: UIColor? = .white) {
        
        var name = ""
        if messageModel.chatTypeEnum == .channel {
            name = signMessageUIableCellVM.model.n
        }
        
        self.setSignMessage(name: name, textColor: textColor)
    }
    
    func setSignMessage(name: String, textColor: UIColor? = .white) {
        
        var nikeName: NSMutableAttributedString? = nil
        
        if name.count > 0 {
            nikeName = NSMutableAttributedString(string: name)
        }
            
        let time = NSMutableAttributedString(string: TimeTool.getTimeString(Date.init(timeIntervalSince1970:(Double((self.messageModel.datetime.int == nil ? "\(Date.milliseconds)":self.messageModel.datetime)))!/1000), format: XinhooTool.is12Hour ? "h:mm a" : "h:mm"))
        
        if self.messageModel.edited > 0 {
            time.yy_insertString(NSLocalizedString("已编辑", comment: "") + "  ", at: 0)
        }
        
        time.yy_font = FONTTime
        time.yy_color = textColor
        nikeName?.yy_font = time.yy_font
        nikeName?.yy_color = time.yy_color
        
        self.timeView.set(nikename: nikeName, time: time, status: .unknown)
        
    }
    
}

extension Xinhoo_LocationLeftTableViewCell: CODChannelSignMessageUIable {
    var signMessageUIableCellVM: CODChatCellViewModelType {
        return self.viewModel!
    }
}

extension Xinhoo_ImageLeftTableViewCell: CODChannelSignMessageUIable {
    var signMessageUIableCellVM: CODChatCellViewModelType {
        return self.viewModel!
    }
}


extension Xinhoo_CardLeftTableViewCell: CODChannelSignMessageUIable {
    var timeView: XinhooTimeAndReadView! {
        self.timeLab
    }
    
    var signMessageUIableCellVM: CODChatCellViewModelType {
        return self.viewModel!
    }
}

extension CODZZS_AudioLeftTableViewCell: CODChannelSignMessageUIable {

    
    var signMessageUIableCellVM: CODChatCellViewModelType {
        return self.viewModel!
    }
}




