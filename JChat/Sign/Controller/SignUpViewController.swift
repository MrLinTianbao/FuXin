//
//  SignUpViewController.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/6/22.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit
import MediaPlayer

class SignUpViewController: STLVideoViewController {
    
    
    @IBOutlet weak var tfInvititaionCode: UITextField!
    @IBOutlet weak var areaBtn: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpBtn: UIButton!
    
    @IBOutlet weak var downImage: UIImageView!
    
    @IBOutlet weak var codeBtn: UIButton!
    
    fileprivate var timer : Timer!
    
    fileprivate var sum = 60
    
    fileprivate var curCode = "中国 +86" //当前区号
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
        
        ZZLimitInputManager.limitInputView(phoneTextField, maxLength: 11)
        
    }

    //MARK: 立即登录
    @IBAction func toSignIn(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: 注册
    @IBAction func signUpAction(_ sender: UIButton) {
        
        phoneTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        let userName = phoneTextField.text!.trimed()
        let passWord = passwordTextField.text!.trimed()
        
        let passwordStr = RSA.encryptString(passWord, publicKey: publicKey)
        
        let validateUsername = UserDefaultValidationService.sharedValidationService.validateUsername(userName)
        if !(validateUsername == .ok) {
            MBProgressHUD_JChat.show(text: validateUsername.description, view: view)
            return
        }
        
        let validatePassword = UserDefaultValidationService.sharedValidationService.validatePassword(passWord)
        if !(validatePassword == .ok) {
            MBProgressHUD_JChat.show(text: validatePassword.description, view: view)
            return
        }
        
        MBProgressHUD_JChat.showMessage(message: "注册中", toView: view)
        
        var areaCode = self.areaBtn.titleLabel?.text!
        
        if areaCode == "地区" {
            areaCode = "+86"
        }
        var parm = ["username":userName,"userpass":passwordStr ?? "","mobile_code":areaCode ?? "+86","captcha":codeTextField.text!]
        
        //邀请码
        let invCode = tfInvititaionCode.text!.trimed()
        if invCode.count > 0 {
            parm["invitation"] = invCode
        }
        
        NetworkRequest.requestMethod(.post, URLString: url_signUp, parameters: parm, success: { (value, json) in

            MBProgressHUD_JChat.hide(forView: self.view, animated: true)

            if json["status"].stringValue == "SUCCESS" {
                
                getUserNews(success: { (json) in
                    
                    JMSGUser.login(withUsername: userName, password: passWord) { (result, error) in
                        MBProgressHUD_JChat.hide(forView: self.view, animated: true)
                        if error == nil {
                            
                            //                        self.uploadImage()
                            
                            UserDefaults.standard.set(userName, forKey: kLastUserName)
                            UserDefaults.standard.set(userName, forKey: kCurrentUserName)
                            let appDelegate = UIApplication.shared.delegate
                            let window = appDelegate?.window!
                            window?.rootViewController = JCMainTabBarController()
                        } else {
                            MBProgressHUD_JChat.show(text: "登录失败", view: self.view)
                        }
                    }
                })
        
            
                
            }else{
                MBProgressHUD_JChat.show(text: json["error"].stringValue, view: self.view)
                MBProgressHUD_JChat.hide(forView: self.view, animated: true)
            }
        
        }) {

            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
        }
    
        
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
        
        if phoneTextField.text != "" && codeTextField.text != "" && passwordTextField.text != "" {
            
            signUpBtn.backgroundColor = UIColor.KTheme.deepOrange
            signUpBtn.isEnabled = true
            
        }else{
            
            signUpBtn.backgroundColor = UIColor.KTheme.shallowOrange
            signUpBtn.isEnabled = false
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
            
//            self.phoneTextField.text = ""
            
            self.areaBtn.setTitle(String(text.suffix(3)), for: .normal)
            self.downImage.image = UIImage()
            
            let index = codeArray.index(of: text)
            ZZLimitInputManager.limitInputView(self.phoneTextField, maxLength: UInt(numArray[index ?? 0]))
        }
        self.present(selectTypeVC, animated: false, completion: nil)
    }
    
    //MARK: 获取验证码
    @IBAction func getCode(_ sender: UIButton) {
        
     
        
        
        var areaCode = self.areaBtn.titleLabel?.text!
        
        if areaCode == "地区" {
            areaCode = "+86"
        }
    
        
//        let url = url_signUpCode + "&account=\(phoneTextField.text!)&mobile_code=\(areaCode ?? "86")"
        
        NetworkRequest.requestMethod(.post, URLString: url_signUpCode, parameters: ["account":phoneTextField.text!,"mobile_code":areaCode ?? "+86"], success: { (value, json) in

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
    
    //MARK: 上传头像
    private func uploadImage() {
        
        let imageData = chatDefaultHead?.pngData()
        
        JMSGUser.updateMyAvatar(with: imageData!, avatarFormat: "png") { (result, error) in
            
            if error == nil {
                let avatorData = NSKeyedArchiver.archivedData(withRootObject: imageData!)
                UserDefaults.standard.set(avatorData, forKey: kLastUserAvator)
                NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateUserInfo), object: nil)
            }
        }
    }
    
    
}
