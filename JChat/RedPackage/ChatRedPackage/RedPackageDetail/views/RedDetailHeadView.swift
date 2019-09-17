//
//  MJTbvColorHeadView.swift
//  XLCustomer
//
//  Created by longma on 2019/1/8.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class RedDetailHeadView: MJTbvColorHeadView {

    @IBOutlet weak var labCount: UILabel!
    @IBOutlet weak var imvTips: UIImageView!
    @IBOutlet weak var labMoney: UILabel!
    @IBOutlet weak var labSubTitle: UILabel!
    @IBOutlet weak var imvHead: UIImageView!
    @IBOutlet weak var labTitle: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.mjBgColor = UIColor.init(hexString: "#E1604D")
    }

}
