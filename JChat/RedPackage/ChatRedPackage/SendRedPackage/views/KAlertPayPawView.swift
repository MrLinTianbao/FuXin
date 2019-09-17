//
//  KStarEvaluationView.swift
//  XLCustomer
//
//  Created by longma on 2019/5/13.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit


class KAlertPayPawView: UIView {
    
    let viewHeight:CGFloat = 180 + (ScreenW - (43+16) * 2)/6 + 30
    var money:CGFloat = 0
    var confirmBlock:((_ title:String,_ alertView:KAlertPayPawView) -> Void)?

    class func showAlertPayPawView(money:CGFloat,type:String?, completion: @escaping (_ title:String,_ alertView:KAlertPayPawView) -> Void){
        
        let keyWindow = UIApplication.shared.keyWindow
        let blackView = KAlertPayPawView.init(frame: (keyWindow?.frame)!)
        keyWindow?.addSubview(blackView)
        blackView.money = money
        blackView.confirmBlock = completion
        blackView.addSubviewsForView()
        blackView.show()
        
    }
    override init(frame: CGRect ) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.rgb(0, 0, 0, transparency: 0)
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        tap.delegate = self
        addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(show_Action), name: UIResponder.keyboardWillShowNotification, object: nil)//键盘显示时的方法
        NotificationCenter.default.addObserver(self, selector: #selector(hide_Action), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func hide_Action(_ sender:NSNotification)
    {
        viewContent.center = self.center
    }
    @objc func show_Action(_ sender:NSNotification)
    {
        //view 向上移动
//        print("userinfo = \(sender.userInfo)")
        let value = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let rect:CGRect = value.cgRectValue //获取键盘的高度
        if  rect.size.height > 50 {
            var frame: CGRect = viewContent.frame
            frame.origin.y = ScreenH - 10 - rect.size.height - viewHeight
            viewContent.frame = frame
        }
    }
    func addSubviewsForView(){
        addSubview(viewContent)
        
        viewContent.addSubview(centerView)
        centerView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(viewContent)
        }
      
    }
    
    lazy var centerView: KAlertPayContentView = {
        let view = Bundle.main.loadNibNamed("KAlertPayContentView", owner: self, options: nil)?.last as! KAlertPayContentView
        view.btnDel.addTarget(self, action: #selector(self.dismiss), for: .touchUpInside)
        view.labMoney.text = "￥\(money)"
        view.pawBlock = { [weak self] (paw)  in
            if self?.confirmBlock != nil{
                self?.confirmBlock!(paw,self!)
            }
        }
        view.passwordField.becomeFirstResponder()
        return view
    }()
    @objc func actionBackClick(){
    }
    lazy var viewContent: UIView = {
        
        let view = UIView ()
        view.backgroundColor = UIColor.white
        view.frame = CGRect(x: 30, y: 0, width: ScreenW - 43*2, height: viewHeight)
        view.center = self.center;
        view.setCornerRadius(5)

        return view
    }()
    @objc func dismiss(){
        
        
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundColor = UIColor.rgb(0, 0, 0, transparency: 0)
            self.viewContent.alpha = 0
            
        }) { finished in
            self.removeFromSuperview()
        }
        
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    func show(){
        
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, transparency: 0.5)!
            self.viewContent.alpha = 1
            
        }) { finished in
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension KAlertPayPawView:UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if touch.view?.isDescendant(of: viewContent) ?? false {
            return false
        }
        return true
    }
}
