//
//  CODImageHeaderNode.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/27.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation

class CODImageHeaderNode: CODImageNode {
    
    
    convenience init(url: URL?, placeholderImage: UIImage? = nil) {
        
        self.init()
        
        dispatch_async_safely_to_main_queue {
            
            self.imageView.cod_loadHeaderByCache(url: url)
            
        }
        
        
                
    }
    
    func setImage(image: UIImage?) {
        
        self.imageView.image = image
        
    }
    
    override func setImageURL(_ url: URL?, placeholderImage: UIImage? = nil) {
        
        self.imageView.cod_loadHeaderByCache(url: url)
        
    }
    
}
