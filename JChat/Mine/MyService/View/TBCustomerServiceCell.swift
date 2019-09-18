//
//  MyCustomerServiceCell.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/7/20.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class TBCustomerServiceCell: UITableViewCell {

    @IBOutlet weak var avatorImage: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var addBtn: UIButton!
    
    var model : MyServiceModel! {
        didSet{
            updateData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    fileprivate func updateData() {
        
        self.avatorImage.setUrlImage(with: model.avatar, placeholder: chatDefaultHead)
        self.nameLabel.text = model.nickname ?? model.username
        
//        if model.is_friend == "1" {
//
//            self.addBtn.setTitle("已添加", for: .normal)
//            self.addBtn.textColor = "shallowGray"
//
//        }else{
//
//            self.addBtn.setTitle("添加求助", for: .normal)
//            self.addBtn.textColor = "deepOrange"
//        }
        
    }
    
}
