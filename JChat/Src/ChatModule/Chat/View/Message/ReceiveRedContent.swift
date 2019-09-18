//
//  ReceiveRedContent.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/7/22.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class ReceiveRedContent: NSObject,JCMessageContentType {
    
    
    func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize.init(width: ScreenW, height: 50)
    }
    

    public weak var delegate: JCMessageDelegate?
    open var layoutMargins: UIEdgeInsets = .zero
    
    open class var viewType: JCMessageContentViewType.Type {
        return ReceiveRedContentView.self
    }
    
    public init(username: String) {
        super.init()
        
        self.username = username
    }
    
    internal var before: JCMessageType?
    internal var after: JCMessageType?
    
    open var username: String?
    
    
    
}

