//
//  CODDiscoverDetailPrivateFooterView.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/24.
//  Copyright (c) 2020 XinHoo. All rights reserved.
//

import UIKit

@IBDesignable
class CODDiscoverDetailPrivateFooterView: UIView {

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
        let nib = UINib(nibName: "CODDiscoverDetailPrivateFooterView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
