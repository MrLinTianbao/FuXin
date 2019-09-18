//
//  KSimpleTitleTbvCell.swift
//  XLCustomer
//
//  Created by longma on 2019/1/2.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class MineWalletTbvCell: UITableViewCell {

    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var labTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.btnRight.isEnabled = false
        self.btnRight.adjustsImageWhenDisabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
