//
//  PocketPay1VC.swift
//  XLCustomer
//
//  Created by longma on 2019/1/9.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit
import SDWebImage
class UserQRCodeVC: CTViewController {
    @IBOutlet weak var labName: UILabel!
    
    @IBOutlet weak var imvCode: UIImageView!
    @IBOutlet weak var labID: UILabel!
    @IBOutlet weak var imvIcon: UIImageView!
    @IBOutlet weak var viewCenterH: NSLayoutConstraint!
    
    var group: JMSGGroup!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUIAppearance()
        
    }
    func setUIAppearance(){
        self.view.backgroundColor = UIColor.KTheme.scroll
        
        let w = 110 + (ScreenW - (42+24)*2) + 50
        viewCenterH.constant = w
        imvIcon.setCornerRadius(5)
        imvCode.backgroundColor = UIColor.white
        
        
//        加好友二维码：fuxin://frend/add?mid=1
//        加群二维码：fuxin://group/add?gid=1
        
//        let uid = JMSGUser.myInfo().uid
//        let username = CacheClass.stringForEnumKey(.username) ?? ""
//        let time = CacheClass.stringForEnumKey(.addtime) ?? ""
//        let url = "fuxin://frend/add?uid=\(uid)&username=\(username)&timeout=\(time)"
//        print("=================   \(url)")
        
        if group != nil {
            self.title = "群二维码"
            
            group.thumbAvatarData { [weak self] (data, id , error) in
                if let data = data {
                    let image = UIImage(data: data)
                    self?.imvIcon.image = image
                }else{
                    self?.imvIcon.image = chatGroupDefaultHead
                }
            }
            labName.text = group.displayName()
            group.memberArray {[weak self] (userArr, error) in
                if let list = userArr as? [JMSGUser] {
                    self?.labID.text = "群人数 \(list.count) 人"
                }
            }
            
            AlertClass.show()
            imvCode.isHidden = true
            //获取群二维码
            NetworkRequest.requestMethod(.get, URLString: url_ChatGroup, parameters: ["group_id":group.gid], success: { (value, json) in
                AlertClass.stop()
                if json["status"] == "SUCCESS" {
                    
                    let downloader = SDWebImageDownloader.shared
                    let url = URL.init(string: json["ret_data"]["qrcode"].stringValue)
                    downloader.downloadImage(with: url, options: .useNSURLCache, progress: { (receivedSize, expectedSize, targetURL) in
                    }) { (image, data, error, finished) in
                        if finished && (image != nil) {
                            self.imvCode.isHidden = false
                            self.imvCode.image = image
                        }
                    }
         
//                    self.imvCode.isHidden = false
//                    self.imvCode.setUrlImage(with: json["ret_data"]["qrcode"].stringValue, placeholder: nil)
                }
            }) {}
            
//            let url = "fuxin://group/add?gid=\(group.gid)"
//            let image = MJManager.setupQRCodeImage(url, image: nil)
//            imvCode.image = image
            

        }else{
            self.title = "我的二维码"
            labName.text = CacheClass.stringForEnumKey(.nickname)
            labID.text = "ID：" + (CacheClass.stringForEnumKey(.username) ?? "")
            imvIcon.setUrlImage(with: (CacheClass.stringForEnumKey(.avatar) ?? ""), placeholder: chatDefaultHead)
            
//            let uid = JMSGUser.myInfo().uid
//            let username = CacheClass.stringForEnumKey(.username) ?? ""
//            let time = (CacheClass.stringForEnumKey(.addtime) ?? "").mj_date(withFormat: "yyyy-MM-dd HH:mm:ss")?.timeIntervalSince1970 ?? 0
            imvCode.isHidden = true
            AlertClass.show()
            
            NetworkRequest.requestMethod(.get, URLString: url_getUserNews, parameters: nil, success: { (value, json) in
                AlertClass.stop()
                if json["status"] == "SUCCESS" {
                    let downloader = SDWebImageDownloader.shared
                    let url = URL.init(string: json["ret_data"]["qrcode"].stringValue)
                    downloader.downloadImage(with: url, options: .useNSURLCache, progress: { (receivedSize, expectedSize, targetURL) in
                    }) { (image, data, error, finished) in
                        if finished && (image != nil) {
                            self.imvCode.isHidden = false
                            self.imvCode.image = image
                        }
                    }
                }else{
                    AlertClass.showErrorToat(withJson: json)
                }
            }) { }
            
        
            
            
//            let url = "fuxin://frend/add?uid=\(uid)&mid=\(username)&timeout=\(String(Int(time)))"
//            print("=================   \(url)")
//
////            fuxin://frend/add?uid=70&username=13938218507&timeout=1565168516
////            let url = "fuxin://frend/add?mid=\(username)"
//
//            let image = MJManager.setupQRCodeImage(url, image: nil)
//            imvCode.image = image
        }
        
        
      
    }
   
    
    

   

}
