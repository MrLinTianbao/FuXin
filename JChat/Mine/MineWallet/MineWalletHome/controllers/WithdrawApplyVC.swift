//
//  PocketPay1VC.swift
//  XLCustomer
//
//  Created by longma on 2019/1/9.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class WithdrawApplyVC: CTViewController {
    
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var btnApply: MJButton!
    @IBOutlet weak var tfMoney: MJUITextField!
    @IBOutlet weak var tfBankName: MJUITextField!
    @IBOutlet weak var tfID: MJUITextField!
    @IBOutlet weak var tfName: MJUITextField!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUIAppearance()
        
    }
    func setUIAppearance(){
        self.title = "提现申请"
        self.view.backgroundColor = UIColor.KTheme.scroll
        tfMoney.adjustsFontSizeToFitWidth = true
        tfBankName.addTarget(self, action: #selector(self.textValueChanged), for: .editingChanged)
        tfID.addTarget(self, action: #selector(self.textValueChanged), for: .editingChanged)
        tfName.addTarget(self, action: #selector(self.textValueChanged), for: .editingChanged)
        tfMoney.addTarget(self, action: #selector(self.textValueChanged), for: .editingChanged)

        tfID.keyboardType = .numberPad
        tfMoney.keyboardType = .decimalPad
        tipsLabel.text = "⚠️提现注意事项：\n工作时间每天早上9:00到凌晨1:00.请提供正确的收款信息，如有什么疑问，请联系客服处理"
        
        bottomLabel.adjustsFontSizeToFitWidth = true
        
        amountLabel.text = "当前余额为：" + (CacheClass.stringForEnumKey(.money) ?? "0")
    }
    @objc func textValueChanged(){
        btnApply.isClickEnabled = !(tfBankName.isEmpty) && !(tfID.isEmpty) && !(tfName.isEmpty) && !(tfMoney.isEmpty)
    }
    @IBAction func onApplyBtnClicked(_ sender: Any) {
        
        if Float(tfMoney.text ?? "0")! < 100 {
            MBProgressHUD_JChat.show(text: "提现金额不能少于100", view: self.view)
            return
        }
        
        MBProgressHUD_JChat.showMessage(message: "正在申请", toView: view)
        
        NetworkRequest.requestMethod(.post, URLString: url_withdrawDeposit, parameters: ["bank_name":tfBankName.text!,"card_number":tfID.text!,"name":tfName.text!,"amount":String(Float(tfMoney.text ?? "0")!)], success: { (value, json) in
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
            
            if json["status"].stringValue == "SUCCESS" {
                MBProgressHUD_JChat.show(text: json["message"].stringValue, view: self.view)
            }else{
                MBProgressHUD_JChat.show(text: json["error"].stringValue, view: self.view)
            }
            
        }) {
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
        }
        
    }
    

   

}
