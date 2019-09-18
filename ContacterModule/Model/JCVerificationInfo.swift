//
//  JCVerificationInfo.swift
//  JChat
//
//  Created by JIGUANG on 14/04/2017.
//  Copyright © 2017 HXHG. All rights reserved.
//

import UIKit


enum JCVerificationType: Int {
    case wait
    case accept
    case reject
    case receive
}


class JCVerificationInfo: NSObject {
    var id = 0
    var username: String = ""
    var nickname: String = ""
    var appkey: String = ""
    var resaon: String = ""
    var state: Int = 0
    
    static func create(username: String, nickname: String?, appkey: String, resaon: String?, state: Int) ->  JCVerificationInfo {
        let info = JCVerificationInfo()
        info.username = username
        info.nickname = nickname ?? ""
        info.appkey = appkey
        info.resaon = resaon ?? ""
        info.state = state
        return info
    }
}

@objcMembers
class JCGroupJoinInfoModel: NSObject {
    var eventID :  String = ""
    var username: String = ""
    var nickname: String = ""
    var groupID: String = ""
    var resaon: String = ""
    var state: Int = 0
    var uid: Int64 = 0
//    static func create(username: String, nickname: String?, appkey: String, resaon: String?, state: Int) ->  JCGroupJoinInfoModel {
//        let info = JCGroupJoinInfoModel()
//        info.username = username
//        info.nickname = nickname ?? ""
//        info.appkey = appkey
//        info.resaon = resaon ?? ""
//        info.state = state
//        return info
//    }
    
//    "eventID":event.eventID,
//    "groupID":event.groupID,
//    "username":event.sendApplyUser.username,
//    "nickname":event.sendApplyUser.nickname
}
