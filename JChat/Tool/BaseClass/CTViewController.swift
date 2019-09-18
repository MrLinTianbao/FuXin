//
//  CTViewController.swift
//  CityTube
//
//  Created by DUONIU_MAC on 2019/6/5.
//  Copyright © 2019年 DUONIU_MAC. All rights reserved.
//

import UIKit

class CTViewController: UIViewController {

    enum EMPTYSTYLE : Int {
        
        case emptyViewNoData
        
        
    }
    
    enum CTNAVSTYLE : Int {
        
        case white
        
        case red
        
    }
    var ctNavStyle:CTNAVSTYLE = .white
    
  override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBarTheme()

    }
    
    //MARK: 设置UINavigationBar的主题
    func setupNavigationBarTheme(){
       
        var backImg = UIImage.init(named: "返回Back")
        var navBgColor = UIColor.KTheme.scroll
        var navBackColor = UIColor.KTheme.black
        switch ctNavStyle {
        case .white:
            backImg = UIImage.init(named: "返回Back")
            navBgColor = UIColor.KTheme.scroll
            navBackColor = UIColor.KTheme.black
            break
        case .red:
            backImg = UIImage.init(named: "backYell")
            navBgColor = UIColor.init(hexString: "#E1604D")!
            navBackColor = UIColor.init(hexString: "#F4D3A2")!
            //隐藏导航栏底部的线条
            navigationController?.navigationBar.shadowImage = UIImage.init()

            break
       
        }
        //修改返回按钮图片
        self.navigationController?.navigationBar.backIndicatorImage = backImg
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImg
        
        
        //不让导航栏遮挡视图
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.view.backgroundColor = UIColor.white
        
        //修改返回按钮文字
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
        
        //导航栏背景颜色
        self.navigationController?.navigationBar.barTintColor = navBgColor
        
        // 设置返回文字颜色,默认返回按钮颜色
        self.navigationController?.navigationBar.tintColor = navBackColor
        
        //设置中部文字属性
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.KTheme.black,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18)]
    }
    
    /// 根据target 字符串跳转控制器
    ///
    /// - Parameter targetStr: 控制器字符串
    func pushViewController(targetStr:String){
        let clsName = Bundle.main.infoDictionary!["CFBundleExecutable"] as? String//这是获取项目的名称，
        let className=clsName! + "." + targetStr
        let viewC = NSClassFromString(className)!as! UIViewController.Type //这里需要指定类的类型XX.Type
        let vc =  viewC.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setNavRightItem(title: String,titleColor:UIColor = UIColor.KTheme.black) {
        
        let navRightItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(self.actionRightItemClick))
        navRightItem.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: titleColor], for: .normal)
        navRightItem.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: titleColor], for: .highlighted)
        
        navigationItem.rightBarButtonItem = navRightItem
        
    }
    
    //MARK: 带图片的右键
    func setNavRightItem(imageStr: String) {
        
        let navRightItem = UIBarButtonItem.init(image: UIImage.init(named: imageStr), style: .done, target: self, action: #selector(self.actionRightItemClick))
        navRightItem.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], for: .normal)
        navRightItem.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], for: .highlighted)
        
        navigationItem.rightBarButtonItem = navRightItem
        
    }
    
    //MARK: 带图片的左键
    func setNavLeftItem(imageStr: String) {
        
        let navLeftItem = UIBarButtonItem.init(image: UIImage.init(named: imageStr), style: .done, target: self, action: #selector(self.actionLeftItemClick))
        navLeftItem.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], for: .normal)
        navLeftItem.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], for: .highlighted)
        
        navigationItem.leftBarButtonItem = navLeftItem
        
    }
    
    func setNavLeftItem(title: String,titleColor:UIColor = UIColor.KTheme.black) {
        
        let navRightItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(self.actionLeftItemClick))
        navRightItem.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: titleColor], for: .normal)
        navRightItem.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: titleColor], for: .highlighted)
        
        navigationItem.leftBarButtonItem = navRightItem
        
    }
    
    //MARK: 让视图覆盖状态栏
    func setAdjustmentBehavior(srvData:UIScrollView){
        if #available(iOS 11.0, *) {
            srvData.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    //MARK: 显示空白页面
    func showEmptyView(view:UIView,emptyStyle:EMPTYSTYLE){
        for subView in view.subviews {
            if subView is EmptyView {
                return
            }
        }
        
        let emptyView = EmptyView()
        emptyView.backgroundColor = view.backgroundColor
        let emptyViewFrame = CGRect.init(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
        var image = UIImage.init(named: "无数据")
        var title = "没有找到数据";
        
        if(emptyStyle == .emptyViewNoData)
        {
            image = UIImage.init(named: "无数据")
            title = "";
        }
        emptyView.frame = emptyViewFrame
        emptyView.show(with: image, title: title, detailTitle: nil, buttonTitle: nil, with: view)
        
    }
    /** 隐藏空白页面 */
    func hideEmptyView(view:UIView){
        EmptyView.hide(view)
    }
   
    
    @objc public func actionRightItemClick() {
        
        
    }
    @objc public func actionLeftItemClick() {
        
        
    }
    deinit {
        print("[\(NSStringFromClass(type(of: self).self))]===已被释放")
    }
}
