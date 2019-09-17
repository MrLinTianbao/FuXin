//
//  CacheEnum.swift
//  CityTube
//
//  Created by DUONIU_MAC on 2019/6/5.
//  Copyright © 2019年 DUONIU_MAC. All rights reserved.
//

import Foundation

enum UDObject : String {
    
    case language_code //语言
    case token
    case groupid//会员组ID，默认0为普通用户，5为客服，6为机器人
    case addFriendCertification //是否开启好友验证
    
    //用户资料
    case username //用户名，即：邮箱号
    case nickname //昵称
    case avatar //用户头像地址
    case money //账户可以余额，单位：元
    case mobile //手机号码，如：13888888888
    case mobile_code //手机区号，默认为+86、美国为：+1
    case is_adding_friend_certification //加我为好友时需要验证，true为是，false为否
    case addtime //注册时间，格式如：2019-01-01 12:43:50
    case qrcode //用户二维码
    case pay_pass //是否设置支付密码
    case customer_type //客服类型
    case invitation //邀请码
    case cover //朋友圈封面
    case mid //id
    
    case customServiceList //客服列表
    case groupJoinList //群成员加入列表

}
