//
//  KSimpleTitleTbvCell.swift
//  XLCustomer
//
//  Created by longma on 2019/1/2.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class WalletRecordTbvCell: UITableViewCell {
    
    var model : WalletRecordModel! {
        didSet{
            updateData()
        }
    }

    @IBOutlet weak var labState: UILabel!
    @IBOutlet weak var labMoney: UILabel!
    @IBOutlet weak var labTime: UILabel!
    @IBOutlet weak var labTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    fileprivate func updateData() {
        
        labTitle.text = model.tags
        labTime.text = model.create_time
        labState.text = ""
        
        
        let amount = model.change_amount ?? "0"
        
        if (model.type ?? "0") == "0" {
            labMoney.text = "+" + amount
        }else{
            labMoney.text = "-" + amount
        }
        
//        switch model.change_type {
//        case "0":
//            labTitle.text = "充值"
//        case "1":
//            labTitle.text = "提现"
//        case "2":
//            labTitle.text = "赔款"
//        case "3":
//            labTitle.text = "退款"
//        case "4":
//            labTitle.text = "发红包"
//        case "5":
//            labTitle.text = "领取红包"
//        case "6":
//            labTitle.text = "转账"
//        default:
//            break
//        }
    }
    
}
