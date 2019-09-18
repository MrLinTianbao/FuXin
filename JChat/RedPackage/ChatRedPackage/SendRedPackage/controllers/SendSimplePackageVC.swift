//
//  PocketPay1VC.swift
//  XLCustomer
//
//  Created by longma on 2019/1/9.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class SendSimplePackageVC: CTViewController {
    
    var redBlock : ((String,String,String)->Void)?
    
    
    @IBOutlet weak var labMoney: UILabel!
    @IBOutlet weak var tfTips: MJUITextField!
    @IBOutlet weak var tfMoney: MJUITextField!
    @IBOutlet weak var btnApply: MJButton!
    
    var toUserName = ""
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUIAppearance()
        
        
        
    }
    func setUIAppearance(){
        self.title = "发红包"
        self.setNavLeftItem(title: "取消")
        self.view.backgroundColor = UIColor.KTheme.scroll
        tfMoney.addTarget(self, action: #selector(self.textValueChanged), for: .editingChanged)
        

    }
    override func actionLeftItemClick() {
        self.dismiss(animated: true, completion: nil)
        
    }
    @objc func textValueChanged(){
        btnApply.isClickEnabled = !(tfMoney.isEmpty)
        
        labMoney.text = "¥ " + String(Int(tfMoney.text!) ?? 0)
        
        if labMoney.text == "¥ " {
            labMoney.text = "¥ 0.00"
        }
    }
    @IBAction func onApplyBtnClicked(_ sender: Any) {
        
        if Int(tfMoney.text!) ?? 0 < 1 {
            MBProgressHUD_JChat.show(text: "红包金额不能少于1", view: self.view)
             return
        }
        
        if Int(tfMoney.text!) ?? 0 > 500 {
            MBProgressHUD_JChat.show(text: "红包金额不能大于500", view: self.view)
            return
        }
        
        let pay_pass = CacheClass.boolForEnumKey(.pay_pass) ?? false
        if !pay_pass {
            
            AlertClass.setAlertView(msg: "你还没有设置支付密码", target: self, actionTitle: "去设置", cancelTitle:"取消", haveCancel: true) { (alert) in
                
                self.navigationController?.pushViewController(ForgetPayPasswardVC())
            }
            
            return
        }
        
        
        KAlertPayPawView.showAlertPayPawView(money: CGFloat(Float(tfMoney.text!) ?? 0), type: nil, completion: { (paw,alertView) in
            
            if self.tfTips.text == "" {
                self.tfTips.text = self.tfTips.placeholder
            }
            
            let passwordStr = RSA.encryptString(paw, publicKey: publicKey)
            
            AlertClass.waiting("正在支付")
            alertView.dismiss()
            
            NetworkRequest.requestMethod(.post, URLString: url_sendRed, parameters: ["to_username":self.toUserName,"amount":self.tfMoney.text!,"blessing":self.tfTips.text!,"pay_pass":passwordStr ?? ""], success: { (value, json) in
                
                AlertClass.stop()
                
                if json["status"].stringValue == "SUCCESS" {
                    
                    alertView.dismiss()
                    self.sendRed(redUid: json["ret_data"]["id"].stringValue)
                    
                }else{
                    
                    SVProgressHUD.showError(withStatus: json["error"].stringValue)

                }
                
            }){
                
                    AlertClass.stop()
            }
            
            
            
        })
        
        
        
    }
    
    
    
    //MARK: 发红包
    fileprivate func sendRed(redUid:String) {
        
        var tipStr = self.tfTips.text?.trimed()
        
        if tipStr == "" {
            tipStr = tfTips.placeholder
        }
        
        self.redBlock?(self.tfMoney.text!,tipStr!, redUid)
        self.dismiss(animated: true, completion: nil)
        
        
    }

}
