//
//  JCTransferContentView.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/7/24.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class JCTransferContentView: UIView,JCMessageContentViewType {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    open func apply(_ message: JCMessageType) {
        guard let content = message.content as? JCTransferContent else {
            return
        }
        
        _message = message
        _delegate = content.delegate
        _userName = content.userName
        _appKey = content.appKey
        _redUid = content.redUid
        _sendUid = content.sendUid
        _status = content.status
        _nickname = content.nickName
        _blessing = content.blessing
        _sendTime = content.sendTime
        
        noteText = content.noteText
        amount = content.amount
        count = content.count
        
        if _blessing == "" {
            _blessing = "恭喜发财，大吉大利"
        }
        
        if _message.options.alignment == .left {
            
            arrowImage.frame = CGRect(x: -12, y: 10, width: 22, height: 22)
            
            let color = _status == 0 ? UIColor.setRGB(0xECA052) : UIColor.setRGB(0xF7E2C5)
            
            
            arrowImage.image = UIImage.init(named: "left_arrow")?.mj_imageChangeColor(color)
        }else if _message.options.alignment == .right {
            
            arrowImage.frame = CGRect(x: 190, y: 10, width: 22, height: 22)
            
            let color = _status == 0 ? UIColor.setRGB(0xECA052) : UIColor.setRGB(0xF7E2C5)
            
            
            arrowImage.image = UIImage.init(named: "right_arrow")?.mj_imageChangeColor(color)
            
        }
        
        titleLabel.text = "¥ " + amount!
        
        if _status == 0 {
            
            imageView.image = UIImage.init(named: "transfer_ws")
            bgView.backgroundColor = UIColor.setRGB(0xECA052)
            statusLabel.text = "转账"
        }else{
            
            imageView.image = UIImage.init(named: "transfer_ys")
            bgView.backgroundColor = UIColor.setRGB(0xF7E2C5)
            statusLabel.text = "已领取"
        }
        
        
        
    }
    
    
    private weak var _delegate: JCMessageDelegate?
    
    private var noteText : String?
    private var amount : String?
    private var count : String?
    private var _userName: String?
    private var _appKey: String?
    private var _nickname: String?
    private var _redUid : String?
    private var _sendUid : String?
    private var _message: JCMessageType!
    private var _user: JMSGUser?
    private var _status = 0
    private var _blessing : String?
    private var _sendTime : String?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 12, y: 13.5, width: 34, height: 40))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var arrowImage: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 190, y: 10, width: 20, height: 20))
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 55, y: 13.5, width: 140, height: 25)
        titleLabel.font = UIFont.systemFont(ofSize: 22)
        titleLabel.textColor = UIColor.white
        return titleLabel
    }()
    
    private lazy var statusLabel: UILabel = {
        let tipsLabel = UILabel()
        tipsLabel.frame = CGRect(x: 55, y: 38.5, width: 140, height: 15)
        tipsLabel.font = UIFont.systemFont(ofSize: 12)
        tipsLabel.textColor = UIColor.white
        return tipsLabel
    }()
    
    private lazy var bgView: UIImageView = {
        let bgView = UIImageView()
        bgView.frame = CGRect(x: 0, y: 0, width: 200, height: 67)
        bgView.backgroundColor = UIColor.init(red: 237/255.0, green: 161/255.0, blue: 80/255.0, alpha: 1)
        return bgView
    }()
    
    
    
    
    private lazy var tipsLabel: UILabel = {
        let tipsLabel = UILabel()
        tipsLabel.backgroundColor = UIColor.white
        tipsLabel.frame = CGRect(x: 0, y: 67, width: 200, height: 20)
        tipsLabel.font = UIFont.systemFont(ofSize: 10)
        tipsLabel.textColor = UIColor(netHex: 0x989898)
        tipsLabel.text = "  富信转账"
        return tipsLabel
    }()
    
    private func _commonInit() {
        _tapGesture()
        
        addSubview(bgView)
        addSubview(imageView)
        addSubview(arrowImage)
        
        addSubview(titleLabel)
        addSubview(tipsLabel)
        addSubview(statusLabel)
        
    }
    
    func _tapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(_clickCell))
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)
    }
    
    @objc func _clickCell() {
        
        
        let jsonText = _message.jmessage?.content as? JMSGTextContent
        
        _delegate?.message!(message: _message, text: jsonText?.text ?? "")
    }

}
