//
//  MJTbvColorHeadView.swift
//  XLCustomer
//
//  Created by longma on 2019/1/8.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class MJTbvColorHeadView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    var mjBgColor : UIColor!{
        didSet{
            let underView = UIView(frame: CGRect(x: 0, y: -3000, width: ScreenW, height: 3000))
            underView.backgroundColor = mjBgColor
            insertSubview(underView, at: 0)
        }
    }
}
