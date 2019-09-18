//
//  JCTransferContent.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/7/24.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class JCTransferContent: NSObject,JCMessageContentType {

    weak var delegate: JCMessageDelegate?
    
    
    //    public weak var redDelegate: JCRedMessageDelegate?
    open var layoutMargins: UIEdgeInsets = .zero
    
    open class var viewType: JCMessageContentViewType.Type {
        return JCTransferContentView.self
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
//    open var user : JMSGUser!
    
    
    open func sizeThatFits(_ size: CGSize) -> CGSize {
        return .init(width: 200, height: 87)
    }
}
