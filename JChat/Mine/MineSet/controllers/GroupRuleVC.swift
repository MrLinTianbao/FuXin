//
//  PocketPay1VC.swift
//  XLCustomer
//
//  Created by longma on 2019/1/9.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit
import WebKit

class GroupRuleVC: CTViewController {
    
    @IBOutlet weak var txvTips: UITextView!
    
    ///链接
    fileprivate var urlStr  = ""
    
    ///webview
    fileprivate var webView : WKWebView!
    ///进度条
    fileprivate let progressView = UIProgressView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = "群规"
        
        getData()
        
    

//        self.setUIAppearance()
        
    }
    
    deinit {

        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
 
    }
    
    fileprivate func createWebView() {
        
        progressView.trackTintColor = UIColor.clear
        progressView.progressTintColor = UIColor.KTheme.deepOrange
        self.view.addSubview(progressView)
        
        progressView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(RATIO_H(maxNum: 5))
        }
        
        self.webView = WKWebView.init(frame: .zero)
        
        self.view.bringSubviewToFront(progressView)
        
        if let url = URL.init(string: self.urlStr) {
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
    
    func setUIAppearance(){
        
        txvTips.textColor = UIColor.rgb(164, 164, 164)
        txvTips.text = ""
        txvTips.isEditable = false
        
        
    }

    //MARK: 获取群规
    fileprivate func getData() {
        AlertClass.show()
        NetworkRequest.requestMethod(.get, URLString: url_aboutUs, parameters: ["id":"7"], success: { (value, json) in
            AlertClass.stop()
            if json["status"] == "SUCCESS" {
                
//                self.txvTips.text = json["ret_data"]["bodys"].stringValue
                
                self.urlStr = json["ret_data"]["arcurl"].stringValue

                self.createWebView()
            }
            
        }) {
            
            
        }
    }
   

}

extension GroupRuleVC : WKNavigationDelegate,WKUIDelegate {
    
    //MARK: 页面加载失败
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        MyLog(global_requestFailed)
        

    }
    
    
    
    //MARK: 页面加载成功
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        MyLog(global_loadSuccess)
        
   
        
       
    }
    
    
    
}
