//
//  DDXMLElementExt.swift
//  COD
//
//  Created by Sim Tsai on 2020/7/3.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation
import SwiftyJSON

extension DDXMLNode {
    
    func getChildrenJSON(name: String) -> JSON? {
        
        if let child = self.getChild(name: name) {
            
            return JSON(parseJSON: child.stringValue ?? "")
            
        }
        
        return nil
        
    }
    
    func getChild(name: String) -> DDXMLNode? {
        
        if let children = self.children {
            for child in children {
                if child.name == name {
                    return child
                }

            }
            
        }
        
        return nil
        
    }
    
    func getNode(name: String) -> DDXMLNode? {
        
        var node: DDXMLNode = self
        
        if node.name == name {
            return node
        }
        
        while (true) {
            
            if let child = node.getChild(name: name) {
                return child
            }

            if let nextNode = node.next {
                node = nextNode
            } else {
                break
            }
            
            
        }
        
        return nil
        
    }
    
    func getJSON(name: String) -> JSON? {
        
//        whileu
        
        var node: DDXMLNode = self
        
        while (true) {
            
            if let json = node.getChildrenJSON(name: name) {
                return json
            }
            
            if let nextNode = node.next {
                node = nextNode
            } else {
                break
            }
            
        }
        
        return nil

    }
    
    func setJSON(to name: String, json: JSON) {
        
        if let node = getNode(name: name) {
            
            if let dic = json.dictionaryObject, let string = dic.jsonString() {
                node.stringValue = string
            } else if let arr = json.arrayObject, let string = arr.jsonString() {
                node.stringValue = string
            }
            
        }
        
    }
    
}
