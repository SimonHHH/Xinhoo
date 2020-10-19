//
//  MediaFileViewController.swift
//  COD
//
//  Created by xinhooo on 2019/8/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Lottie
import SVProgressHUD

class MediaFileViewController: BaseViewController {
    
    var data:NSMutableDictionary?
    var keys = Array<Any>()
    var formatter:DateFormatter?
    var currentFileID = ""
    //是不是云盘
    var isCloudDisk = false
    @IBOutlet weak var listView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        formatter = DateFormatter.init()
        formatter!.dateFormat = "yyyy 年 MM 月 d 日 HH:mm"
        
        self.configView()
        self.configData()
    }

    func configData() {
        
        self.listView.isEditing = XinhooTool.isMultiSelect_ShareMedia
        self.listView.allowsMultipleSelectionDuringEditing = XinhooTool.isMultiSelect_ShareMedia
        
        self.keys = self.data?.allKeys.sorted(by: { (dateStr1, dateStr2) -> Bool in
            
            return (dateStr1 as! String) > (dateStr2 as! String)
        }) ?? Array<Any>()
        
        self.listView.reloadData()
    }
    
    func configView() {
        self.listView.register(UINib.init(nibName: "MediaFileTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "MediaFileTableViewCell")
        self.listView.delegate = self
        self.listView.dataSource = self
        self.listView.emptyDataSetSource = self
        self.listView.emptyDataSetDelegate = self
        self.listView.tableFooterView = UIView.init()
        
        
//        self.listView.isEditing = XinhooTool.isMultiSelect_ShareMedia
//        self.listView.allowsMultipleSelectionDuringEditing = XinhooTool.isMultiSelect_ShareMedia
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

extension MediaFileViewController:UITableViewDelegate,UITableViewDataSource,EmptyDataSetSource,EmptyDataSetDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arr = data?.object(forKey: keys[section]) as? NSMutableArray
        return arr?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let arr = data?.object(forKey: keys[indexPath.section]) as? NSMutableArray
        let model = arr![indexPath.row] as! CODMessageModel
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaFileTableViewCell") as! MediaFileTableViewCell
        
        cell.imgView.image = UIImage(named: CustomUtil.getImageNameWithSuffix(str: model.fileModel?.filename))
        cell.titleLab.text = model.fileModel?.filename
        
        if model.fileModel?.fileSizeString.count ?? 0 > 0 {
            cell.contentLab.text = "\(model.fileModel?.fileSizeString ?? "0kb") · \(formatter!.string(from: Date.init(timeIntervalSince1970: (model.datetime.double() ?? 0)/1000))) "
        }else{
            cell.contentLab.text = "0kb · \(formatter!.string(from: Date.init(timeIntervalSince1970: (model.datetime.double() ?? 0)/1000)))"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if XinhooTool.isMultiSelect_ShareMedia {
            let arr = data?.object(forKey: keys[indexPath.section]) as? NSMutableArray
            let model = arr![indexPath.row] as! CODMessageModel
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpSelectListNoti), object: model)
        }else{
            tableView.deselectRow(at: indexPath, animated: true)
            let arr = data?.object(forKey: keys[indexPath.section]) as? NSMutableArray
            let message = arr![indexPath.row] as! CODMessageModel
            
            if self.currentFileID == message.fileModel?.fileID ?? "" {
                return
            }
            self.currentFileID = message.fileModel?.fileID ?? ""
            
            //文件后缀名
            let suffix = message.fileModel?.filename.pathExtension ?? ""
            
            SVProgressHUD.showProgress(0,status: "已下载:0%")
            CODDownLoadManager.sharedInstance.downloadFile(saveFilePath: CODFileManager.shareInstanceManger().filePathWithName(fileName: "\((message.fileModel?.fileID ?? "")).\(suffix)"), fileID: (message.fileModel!.fileID), isCloudDisk:self.isCloudDisk, downProgress: { (progress) in
                SVProgressHUD.showProgress(Float(progress.fractionCompleted),status: "已下载:\(Int(progress.fractionCompleted*100))%")
            }, success: {
                self.currentFileID = ""
                let previewVC = CODPreviewViewController()
                previewVC.filePath = CODFileManager.shareInstanceManger().filePathWithName(fileName: "\((message.fileModel?.fileID ?? "")).\(suffix)")
                previewVC.fileName = message.fileModel?.filename ?? "文件预览"
                let ctl = UIViewController.current()/* as? CODCustomTabbarViewController*/
                ctl?.navigationController!.pushViewController(previewVC, animated: true)
            }) {
                self.currentFileID = ""
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if XinhooTool.isMultiSelect_ShareMedia {
            let arr = data?.object(forKey: keys[indexPath.section]) as? NSMutableArray
            let model = arr![indexPath.row] as! CODMessageModel
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpSelectListNoti), object: model)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.init(rawValue: UITableViewCell.EditingStyle.delete.rawValue | UITableViewCell.EditingStyle.insert.rawValue)!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = keys[section] as! String
        let arr = data?.object(forKey: keys[section]) as? NSMutableArray
        let view = Bundle.main.loadNibNamed("MediaCollectionReusableView", owner: self, options: nil)?.last as! MediaCollectionReusableView
        view.titleLab.text = title
        view.contentLab.text = String(format: NSLocalizedString("%ld 个文件", comment: ""), arr?.count ?? 0)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 150, height: 100+kNavBarHeight+kSafeArea_Top+40))
        
        let lottieView = AnimationView.init()
        let animation = Animation.filepath(Bundle.main.path(forResource: "404", ofType: "json")!, animationCache: nil)
        lottieView.animation = animation
        lottieView.loopMode = .loop
        lottieView.play()
        view.addSubview(lottieView)
        lottieView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 55, height: 65))
            make.centerX.equalToSuperview()
        }
        
        let lab = UILabel.init(frame: .zero)
        lab.text = NSLocalizedString("暂无聊天文件", comment: "")
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textColor = UIColor.init(hexString: kEmptyTitleColorS)
        view.addSubview(lab)
        lab.snp.makeConstraints { (make) in
            make.top.equalTo(lottieView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        return view
    }
    
}



