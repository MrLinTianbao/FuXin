//
//  ListView.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/5/20.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class ListView: UIView {

    fileprivate let cellId = "listCell"
    
    fileprivate var notDataView : UIImageView!
    
    var tableView : UITableView!
    
    var dataArray = [String]()
    
    fileprivate var page = 1
    
    fileprivate var urlStr = url_notice
    
    var selectBlock : ((_ indexPath: IndexPath) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubView()
        
//        AlertClass.setRefresh(with: tableView, headerAction: {[weak self] in
//
//            self?.page = 1
//            self?.getData(url: self?.urlStr ?? "")
//
//        }) {[weak self] in
//
//            self?.getData(url: self?.urlStr ?? "")
//        }
//        
//        tableView.mj_header.beginRefreshing()
    }
    
    //MARK: 添加子视图
    fileprivate func addSubView() {
        
        self.backgroundColor = UIColor.KTheme.notice
        
        tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(UINib.init(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: cellId)
        self.addSubview(tableView)
        
        notDataView = UIImageView.init(frame: .init(x: ScreenW/4, y: ScreenH/4, width: ScreenW/2, height: ScreenH/2))
        notDataView.backgroundColor = UIColor.white
        notDataView.image = UIImage.init(named: "notData")
        notDataView.contentMode = .scaleAspectFit
        notDataView.isHidden = true
        tableView.addSubview(notDataView)
        
        tableView.mas_makeConstraints { (make) in
            make?.top.equalTo()(self)?.offset()(10)
            make?.left.right()?.bottom()?.equalTo()(self)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: 获取数据
    public func getData(url:String) {

        urlStr = url
        
        NetworkRequest.requestMethod(.get, URLString: urlStr, parameters: ["ids":"1"], success: { (value, json) in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            if json["status"].stringValue == "SUCCESS" {
                
                if self.page == 1 {
                    self.dataArray.removeAll()
                }
                
                if let array = json["ret_data"].arrayObject as? [[String:Any]] {
                    
                    for item in array {
                        let model = MessageModel.setModel(with: item)
//                        self.dataArray.append(model)
                    }
                    
                    self.page += 1
                    
                    self.tableView.reloadData()
                }
            }
            
        }) {
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
        }

    }
    

}

extension ListView : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataArray.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? ListCell
        
//        cell?.model = dataArray[indexPath.row]
        cell?.titleLabel.text = dataArray[indexPath.row]
        cell?.titleLabel.adjustsFontSizeToFitWidth = true
        

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectBlock?(indexPath)
    }
}
