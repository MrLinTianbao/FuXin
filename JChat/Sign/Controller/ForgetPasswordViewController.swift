//
//  ForgetPasswordViewController.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/6/23.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class ForgetPasswordViewController: STLVideoViewController {
    @IBOutlet weak var areaBtn: UIButton!
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var codeTF: UITextField!
    
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var confirmTF: UITextField!
    
    @IBOutlet weak var downImage: UIImageView!
    
    @IBOutlet weak var codeBtn: UIButton!
    
    
    fileprivate var timer : Timer!
    
    fileprivate var sum = 60
    
    fileprivate var curCode = "中国 +86" //当前区号
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(backButton)
    }
    
    fileprivate lazy var backButton : UIButton = {
      
        let button = UIButton.init(frame: .init(x: 20, y: 40, width: 25, height: 25))
        button.setBackgroundImage(string: "white_back")
        button.addTarget(self, action: #selector(popAction), for: .touchUpInside)
        
        return button
        
    }()
    
    @objc fileprivate func popAction() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    

    //MARK: 获取验证码
    @IBAction func getCode(_ sender: UIButton) {
        
        var areaCode = self.areaBtn.titleLabel?.text!
        
        if areaCode == "地区" {
            areaCode = "+86"
        }
        
        NetworkRequest.requestMethod(.post, URLString: url_forgetPwCode, parameters: ["account":phoneTF.text!,"mobile_code":areaCode ?? "+86"], success: { (value, json) in
            
            if json["status"].stringValue == "SUCCESS" {
                
                self.codeBtn.isEnabled = false
                
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timeAction(sender:)), userInfo: nil, repeats: true)
            }else{
                MBProgressHUD_JChat.show(text: json["error"].stringValue, view: self.view)
            }
            
        }) {
            
            
        }
    }
    
    @objc fileprivate func timeAction(sender:Timer) {
        
        sum -= 1
        
        self.codeBtn.setTitle("\(sum)秒后重新获取", for: .normal)
        self.codeBtn.setTitleColor(UIColor.white, for: .normal)
        
        if sum == 0 {
            self.codeBtn.setTitle("获取验证码", for: .normal)
            self.codeBtn.setTitleColor(UIColor.KTheme.black, for: .normal)
            sum = 60
            timer.invalidate()
            timer = nil
            self.codeBtn.isEnabled = true
        }
        
    }
    
    //MARK: 确认
    @IBAction func confirmAction(_ sender: UIButton) {
        
        if passwordTF.text != confirmTF.text {
            
            MBProgressHUD_JChat.show(text: "输入密码不一致", view: self.view)
            return
        }
        
        let passWord = passwordTF.text!.trimed()
        
        let passwordStr = RSA.encryptString(passWord, publicKey: publicKey)
        
        var areaCode = self.areaBtn.titleLabel?.text!
        
        if areaCode == "地区" {
            areaCode = "+86"
        }
        
        MBProgressHUD_JChat.showMessage(message: "修改中", toView: view)
        
        NetworkRequest.requestMethod(.post, URLString: url_forgetPassword, parameters: ["username":phoneTF.text!,"userpass":passwordStr ?? "","captcha":codeTF.text!,"mobile_code":areaCode ?? "+86"], success: { (value, json) in
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
            
            if json["status"].stringValue == "SUCCESS" {
                
                MBProgressHUD_JChat.show(text: "修改成功", view: self.view)
                self.navigationController?.popViewController(animated: true)
                
            }else{
                MBProgressHUD_JChat.show(text: json["error"].stringValue, view: self.view)
            }
            
        }) {
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
        }
        
    }
    
    //MARK: 获取地区
    @IBAction func getArea(_ sender: UIButton) {
        
        let codeArray = ["中国 +86","马来西亚 +60","菲律宾 +60","泰国 +66","缅甸 +95","印度尼西亚 +62","新加坡 +65","澳大利亚 +61"]
        
        let numArray = [11,10,10,9,10,11,8,9]
        
        let selectTypeVC = SelectTypeViewController.init(dataArray: codeArray, selectText: "中国 +86")
        selectTypeVC.modalPresentationStyle = .overCurrentContext
        selectTypeVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        selectTypeVC.textBlock = { (text) in
            self.curCode = text
            
//            self.phoneTF.text = ""
            
            self.areaBtn.setTitle(String(text.suffix(3)), for: .normal)
            self.downImage.image = UIImage()
            
            let index = codeArray.index(of: text)
            ZZLimitInputManager.limitInputView(self.phoneTF, maxLength: UInt(numArray[index ?? 0]))
        }
        self.present(selectTypeVC, animated: false, completion: nil)
    }
    
    //MARK: 开始编辑
    @IBAction func textFieldDidBegin(_ sender: UITextField) {
        
        if areaBtn.titleLabel?.text == "地区" {
            MBProgressHUD_JChat.show(text: "请选择区号", view: self.view)
            self.view.endEditing(true)
        }
    }
    
    //MARK: 文本变化
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        
        if phoneTF.text != "" && codeTF.text != "" && passwordTF.text != "" && confirmTF.text != "" {
            
            confirmBtn.backgroundColor = UIColor.KTheme.deepOrange
            confirmBtn.isEnabled = true
            
        }else{
            
            confirmBtn.backgroundColor = UIColor.KTheme.shallowOrange
            confirmBtn.isEnabled = false
        }
        
    }
}
