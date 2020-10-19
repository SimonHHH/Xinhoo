//
//  IPLockViewController.swift
//  COD
//
//  Created by xinhooo on 2019/10/24.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

class IPLockViewController: BaseViewController {

    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.button.titleLabel?.text = NSLocalizedString("切换账号", comment: "")
        self.button.setTitle(NSLocalizedString("切换账号", comment: ""), for: .normal)
        
        // Do any additional setup after loading the view.
    }

    @IBAction func changeLoginUserAction(_ sender: Any) {
        self.dismiss(animated: true) {
            UserManager.sharedInstance.userLogout()
        }
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
