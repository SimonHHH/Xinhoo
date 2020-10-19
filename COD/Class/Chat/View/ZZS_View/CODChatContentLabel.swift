//
//  CODChatContentLabel.swift
//  COD
//
//  Created by Sim Tsai on 2020/1/11.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit



class CODChatContentLabel: YYLabel {
    
    let timeLab = XinhooTimeAndReadView()

    func config(content: NSMutableAttributedString, timeAtt: NSMutableAttributedString, nikeName: NSMutableAttributedString? = nil, maxWidth: CGFloat, rpTapViewWidth: CGFloat = 0, nickNameWidth: CGFloat = 0, status: XinhooTimeAndReadView.Status = .unknown, style: XinhooTimeAndReadView.Style = .blue){
        
        
        timeLab.viewType = XinhooTimeAndReadView.ViewType.text.rawValue
        
        timeLab.set(nikename: nikeName, time: timeAtt, status: status, style: style)
        
        let exWidth = nickNameWidth > rpTapViewWidth ? nickNameWidth : rpTapViewWidth
        let realMaxWidth = exWidth > maxWidth ? exWidth : maxWidth
        
        
        guard var textLayout = YYTextLayout(containerSize: CGSize(width: realMaxWidth, height: CGFloat.greatestFiniteMagnitude), text: content),
            var lastLineWidth = textLayout.lines.last?.width else {
                return
        }
        
        timeLab.size = timeLab.systemLayoutSizeFitting(CGSize(width: realMaxWidth - 4, height: CGFloat.greatestFiniteMagnitude))
        
        if timeLab.size.width > realMaxWidth {
            timeLab.size.width = realMaxWidth
        }
        
        var lastLeftWidth = maxWidth - lastLineWidth
        var bodyWidth = textLayout.textBoundingSize.width > exWidth ? textLayout.textBoundingSize.width : exWidth
        
        if timeLab.width > lastLeftWidth {
            content.yy_appendString(" ")
            textLayout = YYTextLayout(containerSize: CGSize(width: realMaxWidth, height: CGFloat.greatestFiniteMagnitude), text: content) ?? textLayout
            lastLineWidth = textLayout.lines.last?.width ?? lastLineWidth
            lastLeftWidth = maxWidth - lastLineWidth
            bodyWidth = textLayout.textBoundingSize.width > exWidth ? textLayout.textBoundingSize.width : exWidth
            
            
        }
        
        bodyWidth = bodyWidth > maxWidth ?  maxWidth : bodyWidth
        

        if timeLab.width > lastLeftWidth {
            
            if timeLab.size.width < bodyWidth {
                timeLab.size.width = bodyWidth
            }
            
        } else if content.string.last == "\n" {
            
            if timeLab.size.width < bodyWidth {
                timeLab.size.width = bodyWidth
            }
            
        } else  {
            let bodyLeftWidth =  (bodyWidth - lastLineWidth) - 8
            if bodyWidth > lastLineWidth  &&  bodyLeftWidth > timeLab.width {
                timeLab.width = bodyLeftWidth
            }  else if lastLeftWidth < timeLab.width {
                timeLab.width = bodyWidth
            } else if lastLeftWidth - timeLab.width < 4 {
                timeLab.width = bodyWidth
            }
            
        }
        
        
        let newTimeAtt = NSMutableAttributedString.yy_attachmentString(withContent: timeLab, contentMode: .bottomRight, attachmentSize: timeLab.size, alignTo: font, alignment: .bottom)
        
        
        content.append(newTimeAtt)
        
        self.attributedText = content
        
        
    }
    
    func config(content: NSMutableAttributedString, timeAtt: NSMutableAttributedString, nikeName: NSMutableAttributedString? = nil, maxWidth: CGFloat, minWidth: CGFloat, status: XinhooTimeAndReadView.Status = .unknown, style: XinhooTimeAndReadView.Style = .blue){
        
        
        timeLab.viewType = XinhooTimeAndReadView.ViewType.text.rawValue
        
        timeLab.set(nikename: nikeName, time: timeAtt, status: status, style: style)
        
        let realMaxWidth = maxWidth

        guard var textLayout = YYTextLayout(containerSize: CGSize(width: realMaxWidth, height: CGFloat.greatestFiniteMagnitude), text: content),
            var lastLineWidth = textLayout.lines.last?.width else {
                return
        }
        
        timeLab.size = timeLab.systemLayoutSizeFitting(CGSize(width: realMaxWidth, height: CGFloat.greatestFiniteMagnitude))
        
        if timeLab.size.width > realMaxWidth {
            timeLab.size.width = realMaxWidth
        }
        
        var lastLeftWidth = maxWidth - lastLineWidth
        var bodyWidth = textLayout.textBoundingSize.width > minWidth ? textLayout.textBoundingSize.width : minWidth
        
        if timeLab.width > lastLeftWidth {
            content.yy_appendString(" ")
            textLayout = YYTextLayout(containerSize: CGSize(width: realMaxWidth, height: CGFloat.greatestFiniteMagnitude), text: content) ?? textLayout
            lastLineWidth = textLayout.lines.last?.width ?? lastLineWidth
            lastLeftWidth = maxWidth - lastLineWidth
            bodyWidth = textLayout.textBoundingSize.width > minWidth ? textLayout.textBoundingSize.width : minWidth
        }
        
        bodyWidth = bodyWidth > maxWidth ?  maxWidth : bodyWidth
        

        if timeLab.width > lastLeftWidth {
            
            if timeLab.size.width < bodyWidth {
                timeLab.size.width = bodyWidth
            }
            
        } else if content.string.last == "\n" {
            
            if timeLab.size.width < bodyWidth {
                timeLab.size.width = bodyWidth
            }
            
        } else  {
            let bodyLeftWidth =  (bodyWidth - lastLineWidth)
            if bodyWidth > lastLineWidth  &&  bodyLeftWidth - 4 > timeLab.width {
                timeLab.width = bodyLeftWidth - 4
            }  else if lastLeftWidth < timeLab.width {
                timeLab.width = bodyWidth
            } else if lastLeftWidth - timeLab.width < 4 {
                timeLab.width = bodyWidth
            }
            
        }
        
        timeLab.set(nikename: nikeName, time: timeAtt, status: status, style: style)
        
        let newTimeAtt = NSMutableAttributedString.yy_attachmentString(withContent: timeLab, contentMode: .bottomRight, attachmentSize: timeLab.size, alignTo: font, alignment: .bottom)
        
        
        content.append(newTimeAtt)
        
        self.attributedText = content
        
        
    }
    
}
