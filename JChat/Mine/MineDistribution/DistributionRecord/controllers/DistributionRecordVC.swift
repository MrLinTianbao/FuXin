//
//  ViewController.swift
//  XLCustomer
//
//  Created by longma on 2018/10/16.
//  Copyright © 2018年 XLH. All rights reserved.
//

import UIKit

class DistributionRecordVC: CTViewController {
    
    var page = 1 //页
    
    var dataArray = [InvitedRecordModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        self.setLocalData()
        self.setUIAppearance()
    }
    
    func setLocalData(){
        
    }
    func setUIAppearance(){
        self.title = "邀请记录"
        self.view.addSubview(tbvData)
        tbvData.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        
        AlertClass.setRefresh(with: tbvData, headerAction: {[weak self] in
            
            
            self?.page = 1
            self?.getData()
            
            
            
        }) {[weak self] in
            
            
            
            self?.getData()
            
        }
        
        
    }
    
    func getData() {
        
        NetworkRequest.requestMethod(.get, URLString: url_invitationRecord, parameters: ["page":"\(self.page)","pageSize":"10"], success: { (value, json) in
            
            self.tbvData.mj_header.endRefreshing()
            self.tbvData.mj_footer.endRefreshing()
            
            if json["status"].stringValue == "SUCCESS" {
                
                if let array = json["ret_data"]["list"].arrayObject as? [[String:Any]] {
                    
                    if self.page == 1 {
                        self.dataArray.removeAll()
                    }
                    
                    
                    for item in array {
                        let model = InvitedRecordModel.setModel(with: item)
                        self.dataArray.append(model)
                    }
                    
                    if self.dataArray.count > 0 {
                        self.page += 1
                    }
                    self.showEmptyView()
                    self.tbvData.reloadData()
                }
            }
            
        }) {
            self.tbvData.mj_header.endRefreshing()
            self.tbvData.mj_footer.endRefreshing()
        }
    }
    func showEmptyView(){
        if(self.dataArray.count>0){
            self.hideEmptyView(view: tbvData)
        }else{
            self.showEmptyView(view: tbvData, emptyStyle: .emptyViewNoData)
        }
    }

    //MARK: **************************** 懒加载
    lazy var tbvData: UITableView = {
        
        let tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.KTheme.scroll
        tableView.rowHeight = 52
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)

        let cell = UINib.init(nibName: "DistributionRecordTbvCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "DistributionRecordTbvCell")
        

        return tableView
    }()
    
   
}
extension DistributionRecordVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let array = dataArray[section]
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell( withIdentifier: "DistributionRecordTbvCell", for: indexPath) as! DistributionRecordTbvCell
        cell.model = dataArray[indexPath.row]

        return cell
    }
    /*分区头部部高度*/
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHead = UIView.init()
        sectionHead.backgroundColor = tableView.backgroundColor
        return sectionHead
    }
    /*分区尾部高度*/
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)


    }
    
}
