//
//  PersonRedModel.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/7/28.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

@objcMembers
class PersonRedModel: NSObject {

    var amount : String? //红包金额
    var blessing : String? //祝福语
    var status : String? //红包领取状态
    var addtime : String? //红包时间
    var mid : String? //领取红包的用户ID
    var username : String? //发红包的用户名
    var get_mid : String? //收取红包的用户ID
    var get_username : String? //收取红包的用户名
    var avatar : String? //用户头像
    var get_avatar : String? //领取者头像
}
