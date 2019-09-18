//
//  MJTbvColorHeadView.swift
//  XLCustomer
//
//  Created by longma on 2019/1/8.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class KAlertPayContentView: UIView {
    var passwordDotsArray = [UIView]()
    let kDotsNumber:CGFloat = 6  //密码位数
    let kDotWith_height:CGFloat = 10 //假密码点点的宽和高  应该是等高等宽的正方形 方便设置为圆
    let kDotSpace:CGFloat = -1
    var viewContentW:CGFloat = (ScreenW - (43+16) * 2)
    var passwordW_H:CGFloat = 0

    @IBOutlet weak var labMoney: UILabel!
    @IBOutlet weak var btnDel: UIButton!
    @IBOutlet weak var viewContent: UIView!
    
    var pawBlock:((_ paw:String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        passwordW_H = viewContentW/6

        self.setUIAppearance()

    }
    lazy var passwordField: GLTextField = {
        
        let password_x =  (viewContentW - passwordW_H * kDotsNumber - kDotSpace * (kDotsNumber - 1))
        let password_w = passwordW_H * kDotsNumber + (kDotsNumber - 1) * kDotSpace
        
        let _passwordField = GLTextField ()
        
        _passwordField.frame = CGRect.init(x: 16, y: 180, width: password_w, height: passwordW_H)
        _passwordField.backgroundColor = UIColor.red
        _passwordField.textColor = UIColor.clear
        _passwordField.tintColor = UIColor.clear
        _passwordField.keyboardType = .numberPad
        _passwordField.isSecureTextEntry = true
        _passwordField.addTarget(self, action: #selector(self.passwordFieldDidChange), for: .editingChanged)
        
        return _passwordField
    }()
    
    @objc func passwordFieldDidChange(sender:GLTextField){
        
        self.setDotsViewHidden()
        if let text = sender.text {
            for i in 0..<text.count {
                if passwordDotsArray.count > i {
                    let dotView = passwordDotsArray[i]
                    dotView.isHidden = false
                }
            }
            
            if text.count == 6 {
                if pawBlock != nil{
                    pawBlock!(text)
                }
            }
            
        }
        
        
    }
    func setDotsViewHidden(){
        
        for  view in passwordDotsArray {
            view.isHidden = true
        }
        
        
    }
    @objc func actionShowKeyboard(){
        self.passwordField.becomeFirstResponder()
    }
    
    func setUIAppearance(){
        self.viewContent.addSubview(passwordField)
        self.addDotsViews()
    }
    func addDotsViews(){
        
        for i in 0..<Int(kDotsNumber) {
            //密码框的x坐标
            let kViewX = CGFloat(i) * (passwordW_H + kDotSpace)
            let kViewY = 0;
            let kView = UIView.init(frame: CGRect.init(x: kViewX, y: CGFloat(kViewY), width: passwordW_H, height: passwordW_H))
            kView.backgroundColor = UIColor.white
            kView.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action:#selector(actionShowKeyboard))
            kView.addGestureRecognizer(tap)
            kView.setBorder(color: UIColor.KTheme.shallowGray, width: 1)
            passwordField.addSubview(kView)
            //
            //假密码点的x坐标
            let dotViewX = passwordW_H - passwordW_H / 2.0 - kDotWith_height / 2.0;
            let dotViewY = (passwordW_H - kDotWith_height) / 2.0;
            let dotView = UIView.init(frame: CGRect.init(x: dotViewX, y: dotViewY, width: kDotWith_height, height: kDotWith_height))
            dotView.backgroundColor = UIColor.black
            dotView.setCornerRadius(kDotWith_height/2.0)
            dotView.isHidden = true
            kView.addSubview(dotView)
            passwordDotsArray.append(dotView)
        }
    }
}
