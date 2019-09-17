//
//  JCMessageNoticeContentView.swift
//  JChat
//
//  Created by JIGUANG on 2017/3/9.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit

open class JCMessageNoticeContentView: UILabel, JCMessageContentViewType {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }

    
    open func apply(_ message: JCMessageType) {
        guard let content = message.content as? JCMessageNoticeContent else {
            return
        }
        
        text = " " + content.text
        
        if content.isRed {
            
            let attchment = NSTextAttachment()
            attchment.bounds = .init(x: 0, y: -3, width: 12, height: 15)
            attchment.image = UIImage.init(named: "notReceive")
            
            let attImage = NSAttributedString.init(attachment: attchment)
            
            var attText : NSAttributedString!
            
            if content.money != "" {
                attText = text?.setTextFont(color: UIColor.setRGB(0xC6482F), fontSize: 12, ranStr: content.money)
            }else{
                attText = text?.setTextFont(color: UIColor.setRGB(0xC6482F), fontSize: 12, ranStr: " 红包")
            }
            
            
            
            
            let attStr = NSMutableAttributedString()
            attStr.append(attImage)
            attStr.append(attText!)
        
            
            attributedText = attStr
            
        }
    }
    
    private func _commonInit() {
        layer.cornerRadius = 5
//        layer.borderWidth = 1.0
//        layer.borderColor = UIColor(netHex: 0xD7DCE2).cgColor
        layer.masksToBounds = true
        font = UIFont.systemFont(ofSize: 12)
        backgroundColor = UIColor.black.withAlphaComponent(0.1)//UIColor(netHex: 0xD7DCE2)
        textColor = UIColor.setRGB(0x4c4c4c)
        textAlignment = .center
        numberOfLines = 0
    }
}
