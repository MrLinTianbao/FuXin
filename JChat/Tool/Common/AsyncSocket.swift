//
//  AsyncSocket.swift
//  JChat
//
//  Created by Wilson on 2019/9/13.
//  Copyright © 2019 HXHG. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import SwiftyJSON

class AsyncSocket: NSObject, GCDAsyncSocketDelegate {
    // 客户端socket
    var clientSocket: GCDAsyncSocket!
    var msg: JCMessage!
    
    static let share = AsyncSocket()
    
    var isLogout = false //是否是退出登录
    
    fileprivate var timer : Timer!
    
    var sound : Double = 0 //时间间隔
    var sound2 : Double = 0 //聊天页面刷新时间间隔
    
    override init() {
        super.init()
        
        // 初始化
        clientSocket = GCDAsyncSocket()
        clientSocket.delegate = self
        // 回调主线程
        clientSocket.delegateQueue = DispatchQueue.main
        
        
    }
    
    //MARK: 发送心跳包
    @objc fileprivate func sendText() {
        
        
        
        let dict = ["type":"ping"]
        let dataString : NSData = try! JSONSerialization.data(withJSONObject: dict, options: []) as NSData
        let jsonString = NSString(data: dataString as Data, encoding: String.Encoding.utf8.rawValue)! as String

        AsyncSocket.share.sendMessage(message: jsonString + "\n")
        
        
 
    }
    
    func startConnect(){
        do {
            try clientSocket.connect(toHost: host, onPort: socketPort, withTimeout: -1)
            MyLog("IM Server 连接成功")
        } catch {
            MyLog("IM Server 连接失败")
        }
    }
    
    //MARK: 连接失败
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
        if !isLogout {
            startConnect()
        }
        
        
    }
    
    /**
     * 连接成功时回调
     */
    internal func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) -> Void {
        //print("connect success")
        
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 55, target: self, selector: #selector(self.sendText), userInfo: nil, repeats: true)
        //添加至子线程
        RunLoop.main.add(self.timer, forMode: .common)
        
        clientSocket.readData(withTimeout: -1, tag: 0)
    }
    
    /**
     * 发送成功时回调
     */
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        
        clientSocket.readData(withTimeout: -1, tag: 0)
    }
    
    

    /**
     * 收到消息时回调
     */
    internal func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) -> Void {
        // 1、获取客户端发来的数据，把 NSData 转 NSString
        let readClientDataString: NSString? = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)
        
        AsyncSocket.share.sound += 0.1
        AsyncSocket.share.sound2 += 1
        
        
        // 打印服务端发来的消息
//        MyLog(readClientDataString ?? "")
        
//        AlertClass.showText(_text: readClientDataString! as String)
        
        if readClientDataString == nil {
            return
        }
        
        let jsonArr = ((readClientDataString ?? "") as String).components(separatedBy: "\n")

        var jsonArr2 = [String]()

        for str in jsonArr {
            if str != "" {
                jsonArr2.append(str)
            }
        }

        if (readClientDataString?.contains("###@@@红包###@@@"))! && (readClientDataString?.contains("message"))! && jsonArr2.count > 1 {
            
            

            for str in jsonArr2 {
                let strData = str.data(using: .utf8)
                
                let jsonStr = try? JSONSerialization.jsonObject(with: strData!, options:.allowFragments) as! [String: Any]
                
                let _ = self.getMessage(json: jsonStr)

            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + AsyncSocket.share.sound) {
                let strData2 = jsonArr2.first?.data(using: .utf8)

                let jsonStr2 = try? JSONSerialization.jsonObject(with: strData2!, options:.allowFragments) as! [String: Any]

                if var hb_infor = jsonStr2?["hb_infor"] as? [String:Any] {
                    if let group_id = hb_infor["group_id"] as? String {


                        NotificationCenter.default.post(name:.clearUnReadCount, object: nil, userInfo: ["data":group_id])
                    }
                }


                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateConversation), object: nil, userInfo: nil)
                

            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + AsyncSocket.share.sound2) {

                self.reloadMessage()
            }
            
            

            
        }else{
            
            // Data 转 JSON对象
            let json = try? JSONSerialization.jsonObject(with: data, options:.allowFragments) as! [String: Any]
            
            let isRepeat = self.getMessage(json: json) //是否是重复消息
            
            if (readClientDataString?.contains("###@@@红包###@@@"))! && (readClientDataString?.contains("message"))! {
                
                if isRepeat {
                    return
                }
                
                
                    
                    if var hb_infor = json?["hb_infor"] as? [String:Any] {
                        if let group_id = hb_infor["group_id"] as? String {

                            NotificationCenter.default.post(name:.clearUnReadCount, object: nil, userInfo: ["data":group_id])
                        }
                    }

                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateConversation), object: nil, userInfo: nil)
                
                
                
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + AsyncSocket.share.sound2) {
                    self.reloadMessage()
                }
                
                
                
                

            }
        }
        
        
        
        
        
        
        
        
        
        //print("JSON:", type, client_id)
        //
        
        /*
         // 3、处理请求，返回数据给客户端OK
         let serviceStr: NSMutableString = NSMutableString()
         serviceStr.append("OK")
         serviceStr.append("\r\n")
         clientSocket.write(serviceStr.data(using: String.Encoding.utf8.rawValue)!, withTimeout: -1, tag: 0)
         */
        // 4、每次读完数据后，都要调用一次监听数据的方法
        clientSocket.readData(withTimeout: -1, tag: 0)
    }
    
    /**
     * 断开连接
     */
    func stopConnect() {
        clientSocket.disconnect()
        MyLog("断开连接 IM Server")
    }
    
    /**
     * 发送消息
     * 如： sendMessage(message: "xx")
     */
    func sendMessage(message: String) {
        // timeout -1: 无穷大，一直等
        // tag: 消息标记
        clientSocket.write(message.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withTimeout: -1, tag: 0)
    }
    
    //MARK: 处理消息
    fileprivate func getMessage(json:[String:Any]?) -> Bool { //是否是重复消息
        
        /**
         * 获取事件类型
         * init 为初始化连接
         * message 为消息事件
         */
        if let type = json?["type"] as? String {
            
            switch type {
            case "init": // 初始化连接
                // 获取客户端ID
                let client_id = json?["client_id"] as! String
                if !client_id.isEmpty { // 存储客户端ID
                    UserDefaults.standard.set(client_id, forKey: "client_id")
                    
                }
                
                NetworkRequest.requestMethod(.post, URLString: url_bindIM, parameters: ["client_id":client_id,"method":"PUT"], success: { (value, json) in
                    
                    if json["status"].stringValue != "SUCCESS" {
                        AsyncSocket.share.stopConnect()
                    }
                    
                }) {
                    
                    AsyncSocket.share.stopConnect()
                }
                
            case "hb": // 红包消息事件
                
                let replyDic = ["type":"message", "msg_type":"reply","server_message_id":"\(json?["server_message_id"] ?? "")","receipt_time":getCurrentTime().getTimestamp(),"token":(json?["token"] as? String ?? ""),"uid":CacheClass.stringForEnumKey(.mid) ?? ""] as [String : Any]
                let replyData : NSData = try! JSONSerialization.data(withJSONObject: replyDic, options: []) as NSData
                let replyJson = NSString(data: replyData as Data, encoding: String.Encoding.utf8.rawValue)! as String
                AsyncSocket.share.sendMessage(message: replyJson + "\n")
                
//                if "\(json?["is_resend"] ?? "0")" == "0"  { //是否是重发消息
//
//                    return
//                }
                
                
                if var hb_infor = json?["hb_infor"] as? [String:Any] {
                    if let group_id = hb_infor["group_id"] as? String {
                        
                        let conversation =  JMSGConversation.groupConversation(withGroupId: "\(group_id)")
                                            if let send_user_id = hb_infor["send_user_id"] as? String {
                                                
                                                hb_infor["userId"] = send_user_id
                                            }
                                            
                                            if let username = hb_infor["send_username"] as? String {
                                                
                                                hb_infor["send_user_id"] = username
                                                
                                                if username == JMSGUser.myInfo().username {
                                                    return true
                                                }
                                            }
                                            
                                            
                                            
                                            hb_infor["hb_id"] = "\(hb_infor["hb_id"] ?? "")"
                                            
                                            
                                            hb_infor["hb_num"] = "\(hb_infor["hb_num"] ?? "")"
                                            
                                            var dict = json
                                            dict?["hb_infor"] = hb_infor
                                            
                                            let dataString : NSData = try! JSONSerialization.data(withJSONObject: dict!, options: []) as NSData
                                            let jsonString = NSString(data: dataString as Data, encoding: String.Encoding.utf8.rawValue)! as String
                                            
                                            
                                            
                                            if conversation == nil {
                                                
                                                
                                                JMSGConversation.createGroupConversation(withGroupId: "\(group_id)", completionHandler: { (result, error) in
                                                    
                                                    let conv = JMSGConversation.groupConversation(withGroupId: "\(group_id)")
                                                    
                                                    if let group = conv?.target as? JMSGGroup {
                                                       
                                                        let users = group.memberArray()
                                                        
                                                        for user in users {
                                                            
                                                            //判断用户是否是群成员
                                                            if user.username == JMSGUser.myInfo().username {
                                                                self.createMessage(conversation: conv, jsonString: jsonString, dict: dict)
                                                                
                                                                self.reloadMessage()
                                                                
                                                                return
                                                            }
                                                            
                                                           
                                                        }
                                                        
                                                        JMSGConversation.deleteGroupConversation(withGroupId: "\(group_id)")
                                                    }
                                                    

                                                    
                                                    
                        
                                                })
                                                
                                                return true
                                                
                                            }else{
                                                //获取列表消息
                                                let msgs = conversation?.messageArrayFromNewest(withOffset: nil, limit: nil) ?? [JMSGMessage]()
                                                
                                                for msg in msgs {
                                                    
                                                    if msg.contentType == .text {
                                                        let content = msg.content as! JMSGTextContent
                                                        let jsonData:Data = content.text.data(using: .utf8)!
                                                        let dic = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
                                                        
                                                        if let dict2 = dic as? [String:Any] {

                                                            
                                                                
                                                                if "\(dict2["server_message_id"] ?? "")" == "\(json?["server_message_id"] ?? "")" {
                                                                 
                                                                    return true
                                                            }
                                                                
//
                                                        }
                                                    }
                                                }
                                                
                                                self.createMessage(conversation: conversation, jsonString: jsonString, dict: dict)
                                                
                                                return false
                                            }
                        
                        
                    }
                }
                
                
                
            default:
                break;
            }
        }
        
        return true
    }
    
    //MARK: 创建消息
    fileprivate func createMessage(conversation:JMSGConversation?,jsonString:String,dict:[String:Any]?) {
        
        if let type = dict?["type"] as? String {
            
            if type == "hb" {
                
                if let group = conversation?.target as? JMSGGroup {
                    
                    let users = group.memberArray()
                    
                    var isFlag = false //判断用户是否是群成员
                    
                    for user in users {
                        
                        
                        if user.username == JMSGUser.myInfo().username {
                            
                            isFlag = true
                            break
                        }
                    }
                    
                    if !isFlag {
                        return
                    }
                }
            }
        }
        
        
        
        
        let content = JMSGTextContent(text: jsonString)
        content.addStringExtra("success", forKey: "sendSate")
        content.addStringExtra("0", forKey: "msgStatus")
        
        
        
        let msg = conversation?.createMessage(with: content)
        
        if let hb_infor = dict?["hb_infor"] as? [String:Any] {
            if let hb_create_time = hb_infor["hb_create_time"] as? String {
                msg?.timestamp = NSNumber.init(value: hb_create_time.getTimestamp())
            }
        }
        
        conversation?.unreadCount = NSNumber.init(value: ((conversation?.unreadCount?.intValue) ?? 0) + 1 )
        
        //保存未读消息数
        CacheClass.setObject("\((conversation?.unreadCount?.intValue) ?? 0)", forEnumKey: JMSGUser.myInfo().username + (conversation?.target as! JMSGGroup).gid)
        
        if let msgId = msg?.msgId {
            content.addStringExtra(msgId, forKey: "msgId")
        }
        
        
        
        
        //
//        NotificationCenter.default.post(name: .unReadCount, object: nil, userInfo: ["data":dict!])
    }
    
    //MARK: 消息刷新
    fileprivate func reloadMessage() {
        
        NotificationCenter.default.post(name: .reloadMessageList, object: nil)
    }
}
