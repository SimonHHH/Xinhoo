//
//  ChatCellVM.swift
//  COD
//
//  Created by Sim Tsai on 2020/2/13.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift
import RxCocoa


class ChatCellVM: TableViewCellVM {
    
    var isSelect: Bool = false
    var isFirst: Bool = false
    var indexPath: IndexPath? = nil

    override var identity: String {
        return self.messageModel.msgID
    }
    
    static func == (lhs: ChatCellVM, rhs: ChatCellVM) -> Bool {
        return lhs.messageModel.msgID == rhs.messageModel.msgID
    }
    

    weak var lastCellVM: ChatCellVM? = nil {
        didSet {
            self.cellLocation = self.getCellLocation()
        }
    }
    weak var nextCellVM: ChatCellVM? = nil {
        didSet {
            self.cellLocation = self.getCellLocation()
        }
    }
    
    var showCloudDiskJumButton: Bool {
        let isCloudDiskMessage = self.model.isCloudDiskMessage
        let isNewMessageStruct = (self.model.itemID != nil)
        let cellDirection = self.cellDirection
        
        return (cellDirection == .left && isCloudDiskMessage && isNewMessageStruct)
    }
    
    
    var messageModel: CODMessageModel {
        didSet {
            self.messageModelBR.accept(self.messageModel)
        }
    }
    lazy var messageModelBR: BehaviorRelay<CODMessageModel> = {
        return BehaviorRelay<CODMessageModel>(value: self.messageModel)
    }()
    
    var lastModel:CODMessageModel? {
        return self.lastCellVM?.messageModel
    }
    
    var nextModel:CODMessageModel? {
        return self.nextCellVM?.messageModel
    }
    
    let cellDirection: CellDirection
    var cellLocation: LocationType = .only {
        didSet {
            cellLocationBR.accept(cellLocation)
        }
    }
    var cellLocationBR: BehaviorRelay<LocationType> = BehaviorRelay(value: .only)
    
    override var cellHeight: CGFloat {
        didSet {
            
            if self.cellHeight != messageModel.cellHeight.cgFloat() {
                
                let realm = try! Realm()
                
                let write = {
                    self.messageModel.cellHeight = self.cellHeight.string
                }
                
                if realm.isInWriteTransaction {
                    write()
                } else {
                    try! realm.write(write)
                }

            }
        }
    }
    
    enum CellDirection {
        case left
        case right
    }
    
    public init(name: String = UITableViewCell.self.description(), messageModel: CODMessageModel, cellHeight: CGFloat = UITableView.automaticDimension) {
        self.messageModel = messageModel
        
        let fromWho = messageModel.fromWho
        let toJID = messageModel.toJID

        let me = UserManager.sharedInstance.loginName
        if messageModel.chatTypeEnum == .channel {
            cellDirection = .left
        } else if fromWho.contains(me!) {
            if toJID.contains(kCloudJid) && messageModel.fw.removeAllSapce.count > 0{
                cellDirection = .left
            }else{
                cellDirection = .right
            }
        } else {
            cellDirection = .left
        }

        super.init(name: name, cellHeight: cellHeight)
        
        if let cellHeight = messageModel.cellHeight.cgFloat(), cellHeight > 0 {
            self.cellHeight = cellHeight
        }
    }
    
    lazy var fwName: String = {
        
        var name = ""
        if CustomUtil.getIsCloudMessage(messageModel: model) {
            name = ""
        }else if model.fwf == "C" {
            name = model.fwn
        }else{
            if  model.fw.contains(UserManager.sharedInstance.loginName!) {
                name = UserManager.sharedInstance.nickname ?? ""
            }else{
                if let contact = CODContactRealmTool.getContactByJID(by: model.fw) ,contact.isValid == true{
                    
                    name = contact.getContactNick()
                }else{
                    if let personModel = CODPersonInfoModel.getPersonInfoModel(jid: model.fw) {
                        name = personModel.name
                    }else{
                        let person = CODPersonInfoModel.init()
                        person.jid = model.fw
                        person.name = model.fwn
                        try! Realm.init().write {
                            try! Realm.init().add(person, update: .all)
                        }
                        name = model.fwn
                    }
                }
            }
        }
        
        return name
        
    }()
    
    lazy var fwColor: UIColor? = {
        
        let textColor = (model.fromWho.contains(UserManager.sharedInstance.loginName!) && model.chatTypeEnum != .channel) ? UIColor.init(hexString: "54A044") : UIColor.init(hexString: kBlueTitleColorS)
        
        return textColor
        
    }()
    
    /// cell右下角显示时间
    var sendTime: String {
        let timeString = TimeTool.getTimeString(Date.init(timeIntervalSince1970:(Double((self.model.datetime.int == nil ? "\(Date.milliseconds)":self.model.datetime)))!/1000), format: XinhooTool.is12Hour ? "h:mm a" : "h:mm")
        return  self.model.edited == 0 ? timeString : ("\(NSLocalizedString("已编辑", comment: ""))  " + timeString)
    }
    

    
}
