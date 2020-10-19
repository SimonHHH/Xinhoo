//
//  MediaLinkViewController.swift
//  COD
//
//  Created by xinhooo on 2019/11/20.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Lottie
import SafariServices
import LGAlertView

class MediaLinkViewController: BaseViewController {

    var data:NSMutableDictionary?
    var keys = Array<Any>()
    @IBOutlet weak var listView: UITableView!
    
    //是不是云盘
    var isCloudDisk = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
            self.view.backgroundColor = .white
            
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
            self.listView.register(UINib.init(nibName: "MediaLinkTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "MediaLinkTableViewCell")
            self.listView.delegate = self
            self.listView.dataSource = self
            self.listView.emptyDataSetSource = self
            self.listView.emptyDataSetDelegate = self
            self.listView.estimatedRowHeight = 88
            self.listView.rowHeight = UITableView.automaticDimension
            self.listView.tableFooterView = UIView.init()
            
//            self.listView.isEditing = XinhooTool.isMultiSelect_ShareMedia
//            self.listView.allowsMultipleSelectionDuringEditing = XinhooTool.isMultiSelect_ShareMedia
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

extension MediaLinkViewController:UITableViewDelegate,UITableViewDataSource,EmptyDataSetSource,EmptyDataSetDelegate{
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
        
        var linkArr = Array<String>()
        var textArr = Array<String>()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaLinkTableViewCell") as! MediaLinkTableViewCell
        
        var firstText = self.hostOrIP(url: model.text.getFirstUrl() as NSString ) as String
        for attributeModel in model.entities {
            if attributeModel.typeEnum == .text_link {
                
                if firstText.removeAllSapce.count == 0 {
                    firstText = attributeModel.url
                }
                
                let ocText = model.text as NSString
                
                if attributeModel.offset > model.text.utf16.count || (attributeModel.offset + attributeModel.length) > model.text.utf16.count {
                    continue
                }
//                let endIndex = model.text.index(model.text.startIndex, offsetBy: attributeModel.offset + attributeModel.length)
                let subStr = ocText.substring(with: NSRange(location: attributeModel.offset, length: attributeModel.length))
                textArr.append(subStr)
                linkArr.append(attributeModel.url)
                
            }
        }
        
        if linkArr.count == 0 {
            linkArr = model.text.getAllUrl()
        }
        
        if textArr.count == 0 {
            textArr = model.text.getAllUrl()
        }
        
        cell.titleLab.text = firstText
        cell.contentLab.text = model.text
        cell.linkArray = linkArr
        cell.textArray = textArr
        
        cell.imgView.image = self.imageWithColor(color: UIColor.init(hexString: "DFDFDF"), size: CGSize.init(width: 48, height: 48), text: (firstText as NSString).substring(to: 1) as NSString, textAttributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 24) as Any,NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "FFFFFF") as Any], cirular: false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let arr = data?.object(forKey: keys[indexPath.section]) as? NSMutableArray
        let model = arr![indexPath.row] as! CODMessageModel
        
        if XinhooTool.isMultiSelect_ShareMedia {
            let arr = data?.object(forKey: keys[indexPath.section]) as? NSMutableArray
            let model = arr![indexPath.row] as! CODMessageModel
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpSelectListNoti), object: model)
        }else{
            tableView.deselectRow(at: indexPath, animated: true)
            var strUrl = model.text.getFirstUrl()
            
            if strUrl.removeAllSapce.count == 0 {
               
                for attributeModel in model.entities {
                    if attributeModel.typeEnum == .text_link {
                        strUrl = attributeModel.url
                        break
                    }
                }
            }
            
            CustomUtil.openURL(url: strUrl)
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = keys[section] as! String
        let arr = data?.object(forKey: keys[section]) as? NSMutableArray
        let view = Bundle.main.loadNibNamed("MediaCollectionReusableView", owner: self, options: nil)?.last as! MediaCollectionReusableView
        view.titleLab.text = title
        view.contentLab.text = String(format: NSLocalizedString("%ld 个链接", comment: ""), arr?.count ?? 0)
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
        lab.text = NSLocalizedString("暂无聊天链接", comment: "")
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


extension MediaLinkViewController {
    
    func hostOrIP(url:NSString?) -> NSString {
        
        var urlStr = url
        
        if urlStr == nil || urlStr?.length == 0 {
            return ""
        }
        
        if urlStr?.hasPrefix("http://") ?? false {
            //例 http://www.baidu.com
            urlStr = urlStr?.substring(from: url?.range(of: "http://").length ?? 0) as NSString?
        }else if urlStr?.hasPrefix("https://") ?? false {
            //例 https://www.google.com
            urlStr = urlStr?.substring(from: url?.range(of: "https://").length ?? 0) as NSString?
        }
        //去掉www.
        if (urlStr?.range(of: "www.").length)! > 0 {
            urlStr = urlStr?.substring(from: (urlStr?.range(of: "www.").location)! + 4) as NSString?
        }
        
        //例 http://tieba.baidu.com/f?kw=%D3%CA%B4%C1
        if (urlStr?.range(of: "/").length)! > 0 {
            urlStr = urlStr?.substring(to: (urlStr?.range(of: "/").location)!) as NSString?
        }
        //例 http://user:password@192.168.100.144:8080/
        if (urlStr?.range(of: "@").length)! > 0 {
            urlStr = urlStr?.substring(from: (urlStr?.range(of: "@").location)! + 1) as NSString?
        }
        //例 http://192.168.100.144:8080/
        if (urlStr?.range(of: ":").length)! > 0 {
            urlStr = urlStr?.substring(to: (urlStr?.range(of: ":").location)!) as NSString?
        }
        
        if (urlStr?.range(of: ".").length)! > 0 {
            let strArr = urlStr?.components(separatedBy: ".")
            if strArr?.count ?? 0 >= 3 {
                urlStr = strArr![1] as NSString
            }
            
            if strArr?.count ?? 0 < 3 && strArr?.count ?? 0 >= 2 {
                urlStr = strArr![0] as NSString
            }
        }
        
        urlStr = urlStr?.capitalized as NSString?
        
        return urlStr!
    }
    
    func imageWithColor(color:UIColor?,size:CGSize,text:NSString,textAttributes:NSDictionary,cirular:Bool) -> UIImage? {
        
        if color == nil || size.width <= 0 || size.height <= 0 {
            return nil
        }
        
        let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 3)
        let context = UIGraphicsGetCurrentContext()
        
        if cirular {
            let path = CGPath.init(ellipseIn: rect, transform: nil)
            context?.addPath(path)
            context?.clip()
        }
        
        context?.setFillColor(color!.cgColor)
        context?.fill(rect)
        
        let textSize = text.size(withAttributes: textAttributes as? [NSAttributedString.Key : Any])
        text.draw(in: CGRect.init(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2, width: textSize.width, height: textSize.height), withAttributes: textAttributes as? [NSAttributedString.Key : Any])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
