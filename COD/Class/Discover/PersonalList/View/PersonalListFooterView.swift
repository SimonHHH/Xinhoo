//
//  PersonalListFooterView.swift
//  COD
//
//  Created by Sim Tsai on 2020/8/12.
//  Copyright (c) 2020 XinHoo. All rights reserved.
//

import UIKit

@IBDesignable
class PersonalListFooterView: UIView {

    // Our custom view from the XIB file
    var view: UIView!

    /**
     Initialiser method
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    /**
     Initialiser method
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    /**
     Sets up the view by loading it from the xib file and setting its frame
     */
    func setupView() {
        view = loadViewFromXibFile()
        self.frame = CGRect(origin: .zero, size: CGSize(width: KScreenWidth, height: 60))
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

    /**
     Loads a view instance from the xib file
     - returns: loaded view
     */
    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "PersonalListFooterView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
