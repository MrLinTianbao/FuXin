//
//  ViewController.swift
//  XLCustomer
//
//  Created by longma on 2018/10/16.
//  Copyright © 2018年 XLH. All rights reserved.
//

import UIKit

class WalletRechargeVC: CTViewController {
    let titleArray = [["支付宝"],["微信"],["转账(马币充值)"]]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "充值"
        
        self.setLocalData()
        self.setUIAppearance()
    }
    
    func setLocalData(){
        
    }
    func setUIAppearance(){
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
        tableView.separatorStyle = .none

        let cell = UINib.init(nibName: "MineWalletTbvCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "MineWalletTbvCell")
        

        return tableView
    }()
    lazy var tbvHeadView: MineWalletHeadView = {
        let tableHeadView = Bundle.main.loadNibNamed("MineWalletHeadView", owner: self, options: nil)?.last as! MineWalletHeadView
        tableHeadView.frame = CGRect(x: 0, y: 0, width: ScreenW, height: 110)
        tableHeadView.autoresizingMask = UIView.AutoresizingMask(rawValue: 0)
        
        return tableHeadView
    }()
   
}
extension WalletRechargeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = titleArray[section]
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell( withIdentifier: "MineWalletTbvCell", for: indexPath) as! MineWalletTbvCell
        cell.labTitle.text = titleArray[indexPath.section][indexPath.row]

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

        let title = titleArray[indexPath.section][indexPath.row]
        if title == "支付宝" {
            
            let vc = RechargVC.init(payType: "2")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if title == "微信" {
            
            let vc = RechargVC.init(payType: "1")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if title == "转账(马币充值)" {
//            self.pushViewController(targetStr: "TransferAccountsVC")
            
            let vc = TransferAccountsVC()
            
            vc.payType = "3"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
