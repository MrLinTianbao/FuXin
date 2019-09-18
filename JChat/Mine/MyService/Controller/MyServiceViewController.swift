//
//  MyServiceViewController.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/7/20.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class MyServiceViewController: CTViewController {

    fileprivate let cellId = "myServiceCell"
    
    fileprivate var tableView : UITableView!
    
    fileprivate var dataArray = [MyServiceModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "客服列表"
        
        getData()
        createTableView()
        
    }
    
    
    //MARK: 创建tableView
    fileprivate func createTableView() {
    
        tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "TBCustomerServiceCell", bundle: nil), forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets.zero)
        }
        
        AlertClass.setRefresh(with: tableView, headerAction: {[weak self] in
            
            self?.getData()
            
        }, footerAction: nil)
    
    }
    
    //MARK: 获取数据
    fileprivate func getData() {
        
        MBProgressHUD_JChat.showMessage(message: "正在加载", toView: view)
        
        NetworkRequest.requestMethod(.get, URLString: url_myServiceList, parameters: nil, success: { (value, json) in
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
            
            self.tableView.mj_header.endRefreshing()
            
            if json["status"] == "SUCCESS" {
                
                self.dataArray.removeAll()
             
                if let array = json["ret_data"]["list"].arrayObject as? [[String:Any]] {
                    
                    var customServiceList = [String]()
                    
                    if let list = CacheClass.arrayForEnumKey(.customServiceList) as? [String] {
                        
                        customServiceList = list
                    }
                    
                    for item in array {
                        
                        let model = MyServiceModel.setModel(with: item)
                        self.dataArray.append(model)
                        
                        if  !customServiceList.contains(model.username ?? "") {
                            
                            customServiceList.append(model.username ?? "")
                        }
                    }
                    
                    CacheClass.setObject(customServiceList, forEnumKey: .customServiceList)
                    
                    self.showEmptyView()
                    self.tableView.reloadData()
                    
                    
                }
                
//                if self.dataArray.count == 0 {
//                    self.showEmptyView(view: self.tableView, emptyStyle: .emptyViewNoData)
//                }
                
            }
            
        }) {
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
            self.tableView.mj_header.endRefreshing()
            
        }
    }
    func showEmptyView(){
        if(self.dataArray.count>0){
            self.hideEmptyView(view: tableView)
        }else{
            self.showEmptyView(view: tableView, emptyStyle: .emptyViewNoData)
        }
    }
    @objc fileprivate func toChatAction(sender:UIButton) {
        
        //跳转到聊天页面
        JMSGConversation.createSingleConversation(withUsername: dataArray[sender.tag].username ?? "", appKey: "b940e15cdad7707d4d0172c9") { (result, error) in
            if error == nil {
                let conv = result as! JMSGConversation
                let vc = JCChatViewController(conversation: conv)
                vc.chatForCustomService = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateConversation), object: nil, userInfo: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    
}

extension MyServiceViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? TBCustomerServiceCell
        cell?.selectionStyle = .none
        cell?.model = dataArray[indexPath.row]
        cell?.addBtn.tag = indexPath.row
        cell?.addBtn.addTarget(self, action: #selector(toChatAction(sender:)), for: .touchUpInside)
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
    }
}
