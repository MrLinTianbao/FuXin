//
//  PocketPay1VC.swift
//  XLCustomer
//
//  Created by longma on 2019/1/9.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class ChangeRemarkNameVC: CTViewController {
    var group: JMSGGroup?
    var user: JMSGUser!
    @IBOutlet weak var tfName: MJUITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUIAppearance()
        
    }
    func setUIAppearance(){
        if group != nil {
            self.title = "设置备注名"
           let memberInfo = group?.memberInfo(withUsername: user.username, appkey: user.appKey)
            tfName.text = memberInfo?.groupNickname
            
            
        }else{
            self.title = "修改好友备注"
            tfName.text = user.noteName
        }
        self.view.backgroundColor = UIColor.KTheme.scroll
        self.setNavRightItem(title: "完成", titleColor: UIColor.init(hexString: "#E97C95")!)
        tfName.mj_becomeFirstResponder()
    }
   
    override func actionRightItemClick() {
        if tfName.isEmpty {
            return
        }
        
        tfName.resignFirstResponder()
        let remark = tfName.text!
        AlertClass.waiting("修改中")
        if group == nil {
            user.updateNoteName(remark) { (result, error) in
                AlertClass.stop()
                if error == nil {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateFriendInfo), object: nil)
                    AlertClass.showToat(withStatus: "修改成功", completion: {
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                } else {
                    AlertClass.showToat(withStatus:  "\(String.errorAlert(error! as NSError))")
                    print("error:\(String(describing: error?.localizedDescription))")
                }
            }
        }else{
            
            group?.setGroupNickname(remark, username: user.username, appKey: nil, handler: { (result, error) in
                AlertClass.stop()
                if error == nil {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateFriendInfo), object: nil)
                    AlertClass.showToat(withStatus: "修改成功", completion: {
                        self.navigationController?.popViewController(animated: true)
                    })
                } else {
                    AlertClass.showToat(withStatus:  "\(String.errorAlert(error! as NSError))")
                    print("error:\(String(describing: error?.localizedDescription))")
                }
            })
            
            
        }
        
        
        
       

        
    }

   

}
