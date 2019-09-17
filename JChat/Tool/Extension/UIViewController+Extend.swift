//
//  UIViewController+Extend.swift
//  CityTube
//
//  Created by DUONIU_MAC on 2019/6/5.
//  Copyright © 2019年 DUONIU_MAC. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    // MARK: 设置错误提示框
    public func showErrorAlert(title :String? = "网络请求失败",msg:String? = "") {
//        var errorStr = title
//        if msg != "" {
//            errorStr = global_requestFailed
//
//        }
//        
//        SVProgressHUD.showError(withStatus: errorStr)
        
        
        

        
    }
    
    //MARK: 重新登录
    public func signInAgain() {
        
        SVProgressHUD.showError(withStatus: "账户异常,请重新登录")
        
//        AlertClass.setAlertView(msg: "账户异常,请重新登录", target: self, haveCancel: false) { (alert) in
//
//            JMSGUser.logout({ (result, error) in
//                JCVerificationInfoDB.shareInstance.queue = nil
//                //            Account.removeObjectForKey(kCurrentUserToken)
//                UserDefaults.standard.removeObject(forKey: kCurrentUserName)
//                UserDefaults.standard.removeObject(forKey: kCurrentUserPassword)
//                let appDelegate = UIApplication.shared.delegate
//                let window = appDelegate?.window!
//                window?.rootViewController = JCNavigationController(rootViewController: SignInViewController())
//            })
//        }
        
        
    }
    
    //MARK: 判断页面是否存在
    public func isCurrentViewControllerVisible(viewcontroller:UIViewController) -> Bool {
        return viewcontroller.isViewLoaded && (viewcontroller.view.window != nil)
    }
    
}
