//
//  JCBusinessCardContent.swift
//  JChat
//
//  Created by JIGUANG on 2017/8/31.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit

class JCRedContent: NSObject, JCMessageContentType {
    
    
     weak var delegate: JCMessageDelegate?
    

//    public weak var redDelegate: JCRedMessageDelegate?
    open var layoutMargins: UIEdgeInsets = .zero
    
    open class var viewType: JCMessageContentViewType.Type {
        return JCRedContentView.self
    }
    
    open var status = 0
    open var amount : String?
    open var count : String?
    open var noteText : String?
    open var userName: String?
    open var appKey: String?
    open var redUid : String?
    open var nickName : String?
    open var sendUid : String!
    open var blessing : String!
    open var sendTime : String!
    open var sy_hb_num : String!
    open var hb_num : String!
//    open var user : JMSGUser!
    
    
    open func sizeThatFits(_ size: CGSize) -> CGSize {
        return .init(width: 200, height: 87)
    }

}
