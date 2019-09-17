//
//  JCConversationCell.swift
//  JChat
//
//  Created by JIGUANG on 2017/3/22.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit
import JMessage

class JCConversationCell: JCTableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _init()
    }

    private lazy var avatorView: UIImageView = {
        let avatorView = UIImageView()
        avatorView.contentMode = .scaleToFill
        return avatorView
    }()
    private lazy var statueView: UIImageView = UIImageView()
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        return titleLabel
    }()
    private lazy var msgLabel: UILabel = {
        let msgLabel = UILabel()
        msgLabel.textColor = UIColor(netHex: 0x808080)
        msgLabel.font = UIFont.systemFont(ofSize: 14)
        return msgLabel
    }()
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.textAlignment = .right
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = UIColor(netHex: 0xB3B3B3)
        return dateLabel
    }()
    private lazy var redPoin: UILabel = {
        let redPoin = UILabel(frame: CGRect(x: 65 - 17, y: 4.5, width: 20, height: 20))
        redPoin.textAlignment = .center
        redPoin.font = UIFont.systemFont(ofSize: 11)
        redPoin.textColor = .white
        redPoin.layer.backgroundColor = UIColor(netHex: 0xEB424C).cgColor
        redPoin.textAlignment = .center
        return redPoin
    }()
    
    //MARK: - public func
    open func bindConversation(_ conversation: JMSGConversation) {
        statueView.isHidden = true
        let isGroup = conversation.ex.isGroup
        if conversation.unreadCount != nil && (conversation.unreadCount?.intValue)! > 0 {
            redPoin.isHidden = false
            var text = ""
            if (conversation.unreadCount?.intValue)! > 99 {
                text = "99+"
                redPoin.layer.cornerRadius = 9.0
                redPoin.layer.masksToBounds = true
                redPoin.frame = CGRect(x: 65 - 28, y: 4.5, width: 33, height: 18)
            } else {
                redPoin.layer.cornerRadius = 10.0
                redPoin.layer.masksToBounds = true
                redPoin.frame = CGRect(x: 65 - 15, y: 4.5, width: 20, height: 20)
                text = "\(conversation.unreadCount!)"
            }
            redPoin.text = text
            
            var isNoDisturb = false
            if isGroup {
                if let group = conversation.target as? JMSGGroup {
                    isNoDisturb = group.isNoDisturb
                }
            } else {
                if let user = conversation.target as? JMSGUser {
                    isNoDisturb = user.isNoDisturb
                }
            }
            
            if isNoDisturb {
                redPoin.layer.cornerRadius = 4.0
                redPoin.layer.masksToBounds = true
                redPoin.text = ""
                redPoin.frame = CGRect(x: 65 - 5, y: 4.5, width: 8, height: 8)
            }
        } else {
            redPoin.isHidden = true
        }
        
        if let latestMessage = conversation.latestMessage {
            let time = latestMessage.timestamp.intValue / 1000
            let date = Date(timeIntervalSince1970: TimeInterval(time))
            dateLabel.text = date.conversationDate()
        } else {
            dateLabel.text = ""
        }
        
        msgLabel.text = conversation.latestMessageContentText()
        
        var lqSender = "" //红包领取者
        
        if let content = conversation.latestMessage?.content as? JMSGTextContent {
            
            let text = content.text
            let jsonData:Data = text.data(using: .utf8)!
            let dic = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
            if let dict = dic as? [String:Any] {
                if let type = dict["type"] as? String {
                    if type == "hb" {
                        msgLabel.text = "[红包]"
                        
                        if let _ = dict["msgId"] as? String {
                            
                            var text = ""
                            
                            if let hb_infor = dict["hb_infor"] as? [String:Any] {
                                
                                
                                var hb_sender = hb_infor["send_nickname"] as? String ?? ""
                                
                                var lq_sender = hb_infor["received_nickname"] as? String ?? ""
                                
                                if hb_sender == "" {
                                    hb_sender = hb_infor["send_user_id"] as? String ?? ""
                                }
                                
                                if lq_sender == "" {
                                    lq_sender = hb_infor["received_id"] as? String ?? ""
                                }
                                
                                lqSender = lq_sender
                                
                                let myNickName = JMSGUser.myInfo().nickname ?? JMSGUser.myInfo().username
                                
                                if myNickName == hb_sender {
                                    
                                    text = "\"" + lq_sender + "\"" + "领取了你的 红包"
                                    
                                }else{
                                    
                                    text = "你领取了" + "\"" + hb_sender + "\"" + "的 红包"
                                    
                                    
                                }
                                
                                if hb_sender == lq_sender {
                                    
                                    text = "你领取了自己的 红包"
                                }
                                
                                if myNickName != hb_sender && myNickName != lq_sender {
                                    
                                    text = "\"" + lq_sender + "\"" + "领取了" + "\"" + hb_sender + "\"" + "的 红包"
                                }
                                
                                msgLabel.text = text.replacingOccurrences(of: lq_sender + ":", with: "")
                                
                            }
                        }
                        
                    }else if type == "zz" {
                        msgLabel.text = "[转账]"
                    }else if type == "2" {
                        if let hb_notification = dict["hb_notification"] as? [String:Any] {
                            
                            msgLabel.text = "\"" + (hb_notification["username"] as! String) + "\"" + "获得 " + (hb_notification["money"] as! String) + " 的平台奖励"
                            lqSender = hb_notification["username"] as! String
                        }
                    }else if type == "1" {
                        msgLabel.text = "红包领取结果"
                        if let hb_notification = dict["hb_notification"] as? [String:Any] {
                            lqSender = hb_notification["username"] as! String
                        }
                        
                    }
                }
            }
            
        }
        
        
        if isGroup {
            if let latestMessage = conversation.latestMessage {
                let fromUser = latestMessage.fromUser
                if !fromUser.isEqual(to: JMSGUser.myInfo()) &&
                    latestMessage.contentType != .eventNotification &&
                    latestMessage.contentType != .prompt {
                    msgLabel.text = "\(fromUser.displayName()):\(msgLabel.text!)"
                }
                if conversation.unreadCount != nil &&
                    conversation.unreadCount!.intValue > 0 &&
                    latestMessage.contentType != .prompt {
                    if latestMessage.isAtAll() {
                        msgLabel.attributedText = getAttributString(attributString: "[@所有人]", string: msgLabel.text!)
                    } else if latestMessage.isAtMe() {
                        msgLabel.attributedText = getAttributString(attributString: "[有人@我]", string: msgLabel.text!)
                    }
                }
            }
        }
        
        if let draft = JCDraft.getDraft(conversation) {
            if !draft.isEmpty {
                msgLabel.attributedText = getAttributString(attributString: "[草稿]", string: draft)
            }
        }

        if !isGroup {
            let user = conversation.target as? JMSGUser
            
            self.titleLabel.text = user?.displayName() ?? ""
            user?.thumbAvatarData({ (data, username, error) in
                guard let imageData = data else {
                    self.avatorView.image = self.userDefaultIcon
                    return
                }
                let image = UIImage(data: imageData)
                self.avatorView.image = image
            })
            
            
            JMSGUser.userInfoArray(withUsernameArray: [(user?.username)!]) { (list, error) in

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
                            self.titleLabel.text = info.displayName()
                        })
                    }
                }
            }
            
           
        } else {
            if let group = conversation.target as? JMSGGroup {
                titleLabel.text = group.displayName()
                if group.isShieldMessage {
                    statueView.isHidden = false
                }
                group.thumbAvatarData({ (data, _, error) in
                    if let data = data {
                        self.avatorView.image = UIImage(data: data)
                    } else {
                        self.avatorView.image = self.groupDefaultIcon
                    }
                })
            }
        }

        if conversation.ex.isSticky {
            backgroundColor = UIColor(netHex: 0xF5F6F8)
        } else {
            backgroundColor = .white
        }
        
        if lqSender != "" {
           msgLabel.text = msgLabel.text?.replacingOccurrences(of: lqSender+":", with: "")
        }
        
        if conversation.latestMessage?.contentType == .eventNotification {
            
            msgLabel.text = ""
        }
        
    }
    
    func getAttributString(attributString: String, string: String) -> NSMutableAttributedString {
        let attr = NSMutableAttributedString(string: "")
        var attrSearchString: NSAttributedString!
        attrSearchString = NSAttributedString(string: attributString, attributes: convertToOptionalNSAttributedStringKeyDictionary([ convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor(netHex: 0xEB424C), convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont.boldSystemFont(ofSize: 14.0)]))
        attr.append(attrSearchString)
        attr.append(NSAttributedString(string: string))
        return attr
    }
    
    private lazy var groupDefaultIcon = UIImage.loadImage("com_icon_group_50")
    private lazy var userDefaultIcon = UIImage.loadImage("com_icon_user_50")
    
    //MARK: - private func
    private func _init() {
        avatorView.image = userDefaultIcon
        statueView.image = UIImage.loadImage("com_icon_shield")
        
        contentView.addSubview(avatorView)
        contentView.addSubview(statueView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(msgLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(redPoin)
        
        addConstraint(_JCLayoutConstraintMake(avatorView, .left, .equal, contentView, .left, 15))
        addConstraint(_JCLayoutConstraintMake(avatorView, .top, .equal, contentView, .top, 7.5))
        addConstraint(_JCLayoutConstraintMake(avatorView, .width, .equal, nil, .notAnAttribute, 50))
        addConstraint(_JCLayoutConstraintMake(avatorView, .height, .equal, nil, .notAnAttribute, 50))
        
        addConstraint(_JCLayoutConstraintMake(titleLabel, .left, .equal, avatorView, .right, 10.5))
        addConstraint(_JCLayoutConstraintMake(titleLabel, .top, .equal, contentView, .top, 10.5))
        addConstraint(_JCLayoutConstraintMake(titleLabel, .right, .equal, dateLabel, .left, -3))
        addConstraint(_JCLayoutConstraintMake(titleLabel, .height, .equal, nil, .notAnAttribute, 22.5))
        
        addConstraint(_JCLayoutConstraintMake(msgLabel, .left, .equal, titleLabel, .left))
        addConstraint(_JCLayoutConstraintMake(msgLabel, .top, .equal, titleLabel, .bottom, 1.5))
        addConstraint(_JCLayoutConstraintMake(msgLabel, .right, .equal, statueView, .left, -5))
        addConstraint(_JCLayoutConstraintMake(msgLabel, .height, .equal, nil, .notAnAttribute, 20))
        
        addConstraint(_JCLayoutConstraintMake(dateLabel, .top, .equal, contentView, .top, 16))
        addConstraint(_JCLayoutConstraintMake(dateLabel, .right, .equal, contentView, .right, -15))
        addConstraint(_JCLayoutConstraintMake(dateLabel, .height, .equal, nil, .notAnAttribute, 16.5))
        addConstraint(_JCLayoutConstraintMake(dateLabel, .width, .equal, nil, .notAnAttribute, 100))
        
        addConstraint(_JCLayoutConstraintMake(statueView, .top, .equal, dateLabel, .bottom, 7))
        addConstraint(_JCLayoutConstraintMake(statueView, .right, .equal, contentView, .right, -16))
        addConstraint(_JCLayoutConstraintMake(statueView, .height, .equal, nil, .notAnAttribute, 12))
        addConstraint(_JCLayoutConstraintMake(statueView, .width, .equal, nil, .notAnAttribute, 12))
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
