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
    
    fileprivate var timer : Timer!
    
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
            print("IM Server 连接成功")
        } catch {
            print("IM Server 连接失败")
        }
    }
    
    //MARK: 连接失败
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
        startConnect()
    }
    
    /**
     * 连接成功时回调
     */
    internal func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) -> Void {
        //print("connect success")
        
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.sendText), userInfo: nil, repeats: true)
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
        
        // 打印服务端发来的消息
        print(readClientDataString ?? "")
        
        AlertClass.showText(_text: readClientDataString! as String)
        
        // Data 转 JSON对象
        let json = try? JSONSerialization.jsonObject(with: data, options:.allowFragments) as! [String: Any]
        
        /**
         * 获取事件类型
         * init 为初始化连接
         * message 为消息事件
         */
        let type = json?["type"] as! String
        switch type {
            case "init": // 初始化连接
                // 获取客户端ID
                let client_id = json?["client_id"] as! String
                if !client_id.isEmpty { // 存储客户端ID
                    UserDefaults.standard.set(client_id, forKey: "client_id")
                }
                break;
            case "message": // 消息事件
                // 获取客户端ID
                let msg_type = json?["msg_type"] as! String
                if msg_type.isEqual("red") { // 只处理红包事件
                    //let content = json?["content"] as! String
                    print(json?["content"])
                    let noticeContent = JCMessageNoticeContent(text: "test",isRed:true,money: "10")
                    msg = JCMessage(content: noticeContent)
                }
                break;
            default:
                break;
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
        print("断开连接 IM Server")
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
}
