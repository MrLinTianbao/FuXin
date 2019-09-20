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
    
}
