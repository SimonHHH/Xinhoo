//
//  CODCacheSetViewController.swift
//  COD
//
//  Created by xinhooo on 2019/6/6.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class FileModel : NSObject{
    
    var jid = ""
    var size:Double = 0
}

class CODCacheSetViewController: BaseViewController {

    @IBOutlet weak var sessionLabel: UILabel!
    @IBOutlet weak var iphoneLabel: UILabel!
    @IBOutlet weak var allSelectBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalSizeLab: UILabel!
    
    @IBOutlet weak var appSizeLabel: UILabel!
    @IBOutlet weak var otherAppsLabel: UILabel!
    @IBOutlet weak var freeSizeLabel: UILabel!
    
    @IBOutlet weak var freeSizeCos: NSLayoutConstraint!
    @IBOutlet weak var appSizeCos: NSLayoutConstraint!
    
    var jidArr = Array<FileModel>()
    var selectArr = Array<FileModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("数据与存储", comment: "")
        self.setBackButton()
//        self.view.backgroundColor = .white
       
        self.tableView.register(UINib.init(nibName: "CODCacheSetTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CODCacheSetTableViewCell")
        self.configData()
       
        iphoneLabel.text = NSLocalizedString("iPhone 存储空间", comment: "")
        sessionLabel.text = NSLocalizedString("会话", comment: "")
    }

    func configData() {
        
        let f = ByteCountFormatter()
        let fileManager = FileManager.default
        
        
        var totalSize: Int64 = 0
        var freeSize: Int64 = 0
        var appSize: Int64 = 0
        var sessionListSize: Int64 = 0
        
        if let attributes = try? fileManager.attributesOfFileSystem(forPath: NSHomeDirectory()) {

            if let systemSize = attributes[FileAttributeKey.systemSize] as? Int64 {
                // 总大小
                totalSize = systemSize
                
            }

            if let systemFreeSize = attributes[FileAttributeKey.systemFreeSize] as? Int64 {
                // 可用大小
                freeSize = systemFreeSize
            }

        }
        
        
        jidArr.removeAll()
        let messagePath = CODFileManager.shareInstanceManger().getMessageCachePath()
        let defaultFileManager = FileManager.default
        
        if defaultFileManager.fileExists(atPath: messagePath) {
            
            do{
                let subPath = try defaultFileManager.contentsOfDirectory(atPath: messagePath)
                for jidPath in subPath {
                    
                    let model = FileModel.init()
                    model.jid = jidPath
                    var fileSize:Double = 0
                    for path in defaultFileManager.subpaths(atPath: messagePath.appendingPathComponent(jidPath))!{
                        if !path.hasPrefix("Voices") {
                            fileSize += self.fileSize(filePath: messagePath.appendingPathComponent(jidPath).appendingPathComponent(path))
                        }
                    }
                    model.size = fileSize
                    jidArr.append(model)
                }
            }catch{}
        }
        
        
        // 过滤掉不足1kb的聊天，并且排序
        jidArr.sort { (model1, model2) -> Bool in

            return model1.size > model2.size
        }
        
        jidArr = jidArr.filter { (model) -> Bool in
            
            if model.size > 1000 {
                sessionListSize = sessionListSize + Int64(model.size)
            }
            
            return model.size > 1000
        }
        
        
        do {
            
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let sizeOnDisk = try documentDirectory.sizeOnDisk() {
                
                appSize = appSize + Int64(sizeOnDisk)
            }
            
            let libraryDirectory = try FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let sizeOnDisk = try libraryDirectory.sizeOnDisk() {
                appSize = appSize + Int64(sizeOnDisk)
            }
            
            
            
        } catch {
            
        }
                
        freeSizeLabel.attributedText = self.getAttributedText(firstText: NSLocalizedString("可用空间", comment: ""), secondText: " • \(f.string(fromByteCount: freeSize))")
        
        freeSizeCos = freeSizeCos.setMultiplier(multiplier: CGFloat(Double(freeSize) / Double(totalSize)))
        
        if jidArr.isEmpty {
            
            appSizeLabel.attributedText = self.getAttributedText(firstText: kApp_Name + NSLocalizedString(" 服务文件", comment: ""), secondText: " • \(f.string(fromByteCount: appSize))")
                        
        }else{
            
            appSizeLabel.attributedText = self.getAttributedText(firstText: kApp_Name + NSLocalizedString(" 缓存", comment: ""), secondText: " • \(f.string(fromByteCount: appSize))")
            appSize = appSize + sessionListSize
            
        }
        
        var scale = CGFloat(Double(appSize) / Double(totalSize))
        
        if scale < 0.02 {
            scale = 0.02
        }
        
        appSizeCos = appSizeCos.setMultiplier(multiplier: scale)
        
        // 其他应用 size
        otherAppsLabel.attributedText = self.getAttributedText(firstText: NSLocalizedString("其他应用", comment: ""), secondText: " • \(f.string(fromByteCount: totalSize - freeSize - appSize))")
        
        self.tableView.reloadData()
    }
    
    func getAttributedText(firstText:String,secondText:String) -> NSAttributedString {
        
        return NSAttributedString(string: firstText, attributes: [.font:UIFont.systemFont(ofSize: 13)]) + NSAttributedString(string: secondText, attributes: [.font:UIFont.boldSystemFont(ofSize: 13)])
    }
    
    func fileSize(filePath:String) -> Double {
        
        do {
            let dict = try FileManager.default.attributesOfItem(atPath: filePath)
            return dict[FileAttributeKey.size] as! Double
        }catch{
            return 0
        }
    }

    @IBAction func allSelectAction(_ sender: Any) {
        
        if self.selectArr.count == self.jidArr.count {
            self.selectArr.removeAll()
            self.allSelectBtn.titleLabel?.text = "全选"
             self.allSelectBtn.setTitle("全选", for: .normal)
        }else{
            self.selectArr.removeAll()
            for model in self.jidArr{
                self.selectArr.append(model)
            }
            self.allSelectBtn.titleLabel?.text = "取消全选"
             self.allSelectBtn.setTitle("取消全选", for: .normal)
        }
        self.tableView.reloadData()
        
        var totalSize:Double = 0
        for model in selectArr {
            totalSize += model.size
        }
        self.totalSizeLab.text = String.init(format: NSLocalizedString("释放空间：%@", comment: ""), "\(self.sizeToString(size: totalSize))")
        
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        
        if self.selectArr.count == 0 {
            return
        }
        
        let alert = UIAlertController.init(title: "提示", message: "确定清除缓存？", preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: "取消", style: .default) { (action) in
            
        }
        let confirmAction = UIAlertAction.init(title: "确定", style: .default) { (action) in
        
            for model in self.selectArr {
                CODFileManager.shareInstanceManger().deleteEMConversationFilePathWithFilesAndImagesAndVideos(sessionID: model.jid)
            }
            
            self.selectArr.removeAll()
            self.allSelectBtn.titleLabel?.text = "全选"
            self.allSelectBtn.setTitle("全选", for: .normal)
            self.totalSizeLab.text = String.init(format: NSLocalizedString("释放空间：%@", comment: ""), "\(self.sizeToString(size: 0))")
            
            self.configData()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CODCacheSetViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.jidArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CODCacheSetTableViewCell") as! CODCacheSetTableViewCell
        
        let model = self.jidArr[indexPath.row]
        
        if model.jid.contains(XMPPGroupSuffix){
            if let chatModel = CODGroupChatRealmTool.getGroupChatByJID(by: model.jid) {
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: chatModel.grouppic) { (image) in
                    cell.headImageView.image = image
                }
                cell.nameLab.text = chatModel.getGroupName()
            }else if let chatModel = CODChannelModel.getChannel(jid: model.jid) {
                CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: chatModel.grouppic) { (image) in
                    cell.headImageView.image = image
                }
                cell.nameLab.text = chatModel.getGroupName()
            }else{
                CODFileManager.shareInstanceManger().deleteEMConversationFilePath(sessionID: model.jid)
                self.jidArr.removeAll(model)
                tableView.reloadData()
            }
         
        }else{
            if let chatModel = CODContactRealmTool.getContactByJID(by: model.jid) {
                
                if chatModel.jid.contains(kCloudJid) {
                    cell.headImageView.image = UIImage.init(named: "cloud_disk_icon")
                }else if chatModel.jid.contains("cod_60000000") {
                    cell.headImageView.image = UIImage.helpIcon()
                }else{
                    CODDownLoadManager.sharedInstance.downloadAvatar(userPicID: chatModel.userpic) { (image) in
                        cell.headImageView.image = image
                    }
                }
                cell.nameLab.text = chatModel.getContactNick()
            }else{
                CODFileManager.shareInstanceManger().deleteEMConversationFilePath(sessionID: model.jid)
                self.jidArr.removeAll(model)
                tableView.reloadData()
            }
          
        }
        
        cell.sizeLab.text = self.sizeToString(size: model.size)
        cell.selectBtn.isSelected = self.selectArr.contains(model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = jidArr[indexPath.row]
        if selectArr.contains(model) {
//            selectArr.remove(at: selectArr.firstIndex(of: model)!)
//            selectArr.remove(at: indexPath.row)
            selectArr.removeAll(model)
        }else{
            selectArr.append(model)
        }
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        
        if selectArr.count == jidArr.count {
            self.allSelectBtn.titleLabel?.text = "取消全选"
            self.allSelectBtn.setTitle("取消全选", for: .normal)
        }else{
            self.allSelectBtn.titleLabel?.text = "全选"
            self.allSelectBtn.setTitle("全选", for: .normal)
        }
        
        var totalSize:Double = 0
        for model in selectArr {
            totalSize += model.size
        }
        self.totalSizeLab.text = String.init(format: NSLocalizedString("释放空间：%@", comment: ""), "\(self.sizeToString(size: totalSize))")
    }
    
    
    func sizeToString(size:Double) -> String {
        
        if size > 1000*1000 {
            return String.init(format:"%.2fM",size/1000.0/1000.0)
        }else if size > 1000.0{
            return String.init(format:"%.0fKB",size/1000)
        }else{
            return "0KB"
        }
    }
}
