//
//  UIView+Constraint.swift
//  Balloon
//
//  Created by Gaétan Zanella on 11/02/2019.
//  Copyright © 2019 Gaétan Zanella. All rights reserved.
//

import UIKit

extension UIView {
    func pinToSuperview(with insets: UIEdgeInsets = .zero, edges: UIRectEdge = .all) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        if edges.contains(.top) {
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top).isActive = true
        }
        if edges.contains(.bottom) {
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom).isActive = true
        }
        if edges.contains(.left) {
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left).isActive = true
        }
        if edges.contains(.right) {
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right).isActive = true
        }
    }
}

extension UITableViewCell {
//    func flashingCell() {
//        UIView.animate(withDuration: 0.25, animations: {
//            self.contentView.backgroundColor = UIColor.init(hexString: "007EE5")?.withAlphaComponent(0.5)
//        }) { (finish) in
//            
//            UIView.animate(withDuration: 0.25, animations: {
//                self.contentView.backgroundColor = .clear
//            }, completion: { (finish) in
//                UIView.animate(withDuration: 0.25, animations: {
//                    self.contentView.backgroundColor = UIColor.init(hexString: "007EE5")?.withAlphaComponent(0.5)
//                }) { (finish) in
//                    
//                    UIView.animate(withDuration: 0.25, animations: {
//                        self.contentView.backgroundColor = .clear
//                    }, completion: { (finish) in
//                        
//                    })
//                }
//            })
//        }
//    }
}
