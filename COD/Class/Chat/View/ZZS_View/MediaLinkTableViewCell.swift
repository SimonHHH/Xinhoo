//
//  MediaLinkTableViewCell.swift
//  COD
//
//  Created by xinhooo on 2019/11/20.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import SafariServices
import LGAlertView
class MediaLinkTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var contentLab: UILabel!
    @IBOutlet weak var listView: UITableView!
    @IBOutlet weak var listViewHeightCos: NSLayoutConstraint!
    var linkArray:Array<String> = [] {
        didSet {
            self.listViewHeightCos.constant = CGFloat(self.linkArray.count * 18)
            self.listView.reloadData()
        }
    }
    var textArray:Array<String> = []
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: URL.init(string: "http://www.baidu.com")!) { (data, response, error) in
//            let htmlString = String.init(data: data ?? Data.init(), encoding: .utf8)
//            debugPrint(htmlString!)
//        }
//        dataTask.resume()
        listView.register(UINib(nibName: "CODLinkContentCell", bundle: Bundle.main), forCellReuseIdentifier: "CODLinkContentCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension MediaLinkTableViewCell:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.textArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CODLinkContentCell = tableView.dequeueReusableCell(withIdentifier: "CODLinkContentCell") as! CODLinkContentCell
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressAction(longPress:)))
        cell.addGestureRecognizer(longPress)
        cell.titleLab.text = self.textArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.openURL(url: self.linkArray[indexPath.row])
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 18
    }
    
    @objc func longPressAction(longPress:UILongPressGestureRecognizer) {
        
        if longPress.state == .began {
            let cell = longPress.view as! UITableViewCell
            
            let alert = UIAlertController.init(title: cell.textLabel?.text, message: nil, preferredStyle: .actionSheet)
            let openAction = UIAlertAction.init(title: NSLocalizedString("打开", comment: ""), style: .default) { (action) in
                self.openURL(url: cell.textLabel?.text ?? "")
            }
            
            let copyAction = UIAlertAction.init(title: NSLocalizedString("拷贝", comment: ""), style: .default) { (action) in
                let pastboard = UIPasteboard.general
                pastboard.string = cell.textLabel?.text
            }
            
            let cancelAction = UIAlertAction.init(title: NSLocalizedString("取消", comment: ""), style: .cancel) { (action) in
                
            }
            
            alert.addAction(openAction)
            alert.addAction(copyAction)
            alert.addAction(cancelAction)
            
            UIViewController.current()?.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    func openURL(url:String) {
        CustomUtil.openURL(url: url)
    }
    
}

