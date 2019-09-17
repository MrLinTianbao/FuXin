//
//  PocketPay1VC.swift
//  XLCustomer
//
//  Created by longma on 2019/1/9.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class AboutVC: CTViewController {
    
    @IBOutlet weak var txvTips: UITextView!
    
    @IBOutlet weak var logoImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUIAppearance()
        
    }
    func setUIAppearance(){
        self.title = "关于我们"
        txvTips.textColor = UIColor.rgb(164, 164, 164)
        txvTips.text = ""
        txvTips.isEditable = false
        
        getData()
    }

    //MARK: 获取关于我们
    fileprivate func getData() {
        
        NetworkRequest.requestMethod(.get, URLString: url_aboutUs, parameters: ["id":"6"], success: { (value, json) in
            
            if json["status"] == "SUCCESS" {
                
                self.titleLabel.text = json["ret_data"]["title"].stringValue
                self.txvTips.text = json["ret_data"]["bodys"].stringValue
//                self.logoImage.setUrlImage(with: json["ret_data"]["titleimg"].stringValue)
            }
            
        }) {
            
            
        }
    }
   

}
