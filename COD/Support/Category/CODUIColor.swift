//
//  CODUIColor.swift
//  COD
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

extension UIColor {
    //这个是tabBar选中的颜色
    class var barBarSelectColor: UIColor {
        get{
            return UIColor.init(hexString: "#68BB1E")!
        }
    }
    class var titleWhiteColor: UIColor {
        get{
            return UIColor.init(hexString: "#FFFFFF")!
        }
    }
    class var titleBlackColor: UIColor {
        get{
            return UIColor.init(hexString: "#111111")!
        }
    }
    class var titleLightColor: UIColor {
        get{
            return UIColor.init(hexString: "#AAAAAA")!
        }
    }
    class var lineLightColor: UIColor {
        get{
            return UIColor.init(hexString: "#DDDDDD")!
        }
    }
    class var viewBackgroundColor: UIColor {
        get{
            return UIColor.init(hexString: "#EFEFF4")!
        }
    }
    class var colorGrayForChatBar: UIColor {
        get{
            return UIColor.init(hexString: "#F5F5F7")!
        }
    }
    

    class func interpolation(from: CGFloat, to: CGFloat, percent: CGFloat) -> CGFloat {
        let percent = max(0, min(1, percent))
        return from + (to - from) * percent
    }
    
    class func interpolationColor(from: UIColor, to: UIColor, percent: CGFloat) -> UIColor {
        
        
        let red = self.interpolation(from: from.cod_red, to: to.cod_red, percent: percent)
        let green = self.interpolation(from: from.cod_green, to: to.cod_green, percent: percent)
        let blue = self.interpolation(from: from.cod_blue, to: to.cod_blue, percent: percent)
        let alpha = self.interpolation(from: from.cod_alpha, to: to.cod_alpha, percent: percent)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        
    }
    
    var cod_red: CGFloat {
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: nil, blue: nil, alpha: nil)
        
        return red
    }
    
    var cod_green: CGFloat {
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(nil, green: &green, blue: nil, alpha: nil)
        
        return green
    }
    
    var cod_blue: CGFloat {
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(nil, green: nil, blue: &blue, alpha: nil)
        
        return blue
    }
    
    
    var cod_alpha: CGFloat {
        return self.cgColor.alpha
    }
    
}

