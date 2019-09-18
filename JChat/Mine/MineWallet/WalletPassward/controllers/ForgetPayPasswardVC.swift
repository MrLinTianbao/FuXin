//
//  PocketPay1VC.swift
//  XLCustomer
//
//  Created by longma on 2019/1/9.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class ForgetPayPasswardVC: CTViewController {
    @IBOutlet weak var tfPhone: MJUITextField!
    
    @IBOutlet weak var btnCode: UIButton!
    @IBOutlet weak var tfCode: MJUITextField!
    @IBOutlet weak var btnArea: UIButton!
    @IBOutlet weak var tfNewPw: MJUITextField!
    
    @IBOutlet weak var tfConfrimPw: MJUITextField!
    
    @IBOutlet weak var btnApply: MJButton!
    
    fileprivate var curCode = "中国 +86" //当前区号
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUIAppearance()
        
    }
    func setUIAppearance(){
        self.title = "设置/重置支付密码"
        self.view.backgroundColor = UIColor.KTheme.scroll
        btnArea.addTarget(self, action: #selector(self.onAreaBtnClicked), for: .touchUpInside)
        btnArea.set(image: UIImage(named: "下下"), title: "地区", titlePosition: .left,
                      additionalSpacing: 2, state: .normal)
        btnCode.addTarget(self, action: #selector(self.onCodeBtnClicked), for: .touchUpInside)
        
        tfPhone.text = CacheClass.stringForEnumKey(.mobile) ?? ""

        
        tfPhone.addTarget(self, action: #selector(self.textValueChanged), for: .editingChanged)
        tfCode.addTarget(self, action: #selector(self.textValueChanged), for: .editingChanged)
        tfNewPw.addTarget(self, action: #selector(self.textValueChanged), for: .editingChanged)
        tfConfrimPw.addTarget(self, action: #selector(self.textValueChanged), for: .editingChanged)

        tfNewPw.isSecureTextEntry = true
        tfConfrimPw.isSecureTextEntry = true
        
        btnArea.setTitle(CacheClass.stringForEnumKey(.mobile_code) ?? "+86", for: .normal)
    }
    @objc func textValueChanged(){
        btnApply.isClickEnabled = !(tfCode.isEmpty) && !(tfNewPw.isEmpty) && !(tfConfrimPw.isEmpty) && !(tfPhone.isEmpty)
    }
    @objc func onCodeBtnClicked(){
        
        
        if tfPhone.text == "" {
            
            MBProgressHUD_JChat.show(text: "请输入手机号", view: self.view)
            return
        }
        
        var areaCode = self.btnArea.titleLabel?.text!
        
        if areaCode == "地区" {
            areaCode = "+86"
        }
        
        NetworkRequest.requestMethod(.post, URLString: url_forgetPwCode, parameters: ["account":tfPhone.text!,"mobile_code":areaCode!], success: { (value, json) in
            
            if  json["status"].stringValue == "SUCCESS" {
                
                self.btnCode.mj_countDown(count: 60, enabledColor: UIColor.KTheme.deepOrange)
                
            }else{
                MBProgressHUD_JChat.show(text: json["error"].stringValue, view: self.view)
            }
            
        }) {
            
            
        }
    }
    @objc func onAreaBtnClicked(){
        
        let codeArray = ["中国 +86","马来西亚 +60","菲律宾 +60","泰国 +66","缅甸 +95","印度尼西亚 +62","新加坡 +65","澳大利亚 +61"]
        
        let numArray = [11,10,10,9,10,11,8,9]
        
        let selectTypeVC = SelectTypeViewController.init(dataArray: codeArray, selectText: "中国 +86")
        selectTypeVC.modalPresentationStyle = .overCurrentContext
        selectTypeVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        selectTypeVC.textBlock = { [weak self] (text) in
            self?.btnArea.set(image: UIImage(), title: String(text.suffix(3)), titlePosition: .left,
                        additionalSpacing: 2, state: .normal)
            
            self?.curCode = text
            
//            self?.tfPhone.text = ""
            
            let index = codeArray.index(of: text)
            ZZLimitInputManager.limitInputView(self?.tfPhone, maxLength: UInt(numArray[index ?? 0]))
        }
        self.present(selectTypeVC, animated: false, completion: nil)
    }
    
    @IBAction func onApplyBtnClicked(_ sender: Any) {
        
        
        if tfNewPw.text != tfConfrimPw.text {
            MBProgressHUD_JChat.show(text: "密码不一致", view: self.view)
            return
        }
        
        if tfNewPw.text?.count != 6 {
            MBProgressHUD_JChat.show(text: "支付密码必须为6位", view: self.view)
            return
        }
        
        let passWord = tfNewPw.text!.trimed()
        
        let passwordStr = RSA.encryptString(passWord, publicKey: publicKey)
        
        MBProgressHUD_JChat.showMessage(message: "修改中", toView: view)
        
        NetworkRequest.requestMethod(.post, URLString: url_changePayPW, parameters: ["captcha":tfCode.text!,"pay_pass":passwordStr ?? "","method":"PUT"], success: { (value, json) in
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
            
            if json["status"].stringValue == "SUCCESS" {
                
                MBProgressHUD_JChat.show(text: "修改成功", view: self.view)
                
                getUserNews()
                
                self.navigationController?.popViewController(animated: true)
                
            }else{
                MBProgressHUD_JChat.show(text: json["error"].stringValue, view: self.view)
            }
            
        }) {
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
            
        }
        
        
    }
    

   

}
