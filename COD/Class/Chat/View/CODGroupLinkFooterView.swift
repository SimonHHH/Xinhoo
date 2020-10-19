//
//  CODGroupLinkFooterView.swift
//  COD
//
//  Created by XinHoo on 2020/4/17.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODGroupLinkFooterView: UITableViewHeaderFooterView, TableViewHeaderFooterDataSourceType {
    
    @IBOutlet weak var titleLab: UILabel!
    
    func configHeaderFooterVM(sectionVM: Any, section: Int) {
        guard let vm = sectionVM as? CODGroupLinkSectionModel else {
            return
        }
        self.titleLab.text = vm.title
    }
    
}
