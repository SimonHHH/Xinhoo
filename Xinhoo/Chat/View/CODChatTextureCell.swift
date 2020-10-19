//
//  CODChatTextureCell.swift
//  COD
//
//  Created by Sim Tsai on 2020/4/13.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODChatTextureCell: CODBaseChatCell {
    
    var chatCellNode: CODChatCellNode?
    var viewModel: ChatCellVM?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clear
        selectionStyle = .none
        selectedBackgroundView = UIView()

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        guard let chatCellNode = chatCellNode else {
            return CGSize(width: KScreenWidth, height: 40)
        }
        
        chatCellNode.frame = CGRect(origin: .zero, size: chatCellNode.sizeThatFits(size))
        
        return chatCellNode.frame.size
    }
    
    override func flashingCell() {
        self.chatCellNode?.flashingCell()
    }

}

extension CODChatTextureCell: TableViewCellDataSourcesType {
    func configCellVM(pageVM: Any?, cellVM: TableViewCellVM, lastCellVM: TableViewCellVM?, nextCellVM: TableViewCellVM?, indexPath: IndexPath) {
        
        guard let cellVM = cellVM as? CellViewModelType, let pageVM = pageVM as? CODChatMessageDisplayPageVM else {
            return
        }
        
        if cellVM == self.viewModel && cellVM.lastCellVM == lastCellVM && cellVM.nextCellVM == nextCellVM {
            return
        }
        
        self.commandConfig(pageVM: pageVM, cellVM: cellVM, lastCellVM: lastCellVM, nextCellVM: nextCellVM, indexPath: indexPath)
        
        chatCellNode?.removeFromSupernode()
        self.messageModel = cellVM.messageModel
        
        if let cellVM = cellVM as? Xinhoo_MultipleImageCellVM {
            chatCellNode = CODMultipleImageCellNode(vm: cellVM, pageVM: pageVM)
        }
        
        if let cellVM = cellVM as? Xinhoo_FileViewModel {
            chatCellNode = CODChatFileCellNode(vm: cellVM, pageVM: pageVM)
        }
        
        self.contentView.addSubnode(chatCellNode!)
        chatCellNode?.frame = CGRect(origin: .zero, size: CGSize(width: KScreenWidth, height: 40))


    }
    
    
    

}

extension CODChatTextureCell: XinhooCellViewProtocol { }
