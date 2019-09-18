//
//  PocketPay1VC.swift
//  XLCustomer
//
//  Created by longma on 2019/1/9.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class ChangeUserPasswardVC: CTViewController {
    @IBOutlet weak var tfOldPw: MJUITextField!
    @IBOutlet weak var labUserID: UILabel!
    
    @IBOutlet weak var tfNewPw: MJUITextField!
    
    @IBOutlet weak var tfConfrimPw: MJUITextField!
    
    @IBOutlet weak var btnApply: MJButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUIAppearance()
        
    }
    func setUIAppearance(){
        self.title = "修改密码"
        self.view.backgroundColor = UIColor.KTheme.scroll
        tfOldPw.addTarget(self, action: #selector(self.textValueChanged), for: .editingChanged)
        tfNewPw.addTarget(self, action: #selector(self.textValueChanged), for: .editingChanged)
        tfConfrimPw.addTarget(self, action: #selector(self.textValueChanged), for: .editingChanged)

        tfNewPw.isSecureTextEntry = true
        tfConfrimPw.isSecureTextEntry = true
        labUserID.text = CacheClass.stringForEnumKey(.nickname)

    }
    @objc func textValueChanged(){
        btnApply.isClickEnabled = !(tfOldPw.isEmpty) && !(tfNewPw.isEmpty) && !(tfConfrimPw.isEmpty)
    }
    @IBAction func onApplyBtnClicked(_ sender: Any) {
        
        if tfNewPw.text != tfConfrimPw.text {
            
            AlertClass.showToat(withStatus: "输入密码不一致")
            return
        }
        
        let oldPassWord = tfOldPw.text!.trimed()
        let oldPasswordStr = RSA.encryptString(oldPassWord, publicKey: publicKey)

        
        let passWord = tfNewPw.text!.trimed()
        let passwordStr = RSA.encryptString(passWord, publicKey: publicKey)
        
        
        let parm:[String : Any] = [
                   "username":CacheClass.stringForEnumKey(.mobile) ?? "",
                   "userpass":passwordStr ?? "","oldpass":oldPasswordStr ?? "","method":"PUT"
                  ]
        let username = CacheClass.stringForEnumKey(.username)
        AlertClass.show()
        self.view.endEditing(false)
        NetworkRequest.requestMethod(.post, URLString: url_changePw, parameters:parm , success: { (value, jsons) in
            
            
            if jsons["status"].stringValue == "SUCCESS" {
                
                AlertClass.stop()
                AlertClass.showToat(withStatus: jsons["message"].stringValue, completion: {
                    
                    JMSGUser.logout({ (result, error) in
                        JCVerificationInfoDB.shareInstance.queue = nil
                        //            Account.removeObjectForKey(kCurrentUserToken)
                        UserDefaults.standard.removeObject(forKey: kCurrentUserName)
                        UserDefaults.standard.removeObject(forKey: kCurrentUserPassword)
                        removeUseNews()
                        let appDelegate = UIApplication.shared.delegate
                        let window = appDelegate?.window!
                        window?.rootViewController = JCNavigationController(rootViewController: SignInViewController())
                    })
                    
                })
     
            }else{
                AlertClass.stop()
                AlertClass.showErrorToat(withJson: jsons)
            }
        }) {}
        
        
    }
    

   

}
