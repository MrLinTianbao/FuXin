//
//  MyCircleTextCell.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/6/26.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class MyCircleTextCell: UITableViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
