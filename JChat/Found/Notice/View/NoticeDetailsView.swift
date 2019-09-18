//
//  NoticeDetailsView.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/6/23.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class NoticeDetailsView: UIView {
    var start:String?
    var end:String?
    fileprivate let cellId = "noticeDetailsCell"
    
    fileprivate var notDataView : UIImageView!
    
    var tableView : UITableView!
    var currentVC : CTViewController?

     var dataArray = [RedReportModel]()
    
    fileprivate var page = 1
    
     var urlStr = url_RedThunder

    init(start:String?,end:String?,urlStr:String,currentVC:CTViewController) {
        super.init(frame: .zero)
        self.currentVC = currentVC
        self.start = start
        self.end = end
        self.urlStr = urlStr
        self.backgroundColor = UIColor.KTheme.notice
        
        let headView = Bundle.main.loadNibNamed("NoticeDetailsHeadView", owner: self, options: nil)?.last as? NoticeDetailsHeadView
        headView?.frame = .init(x: 0, y: 0, width: ScreenW, height: 50)
        self.addSubview(headView!)
        
        tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(UINib.init(nibName: "NoticeDetailsCellTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        self.addSubview(tableView)
        
        notDataView = UIImageView.init(frame: .init(x: ScreenW/4, y: ScreenH/4, width: ScreenW/2, height: ScreenH/2))
        notDataView.backgroundColor = UIColor.white
        notDataView.image = UIImage.init(named: "notData")
        notDataView.contentMode = .scaleAspectFit
        notDataView.isHidden = true
        tableView.addSubview(notDataView)
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(headView!.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        AlertClass.setRefresh(with: tableView, headerAction: {[weak self] in

            self?.page = 1
            self?.getData(url: self?.urlStr ?? "")

        }) {[weak self] in

            self?.getData(url: self?.urlStr ?? "")
        }

        tableView.mj_header.beginRefreshing()
    }
    
    //MARK: 获取数据
    public func getData(url:String) {
        
        urlStr = url
        
        let parm = [
            "page":"\(page)",
            "pageSize":"20",
            "start":start ?? "".urlEncoded,
            "end":end ?? "".urlEncoded
        ]
//        AlertClass.show()
        NetworkRequest.requestMethod(.get, URLString: urlStr, parameters: parm, success: { (value, json) in
//            AlertClass.stop()
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            if json["status"].stringValue == "SUCCESS" {
                
                if self.page == 1 {
                    self.dataArray.removeAll()
                }
                
                if let array = json["ret_data"]["list"].arrayObject as? [[String:Any]] {
                    if self.page == 1 {
                        self.dataArray.removeAll()
                    }
                    for item in array {
                        let model = RedReportModel.setModel(with: item)
                        self.dataArray.append(model)
                    }
                    
                    if self.dataArray.count > 0 {
                        self.page += 1
                    }
                    self.showEmptyView()
                    
                    self.tableView.reloadData()
                }
            }
            
        }) {
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
        }
        
        
        
    }
    func showEmptyView(){
        if(self.dataArray.count>0){
            currentVC?.hideEmptyView(view: tableView)
        }else{
            currentVC?.showEmptyView(view: tableView, emptyStyle: .emptyViewNoData)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NoticeDetailsView : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? NoticeDetailsCellTableViewCell
        let model = dataArray[indexPath.row]

        cell?.selectionStyle = .none
        cell?.numberLabel.text = "\(indexPath.row+1)"
        cell?.nameLabel.text = model.username
            cell?.idLabel.text = model.mid
            cell?.amountLabel.text = model.amount
            cell?.packageLabel.text = model.num
        
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
}
