//
//  SendPackageViewController.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/6/23.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class SendPackageViewController: CTViewController {

    var start:String?
    var end:String?

    override func viewDidLoad() {
        super.viewDidLoad()

        let listView = NoticeDetailsView.init(start: start, end: end ,urlStr : url_RedThunder, currentVC:self)
        self.view.addSubview(listView)
        self.view.backgroundColor = UIColor.KTheme.notice
        
        listView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets.zero)
        }
        
        
    }
    

    

}
