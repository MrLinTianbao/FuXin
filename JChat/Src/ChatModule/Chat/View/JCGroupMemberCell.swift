//
//  JCGroupMemberCell.swift
//  JChat
//
//  Created by JIGUANG on 2017/5/10.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit
import JMessage

class JCGroupMemberCell: UICollectionViewCell {
    var group: JMSGGroup!
    var avator: UIImage? {
        get {
            return avatorView.image
        }
        set {
            nickname.text = ""
            avatorView.image = newValue
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    private var avatorView: UIImageView = UIImageView()
    private var nickname: UILabel = UILabel()
    private lazy var userDefaultIcon = UIImage.loadImage("com_icon_user_50")
    
    private func _init() {
        
        nickname.font = UIFont.systemFont(ofSize: 12)
        nickname.textAlignment = .center
        
        addSubview(avatorView)
        addSubview(nickname)
        
        addConstraint(_JCLayoutConstraintMake(avatorView, .centerY, .equal, contentView, .centerY, -10))
        addConstraint(_JCLayoutConstraintMake(avatorView, .width, .equal, nil, .notAnAttribute, 50))
        addConstraint(_JCLayoutConstraintMake(avatorView, .height, .equal, nil, .notAnAttribute, 50))
        addConstraint(_JCLayoutConstraintMake(avatorView, .centerX, .equal, contentView, .centerX))
        
        addConstraint(_JCLayoutConstraintMake(nickname, .centerX, .equal, contentView, .centerX))
        addConstraint(_JCLayoutConstraintMake(nickname, .width, .equal, nil, .notAnAttribute, 50))
        addConstraint(_JCLayoutConstraintMake(nickname, .height, .equal, nil, .notAnAttribute, 15))
        addConstraint(_JCLayoutConstraintMake(nickname, .top, .equal, avatorView, .bottom, 5))
        
    }
    
    func bindDate(user: JMSGUser) {
        nickname.text = user.displayName()
        user.thumbAvatarData { (data, id, error) in
            if let data = data {
                let image = UIImage(data: data)
                self.avatorView.image = image
            } else {
                self.avatorView.image = self.userDefaultIcon
            }
        }
        
        //mj819
        JMSGUser.userInfoArray(withUsernameArray: [user.username]) { (list, error) in
            
            if let array = list as? [JMSGUser] {
                if array.count > 0 {
                    let info = array[0]
                    info.thumbAvatarData({ (data, username, error) in
                        guard let imageData = data else {
                            self.avatorView.image = self.userDefaultIcon
                            return
                        }
                        let image = UIImage(data: imageData)
                        self.avatorView.image = image
                        //mj群昵称
                        if let groupNickname = self.group?.memberInfo(withUsername: user.username, appkey: user.appKey)?.groupNickname {
                            self.nickname.text = groupNickname
                        }else{
                            self.nickname.text = info.displayName()
                        }
                        
                    })
                }
            }
        }
        
        
        
    }
    
}
