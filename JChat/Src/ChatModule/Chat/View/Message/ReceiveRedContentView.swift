//
//  ReceiveRedContentView.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/7/22.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class ReceiveRedContentView: UILabel,JCMessageContentViewType {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    open func apply(_ message: JCMessageType) {
        guard let content = message.content as? ReceiveRedContent else {
            return
        }
        text = content.username! + "领取了你的红包"
    }
    
    private func _commonInit() {
        layer.cornerRadius = 2.5
        layer.borderWidth = 1.0
        layer.borderColor = UIColor(netHex: 0xD7DCE2).cgColor
        layer.masksToBounds = true
        font = UIFont.systemFont(ofSize: 12)
        backgroundColor = UIColor(netHex: 0xD7DCE2)
        textColor = .white
        textAlignment = .center
    }
    

}
