//
//  ViewController.swift
//  XLCustomer
//
//  Created by longma on 2018/10/16.
//  Copyright © 2018年 XLH. All rights reserved.
//

import UIKit

class BlacklistVC: CTViewController {
    var dataArray = [JMSGUser]()
    
    fileprivate var notDataView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setLocalData()
        self.setUIAppearance()
    }
    
    func setLocalData(){
        
    }
    func setUIAppearance(){
        self.title = "黑名单"
        self.view.addSubview(tbvData)
        
//        notDataView = UIImageView.init(frame: .init(x: ScreenW/4, y: ScreenH/4, width: ScreenW/2, height: ScreenH/2))
//        notDataView.backgroundColor = UIColor.white
//        notDataView.image = UIImage.init(named: "notData")
//        notDataView.isHidden = true
//        notDataView.contentMode = .scaleAspectFit
//        tbvData.addSubview(notDataView)
        
        tbvData.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        
        JMessage.blackList { (array, error) in
            
            self.dataArray = array as? [JMSGUser] ?? [JMSGUser]()
            
            //主线程刷新UI
            DispatchQueue.main.async(execute: {
                if self.dataArray.count == 0 {
//                    self.notDataView.isHidden = false
                    self.tbvData.backgroundColor = UIColor.white
                    
                }else{
//                    self.notDataView.isHidden = true
                    self.tbvData.backgroundColor = UIColor.KTheme.lightGray
                }
                self.tbvData.reloadData()
            })
            self.showEmptyView()

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
        
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.KTheme.scroll
        tableView.rowHeight = 65
        tableView.separatorStyle = .none
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 75, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        let cell = UINib.init(nibName: "BlacklistTbvCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "BlacklistTbvCell")
        
        
        return tableView
    }()
    
    //MARK: 移除黑名单
    @objc fileprivate func removeBlackList(sender:UIButton) {
        
        let userName = dataArray[sender.tag].username
        
        AlertClass.setAlertView(msg: "确定要移除黑名单?", target: self, haveCancel: true) { (alert) in
            
            JMSGUser.delUsers(fromBlacklist: [userName]) { (array, error) in
                
                if error == nil {
                    self.dataArray.remove(at: sender.tag)
                    self.tbvData.reloadData()
                }
            }
        }
        
        
        
        
    }
    
    
}
extension BlacklistVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell( withIdentifier: "BlacklistTbvCell", for: indexPath) as! BlacklistTbvCell
        
        let model = dataArray[indexPath.row]
        
        cell.btnAdd.tag = indexPath.row
        cell.btnAdd.addTarget(self, action: #selector(removeBlackList(sender:)), for: .touchUpInside)
        
        cell.btnAdd.setTitle("移除黑名单", for: .normal)
        cell.labTitle.text = model.nickname ?? model.username
        
        model.thumbAvatarData { (data, username, error) in
            
            if let imageData = data {
                let image = UIImage.init(data: imageData)
                cell.imvIcon.image = image
            }else{
                cell.imvIcon.image = chatDefaultHead
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
}
