//
//  FXRedInfoModel.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/7/22.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

@objcMembers
class FXRedInfoModel: NSObject {

    var blessing : String?
    var hb_extra : String? // 红包备注
    var hb_id : String? //红包id
    var hb_money : String? //红包金额
    var hb_num : String? //红包数量
    var hb_create_time : String? //创建时间
    var received_id : String? //群id或者个人id
    var send_user_id : String? //发送着id
    var is_group = false //是否是群
    
}
