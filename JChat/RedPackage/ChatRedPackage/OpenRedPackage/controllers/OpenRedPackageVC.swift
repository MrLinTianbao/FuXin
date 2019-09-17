//
//  PocketPay1VC.swift
//  XLCustomer
//
//  Created by longma on 2019/1/9.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class OpenRedPackageVC: CTViewController {
    
    @IBOutlet weak var btnOpenBottom: NSLayoutConstraint!
    @IBOutlet weak var btnOpen: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var nickNameLabel: UILabel!
    
    @IBOutlet weak var tipsLabel: UILabel!
    
    @IBOutlet weak var redDtailsBtn: UIButton!
    
    @IBOutlet weak var amoutLabel: UILabel!
    
    fileprivate var requestCount = 0 //网络请求次数
    
    var redId = "" //红包id
    
    var gid = "" //群id
    
    var user : JMSGUser!
    var redTips = "" //提示语
    var amount = "" //金额
    
    var userName = "0"

    var redBlock : ((JSON)->Void)?
    var redDetailsBlock : ((String,String)->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUIAppearance()
        
    }
    func setUIAppearance(){
        self.title = "打开红包"
        
       
            JMSGUser.userInfoArray(withUsernameArray: [userName], completionHandler: { (result, error) in
                let users = result as? [JMSGUser]
                guard let user = users?.first else {
                    return
                }
                self.user = user
                
                user.thumbAvatarData { (data, username, error) in
                    
                    if let imageData = data {
                        let image = UIImage.init(data: imageData)
                        self.avatarImage.image = image
                    }else{
                        self.avatarImage.image = chatDefaultHead
                    }
                }
                
                self.nickNameLabel.text = self.user.nickname ?? self.user.username
                self.tipsLabel.text = self.redTips
                self.amoutLabel.text = ""//self.amount
                
                
            })
        
        if userName == JMSGUser.myInfo().username && gid != "" {
            
            redDtailsBtn.isHidden = false
        }else{
            redDtailsBtn.isHidden = true
        }
        
        
        btnOpen.backgroundColor = UIColor.init(hexString: "#F4D3A2")
        btnOpen.setCornerRadius(45)
        nickNameLabel.textColor = UIColor.init(hexString: "#F4D3A2")
        tipsLabel.textColor = UIColor.init(hexString: "#F4D3A2")
        //        43 29:48
        let bottom = (ScreenW - 43*2)*(48/29)*(6/48)
        btnOpenBottom.constant = bottom
        
        
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        self.dismiss(animated: false, completion: nil)
//    }
  
    
    @IBAction func openRedPackage(_ sender: UIButton) {
        
        btnOpen.isEnabled = false
        
//        let transformAnima = CABasicAnimation.init(keyPath: "transform.rotation.y")
//        //    transformAnima.fromValue = @(M_PI_2);
//        //旋转到什么角度
//        //        transformAnima.toValue = [NSNumber numberWithFloat: M_PI];
//        transformAnima.toValue = NSNumber.init(value: Double.pi)
//        //旋转一次所需要的时间
//        transformAnima.duration = 0.2;
//        transformAnima.isCumulative = true
//        transformAnima.autoreverses = false;
//        transformAnima.repeatCount = HUGE
//        transformAnima.fillMode = .forwards
//        transformAnima.isRemovedOnCompletion = false
//        transformAnima.timingFunction = CAMediaTimingFunction(name: .linear)
//        btnOpen.layer.zPosition = 5
//        btnOpen.layer.zPosition = btnOpen.layer.frame.size.width / 2.0
//        btnOpen.layer.add(transformAnima, forKey: "rotationAnimationY")
        
        var time = 0 //延迟时间
        
        if requestCount == 0 {
            MBProgressHUD_JChat.showMessage(message: "正在加载...", toView: self.view)
        }else if requestCount == 1 {
            time = 1
        }else if requestCount == 2 {
            time = 10
        }
        
        requestCount += 1
        
        let urlStr = gid != "" ? url_sendRayRed : url_sendRed
        
        
        
        
        var dic = ["id":redId.replacingOccurrences(of: " ", with: ""),"method":"PUT"]
        
        if gid != "" {
            dic["group_id"] = gid
        }
        
        NetworkRequest.requestMethod(.post, URLString: urlStr, parameters: dic, success: { (value, json) in
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
            
            if json["status"].stringValue == "SUCCESS" {
                
                
                self.redBlock?(json)
                self.dismiss(animated: false, completion: nil)
                
            }else{
                if json["code"].stringValue == "2" {
                    
                    
                    if self.requestCount >= 4 {
                        
                        self.redBlock?(json)
                        self.dismiss(animated: false, completion: nil)
                        
                    }else{
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(time)) {
                            self.openRedPackage(self.btnOpen)
                        }
                        
                    }
                }else{
                    
              
                    
                    self.redBlock?(json)
                    self.dismiss(animated: false, completion: nil)
                    
                
                }
            }
            
            
            
            
            
        }) {
            
            MBProgressHUD_JChat.show(text: "网络异常", view: self.view)
    
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
            self.dismiss(animated: false, completion: nil)
        }
        
        
        
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        
        self.dismiss(animated: false, completion: nil)
    }
    
    //MARK: 查看红包详情
    @IBAction func redPackageDetails(_ sender: UIButton) {
        
        self.redDetailsBlock?(redId,gid)
        self.dismiss(animated: false, completion: nil)
    }
    
}
