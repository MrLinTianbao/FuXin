//
//  PocketPay1VC.swift
//  XLCustomer
//
//  Created by longma on 2019/1/9.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class ChangeUserNameVC: CTViewController {
    
    
    @IBOutlet weak var tfName: MJUITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUIAppearance()
        
    }
    func setUIAppearance(){
        self.title = "修改昵称"
        self.view.backgroundColor = UIColor.KTheme.scroll
        self.setNavRightItem(title: "完成", titleColor: UIColor.init(hexString: "#E97C95")!)
        tfName.mj_becomeFirstResponder()
        tfName.text = CacheClass.stringForEnumKey(.nickname)

    }
    override func actionRightItemClick() {
        if tfName.isEmpty {
            return
        }
        tfName.resignFirstResponder()
        let nickname = tfName.text ?? ""
        let parm:[String : Any] = [
            "nickname":nickname,
            "method":"PUT",
            ]
        AlertClass.show()
        NetworkRequest.requestMethod(.post, URLString: url_signUp, parameters:parm , success: { (value, json) in
            AlertClass.stop()
            
            if json["status"].stringValue == "SUCCESS" {
                
                JMSGUser.updateMyInfo(withParameter: nickname, userFieldType: .fieldsNickname) { (resultObject, error) -> Void in
                    if error == nil {
                        CacheClass.setObject(self.tfName.text, forEnumKey: .nickname)

                        AlertClass.showToat(withStatus: json["message"].stringValue, completion: {
                            self.navigationController?.popViewController()
                        })
                    } else {
                        AlertClass.showToat(withStatus: "修改失败")
                        print("error:\(String(describing: error?.localizedDescription))")
                    }
                }
                
                
                
            }else{
                AlertClass.showErrorToat(withJson: json)
            }
        }) {}
        
        
    }
    

   

}
