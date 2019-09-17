//
//  RechargVC.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/7/11.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class RechargVC: CTViewController {

    @IBOutlet weak var logoImage: UIImageView!
    
    @IBOutlet weak var moneyTF: UITextField!
    
    @IBOutlet weak var nickNameTF: UITextField!
    
    @IBOutlet weak var idTF: UITextField!
    
    fileprivate var payType = "0" //支付类型
    
    init(payType:String) {
        super.init(nibName: nil, bundle: nil)
        
        self.payType = payType
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nickNameTF.placeholder = CacheClass.stringForEnumKey(.nickname)
        idTF.placeholder = String(JMSGUser.myInfo().uid)

        self.view.backgroundColor = UIColor.KTheme.scroll
        
        if payType == "1" {
            
            self.title = "微信支付"
            logoImage.image = UIImage.init(named: "mine_wx")
            
        }else if payType == "2" {
            
            self.title = "支付宝支付"
            logoImage.image = UIImage.init(named: "mine_zfb")
        }
        
    }


    @IBAction func confirmAction(_ sender: UIButton) {
        
        if moneyTF.text == "" {
            
            MBProgressHUD_JChat.show(text: "请输入金额", view: self.view)
            return
        }
        
        if Int(moneyTF.text!) == nil {
            MBProgressHUD_JChat.show(text: "请输入正确的金额", view: self.view)
            return
        }
        
        if Int(moneyTF.text!) ?? 0 < 100  {
            MBProgressHUD_JChat.show(text: "充值金额不能少于100", view: self.view)
            return
        }
        
        MBProgressHUD_JChat.showMessage(message: "正在充值...", toView: view)
        
        NetworkRequest.requestMethod(.post, URLString: url_recharge, parameters: ["amount":moneyTF.text!,"pay_type":payType], success: { (value, json) in
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
            
            if json["status"].stringValue == "SUCCESS" {
                
//                MBProgressHUD_JChat.show(text: "充值成功", view: self.view)
                
                if let pay_url = json["ret_data"]["pay_url"].string {
                    
                    let webVC = WebViewController.init(urlString: pay_url, title: self.title)
                    webVC.pay_type = json["ret_data"]["pay_url"].string ?? ""
                    webVC.pay_order_id = json["ret_data"]["pay_order_id"].string ?? ""
                    webVC.order_id = json["ret_data"]["order_id"].string ?? ""
                    webVC.isPay = true
                    self.navigationController?.pushViewController(webVC, animated: true)
                }
                
                
            }else{
                MBProgressHUD_JChat.show(text: json["error"].stringValue, view: self.view)
            }
            
        }) {
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
        }

    }
    

}
