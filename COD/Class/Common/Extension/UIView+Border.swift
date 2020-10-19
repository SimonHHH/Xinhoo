//
//  UIView+Border.swift
//  COD
//
//  Created by Sim Tsai on 2020/5/14.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation



extension UIView {
    
    
    public enum BorderSide: String {
        case top
        case right
        case bottom
        case left
    }
    
    public struct BorderSides: OptionSet {
        
        public let rawValue: Int
        
        public static let unknown = BorderSides(rawValue: 0)
        
        public static let top = BorderSides(rawValue: 1)
        public static let right = BorderSides(rawValue: 1 << 1)
        public static let bottom = BorderSides(rawValue: 1 << 2)
        public static let left = BorderSides(rawValue: 1 << 3)
        
        public static let AllSides: BorderSides = [.top, .right, .bottom, .left]
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        
        init(side: BorderSide?) {
            guard let side = side else {
                self = .unknown
                return
            }
            
            switch side {
            case .top: self = .top
            case .right: self = .right
            case .bottom: self = .bottom
            case .left: self = .left
            }
        }
    }
    
    private func clearLayer() {
        self.layer.borderColor = nil
        self.layer.borderWidth = 0
        self.layer.sublayers?.filter { $0.name == "borderSideLayer" || $0.name == "borderAllSides" }
            .forEach { $0.removeFromSuperlayer() }
    }
    
    
    
    func addBorder(toSide sides: BorderSides, withColor color: UIColor, borderWidth: CGFloat = 0.5, offset: UIEdgeInsets = .zero) {
        
        self.clearLayer()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "borderSideLayer"
        shapeLayer.path = makeBorderPath(toSide: sides, in: self.bounds, borderWidth:  borderWidth, offset: offset).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = borderWidth
        shapeLayer.frame = self.bounds
        
        self.layer.insertSublayer(shapeLayer, at: 0)
        
        
    }
    
    private func makeBorderPath(toSide sides: BorderSides, in bounds: CGRect, borderWidth: CGFloat = 0.5, offset: UIEdgeInsets = .zero) -> UIBezierPath {
        let lines = makeLines(toSide: sides, in: bounds, borderWidth: borderWidth, offset:  offset)
        let borderPath = UIBezierPath()
        lines.forEach {
            borderPath.move(to: $0.start)
            borderPath.addLine(to: $0.end)
        }
        return borderPath
    }
    
    private func makeLines(toSide sides: BorderSides, in bounds: CGRect, borderWidth: CGFloat = 0.5, offset: UIEdgeInsets = .zero) -> [(start: CGPoint, end: CGPoint)] {
        
        let shift = borderWidth / 2
        var lines = [(start: CGPoint, end: CGPoint)]()
        

        if sides.contains(.top) {
            lines.append((start: CGPoint(x: 0 + offset.left, y: shift), end: CGPoint(x: bounds.maxX - offset.right, y: shift)))
        }
        if sides.contains(.right) {
            lines.append((start: CGPoint(x: bounds.size.width - shift, y: 0 + offset.top), end: CGPoint(x: bounds.size.width - shift, y: bounds.maxY - offset.bottom)))
        }
        if sides.contains(.bottom) {
            lines.append((start: CGPoint(x: 0 + offset.left, y: bounds.size.height - shift), end: CGPoint(x: bounds.maxX - offset.right, y: bounds.size.height - shift)))
        }
        if sides.contains(.left) {
            lines.append((start: CGPoint(x: shift, y: 0 + offset.top), end: CGPoint(x: shift, y: bounds.maxY - offset.bottom)))
        }
        return lines
    }
    
    
}

extension UIEdgeInsets {
    
    var horizontal: CGFloat {
        return self.left + self.right
    }
    
    var vertical: CGFloat {
        return self.top + self.bottom
    }
    
}
