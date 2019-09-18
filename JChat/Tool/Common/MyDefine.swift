//
//  MyDefine.swift
//  CityTube
//
//  Created by DUONIU_MAC on 2019/6/5.
//  Copyright © 2019年 DUONIU_MAC. All rights reserved.
//

import Foundation
import UIKit

/// 获取Document目录
let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                        .userDomainMask, true)[0]

///加密公钥
let publicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA/CeyeU8m8j2TNf/Of9CFDGJhLTxKyumBYmGH3we8AjJAgeLEpwrRC40ZVmnnpF/GobYuqWNiT3juFeJEoxGXBZQIilcE3X201e/VBnRvvqh5VkLXmS1xIMepN6UofZC4TACGVvTSdHiNezyg+caGDmybPQF/aPzOAw5XAUsum/UfFzjKtakT9tHUFFNzmn/vnV9ZyiLTxOFm/Lt0nraLrHT/mPJx25+8iivjmLaDn6G6ThdsSWg084qHWJXh2MkRcpmqsq59u70lZ7A7nVVYiEabgUPWoMwpmu9WzQE0iWCWva6+xNJLUz9c8dWn5bCNsgWpAdF5b+H/xcHVld3xTQIDAQAB".replacingOccurrences(of: " ", with: "")

let kViewAwaitTime:Double = 1.2//等待时间

let weChatAppid = "wx314a1a4a27e9a3c6" //微信登录appid

/// 聊天默认头像
let chatDefaultHead = UIImage.init(named: "com_icon_user")
var chatGroupDefaultHead = UIImage.loadImage("com_icon_group_50")
/// 状态栏高度
var StatusBarHeight : CGFloat {
    return UIApplication.shared.statusBarFrame.size.height
}

/// 导航栏高度
var NAVBarHeight : CGFloat {
    return UINavigationController().navigationBar.bounds.size.height
}

/// 状态栏高度 + 导航栏高度
var StatusBarAddNavBarHeight : CGFloat {
    return StatusBarHeight + NAVBarHeight
}

/// 屏幕宽度
var ScreenW : CGFloat {
    return UIScreen.main.bounds.size.width
}

/// 屏幕高度
var ScreenH : CGFloat {
    return UIScreen.main.bounds.size.height
}

//MARK: 长度适配(以iPhone7为例)
func RATIO(_ num:CGFloat) -> CGFloat {
    return num * ((UIScreen.main.bounds.size.width) / 375.0)
}

func RATIO_H(_ num:CGFloat) -> CGFloat {
    return num * ((UIScreen.main.bounds.size.height) / 667.0)
}

func RATIO(maxNum:CGFloat) -> CGFloat {
    let a = maxNum * ((UIScreen.main.bounds.size.width) / 375.0)
    return a > maxNum ? maxNum : a
}

func RATIO_H(maxNum:CGFloat) -> CGFloat {
    let a = maxNum * ((UIScreen.main.bounds.size.height) / 667.0)
    return a > maxNum ? maxNum : a
}

//MARK: 获取数据保存路径
func getDocDir(path:String) -> String {
    
    let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                     .userDomainMask, true)[0] + "/\(path).data"
    return docDir
}

// MARK: - 打印方法
func MyLog<T>(_ message : T,file:String = #file,methodName: String = #function, lineNumber: Int = #line){
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    let dateForm = DateFormatter.init()
    dateForm.dateFormat = "HH:mm:ss:SSS"
    print("[\(fileName)][\(lineNumber)][\(dateForm.string(from: Date()))]\(methodName):\(message)")
    #endif
    
}

//MARK: 删除用户信息
func removeUseNews() {
    
    CacheClass.removeObjectForEnumKey(.username)
    CacheClass.removeObjectForEnumKey(.nickname)
    CacheClass.removeObjectForEnumKey(.avatar)
    CacheClass.removeObjectForEnumKey(.money)
    CacheClass.removeObjectForEnumKey(.mobile)
    CacheClass.removeObjectForEnumKey(.mobile_code)
    CacheClass.removeObjectForEnumKey(.groupid)
    CacheClass.removeObjectForEnumKey(.is_adding_friend_certification)
    CacheClass.removeObjectForEnumKey(.addtime)
    CacheClass.removeObjectForEnumKey(.pay_pass)
    CacheClass.removeObjectForEnumKey(.customer_type)
    CacheClass.removeObjectForEnumKey(.token)
    CacheClass.removeObjectForEnumKey(.invitation)
    CacheClass.removeObjectForEnumKey(.cover)
    CacheClass.removeObjectForEnumKey(.mid)

}

//MARK: 获取用户资料
func getUserNews(success:((JSON) -> Void)?=nil) {
        
        NetworkRequest.requestMethod(.get, URLString: url_getUserNews, parameters: nil, success: { (value, json) in
            
            if json["status"] == "SUCCESS" {
                
                if let ret_data = json["ret_data"].dictionary {
                    
                    CacheClass.setObject(ret_data["username"]?.string ?? "", forEnumKey: .username)
                    CacheClass.setObject(ret_data["nickname"]?.string ?? "", forEnumKey: .nickname)
                    CacheClass.setObject(ret_data["avatar"]?.string ?? "", forEnumKey: .avatar)
                    CacheClass.setObject(ret_data["money"]?.string ?? "", forEnumKey: .money)
                    CacheClass.setObject(ret_data["mobile"]?.string ?? "", forEnumKey: .mobile)
                    CacheClass.setObject(ret_data["mobile_code"]?.string ?? "", forEnumKey: .mobile_code)
                    CacheClass.setObject(ret_data["groupid"]?.string ?? "", forEnumKey: .groupid)
                    CacheClass.setObject(ret_data["is_adding_friend_certification"]?.string ?? "", forEnumKey: .is_adding_friend_certification)
                    CacheClass.setObject(ret_data["addtime"]?.string ?? "", forEnumKey: .addtime)
                    CacheClass.setObject(ret_data["pay_pass"]?.bool ?? "", forEnumKey: .pay_pass)
                    CacheClass.setObject(ret_data["customer_type"]?.string ?? "", forEnumKey: .customer_type)
                    CacheClass.setObject(ret_data["invitation"]?.string ?? "", forEnumKey: .invitation)
                    CacheClass.setObject(ret_data["cover"]?.string ?? "", forEnumKey: .cover)
                    CacheClass.setObject(ret_data["mid"]?.string ?? "", forEnumKey: .mid)
                    CacheClass.setObject(ret_data["qrcode"]?.string ?? "", forEnumKey: .qrcode)

                    
                }
                
                success?(json)
                
            }else{
                
                    AlertClass.showErrorToat(withJson: json)
                
            }
            
        }) {
            
            
        }
    }

//MARK: 获取当前时间
func getCurrentTime() -> String {
    
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    
    return dateFormatter.string(from: date)
}

//MARK: 红包是否过期
func isRedTimeout(time:String) -> Bool {
    
    let curTime = getCurrentTime().getTimestamp()
    
    let sendTime = time.getTimestamp()
    
    let redTime = curTime - sendTime
    
    if redTime > (60 * 60) {
        return true
    }else{
        return false
    }
}


