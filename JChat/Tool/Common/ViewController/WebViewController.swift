//
//  WebViewController.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/7/12.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: CTViewController {
    
    ///webview
    fileprivate var webView : WKWebView!
    
    ///链接
    fileprivate var urlStr  = ""
    
    ///进度条
    fileprivate let progressView = UIProgressView()
    
    fileprivate var timer : Timer!
    
    var isPay = false //支付页面
    
    var order_id  = "" //订单号
    var pay_order_id = "" //用于传递给第三方支付平台的支付订单号，如：201904150556014827
    var pay_type = "0" //支付订单类型，默认0为充值订单支付
    
    var isRequest = false //是否正在请求
    
    init(urlString:String?,title:String? = "") {
        super.init(nibName: nil, bundle: nil)
        
        self.urlStr = urlString ?? ""
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isPay {
            self.setNavLeftItem(imageStr: "返回Back")
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.getOrderStatus(sender:)), userInfo: nil, repeats: true)
//            RunLoop.current.add(timer, forMode: .common)
        }

        progressView.trackTintColor = UIColor.clear
        progressView.progressTintColor = UIColor.KTheme.deepOrange
        self.view.addSubview(progressView)
        
        progressView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(RATIO_H(maxNum: 5))
        }
        
        createWebView()
        
        self.view.bringSubviewToFront(progressView)
        
        AlertClass.setRefresh(with: webView.scrollView, headerAction: {[weak self] in
            
            if let url = URL.init(string: (self?.urlStr)!) {
                let request = URLRequest.init(url: url)
                self?.webView.load(request)
            }
            
        }, footerAction: nil)
    }
    
    override func actionLeftItemClick() {
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: 获取订单状态
    @objc fileprivate func getOrderStatus(sender:Timer) {
        
        if isRequest {
            return
        }
        
        isRequest = true
        
        NetworkRequest.requestMethod(.get, URLString: url_PayStatus, parameters: ["order_id":order_id,"pay_order_id":pay_order_id,"pay_type":pay_type], success: { (value, json) in
            
            if json["status"].stringValue == "SUCCESS" {
                
                self.timer.invalidate()
                self.timer = nil
                
                let vc = MineWalletVC()
                vc.isPay = true
                self.navigationController?.pushViewController(vc)
                
            }else{
                self.isRequest = false
            }
            
            
        }) {
            
            self.isRequest = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil
        }
        
    }
    
    deinit {
        
        if self.webView != nil {
            self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        }
        
    }
    
    fileprivate func createWebView() {
        
        self.webView = WKWebView.init(frame: .zero)
    
        
        
        if let url = URL.init(string: urlStr) {
            let request = URLRequest.init(url: url)
            webView.load(request)
        }
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        self.view.addSubview(webView)
        
        
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets.zero)
        }
        
        if isPay {
            //添加长按手势
            let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(self.handleLongPress(sender:)))
            longPress.minimumPressDuration = 0.5
            longPress.delegate = self
            self.webView.addGestureRecognizer(longPress)
        }
        
        
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if "estimatedProgress" == keyPath {
            self.progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
            if self.progressView.progress == 0 {
                self.progressView.isHidden = false
            }else if self.progressView.progress == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if self.progressView.progress == 1 {
                        self.progressView.progress = 0
                        self.progressView.isHidden = true
                    }
                }
            }
        }
    }
    
    //MARK: 长按手势
    @objc fileprivate func handleLongPress(sender:UILongPressGestureRecognizer) {
        
        if sender.state != .began {
            return
        }
        
//        let touchPoint = sender.location(in: self.webView)
        
        let selectPhotoVC = SelectPhotoViewController.init(titleArray: ["保存到相册中"])
        selectPhotoVC.modalPresentationStyle = .overCurrentContext
        selectPhotoVC.photoBlock = {(title) in
            
            if title == "保存到相册中" {

//                self.savePhotoToAlbum(touchPoint: touchPoint)
                
                UIGraphicsBeginImageContextWithOptions(CGSize.init(width: self.webView.frame.size.width, height: self.webView.scrollView.contentSize.height), false, 0) //原图
                self.webView.layer.render(in: UIGraphicsGetCurrentContext()!)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
                
            }
            
        }
        self.present(selectPhotoVC, animated: false, completion: nil)
    
        
    }
    
    fileprivate func savePhotoToAlbum(touchPoint:CGPoint) {
        
        
        // 获取长按位置对应的图片url的JS代码
        let imgJS = "document.elementFromPoint(\(touchPoint.x),\(touchPoint.y)).src"
        // 执行对应的JS代码 获取url
        self.webView.evaluateJavaScript(imgJS) { (imgUrl, error) in
            
            if let url = imgUrl as? String {
                let data = NSData.init(contentsOf: URL.init(string: url)!)
                let image = UIImage.init(data: data! as Data)
                if image == nil {
                    return
                }else{
                    UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
                }
                
                
            }
        }
    }
    
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        var showMessage = ""
        
        if error != nil{
            
            showMessage = "保存失败"
            
        }else{
            
            showMessage = "保存成功"
            
        }
        
        SVProgressHUD.showInfo(withStatus: showMessage)
        
        
    }

}

extension WebViewController : WKNavigationDelegate,WKUIDelegate {
    
    //MARK: 页面加载失败
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        MyLog(global_requestFailed)
        
        webView.scrollView.mj_header.endRefreshing()
    }
    
    
    
    //MARK: 页面加载成功
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        MyLog(global_loadSuccess)
        
        webView.scrollView.mj_header.endRefreshing()
        
        //        // 不执行前段界面弹出列表的JS代码
        //
        let javascript = "document.documentElement.style.webkitTouchCallout='none';"
        webView.evaluateJavaScript(javascript, completionHandler: nil)

    }
    
    
    
}

extension WebViewController : UIGestureRecognizerDelegate {
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer is UILongPressGestureRecognizer {
            return true
        }else{
            return false
        }
        
    }
}
