//
//  RayRedModel.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/7/28.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

@objcMembers
class RayRedModel: NSObject {
    
    var mid : String? //领取红包的用户ID
    var addtime : String? //领取红包的时间
    var amount : String? //领取红包的金额
    var reward : String? //平台奖励金额
    var is_hit : String? //是否中雷，0为未中，1为中雷
    var username : String? //领取红包的用户名
    var indemnity : String? //中雷后赔给发包人的金额
    var avatar : String? //用户头像
    var user_type : String? //用户类型，0为普通用户，1为首抢机器人，2为智能机器人
    
}
