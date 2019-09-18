//
//  GroupNoticeView.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/7/30.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class GroupNoticeView: UIView {
    
    fileprivate var noticeImage : UIImageView!
    fileprivate var noticeView : UIView!
    fileprivate let noticeLabel = UILabel()
//    fileprivate let noticeLabel2 = UILabel()
    
    var title : String! {
        didSet{
            updateFrame()
        }
    }
    
    var timer : Timer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.KTheme.deepOrange
        
        noticeImage = UIImageView.init(frame: .init(x: 16, y: 5, width: 20, height: 20))
        noticeImage.image = UIImage.init(named: "advertising")
        self.addSubview(noticeImage)
        
        noticeView = UIView.init(frame: .init(x: 40, y: 5, width: ScreenW-40, height: 20))
        noticeView.clipsToBounds = true
        self.addSubview(noticeView)
    
        noticeLabel.textColor = UIColor.white
        noticeLabel.font = UIFont.systemFont(ofSize: 14)
        noticeView.addSubview(noticeLabel)
        
//        noticeLabel2.textColor = UIColor.white
//        noticeLabel2.font = UIFont.systemFont(ofSize: 12)
//        noticeView.addSubview(noticeLabel2)
        
        
        
        
    }
    
    //MARK: 更新坐标
    fileprivate func updateFrame() {
        
        let width = title.size(font: 14, height: 20).width
        
        noticeLabel.text = title
//        noticeLabel2.text = title
        
        noticeLabel.frame = .init(x: ScreenW-40, y: 0, width: width, height: 20)
//        noticeLabel2.frame = .init(x: ScreenW, y: noticeLabel.frame.maxY + 100, width: width, height: 17)
        
        addAnimate()
    }
    
    //MARK: 添加动画
    fileprivate func addAnimate() {
        
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.beginAnimation(sender:)), userInfo: nil, repeats: true)
        //添加至子线程
        RunLoop.main.add(self.timer, forMode: .common)
        
        
    }
    
    //MARK: 开始动画
    @objc fileprivate func beginAnimation(sender:Timer) {
        
//        let width = title.size(font: 12, height: 17).width < (ScreenW-40) ? (ScreenW-40) : title.size(font: 12, height: 17).width
        
        self.noticeLabel.frame.origin.x -= ScreenW/500
//        self.noticeLabel2.frame.origin.x -= ScreenW/500
        
        if self.noticeLabel.frame.maxX <= 0 {
            self.noticeLabel.frame.origin.x = ScreenW-40
        }
        
//        if self.noticeLabel2.frame.maxX <= 0 {
//            self.noticeLabel2.frame.origin.x = width + 40
//        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
