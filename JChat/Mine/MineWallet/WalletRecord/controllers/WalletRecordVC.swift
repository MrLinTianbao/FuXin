//
//  ViewController.swift
//  XLCustomer
//
//  Created by longma on 2018/10/16.
//  Copyright © 2018年 XLH. All rights reserved.
//

import UIKit

class WalletRecordVC: CTViewController {
    
    
    var dataArray = [WalletRecordModel]()
    
    var page = 1 //页
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        self.setLocalData()
        self.setUIAppearance()
    }
    
    func setLocalData(){
        
    }
    func setUIAppearance(){
        self.title = "交易记录"
        self.view.addSubview(tbvData)
        tbvData.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets.zero)
        }
        
        AlertClass.setRefresh(with: tbvData, headerAction: {[weak self] in
            
           
                self?.page = 1
                self?.getData()
        
            
            
        }) {[weak self] in
            
            
                
                self?.getData()
            
        }
        
    }
    
    //MARK: **************************** 懒加载
    lazy var tbvData: UITableView = {
        
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.KTheme.scroll
        tableView.rowHeight = 63
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        tableView.separatorColor = UIColor.KTheme.line
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        let cell = UINib.init(nibName: "WalletRecordTbvCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "WalletRecordTbvCell")
        

        return tableView
    }()
    
    //MARK: 获取数据
    fileprivate func getData() {
        
        NetworkRequest.requestMethod(.get, URLString: url_billDetails, parameters: ["page":"\(page)","pageSize":"10"], success: { (value, json) in
            
            self.tbvData.mj_header.endRefreshing()
            self.tbvData.mj_footer.endRefreshing()
            
            if json["status"].stringValue == "SUCCESS" {
                
                if let array = json["ret_data"]["list"].arrayObject as? [[String:Any]] {
                    
                    if self.page == 1 {
                        self.dataArray.removeAll()
                    }
                    
                    
                    for item in array {
                        let model = WalletRecordModel.setModel(with: item)
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

   
}
extension WalletRecordVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell( withIdentifier: "WalletRecordTbvCell", for: indexPath) as! WalletRecordTbvCell
        cell.model = dataArray[indexPath.row]
        cell.selectionStyle = .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)


    }
    
}
