//
//  Notification+Extend.swift
//  CityTube
//
//  Created by DUONIU_MAC on 2019/6/5.
//  Copyright © 2019年 DUONIU_MAC. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    
    //微信登录
    static public let wechat_login = Notification.Name(rawValue: "wechat_login")
    //聊天页面滑动至底部
    static public let chatScrollToLast = Notification.Name(rawValue: "scrollToLast")
    //未读消息数
    static public let unReadCount = Notification.Name(rawValue: "unReadCount")
    //清空未读消息数
    static public let clearUnReadCount = Notification.Name(rawValue: "clearUnReadCount")
    //刷新列表
    static public let reloadMessageList = Notification.Name(rawValue: "reloadMessageList")
    
}
