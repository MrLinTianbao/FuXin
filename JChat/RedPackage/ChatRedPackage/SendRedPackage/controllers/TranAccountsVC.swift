//
//  PocketPay1VC.swift
//  XLCustomer
//
//  Created by longma on 2019/1/9.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class TranAccountsVC: CTViewController {
    
    var redBlock : ((String,String)->Void)?
    
    @IBOutlet weak var imvIcon: UIImageView!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var viewBottom: UIView!
    
    @IBOutlet weak var tfMoney: MJUITextField!
    @IBOutlet weak var btnApply: MJButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUIAppearance()
        
    }
    func setUIAppearance(){
        self.title = "转账"
        self.view.backgroundColor = UIColor.KTheme.scroll
        tfMoney.addTarget(self, action: #selector(self.textValueChanged), for: .editingChanged)
        tfMoney.mj_becomeFirstResponder()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewBottom.setCorner(cornerRadius: 20, corner: [.topLeft,.topRight])

    }
    @objc func textValueChanged(){
        btnApply.isClickEnabled = !(tfMoney.isEmpty)
    }
    @IBAction func onApplyBtnClicked(_ sender: Any) {
        
        redBlock?(tfMoney.text!,"转账")
        self.navigationController?.popViewController(animated: true)
        
    }
    

   

}
