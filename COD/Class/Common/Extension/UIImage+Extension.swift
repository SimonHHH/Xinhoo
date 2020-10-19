//
//  UIImage+Extension.swift
//  COD
//
//  Created by 1 on 2019/4/3.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

extension UIImage {
    
    

}

extension UIImage {
    
    enum GradientStartPoint {
        case left
        case right
        case top
        case bottom
        case topRight
        case bottomRight
        case topLeft
        case bottomLeft
    }
    
    //颜色转图片
    class func imageFromColor(color: UIColor, viewSize: CGSize) -> UIImage{
        
        let rect: CGRect = CGRect(x: 0, y: 0, width: viewSize.width, height: viewSize.height)
        
        UIGraphicsBeginImageContext(rect.size)
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(color.cgColor)
        
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsGetCurrentContext()
        
        return image!
        
    }
    //    修改图片的颜色
    func imageWithTintColor(tintColor:UIColor, blendMode:CGBlendMode) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        tintColor.setFill()
        
        let bounds = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIRectFill(bounds)
        self.draw(in: bounds, blendMode: blendMode, alpha: 1.0)
        if blendMode != .destinationIn {
            self.draw(in: bounds, blendMode: .destinationIn, alpha: 1.0)
        }
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
    
    //截取视频的图片
    //获取本地视频的第一帧图片
    class func getVideoSecondImage(videoURL:String?) -> UIImage?{
        if videoURL == nil{
            return nil
        }
        let otherAsset = AVURLAsset(url: URL.init(fileURLWithPath: videoURL!, isDirectory: false), options: nil)
        let asset = AVURLAsset(url: URL(fileURLWithPath: videoURL!), options: nil)
        let gen = AVAssetImageGenerator(asset: asset)
        gen.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
        var actualTime:CMTime = CMTimeMake(value: 0,timescale: 0)
        var image:CGImage?
        do{
            image = try gen.copyCGImage(at: time, actualTime: &actualTime)
        }catch{
            return nil
        }
        let videoImage = UIImage(cgImage: image!)
        return videoImage
    }
    
    //    截取网络视频的第一帧图片
    class func getNetWorkVideoImage(videoURL:String?,complete:@escaping(_ image:UIImage?) -> Void){
        if videoURL == nil{
            complete(nil)
            return
        }
        DispatchQueue.global().async {
            let asset = AVURLAsset(url: URL(fileURLWithPath: videoURL!), options: nil)
            let gen = AVAssetImageGenerator(asset: asset)
            gen.appliesPreferredTrackTransform = true
            let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
            var actualTime:CMTime = CMTimeMake(value: 0,timescale: 0)
            var image:CGImage?
            do{
                image = try gen.copyCGImage(at: time, actualTime: &actualTime)
            }catch{
                complete(nil)
                return
            }
            let videoImage = UIImage(cgImage: image!)
            DispatchQueue.main.async {
                complete(videoImage)
            }
        }
    }
}
extension UIImage {
    /// 依据宽度等比例对图片重新绘制
    ///
    /// - Parameters:
    ///   - originalImage: 原图
    ///   - scaledWidth: 将要缩放或拉伸的宽度
    /// - Returns: 新的图片
    class func image(originalImage:UIImage? ,to scaledWidth:CGFloat) -> UIImage? {
        guard let image = originalImage else {
            return UIImage.init()
        }
        let imageWidth = image.size.width
        let imageHeigth = image.size.height
        let width = scaledWidth
        let height = image.size.height / (image.size.width / width)
        
        let widthScale = imageWidth / width
        let heightScale = imageHeigth / height
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        
        if widthScale > heightScale {
            image.draw(in: CGRect(x: 0, y: 0, width: imageWidth / heightScale, height: heightScale))
        } else {
            image.draw(in: CGRect(x: 0, y: 0, width: width, height: imageHeigth / widthScale))
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

 extension UIImage {
     // 修复图片旋转
     func fixOrientation() -> UIImage {
         if self.imageOrientation == .up {
             return self
         }
         
         var transform = CGAffineTransform.identity
         
         switch self.imageOrientation {
         case .down, .downMirrored:
             transform = transform.translatedBy(x: self.size.width, y: self.size.height)
             transform = transform.rotated(by: .pi)
             break
             
         case .left, .leftMirrored:
             transform = transform.translatedBy(x: self.size.width, y: 0)
             transform = transform.rotated(by: .pi / 2)
             break
             
         case .right, .rightMirrored:
             transform = transform.translatedBy(x: 0, y: self.size.height)
             transform = transform.rotated(by: -.pi / 2)
             break
             
         default:
             break
         }
         
         switch self.imageOrientation {
         case .upMirrored, .downMirrored:
             transform = transform.translatedBy(x: self.size.width, y: 0)
             transform = transform.scaledBy(x: -1, y: 1)
             break
             
         case .leftMirrored, .rightMirrored:
             transform = transform.translatedBy(x: self.size.height, y: 0);
             transform = transform.scaledBy(x: -1, y: 1)
             break
             
         default:
             break
         }
         
         let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
         ctx?.concatenate(transform)
         
         switch self.imageOrientation {
         case .left, .leftMirrored, .right, .rightMirrored:
             ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
             break
             
         default:
             ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
             break
         }
         
         let cgimg: CGImage = (ctx?.makeImage())!
         let img = UIImage(cgImage: cgimg)
         
         return img
     }
    

    
    class func gradientImage(size: CGSize, startColor: UIColor, endColor: UIColor, direction: GradientStartPoint) -> UIImage? {
        
        UIGraphicsBeginImageContext(size)
        
        guard let currentContext = UIGraphicsGetCurrentContext() else { return nil }
        
        let path = CGMutablePath()
        let rect = CGRect(origin: .zero, size: size)
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let startColorComponents = startColor.cgColor.components else { return nil }
            
        guard let endColorComponents = endColor.cgColor.components else { return nil }
            
        let colorComponents: [CGFloat]
                = [startColorComponents[0], startColorComponents[1], startColorComponents[2], startColorComponents[3], endColorComponents[0], endColorComponents[1], endColorComponents[2], endColorComponents[3]]
            
        let locations:[CGFloat] = [0.0, 1.0]
        
        guard let gradient = CGGradient(colorSpace: colorSpace,colorComponents: colorComponents,locations: locations,count: 2) else { return nil }
        
        var startPoint = CGPoint.zero
        var endPoint = CGPoint.zero
        
        switch direction {
        case .left:
            startPoint = CGPoint(x: rect.minX, y: rect.midY)
            endPoint = CGPoint(x: rect.maxX, y: rect.midY)
        case .right:
            startPoint = CGPoint(x: rect.maxX, y: rect.midY)
            endPoint = CGPoint(x: rect.minX, y: rect.midY)
        case .top:
            startPoint = CGPoint(x: rect.midX, y: rect.midY)
            endPoint = CGPoint(x: rect.midX, y: rect.maxY)
        case .bottom:
            startPoint = CGPoint(x: rect.midX, y: rect.maxY)
            endPoint = CGPoint(x: rect.midX, y: rect.minY)
        case .topRight:
            startPoint = CGPoint(x: rect.maxX, y: rect.minY)
            endPoint = CGPoint(x: rect.minX, y: rect.maxY)
        case .bottomRight:
            startPoint = CGPoint(x: rect.maxX, y: rect.maxY)
            endPoint = CGPoint(x: rect.minX, y: rect.minY)
        case .topLeft:
            startPoint = CGPoint(x: rect.minX, y: rect.minY)
            endPoint = CGPoint(x: rect.maxX, y: rect.maxY)
        case .bottomLeft:
            startPoint = CGPoint(x: rect.minX, y: rect.maxY)
            endPoint = CGPoint(x: rect.maxX, y: rect.minY)
        }
        


        currentContext.addPath(path)
        currentContext.clip()
        
        currentContext.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: UInt32(0)))
        
        currentContext.restoreGState()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
        
    }
    
//
//    @implementation UIImage (Gradient)
//
//    - (instancetype)initGradientImageWithSize:(CGSize)size startColor:(UIColor*)startColor endColor:(UIColor*)endColor direction:(UIImageGradientStartPoint)direction  {
//
//        UIGraphicsBeginImageContext(size);
//        CGContextRef gc = UIGraphicsGetCurrentContext();
//
//        // 创建画布
//        CGMutablePathRef path = CGPathCreateMutable();
//        CGRect rect = CGRectMake(0, 0, size.width, size.height);
//        CGPathMoveToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect));
//        CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect));
//        CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
//        CGPathAddLineToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect));
//        CGPathCloseSubpath(path);
//
//        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//
//        CGFloat locations[] = { 0.0, 1.0 };
//
//        NSArray *colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
//
//        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
//
//        CGContextSaveGState(gc);
//
//        CGPoint startPoint = CGPointZero;
//        CGPoint endPoint = CGPointZero;
//
//        switch (direction) {
//            case UIImageGradientStartPointLeft:
//                startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
//                endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
//                break;
//            case UIImageGradientStartPointTop:
//                startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
//                endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
//                break;
//            case UIImageGradientStartPointRight:
//                startPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
//                endPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
//                break;
//            case UIImageGradientStartPointBottom:
//                startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
//                endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
//                break;
//            case UIImageGradientStartPointTopLeft:
//                startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
//                endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
//                break;
//            case UIImageGradientStartPointTopRight:
//                startPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
//                endPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
//                break;
//
//            case UIImageGradientStartPointBotoomLeft:
//                startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
//                endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
//                break;
//
//            case UIImageGradientStartPointBottomRight:
//                startPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
//                endPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
//                break;
//
//            default:
//                break;
//        }
//
//
//        CGContextRestoreGState(gc);
//
//        CGContextAddPath(gc, path);
//        CGContextClip(gc);
//
//        CGContextDrawLinearGradient(gc, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);
//
//        CGGradientRelease(gradient);
//        CGColorSpaceRelease(colorSpace);
//
//        CGPathRelease(path);
//
//        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//
//        return img;
//
//
//
//    }
//
//    @end
 }
