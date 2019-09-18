//
//  FXRedModel.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/7/22.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

@objcMembers
class FXRedModel: NSObject,NSCoding {
    
    var hb_infor : FXRedInfoModel? //红包详情
    var message : String?
    var type : String? //类型
    var status : String? //红包状态 0未领取 1已领取 2超时退回红包

    
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.hb_infor, forKey: "hb_infor")
        aCoder.encode(self.message, forKey: "message")
        aCoder.encode(self.type, forKey: "type")
        aCoder.encode(self.status, forKey: "status")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        self.hb_infor = aDecoder.decodeObject(forKey: "hb_infor") as? FXRedInfoModel
        self.message = aDecoder.decodeObject(forKey: "message") as? String
        self.type = aDecoder.decodeObject(forKey: "type") as? String
        self.status = aDecoder.decodeObject(forKey: "status") as? String
        
    }
    

    override init() {
        super.init()
    }
}
