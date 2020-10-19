//
//  ForgetPwViewController.swift
//  COD
//
//  Created by XinHoo on 2019/2/26.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class ForgetPwViewController: BaseViewController {

    @IBOutlet weak var countryLab: UILabel!
    
    @IBOutlet weak var phoneField: UITextField!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var switchBtn: UIButton!
    var areaCode = "86"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("设置登录密码", comment: "")
        self.setBackButton()
        
        if UserManager.sharedInstance.isLogin {
            phoneField.isEnabled = false
            phoneField.text = UserManager.sharedInstance.phoneNum
            phoneField.textColor = UIColor(hexString: kSubTitleColors)
            countryLab.textColor = UIColor(hexString: kSubTitleColors)
            switchBtn.isHidden = false
        }
        
        switchBtn.setTitle(NSLocalizedString("密码验证", comment: ""), for: .normal)
        
        if UserManager.sharedInstance.countryName != ""{
            self.countryLab.text = "\(UserManager.sharedInstance.countryName ?? "")(+\(UserManager.sharedInstance.areaNum ?? ""))"
            self.areaCode = UserManager.sharedInstance.areaNum ?? "86"
        }
    }
    
    @IBAction func switchVerifyTypeAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func showCountryList(_ sender: Any) {
        /*
        let vc = CODCountryCodeViewController.init(nibName: "CODCountryCodeViewController", bundle: Bundle.main)
        vc.selectBlock = { (model) in
            
            self.countryLab.text = "\(model.name)(+\(model.phonecode))"
            self.areaCode = model.phonecode
            UserManager.sharedInstance.countryName = model.name
            UserManager.sharedInstance.areaNum = model.phonecode
        }
        self.navigationController?.pushViewController(vc)
        */
    }
    
    @IBAction func nextStep(_ sender: Any) {
        let phoneStr = phoneField.text
        
        if (phoneStr!.count <= 0) {
            CODProgressHUD.showErrorWithStatus("Phone Number cannot be blank")
            return
        }
        let ctl = ForgetPwThirdViewController()
        ctl.areaCode = self.areaCode
        ctl.phoneStr = phoneStr!
        self.navigationController?.pushViewController(ctl, animated: true)
        
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
