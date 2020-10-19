//
//  CODChangeFontViewController.swift
//  COD
//
//  Created by xinhooo on 2019/4/13.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
private let CODTextChatCell_identity = "CODTextChatCell_identity"

class CODChangeFontViewController: BaseViewController {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sizeLabCos: NSLayoutConstraint!
    @IBOutlet weak var sizeLab: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackButton()
        // Do any additional setup after loading the view.
        slider.isContinuous = false
        tableView.contentInset = UIEdgeInsets.init(top: 30, left: 0, bottom: 0, right: 0)
        tableView.register(CODTextChatCell.self, forCellReuseIdentifier: CODTextChatCell_identity)
        self.navigationItem.title = NSLocalizedString("字体大小", comment: "")
        
//        NSLayoutConstraint.deactivate([self.sizeLabCos])
//        let newSizeLabCos = NSLayoutConstraint.init(item: self.sizeLabCos.firstItem as Any, attribute: self.sizeLabCos.firstAttribute, relatedBy: self.sizeLabCos.relation, toItem: self.sizeLabCos.secondItem, attribute: self.sizeLabCos.secondAttribute, multiplier: 2, constant: self.sizeLabCos.constant)
//        NSLayoutConstraint.activate([newSizeLabCos])
        var multiplier:CGFloat = 0
        let size = UserDefaults.standard.integer(forKey: kFontSize_Change)
        switch size {
        case -2:
            multiplier = 1/100.0
            slider.value = 0
        case 0:
            multiplier = 1/2.0
            slider.value = 1
        case 2:
            multiplier = 1
            slider.value = 2
        case 4:
            multiplier = 1.5
            slider.value = 3
        case 6:
            multiplier = 2
            slider.value = 4
            
        default:
            break
        }
        self.setMultipierText(multiplier: multiplier)
        self.sizeLabCos = self.sizeLabCos.setMultiplier(multiplier: multiplier)
    }

    @IBAction func valueChange(_ sender: UISlider) {
        
        
        var multiplier:CGFloat = 0
        
        if sender.value <= 0.5 {
            slider.setValue(0, animated: true)
            UserDefaults.standard.set("-2" as String, forKey: kFontSize_Change)
            multiplier = 1/100.0
        }
        
        if sender.value > 0.5,sender.value <= 1.5{
            slider.setValue(1, animated: true)
            UserDefaults.standard.set("0" as String, forKey: kFontSize_Change)
            multiplier = 1/2.0
        }
        
        if sender.value > 1.5,sender.value <= 2.5{
            slider.setValue(2, animated: true)
            UserDefaults.standard.set("2" as String, forKey: kFontSize_Change)
            multiplier = 1
        }
        
        if sender.value > 2.5,sender.value <= 3.5{
            slider.setValue(3, animated: true)
            UserDefaults.standard.set("4" as String, forKey: kFontSize_Change)
            multiplier = 1.5
        }
        
        if sender.value > 3.5,sender.value <= 4{
            slider.setValue(4, animated: true)
            UserDefaults.standard.set("6" as String, forKey: kFontSize_Change)
            multiplier = 2
        }
        
        self.sizeLabCos = self.sizeLabCos.setMultiplier(multiplier: multiplier)
        self.setMultipierText(multiplier: multiplier)
        self.tableView.reloadData()
        
    }
    
    func setMultipierText(multiplier:CGFloat) {
        
        var text = "100%"
        switch multiplier {
        case 1/100.0:
            text = "80%"
        case 1/2:
            text = "100%"
        case 1:
            text = "125%"
        case 1.5:
            text = "150%"
        case 2:
            text = "175%"
        default:
            break
        }
        self.sizeLab.text = text
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getDataSource() -> NSArray {
        
        let model_right:CODMessageModel = CODMessageModel()
        model_right.text = NSLocalizedString("预览字体的大小。", comment: "")
        model_right.isReaded = true
        model_right.isShowDate = false
        model_right.fromWho = UserManager.sharedInstance.loginName!
        
        let model_left:CODMessageModel = CODMessageModel()
        model_left.text = NSLocalizedString("拖动下面的滑块，可设置字体的大小。", comment: "")
        model_left.isReaded = true
        model_left.isShowDate = false
        
        return [model_right,model_left]
    }
    
}

extension CODChangeFontViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model :CODMessageModel = self.getDataSource()[indexPath.row] as! CODMessageModel
        let cell = tableView.dequeueReusableCell(withIdentifier: CODTextChatCell_identity, for: indexPath) as! CODTextChatCell
        cell.setCellContent(model, isShowName: false)
        return cell
    }
}
