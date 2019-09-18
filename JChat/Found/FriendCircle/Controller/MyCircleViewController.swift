//
//  MyCircleViewController.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/6/26.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class MyCircleViewController: CTViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let textCell = "textCell"
    fileprivate let imageCell = "imageCell"
    
    fileprivate var dataArray = [FriendCircleModel]()
    
    var user = JMSGUser.myInfo()
    
    fileprivate var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user == JMSGUser.myInfo() {
            self.title = "我的朋友圈"
        }else{
            self.title = (user.nickname ?? user.username) + "的朋友圈"
        }
        
        getData()
        
        
        self.navigationController?.navigationBar.isHidden = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "MyCircleTextCell", bundle: nil), forCellReuseIdentifier: textCell)
        tableView.register(UINib.init(nibName: "MyCircleImageCell", bundle: nil), forCellReuseIdentifier: imageCell)
        
        AlertClass.setRefresh(with: tableView, headerAction: {[weak self] in
            
            self?.page = 1
            self?.getData()
            
        }) {[weak self] in
            
            self?.getData()
        }
        
    }
    
    //MARK: 获取内容
    fileprivate func getData() {
        
        NetworkRequest.requestMethod(.get, URLString: url_friendCircle, parameters: ["username":user.username,"page":"\(self.page)","pageSize":"10"], success: { (value, json) in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            
            if json["status"].stringValue == "SUCCESS" {
                
                if let array = json["ret_data"]["list"].arrayObject as? [[String:Any]] {
                    
                    if self.page == 1 {
                        self.dataArray.removeAll()
                    }
                    
                    for item in array {
                        let model = FriendCircleModel.setModel(with: item)
                        self.dataArray.append(model)
                    }
                    
                    if array.count > 0 {
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
            self.hideEmptyView(view: tableView)
        }else{
            self.showEmptyView(view: tableView, emptyStyle: .emptyViewNoData)
        }
    }
    

}

extension MyCircleViewController : UITableViewDelegate,UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let model = dataArray[indexPath.row]
        
        var height = model.contents?.size(font: 12, width: ScreenW-102).height ?? 0
        
        if height > 50 {
            height = 50
        }
        
        if let _ = model.images as? [String]  {
            return 84
        }else{
            
            return height + 34
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = dataArray[indexPath.row]
        
        if let images = model.images as? [String] {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: imageCell, for: indexPath) as? MyCircleImageCell
            cell?.titleLabel.text = model.contents
            cell?.circleImageView.setUrlImage(with: images.first, placeholder: UIImage.init(named: ""))
            cell?.monthLabel.text = "\(Int((model.addtime?.getTimeUint(type: .month))!) ?? 0)" + "月"
            cell?.dayLabel.text = model.addtime?.getTimeUint(type: .day)
            return cell!
            
            
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: textCell, for: indexPath) as? MyCircleTextCell
            cell?.titleLabel.text = model.contents
            
            cell?.monthLabel.text = "\(Int((model.addtime?.getTimeUint(type: .month))!) ?? 0)" + "月"
            cell?.dayLabel.text = model.addtime?.getTimeUint(type: .day)
            
            var height = model.contents?.size(font: 12, width: ScreenW-92).height ?? 0
            
            if height > 50 {
                height = 50
            }
            
            cell?.bgView.snp.remakeConstraints({ (make) in
                make.top.equalTo((cell?.dayLabel)!)
                make.left.equalTo((cell?.monthLabel.snp.right)!).offset(5)
                make.right.equalToSuperview().offset(-16)
                make.height.equalTo(height+10)
            })
            
            return cell!
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = CircleDetailViewController()
        vc.model = dataArray[indexPath.row]
        self.navigationController?.pushViewController(vc)
    }
}
