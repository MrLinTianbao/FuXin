//
//  PersonRedDetailsVC.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/7/28.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class PersonRedDetailsVC: CTViewController {

    var dataArray = [PersonRedModel]()
    
    var redId = "" //红包ID
    
    
    override func viewDidLoad() {
    
        
        self.ctNavStyle = .red
        super.viewDidLoad()
        
        self.setLocalData()
        self.setUIAppearance()
        
        
            self.getData()
            self.getTimeout()
        
    }
    
    //MARK: 获取超时时间
    fileprivate func getTimeout() {
        
        NetworkRequest.requestMethod(.get, URLString: url_systemRed, parameters: nil, success: { (value, json) in
            
            if json["status"].stringValue == "SUCCESS" {
                
                if let get_time_out = Double(json["ret_data"]["get_time_out"].stringValue) {
                    
                    let footLabel = UILabel.init(frame: .init(x: 0, y: 0, width: ScreenW, height: 60))
                    
                    footLabel.textColor = UIColor.gray
                    footLabel.font = UIFont.systemFont(ofSize: 14)
                    footLabel.textAlignment = .center
                    
                    
                    if get_time_out < 1 {
                        footLabel.text = "未领取的红包，将于\(Int(get_time_out * 60))分钟后发起退款"
                    }else{
                        footLabel.text = "未领取的红包，将于\(Int(get_time_out))小时后发起退款"
                    }
                    
                    self.tbvData.tableFooterView = footLabel
                    
                }
            }
            
        }) {
            
            
        }
    }
    
    //MARK: 获取数据
    fileprivate func getData() {
        
        
        
        NetworkRequest.requestMethod(.get, URLString: url_sendRed, parameters: ["id":redId], success: { (value, json) in
            
            
            
            self.tbvHeadView.imvHead.setUrlImage(with: json["ret_data"]["avatar"].stringValue)
            self.tbvHeadView.labTitle.text = json["ret_data"]["username"].stringValue + "的红包"
            self.tbvHeadView.labSubTitle.text = json["ret_data"]["blessing"].stringValue
            self.tbvHeadView.labMoney.text = json["ret_data"]["amount"].stringValue
            self.tbvHeadView.imvTips.image = UIImage.init(named: "没中雷-小")
            
            self.tbvHeadView.labCount.text = "1个红包共\(json["ret_data"]["amount"].stringValue)元"
            self.tbvHeadView.timeLabel.text = json["ret_data"]["addtime"].stringValue
            
            if json["status"].stringValue == "SUCCESS" {
                
                if json["ret_data"]["status"].stringValue == "1" {
                    if let dic = json["ret_data"].dictionaryObject {
                        
                        let model = PersonRedModel.setModel(with: dic)
                        self.dataArray.append(model)
                        
                        self.tbvData.reloadData()
                        
                    }
                }
            
                
            }
            
        }) {
            
            self.navigationController?.popViewController()
            
        }
        
        
    }
    
    func setLocalData(){
        
    }
    func setUIAppearance(){
        self.view.addSubview(tbvData)
        tbvData.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: **************************** 懒加载
    lazy var tbvData: UITableView = {
    
        
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.KTheme.scroll
        tableView.rowHeight = 65
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        let cell = UINib.init(nibName: "RedPackageDetailTbvCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "RedPackageDetailTbvCell")
        
        tableView.tableHeaderView = tbvHeadView
        
        return tableView
    }()
    lazy var tbvHeadView: RedDetailHeadView = {
        let tableHeadView = Bundle.main.loadNibNamed("RedDetailHeadView", owner: self, options: nil)?.last as! RedDetailHeadView
        tableHeadView.frame = CGRect(x: 0, y: 0, width: ScreenW, height: 378)
        tableHeadView.autoresizingMask = UIView.AutoresizingMask(rawValue: 0)
        
        return tableHeadView
    }()

}

extension PersonRedDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell( withIdentifier: "RedPackageDetailTbvCell", for: indexPath) as! RedPackageDetailTbvCell
        cell.selectionStyle = .none
        
        let model = dataArray[indexPath.row]
        
        cell.labName.text = model.get_username
        cell.labTime.text = (model.addtime ?? "").getTimeUint(type: .hours) + ":" + (model.addtime ?? "").getTimeUint(type: .minutes) + ":" + (model.addtime ?? "").getTimeUint(type: .seconds)
        cell.labMoney.text = model.amount
        cell.imvIcon.setUrlImage(with: model.get_avatar)
        
        cell.layoutIfNeeded()
        cell.labMoney.centerY = cell.imvState.centerY
        
        
        cell.imvState.image = UIImage.init(named: "没中雷-小")
        
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
}
