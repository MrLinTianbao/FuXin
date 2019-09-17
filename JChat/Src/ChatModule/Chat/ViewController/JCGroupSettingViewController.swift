//
//  JCGroupSettingViewController.swift
//  JChat
//
//  Created by JIGUANG on 2017/4/27.
//  Copy © 2017年 HXHG. All rights reserved.
//

import UIKit
import JMessage

class JCGroupSettingViewController: CTViewController {
    
    var group: JMSGGroup!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _init()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private var tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    fileprivate var memberCount = 0
    fileprivate lazy var users: [JMSGUser] = []
    fileprivate var isMyGroup = false
    fileprivate var isNeedUpdate = false
    var customType:CustomerType = .otherMember
    //MARK: - private func
    private func _init() {
        self.title = "群组信息"
        view.backgroundColor = .white

        users = group.memberArray()
        
//        users = users + users + users

        memberCount = users.count
        
//        let user = JMSGUser.myInfo()
//        && group.ownerAppKey == user.appKey!  这里group.ownerAppKey == "" 目测sdk bug
//        if group.owner == user.username  {
//            isMyGroup = true
//        }
        
        customType = MJManager.customerType()
//        customType = .inService
        
        
        
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionIndexColor = UIColor(netHex: 0x2dd0cf)
        tableView.sectionIndexBackgroundColor = .clear
        tableView.register(JCButtonCell.self, forCellReuseIdentifier: "JCButtonCell")
        tableView.register(JCMineInfoCell.self, forCellReuseIdentifier: "JCMineInfoCell")
        tableView.register(GroupAvatorCell.self, forCellReuseIdentifier: "GroupAvatorCell")
//        tableView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height-56)
        view.addSubview(tableView)
        
//        self.view.addSubview(exitGroupBtn)
        
//        exitGroupBtn.snp.makeConstraints { (make) in
//            make.left.right.bottom.equalToSuperview()
//            make.height.equalTo(56)
//        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(self.view)
        }
        
//        customLeftBarButton(delegate: self)
        
        JMSGGroup.groupInfo(withGroupId: group.gid) { (result, error) in
            if error == nil {
                guard let group = result as? JMSGGroup else {
                    return
                }
                self.group = group
                self.isNeedUpdate = true
                self._updateGroupInfo()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(_updateGroupInfo), name: NSNotification.Name(rawValue: kUpdateGroupInfo), object: nil)
    }
    
    fileprivate lazy var exitGroupBtn : UIButton = {
       
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.setTitle("退出此群", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(exitGroup), for: .touchUpInside)
        return button
    }()
    
    //MARK: 退出此群
    @objc fileprivate func exitGroup(sender:UIButton) {
        
        buttonCell(clickButton: sender)
    }
    
    @objc func _updateGroupInfo() {
        
        if !isNeedUpdate {
            let conv = JMSGConversation.groupConversation(withGroupId: group.gid)
            group = conv?.target as! JMSGGroup
        }
        if group.memberArray().count != memberCount {
            isNeedUpdate = true
            memberCount = group.memberArray().count
        }
        users = group.memberArray()
        memberCount = users.count
        tableView.reloadData()
        
        
        
//        if !isNeedUpdate {
//            let conv = JMSGConversation.groupConversation(withGroupId: group.gid)
//            group = conv?.target as? JMSGGroup
//        }
//        if group.memberArray().count != memberCount {
//            isNeedUpdate = true
//        }
//
//        group.memberInfoList {[weak self] (list, error) in
//            if let userArr = list as? [JMSGUser] {
//                if userArr.count != self?.memberCount {
//                    self?.isNeedUpdate = true
//                    self?.memberCount = userArr.count
//                }
//                self?.users = userArr
//                self?.memberCount = self?.users.count ?? 0
//                self?.tableView.reloadData()
//            }
//        }
        //////////11111
        
//        group.memberArray {[weak self] (list, error) in
//            if let userArr = list as? [JMSGUser] {
//                if userArr.count != self?.memberCount {
//                    self?.isNeedUpdate = true
//                    self?.memberCount = userArr.count
//                }
//                self?.users = userArr
//                self?.memberCount = self?.users.count ?? 0
//                self?.tableView.reloadData()
//            }
//
//        }
       
        
//        if group.memberArray().count != memberCount {
//            isNeedUpdate = true
//            memberCount = group.memberArray().count
//        }
//        users = group.memberArray()
//        memberCount = users.count
//        tableView.reloadData()
    }
    
}

extension JCGroupSettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 4
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 3
        case 3:
//            return 5
            return 3
        case 4:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if customType == .inService {
                if memberCount > 13 {
                    return 314
                }
                if memberCount > 8 {
                    return 260
                }
                if memberCount > 3 {
                    return 200
                }
                return 100
            }else if customType == .outService {
                if memberCount > 14 {
                    return 314
                }
                if memberCount > 9 {
                    return 260
                }
                if memberCount > 4 {
                    return 200
                }
                return 100
            }else{
                if memberCount > 15 {
                    return 314
                }
                if memberCount > 10 {
                    return 260
                }
                if memberCount > 5 {
                    return 200
                }
                return 100
            }
            
            
            
            
//            if isMyGroup {
//                if memberCount > 13 {
//                    return 314
//                }
//                if memberCount > 8 {
//                    return 260
//                }
//                if memberCount > 3 {
//                    return 200
//                }
//                return 100
//            } else {
//                if memberCount > 14 {
//                    return 314
//                }
//                if memberCount > 9 {
//                    return 260
//                }
//                if memberCount > 4 {
//                    return 200
//                }
//                return 100
//            }
            
        case 1:
            return 45
        case 2:
            return 45
        case 3:
            return 40
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return 0.0001
//        }
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.0001
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "JCGroupSettingCell") as? JCGroupSettingCell
            if isNeedUpdate {
                cell = JCGroupSettingCell(style: .default, reuseIdentifier: "JCGroupSettingCell", group: self.group)
                isNeedUpdate = false
            }
            if cell == nil {
                cell = JCGroupSettingCell(style: .default, reuseIdentifier: "JCGroupSettingCell", group: self.group)
            }
            return cell!
        }
        if indexPath.section == 4 {
            return tableView.dequeueReusableCell(withIdentifier: "JCButtonCell", for: indexPath)
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "GroupAvatorCell", for: indexPath)
        }
        
        if indexPath.section == 1 {
            return tableView.dequeueReusableCell(withIdentifier: "GroupAvatorCell", for: indexPath)
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "JCMineInfoCell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        if indexPath.section == 4 {
            guard let cell = cell as? JCButtonCell else {
                return
            }
            cell.buttonColor = UIColor(netHex: 0xEB424D)
            cell.buttonTitle = "退出此群"
            cell.delegate = self
            return
        }
        cell.accessoryType = .disclosureIndicator
        if indexPath.section == 0 {
            guard let cell = cell as? JCGroupSettingCell else {
                return
            }
            cell.bindData(self.group)
            cell.delegate = self
            cell.accessoryType = .none
            return
        }

        if let cell = cell as? GroupAvatorCell {
            
            if indexPath.section == 2 {
                cell.title = "群头像"
                cell.bindData(group)
            }else if indexPath.section == 1 {
                cell.title = "群二维码"
                cell.avator = UIImage.init(named: "二维码")
            }
            
            
        }

        guard let cell = cell as? JCMineInfoCell else {
            return
        }
        if indexPath.section == 3 {
            if indexPath.row == 0 {
                cell.delegate = self
                cell.indexPate = indexPath
                cell.accessoryType = .none
                cell.isSwitchOn = group.isNoDisturb
                cell.isShowSwitch = true
            }
            if indexPath.row == 1 {
                cell.delegate = self
                cell.indexPate = indexPath
                cell.accessoryType = .none
                cell.isSwitchOn = group.isShieldMessage
                cell.isShowSwitch = true
            }
        }
        if indexPath.section == 2 {
            let conv = JMSGConversation.groupConversation(withGroupId: self.group.gid)
            let group = conv?.target as! JMSGGroup
            switch indexPath.row {
            case 1:
                cell.title = "群聊名称"
                cell.detail = group.displayName()
            case 2:
                cell.title = "群描述"
                cell.detail = group.desc
            default:
                break
            }
        } else if indexPath.section == 3 {
            switch indexPath.row {
//            case 0:
//                cell.title = "聊天文件"
            case 0:
                cell.title = "消息免打扰"
            case 1:
                cell.title = "消息屏蔽"
//            case 2:
//                cell.title = "清理缓存"
            case 2:
                cell.title = "清空聊天记录"
            default:
                break
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
            
            if indexPath.section == 2 {
                
                let gid = CacheClass.stringForEnumKey(.groupid) ?? ""
                let customer_type = CacheClass.stringForEnumKey(.customer_type) ?? ""
                
                if gid == "5" && customer_type == "0" { //内部客服
                
                    switch indexPath.row {
                    case 0:
                        let vc = GroupAvatorViewController()
                        vc.group = group
                        navigationController?.pushViewController(vc, animated: true)
                    case 1:
                        let vc = JCGroupNameViewController()
                        vc.group = group
                        navigationController?.pushViewController(vc, animated: true)
                    case 2:
                        let vc = JCGroupDescViewController()
                        vc.group = group
                        navigationController?.pushViewController(vc, animated: true)
                    default:
                        break
                    }
                    
                }else{
                    MBProgressHUD_JChat.show(text: "你没有修改权限", view: self.view)
                }
            
            }

        
        
        
        if indexPath.section == 1 {
            
            let gid = CacheClass.stringForEnumKey(.groupid) ?? ""
            
            if gid == "5" { //客服
                let vc = UserQRCodeVC()//MJ
                vc.group = group
                navigationController?.pushViewController(vc, animated: true)
            }else{
                MBProgressHUD_JChat.show(text: "你没有权限", view: self.view)
            }
            
            
        }
        
        if indexPath.section == 3 {
            switch indexPath.row {
//            case 2:
//                let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "清理缓存")
//                actionSheet.tag = 1001
//                actionSheet.show(in: self.view)
//            case 0:
//                let vc = FileManagerViewController()
//                let conv = JMSGConversation.groupConversation(withGroupId: group.gid)
//                vc.conversation  = conv
//                navigationController?.pushViewController(vc, animated: true)
            case 2:
                let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "清空聊天记录")
                actionSheet.tag = 1001
                actionSheet.show(in: self.view)
            default:
                break
            }
        }
    }
}

extension JCGroupSettingViewController: UIAlertViewDelegate {
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        switch buttonIndex {
        case 1:
            MBProgressHUD_JChat.showMessage(message: "退出中...", toView: self.view)
            group.exit({ (result, error) in
                MBProgressHUD_JChat.hide(forView: self.view, animated: true)
                if error == nil {
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    MBProgressHUD_JChat.show(text: "\(String.errorAlert(error! as NSError))", view: self.view)
                }
            })
        default:
            break
        }
    }
}

extension JCGroupSettingViewController: JCMineInfoCellDelegate {
    func mineInfoCell(clickSwitchButton button: UISwitch, indexPath: IndexPath?) {
        if indexPath != nil {
            switch (indexPath?.row)! {
            case 1:
                if group.isNoDisturb == button.isOn {
                    return
                }
                // 消息免打扰
                group.setIsNoDisturb(button.isOn, handler: { (result, error) in
                    MBProgressHUD_JChat.hide(forView: self.view, animated: true)
                    if error != nil {
                        button.isOn = !button.isOn
                        MBProgressHUD_JChat.show(text: "\(String.errorAlert(error! as NSError))", view: self.view)
                    }
                })
            case 2:
                if group.isShieldMessage == button.isOn {
                    return
                }
                // 消息屏蔽
                group.setIsShield(button.isOn, handler: { (result, error) in
                    MBProgressHUD_JChat.hide(forView: self.view, animated: true)
                    if error != nil {
                        button.isOn = !button.isOn
                        MBProgressHUD_JChat.show(text: "\(String.errorAlert(error! as NSError))", view: self.view)
                    }
                })
            default:
                break
            }
        }
    }
}

extension JCGroupSettingViewController: JCButtonCellDelegate {
    func buttonCell(clickButton button: UIButton) {
        let alertView = UIAlertView(title: "退出此群", message: "确定要退出此群？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
        alertView.show()
    }
}

extension JCGroupSettingViewController: JCGroupSettingCellDelegate {
    func clickMoreButton(clickButton button: UIButton) {
        let vc = JCGroupMembersViewController()
        vc.group = self.group
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func clickAddCell(cell: JCGroupSettingCell) {
        
        let vc = JCUpdateMemberViewController()
        vc.group = group
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func clickRemoveCell(cell: JCGroupSettingCell) {
        let vc = JCRemoveMemberViewController()
        vc.group = group
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didSelectCell(cell: JCGroupSettingCell, indexPath: IndexPath) {
        let index = indexPath.section * 5 + indexPath.row
        let user = users[index]
        if user.isEqual(to: JMSGUser.myInfo()) {
            
            let chatVC  = ChatPersonalCenterVC()
            chatVC.isMySelf = true
            chatVC.user = user
            navigationController?.pushViewController(/**JCMyInfoViewController()**/chatVC, animated: true)
            return
        }
        let vc = ChatPersonalCenterVC() //JCUserInfoViewController()
        vc.group = group
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension JCGroupSettingViewController: UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
//        if actionSheet.tag == 1001 {
//            // SDK 暂无该功能
//        }
        
        if actionSheet.tag == 1001 {
            if buttonIndex == 1 {
                let conv = JMSGConversation.groupConversation(withGroupId: group.gid)
                conv?.deleteAllMessages()
                NotificationCenter.default.post(name: Notification.Name(rawValue: kDeleteAllMessage), object: nil)
                MBProgressHUD_JChat.show(text: "成功清空", view: self.view)
            }
        }
    }
}

//extension JCGroupSettingViewController: UIGestureRecognizerDelegate {
//    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        return true
//    }
//}
