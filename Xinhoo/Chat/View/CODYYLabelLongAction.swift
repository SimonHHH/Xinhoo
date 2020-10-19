//
//  CODYYLabelLongAction.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/7.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import Aspects

protocol CODYYLabelLongActionable where Self: UITableViewCell, ContentLabelType: CODYYLabelLongAction, ViewModelType: ChatCellVM  {
    func configYYLabelLongAction()
    
    associatedtype ContentLabelType
    associatedtype ViewModelType

    var contentLab: ContentLabelType! { get }
    
    var chatDelegate:CODIMChatCellDelegate? { get }
    
    var backView: UIView! { get }
    
    var messageModel: CODMessageModel { get }
    
    var viewModel: ViewModelType? { get }
    
    var pageVM: CODChatMessageDisplayPageVM? { get }

}

extension CODZZS_TextRightTableViewCell: CODYYLabelLongActionable {
//    typealias ContentLabelType = CODChatContentLabel
}

extension CODZZS_TextLeftTableViewCell: CODYYLabelLongActionable {
//    typealias ContentLabelType = CODChatContentLabel
}

extension Xinhoo_ImageRightTableViewCell: CODYYLabelLongActionable{

    typealias ContentLabelType = CODYYLabelLongAction
    
    var contentLab: ContentLabelType! {
        return self.lblDesc
    }

}

extension Xinhoo_ImageLeftTableViewCell: CODYYLabelLongActionable{

    typealias ContentLabelType = CODYYLabelLongAction
    
    var contentLab: ContentLabelType! {
        return self.lblDesc
    }

}

extension Xinhoo_FileLeftTableViewCell: CODYYLabelLongActionable{

    typealias ContentLabelType = CODYYLabelLongAction
    
    var contentLab: ContentLabelType! {
        return self.lblDesc
    }

}

extension Xinhoo_FileRightTableViewCell: CODYYLabelLongActionable{

    typealias ContentLabelType = CODYYLabelLongAction
    
    var contentLab: ContentLabelType! {
        return self.lblDesc
    }

}

extension CODYYLabelLongActionable {
    func configYYLabelLongAction() {
        
        self.contentLab.setLongTap()
        self.contentLab.longPassTextAction = { [weak self] in
            guard let `self` = self else { return }
            self.pageVM?.cellLongPressMessage(cellVM: self.viewModel, self, self.backView)
        }
        
    }
    
    
}

class CODYYLabelLongAction: YYLabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var isLongTap: Bool = false
    
    var longPassTextAction: (() -> ())?
    var longPressTimer: Timer?
    
    func setLongTap() {
        
        let wrappedBlock:@convention(block) (AspectInfo)-> Void = { [weak self] aspectInfo in
            
            guard let `self` = self else { return }
            
            self.isLongTap = true
        }
        
        let wrapped2Block:@convention(block) (AspectInfo)-> Void = { [weak self] aspectInfo in
            
            guard let `self` = self else { return }
            
            self.isLongTap = false
        }
        
        try! self.aspect_hook(NSSelectorFromString("_startLongPressTimer"), with: .positionBefore, usingBlock:wrappedBlock)
        
        try! self.aspect_hook(NSSelectorFromString("_endLongPressTimer"), with: .positionBefore, usingBlock:wrapped2Block)

    }
    
    func startLongPressTimer() {
        
        longPressTimer?.invalidate()
        
        longPressTimer = Timer(timeInterval: 0.8, target: YYTextWeakProxy(target: self), selector: #selector(trackDidLongPress), userInfo: nil, repeats: false)
        
        RunLoop.current.add(longPressTimer!, forMode: .common)

    }
    
    func endLongPressTimer() {
        
        longPressTimer?.invalidate()
        longPressTimer = nil

    }
    
    @objc func trackDidLongPress() {
        
        self.longPassTextAction?()
        endLongPressTimer()
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if isLongTap == false {
            
            if self.longPassTextAction != nil {
                startLongPressTimer()
            }

        }
        
        print("isLongTap = \(isLongTap)")

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        endLongPressTimer()
    }
    

}
