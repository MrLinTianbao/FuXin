//
//  ViewController.swift
//  XLCustomer
//
//  Created by longma on 2018/10/16.
//  Copyright © 2018年 XLH. All rights reserved.
//

import UIKit

class MinePrivacySet: CTViewController {
    let titleArray = [["加我为朋友时需要验证"],["通讯录黑名单"]]
    
    fileprivate var isValidation = CacheClass.boolForEnumKey(.addFriendCertification) ?? true //是否需要验证
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setLocalData()
        self.setUIAppearance()
        getValidation()
    }
    
    func setLocalData(){
        
    }
    func setUIAppearance(){
        self.title = "隐私设置"
        self.view.addSubview(tbvData)
        tbvData.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
    }
    override func actionRightItemClick(){
        self.pushViewController(targetStr: "WalletRecordVC")

    }
    @objc func switchDidChange(_ sender: UISwitch){
        print(sender.isOn)
        
        
        
        MBProgressHUD_JChat.showMessage(message: "修改中", toView: view)
        
        NetworkRequest.requestMethod(.post, URLString: url_signUp, parameters: ["is_adding_friend_certification":sender.isOn ? "1" : "0","method":"PUT"], success: { (value, json) in
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
            
            if json["status"].stringValue == "SUCCESS" {
                
                self.isValidation = sender.isOn
                CacheClass.setObject(self.isValidation, forEnumKey: .addFriendCertification)
                
                MBProgressHUD_JChat.show(text: "修改成功", view: self.view)
            }else{
                MBProgressHUD_JChat.show(text: "修改失败", view: self.view)
            }
            
        }) {
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
        }
    }
    //MARK: **************************** 懒加载
    lazy var tbvData: UITableView = {
        
        let tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.KTheme.scroll
        tableView.rowHeight = 56
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.separatorStyle = .none

        let cell = UINib.init(nibName: "MineSwitchTbvCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "MineSwitchTbvCell")
        
        let cell1 = UINib.init(nibName: "MineWalletTbvCell", bundle: nil)
        tableView.register(cell1, forCellReuseIdentifier: "MineWalletTbvCell")
        

        return tableView
    }()
    
    //MARK: 获取验证信息
    fileprivate func getValidation() {
        
        NetworkRequest.requestMethod(.get, URLString: url_addFriValidation, parameters: ["username":UserDefaults.standard.object(forKey: kCurrentUserName) as? String ?? ""], success: { (value, json) in
            
            if json["status"].stringValue == "SUCCESS" {
                
                self.isValidation = json["ret_data"]["is_adding_friend_certification"].boolValue
                
                CacheClass.setObject(json["ret_data"]["is_adding_friend_certification"].bool ?? true, forEnumKey: .addFriendCertification)
                
                self.tbvData.reloadData()
            }
            
        }) {
            
        }
    }
    
   
}
extension MinePrivacySet: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = titleArray[section]
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell( withIdentifier: "MineWalletTbvCell", for: indexPath) as! MineWalletTbvCell
            cell.labTitle.text = titleArray[indexPath.section][indexPath.row]
            return cell
        }else{
            let cell = tableView.dequeueReusableCell( withIdentifier: "MineSwitchTbvCell", for: indexPath) as! MineSwitchTbvCell
            cell.labTitle.text = titleArray[indexPath.section][indexPath.row]
            cell.switchFlag.addTarget(self, action: #selector(switchDidChange(_:)), for: .valueChanged)
            cell.switchFlag.isOn = self.isValidation
            
            return cell
        }
        

    }
    /*分区头部部高度*/
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 8
        }
        return 0.01
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
        let title = titleArray[indexPath.section][indexPath.row]
        if title == "通讯录黑名单" {
            self.pushViewController(targetStr: "BlacklistVC")
        }

    }
    
}
