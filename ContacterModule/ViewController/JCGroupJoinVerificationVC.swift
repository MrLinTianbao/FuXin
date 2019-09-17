//
//  JCIdentityVerificationViewController.swift
//  JChat
//
//  Created by JIGUANG on 2017/4/5.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit

class JCGroupJoinVerificationVC: CTViewController {
    
    var tableView : UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        _init()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UserDefaults.standard.set(0, forKey: kUnreadGroupInvitationCount)

    }
    
    private var infos = [JCGroupJoinInfoModel]()
    
    // MARK: - private func
    private func _init() {
        
        
        self.title = "群通知"
        view.backgroundColor = .white
        tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(JCVerificationCell.self, forCellReuseIdentifier: "JCVerificationCell")
        self.view.addSubview(tableView)

        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets.zero)
        }
        
        _getData()
       
    }
    
   
    @objc func _getData() {
        if let list = CacheClass.arrayForEnumKey(CacheClass.stringForEnumKey(.username)) as? [[String:Any]] {
            
            let modelArray = NSArray.yy_modelArray(with: JCGroupJoinInfoModel.self, json: list)
            infos = modelArray as! [JCGroupJoinInfoModel]
            tableView.reloadData()
            
        }
    }

    
}
extension JCGroupJoinVerificationVC: JCVerificationCellDelegate  {
    func clickAcceptButtonAt(info:JCGroupJoinInfoModel)
    {
        let user = JMSGUser.init(uid: info.uid)

        JMSGGroup.processApplyJoinEventID(info.eventID, gid: info.groupID, join: user!, apply: user!, isAgree: true, reason: nil) { (result, error) in
            info.state = 1
            self.tableView.reloadData()
            
            if let list =  MJOCManager.arrayOrDic(with: self.infos) as? [[String:Any]] {
                print("=================   \(list)")
                CacheClass.setObject(list, forEnumKey: CacheClass.stringForEnumKey(.username))
            }
        }

    }
}
extension JCGroupJoinVerificationVC:UITableViewDelegate,UITableViewDataSource {
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "JCVerificationCell", for: indexPath)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? JCVerificationCell else {
            return
        }
        cell.isGrouJoin = true
        cell.delegate = self
        let dic = infos[indexPath.row]
        cell.bindDataGroup(dic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            infos.remove(at: indexPath.row)
            tableView.reloadData()
            
            if let list =  MJOCManager.arrayOrDic(with: infos) as? [[String:Any]] {
                print("=================   \(list)")
                CacheClass.setObject(list, forEnumKey: CacheClass.stringForEnumKey(.username))
            }
        }
    }
}
