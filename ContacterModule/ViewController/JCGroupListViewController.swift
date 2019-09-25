//
//  JCGroupListViewController.swift
//  JChat
//
//  Created by JIGUANG on 2017/3/16.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit
import JMessage

class JCGroupListViewController: CTViewController {

    var message: JMSGMessage?
    var fromUser: JMSGUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        _init()
    }

    var groupList: [JMSGGroup] = []
    private lazy var defaultImage: UIImage? = chatGroupDefaultHead
    fileprivate var selectGroup: JMSGGroup!
    //MARK: **************************** 懒加载
    lazy var tableView: UITableView = {
        
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.KTheme.scroll
        tableView.rowHeight = 56
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.separatorStyle = .none
        tableView.register(JCTableViewCell.self, forCellReuseIdentifier: "JCGroupListCell")
        
        
        return tableView
    }()
    // MARK: - private func
    private func _init() {
        self.title = "群组"
        view.backgroundColor = .white
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        
        _getGroupList()
    }
    
    private func _getGroupList() {
        MBProgressHUD_JChat.showMessage(message: "加载中...", toView: tableView)
        JMSGGroup.myGroupArray { (result, error) in
            if error == nil {
                self.groupList.removeAll()
                let gids = result as! [NSNumber]
                if gids.count == 0 {
                    MBProgressHUD_JChat.hide(forView: self.tableView, animated: true)
                    return
                }
                for gid in gids {
                    JMSGGroup.groupInfo(withGroupId: "\(gid)", completionHandler: { (result, error) in
                        guard let group = result as? JMSGGroup else {
                            return
                        } 
                        self.groupList.append(group)
                        if self.groupList.count == gids.count {
                            MBProgressHUD_JChat.hide(forView: self.tableView, animated: true)
                            self.groupList = self.groupList.sorted(by: { (g1, g2) -> Bool in
                                return g1.displayName().firstCharacter() < g2.displayName().firstCharacter()
                            })
                            self.tableView.reloadData()
                        }
                        self.showEmptyView()
                    })
                }
                
                
            } else {
                MBProgressHUD_JChat.hide(forView: self.tableView, animated: true)
                MBProgressHUD_JChat.show(text: "加载失败", view: self.view)
            }
        }
        
    }

    
    func showEmptyView(){
        if(self.groupList.count>0){
            self.hideEmptyView(view: tableView)
        }else{
            self.showEmptyView(view: tableView, emptyStyle: .emptyViewNoData)
        }
    }
    private func sendBusinessCard() {
        JCAlertView.bulid().setTitle("发送给：\(selectGroup.displayName())")
            .setMessage(fromUser!.displayName() + "的名片")
            .setDelegate(self)
            .addCancelButton("取消")
            .addButton("确定")
            .setTag(10003)
            .show()
    }

    private func forwardMessage(_ message: JMSGMessage) {
        JCAlertView.bulid().setJMessage(message)
            .setTitle("发送给：\(selectGroup.displayName())")
            .setDelegate(self)
            .setTag(10001)
            .show()
    }

}
extension JCGroupListViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupList.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JCGroupListCell", for: indexPath)
        
        let group = groupList[indexPath.row]
        cell.textLabel?.text = group.displayName()
        cell.imageView?.image = defaultImage
        cell.imageView?.contentMode = .scaleAspectFit
        group.thumbAvatarData({ (data, _, error) in
            if let data = data {
                cell.imageView?.image = UIImage(data: data)
            }
        })
        
        
        return cell
    }
    
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let group = groupList[indexPath.row]
        selectGroup = group
        if let message = message {
            forwardMessage(message)
            return
        }
        
        if fromUser != nil {
            sendBusinessCard()
            return
        }
        JMSGConversation.createGroupConversation(withGroupId: group.gid) { (result, error) in
            if let conv = result as? JMSGConversation {
                let vc = JCChatViewController(conversation: conv)
                
                if let target = conv.target as? JMSGGroup {
                    //保存未读消息数
                    CacheClass.setObject("0", forEnumKey: JMSGUser.myInfo().username + target.gid)
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateConversation), object: nil, userInfo: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
extension JCGroupListViewController: UIAlertViewDelegate {
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != 1 {
            return
        }
        switch alertView.tag {
        case 10001:
            JMSGMessage.forwardMessage(message!, target: selectGroup, optionalContent: JMSGOptionalContent.ex.default)

        case 10003:
            let msg = JMSGMessage.ex.createBusinessCardMessage(gid: selectGroup.gid, userName: fromUser!.username, appKey: fromUser?.appKey ?? "")
            JMSGMessage.send(msg, optionalContent: JMSGOptionalContent.ex.default)

        default:
            break
        }
        MBProgressHUD_JChat.show(text: "已发送", view: view, 2)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)
        }
        weak var weakSelf = self
        let time: TimeInterval = 2
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            weakSelf?.dismiss(animated: true, completion: nil)
        }
    }
}
