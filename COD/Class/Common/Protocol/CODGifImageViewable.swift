//
//  CODGifImageViewable.swift
//  COD
//
//  Created by Sim Tsai on 2019/12/24.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import Foundation
import FLAnimatedImage

protocol CODGifImageViewable where Self: UIImageView {
    
    func setGifImage(identifier: String)
    
//    var animatedImage: FLAnimatedImage! { set get }
    
    
}

extension FLAnimatedImageView: CODGifImageViewable {
    
    func setGifImage(identifier: String) {
        
        guard let dataUrl =  Bundle.main.url(forResource: identifier, withExtension: "gif"),
        let data = try? Data(contentsOf: dataUrl) else {
            return
        }
        
        let image = FLAnimatedImage(animatedGIFData: data)
        self.animatedImage = image
    }

}

extension SDAnimatedImageView: CODGifImageViewable {
    
    func setGifImage(identifier: String) {
        
        guard let dataUrl =  Bundle.main.url(forResource: identifier, withExtension: "gif"),
        let data = try? Data(contentsOf: dataUrl) else {
            return
        }
        
//        let image = FLAnimatedImage(animatedGIFData: data)
        self.image = SDAnimatedImage(data: data)
        self.contentMode = .scaleAspectFit
    }

}

