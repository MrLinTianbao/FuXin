//
//  PocketPay1VC.swift
//  XLCustomer
//
//  Created by longma on 2019/1/9.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class DistributionShareVC: CTViewController {
    
    @IBOutlet weak var labTime: UILabel!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var viewBubb: UIView!
    @IBOutlet weak var imvHead: UIImageView!
    
    
    @IBOutlet weak var appCode: UIImageView!
    
    @IBOutlet weak var invitaCodeLabel: UILabel!
    
   
    @IBOutlet weak var wechatView: UIView!
    
    @IBOutlet weak var albumView: UIView!
    
    @IBOutlet weak var friCircleView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getAppCode()
        self.setUIAppearance()
        
    }
    func setUIAppearance(){
        self.title = "分销"
        self.setNavRightItem(title: "邀请记录", titleColor: UIColor.KTheme.deepOrange)
        self.view.backgroundColor = UIColor.KTheme.scroll
        viewBubb.clipsToBounds = false
        invitaCodeLabel.text = CacheClass.stringForEnumKey(.invitation)
        nameLabel.text = (CacheClass.stringForEnumKey(.nickname) ?? CacheClass.stringForEnumKey(.username) ?? "") + " 邀请你进去群聊"
        let tapGestrue = UITapGestureRecognizer.init(target: self, action: #selector(shareForFriend))
        let tapGestrue2 = UITapGestureRecognizer.init(target: self, action: #selector(saveToAlbum))
        let tapGestrue3 = UITapGestureRecognizer.init(target: self, action: #selector(shareForFriendCircle))
        let tapGestrue4 = UITapGestureRecognizer.init(target: self, action: #selector(copyCode))
        
        wechatView.isUserInteractionEnabled = true
        albumView.isUserInteractionEnabled = true
        friCircleView.isUserInteractionEnabled = true
        invitaCodeLabel.isUserInteractionEnabled = true
        
        wechatView.addGestureRecognizer(tapGestrue)
        albumView.addGestureRecognizer(tapGestrue2)
        friCircleView.addGestureRecognizer(tapGestrue3)
        invitaCodeLabel.addGestureRecognizer(tapGestrue4)
        
        
        let date = Date()
        let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "HH:mm"
        labTime.text = dateFormatter.string(from: date)
        
        imvHead.setUrlImage(with: (CacheClass.stringForEnumKey(.avatar) ?? ""), placeholder: chatDefaultHead)

//        let hh = getCurrentTime().getTimeUint(type: .hours)
//
//        let mm = getCurrentTime().getTimeUint(type: .minutes)
//
//        labTime.text = hh + ":" + mm
      
    }
    override func actionRightItemClick() {
        self.pushViewController(targetStr: "DistributionRecordVC")
    }
    
    //MARK: 复制邀请码
    @objc fileprivate func copyCode() {
        
        if invitaCodeLabel.text != "" {
            let pasteboard = UIPasteboard.general
            pasteboard.string = invitaCodeLabel.text
            
            MBProgressHUD_JChat.show(text: "复制成功", view: self.view)
            
        }
    }
    
    //MARK: 分享至微信好友
    @objc fileprivate func shareForFriend() {
        
        //判断是否安装微信
        if WXApi.isWXAppInstalled() {
            
            //获取截图
            UIGraphicsBeginImageContextWithOptions(CGSize.init(width: self.whiteView.frame.size.width, height: self.whiteView.frame.size.height), false, 0) //原图
            self.whiteView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

           
                
                let webpageObject = WXWebpageObject()
                webpageObject.webpageUrl = "http://www.fuxin.in/?a=share&mid=\(CacheClass.stringForEnumKey(.mid) ?? "")"
                
                let message = WXMediaMessage()
                message.title = (CacheClass.stringForEnumKey(.nickname) ?? CacheClass.stringForEnumKey(.username) ?? "") + " 邀请你进去群聊"
                message.description = "富信官方邀请你加入 我们群里吧"
                message.setThumbImage(image!)
                message.mediaObject = webpageObject
                
                let req = SendMessageToWXReq()
                req.bText = false
                req.message = message
                req.scene = Int32(WXSceneSession.rawValue)
                WXApi.send(req)
            
            
            
            
            
            
        }else{
            
            AlertClass.setAlertView(msg: "请先安装微信客户端", target: self, haveCancel: false, handler: nil)
        }
    }
    
    
    
    //MARK: 保存至相册
    @objc fileprivate func saveToAlbum() {
        
        AlertClass.setAlertView(msg: "保存该页面至相册", target: self, haveCancel: true) { (alert) in
            
            UIGraphicsBeginImageContextWithOptions(CGSize.init(width: self.whiteView.frame.size.width, height: self.whiteView.frame.size.height), false, 0) //原图
            self.whiteView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
        }
        

    }
    
    //MARK: 分享至朋友圈
    @objc fileprivate func shareForFriendCircle() {
        
        //判断是否安装微信
        if WXApi.isWXAppInstalled() {
            
            //获取截图
            UIGraphicsBeginImageContextWithOptions(CGSize.init(width: self.whiteView.frame.size.width, height: self.whiteView.frame.size.height), false, 0) //原图
            self.whiteView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            
                
                let webpageObject = WXWebpageObject()
            webpageObject.webpageUrl = "http://www.fuxin.in/?a=share&mid=\(CacheClass.stringForEnumKey(.mid) ?? "")"
                
                let message = WXMediaMessage()
                message.title = (CacheClass.stringForEnumKey(.nickname) ?? CacheClass.stringForEnumKey(.username) ?? "") + " 邀请你进去群聊"
                message.description = "富信官方邀请你加入 我们群里吧"
                message.setThumbImage(image!)
                message.mediaObject = webpageObject
                
                let req = SendMessageToWXReq()
                req.bText = false
                req.message = message
                req.scene = Int32(WXSceneTimeline.rawValue)
                WXApi.send(req)
           
            
        }else{
            
            AlertClass.setAlertView(msg: "请先安装微信客户端", target: self, haveCancel: false, handler: nil)
        }
    }
    
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        var showMessage = ""
        
        if error != nil{
            
            showMessage = "保存失败"
            
        }else{
            
            showMessage = "保存成功"
            
        }
        
        SVProgressHUD.showInfo(withStatus: showMessage)
        
        
    }
    
    //MARK: 获取app二维码
    fileprivate func getAppCode() {
        
        NetworkRequest.requestMethod(.get, URLString: url_rechargeCode, parameters: nil, success: { (value, json) in
            
            if json["status"].stringValue == "SUCCESS" {
                
                self.appCode.setUrlImage(with: json["ret_data"]["down_qrcode"].stringValue, placeholder: UIImage.init(named: ""))
                
                
            }
            
        }) {
            
            
        }
    }

}
