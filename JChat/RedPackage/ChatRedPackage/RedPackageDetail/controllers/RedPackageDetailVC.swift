//
//  ViewController.swift
//  XLCustomer
//
//  Created by longma on 2018/10/16.
//  Copyright © 2018年 XLH. All rights reserved.
//

import UIKit

class RedPackageDetailVC: CTViewController {
    
    
    var dataArray = [RayRedModel]()
    
    var username = "" //发送包用户
    
    var group_id = "" //群id
    var redId = "" //红包ID
    
    var isEnd = false //是否领完
    
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
        
        
        NetworkRequest.requestMethod(.get, URLString: url_sendRayRed, parameters: ["id":redId,"group_id":group_id], success: { (value, json) in
            
            
            self.tbvHeadView.imvHead.setUrlImage(with: json["ret_data"]["avatar"].stringValue)
            self.tbvHeadView.labTitle.text = json["ret_data"]["username"].stringValue + "的红包"
            self.tbvHeadView.timeLabel.text = json["ret_data"]["addtime"].stringValue
            
            self.username = self.tbvHeadView.labTitle.text ?? ""
            self.tbvHeadView.labSubTitle.text = json["ret_data"]["blessing"].stringValue
            self.tbvHeadView.labMoney.text = ""//json["ret_data"]["payment_amount"].stringValue
            self.username = json["ret_data"]["username"].stringValue
            self.tbvHeadView.imvTips.image = UIImage.init(named: "没中雷-小")
            self.isEnd = json["ret_data"]["is_end"].boolValue
            
            if json["status"].stringValue == "SUCCESS" {
                
                if let array = json["ret_data"]["items"].arrayObject as? [[String:Any]] {
                    
                    var redSum:Double = 0
                    
                    for item in array {
                        let model = RayRedModel.setModel(with: item)
                        self.dataArray.append(model)
                        
                        redSum += Double(model.amount ?? "0")!
                    }
                    
                    let sum = String(format: "%.2f", redSum)
                    
//                    已领取4/7个，共29.83/50.00元
                    
                    self.tbvHeadView.labCount.text = "已领取\(self.dataArray.count)/\(json["ret_data"]["type"].stringValue == "0" ? 7 : 9)个，共\(sum)/\(json["ret_data"]["payment_amount"].stringValue)元"
                    
                    self.tbvData.reloadData()
                    
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
extension RedPackageDetailVC: UITableViewDelegate, UITableViewDataSource {
    
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
        
        cell.labName.text = model.username
        cell.labTime.text = (model.addtime ?? "").getTimeUint(type: .hours) + ":" + (model.addtime ?? "").getTimeUint(type: .minutes) + ":" + (model.addtime ?? "").getTimeUint(type: .seconds)
        cell.labMoney.text = model.amount
        cell.imvIcon.setUrlImage(with: model.avatar)
        
        cell.layoutIfNeeded()
        
        if model.is_hit == "1" && self.isEnd {
            cell.imvState.image = UIImage.init(named: "中雷")
            cell.labTips.text = ""//"已从余额扣除\(model.indemnity ?? "0")元给\(self.username)"
            
//            cell.labMoney.frame.origin.y = cell.imvState.frame.origin.y
            
            
        }else{
            cell.imvState.image = UIImage.init(named: "没中雷-小")
            cell.labTips.text = ""
            
            
            
        }
        
        cell.labMoney.centerY = cell.imvState.centerY
        
        if let nickName = CacheClass.stringForEnumKey(.nickname) {
            if nickName == model.username {
                self.tbvHeadView.imvTips.image = cell.imvState.image
                self.tbvHeadView.labMoney.text = model.amount
            }
        }
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)


    }
    
}
