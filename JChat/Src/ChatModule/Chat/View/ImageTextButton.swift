//
//  ImageTextButton.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/7/13.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit
import SnapKit

class ImageTextButton: UIButton {
    
    fileprivate let iconImage = UIImageView()
    fileprivate let textLabel = UILabel()

    init(imageStr:String,title:String) {
        super.init(frame: .zero)
        
        iconImage.contentMode = .scaleAspectFit
        iconImage.image = UIImage.init(named: imageStr)
        self.addSubview(iconImage)
        
        textLabel.text = title
        textLabel.textColor = UIColor.KTheme.deepGray
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.textAlignment = .center
        self.addSubview(textLabel)
        
        iconImage.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        textLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconImage.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(10)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
