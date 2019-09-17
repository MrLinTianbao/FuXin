//
//  BindPhoneViewController.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/7/5.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class BindPhoneViewController: STLVideoViewController {
    
    @IBOutlet weak var areaBtn: UIButton!
    
    @IBOutlet weak var codeBtn: UIButton!
    
    @IBOutlet weak var phoneTF: UITextField!
    
    @IBOutlet weak var codeTF: UITextField!
    
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var downImage: UIImageView!
    
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
        
        NetworkRequest.requestMethod(.post, URLString:  url_signUpCode, parameters: ["account":phoneTF.text!,"mobile_code":areaCode ?? "+86"], success: { (value, json) in
            
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
            self.codeBtn.setTitleColor(UIColor.KTheme.deepOrange, for: .normal)
            sum = 60
            timer.invalidate()
            timer = nil
            self.codeBtn.isEnabled = true
        }
        
    }
    
    //MARK: 选择地区
    @IBAction func getArea(_ sender: UIButton) {
        
        let codeArray = ["中国 +86","马来西亚 +60","菲律宾 +60","泰国 +66","缅甸 +95","印度尼西亚 +62","新加坡 +65","澳大利亚 +61"]
        
        let numArray = [11,10,10,9,10,11,8,9]
        
        let selectTypeVC = SelectTypeViewController.init(dataArray: codeArray, selectText: "中国 +86")
        selectTypeVC.modalPresentationStyle = .overCurrentContext
        selectTypeVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        selectTypeVC.textBlock = { (text) in
            self.curCode = text
            
            self.phoneTF.text = ""
            
            self.areaBtn.setTitle(String(text.suffix(3)), for: .normal)
            self.downImage.image = UIImage()
            
            let index = codeArray.index(of: text)
            ZZLimitInputManager.limitInputView(self.phoneTF, maxLength: UInt(numArray[index ?? 0]))
        }
        self.present(selectTypeVC, animated: false, completion: nil)
    }
    
    //MARK: 确认
    @IBAction func confirmAction(_ sender: UIButton) {
        
        let username = phoneTF.text!.trimed()
        let password = passwordTF.text!.trimed()
        
        let passwordStr = RSA.encryptString(password, publicKey: publicKey)
        
        var areaCode = self.areaBtn.titleLabel?.text!
        
        if areaCode == "地区" {
            areaCode = "+86"
        }
        
        MBProgressHUD_JChat.showMessage(message: "绑定中", toView: view)
        
        NetworkRequest.requestMethod(.post, URLString: url_bindPhone, parameters: ["username":username,"userpass":passwordStr ?? "","captcha":codeTF.text!,"mobile_code":areaCode ?? "+86","method":"PUT"], success: { (value, json) in
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
            
            if json["status"].stringValue == "SUCCESS" {
                
                    
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
    
    //MARK: 开始编辑
    @IBAction func textFieldDidBegin(_ sender: UITextField) {
        
        if areaBtn.titleLabel?.text == "地区" {
            MBProgressHUD_JChat.show(text: "请选择区号", view: self.view)
            self.view.endEditing(true)
        }
    }
    
    //MARK: 文本变化
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        
        if phoneTF.text != "" && codeTF.text != "" && passwordTF.text != "" {
            
            confirmBtn.backgroundColor = UIColor.KTheme.deepOrange
            confirmBtn.isEnabled = true
            
        }else{
            
            confirmBtn.backgroundColor = UIColor.KTheme.shallowOrange
            confirmBtn.isEnabled = false
        }
    }
    
    //MARK: 上传头像
    private func uploadImage(imageStr:String) {
        
        let imageData = imageStr.data(using: String.Encoding.utf8)
        JMSGUser.updateMyAvatar(with: imageData!, avatarFormat: "png") { (result, error) in
            
            if error == nil {
                let avatorData = NSKeyedArchiver.archivedData(withRootObject: imageData!)
                UserDefaults.standard.set(avatorData, forKey: kLastUserAvator)
                NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateUserInfo), object: nil)
            }
        }
    }
    
    private func setupNickname(nickname:String) {
        JMSGUser.updateMyInfo(withParameter: nickname, userFieldType: .fieldsNickname) { (resultObject, error) -> Void in
            if error == nil {
                NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateUserInfo), object: nil)
                
            }else{
                MyLog("error:\(String(describing: error?.localizedDescription))")
            }
        }
    }
}

