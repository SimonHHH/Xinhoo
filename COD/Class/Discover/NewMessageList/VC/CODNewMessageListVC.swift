//
//  CODNewMessageListVC.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/18.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class CODDiscoverNewMessageListVC: BaseViewController, ASTableDataSourcesAdapterDelegate {
    
    let newMessageListPageVM = CODNewMessageListPageVM()
    
    var pageVM: Any? {
        return self.newMessageListPageVM
    }
    
    let tableNode = ASTableNode()
    
    var adapter: ASTableDataSourcesAdapter<DiscoverHomeSectionVM>!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
