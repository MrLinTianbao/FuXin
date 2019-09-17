//
//  MessageModel.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/6/2.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

@objcMembers
class MessageModel: NSObject {

    var id: String? //广告ID
    var adv_title: String? //广告标题
    var adv_image: String? //广告图片链接
    var adv_url: String? //点击广告要跳转的链接地址
    var adv_sort: String? //排序值
    var class_id: String? //广告位ID
    var adv_code: String? //广告代码
    var start_time: String? //广告开始时间
    var end_time: String? //广告结束时间
    var addtime: String? //广告结束时间
}
