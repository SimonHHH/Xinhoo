//
//  TransmitMultiSelectView.swift
//  COD
//
//  Created by xinhooo on 2020/2/15.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class TransmitMultiSelectView: UIView,UICollectionViewDelegate,UICollectionViewDataSource,UITextViewDelegate {

    var selectArr: Array = [String]()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var totalMsgLab: UILabel!
    @IBOutlet weak var remarkTF: CustomTextView!
    @IBOutlet weak var sendLab: UILabel!
    typealias RemarkChangeBlock = (_ text:NSAttributedString?) -> ()
    var remarkChangeBlock:RemarkChangeBlock?
    
    var typingAttributes:[NSAttributedString.Key : Any] = [:]
    
    class func initWitXib(selectArr:Array<String>,messages:Array<CODMessageModel>) -> TransmitMultiSelectView {
        
        let view = Bundle.main.loadNibNamed("TransmitMultiSelectView", owner: self, options: nil)?.last as! TransmitMultiSelectView
        
        view.remarkTF.placeholder = NSLocalizedString("给朋友留言", comment: "")
        view.remarkTF.allowsEditingTextAttributes = true
        
        view.sendLab.text = NSLocalizedString("发送给：", comment: "")
        
        view.totalMsgLab.text = String(format: NSLocalizedString("[转发]共%ld条消息", comment: ""), messages.count)
        view.typingAttributes = view.remarkTF.typingAttributes
        view.selectArr = selectArr
        view.frame = CGRect(x: 0, y: 0, width: KScreenWidth - 50, height: 185)
        view.collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "collectionCell")
        
        return view
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count == 0 {
            textView.typingAttributes = self.typingAttributes
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.remarkChangeBlock != nil {
            self.remarkChangeBlock!(textView.attributedText)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath)
        cell.contentView.removeSubviews()
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        imageView.contentMode = .scaleToFill
        imageView.cornerRadius = 25
        cell.contentView.addSubview(imageView)
        
        let jid = selectArr[indexPath.item]
        
        
        /// 优先查询历史会话，如果查询不到则去查询联系人表
        if let chatModel = CODChatListRealmTool.getChatList(jid: jid) {
            if chatModel.id <= 0 {
                if chatModel.id == CloudDiskRosterID  {
                    imageView.image = UIImage(named: "cloud_disk_icon")
                }else{
                    imageView.image = UIImage.helpIcon()
                }
                
            }else{
                var imgUrl = chatModel.icon
                
                if imgUrl == "" {
                    imgUrl =  chatModel.icon
                }
                
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: imgUrl) { (image) in
                    imageView.image = image
                }
            }
        }else if let contactModel = CODContactRealmTool.getContactByJID(by: jid) {
            if (contactModel.name == "\(kApp_Name)小助手") {
                //网络图片需要处理一下
                imageView.image = UIImage.helpIcon()
            }else{
                if let _ = URL.init(string: contactModel.userpic.getHeaderImageFullPath(imageType: 0)) {
                    CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: contactModel.userpic) { (image) in
                        imageView.image = image
                    }
                }else{
                    imageView.image = UIImage(named: "default_header_80")
                }
            }
        }
        
        return cell
        
    }
    
}
