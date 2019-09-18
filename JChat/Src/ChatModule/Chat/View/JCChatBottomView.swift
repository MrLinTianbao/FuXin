//
//  JCChatBottomView.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/7/13.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class JCChatBottomView: UIView {
    
    fileprivate let picBtn = ImageTextButton.init(imageStr: "redPackage", title: "红包")
    fileprivate let takePhotoBtn = ImageTextButton.init(imageStr: "transfer", title: "转账")
    
    var redPackageBlock : (()->Void)?
    var transferBlock : (()->Void)?

    init() {
        super.init(frame: .zero)
        
        self.addSubview(picBtn)
        self.addSubview(takePhotoBtn)
        
        picBtn.tag = 1
        takePhotoBtn.tag = 2
        
        picBtn.addTarget(self, action: #selector(selectOperate(sender:)), for: .touchUpInside)
        takePhotoBtn.addTarget(self, action: #selector(selectOperate(sender:)), for: .touchUpInside)
        
        picBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(50)
            make.width.equalTo(50)
            make.height.equalTo(60)
        }
        
        takePhotoBtn.snp.makeConstraints { (make) in
            make.top.width.height.equalTo(picBtn)
            make.left.equalTo(picBtn.snp.right).offset(50)
        }
    }
    
    @objc fileprivate func selectOperate(sender:ImageTextButton) {
        
        if sender.tag == 1 {
            self.redPackageBlock?()
        }else{
            self.transferBlock?()
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
