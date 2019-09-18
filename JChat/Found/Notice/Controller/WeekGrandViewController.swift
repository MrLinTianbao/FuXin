//
//  WeekGrandViewController.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/6/23.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class WeekGrandViewController: CTViewController {
    var dateTimeArray = [[String:String]]()
    var listView:ListView?

    override func viewDidLoad() {
        super.viewDidLoad()

         listView = ListView.init(frame: .zero)
        self.view.addSubview(listView!)
        self.view.backgroundColor = UIColor.KTheme.notice
        
        listView?.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets.zero)
        }
        listView?.selectBlock = {[weak self] (index) in
            let dayStr = self?.dateTimeArray[index.row]
            let vc = NoticeDetailsViewController()
            vc.isWeek = true
            vc.start = dayStr!["start"]
            vc.end = dayStr!["end"]
            self?.navigationController?.pushViewController(vc)
        }
        
        
//        if let list = MJOCManager.mj_currentWeekTimes() {
//
//            var dateTieleArray = [String]()
//            let week = ["星期一","星期二","星期三","星期四","星期五","星期六","星期日"]
//            for i in 0..<list.count {
//
//                if let sr = list[i] as? String {
//                    dateTimeArray.append(sr)
//                    dateTieleArray.append(week[i] + "战报详情")
//                    print("=================   \(list[i])")
//                }
//            }
//
//            listView?.dataArray = dateTieleArray
//            listView?.tableView.reloadData()
//        }
        
        requestAllDaysWithMonth()
    }
    
    func requestAllDaysWithMonth() {
        AlertClass.show()
        NetworkRequest.requestMethod(.get, URLString: url_dateList, parameters: ["type":"week"], success: { (value, json) in
            AlertClass.stop()
            
            if json["status"].stringValue == "SUCCESS" {
                
                if let array = json["ret_data"].arrayObject as? [[String:String]] {
                    var dateTieleArray = [String]()
                    self.dateTimeArray = array
                    for dic in array{
                        dateTieleArray.append(dic["start"]! + "日至" + dic["end"]! +  "日战报详情")
                        self.listView?.dataArray = dateTieleArray
                        self.listView?.tableView.reloadData()
                    }
                }
            }else{
                AlertClass.showErrorToat(withJson: json)
            }
            
        }) {
            
        }
    }
    


}
