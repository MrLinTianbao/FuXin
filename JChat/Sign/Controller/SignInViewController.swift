//
//  SignInViewController.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/6/22.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit
import SwiftyJSON

class SignInViewController: STLVideoViewController {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBOutlet weak var signInBtn: UIButton!
    
    @IBOutlet weak var areaBtn: UIButton!
    
    @IBOutlet weak var downImage: UIImageView!
    
    fileprivate var curCode = "中国 +86" //当前区号
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        ZZLimitInputManager.limitInputView(phoneTextField, maxLength: 11)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(wechatLogin(sender:)), name: .wechat_login, object: nil)
       
        self.view.backgroundColor = UIColor.green
        self.view.setBackgroundImage(string: "sign_bg")
    }
    
    //MARK: 微信登录成功通知
    @objc fileprivate func wechatLogin(sender:Notification) {
        
        let json = JSON.init(sender.userInfo!)
        
        let code = json["code"].stringValue
        
        MBProgressHUD_JChat.showMessage(message: "登录中", toView: view)
        
        NetworkRequest.requestMethod(.post, URLString: url_wechat, parameters: ["code":code], success: { (value, json) in
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
            
            if json["status"].stringValue == "SUCCESS" {
                
                if let token = json["ret_data"]["token"].string {
                    
                    CacheClass.setObject(token, forEnumKey: .token)
                }
                
                if let userInfo = json["ret_data"]["userInfo"].dictionaryObject {
                    
                    let username = userInfo["username"] as? String
                    let password = userInfo["password"] as? String
                    
                    getUserNews(success: { (json) in
                        
                        DispatchQueue.global().async {
                            //上传头像
                            if let avatar = json["ret_data"]["avatar"].string {
                                if let iamgeData = NSData.init(contentsOf: URL.init(string: avatar)!) {
                                    //上传到IM
                                    JMSGUser.updateMyAvatar(with: iamgeData as Data, avatarFormat: "", completionHandler: { (resultObject, error) in
                                        if error == nil {
                                            JMSGUser.myInfo().thumbAvatarData({ (data, id, error) in
                                                if let data = data {
                                                    let imageData = NSKeyedArchiver.archivedData(withRootObject: data)
                                                    UserDefaults.standard.set(imageData, forKey: kLastUserAvator)
                                                } else {
                                                    UserDefaults.standard.removeObject(forKey: kLastUserAvator)
                                                }
                                            })
                                        } else {
                                            
                                        }
                                    })
                                    
                                    
                                }
                            }
                            
                            
                            //上传用户名
                            if let nickName = json["ret_data"]["nickname"].string {
                                
                                JMSGUser.updateMyInfo(withParameter: nickName, userFieldType: .fieldsNickname) { (resultObject, error) -> Void in
                                    
                                    if error == nil {
                                        
                                    } else {
                                        
                                    }
                                }
                            }
                            
                        }
                        
                        
                        
                        
                        JMSGUser.login(withUsername: username ?? "", password: password ?? "") { (result, error) in
                            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
                            if error == nil {
                                
                                
                                
                                UserDefaults.standard.set(username, forKey: kLastUserName)
                                JMSGUser.myInfo().thumbAvatarData({ (data, id, error) in
                                    if let data = data {
                                        let imageData = NSKeyedArchiver.archivedData(withRootObject: data)
                                        UserDefaults.standard.set(imageData, forKey: kLastUserAvator)
                                    } else {
                                        UserDefaults.standard.removeObject(forKey: kLastUserAvator)
                                    }
                                })
                                UserDefaults.standard.set(username, forKey: kCurrentUserName)
                                UserDefaults.standard.set(password, forKey: kCurrentUserPassword)
                                
                                
                                
                                let appDelegate = UIApplication.shared.delegate
                                let window = appDelegate?.window!
                                window?.rootViewController = JCMainTabBarController()
                                
                            } else {
                                MBProgressHUD_JChat.show(text: "\(String.errorAlert(error! as NSError))", view: self.view)
                                
                            }
                        }
                        
                        
                        
                    })
                    

                }else{
                    self.navigationController?.pushViewController(BindPhoneViewController())
                }
                

                
                
                
                
                
            }else{
                
                MBProgressHUD_JChat.show(text: json["error"].stringValue, view: self.view)
                
            }
            
        }) {
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
        }
    }
    
    //MAKR: 微信登录
    @IBAction func weChatSignIn(_ sender: UIButton) {
        
        //判断是否安装微信
        if WXApi.isWXAppInstalled() {
            
            let req = SendAuthReq()
            req.scope = "snsapi_userinfo"
            req.state = "FXApp"
            WXApi.send(req)
            
        }else{
            
            AlertClass.setAlertView(msg: "请先安装微信客户端", target: self, haveCancel: false, handler: nil)
        }
        
    }
    
    //MARK: 登录
    @IBAction func signInAction(_ sender: UIButton) {
        
        let username = phoneTextField.text!.trimed()
        let password = codeTextField.text!.trimed()
        
        let passwordStr = RSA.encryptString(password, publicKey: publicKey)
        
        let validateUsername = UserDefaultValidationService.sharedValidationService.validateUsername(username)
        if !(validateUsername == .ok) {
            MBProgressHUD_JChat.show(text: validateUsername.description, view: view)
            return
        }
        
        let validatePassword = UserDefaultValidationService.sharedValidationService.validatePassword(password)
        if !(validatePassword == .ok) {
            MBProgressHUD_JChat.show(text: validatePassword.description, view: view)
            return
        }
        
        MBProgressHUD_JChat.showMessage(message: "登录中", toView: view)
        
        NetworkRequest.requestMethod(.post, URLString: url_signIn, parameters: ["username":username,"userpass":passwordStr ?? ""], success: { (value, json) in
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
            
            if json["status"].stringValue == "SUCCESS" {
                let client_id = UserDefaults.standard.value(forKey: "client_id")
                if (client_id != nil) {
                    NetworkRequest.requestMethod(.post, URLString: url_bindIM, parameters: ["client_id":client_id ?? "", "method":"put"], success: { (bindValue, bindJson) in
                        
                        print("bindJson", bindJson)
                        
                    }){}
                }
                
                
                getUserNews(success: { (json) in
                    
                    JMSGUser.login(withUsername: username, password: password) { (result, error) in
                        MBProgressHUD_JChat.hide(forView: self.view, animated: true)
                        if error == nil {
                            UserDefaults.standard.set(username, forKey: kLastUserName)
                            JMSGUser.myInfo().thumbAvatarData({ (data, id, error) in
                                if let data = data {
                                    let imageData = NSKeyedArchiver.archivedData(withRootObject: data)
                                    UserDefaults.standard.set(imageData, forKey: kLastUserAvator)
                                } else {
                                    UserDefaults.standard.removeObject(forKey: kLastUserAvator)
                                }
                            })
                            UserDefaults.standard.set(username, forKey: kCurrentUserName)
                            UserDefaults.standard.set(password, forKey: kCurrentUserPassword)
                            let appDelegate = UIApplication.shared.delegate
                            let window = appDelegate?.window!
                            window?.rootViewController = JCMainTabBarController()
                        } else {
                            MBProgressHUD_JChat.show(text: "\(String.errorAlert(error! as NSError))", view: self.view)
                            
                        }
                    }
                })
                
                
            }else{
                MBProgressHUD_JChat.show(text: json["error"].stringValue, view: self.view)
            }
            
        }) {
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
        
        }
        
        
    }
    
    //MARK: 去注册
    @IBAction func toSignUp(_ sender: UIButton) {
        
        self.navigationController?.pushViewController(SignUpViewController())
    }
    
    //MARK: 忘记密码
    @IBAction func forgetPassword(_ sender: UIButton) {
        
        self.navigationController?.pushViewController(ForgetPasswordViewController(), animated: true)
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
        
        
        if phoneTextField.text != "" && codeTextField.text != "" {
            
            signInBtn.backgroundColor = UIColor.KTheme.deepOrange
            signInBtn.isEnabled = true
        }else{
            signInBtn.backgroundColor = UIColor.KTheme.shallowOrange
            signInBtn.isEnabled = false
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
            
            
            
//            self.phoneTextField.text = ""
            
            self.curCode = text
            
            self.areaBtn.setTitle(String(text.suffix(3)), for: .normal)
            self.downImage.image = UIImage()
            
            let index = codeArray.index(of: text)
            ZZLimitInputManager.limitInputView(self.phoneTextField, maxLength: UInt(numArray[index ?? 0]))
        }
        self.present(selectTypeVC, animated: false, completion: nil)
    }
    
}


