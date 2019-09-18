//
//  NoticeDetailsViewController.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/6/23.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class NoticeDetailsViewController: CTViewController {
    var start:String?
    var end:String?
    var isWeek:Bool = false
    fileprivate let titleLabel = UILabel()
    
    fileprivate let selectVC = SelectViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "公告详情"
        addSubView()
    }

    //MARK: 添加子视图
    fileprivate func addSubView() {
        let time = (start ?? "") + " 00:00:00"
        self.view.backgroundColor = UIColor.KTheme.notice
        let year = time.getTimeUint(type: .year)
        let month = time.getTimeUint(type: .month)
        let day = time.getTimeUint(type: .day)
        
        if isWeek {
            let title = start! + "日至" + end! +  "日战报详情"
            titleLabel.text = title
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        }else{
            let title = "\(year)年\(month)月\(day)日战报详情"
            titleLabel.text = title
            titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        }
        
       
        self.view.addSubview(titleLabel)
        
        selectVC.titles = ["发包最多","点包最多"]
        let vc1 = SendPackageViewController()
         vc1.start = start! + " 00:00:00"
         vc1.end = end! + " 23:59:59"
         let vc2 = TouchPackageViewController()
        vc2.start = start! + " 00:00:00"
        vc2.end = end! + " 23:59:59"
        selectVC.controllers = [vc1,vc2]
        self.addChild(selectVC)
        self.view.addSubview(selectVC.view)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(10)
            make.height.greaterThanOrEqualTo(10)
        }
        
        selectVC.view.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        
    }
    

}
