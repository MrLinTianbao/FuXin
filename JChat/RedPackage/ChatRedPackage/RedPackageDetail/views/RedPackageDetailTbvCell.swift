//
//  KSimpleTitleTbvCell.swift
//  XLCustomer
//
//  Created by longma on 2019/1/2.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class RedPackageDetailTbvCell: UITableViewCell {

    @IBOutlet weak var labMoneyTop: NSLayoutConstraint!
    @IBOutlet weak var imvState: UIImageView!
    @IBOutlet weak var labTips: UILabel!
    @IBOutlet weak var labMoney: UILabel!
    @IBOutlet weak var imvIcon: UIImageView!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
