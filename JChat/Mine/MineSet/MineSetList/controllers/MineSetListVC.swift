//
//  ViewController.swift
//  XLCustomer
//
//  Created by longma on 2018/10/16.
//  Copyright © 2018年 XLH. All rights reserved.
//

import UIKit

class MineSetListVC: CTViewController {
    let titleArray = [["密码修改","隐私设置"],["新消息通知"],["清除缓存","关于我们"]]
    var targetArray = [["ChangeUserPasswardVC","MinePrivacySet"],["WithdrawApplyVC"],["WalletRechargeVC","AboutVC"]]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setLocalData()
        self.setUIAppearance()
    }
    
    func setLocalData(){
        
    }
    func setUIAppearance(){
        self.title = "设置"
        self.view.addSubview(tbvData)
        tbvData.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
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
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 0)
        tableView.separatorColor = UIColor.KTheme.line

        let cell = UINib.init(nibName: "MineWalletTbvCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "MineWalletTbvCell")
        let cell1 = UINib.init(nibName: "DistributionRecordTbvCell", bundle: nil)
        tableView.register(cell1, forCellReuseIdentifier: "DistributionRecordTbvCell")
        let cell2 = UINib.init(nibName: "MineSwitchTbvCell", bundle: nil)
        tableView.register(cell2, forCellReuseIdentifier: "MineSwitchTbvCell")
        tableView.tableFooterView = tbvFootView

        return tableView
    }()
    lazy var tbvFootView: MineFootBtnView = {
        let tableFootView = Bundle.main.loadNibNamed("MineFootBtnView", owner: self, options: nil)?.last as! MineFootBtnView
        tableFootView.frame = CGRect(x: 0, y: 0, width: ScreenW, height: 56)
        tableFootView.autoresizingMask = UIView.AutoresizingMask(rawValue: 0)
        tableFootView.btnSimple.addTarget(self, action: #selector(signOutAction), for: .touchUpInside)
        
        return tableFootView
    }()
    
    //MARK: 设置新消息通知
    @objc fileprivate func setNewsNotice(sender:UISwitch) {
        
        JMessage.setIsGlobalNoDisturb(!sender.isOn) { (result, error) in
            if error != nil{
                print("***************** 失败")
            }else{
                print("***************** 成功")

            }
        }
    }
    
    //MARK: 退出登录
    @objc fileprivate func signOutAction() {
        
        AlertClass.setAlertView(msg: "你确定要退出登录吗?", target: self, haveCancel: true) { (alert) in
            
            JMSGUser.logout({ (result, error) in
                JCVerificationInfoDB.shareInstance.queue = nil
                //            Account.removeObjectForKey(kCurrentUserToken)
                UserDefaults.standard.removeObject(forKey: kCurrentUserName)
                UserDefaults.standard.removeObject(forKey: kCurrentUserPassword)
                removeUseNews()
                let appDelegate = UIApplication.shared.delegate
                let window = appDelegate?.window!
                window?.rootViewController = JCNavigationController(rootViewController: SignInViewController())
                
                AsyncSocket.share.isLogout = true
                AsyncSocket.share.stopConnect() //断开长链接
            })
        }
        
        
        
    }
    
    //MARK: 计算缓存文件大小
    func getCacheSize()-> String {
        // 取出cache文件夹目录
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        
        // 取出文件夹下所有文件数组
        let fileArr = FileManager.default.subpaths(atPath: cachePath!)
        
        //快速枚举出所有文件名 计算文件大小
        var size = 0
        for file in fileArr! {
            
            // 把文件名拼接到路径中
            let path = cachePath! + ("/\(file)")
            // 取出文件属性
            let floder = try! FileManager.default.attributesOfItem(atPath: path)
            // 用元组取出文件大小属性
            for (key, fileSize) in floder {
                // 累加文件大小
                if key == FileAttributeKey.size {
                    size += (fileSize as AnyObject).integerValue
                }
            }
        }
        
        let totalCache = Double(size) / 1024.00 / 1024.00
        return String(format: "%.2fM", totalCache)
        
    }
    
    //MARK: 清除缓存
    func clearCache() {
        
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        
        
        let fileArr = FileManager.default.subpaths(atPath: cachePath!)
        
        
        
        // 遍历删除
        
        for file in fileArr! {
            
            let path = (cachePath! as NSString).appending("/\(file)")
            
            if FileManager.default.fileExists(atPath: path) {
                
                do {
                    
                    try FileManager.default.removeItem(atPath: path)
                    
                } catch {
                    
                    
                    
                }
                
            }
            
        }
        
        tbvData.reloadData()
        
        
    }
}
extension MineSetListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = titleArray[section]
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell( withIdentifier: "MineWalletTbvCell", for: indexPath) as! MineWalletTbvCell
            cell.labTitle.text = titleArray[indexPath.section][indexPath.row]
            
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell( withIdentifier: "MineSwitchTbvCell", for: indexPath) as! MineSwitchTbvCell
            cell.labTitle.text = titleArray[indexPath.section][indexPath.row]
            cell.switchFlag.isOn = !JMessage.isSetGlobalNoDisturb()
            cell.switchFlag.addTarget(self, action: #selector(setNewsNotice(sender:)), for: .valueChanged)
            return cell
        }else{
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell( withIdentifier: "DistributionRecordTbvCell", for: indexPath) as! DistributionRecordTbvCell
                cell.labTitle.text = titleArray[indexPath.section][indexPath.row]
                cell.labSubTitle.text = getCacheSize()
                cell.labSubTitle.textColor = UIColor.KTheme.shallowGray
                
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell( withIdentifier: "MineWalletTbvCell", for: indexPath) as! MineWalletTbvCell
                cell.labTitle.text = titleArray[indexPath.section][indexPath.row]
                
                return cell
            }
        }
        
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
        if section == 2 {
            return 8
        }
        return 0.01
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 1 {
            return
        }
        else if indexPath.section == 2 && indexPath.row == 0{
            
            AlertClass.setAlertView(msg: "你确定要清除缓存吗?", target: self, haveCancel: true) { (alert) in
                
                self.clearCache()
            }
            
        }else{
            self.pushViewController(targetStr: targetArray[indexPath.section][indexPath.row])
        }

    }
    
}
