//
//  CloudDiskJumpProtocol.swift
//  COD
//
//  Created by Sim Tsai on 2020/8/31.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

protocol CloudDiskJumpProtocol {
    
    associatedtype VM
    
    var cloudDiskJumpBtn: UIButton! { get }
    var viewModel: VM? { get }
    
    func configCloudDiskJumpUI()
    

}



extension CloudDiskJumpProtocol where VM: ChatCellVM, Self: CODBaseChatCell {
    
    func configCloudDiskJumpUI() {
        
        if viewModel?.showCloudDiskJumButton ?? false {
            self.cloudDiskJumpBtn.isHidden = false
        } else {
            self.cloudDiskJumpBtn.isHidden = true
        }
        
        cloudDiskJumpBtn.addTap { [weak self] in
            guard let `self` = self else { return }
            if let jid = self.messageModel.itemID, let msgID = self.messageModel.smsgID {
                self.pageVM?.onClickCloudDaskJump(jid: jid, msgID: msgID)
            }
        }

    }
    
    
}

extension CODZZS_TextLeftTableViewCell: CloudDiskJumpProtocol {}
extension CODZZS_AudioLeftTableViewCell: CloudDiskJumpProtocol {}
extension Xinhoo_LocationLeftTableViewCell: CloudDiskJumpProtocol {}
extension Xinhoo_ImageLeftTableViewCell: CloudDiskJumpProtocol {}
extension Xinhoo_CardLeftTableViewCell: CloudDiskJumpProtocol {}
