//
//  MyCircleImageCell.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/6/26.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class MyCircleImageCell: UITableViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var circleImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        circleImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
