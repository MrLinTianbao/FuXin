//
//  JCMessageTextContentView.swift
//  JChat
//
//  Created by JIGUANG on 2017/3/9.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit

open class JCMessageTextContentView: KILabel, JCMessageContentViewType {

//    var imageView : UIImageView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return super.canPerformAction(action, withSender: sender)
    }
    
    open func apply(_ message: JCMessageType) {
        guard let content = message.content as? JCMessageTextContent else {
            return
        }
        
        if message.options.alignment == .right {
            let mattr = NSMutableAttributedString.init(string: content.text.string)
            mattr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSMakeRange(0, mattr.length))
            mattr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16), range: NSMakeRange(0, mattr.length))
        
            self.attributedText = mattr
        }else{
            self.attributedText = content.text
        }
        
        
        
        
        
        
        
        
        self.linkDetectionTypes = KILinkTypeOption.URL
        self.urlLinkTapHandler = { label, url, range in
            if let Url = URL(string: url) {
                if UIApplication.shared.canOpenURL(Url) {
                    UIApplication.shared.openURL(Url)
                } else {
                    let newUrl = URL(string: "https://" + url)
                    UIApplication.shared.openURL(newUrl!)
                }
            }
        }
    }
    
    private func _commonInit() {
        self.numberOfLines = 0
        self.textColor = UIColor.white

    }
}


