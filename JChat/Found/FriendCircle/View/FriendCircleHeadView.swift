//
//  FriendCircleHeadView.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/6/24.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class FriendCircleHeadView: UIView {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var photoBtn: UIButton!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarBtn: UIButton!
    
    @IBOutlet weak var tipLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarBtn.setBackgroundImageFor(.normal, with: URL.init(string: CacheClass.stringForEnumKey(.avatar) ?? "")!, placeholderImage: chatDefaultHead)
        
        self.nameLabel.text = CacheClass.stringForEnumKey(.nickname)
        
        if let cover = CacheClass.stringForEnumKey(.cover) {
            bannerImage.setUrlImage(with: cover, placeholder: UIImage.init(named: ""))
            
            if cover != "" {
                tipLabel.text = ""
            }
            
            
        }
        
        
        
        bannerImage.contentMode = .scaleAspectFill
        bannerImage.clipsToBounds = true
        
    }

}
