//
//  WalletRecordModel.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/8/1.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

@objcMembers
class WalletRecordModel: NSObject {

    var id : String? //流水ID
    var type : String? //类型，0为收入，1为支出
    var opt_mid : String? //对方用户ID，如果type为0则为付款人ID，type为1时则为收款人ID，值为0时为平台官方，如：80
    var opt_account : String? //对方账号/手机号，如果type为0则为付款人账号，type为1时则为收款人账号，如：13798764555
    var last_amount : String? //变动后的金额
    var change_amount : String? //变动金额
    var change_title : String? //流水标题，如：订单号: 9 (收入)
    var change_type : String? //流水类型，0为充值流水，1为提现流水，2为赔款流水，3为退款流水，4为发红包流水，5为领取红包流水，6为转账流水
    var create_time : String? //流水创建时间
    var red_id : String? //红包ID
    var tags : String? //流水标签
}
