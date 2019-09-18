//
//  DayGrandViewController.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/6/23.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit
//每日战报
class DayGrandViewController: CTViewController {
    var dateTimeArray = [String]()
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
            vc.start = dayStr
            vc.end = dayStr
            self?.navigationController?.pushViewController(vc)
        }

//        getAllDaysWithMonth()
        requestAllDaysWithMonth()

    }
    func requestAllDaysWithMonth() {
        AlertClass.show()
        NetworkRequest.requestMethod(.get, URLString: url_dateList, parameters: ["type":"day"], success: { (value, json) in
            AlertClass.stop()

            if json["status"].stringValue == "SUCCESS" {

                if let array = json["ret_data"].arrayObject as? [String] {
                    var dateTieleArray = [String]()
                    self.dateTimeArray = array
                    for title in array{
                        dateTieleArray.append(title + "日战报详情")
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
    
    func getAllDaysWithMonth() {
        
//        let dayCount = getInMonthNumberOfDays() //一个月的总天数
        let dayCount = Int(getCurrentTime().getTimeUint(type: .day) ) ?? 0
        var dateTieleArray = [String]()

        let formatter = DateFormatter()
        let currentDate = Date()
        formatter.dateFormat = "yyyy-MM"
        let str = formatter.string(from: currentDate)
        formatter.dateFormat = "yyyy-MM-dd"
        for i in 1...dayCount {
            let sr = String(format: "%@-%02d", str, i)
            
            dateTimeArray.append(sr)
            dateTieleArray.append(sr + "日战报详情")
        }
        
        listView?.dataArray = dateTieleArray
        listView?.tableView.reloadData()
        print("=================   \(dateTimeArray)")

        
    }
  
    func getInMonthNumberOfDays() -> Int {
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        let range = calendar.range(of: .day, in: .month, for: currentDate)
        return range?.count ?? 0
    }
    

}
